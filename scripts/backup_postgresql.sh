#!/bin/bash

# Variables
BACKUP_DIR="/var/backups/postgresql"
DB_NAMES=("share_master" "allpay_vendor" "vendor_portal")
DATE=$(TZ="Asia/Bangkok" date '+%Y%m%d%H%M')

# Create backup directory if it doesn't exist
sudo mkdir -p $BACKUP_DIR
sudo chmod 777 $BACKUP_DIR

# Backup each database
for DB_NAME in "${DB_NAMES[@]}"; do
   sudo -u postgres bash -c "pg_dump --format=c --clean --if-exists --load-via-partition-root --quote-all-identifiers ${DB_NAME} | gzip > ${BACKUP_DIR}/${DB_NAME}-${DATE}.dump.gz"
done

sudo find ${BACKUP_DIR}/ -type f -name "*.gz" -mtime +10 -exec rm -f {} \;