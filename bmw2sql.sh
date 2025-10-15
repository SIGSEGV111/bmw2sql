#!/bin/bash -eu
source "/opt/amp-bash-commons/shell-util.sh"

my_path="$(dirname "$(readlink -f "$0")")"
ensureProgramsInstalled jq mqtt-sub stdin2sql.php stdbuf
parseCommandlineArguments "t:token-file:BMW_TOKEN_FILE=file" "b:table:BMW_TABLE=string?bmw_mqtt" "p:payload:BMW_PAYLOAD_COLUMN=string?payload" "i:id:BMW_ID_COLUMN=string?id" -- "$@"

export PGAPPNAME="${PGAPPNAME:-bmw2sql}"

function getJsonValue()
{
	jq -r "$1" <<<"$json"
}

function toSql()
{
	set +e
	echo "[$(date)] starting stdin2sql" 1>&2
	for((;;)); do
		stdin2sql.php --sql "INSERT INTO $__table ($__payload) VALUES (\$1::JSONB) RETURNING $__id"
		sleep 0.1
		echo "[$(date)] restarting stdin2sql" 1>&2
	done
}

function streamMqtt()
{
	set +e
	echo "[$(date)] starting mqtt-sub" 1>&2
	for((;;)); do
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
			--debug

		echo "[$(date)] restarting mqtt-sub" 1>&2
	done
}

streamMqtt | stdbuf --output=L -- jq -c '.data' | toSql
