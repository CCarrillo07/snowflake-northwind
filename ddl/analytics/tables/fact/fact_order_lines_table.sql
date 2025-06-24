CREATE OR REPLACE TABLE analytics.fact_order_lines AS
SELECT
    o.order_id,
    o.order_date,
    o.shipped_date,
    o.days_to_ship,
    o.customer_id,
    o.employee_id,
    o.shipper_id,
    ol.product_id,
    ol.category_id,
    ol.unit_price,
    ol.quantity,
    ol.discount,
    ol.line_total
FROM transformation.orders o
JOIN transformation.order_line_details ol ON o.order_id = ol.order_id;
