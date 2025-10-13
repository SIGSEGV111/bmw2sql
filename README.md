# BMW CarData → PostgreSQL Streamer

Streams BMW CarData MQTT events into a PostgreSQL table. Minimal, single-script pipeline.

## How it works

* Reads auth and identifiers from a token JSON file.
* Subscribes to `customer.streaming-cardata.bmwgroup.com:9000` on topic `<gcid>/<vin>`.
* Extracts `.data` from each MQTT message.
* Inserts each JSON payload into PostgreSQL via `stdin2sql.php`:

  ```sql
  INSERT INTO <table> (<payload_col>) VALUES ($1::JSONB) RETURNING <id_col>;
  ```
* Runs forever and reconnects on failure.

## Requirements

* `jq`
* [mqtt-sub](https://github.com/SIGSEGV111/mqtt-sub)
* [stdin2sql.php](https://github.com/SIGSEGV111/stdin2sql)
* `/opt/amp-bash-commons/shell-util.sh` available (or remove `parseCommandlineArguments` and `parseCommandlineArguments`)
* PostgreSQL reachable by `stdin2sql.php` (auth as configured there)
* Optional, but recommended: [bmw-token-manager](https://github.com/SIGSEGV111/bmw-token-manager)

## PostgreSQL table

Create a table with a JSONB payload and an id column. Example:

```sql
CREATE TABLE bmw_mqtt (
  id      BIGSERIAL PRIMARY KEY,
  ts      BIGINT NOT NULL DEFAULT (EXTRACT(EPOCH FROM clock_timestamp())*1000000)::BIGINT,
  payload JSONB  NOT NULL
);
```

## Token file

Path given with `-t/--token-file`. Expected JSON keys:

```json
{
  "id_token": "JWT or opaque token",
  "gcid": "client-id",
  "vin": "WBA..."
}
```

## Usage

```bash
./bmw2sql.sh \
  --token-file token.json \
  --table bmw_mqtt \
  --payload payload \
  --id id
```

Short forms:

* `-t, --token-file FILE`  token JSON path
* `-b, --table NAME`       target table (default `bmw_mqtt`)
* `-p, --payload NAME`     JSONB column (default `payload`)
* `-i, --id NAME`          id column returned (default `id`)

You can also set env vars instead of flags:

* `BMW_TABLE`, `BMW_PAYLOAD_COLUMN`, `BMW_ID_COLUMN`

## Notes

* Topic is `<gcid>/<vin>`. Credentials: `--username $gcid`, `--password $id_token`.
* Only the `.data` field of each message is stored.
* The script prints a timestamp at each reconnect.
* Ensure the token file is protected: `chmod 600 token.json`.
