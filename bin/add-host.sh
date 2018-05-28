#!/usr/bin/env bash

# Adlibre Backup - Add new host

CWD="$(dirname $0)/"

# Source Config
. ${CWD}../etc/backup.conf

# Source Functions
. ${CWD}functions.sh;

# Parse Opts
while true; do
    case "$1" in
        -r | --realm) HOSTS_REALM=$2; HOSTS_DIR="/${POOL_NAME}/${HOSTS_REALM}/"; shift 2 ;;
        -h | --help ) showUsage; exit 128 ;;
        -- ) shift; break ;;
        * ) if [ ! "$1" == "" ]; then HOST=$1; fi; shift; break ;;
    esac
done

if [ ! $HOST ]; then
    echo "Please specify host name."
    exit
fi

# Create hosts subvolume
if [ ! -d "${HOSTS_DIR}" ]; then
    storageCreate $POOL_TYPE ${POOL_NAME}/${HOSTS_REALM}
fi

# Create host subvolume
if [ ! -d "${HOSTS_DIR}${HOST}" ]; then
    storageCreate $POOL_TYPE ${POOL_NAME}/${HOSTS_REALM}/${HOST}
    mkdir ${HOSTS_DIR}${HOST}/c
    mkdir ${HOSTS_DIR}${HOST}/d
    mkdir ${HOSTS_DIR}${HOST}/l
    cp /${POOL_NAME}/etc/host_default.conf ${HOSTS_DIR}${HOST}/c/backup.conf
    if [ "${POOL_TYPE}" == "btrfs" ]; then 
        mkdir -p ${HOSTS_DIR}${HOST}/.btrfs/snapshot
    fi
else
    echo "Error: Host already exists."
    exit 99
fi

# Try to copy ssh-key to host
ssh-copy-id -i ${SSH_KEY} ${SSH_USER}@${HOST}
