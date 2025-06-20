CREATE OR REPLACE VIEW northwind.harmonized.v_monthly_sales AS
SELECT
    DATE_TRUNC('month', order_date) AS month_start_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.freight) AS total_freight,
    SUM(od.line_total) AS total_sales_amount,
    AVG(od.line_total) AS avg_order_value
FROM northwind.harmonized.orders o
JOIN northwind.harmonized.order_details od ON o.order_id = od.order_id
GROUP BY 1
ORDER BY 1;
