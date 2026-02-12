/*
===========================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===========================================================================================================

Description:
    This stored procedure executes the ETL (Extract, Transform, Load) process
    to populate tables in the 'silver' schema using data from the 'bronze' schema.

Layer Purpose:
    The Silver layer represents cleansed, standardized, and deduplicated data.
    It applies data quality rules, transformations, and business logic to
    prepare structured data for downstream consumption in the Gold layer.

Actions Performed:
    - Truncates existing Silver tables to ensure a full reload.
    - Extracts raw data from Bronze tables.
    - Applies transformations such as:
        • Data trimming and standardization
        • Code-to-description mapping
        • Null handling and default value assignment
        • Deduplication using window functions
        • Derived column calculations
        • Data validation and correction logic
    - Inserts transformed data into Silver tables.

Processing Type:
    - Full Load (TRUNCATE + INSERT)
    - Batch execution with load duration logging
    - Error handling using TRY-CATCH block

Parameters:
    None.
    This procedure does not accept input parameters and does not return values.

Execution:
    EXEC silver.load_silver;

Dependencies:
    - Bronze schema tables must exist and contain data.
    - Silver schema tables must be pre-created.

===========================================================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	declare @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @BATCH_end_time DATETIME
	SET @batch_start_time = GETDATE();
	BEGIN TRY
		
		PRINT '=======================================';
		PRINT 'Loading Silver Layers';
		PRINT '=======================================';

		PRINT '---------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE()
		PRINT'Truncating table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT'>>Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info
		(
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'MARRIED'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'SINGLE'
				ELSE 'n/a'
			END AS cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		FROM
		(
		SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
		)t
		where flag_last = 1
		SET @end_time = GETDATE()
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE()
		PRINT'Truncating table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT'>>Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info
		(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,	--Extracy category ID
			SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,			--Extract product key
			prd_nm,
			COALESCE(prd_cost, 0) prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,	--Map product line codes to descriptive values 
			CAST(prd_start_dt AS date) prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS date) prd_end_dt		--Calculate end date as one day before next start date
		FROM bronze.crm_prd_info
		SET @end_time = GETDATE()
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE()
		PRINT'Truncating table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT'>>Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details
		(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS varchar) AS date)
			END sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS varchar) AS date) 
			END AS sls_ship_dt,
			CASE
			WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL 
			ELSE CAST(CAST(sls_due_dt AS varchar) AS date)
			END AS sls_due_dt,
			CASE
				WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END sls_sales,	--Recalculate sales if original value is missing or incorrect
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0
				THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price	--Derive price if original values is invalid
			END sls_price
		FROM bronze.crm_sales_details
		SET @end_time = GETDATE()
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		PRINT '---------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE()
		PRINT'Truncating table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT'>>Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12
		(
			cid,
			bdate,
			gen
		)
		SELECT
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate < '1924-01-01' OR bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,	--Set future birthdates to NULL and age > 100 to NULL.
			CASE 
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen	--Normalize gender values and handle unknown cases
		FROM bronze.erp_cust_az12
		SET @end_time = GETDATE()
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE()
		PRINT'Truncating table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT'>>Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101
		(
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid,
			CASE 
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry	--Normalize and Handle missing or blanck country codes
		FROM bronze.erp_loc_a101
		SET @end_time = GETDATE()
		PRINT'>> Load duartion: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE()
		PRINT'Truncating table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT'>>Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2
		(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE()
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
	PRINT'Loading of the Silver Layer is Completed!';
	PRINT'>> Total Load duartion of Silver Layer: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' Seconds';
	PRINT '---------------------------------------';
END

EXEC silver.load_silver
