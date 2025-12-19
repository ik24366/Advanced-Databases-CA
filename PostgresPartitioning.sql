-- Query used to test RANGE partitioning
-- Total revenue per month for 2025
SELECT
  d.year,
  d.month,
  SUM(f.total) AS revenue
FROM c22391076_dw.fact_sales f
JOIN c22391076_dw.dim_date d ON f.date_key = d.date_key
WHERE d.year = 2025
GROUP BY d.year, d.month
ORDER BY d.month;
-- Query used to test LIST partitioning
-- Total sales by region
SELECT
  c.region,
  SUM(f.total) AS revenue
FROM c22391076_dw.fact_sales f
JOIN c22391076_dw.dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.region
ORDER BY revenue DESC;
-- Query used to test HASH partitioning
-- All sales for a given customer
SELECT
  f.*
FROM c22391076_dw.fact_sales f
WHERE f.customer_key = 123;  -- pick a real customer_key that exists
