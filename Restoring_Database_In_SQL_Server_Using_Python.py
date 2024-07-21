import pyodbc
import time

# Database connection settings
server = ''
database = ''
change_database=''
username = ''
password = ''
driver = '{ODBC Driver 17 for SQL Server}'

def run_sql_command(conn, sql_command):
    """Execute a SQL command without returning any result."""
    cursor = conn.cursor()
    try:
        cursor.execute(sql_command)
        while cursor.nextset():
            print(cursor.messages[0][1])
            pass  # To process all messages if any
        conn.commit()
    finally:
        cursor.close()
        print('Cursor connection is closed in run_sql_command function')

def check_database_state(conn, database_name):
    """Check the state of the database."""
    cursor = conn.cursor()
    try:
        cursor.execute(f"SELECT state_desc FROM sys.databases WHERE name = '{database_name}'")
        result = cursor.fetchone()
        return result[0] if result else None
    finally:
        cursor.close()
        print('Cursor connection is closed in check_database_state function')

def restore_database(FileName_INFO):
    conn = None
    try:
        conn = pyodbc.connect(f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}', autocommit=True)
        # Backup the database
        backup_filename = f'{database}_backup_from_pyscript.bkp'
        backup_path = f'D:\\Projects\\backup_files\\backup_path\\{backup_filename}'

        backup_command = f"""
        BACKUP DATABASE {database}
        TO DISK = N'{backup_path}'
        WITH FORMAT, MEDIANAME = 'SQLServerBackups',
        NAME = 'Full Backup of {database}';
        """
        run_sql_command(conn, backup_command)
        print("Backup successful.")

        # Set the database offline
        offline_command = f"""
        ALTER DATABASE {database}
        SET OFFLINE WITH ROLLBACK IMMEDIATE;
        """
        run_sql_command(conn, offline_command)
        print("Database set offline.")

        # Check if database is offline
        db_state = check_database_state(conn, database)
        print(db_state)
        while db_state != 'OFFLINE':
            print(f"Waiting for database to go offline. Current state: {db_state}")
            time.sleep(10)  # Wait for 10 seconds before checking again
            db_state = check_database_state(conn, database)
    except Exception as e:
        print(f"An error occurred: {str(e)}")
    finally:
        if conn:
            conn.close()
            print('conn connection is closed in backup_command function')
            

    try:
        # Connect to the system database to restore
        conn = pyodbc.connect(f'DRIVER={driver};SERVER={server};DATABASE={change_database};UID={username};PWD={password}', autocommit=True)
        bkp_file_restore_path = f'D:\\Projects\\backup_files\\restore_files_path\\{FileName_INFO}.bak'
        restore_command = f"""
        USE {change_database};
        RESTORE DATABASE {database}
        FROM DISK = N'{bkp_file_restore_path}'
        WITH REPLACE, RECOVERY;
        """
        run_sql_command(conn, restore_command)
        print("Database restore was successful")
    except Exception as e:
        print(f"An error occurred during restore: {str(e)}")
    finally:
        if conn:
            conn.close()
            print('conn connection is closed in restore_command function')

if __name__ == "__main__":
    restore_database('AdventureWorksDW2022')
