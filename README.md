# Defog Data

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

### Python Library

This is the recommended way to access the schema from the json files in a python environment. To use the python library in your code, navigate to this repository and install it using pip:
```sh
pip install -e .
```
The `-e` allows us to edit the code in place, ie if we make changes to the code, we don't have to reinstall the package.

Once you have it installed, you can access the json metadata of each database as a dictionary using the following code:
```python
import defog_data

defog_data.academic
# {'table_metadata': {'cite': [{'data_type': 'bigint',
#    'column_name': 'cited',
#    'column_description': ['ID of the publication being cited']},
#    ...
```

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