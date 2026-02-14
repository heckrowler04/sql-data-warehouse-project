/*
===============================================================================
Data Quality Validation Script — Gold Layer
===============================================================================
Purpose:
    Executes data quality validation checks on the Gold layer to ensure
    data integrity, consistency, and analytical reliability.

Description:
    This script validates that the presentation layer conforms to
    dimensional modeling standards and is suitable for downstream
    analytics, reporting, and business intelligence consumption.

Validation Scope:
    - Verifies uniqueness of surrogate keys in dimension tables.
    - Confirms referential integrity between fact and dimension tables.
    - Validates expected relationships within the star schema model.
    - Detects anomalies that could impact analytical accuracy.

Usage Guidelines:
    - Run after Gold layer objects are refreshed or rebuilt.
    - Review any validation failures immediately.
    - Investigate and resolve discrepancies before releasing data
      to reporting or analytics environments.

===============================================================================
*/


-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 

SELECT 
    customerKey,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customerKey
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  
