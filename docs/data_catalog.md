# Gold Layer Data Catalog

## Overview
The **Gold Layer** represents curated, business-ready data designed for analytics, reporting, and decision-making.  
It follows a dimensional modeling approach consisting of:

- **Dimension tables** — descriptive attributes used for filtering, grouping, and segmentation.
- **Fact tables** — transactional or measurable events used for aggregation and analysis.

---

## Data Model Summary

| Layer Object | Type | Description |
|-------------|------|-------------|
| gold.dim_customers | Dimension | Customer attributes and demographics |
| gold.dim_products | Dimension | Product attributes and classifications |
| gold.fact_sales | Fact | Transactional sales records |

---

# Dimension Tables

---

## gold.dim_customers

**Purpose**  
Stores enriched customer attributes used for customer analytics and segmentation.

**Grain**  
One record per customer.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customerKey | INT | Surrogate key uniquely identifying a customer record. |
| customer_id | INT | Source system identifier assigned to the customer. |
| customer_number | NVARCHAR(50) | Business identifier used for tracking customers. |
| first_name | NVARCHAR(50) | Customer given name. |
| last_name | NVARCHAR(50) | Customer family name. |
| country | NVARCHAR(50) | Country of residence. |
| marital_status | NVARCHAR(50) | Marital status classification. |
| gender | NVARCHAR(50) | Gender classification. |
| birthdate | DATE | Date of birth. |
| create_date | DATE | Date the customer record was created in the source system. |

---

## gold.dim_products

**Purpose**  
Stores descriptive product attributes used for product performance analysis and reporting.

**Grain**  
One record per product.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_key | INT | Surrogate key uniquely identifying each product record. |
| product_id | INT | Source system product identifier. |
| product_number | NVARCHAR(50) | Business product code used for tracking. |
| product_name | NVARCHAR(50) | Descriptive product name. |
| category_id | NVARCHAR(50) | Identifier for product category. |
| category | NVARCHAR(50) | High-level product classification. |
| subcategory | NVARCHAR(50) | Detailed classification within category. |
| maintenance_required | NVARCHAR(50) | Indicates whether maintenance is required. |
| cost | INT | Base product cost. |
| product_line | NVARCHAR(50) | Product line or series. |
| start_date | DATE | Date product became available for sale. |

---

# Fact Tables

---

## gold.fact_sales

**Purpose**  
Stores transactional sales events used for revenue, volume, and trend analysis.

**Grain**  
One record per **order line item** (product per order).

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| order_number | NVARCHAR(50) | Unique identifier for each sales order. |
| product_key | INT | Foreign key referencing `dim_products.product_key`. |
| customer_key | INT | Foreign key referencing `dim_customers.customer_key`. |
| order_date | DATE | Date the order was placed. |
| shipping_date | DATE | Date the order was shipped. |
| due_date | DATE | Payment due date. |
| quantity | INT | Number of units sold. |
| price | INT | Unit price at time of sale. |
| sales_amount | INT | Total line amount calculated as `quantity × price`. |

---

# Relationships

| From | To | Relationship | Description |
|------|----|--------------|-------------|
| dim_customers | fact_sales | 1 → Many | One customer can generate multiple sales transactions |
| dim_products | fact_sales | 1 → Many | One product can appear in multiple sales transactions |

---

# Metric Definitions

| Metric | Formula | Notes |
|------|----------|------|
| sales_amount | quantity × price | Calculated per order line |

---

# Modeling Standards

| Term | Definition |
|------|-------------|
| Surrogate Key | System-generated unique identifier used instead of business keys |
| Grain | The level of detail represented by one row in a table |
| Dimension | Descriptive table used for slicing and filtering data |
| Fact | Table storing measurable business events |

---

# Governance Metadata (Recommended Extension)

These fields are commonly added in enterprise catalogs:

- Data Owner
- Refresh Frequency
- Source System
- Data Lineage
- Data Quality Rules
- Nullability Constraints
- Slowly Changing Dimension Type

---

| Metadata | Value |
|--------|------|
| Document Version | 1.0 |
| Last Updated | 2026-02-14 |
| Owner | Vinayaka Gudli (Data Engineering) |




