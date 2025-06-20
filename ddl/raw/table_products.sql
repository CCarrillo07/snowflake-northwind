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
