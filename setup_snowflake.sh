set -e

# get arguments
# if there are no arguments, set them to a default list
if [ $# -eq 0 ]; then
    set -- academic advising atis geography restaurants scholar yelp broker car_dealership derm_treatment ewallet
fi
echo "Databases to init: $@"

for db_name in "$@"; do
    echo "dropping and recreating database ${db_name}"
    # drop and recreate database
    snowsql -q "DROP DATABASE IF EXISTS ${db_name}; CREATE DATABASE ${db_name};" -o exit_on_error=true
    echo "done dropping and recreating database ${db_name}"
    db_path="defog_data/${db_name}/${db_name}.sql"
    echo "importing ${db_path} into database ${db_name}"
    snowsql -d "${db_name}" -s public -f "${db_path}"
done