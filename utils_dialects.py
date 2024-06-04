import sqlglot
from google.cloud import bigquery
import mysql.connector
from mysql.connector import errorcode
import pyodbc
import sqlite3
import re
import os
import time

GOOGLE_APPLICATION_CREDENTIALS = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
bigquery_proj = os.getenv("BIGQUERY_PROJ")
creds = {
    "mysql": {
        "user": "root",
        "password": "password",
        "host": "localhost",
    },
    "tsql": {
        "server": os.getenv("TSQL_SERVER"),
        "user": "test_user",
        "password": "password",
        "driver": "{ODBC Driver 17 for SQL Server}",
    },
}


def fix_ddl_bigquery(translated_ddl):
    """
    Fix the translated DDL for BigQuery
    """
    translated_ddl = re.sub(
        r"NOT NULL DEFAULT CURRENT_TIMESTAMP\(\)",
        "DEFAULT CAST(CURRENT_TIMESTAMP() AS DATETIME) NOT NULL",
        translated_ddl,
    )
    # translated_ddl = re.sub(
    #     r"DEFAULT\s+('[^']*'|\d+|[a-zA-Z_]+\(\))", "", translated_ddl
    # )
    translated_ddl = re.sub(
        r"SERIAL(PRIMARY KEY)?", "INT64", translated_ddl
    )
    translated_ddl = translated_ddl.replace("EXTRACT(EPOCH FROM ", "UNIX_SECONDS(")
    translated_ddl = re.sub(
        r", (TIMESTAMP_TRUNC\(CURRENT_DATE, (DAY|MIN|WEEK|MONTH|YEAR)\))",
        lambda match: rf", CAST({match.group(1)} AS DATE)",
        translated_ddl,
    )
    translated_ddl = re.sub(
        r"(TIMESTAMP_TRUNC\(CURRENT_DATE|CURRENT_DATE(?!,))(.+?\s*.+? INTERVAL\s*'\d+'\s*(DAY|MIN|WEEK|MONTH|YEAR))",
        lambda match: rf"CAST({match.group(1)}{match.group(2)} AS DATE)",
        translated_ddl,
    )
    translated_ddl = re.sub(
        r"(?<!UNIX_SECONDS\()"
        r"(TIMESTAMP_TRUNC\(CURRENT_TIMESTAMP\(\),\s*(DAY|MONTH|YEAR|WEEK)\)|CURRENT_TIMESTAMP\(\)(?!,))"
        r"(\s*.+? INTERVAL\s*'\d+'\s*(DAY|MIN|WEEK|MONTH|YEAR))",
        lambda match: rf"CAST({match.group(1)} AS DATETIME){match.group(3)}",
        translated_ddl,
    )
    translated_ddl = re.sub(
        r"AS DATE\) (\+|-) INTERVAL '(\d+)' (DAY|MIN|WEEK|MONTH|YEAR)",
        lambda match: f"{match.group(1)} INTERVAL {match.group(2)} {match.group(3)} AS DATE)",
        translated_ddl,
    )
    translated_ddl = re.sub(r"\bMIN\b", "MINUTE", translated_ddl)
    return translated_ddl


def fix_ddl_mysql(translated_ddl):
    """
    Fix the translated DDL for MySQL
    """
    translated_ddl = re.sub(r"VARCHAR(?!\()", "VARCHAR(255)", translated_ddl)
    translated_ddl = re.sub(r"CAST\('0' AS SIGNED\)", "0", translated_ddl)
    translated_ddl = re.sub(
        r"TEXT DEFAULT CAST\('([^']*)' AS CHAR\)", "TEXT", translated_ddl
    )
    reserved_keywords = [
        "long",
        "rank",
    ]
    for keyword in reserved_keywords:
        translated_ddl = re.sub(
            rf"\b{keyword}\b", f"`{keyword}`", translated_ddl, flags=re.IGNORECASE
        )

    def replace_timestamp_trunc(match):
        timestamp = match.group(1)
        unit = match.group(2).upper()
        if unit == "YEAR":
            return f"DATE_FORMAT({timestamp}, '%Y-01-01')"
        elif unit == "MONTH":
            return f"DATE_FORMAT({timestamp}, '%Y-%m-01')"
        elif unit == "DAY":
            return f"DATE({timestamp})"
        elif unit == "WEEK":
            return f"DATE_SUB({timestamp}, INTERVAL WEEKDAY({timestamp}) DAY)"
        else:
            raise ValueError(f"Unsupported unit for TIMESTAMP_TRUNC: {unit}")

    translated_ddl = re.sub(
        r"TIMESTAMP_TRUNC\(([^,]+),\s*(YEAR|MONTH|DAY|WEEK)\)\s*",
        replace_timestamp_trunc,
        translated_ddl,
    )
    translated_ddl = re.sub(
        r"EXTRACT\(EPOCH FROM CURRENT_TIMESTAMP\(\)",
        r"UNIX_TIMESTAMP(CURRENT_TIMESTAMP()",
        translated_ddl,
    )

    def replace_interval(match):
        value = match.group(1)
        unit = match.group(2).upper().rstrip("S")
        if unit == "MIN":
            unit = "MINUTE"
        return f"INTERVAL {value} {unit}"

    translated_ddl = re.sub(
        r"INTERVAL '(\d+)' (YEARS?|DAYS?|MONTHS?|WEEKS?|MINS?)",
        replace_interval,
        translated_ddl,
    )
    return translated_ddl


def fix_ddl_sqlite(translated_ddl):
    """
    Fix the translated DDL for SQLite
    """
    translated_ddl = re.sub(
        r"SERIAL(PRIMARY KEY)?", "INTEGER PRIMARY KEY", translated_ddl
    )
    translated_ddl = re.sub(
        r"DEFAULT\s+CAST\('([^']*)' AS [A-Z]*\)", r"DEFAULT '\1'", translated_ddl
    )
    # remove start of week/month/day to simplify date just for sqlite
    translated_ddl = re.sub(
        r"TIMESTAMP_TRUNC\((.+?),\s*(MONTH|WEEK|DAY)\)",
        lambda match: f"{match.group(1)}",
        translated_ddl,
    )
    translated_ddl = re.sub(
        r"CURRENT_(TIMESTAMP|DATE) (\+|-) INTERVAL '(\d+)' (YEARS?|DAYS?|MONTHS?|WEEKS?)",
        lambda match: (
            f"{'DATETIME' if match.group(1) == 'TIMESTAMP' else 'DATE'}("
            f"'now', '{match.group(2)}{match.group(3)} {match.group(4).lower()}')"
        ),
        translated_ddl,
    )

    def replace_interval(match):
        value = match.group(2)
        unit = match.group(3).upper().rstrip("S")
        if unit == "MIN":
            unit = "MINUTE"
        return f", '{match.group(1)}{value} {unit.lower()}')"

    translated_ddl = re.sub(
        r"\) (\+|-) INTERVAL '(\d+)' (YEARS?|DAYS?|MONTHS?|WEEKS?|MINS?)",
        replace_interval,
        translated_ddl,
    )
    # repeated to handle multiple occurences
    translated_ddl = re.sub(
        r"\) (\+|-) INTERVAL '(\d+)' (YEARS?|DAYS?|MONTHS?|WEEKS?|MINS?)",
        replace_interval,
        translated_ddl,
    )
    translated_ddl = re.sub(
        r"EXTRACT\(EPOCH FROM ([^)]+)\)",
        lambda match: f"strftime('%s', {match.group(1)})",
        translated_ddl,
    )
    translated_ddl = re.sub(
        r"EXTRACT\(EPOCH FROM CURRENT_TIMESTAMP\)",
        r"strftime('%s', CURRENT_TIMESTAMP)",
        translated_ddl,
    )
    # recalculate weeks as days because sqlite doesn't support weeks
    translated_ddl = re.sub(
        r"(\d+) weeks?",
        lambda match: f"{int(match.group(1)) * 7} days",
        translated_ddl,
    )
    return translated_ddl


def fix_ddl_tsql(translated_ddl):
    """
    Fix the translated DDL for T-SQL
    """
    translated_ddl = translated_ddl.replace("(1 = 1),\n", "1,")
    translated_ddl = translated_ddl.replace("(1 = 0),\n", "0,")
    translated_ddl = translated_ddl.replace("(1 = 1))", "1)")
    translated_ddl = translated_ddl.replace("(1 = 0))", "0)")
    translated_ddl = re.sub(r"VARCHAR(?!\()", "VARCHAR(255)", translated_ddl)
    # replace SERIAL datatype with INTEGER
    translated_ddl = re.sub(
        r"SERIAL(PRIMARY KEY)?", "INTEGER", translated_ddl
    )
    translated_ddl = re.sub(
        r"GETDATE\(\) (\+|-) INTERVAL '(\d+)' (YEARS?|DAYS?|MONTHS?|WEEKS?|MINS?)",
        lambda match: f"DATEADD({match.group(3).rstrip('S')}, {'-' if match.group(1) == '-' else ''}{match.group(2)}, GETDATE())",
        translated_ddl,
    )

    def replace_timestamp_trunc(match):
        expression = match.group(1).strip()
        unit = match.group(2).strip().upper()
        if unit == "MONTH":
            return f"DATEADD(DAY, 1, EOMONTH({expression}, -1))"
        elif unit == "WEEK":
            if "DATEADD" in expression:
                return (
                    f"DATEADD(DAY, -DATEPART(WEEKDAY, {expression}) + 1, {expression})"
                )
            else:
                return f"DATEADD(DAY, -DATEPART(WEEKDAY, {expression}) + 1, CAST({expression} AS DATE))"
        else:
            raise ValueError(f"Unsupported unit for TIMESTAMP_TRUNC: {unit}")

    translated_ddl = re.sub(
        r"TIMESTAMP_TRUNC\((.+?),\s*(MONTH|WEEK)\)",
        replace_timestamp_trunc,
        translated_ddl,
    )
    # replace INTERVAL with DATEADD
    translated_ddl = re.sub(
        r"(DATEADD.+?)\) (\+|-) INTERVAL '(\d+)' (YEARS?|DAYS?|MONTHS?|WEEKS?)",
        lambda match: f"DATEADD({match.group(4).rstrip('S')}, {'-' if match.group(2) == '-' else ''}{match.group(3)}, {match.group(1)}))",
        translated_ddl,
    )
    # repeated to handle multiple occurences
    translated_ddl = re.sub(
        r"(DATEADD.+?)\) (\+|-) INTERVAL '(\d+)' (YEARS?|DAYS?|MONTHS?|WEEKS?)",
        lambda match: f"DATEADD({match.group(4).rstrip('S')}, {'-' if match.group(2) == '-' else ''}{match.group(3)}, {match.group(1)}))",
        translated_ddl,
    )
    # replace specific occurrence in ewallet
    translated_ddl = re.sub(
        r"DATEADD\(DAY, (-?\d+), GETDATE\(\)\) (\+|-) INTERVAL '(\d+)' MIN",
        lambda match: f"DATEADD(MINUTE, {'-' if match.group(2) == '-' else ''}{match.group(3)}, DATEADD(DAY, {match.group(1)}, GETDATE()))",
        translated_ddl,
    )
    translated_ddl = re.sub(
        r"DATEPART\(EPOCH, ([^)]+)\)",
        r"DATEDIFF(SECOND, '1970-01-01', \1)",
        translated_ddl,
    )
    return translated_ddl


def conv_ddl_to_dialect(db_name, dialect):
    """
    Convert DDL statements from postgres to dialect
    """
    folder_name = f"defog_data/{db_name}"
    file_name = f"{folder_name}/{db_name}.sql"
    # open the file
    with open(file_name, "r") as f:
        lines = f.readlines()
        # remove lines that start with PRIMARY or FOREIGN or UNIQUE
        lines = [
            line
            for line in lines
            if not any(
                line.strip().startswith(keyword)
                for keyword in ["PRIMARY", "FOREIGN", "UNIQUE", "CONSTRAINT", "--"]
            )
        ]
        # join the list as a str
        lines = "".join(lines)

    # translate with sqlglot
    translated_ddl = sqlglot.transpile(lines, read="postgres", write=dialect)

    # fix translated ddl with regex depending on the dialect
    translated_ddl = "\n".join(translated_ddl)
    if dialect == "bigquery":
        if not bigquery_proj:
            raise ValueError(
                "Please set the `bigquery_proj` variable to your project ID"
            )
        translated_ddl = translated_ddl.replace(
            "CREATE TABLE ", f"\nCREATE TABLE {bigquery_proj}.{db_name}."
        )
        translated_ddl = translated_ddl.replace(
            "INSERT INTO ", f"\nINSERT INTO {bigquery_proj}.{db_name}."
        )

    else:
        translated_ddl = translated_ddl.replace("CREATE TABLE", f"\nCREATE TABLE")
        translated_ddl = translated_ddl.replace("INSERT INTO", f"\nINSERT INTO")
    translated_ddl = re.sub(
        r"REFERENCES\s+[a-zA-Z_][a-zA-Z0-9_.]*\s*\(\s*[a-zA-Z_][a-zA-Z0-9_.]*\s*\)",
        "",
        translated_ddl,
    )
    translated_ddl = translated_ddl.replace("public.", "")
    translated_ddl = translated_ddl.replace("UNIQUE", "")
    translated_ddl = translated_ddl.replace("VALUES", "VALUES\n")
    translated_ddl = translated_ddl.replace("),", "),\n")
    translated_ddl = translated_ddl.replace(")\n\nCREATE", ");\n\nCREATE")
    translated_ddl = translated_ddl.replace(")\n\nINSERT", ");\n\nINSERT")
    translated_ddl = translated_ddl.replace(" PRIMARY KEY", "")

    # remove schema for mysql, sqlite and bigquery since they don't support it
    if dialect in ["mysql", "sqlite", "bigquery"]:
        schema_names = re.findall(
            r"CREATE SCHEMA IF NOT EXISTS ([a-zA-Z_][a-zA-Z0-9_]*)", translated_ddl
        )
        if schema_names:
            for schema_name in schema_names:
                translated_ddl = translated_ddl.replace(
                    f"CREATE SCHEMA IF NOT EXISTS {schema_name}", ""
                )
                translated_ddl = translated_ddl.replace(f"{schema_name}.", "")

    if dialect == "bigquery":
        translated_ddl = fix_ddl_bigquery(translated_ddl)
    if dialect == "mysql":
        translated_ddl = fix_ddl_mysql(translated_ddl)
    if dialect == "sqlite":
        translated_ddl = fix_ddl_sqlite(translated_ddl)
    if dialect == "tsql":
        translated_ddl = fix_ddl_tsql(translated_ddl)
    translated_ddl += ";"

    # save the translated ddl
    translated_file_name = f"{folder_name}/{db_name}_{dialect}.sql"
    with open(translated_file_name, "w") as f:
        f.write(translated_ddl)
    # print(f"{dialect} DDL saved to {translated_file_name}")


def create_bq_db(bigquery_proj, db_name):
    """
    Create a BigQuery dataset and tables from the sql file
    """
    # Create a client
    client = bigquery.Client(project=bigquery_proj)

    # Create a dataset
    dataset_id = f"{bigquery_proj}.{db_name}"
    dataset = bigquery.Dataset(dataset_id)
    dataset.location = "US"
    try:
        client.delete_dataset(dataset_id, delete_contents=True, not_found_ok=True)
        created_dataset = client.create_dataset(dataset, timeout=30, exists_ok=True)
        # print("Dataset created successfully. Full ID:", created_dataset.full_dataset_id,)
    except Exception as e:
        print(e)

    sql_path = f"defog_data/{db_name}/{db_name}_bigquery.sql"
    with open(sql_path, "r") as file:
        sql = file.read()
    try:
        client.query(sql)
        # print(f"Tables for `{db_name}` created successfully")
    except Exception as e:
        print(e)


def create_mysql_db(db_name):
    """
    Create a MySQL database and tables from the sql file
    """
    try:
        conn = mysql.connector.connect(**creds["mysql"])
        cursor = conn.cursor()
        cursor.execute(f"DROP DATABASE IF EXISTS {db_name};")
        cursor.execute(f"CREATE DATABASE {db_name};")
        # print(f"Database `{db_name}` created successfully")

    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Something is wrong with your user name or password")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print(f"Database `{db_name}` does not exist")
        elif "Lost connection" in str(err):
            time.sleep(2)
            if conn in locals():
                conn.close()
            if cursor in locals():
                cursor.close()
            print(f"Lost connection for `{db_name}`. Retrying...")
            create_mysql_db(db_name)
        else:
            print(err)
        raise

    sql_path = f"defog_data/{db_name}/{db_name}_mysql.sql"
    with open(sql_path, "r") as file:
        sql = file.read()

    try:
        cursor.execute(f"USE {db_name};")
        for result in cursor.execute(sql, multi=True):
            pass
        conn.commit()
        # print(f"Tables for `{db_name}` created successfully")
    except Exception as e:
        print(f"Error creating tables for `{db_name}`: {e}")
        raise
    finally:
        if "cursor" in locals():
            cursor.close()
        if "conn" in locals():
            conn.close()


def create_sqlite_db(db_name):
    """
    Create a SQLite database and tables from the sql file
    """

    sql_path = f"defog_data/{db_name}/{db_name}_sqlite.sql"
    with open(sql_path, "r") as file:
        sql = file.read()
    # create sqlite_dbs directory if it doesn't exist
    if not os.path.exists("sqlite_dbs"):
        os.makedirs("sqlite_dbs")

    try:
        if os.path.exists(f"sqlite_dbs/{db_name}.db"):
            os.remove(f"sqlite_dbs/{db_name}.db")
        conn = sqlite3.connect(f"sqlite_dbs/{db_name}.db")
        cursor = conn.cursor()
        commands = sql.split(");")
        # strip all the commands
        commands = [command.strip() for command in commands]
        # remove empty strings
        commands = list(filter(None, commands))
        # add back the semicolon
        commands = [command + ");" for command in commands]

        try:
            for command in commands:
                cursor.execute(command)
        except Exception as e:
            print(f"Error creating tables for command: {command}\nError: {e}")
            raise

        conn.commit()
        # print(f"Tables for `{db_name}` created successfully")
    except Exception as e:
        print(f"Error creating database or tables for `{db_name}`: {e}")
        raise
    finally:
        if "cursor" in locals():
            cursor.close()
        if "conn" in locals():
            conn.close()


def create_tsql_db(db_name):
    """
    Create a T-SQL database and tables from the sql file
    """
    try:
        with pyodbc.connect(
            f"DRIVER={creds['tsql']['driver']};SERVER={creds['tsql']['server']};UID={creds['tsql']['user']};PWD={creds['tsql']['password']}"
        ) as conn:
            conn.autocommit = True
            with conn.cursor() as cursor:
                cursor.execute(f"DROP DATABASE IF EXISTS {db_name};")
                cursor.execute(f"CREATE DATABASE {db_name};")
                # print(f"Database `{test_db_name}` created successfully")
    except pyodbc.Error as err:
        if err.args[0] == "28000":
            print("Something is wrong with your user name or password")
        elif err.args[0] == "42000":
            print(f"Database `{db_name}` already exists")
            pass
        elif "Communication link failure" in str(err):
            time.sleep(2)
            print(f"Lost connection for `{db_name}`. Retrying...")
            create_tsql_db(db_name)
        else:
            print(err)
        raise

    sql_path = f"defog_data/{db_name}/{db_name}_tsql.sql"
    with open(sql_path, "r") as file:
        sql = file.read()

    try:
        with pyodbc.connect(
            f"DRIVER={creds['tsql']['driver']};SERVER={creds['tsql']['server']};DATABASE={db_name};UID={creds['tsql']['user']};PWD={creds['tsql']['password']}"
        ) as conn:
            with conn.cursor() as cursor:
                cursor.execute(f"USE {db_name};")
                cursor.execute(sql)
                # print(f"Tables for `{db_name}` created successfully")
    except Exception as e:
        print(f"Error creating tables for `{db_name}`: {e}")
        raise
    finally:
        if "cursor" in locals():
            cursor.close()
        if "conn" in locals():
            conn.close()


def test_query_db(db_name, dialect, test_queries):
    """
    Query the database to check if that values were insert into tables
    """
    for db, table_name in test_queries:
        if db == db_name:
            if dialect == "bigquery":
                tries = 0
                table_name = table_name.split(".")[-1]
                client = bigquery.Client(project=bigquery_proj)
                query = f"SELECT * FROM {bigquery_proj}.{db_name}.{table_name}"
                while tries < 5:
                    time.sleep(10 * tries)
                    query_job = client.query(query)
                    results = query_job.result()
                    if results.total_rows == 0 and tries == 3:
                        print(f"WARNING: No values found for `{db_name}`")
                        break
                    elif results.total_rows == 0:
                        print(f"Retrying to find values for `{db_name}`")
                        tries += 1
                        continue
                    else:
                        print(f"Values found for `{db_name}`")
                        break

            elif dialect == "mysql":
                table_name = table_name.split(".")[-1]
                conn = mysql.connector.connect(**creds["mysql"], database=db_name)
                cursor = conn.cursor()
                cursor.execute(f"SELECT * FROM {table_name}")
                query_job = cursor.fetchall()
                if not query_job:
                    print(f"WARNING: No values found for `{db_name}`")
            elif dialect == "sqlite":
                table_name = table_name.split(".")[-1]
                conn = sqlite3.connect(f"sqlite_dbs/{db_name}.db")
                cursor = conn.cursor()
                cursor.execute(f"SELECT * FROM {table_name}")
                query_job = cursor.fetchall()
                if not query_job:
                    print(f"WARNING: No values found for `{db_name}`")
            elif dialect == "tsql":
                with pyodbc.connect(
                    f"DRIVER={creds['tsql']['driver']};SERVER={creds['tsql']['server']};DATABASE={db_name};UID={creds['tsql']['user']};PWD={creds['tsql']['password']}"
                ) as conn:
                    with conn.cursor() as cursor:
                        cursor.execute(f"SELECT * FROM {table_name}")
                        query_job = cursor.fetchall()
                        if not query_job:
                            print(f"WARNING: No values found for `{db_name}`")
        else:
            pass
