-- Revenue per Category (simple GROUP BY)
CREATE OR REPLACE VIEW analytics.v_revenue_per_category AS
SELECT 
    category_id, 
    category_name, 
    SUM(line_total) AS total_revenue
FROM analytics.fact_order_lines
GROUP BY category_id, category_name
ORDER BY total_revenue DESC;
