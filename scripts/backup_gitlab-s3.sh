#!/bin/bash

echo "Define variables .."

# Define variables
BACKUP_DIR=/gitlab-aws/gitlab/gitlab-backup-tar
DOCKER_CONTAINER=Gitlab-Server
S3_BUCKET_NAME=s3-gitlab-backup-prod
TIMESTAMP=$(date +%F_%H-%M-%S)

echo "Create Backup .."

# Create a backup
docker exec $DOCKER_CONTAINER gitlab-backup create STRATEGY=copy

echo "Upload to S3 .."

# Upload the backup to S3
aws s3 cp $BACKUP_DIR s3://$S3_BUCKET_NAME/gitlab-backups --recursive


echo "Cleanup .."

# Cleanup old backups
find $BACKUP_DIR -type f -name '*' -exec rm {} \;

echo "Backup completed and uploaded to S3."
