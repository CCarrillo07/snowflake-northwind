USE ROLE accountadmin;
USE DATABASE northwind;
USE SCHEMA analytics;

-- =====================================
-- 1. FACT TABLE (only keys and measures)
-- =====================================

-- =====================================
-- 2. DIMENSION TABLES (descriptive attributes)
-- =====================================

-- =====================================
-- 3. KPI VIEWS with best practices
-- =====================================

-- =====================================
-- 4. STORED PROCEDURE TO REFRESH FACT TABLE
-- =====================================

USE SCHEMA automation;

CREATE OR REPLACE PROCEDURE sp_build_fact_order_lines()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO analytics.fact_order_lines
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

  RETURN 'Fact table refreshed successfully.';
END;
$$;

-- =====================================
-- 5. TASK TO AUTOMATE REFRESHING ANALYTICS LAYER
-- =====================================

CREATE OR REPLACE TASK task_build_analytics
  WAREHOUSE = COMPUTE_WH
  AFTER task_transform_all
AS
  CALL sp_build_fact_order_lines();

ALTER TASK task_build_analytics RESUME;

-- =====================================
-- 6. SAMPLE QUERY TO TEST VIEWS
-- =====================================
-- SELECT * FROM analytics.v_top10_products_by_revenue;
-- SELECT * FROM analytics.v_revenue_per_category;
-- SELECT * FROM analytics.v_units_sold_per_category;
-- SELECT * FROM analytics.v_low_selling_products;
-- SELECT * FROM analytics.v_stock_vs_sales;
