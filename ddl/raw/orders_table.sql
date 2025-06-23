CREATE OR REPLACE TABLE orders (
    order_id INT,
    customer_id VARCHAR(5),
    employee_id INT,
    order_date TIMESTAMP,
    required_date TIMESTAMP,
    shipped_date TIMESTAMP,
    ship_via INT,
    freight NUMBER(10, 4),
    ship_name VARCHAR,
    ship_address VARCHAR,
    ship_city VARCHAR,
    ship_region VARCHAR,
    ship_postal_code VARCHAR,
    ship_country VARCHAR
);
