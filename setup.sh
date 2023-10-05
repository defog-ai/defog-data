set -e

# get arguments
# if $@ is empty, set it to academic advising atis geography restaurants scholar yelp
if [ -z "$@" ]; then
    set -- academic advising atis geography restaurants scholar yelp
fi
# $@ is all arguments passed to the script
echo "Databases to init: $@"

# get each folder name in data/export
for db_name in "$@"; do
    echo "dropping and recreating database ${db_name}"
    # drop and recreate database
    PGPASSWORD=$DBPASSWORD psql -U $DBUSER -h $DBHOST -p $DBPORT -c "DROP DATABASE IF EXISTS ${db_name};"
    PGPASSWORD=$DBPASSWORD psql -U $DBUSER -h $DBHOST -p $DBPORT -c "CREATE DATABASE ${db_name};"
    echo "done dropping and recreating database ${db_name}"
    db_path="${db_name}/${db_name}.sql"
    echo "importing ${db_path} into database ${db_name}"
    PGPASSWORD=$DBPASSWORD psql -U $DBUSER -h $DBHOST -p $DBPORT -d "${db_name}" -f "${db_path}"
done