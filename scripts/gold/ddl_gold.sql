/*
===============================================================================
DDL Script: Gold Layer View Creation
===============================================================================
Purpose:
    Creates analytical views for the Gold layer of the data warehouse.
    The Gold layer represents the final presentation layer structured
    as dimension and fact tables following a Star Schema model.

Description:
    Each view transforms and integrates data from the Silver layer
    to deliver clean, standardized, and business-ready datasets
    optimized for analytics, reporting, and dashboarding.

Usage Guidelines:
    - Execute after Silver layer tables are fully populated.
    - Views are intended for direct consumption by analysts,
      BI tools, and reporting systems.
    - Do not modify these views without impact analysis,
      as downstream reports may depend on them.

===============================================================================
*/

--  =============================================================================
--  Create Dimension : gold.dim_customers
--  =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
  DROP VIEW gold.dim_customers;
GO
  
CREATE VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customerKey,	--Surrogate Key is generated (Choose either startdate or customer_id)
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS customer_firstname,
	ci.cst_lastname AS customer_lastname,
	la.cntry AS customer_country,
	ci.cst_marital_status AS customer_marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr	--CRM is the MASTER for Gender Info
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS Customer_gender,
	ca.bdate AS customer_birthdate,
	ci.cst_create_date as createdate
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
on ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
on ci.cst_key = la.cid

--  =============================================================================
--  Create Dimension : gold.dim_customers
--  =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
  DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY prd_start_dt, prd_id) AS product_key,	--Surrogate Key is generated (Choose either startdate or product_id)
	pi.prd_id AS product_id,
	pi.prd_key AS product_number,
	pi.prd_nm AS product_name,
	pi.cat_id AS category_id,
	pcg.cat AS category,
	pcg.subcat AS subcategory,
	pcg.maintenance,
	pi.prd_cost AS product_cost,
	pi.prd_line AS product_line,
	pi.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 pcg
ON pi.cat_id = pcg.id
WHERE prd_end_dt IS NULL	--Filter out all historical data as NULL represents the current end date

--  =============================================================================
--  Create Dimension : gold.dim_customers
--  =============================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
  DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	dp.product_key,
	dc.customerKey,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products as dp
ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers as dc
ON sd.sls_cust_id = dc.customer_id


