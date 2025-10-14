#!/bin/bash -eu
source "/opt/amp-bash-commons/shell-util.sh"

my_path="$(dirname "$(readlink -f "$0")")"
ensureProgramsInstalled jq mqtt-sub stdin2sql.php
parseCommandlineArguments "t:token-file=file" "b:table:BMW_TABLE=string?bmw_mqtt" "p:payload:BMW_PAYLOAD_COLUMN=string?payload" "i:id:BMW_ID_COLUMN=string?id" -- "$@"

function getJsonValue()
{
	jq -r "$1" <<<"$json"
}

set -o pipefail +o errtrace
set +e
for ((;;)); do
	date
	json="$(cat "$__token_file")"
	id_token=$(getJsonValue ".id_token")
	gcid=$(getJsonValue ".gcid")
	vin=$(getJsonValue ".vin")

	mqtt-sub \
		--keepalive 30 \
		--host "customer.streaming-cardata.bmwgroup.com" \
		--port 9000 \
		--username "$gcid" \
		--password "$id_token" \
		--topic "$gcid/$vin" \
		--debug \
		| jq -c '.data' \
		| stdin2sql.php --sql "INSERT INTO $__table ($__payload) VALUES (\$1::JSONB) RETURNING $__id" -x "application_name=bmw2sql"
done
