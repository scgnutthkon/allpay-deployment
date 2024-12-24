#!/bin/bash

# Variables
BACKUP_DIR="/var/backups/mongodb"
DB_NAMES=("allPay" "vendorPortal")
DATE=$(TZ="Asia/Bangkok" date '+%Y%m%d%H%M')
MONGODB_ROOT_USER="root"
MONGODB_ROOT_PASSWORD="mflv[1234"

# Create backup directory if it doesn't exist
sudo mkdir -p $BACKUP_DIR

for DB_NAME in "${DB_NAMES[@]}"; do
    mongodump --username=${MONGODB_ROOT_USER} --password=${MONGODB_ROOT_PASSWORD} --authenticationDatabase=admin --host=127.0.0.1 --port=27017 --db=${DB_NAME} --gzip --archive=${BACKUP_DIR}/${DB_NAME}-${DATE}.gz
done

find ${BACKUP_DIR}/ -type f -name "*.gz" -mtime +10 -exec rm -f {} \;