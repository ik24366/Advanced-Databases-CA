-- ===============================================
-- CMPU4003_03_dw_scaffold.sql : Data Warehouse Scaffold 
-- ===============================================

DROP SCHEMA IF EXISTS dw_lite CASCADE;
CREATE SCHEMA dw_lite;
SET search_path = dw_lite, public;

-- -------------------------
-- DIMENSIONS
-- -------------------------

CREATE TABLE dw_lite.dim_date (
  date_key int PRIMARY KEY,
  date_actual date,
  year int,
  month int,
  day int
);

CREATE TABLE dw_lite.dim_customer (
  customer_key bigint PRIMARY KEY,
  region text,
  full_name text,
  age_band text
);

CREATE TABLE dw_lite.dim_product (
  product_key bigint PRIMARY KEY,
  category text,
  merchant text,
  price numeric(12,2)
);

-- -------------------------
-- FACT (yours to define)
-- -------------------------
-- Think: What should one row in your fact table represent?
-- Is it an order, an order item, or a daily summary?
-- What are the measures (facts) you would include?

CREATE TABLE dw_lite.fact_sales (
  -- Students: define your own grain and measures below.
  -- Think: what does one row represent?
  -- e.g. an order, an order item, a daily summary, average sales of a particular type.

  fact_id serial PRIMARY KEY

  -- date_key int,          -- FK to dw_lite.dim_date
  -- dim1_key bigint,       -- e.g. customer or product dimension
  -- dim2_key bigint,       -- another relevant dimension
  -- grain_amt numeric(14,2),  -- whatever you want to track
  -- grain_other_derived numeric(6,2), -- optional derived measure representing something else you want to track 
  -- other_grain_att text,     -- optional descriptive attribute
  -- another_grain_att ...     -- optional attribute or derived measure
);


-- -------------------------
-- LOAD DIMENSIONS
-- -------------------------
INSERT INTO dw_lite.dim_date(date_key, date_actual, year, month, day)
SELECT to_char(d,'YYYYMMDD')::int, d,
       EXTRACT(YEAR FROM d)::int,
       EXTRACT(MONTH FROM d)::int,
       EXTRACT(DAY FROM d)::int
FROM generate_series(current_date - interval '90 days', current_date, interval '1 day') d;

INSERT INTO dw_lite.dim_customer(customer_key, region, full_name, age_band)
SELECT c.customer_id,
       r.region_name,
       c.full_name,
       c.attributes ->> 'age_band'
FROM rel_src.customers c
JOIN rel_src.regions r ON r.region_id = c.region_id;

INSERT INTO dw_lite.dim_product(product_key, category, merchant, price)
SELECT p.product_id,
       cat.category_name,
       m.merchant_name,
       p.base_price
FROM rel_src.products p
JOIN rel_src.categories cat ON cat.category_id = p.category_id
JOIN rel_src.merchants m ON m.merchant_id = p.merchant_id;

-- -------------------------
-- NEXT STEPS 
-- -------------------------
-- 1. Decide the grain of dw_lite.fact_sales (row per order, per item, per day?).
-- 2. Identify which dimensions it links to (dim_date, dim_customer, dim_product?).
-- 3. Decide which numeric measures (facts) to store.
-- 4. Write an INSERT INTO dw_lite.fact_sales (...) SELECT ... FROM rel_src.orders ...
-- 5. Test your design with queries and EXPLAIN ANALYZE.

-- Example to adapt:
-- INSERT INTO dw_lite.fact_sales(date_key, customer_key, product_key, total_amount)
-- SELECT to_char(o.order_date,'YYYYMMDD')::int,
--        o.customer_id,
--        oi.product_id,
--        SUM(oi.quantity * oi.unit_price)
-- FROM rel_src.orders o
-- JOIN rel_src.order_items oi ON oi.order_id = o.order_id
-- GROUP BY 1,2,3;

ANALYZE;
