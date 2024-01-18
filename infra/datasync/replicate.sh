#!/bin/bash

SCHEMAS=(marlowe chain)

fn_dump() {
  ACTION=$1
  DB_PASSWORD=$2
  DB_HOST=$3
  DB_USER=$4
  DB_NAME=$5
  DB_SCHEMA=$6

  export PGPASSWORD=$DB_PASSWORD
  if [ $ACTION == "export" ]; then
    /usr/bin/pg_dump --host=$DB_HOST --username=$DB_USER --dbname=$DB_NAME --schema=$DB_SCHEMA \
    --clean --format=d --file=/dump/$DB_SCHEMA --jobs=$CONCURRENCY_LEVEL --compress=$COMPRESSION_LEVEL --verbose
  else
    echo "drop schema ${DB_SCHEMA} cascade;" | \
    /usr/bin/psql --host=$DB_HOST --username=$DB_USER --dbname=$DB_NAME
    /usr/bin/pg_restore --host=$DB_HOST --username=$DB_USER --dbname=$DB_NAME \
    --format=d --jobs=$CONCURRENCY_LEVEL /dump/$DB_SCHEMA --exit-on-error --verbose
  fi
}

for SCHEMA in ${SCHEMAS[@]}; do
  [ -d /dump/${SCHEMA} ] && rm -rf /dump/${SCHEMA}
  if [ $SCHEMA == "marlowe" ]; then
    fn_dump "export" $MARLOWE_DB_PASSWORD $MARLOWE_DB_HOST $MARLOWE_DB_USER $MARLOWE_DB_NAME $SCHEMA
  else
    fn_dump "export" $CHAIN_DB_PASSWORD $CHAIN_DB_HOST $CHAIN_DB_USER $CHAIN_DB_NAME $SCHEMA
  fi
  fn_dump "import" $LOOKER_DB_PASSWORD $LOOKER_DB_HOST $LOOKER_DB_USER $LOOKER_DB_NAME $SCHEMA
done

exit 0
