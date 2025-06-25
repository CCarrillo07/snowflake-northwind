-- Product-level sales summary by quantity and revenue
CREATE OR REPLACE VIEW analytics.v_product_sales_summary AS
SELECT
    f.product_id,
    p.product_name,
    SUM(f.quantity) AS total_units_sold,
    SUM(f.line_total) AS total_revenue
FROM analytics.fact_order_lines f
JOIN analytics.dim_products p ON f.product_id = p.product_id
GROUP BY f.product_id, p.product_name
ORDER BY total_revenue ASC;
