set -e

# get arguments
# if $@ is empty, set it to all of our db's
if [ -z "$@" ]; then
    set -- academic advising atis broker car_dealership derm_treatment ewallet geography restaurants scholar yelp
fi
# $@ is all arguments passed to the script
echo "Databases to init: $@"

# get each folder name in data/export
for db_name in "$@"; do
    echo "dropping and recreating database ${db_name}"
    # drop and recreate database
    PGPASSWORD="${DBPASSWORD:-postgres}" psql -U "${DBUSER:-postgres}" -h "${DBHOST:-localhost}" -p "${DBPORT:-5432}" -c "DROP DATABASE IF EXISTS ${db_name};"
    PGPASSWORD="${DBPASSWORD:-postgres}" psql -U "${DBUSER:-postgres}" -h "${DBHOST:-localhost}" -p "${DBPORT:-5432}" -c "CREATE DATABASE ${db_name};"
    echo "done dropping and recreating database ${db_name}"
    db_path="defog_data/${db_name}/${db_name}.sql"
    echo "importing ${db_path} into database ${db_name}"
    PGPASSWORD="${DBPASSWORD:-postgres}" psql -U "${DBUSER:-postgres}" -h "${DBHOST:-localhost}" -p "${DBPORT:-5432}" -d "${db_name}" -f "${db_path}"
done
