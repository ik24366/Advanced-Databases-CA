-- Populate dim_date
INSERT INTO c22391076_dw.dim_date (date_key, date_actual, year, month, day)
SELECT DISTINCT
    TO_CHAR(o.order_date, 'YYYYMMDD')::int AS date_key,
    o.order_date                               AS date_actual,
    EXTRACT(YEAR  FROM o.order_date)::int      AS year,
    EXTRACT(MONTH FROM o.order_date)::int      AS month,
    EXTRACT(DAY   FROM o.order_date)::int      AS day
FROM rel_src.orders o;

-- Populate dim_customer
INSERT INTO c22391076_dw.dim_customer (customer_key, region, full_name, age_band)
SELECT
    c.customer_id                              AS customer_key,
    r.region_name                              AS region,
    c.full_name,
    COALESCE(c.attributes->>'age_band', 'unknown') AS age_band
FROM rel_src.customers c
JOIN rel_src.regions r ON c.region_id = r.region_id;

-- Populate dim_product
INSERT INTO c22391076_dw.dim_product (product_key, category, merchant, price)
SELECT
    p.product_id                                AS product_key,
    cat.category_name                           AS category,
    m.merchant_name                             AS merchant,
    p.base_price                                AS price
FROM rel_src.products p
LEFT JOIN rel_src.categories cat ON p.category_id = cat.category_id
JOIN rel_src.merchants m ON p.merchant_id = m.merchant_id;

-- Populate fact_sales with JSONB meta
INSERT INTO c22391076_dw.fact_sales
    (date_key, customer_key, product_key, quantity, unit_price, discount, total, meta)
SELECT
    TO_CHAR(o.order_date, 'YYYYMMDD')::int      AS date_key,
    o.customer_id                               AS customer_key,
    oi.product_id                               AS product_key,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    (oi.quantity * oi.unit_price - oi.discount) AS total,
    o.meta                                      AS meta
FROM rel_src.orders o
JOIN rel_src.order_items oi ON o.order_id = oi.order_id
JOIN rel_src.products p      ON oi.product_id = p.product_id
WHERE o.status = 'delivered';
