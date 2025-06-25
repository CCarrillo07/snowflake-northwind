# 📊 Northwind Data Pipeline Project

This repository contains a complete end-to-end data pipeline project using the classic **Northwind dataset**. It demonstrates how to structure and manage raw data ingestion, transformation, and analytics within **Snowflake**, and includes a **Streamlit app** for KPI visualization.

---

## 📁 Repository Structure

+-- data/ # Raw CSV files (customers, orders, products, etc.)
+-- ddl/ # DDL scripts organized by layer
| +-- raw/ # Raw source table definitions
| +-- harmonized/ # Cleaned/staged tables
| +-- analytics/ # Star schema: dimensions, facts, views
| | +-- tables/
| | | +-- dim/
| | | +-- fact/
| | +-- views/
| +-- database/ # Database creation script
| +-- schemas/ # Schema creation script
+-- iam/ # Snowflake IAM policy for S3 access
+-- worksheets/ # SQL and app scripts by phase
| +-- ingestion/ # Ingest raw CSVs into Snowflake
| +-- transformation/ # Build harmonized & analytics layers
| +-- analytics/ # Query logic for insights
| +-- delivery/ # Streamlit KPI dashboard
