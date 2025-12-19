-- 1. Simple filter on JSONB device
SELECT *
FROM c22391076_dw.fact_sales
WHERE meta->>'device' = 'mobile';

-- 2. Group by a JSONB field (referrer)
SELECT meta->>'referrer' AS ref_type,
       COUNT(*) AS num_sales
FROM c22391076_dw.fact_sales
GROUP BY ref_type
ORDER BY num_sales DESC;

-- 3. Containment query using @>
SELECT *
FROM c22391076_dw.fact_sales
WHERE meta @> '{"campaign":"black_friday"}';

-- 4. JSONB query with EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT meta->>'device' AS device_type,
       COUNT(*) AS num_sales
FROM c22391076_dw.fact_sales
GROUP BY device_type;
