#!/bin/bash

# Variables
BACKUP_DIR="/var/backups/postgresql"
DB_NAMES=("share_master" "allpay_vendor" "vendor_portal")
DATE=$(TZ="Asia/Bangkok" date '+%Y%m%d%H%M')

# Create backup directory if it doesn't exist
sudo mkdir -p $BACKUP_DIR

# Backup each database
for DB_NAME in "${DB_NAMES[@]}"; do
   sudo -u postgres pg_dump --clean --if-exists --load-via-partition-root --quote-all-identifiers ${DB_NAME} | sudo gzip > ${BACKUP_DIR}/${DB_NAME}-${DATE}.sql.gz
done

find ${BACKUP_DIR}/ -type f -name "*.gz" -mtime +10 -exec rm -f {} \;