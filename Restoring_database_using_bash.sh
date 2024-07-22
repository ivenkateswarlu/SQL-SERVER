#!/bin/bash

# Database settings
SERVER=''
DATABASE=''
CHANGE_DATABASE=''
USERNAME=''
PASSWORD=''

# Backup base path on Windows
BASE_BACKUP_PATH="D:\\Projects\\backup_files\\backup_path"

# Get the latest PostTime in the required format (only date part)
LATEST_DATE=$(sqlcmd -S $SERVER -U $USERNAME -P $PASSWORD -d $DATABASE -Q "SET NOCOUNT ON; SELECT CONVERT(varchar, MAX(PostTime), 23) FROM DatabaseLog;" -h -1 | tr -d '[:space:]')
echo "latest date is: $LATEST_DATE"
# Check if we got the date correctly
if [[ -z "$LATEST_DATE" ]]; then
    echo "Failed to retrieve the latest date from DatabaseLog."
    exit 1
fi

# Rearrange the date to MM_DD_YYYY format
FORMATTED_DATE=$(echo $LATEST_DATE | awk -F'-' '{print $2"_"$3"_"$1}')

# Generate the backup file name
BACKUP_FILE_NAME="${DATABASE}_${FORMATTED_DATE}_bashscript.bak"
BACKUP_PATH="${BASE_BACKUP_PATH}\\${BACKUP_FILE_NAME}"

# Backup command
echo "Starting backup of database $DATABASE to $BACKUP_PATH..."
sqlcmd -S $SERVER -U $USERNAME -P $PASSWORD -d $DATABASE -Q "BACKUP DATABASE $DATABASE TO DISK = N'$BACKUP_PATH' WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Full Backup of $DATABASE';"

if [ $? -eq 0 ]; then
    echo "Backup completed successfully to $BACKUP_PATH."
else
    echo "Backup failed."
fi


# Database offline command
echo "Taking database $DATABASE to offline"
sqlcmd -S $SERVER -U $USERNAME -P $PASSWORD -d $CHANGE_DATABASE -Q "ALTER DATABASE $DATABASE SET OFFLINE WITH ROLLBACK IMMEDIATE;"

if [ $? -eq 0 ]; then
    echo "Database $DATABASE was Offline."
else
    echo "Failed to bring the database $DATABASE offline"
fi


# Backup and Restore base path on Windows
RESTORE_PATH="D:\\Projects\\backup_files\\restore_files_path"

# Identify the latest .bak file
LATEST_BAK_FILE=$(find "$RESTORE_PATH" -maxdepth 1 -type f -name '*.bak' -printf '%T+ %p\n' | sort -r | head -n1 | cut -d' ' -f2-)

# Check if a backup file was found
if [[ -z "$LATEST_BAK_FILE" ]]; then
    echo "No backup file found."
    exit 1
fi

echo "Latest backup file found: $LATEST_BAK_FILE"

# Restore the latest backup file into SQL Server
echo "Restoring database from $LATEST_BAK_FILE to $DATABASE..."
sqlcmd -S $SERVER -U $USERNAME -P $PASSWORD -d $CHANGE_DATABASE -Q "RESTORE DATABASE $DATABASE FROM DISK = N'$LATEST_BAK_FILE' WITH REPLACE, RECOVERY;"

if [ $? -eq 0 ]; then
    echo "Database $DATABASE has been successfully restored."
else
    echo "Failed to restore database $DATABASE."
fi
