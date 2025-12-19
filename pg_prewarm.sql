CREATE EXTENSION IF NOT EXISTS pg_prewarm;

-- Before
EXPLAIN ANALYZE
SELECT SUM(total)
FROM c22391076_dw.fact_sales_unlogged;

-- Warm buffer cache
SELECT pg_prewarm('c22391076_dw.fact_sales_unlogged');

-- After
EXPLAIN ANALYZE
SELECT SUM(total)
FROM c22391076_dw.fact_sales_unlogged;
