#!/bin/bash

echo "Define variables .."

# Define variables
BACKUP_DIR=/nexus2/temp-backup
S3_BUCKET=s3://s3-nexus-backup-production/nexus-backups

echo "Find and upload .bak files to S3 .."
find $BACKUP_DIR -type f -name '*.bak' -exec aws s3 cp {} $S3_BUCKET/ \;

if [ $? -eq 0 ]; then
    echo "Files uploaded to S3 successfully"
    echo "Delete .bak files from local directory .."
    find $BACKUP_DIR -type f -name '*.bak' -exec rm {} \;
    if [ $? -eq 0 ]; then
        echo ".bak files deleted successfully"
    else
        echo "Failed to delete .bak files"
        exit 1
    fi
else
    echo "Failed to upload files to S3"
    exit 1
fi

echo "Backup completed and uploaded to S3."
