# 📊 Data Warehouse and Analytics Project

| Metadata | Value |
|--------|------|
| Project | Data Warehouse & Analytics Platform |
| Author | Vinayaka Gudli |
| Role | Aspiring Data Engineer |
| Stack | SQL Server, SQL |
| Architecture | Bronze → Silver → Gold |
| Project Type | Portfolio Project |

---

## 📖 Overview
Welcome to the **Data Warehouse and Analytics Project** 🚀  

This project demonstrates the design and implementation of a **SQL-based data warehouse** built for analytical reporting and business intelligence. It follows modern **data engineering best practices** and implements a layered architecture used in real-world data platforms.

A **data warehouse** is a centralized system designed for reporting, analytics, and decision-making.

---

## 🏗️ Data Architecture

<img width="1389" height="780" alt="Screenshot 2026-02-14 154841" src="https://github.com/user-attachments/assets/39774136-9f61-401f-a7c1-bf8bcd2002e4" />

The diagram above illustrates the complete data pipeline architecture used in this project.

### Architecture Flow

The system follows a **layered architecture pattern**, widely adopted in industry-grade data platforms.

---

### 🔹 Source Layer
Raw data originates from multiple operational systems:

- CRM system  
- ERP system  

Data is received in **CSV format** and stored in folders before ingestion.

---

### 🥉 Bronze Layer — Raw Data
Stores original source data exactly as received.

**Purpose**
- Preserve raw records
- Maintain audit trail
- Enable reprocessing if needed

**Characteristics**
- Tables only
- No transformations
- Batch loading
- Truncate + Insert strategy
- Schema matches source

---

### 🥈 Silver Layer — Cleaned Data
Transforms raw data into structured and standardized datasets.

**Processes**
- Data cleansing
- Standardization
- Derived columns
- Enrichment

**Goal**
Produce reliable and consistent datasets.

---

### 🥇 Gold Layer — Business Ready Data
Final presentation layer optimized for analytics.

**Contains**
- Fact tables
- Dimension tables
- Aggregated tables
- Analytical views

**Transformations**
- Business logic
- Aggregations
- Data integrations

**Models**
- Star schema
- Flat tables
- Aggregations

---

### 👥 Consumer Layer
Final data usage layer:

- BI dashboards
- SQL analytics
- Machine learning models

---

## 🧠 Architecture Principles

| Principle | Meaning |
|--------|---------|
| Layered Design | Separates raw, cleaned, and analytics data |
| Data Lineage | Tracks data from source to output |
| Scalability | Supports increasing data volume |
| Reusability | Layers usable independently |
| Reliability | Failures isolated to specific layer |

---

## 🚀 Project Requirements

### 🎯 Objective
Design and build a modern **SQL Server data warehouse** to consolidate sales data from multiple systems and enable analytics.

### 📌 Specifications
- Import data from **ERP** and **CRM**
- Data provided as CSV files
- Clean data before loading
- Combine sources into single analytical model
- Use latest dataset only (no history tracking)
- Provide documentation for analysts

---

## 🛠️ Tech Stack
- **Database:** SQL Server  
- **Language:** SQL  
- **Modeling:** Star & Snowflake Schema  
- **ETL:** SQL transformations  

🚧 Future enhancement: PySpark pipelines for scalable batch processing.

---

## 🧩 Concepts Demonstrated

- Data warehousing architecture
- ETL pipeline design
- Dimensional modeling
- Data cleaning and validation
- Analytical query optimization
- Layered system design

---

## 📚 Currently Learning
- Building data warehouses
- Fact & dimension modeling
- Analytical SQL
- PySpark ETL pipelines
- Apache Airflow orchestration
- Data Structures & Algorithms

---

## 🎯 Career Goal
To become a **Data Engineer** who builds scalable, reliable, and efficient data platforms for analytics and decision-making.

---

## 📫 Connect With Me
- GitHub: https://github.com/heckrowler04  
- LinkedIn: https://www.linkedin.com/in/vinayaka-gudli-3591042a6/

---

## 👨‍💻 Author
**Vinayaka Gudli**

---

## 🛡️ License
Licensed under the **MIT License**.  
Free to use, modify, and distribute with attribution.

---

⭐ *Always learning. Always building.*
