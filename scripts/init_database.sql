/*
=====================================================================
Create Database and Schemas
=====================================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse'.
    If the database already exists, it will be dropped and recreated.
    The script also creates three schemas within the database:
    'bronze', 'silver', and 'gold'.

    These schemas represent different data layers commonly used
    in data warehousing architectures.

WARNING:
    Running this script will DROP the entire 'DataWarehouse' database
    if it already exists.
    All existing data will be permanently deleted.

    Proceed with caution and ensure proper backups are taken
    before executing this script.
=====================================================================
*/

use master;
GO

--Drop and recreate the 'DataWarehouse' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
  ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWarehouse;
END;
GO

--Create the 'DataWarehouse' database
create database DataWarehouse;

use DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA bronze;
go
  
CREATE SCHEMA silver;
go
  
CREATE SCHEMA gold;
go
