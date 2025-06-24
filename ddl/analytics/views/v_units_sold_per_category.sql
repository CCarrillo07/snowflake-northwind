-- Units Sold per Category (simple GROUP BY)
CREATE OR REPLACE VIEW analytics.v_units_sold_per_category AS
SELECT 
    f.category_id, 
    c.category_name, 
    SUM(f.quantity) AS total_units_sold
FROM analytics.fact_order_lines f
JOIN analytics.dim_categories c ON f.category_id = c.category_id
GROUP BY f.category_id, c.category_name
ORDER BY total_units_sold DESC;
