-- Low Selling Products (GROUP BY + HAVING)
CREATE OR REPLACE VIEW analytics.v_low_selling_products AS
SELECT
    product_id,
    product_name,
    SUM(quantity) AS total_units_sold,
    SUM(line_total) AS total_revenue
FROM analytics.fact_order_lines
GROUP BY product_id, product_name
HAVING SUM(line_total) < 1000
ORDER BY total_revenue ASC;
