-- Stock vs Sales Analysis (LEFT JOIN + CASE)
CREATE OR REPLACE VIEW analytics.v_stock_vs_sales AS
SELECT
    p.product_id,
    dp.product_name,
    p.units_in_stock,
    COALESCE(s.total_units_sold, 0) AS total_units_sold,
    CASE
        WHEN p.units_in_stock = 0 THEN 'Out of stock'
        WHEN p.units_in_stock < 10 THEN 'Low stock'
        ELSE 'Sufficient stock'
    END AS stock_status
FROM harmonized.products p
JOIN analytics.dim_products dp ON p.product_id = dp.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_units_sold
    FROM analytics.fact_order_lines
    GROUP BY product_id
) s ON p.product_id = s.product_id;
