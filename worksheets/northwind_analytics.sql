USE ROLE accountadmin;
USE DATABASE northwind;
USE SCHEMA analytics;

-- =====================================
-- 1. FACT TABLE (only keys and measures)
-- =====================================
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

-- =====================================
-- 2. DIMENSION TABLES (descriptive attributes)
-- =====================================
CREATE OR REPLACE TABLE analytics.dim_products (
    product_id INT,
    product_name VARCHAR,
    category_id INT,
    category_name VARCHAR
);

CREATE OR REPLACE TABLE analytics.dim_categories (
    category_id INT,
    category_name VARCHAR
);

CREATE OR REPLACE TABLE analytics.dim_customers (
    customer_id VARCHAR,
    customer_name VARCHAR
);

CREATE OR REPLACE TABLE analytics.dim_employees (
    employee_id INT,
    employee_name VARCHAR
);

CREATE OR REPLACE TABLE analytics.dim_shippers (
    shipper_id INT,
    shipper_name VARCHAR
);

-- =====================================
-- 3. KPI VIEWS with best practices
-- =====================================

-- Top 10 Products by Revenue (CTE + RANK)
CREATE OR REPLACE VIEW analytics.v_top10_products_by_revenue AS
WITH ranked_products AS (
  SELECT 
    product_id,
    product_name,
    SUM(line_total) AS total_revenue,
    RANK() OVER (ORDER BY SUM(line_total) DESC) AS revenue_rank
  FROM analytics.fact_order_lines
  GROUP BY product_id, product_name
)
SELECT product_id, product_name, total_revenue
FROM ranked_products
WHERE revenue_rank <= 10
ORDER BY revenue_rank;

-- Revenue per Category
CREATE OR REPLACE VIEW analytics.v_revenue_per_category AS
SELECT 
  category_id, 
  category_name, 
  SUM(line_total) AS total_revenue
FROM analytics.fact_order_lines
GROUP BY category_id, category_name
ORDER BY total_revenue DESC;

-- Units Sold per Category
CREATE OR REPLACE VIEW analytics.v_units_sold_per_category AS
SELECT 
  category_id, 
  category_name, 
  SUM(quantity) AS total_units_sold
FROM analytics.fact_order_lines
GROUP BY category_id, category_name
ORDER BY total_units_sold DESC;

-- Low Selling Products (HAVING clause)
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

-- Stock vs Sales Analysis (LEFT JOIN + CASE)
CREATE OR REPLACE VIEW analytics.v_stock_vs_sales AS
SELECT
  p.product_id,
  p.product_name,
  p.units_in_stock,
  COALESCE(s.total_units_sold, 0) AS total_units_sold,
  CASE
    WHEN p.units_in_stock = 0 THEN 'Out of stock'
    WHEN p.units_in_stock < 10 THEN 'Low stock'
    ELSE 'Sufficient stock'
  END AS stock_status
FROM transformation.products p
LEFT JOIN (
  SELECT product_id, SUM(quantity) AS total_units_sold
  FROM analytics.fact_order_lines
  GROUP BY product_id
) s ON p.product_id = s.product_id;

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
  FROM transformation.orders o
  JOIN transformation.order_line_details ol ON o.order_id = ol.order_id;

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
  FROM transformation.order_line_details;

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
  FROM transformation.order_line_details;

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
  FROM transformation.orders;

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
  FROM transformation.orders;

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
  FROM transformation.orders;

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
  WAREHOUSE = COMPUTE_WH
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
-- SELECT * FROM analytics.v_stock_vs_sales;
