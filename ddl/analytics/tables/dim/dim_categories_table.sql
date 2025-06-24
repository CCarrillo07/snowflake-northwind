CREATE OR REPLACE TABLE analytics.dim_categories AS
SELECT DISTINCT category_id, category_name
FROM harmonized.order_line_details;
