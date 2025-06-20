CREATE OR REPLACE TABLE order_details (
    order_id INT,
    product_id INT,
    unit_price NUMBER(10, 4),
    quantity SMALLINT,
    discount FLOAT
);
