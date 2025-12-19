-- =========================================================
-- LIST partitioning for c22391076_dw.fact_sales on region
-- =========================================================

-- 0) Clean up if re-running
DROP TABLE IF EXISTS c22391076_dw.fact_sales_list CASCADE;

-- 1) Parent LIST-partitioned table
CREATE TABLE c22391076_dw.fact_sales_list
(
  fact_id      serial,
  date_key     integer,
  customer_key bigint,
  product_key  bigint,
  region       text,
  quantity     integer,
  unit_price   numeric(12,2),
  discount     numeric(12,2),
  total        numeric(12,2),
  meta         jsonb
)
PARTITION BY LIST (region);

-- 2) Partitions for each actual region in dim_customer
CREATE TABLE c22391076_dw.fact_sales_list_europe
  PARTITION OF c22391076_dw.fact_sales_list
  FOR VALUES IN ('Europe');

CREATE TABLE c22391076_dw.fact_sales_list_ireland
  PARTITION OF c22391076_dw.fact_sales_list
  FOR VALUES IN ('Ireland');

CREATE TABLE c22391076_dw.fact_sales_list_uk
  PARTITION OF c22391076_dw.fact_sales_list
  FOR VALUES IN ('United Kingdom');

CREATE TABLE c22391076_dw.fact_sales_list_united_states
  PARTITION OF c22391076_dw.fact_sales_list
  FOR VALUES IN ('United States');

-- 3) Load data from original fact_sales joined with dim_customer to get region
INSERT INTO c22391076_dw.fact_sales_list
(fact_id, date_key, customer_key, product_key,
 region, quantity, unit_price, discount, total, meta)
SELECT
  f.fact_id,
  f.date_key,
  f.customer_key,
  f.product_key,
  c.region,
  f.quantity,
  f.unit_price,
  f.discount,
  f.total,
  f.meta
FROM c22391076_dw.fact_sales f
JOIN c22391076_dw.dim_customer c
  ON f.customer_key = c.customer_key;

-- 4) Optional sanity checks

-- Total rows match original fact table?
SELECT COUNT(*) AS fact_sales_rows
FROM c22391076_dw.fact_sales;

SELECT COUNT(*) AS fact_sales_list_rows
FROM c22391076_dw.fact_sales_list;

-- Rows per region/partition
SELECT region, COUNT(*) AS rows_per_region
FROM c22391076_dw.fact_sales_list
GROUP BY region
ORDER BY region;

-- 5) Example EXPLAIN ANALYZE comparisons for the report

-- Non-partitioned
EXPLAIN ANALYZE
SELECT c.region, SUM(f.total) AS revenue
FROM c22391076_dw.fact_sales f
JOIN c22391076_dw.dim_customer c
  ON f.customer_key = c.customer_key
GROUP BY c.region
ORDER BY revenue DESC;

-- LIST-partitioned
EXPLAIN ANALYZE
SELECT region, SUM(total) AS revenue
FROM c22391076_dw.fact_sales_list
GROUP BY region
ORDER BY revenue DESC;
