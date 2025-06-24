CREATE OR REPLACE TABLE analytics.dim_categories AS
SELECT DISTINCT category_id, category_name
FROM transformation.order_line_details;
