-- Low Selling Products (GROUP BY + HAVING)
CREATE OR REPLACE VIEW analytics.v_low_selling_products AS
SELECT
    f.product_id,
    p.product_name,
    SUM(f.quantity) AS total_units_sold,
    SUM(f.line_total) AS total_revenue
FROM analytics.fact_order_lines f
JOIN analytics.dim_products p ON f.product_id = p.product_id
GROUP BY f.product_id, p.product_name
HAVING SUM(f.line_total) < 1000
ORDER BY total_revenue ASC;
