USE ROLE accountadmin;

/*-----------------------------------------------------
-- Step 1: Database and Schema Setup
-----------------------------------------------------*/

-- Create database

-- Switch to the new database
USE DATABASE northwind;

-- Create schemas

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

LIST @public.s3load_stage/raw/suppliers;

-- Preview the data of a file stored in the stage
SELECT $1, $2, $3 FROM @public.s3load_stage/raw/regions;

/*-----------------------------------------------------
-- Step 3: Create Tables in raw schema
-----------------------------------------------------*/

USE SCHEMA raw;

/*-----------------------------------------------------
-- Step 4: Data Tables Loading
-----------------------------------------------------*/

-- Categories table loading
COPY INTO northwind.raw.categories
FROM @public.s3load_stage/raw/categories;

SELECT * FROM northwind.raw.categories;

-- Use COPY INTO to load data into customers, employee_territories, employees, products, regions, shippers, suppliers, and territories

/*-----------------------------------------------------
-- Step 5: PIPE demonstration 
-----------------------------------------------------*/

/*-----------------------------------------------------
AUTO-INGEST - Not available for free accounts

CREATE OR REPLACE NOTIFICATION INTEGRATION s3_notify_int
  TYPE = QUEUE
  ENABLED = TRUE
  NOTIFICATION_PROVIDER = AWS_SQS
  AWS_SQS_ARN = 'arn:aws:sqs:us-east-2:457151801201:snowflake-s3-queue'
  AWS_SQS_ROLE_ARN = 'arn:aws:iam::457151801201:role/snowflake_role'
  DIRECTION = 'INBOUND'
  COMMENT = 'Integration to receive notifications from S3 via SQS';

CREATE OR REPLACE STAGE public.s3load_stage
  URL = 's3://snowflake-northwind/'
  STORAGE_INTEGRATION = S3_role_integration
  NOTIFICATION_INTEGRATION = s3_notify_int
  FILE_FORMAT = public.csv_ff;

CREATE OR REPLACE PIPE northwind.raw.suppliers_pipe
AUTO_INGEST = TRUE AS
  COPY INTO northwind.raw.suppliers
  FROM @public.s3load_stage/raw/suppliers
  FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff');
-----------------------------------------------------*/

/*-----------------------------------------------------
WORKAROUND - STORED PROCEDURE and TASK
-----------------------------------------------------*/

USE SCHEMA automation;

CREATE OR REPLACE PROCEDURE sp_load_orders()
  LANGUAGE SQL
AS
$$
BEGIN
  COPY INTO northwind.raw.orders
  FROM @public.s3load_stage/raw/orders
  FILE_FORMAT = (FORMAT_NAME = 'public.csv_ff')
  ON_ERROR = 'CONTINUE';
END;
$$;

CREATE OR REPLACE TASK task_load_orders
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON * * * * * UTC'  -- every 1 minute
AS
  CALL sp_load_orders();

SHOW TASKS;
 
-- Start the task
ALTER TASK task_load_orders RESUME;

-- Run the following query after 1 minute
SELECT * FROM northwind.raw.orders;

-- Remember to suspend this task when not in use to avoid unnecessary credit consumption.
ALTER TASK task_load_orders SUSPEND;

--Automate the data ingestion for order_details
