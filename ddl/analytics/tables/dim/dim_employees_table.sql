CREATE OR REPLACE TABLE analytics.dim_employees AS
SELECT DISTINCT employee_id, employee_name
FROM transformation.orders;
