#!/bin/bash

BACKUP_DIR="/home/fran/backups"

mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/home_backup.tar.gz /home/fran

echo "Backup completed."
