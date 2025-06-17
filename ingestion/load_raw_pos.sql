USE ROLE accountadmin;

/*-----------------------------------------------------
-- Step 1: Database and Schema Setup
-----------------------------------------------------*/

-- Create database
CREATE OR REPLACE DATABASE northwind;

-- Switch to the new database
USE DATABASE northwind;

-- Create schemas
CREATE OR REPLACE SCHEMA raw;
CREATE OR REPLACE SCHEMA harmonized;
CREATE OR REPLACE SCHEMA analytics;
CREATE OR REPLACE SCHEMA public;  -- for shared utilities like file formats and stages

/*-----------------------------------------------------
-- Step 2: AWS Integration and Stage Creation
-----------------------------------------------------*/

-- Create storage integration
CREATE OR REPLACE STORAGE INTEGRATION S3_role_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::457151801201:role/snowflake_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-northwind/');

-- View the integration
SHOW INTEGRATIONS;
DESCRIBE INTEGRATION S3_role_integration;

-- Create CSV file format under the public schema
CREATE OR REPLACE FILE FORMAT public.csv_ff 
  TYPE = 'csv'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TRIM_SPACE = TRUE
  NULL_IF = ('NULL'); 

-- Create stage using the integration and file format
CREATE OR REPLACE STAGE public.s3load_stage
  URL = 's3://snowflake-northwind/'
  STORAGE_INTEGRATION = S3_role_integration
  FILE_FORMAT = public.csv_ff;

-- View the stage
SHOW STAGES;

-- Preview the contents of a folder in the stage 
LIST @public.s3load_stage/raw/categories;

LIST @public.s3load_stage/raw/orders;

-- Preview the data of a file stored in the stage
SELECT $1, $2, $3 FROM @public.s3load_stage/raw/shippers;

/*-----------------------------------------------------
-- Step 3: Create Tables in raw schema
-----------------------------------------------------*/

USE SCHEMA raw;

CREATE OR REPLACE TABLE categories (
    category_id INT,
    category_name VARCHAR,
    description VARCHAR,
    picture VARCHAR
);

CREATE OR REPLACE TABLE customers (
    customer_id VARCHAR(5),
    company_name VARCHAR,
    contact_name VARCHAR,
    contact_title VARCHAR,
    address VARCHAR,
    city VARCHAR,
    region VARCHAR,
    postal_code VARCHAR,
    country VARCHAR,
    phone VARCHAR,
    fax VARCHAR
);

CREATE OR REPLACE TABLE employees (
    employee_id INT,
    last_name VARCHAR,
    first_name VARCHAR,
    title VARCHAR,
    title_of_courtesy VARCHAR,
    birth_date DATE,
    hire_date DATE,
    address VARCHAR,
    city VARCHAR,
    region VARCHAR,
    postal_code VARCHAR,
    country VARCHAR,
    home_phone VARCHAR,
    extension VARCHAR,
    photo VARCHAR,
    notes VARCHAR,
    reports_to INT,
    photo_path VARCHAR
);

CREATE OR REPLACE TABLE order_details (
    order_id INT,
    product_id INT,
    unit_price NUMBER(10, 4),
    quantity SMALLINT,
    discount FLOAT
);

CREATE OR REPLACE TABLE orders (
    order_id INT,
    customer_id VARCHAR(5),
    employee_id INT,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via INT,
    freight NUMBER(10, 4),
    ship_name VARCHAR,
    ship_address VARCHAR,
    ship_city VARCHAR,
    ship_region VARCHAR,
    ship_postal_code VARCHAR,
    ship_country VARCHAR
);

CREATE OR REPLACE TABLE products (
    product_id INT,
    product_name VARCHAR,
    supplier_id INT,
    category_id INT,
    quantity_per_unit VARCHAR,
    unit_price NUMBER(10, 4),
    units_in_stock SMALLINT,
    units_on_order SMALLINT,
    reorder_level SMALLINT,
    discontinued BOOLEAN
);

CREATE OR REPLACE TABLE shippers (
    shipper_id INT,
    company_name VARCHAR,
    phone VARCHAR
);

CREATE OR REPLACE TABLE suppliers (
    supplier_id INT,
    company_name VARCHAR,
    contact_name VARCHAR,
    contact_title VARCHAR,
    address VARCHAR,
    city VARCHAR,
    region VARCHAR,
    postal_code VARCHAR,
    country VARCHAR,
    phone VARCHAR,
    fax VARCHAR,
    homepage VARCHAR
);

CREATE OR REPLACE TABLE territories (
    territory_id VARCHAR(20),
    territory_description VARCHAR,
    region_id INT
);

CREATE OR REPLACE TABLE employee_territories (
    employee_id INT,
    territory_id VARCHAR(20)
);

CREATE OR REPLACE TABLE regions (
    region_id INT,
    region_description VARCHAR
);

/*-----------------------------------------------------
-- Step 4: Data Tables Loading
-----------------------------------------------------*/

-- Categories table loading
COPY INTO northwind.raw.categories
FROM @public.s3load_stage/raw/categories;

-- Use COPY INTO to load data into customers, employee_territories, employees, order_details, orders, products, regions, and shippers.
