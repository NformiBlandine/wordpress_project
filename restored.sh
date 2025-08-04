WP_BACKUP_FILE="wp-volume-$DATE.tar.gz"

# === CHECK FILES EXIST ===
if [ ! -f "$BACKUP_DIR/$DB_BACKUP_FILE" ]; then
  echo "❌ Database backup file not found: $BACKUP_DIR/$DB_BACKUP_FILE"
  exit 1
fi

if [ ! -f "$BACKUP_DIR/$WP_BACKUP_FILE" ]; then
  echo "❌ WordPress backup file not found: $BACKUP_DIR/$WP_BACKUP_FILE"
  exit 1
fi

# === Restore MySQL Volume ===
echo "[*] Restoring MySQL volume ($DB_VOLUME) from $DB_BACKUP_FILE..."
docker run --rm \
  -v $DB_VOLUME:/dbdata \
  -v "$(pwd)/backups:/backup" \
  $TMP_CONTAINER_IMAGE \
  bash -c "rm -rf /dbdata/* && tar xzf /backup/$DB_BACKUP_FILE -C /"

# === Restore WordPress Volume ===
echo "[*] Restoring WordPress volume ($WP_VOLUME) from $WP_BACKUP_FILE..."
docker run --rm \
  -v $WP_VOLUME:/wpdata \
  -v "$(pwd)/backups:/backup" \
  $TMP_CONTAINER_IMAGE \
  bash -c "rm -rf /wpdata/* && tar xzf /backup/$WP_BACKUP_FILE -C /"

echo "[✓] Restore complete from backup: $DATE"
