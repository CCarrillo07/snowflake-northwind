CREATE OR REPLACE TABLE analytics.dim_customers AS
SELECT DISTINCT customer_id, customer_name
FROM harmonized.orders;
