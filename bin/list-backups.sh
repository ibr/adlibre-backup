#!/usr/bin/env bash

# Adlibre Backup - List backups for a host

CWD="$(dirname $0)/"

# Source Config
. ${CWD}../etc/backup.conf

# Source Functions
. ${CWD}functions.sh;

HOSTS_DIR="/${POOL_NAME}/hosts/"

if [ ! $(whoami) = "root" ]; then
    echo "Error: Must run as root."
    exit 99
fi

if [ "$1" != '' ]; then
    HOSTS=$(ls /${POOL_NAME}/$1)
elif
    [ "$1" == '' ]; then
    echo "Bitte Bereich angeben."
    exit 99
fi

BEREICH=$1

for host in $HOSTS; do
    if [ -d /${POOL_NAME}/${BEREICH}/${host}/.${POOL_TYPE}/snapshot ]; then
        SNAPSHOTS=$(find /${POOL_NAME}/${BEREICH}/${host}/.${POOL_TYPE}/snapshot -maxdepth 1 -mindepth 1 | sort)
        for snapshot in $SNAPSHOTS; do
            SNAPSHOT=$(basename $snapshot)
            EXPIRY=$(cat $snapshot/c/EXPIRY 2> /dev/null)
            ANNOTATION=$(cat $snapshot/c/ANNOTATION 2> /dev/null)
            STATUS=$(cat $snapshot/l/STATUS 2> /dev/null)
            echo "$host $SNAPSHOT $EXPIRY $STATUS \"$ANNOTATION\""
        done
    fi
done

exit 0
