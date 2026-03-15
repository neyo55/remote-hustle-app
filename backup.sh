#!/bin/bash
# Remote Hustle Daily Backup Script

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="remote-hustle-data"
ZIP_NAME="backup_$TIMESTAMP.zip"
S3_BUCKET="s3://remote-hustle-backup-neyo55-2026"

echo "Zipping data..."
zip -r $ZIP_NAME $BACKUP_DIR

echo "Uploading to AWS S3..."
aws s3 cp $ZIP_NAME $S3_BUCKET/

echo "Backup successful: $ZIP_NAME uploaded to S3" | mail -s "Backup Success" kbneyo55@gmail.com