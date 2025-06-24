CREATE OR REPLACE TABLE northwind.harmonized.products (
    product_id INT,
    product_name VARCHAR,
    supplier_id INT,
    supplier_name VARCHAR,
    category_id INT,
    category_name VARCHAR,
    quantity_per_unit VARCHAR,
    unit_price NUMBER(10,2),
    units_in_stock SMALLINT,
    units_on_order SMALLINT,
    reorder_level SMALLINT,
    discontinued BOOLEAN,
    product_status VARCHAR
);
