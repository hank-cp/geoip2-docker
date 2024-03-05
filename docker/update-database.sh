#!/bin/sh

set -e

database_dir=/usr/share/GeoIP
log_dir="/tmp/geoipupdate"
log_file="$log_dir/.healthcheck"
flags="--output"
export GEOIPUPDATE_CONF_FILE=""

if [ -z "$GEOIPUPDATE_DB_DIR" ]; then
  export GEOIPUPDATE_DB_DIR="$database_dir"
fi

if [ -z "$GEOIPUPDATE_ACCOUNT_ID" ] && [ -z  "$GEOIPUPDATE_ACCOUNT_ID_FILE" ]; then
    echo "ERROR: You must set the environment variable GEOIPUPDATE_ACCOUNT_ID or GEOIPUPDATE_ACCOUNT_ID_FILE!"
    exit 1
fi

if [ -z "$GEOIPUPDATE_LICENSE_KEY" ] && [ -z  "$GEOIPUPDATE_LICENSE_KEY_FILE" ]; then
    echo "ERROR: You must set the environment variable GEOIPUPDATE_LICENSE_KEY or GEOIPUPDATE_LICENSE_KEY_FILE!"
    exit 1
fi

if [ -z "$GEOIPUPDATE_EDITION_IDS" ]; then
    echo "ERROR: You must set the environment variable GEOIPUPDATE_EDITION_IDS!"
    exit 1
fi

mkdir -p $log_dir

echo "# STATE: Running geoipupdate"
/usr/bin/geoipupdate $flags 1>$log_file

curl http://localhost:8080/geoip/v2.1/reload