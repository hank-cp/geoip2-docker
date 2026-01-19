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
if /usr/bin/geoipupdate $flags 1>$log_file 2>&1; then
    echo "# STATE: geoipupdate completed successfully"
else
    echo "# WARNING: geoipupdate failed, attempting direct download"
    
    # Read account credentials
    if [ -n "$GEOIPUPDATE_ACCOUNT_ID_FILE" ]; then
        ACCOUNT_ID=$(cat "$GEOIPUPDATE_ACCOUNT_ID_FILE")
    else
        ACCOUNT_ID="$GEOIPUPDATE_ACCOUNT_ID"
    fi
    
    if [ -n "$GEOIPUPDATE_LICENSE_KEY_FILE" ]; then
        LICENSE_KEY=$(cat "$GEOIPUPDATE_LICENSE_KEY_FILE")
    else
        LICENSE_KEY="$GEOIPUPDATE_LICENSE_KEY"
    fi
    
    # Parse edition IDs and download each database
    IFS=' ' read -ra EDITIONS <<< "$GEOIPUPDATE_EDITION_IDS"
    for EDITION_ID in "${EDITIONS[@]}"; do
        echo "# STATE: Downloading $EDITION_ID via direct download"
        
        # Download the database using MaxMind permalink
        DOWNLOAD_URL="https://download.maxmind.com/geoip/databases/${EDITION_ID}/download?suffix=tar.gz"
        TEMP_FILE="/tmp/${EDITION_ID}.tar.gz"
        
        if curl -f -L -u "${ACCOUNT_ID}:${LICENSE_KEY}" -o "$TEMP_FILE" "$DOWNLOAD_URL"; then
            echo "# STATE: Successfully downloaded $EDITION_ID"
            
            # Extract the .mmdb file from the tar.gz
            tar -xzf "$TEMP_FILE" -C "$GEOIPUPDATE_DB_DIR" --strip-components=1 --wildcards '*.mmdb'
            
            if [ $? -eq 0 ]; then
                echo "# STATE: Successfully extracted $EDITION_ID to $GEOIPUPDATE_DB_DIR"
            else
                echo "# ERROR: Failed to extract $EDITION_ID"
            fi
            
            rm -f "$TEMP_FILE"
        else
            echo "# ERROR: Failed to download $EDITION_ID from $DOWNLOAD_URL"
        fi
    done
    
    echo "# STATE: Direct download process completed" >> $log_file
fi

curl http://localhost:8080/geoip/v2.1/reload