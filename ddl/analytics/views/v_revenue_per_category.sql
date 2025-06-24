-- Revenue per Category (simple GROUP BY)
CREATE OR REPLACE VIEW analytics.v_revenue_per_category AS
SELECT 
    f.category_id, 
    c.category_name, 
    SUM(f.line_total) AS total_revenue
FROM analytics.fact_order_lines f
JOIN analytics.dim_categories c ON f.category_id = c.category_id
GROUP BY f.category_id, c.category_name
ORDER BY total_revenue DESC;
