This repository contains a complete end-to-end data pipeline project based on the Northwind dataset. It includes data ingestion, transformation, and analytics layers implemented for Snowflake, along with IAM policies and a Streamlit dashboard app for KPI visualization.

Repository Structure:

data/ – Raw CSV files representing the Northwind dataset, including customers, orders, products, and more.

ddl/ – SQL scripts organized by layer:

raw/ – Table definitions reflecting source data structure.

harmonized/ – Cleaned and standardized staging tables.

analytics/ – Dimensional tables, fact tables, and business-focused views for reporting.

database/ and schemas/ – Scripts to create the database and schema structure.

iam/ – Snowflake IAM policy file for secure S3 data access.

worksheets/ – SQL scripts and app code for:

ingestion/ – Loading raw data into Snowflake.

transformation/ – Building harmonized and analytics layers.

analytics/ – Business insights and queries.

delivery/ – Streamlit app (northwind_kpis_app.py) for visualizing KPIs.
