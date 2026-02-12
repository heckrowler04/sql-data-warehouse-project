/*
=================================================================================================
Quality Checks – Silver Layer Validation
=================================================================================================

Script Purpose:
    This script performs data quality validation checks on tables within the
    'silver' schema to ensure data consistency, accuracy, and standardization
    after the ETL process.

    These checks help verify that transformations applied during the
    Bronze → Silver load have been correctly executed.

Validation Includes:
    - Detection of NULL values in primary key columns
    - Identification of duplicate primary keys
    - Detection of unwanted leading or trailing spaces in string columns
    - Verification of standardized values (e.g., gender, marital status)
    - Validation of derived or calculated fields
    - Basic referential integrity checks where applicable

Usage Notes:
    - Execute this script immediately after loading the Silver layer.
    - Investigate and resolve any discrepancies identified.
    - These checks should return zero rows for critical validation failures.
    - Integrate into automated pipelines for continuous data quality monitoring.

Dependencies:
    - Silver schema tables must be populated.
    - ETL load procedure (silver.load_silver) must have completed successfully.

=================================================================================================
*/


--=================================================================================================
--Checking 'silver.crm_cust_info'
--=================================================================================================

--Check For Nulls or Duplicates in Primary Key
--Expectation: No Result
SELECT
	cst_id,
	COUNT(*) as totalCstId
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

--Check for Unwanted Spaces
--Expectation: No Results

SELECT
	*
FROM silver.crm_cust_info

SELECT
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname ! = TRIM(cst_firstname);

SELECT
	cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname ! = TRIM(cst_lastname);

SELECT
	cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status)

SELECT
	cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

--Data Standardization & Consistency
SELECT
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
		ELSE 'n/a'
	END AS cst_gndr
FROM 
(
SELECT	
	DISTINCT cst_gndr
FROM silver.crm_cust_info
)T;

--=================================================================================================
--Checking 'silver.prd_info'
--=================================================================================================

SELECT
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'MARRIED'
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'SINGLE'
		ELSE 'n/a'
	END AS cst_marital_status
FROM 
(
SELECT	
	DISTINCT cst_marital_status
FROM silver.crm_cust_info
)T

select
	*
from bronze.crm_sales_details
where sls_prd_key NOT IN
(SELECT	
	prd_key
FROM bronze.crm_prd_info)
--Quality Checks
--Check for Nulls or Duplicates in Primary Key
--Expectation: No Results

SELECT
	prd_id,
	COUNT(*) as TotalPK
from silver.crm_prd_info
group by prd_id
having COUNT(*) > 1 or prd_id IS NULL

--Check for unwanted Spaces
--Expectations: No Results
SELECT
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check it if only the business allows it!
--Check for NULLS or Negetaive Numbers
--Expetations: No Results
SELECT
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardization & Consistency
SELECT
	DISTINCT prd_line
FROM silver.crm_prd_info

--Check for Invalid Date Orders
SELECT
	prd_start_dt,
	prd_end_dt
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


--=================================================================================================
--Checking 'silver.crm_sales_details'
--=================================================================================================

--Check Data Consistency: Between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.
SELECT DISTINCT
	sls_sales AS sls_sales_old, 
	sls_quantity,
	sls_price AS sls_price_old,
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END sls_sales,
	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
OR sls_sales <=0 OR sls_quantity <= 0 OR sls_price <= 0
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price 

SELECT
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

SELECT
	*
FROM silver.crm_sales_details

--=================================================================================================
--Checking 'silver.erp_cust_az12'
--=================================================================================================

--Identify Out-of-Range Dates
SELECT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--Data Standardization & Consistency
SELECT
	DISTINCT gen,
	CASE 
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END AS gen
FROM silver.erp_cust_az12

SELECT
	*
FROM silver.erp_cust_az12

--=================================================================================================
--Checking 'silver.erp_loc_a101'
--=================================================================================================

--Data Standardization & Consistency
SELECT
	DISTINCT cntry AS CNTRY_OLD,
	CASE 
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry
FROM silver.erp_loc_a101
ORDER BY cntry

SELECT
	*
FROM silver.erp_loc_a101

--=================================================================================================
--Checking 'silver.erp_px_cat_g1v2'
--=================================================================================================

--CHECK FOR UNWNTED SPACES
SELECT
	*
FROM silver.erp_px_cat_g1v2
WHERE TRIM(cat) != cat OR TRIM(subcat) != subcat OR TRIM(maintenance) != maintenance

--Data Standardization and Consistency
SELECT
	DISTINCT maintenance
FROM silver.erp_px_cat_g1v2

SELECT
	*
FROM silver.erp_px_cat_g1v2
