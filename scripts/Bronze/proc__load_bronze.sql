/*
========================================================================================================
Stored Procedure: Load Bronze Layer (Source → Bronze)
========================================================================================================
Purpose:
    This stored procedure loads raw data from external CSV files into the Bronze layer
    of the data warehouse.

Process Overview:
    - Truncates existing Bronze tables to perform a full refresh load
    - Uses the BULK INSERT command to ingest data from CSV files into Bronze tables
    - Captures load duration for individual tables and the overall batch

Parameters:
    None.
    This stored procedure does not accept input parameters and does not return any values.

Execution Example:
    EXEC bronze.load_bronze;
========================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	SET @batch_start_time = GETDATE();
	BEGIN TRY
		PRINT '=======================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=======================================';

		PRINT '---------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting Data into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'E:\Docs\Datawarehouse project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH 
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT '>> Inserting Data into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		from 'E:\Docs\Datawarehouse project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH 
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT '>> Inserting Data into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'E:\Docs\Datawarehouse project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH 
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		PRINT '---------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12 
		PRINT '>> Inserting Data into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12 
		FROM 'E:\Docs\Datawarehouse project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101
		PRINT '>> Inserting Data into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'E:\Docs\Datawarehouse project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT '>> Inserting Data into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'E:\Docs\Datawarehouse project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

	END TRY

	BEGIN CATCH
		PRINT '=======================================';
		PRINT 'Error Message ' + ERROR_MESSAGE();
		PRINT 'Error Number ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=======================================';
	END CATCH
	SET @batch_end_time = GETDATE();
	PRINT'Loading of the Bronze Layer is Completed!';
	PRINT'>> Total Load duartion of Bronze Layer: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' Seconds';
	PRINT '---------------------------------------';
END

EXEC bronze.load_bronze

SELECT
	COUNT(*)
FROM bronze.crm_cust_info

SELECT
	COUNT(*)
FROM bronze.crm_prd_info

SELECT
	COUNT(*)
FROM bronze.crm_sales_details

SELECT
	COUNT(*)
FROM bronze.erp_cust_az12

SELECT
	COUNT(*)
FROM bronze.erp_loc_a101

SELECT
	COUNT(*)
FROM bronze.erp_px_cat_g1v2
