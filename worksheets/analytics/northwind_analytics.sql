USE WAREHOUSE USERNAME_WH;
USE ROLE USERNAME_ROLE;
USE DATABASE USERNAME_NORTHWIND;
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
-- 4. STORED PROCEDURES TO REFRESH ANALYTICS TABLES
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
  FROM harmonized.orders o
  JOIN harmonized.order_line_details ol ON o.order_id = ol.order_id;

  RETURN 'Fact table refreshed.';
END;
$$;

CREATE OR REPLACE PROCEDURE sp_build_dim_products()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO analytics.dim_products
  SELECT DISTINCT product_id, product_name, category_id, category_name
  FROM harmonized.order_line_details;

  RETURN 'dim_products refreshed.';
END;
$$;

CREATE OR REPLACE PROCEDURE sp_build_dim_categories()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO analytics.dim_categories
  SELECT DISTINCT category_id, category_name
  FROM harmonized.order_line_details;

  RETURN 'dim_categories refreshed.';
END;
$$;

CREATE OR REPLACE PROCEDURE sp_build_dim_customers()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO analytics.dim_customers
  SELECT DISTINCT customer_id, customer_name
  FROM harmonized.orders;

  RETURN 'dim_customers refreshed.';
END;
$$;

CREATE OR REPLACE PROCEDURE sp_build_dim_employees()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO analytics.dim_employees
  SELECT DISTINCT employee_id, employee_name
  FROM harmonized.orders;

  RETURN 'dim_employees refreshed.';
END;
$$;

CREATE OR REPLACE PROCEDURE sp_build_dim_shippers()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO analytics.dim_shippers
  SELECT DISTINCT shipper_id, shipper_name
  FROM harmonized.orders;

  RETURN 'dim_shippers refreshed.';
END;
$$;

-- =====================================
-- 5. MASTER PROCEDURE TO REFRESH ALL ANALYTICS TABLES
-- =====================================
CREATE OR REPLACE PROCEDURE sp_build_analytics_all()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  CALL sp_build_fact_order_lines();
  CALL sp_build_dim_products();
  CALL sp_build_dim_categories();
  CALL sp_build_dim_customers();
  CALL sp_build_dim_employees();
  CALL sp_build_dim_shippers();

  RETURN 'Analytics layer fully refreshed.';
END;
$$;

-- =====================================
-- 6. TASK TO REFRESH ANALYTICS AFTER TRANSFORMATION
-- =====================================
CREATE OR REPLACE TASK task_build_analytics
  WAREHOUSE = USERNAME_WH
  AFTER task_transform_all
AS
  CALL sp_build_analytics_all();

ALTER TASK task_build_analytics RESUME;


-- =====================================
-- 7. SAMPLE QUERY TO TEST VIEWS
-- =====================================
-- SELECT * FROM analytics.v_top10_products_by_revenue;
-- SELECT * FROM analytics.v_revenue_per_category;
-- SELECT * FROM analytics.v_units_sold_per_category;
-- SELECT * FROM analytics.v_low_selling_products;
