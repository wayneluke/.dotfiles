#!/bin/bash

# Prompt the user for the MySQL database name
read -p "Enter the MySQL database name: " DB_NAME

# Prompt for MySQL username
read -p "Enter your MySQL username: " DB_USER

# Prompt for MySQL password (hidden input)
read -s -p "Enter your MySQL password: " DB_PASS
echo  # Newline for better formatting

# Define the backup directory and filename
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$TIMESTAMP.sql"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform the database backup
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"

# Check if the backup was successful
if [ $? -eq 0 ]; then
  echo "Backup successful! Saved to $BACKUP_FILE"
else
  echo "Backup failed! Please check your credentials and database name."
  exit 1
fi
