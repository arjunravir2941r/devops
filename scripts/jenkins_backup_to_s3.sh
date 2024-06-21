#!/bin/bash

echo "Define variables .."

# Define variables
JENKINS_HOME_DIR=/jenkins/jenkins_home   # Replace with your actual path
BACKUP_DIR=/tools-backup/jenkins-backup
S3_BUCKET_NAME=s3-jenkins-backup-production
TIMESTAMP=$(date +%F_%H-%M-%S)

echo "Create Backup Directory .."
mkdir -p $BACKUP_DIR

echo "Create Backup .."

# Create a tarball of the Jenkins home directory on the host system
tar czf $BACKUP_DIR/jenkins-backup-$TIMESTAMP.tar.gz -C $JENKINS_HOME_DIR .

echo "Upload to S3 .."

# Upload the backup to S3
aws s3 cp $BACKUP_DIR/jenkins-backup-$TIMESTAMP.tar.gz s3://$S3_BUCKET_NAME/jenkins-backups/

echo "Cleanup .."

# Cleanup old backups
find $BACKUP_DIR -type f -name '*.tar.gz' -exec rm {} \;

echo "Backup completed and uploaded to S3."

