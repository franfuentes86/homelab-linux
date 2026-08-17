#!/bin/bash

set -euo pipefail

SOURCE="/home"
BACKUP_DIR="/opt/backups/home"
LOG_DIR="/var/log/homelab"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

BACKUP_FILE="${BACKUP_DIR}/home_backup_${DATE}.tar.gz"
LOG_FILE="${LOG_DIR}/backup.log"

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

echo "[$(date)] Starting backup" | tee -a "$LOG_FILE"

tar -czf "$BACKUP_FILE" "$SOURCE"

echo "[$(date)] Backup completed: $BACKUP_FILE" | tee -a "$LOG_FILE"
