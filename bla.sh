#!/bin/bash

# === CONFIGURATION ===
DATE=$(date +%F-%H%M)
BACKUP_DIR="./backups"
DB_VOLUME="wordpress-project_dbdata"
WP_VOLUME="wordpress-project_wordpress"
TMP_CONTAINER_IMAGE="ubuntu"

# === CREATE BACKUP FOLDER ===
mkdir -p $BACKUP_DIR

# === Backup MySQL Volume ===
echo "[*] Backing up MySQL volume ($DB_VOLUME)..."
docker run --rm \
  -v $DB_VOLUME:/dbdata \
  -v "$(pwd)/backups:/backup" \
  $TMP_CONTAINER_IMAGE \
  tar czf /backup/db-volume-$DATE.tar.gz /dbdata

# === Backup WordPress Volume ===
echo "[*] Backing up WordPress volume ($WP_VOLUME)..."
docker run --rm \
  -v $WP_VOLUME:/wpdata \
  -v "$(pwd)/backups:/backup" \
  $TMP_CONTAINER_IMAGE \
  tar czf /backup/wp-volume-$DATE.tar.gz /wpdata

echo "[✓] Backup completed!"
echo "Saved to: $BACKUP_DIR"

