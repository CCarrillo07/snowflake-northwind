CREATE OR REPLACE TABLE northwind.harmonized.orders (
    order_id INT,
    order_date DATE,
    shipped_date DATE,
    days_to_ship INT,
    customer_id VARCHAR,
    customer_name VARCHAR,
    employee_id INT,
    employee_name VARCHAR,
    shipper_id INT,
    shipper_name VARCHAR,
    freight NUMBER(10,2)
);
