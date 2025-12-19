-- =========================================================
-- RANGE partitioning for c22391076_dw.fact_sales on date_key
-- =========================================================

-- 0) Safety: drop existing partitioned table if re-running
DROP TABLE IF EXISTS c22391076_dw.fact_sales_range CASCADE;

-- 1) Create partitioned parent table
CREATE TABLE c22391076_dw.fact_sales_range
(
  fact_id      serial,
  date_key     integer,
  customer_key bigint,
  product_key  bigint,
  quantity     integer,
  unit_price   numeric(12,2),
  discount     numeric(12,2),
  total        numeric(12,2),
  meta         jsonb
)
PARTITION BY RANGE (date_key);

-- 2) Create partitions covering 2025-09-14 to 2025-11-30
CREATE TABLE c22391076_dw.fact_sales_range_sep
  PARTITION OF c22391076_dw.fact_sales_range
  FOR VALUES FROM (20250914) TO (20251001);

CREATE TABLE c22391076_dw.fact_sales_range_oct
  PARTITION OF c22391076_dw.fact_sales_range
  FOR VALUES FROM (20251001) TO (20251101);

CREATE TABLE c22391076_dw.fact_sales_range_nov
  PARTITION OF c22391076_dw.fact_sales_range
  FOR VALUES FROM (20251101) TO (20251201);

-- 3) Load all rows from original fact_sales
INSERT INTO c22391076_dw.fact_sales_range
SELECT fact_id, date_key, customer_key, product_key,
       quantity, unit_price, discount, total, meta
FROM c22391076_dw.fact_sales;

-- 4) Optional checks

-- Row counts match?
SELECT COUNT(*) AS fact_sales_rows
FROM c22391076_dw.fact_sales;

SELECT COUNT(*) AS fact_sales_range_rows
FROM c22391076_dw.fact_sales_range;

-- Per-partition counts
SELECT COUNT(*) AS sep_rows
FROM c22391076_dw.fact_sales_range_sep;

SELECT COUNT(*) AS oct_rows
FROM c22391076_dw.fact_sales_range_oct;

SELECT COUNT(*) AS nov_rows
FROM c22391076_dw.fact_sales_range_nov;

-- 5) Example comparison queries (for report)

-- Non-partitioned
EXPLAIN ANALYZE
SELECT SUM(total)
FROM c22391076_dw.fact_sales
WHERE date_key BETWEEN 20251001 AND 20251031;

-- Range-partitioned
EXPLAIN ANALYZE
SELECT SUM(total)
FROM c22391076_dw.fact_sales_range
WHERE date_key BETWEEN 20251001 AND 20251031;
