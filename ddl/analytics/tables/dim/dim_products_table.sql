CREATE OR REPLACE TABLE analytics.dim_products AS
SELECT DISTINCT product_id, product_name, category_id, category_name
FROM harmonized.order_line_details;
