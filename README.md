# Defog Data
[![Build Status](https://github.com/defog-ai/defog-data/actions/workflows/main.yml/badge.svg)](https://github.com/defog-ai/defog-data/actions/workflows/main.yml)

This repository contains the metadata and data of different databases that we require for various purposes, specifically testing.

## Usage

### Data Import
To import the data into your database, you can use the `setup.sh` script. The script will drop and recreate the database if already present, so be careful when using it. This has the desired effect of idempotency, ie running it multiple times will result in the same state. Do remember to set the following environment variables to suit your postgres connection before running the script:
```sh
export DBPASSWORD="postgres"
export DBUSER="postgres"
export DBHOST="localhost"
export DBPORT=5432
./setup.sh
```

#### Snowflake
To set up the data in snowflake, you would need to have the snowflake cli installed ([instructions](https://docs.snowflake.com/en/user-guide/snowsql-install-config)), and have your credentials configured as per the [docs](https://docs.snowflake.com/en/user-guide/snowsql-config). You can then run the following command to setup the data:
```sh
./setup_snowflake.sh
```
This will create 1 database per database in the repo as before, using `public` as the default schema.

Note that the same sql files work for both the postgres and snowflake databases, so you can use the same sql files to setup both databases.

#### BigQuery, MySQL, SQLite, SQL Server
To set up the data in these systems, you would need your credentials to be configured in `utils_dialects`. You can then run the following command to set up the databases:
```
python translate_ddl_dialect.py
```
This will create one new SQL file per database per dialect.
For SQLite, the `.db` files will be saved in the folder `sqlite_dbs`.
Note that BigQuery, MySQL and SQLite do not support schemas and hence the SQL files will be modified to skip schema creation.

### Python Library

This is the recommended way to access the schema from the json files in a python environment. To use the python library in your code, navigate to this repository and install it using pip:
```sh
pip install -r requirements.txt # get dependencies
pip install -e .
```
The `-e` allows us to edit the code in place, ie if we make changes to the code, we don't have to reinstall the package.

#### Metadata

Once you have it installed, you can access the json metadata of each database as a dictionary using the following code:
```python
import defog_data.metadata as md

md.academic
# {'table_metadata': {'cite': [{'data_type': 'bigint',
#    'column_name': 'cited',
#    'column_description': ['ID of the publication being cited']},
#    ...
```

#### Supplementary

We also have column embeddings, joinable columns and special columns with named entities, split by database in [supplementary.py](defog_data/supplementary.py). To access them, use the following code:
```python
import defog_data.supplementary as sup

# embeddings and accompanying column info in csv format
embeddings, csv_info = sup.load_embeddings("<your path of choice>")
# columns that can be joined on
sup.columns_join
# columns with named entities
sup.columns_ner
```

Note that the embeddings need to be regenerated should the underlying data get updated (eg new columns added, major version bumps). To regenerate the embeddings, you can delete the embeddings at the path specified above, and run the `load_embeddings` function again to regenerate them.

## Organization

### Databases

Each database (eg `academic`) is organized in a folder with the following structure:
```sh
academic
├── academic.json
└── academic.sql
```
The json contains the metadata of the database along with the column and table descriptions, while the sql file contains the dump of the database (metadata + data). This is to facilitate easier importing of the data into a database, without worrying about the sequence of inserts, especially foreign key constraints which require the primary key from the parent table to be present before inserting into the child table.

## Testing

The test in `tests.py` just ensures that we are able to access the respective metadata for each table in each database. To run the tests, use the following command:
```sh
python -m unittest tests.py
```

## Release

To build for release, first bump the version in [setup.py](setup.py) and then run the following commands:
```sh
python setup.py sdist bdist_wheel
twine upload dist/defog*
```