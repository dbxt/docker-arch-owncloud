#!/usr/bin/env bash

set -e

DB_TYPE=${DB_TYPE} #:-sqlite}
DB_HOST=${DB_HOST} #:-localhost}
DB_NAME=${DB_NAME} #:-owncloud}
DB_USER=${DB_USER} #:-owncloud}
DB_PASS=${DB_PASS} #:-owncloud}
DB_TABLE_PREFIX=${DB_TABLE_PREFIX:-oc_}
ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-changeme}
DATA_DIR=${DATA_DIR:-/var/www/owncloud/data}

HTTPS_ENABLED=${HTTPS_ENABLED:-false}

update_config_line() {
    local -r config="$1" option="$2" value="$3"

    # Skip if value is empty.
    if [[ -z "$value" ]]; then
        return
    fi

    # Check if the option is set.
    if grep "$option" "$config" >/dev/null 2>&1
    then
        # Update existing option
        sed -i "s|\([\"']$option[\"']\s\+=>\).*|\1 '$value',|" "$config"
    else
        # Create autoconfig.php if necessary
        [[ -f "$config" ]] || {
            echo -e '<?php\n$AUTOCONFIG = array (' > "$config"
        }

        # Add to config
        sed -i "s|\(CONFIG\s*=\s*array\s*(\).*|\1\n  '$option' => 
'$value',|" "$config"
    fi
}

update_owncloud_config() {
    echo -n "Updating config.php... "
    local -r config=/var/www/owncloud/config/config.php
    update_config_line "$config" dbtype "$DB_TYPE"
    update_config_line "$config" dbhost "$DB_HOST"
    update_config_line "$config" dbname "$DB_NAME"
    update_config_line "$config" dbuser "$DB_USER"
    update_config_line "$config" dbpassword "$DB_PASS"
    update_config_line "$config" dbtableprefix "$DB_TABLE_PREFIX"
    update_config_line "$config" directory "$DATA_DIR"
    echo "Done !"
}

# Update the config if the config file exists, otherwise autoconfigure 
owncloud
if [[ -f /var/www/owncloud/config/config.php ]]
then
    update_owncloud_config
else
    owncloud_autoconfig
fi
