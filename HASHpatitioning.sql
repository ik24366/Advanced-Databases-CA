-- 0) Clean up if re-running
DROP TABLE IF EXISTS c22391076_dw.fact_sales_hash CASCADE;

-- 1) Parent table partitioned by HASH(customer_key)
CREATE TABLE c22391076_dw.fact_sales_hash
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
PARTITION BY HASH (customer_key);

-- 2) Define 4 hash partitions
CREATE TABLE c22391076_dw.fact_sales_hash_p0
  PARTITION OF c22391076_dw.fact_sales_hash
  FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE c22391076_dw.fact_sales_hash_p1
  PARTITION OF c22391076_dw.fact_sales_hash
  FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE c22391076_dw.fact_sales_hash_p2
  PARTITION OF c22391076_dw.fact_sales_hash
  FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE c22391076_dw.fact_sales_hash_p3
  PARTITION OF c22391076_dw.fact_sales_hash
  FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- 3) Load data from original fact_sales
INSERT INTO c22391076_dw.fact_sales_hash
SELECT fact_id, date_key, customer_key, product_key,
       quantity, unit_price, discount, total, meta
FROM c22391076_dw.fact_sales;

-- 4) Optional sanity check
SELECT COUNT(*) AS fact_sales_rows
FROM c22391076_dw.fact_sales;

SELECT COUNT(*) AS fact_sales_hash_rows
FROM c22391076_dw.fact_sales_hash;
