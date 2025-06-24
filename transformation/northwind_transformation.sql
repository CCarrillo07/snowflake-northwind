USE ROLE accountadmin;
USE DATABASE northwind;

-- =========================
-- Step 1: Create Harmonized Tables
-- =========================

USE SCHEMA harmonized;

-- =========================
-- Step 2: Stored Procedures for Data Transformation
-- =========================

USE SCHEMA automation;

CREATE OR REPLACE PROCEDURE sp_transform_orders()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO northwind.harmonized.orders
  SELECT
    o.order_id,
    CAST(o.order_date AS DATE),
    CAST(o.shipped_date AS DATE),
    DATEDIFF('day', CAST(o.order_date AS DATE), CAST(o.shipped_date AS DATE)),
    c.customer_id,
    c.company_name,
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name),
    s.shipper_id,
    s.company_name,
    o.freight
  FROM northwind.raw.orders o
  LEFT JOIN northwind.raw.customers c ON o.customer_id = c.customer_id
  LEFT JOIN northwind.raw.employees e ON o.employee_id = e.employee_id
  LEFT JOIN northwind.raw.shippers s ON o.ship_via = s.shipper_id
  WHERE o.order_id IS NOT NULL;

  RETURN 'Transform completed successfully.';
END;
$$;

CREATE OR REPLACE PROCEDURE sp_transform_order_line_details()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO northwind.harmonized.order_line_details
  SELECT
    od.order_id,
    od.product_id,
    p.product_name,
    c.category_id,
    c.category_name,
    od.unit_price,
    od.quantity,
    od.discount,
    ROUND(od.unit_price * od.quantity * (1 - od.discount), 2)
  FROM northwind.raw.order_details od
  LEFT JOIN northwind.raw.products p ON od.product_id = p.product_id
  LEFT JOIN northwind.raw.categories c ON p.category_id = c.category_id
  WHERE od.order_id IS NOT NULL AND od.product_id IS NOT NULL;

  RETURN 'Transform completed successfully.';
END;
$$;

CREATE OR REPLACE PROCEDURE sp_transform_products()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  INSERT OVERWRITE INTO northwind.harmonized.products
  SELECT
    p.product_id,
    p.product_name,
    p.supplier_id,
    s.company_name,
    p.category_id,
    c.category_name,
    p.quantity_per_unit,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order,
    p.reorder_level,
    p.discontinued,
    CASE WHEN p.discontinued THEN 'Discontinued' ELSE 'Active' END
  FROM northwind.raw.products p
  LEFT JOIN northwind.raw.categories c ON p.category_id = c.category_id
  LEFT JOIN northwind.raw.suppliers s ON p.supplier_id = s.supplier_id;

  RETURN 'Transform completed successfully.';
END;
$$;

-- =========================
-- Step 3: Master Procedure to Call All Transformations
-- =========================

CREATE OR REPLACE PROCEDURE sp_transform_all()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  CALL sp_transform_orders();
  CALL sp_transform_order_line_details();
  CALL sp_transform_products();
  RETURN 'Transform completed successfully.';
END;
$$;

-- =========================
-- Step 4: Task to Orchestrate the Transformations
-- =========================

/*===============================================================
  Before proceeding, create a single task named `task_load_orders_info` 
  that runs a master stored procedure (`sp_load_orders_info`) responsible 
  for calling both `sp_load_orders` and `sp_load_order_details`.

  This new task consolidates the ingestion of both `orders` and 
  `order_details` data into a single orchestration point.

  Any existing individual ingestion tasks for `orders` and 
  `order_details` must be deleted, as `task_load_orders_info` 
  will replace them in the ingestion phase.
================================================================*/

USE SCHEMA automation;

CREATE OR REPLACE TASK task_transform_all
  WAREHOUSE = COMPUTE_WH
  AFTER task_load_orders_info
AS
  CALL sp_transform_all();

-- Activate the task
ALTER TASK task_transform_all RESUME;

SHOW TASKS;

ALTER TASK task_load_orders_info RESUME;

SELECT * FROM northwind.harmonized.orders;
SELECT * FROM northwind.harmonized.order_line_details;
SELECT * FROM northwind.harmonized.products;

-- Remember to suspend this task when not in use to avoid unnecessary credit consumption.
ALTER TASK task_transform_all SUSPEND;
ALTER TASK task_load_orders_info SUSPEND;
