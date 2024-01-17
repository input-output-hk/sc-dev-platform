#!/bin/bash

SCHEMAS=(marlowe chain)

[ -d /dump/marlowe ] && rm -rf /dump/marlowe
[ -d /dump/chain ] && rm -rf /dump/chain

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
		--clean --format=d --file=/dump/$DB_SCHEMA --jobs=$CONCURRENCY_LEVEL --compress=$COMPRESS_LEVEL --verbose
	else
		/usr/bin/pg_restore --host=$DB_HOST --username=$DB_USER --dbname=$DB_NAME \
		--format=d --jobs=$CONCURRENCY_LEVEL --clean /dump/$DB_SCHEMA --verbose
	fi
}

for SCHEMA in ${SCHEMAS[@]}; do
	if [ $SCHEMA == "marlowe" ]; then
		fn_dump "export" $MARLOWE_DB_PASSWORD $MARLOWE_DB_HOST $MARLOWE_DB_USER $MARLOWE_DB_NAME $SCHEMA
	else
		fn_dump "export" $CHAIN_DB_PASSWORD $CHAIN_DB_HOST $CHAIN_DB_USER $CHAIN_DB_NAME $SCHEMA
	fi
	fn_dump "import" $LOOKER_DB_PASSWORD $LOOKER_DB_HOST $LOOKER_DB_USER $LOOKER_DB_NAME $SCHEMA
done

exit 0
