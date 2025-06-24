-- Units Sold per Category (simple GROUP BY)
CREATE OR REPLACE VIEW analytics.v_units_sold_per_category AS
SELECT 
    category_id, 
    category_name, 
    SUM(quantity) AS total_units_sold
FROM analytics.fact_order_lines
GROUP BY category_id, category_name
ORDER BY total_units_sold DESC;
