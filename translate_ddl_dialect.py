# This script reads the DDL statements from the Postgres sql files and translates them to the specified dialect.
# It then creates the databases and tables from the translated DDL statements.
# Finally, it queries the database to check that values were insert into tables.

import os
import time
from tqdm import tqdm
from utils_dialects import (
    create_bq_db,
    create_mysql_db,
    create_sqlite_db,
    create_tsql_db,
    test_query_db,
    conv_ddl_to_dialect
)

# List of databases to create
db_names = [
    "academic",
    "advising",
    "atis",
    "broker",
    "car_dealership",
    "derm_treatment",
    "ewallet",
    "geography",
    "restaurants",
    "scholar",
    "yelp",
]
dialects = [
    "bigquery",
    "mysql",
    "sqlite",
    "tsql",
]  # Supported dialects: bigquery, mysql, sqlite, tsql
bigquery_proj = os.getenv("BIGQUERY_PROJ")

# For testing that values were inserted into tables, format: (db_name, table_name)
test_queries = [
    ("academic", "writes"),
    ("advising", "student_record"),
    ("atis", "time_zone"),
    ("broker", "sbTransaction"),
    ("car_dealership", "payments_made"),
    ("derm_treatment", "concomitant_meds"),
    ("ewallet", "consumer_div.user_setting_snapshot"),
    ("geography", "state"),
    ("restaurants", "restaurant"),
    ("scholar", "writes"),
    ("yelp", "users"),
]

# Run the main function
def main():
    for dialect in tqdm(dialects):
        print(f"Translating DDL to {dialect} dialect...")
        for db_name in tqdm(db_names):
            conv_ddl_to_dialect(db_name, dialect)
            if dialect == "bigquery":
                create_bq_db(bigquery_proj, db_name)
                time.sleep(10)
            elif dialect == "mysql":
                create_mysql_db(db_name)
            elif dialect == "sqlite":
                create_sqlite_db(db_name)
            elif dialect == "tsql":
                create_tsql_db(db_name)
            tries = 0
            while tries < 20:
                try:
                    test_query_db(db_name, dialect, test_queries)
                    break
                except Exception as e:
                    if "not found" in str(e):
                        # print(f"Table not found. Retrying...")
                        tries += 1
                        continue
                    else:
                        break


if __name__ == "__main__":
    main()
