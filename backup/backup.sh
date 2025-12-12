#!/bin/bash

# ==== CONFIGURE THESE ====
BACKUP_TIMESTAMP=$(date +"%Y%m%d_%H%M")
REMOTE_DUMP_PATH="/var/lib/postgresql/xwiki_backup_${BACKUP_TIMESTAMP}.sql"
REMOTE_DATA_PATH="/var/lib/xwiki"
REMOTE_DATA_TAR="/tmp/data_backup_${BACKUP_TIMESTAMP}.tar.gz"
DB_NAME="xwiki"
DB_USER="postgres"
# ==========================


echo "Starting remote PostgreSQL dump..."

# Run pg_dump on remote server and tar the data folder.
ssh $XWIKI_SERVER_USER@$XWIKI_SERVER_ADDRESS "sudo runuser -l ${DB_USER} -c 'pg_dump ${DB_NAME} > ${REMOTE_DUMP_PATH}; cd ${REMOTE_DATA_PATH}; tar -czvf ${REMOTE_DATA_TAR} data'"


if [ $? -ne 0 ]; then
    echo "Failed to perform pg_dump on remote server."
    exit 1
fi

echo "Dump completed. Downloading file..."

# Download dump to local computer.
scp $XWIKI_SERVER_USER@$XWIKI_SERVER_ADDRESS:${REMOTE_DUMP_PATH} $XWIKI_BACKUP_PATH
scp $XWIKI_SERVER_USER@$XWIKI_SERVER_ADDRESS:${REMOTE_DATA_TAR} $XWIKI_BACKUP_DATA_PATH

if [ $? -ne 0 ]; then
    echo "Failed to download dump file."
    exit 1
fi

echo "Download complete: $XWIKI_BACKUP_PATH"

# Cleanup.
echo "Removing remote dump file..."
ssh $XWIKI_SERVER_USER@$XWIKI_SERVER_ADDRESS "rm ${REMOTE_DUMP_PATH}"
ssh $XWIKI_SERVER_USER@$XWIKI_SERVER_ADDRESS "rm ${REMOTE_DATA_TAR}"

echo "Done!"
