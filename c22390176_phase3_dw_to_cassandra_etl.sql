-- 1) Export for customer_daily_sales.csv
--   Used by load_customer_daily_sales.py
SELECT
  customer_id,
  sale_date::date AS sale_date,
  SUM(total_amount) AS total_amount,
  ARRAY_AGG(DISTINCT product_id) AS product_ids
FROM fact_sales
GROUP BY customer_id, sale_date::date
ORDER BY customer_id, sale_date::date;
-- 2) Export for region_date_sales.csv
--   Used by region_date_sales.py
SELECT
  region,
  sale_date::date AS sale_date,
  SUM(total_amount) AS total_amount
FROM fact_sales
GROUP BY region, sale_date::date
ORDER BY region, sale_date::date;
-- 3) Export for product_sales_by_customer.csv
--   Used by product_sales_customer.py
SELECT
  product_id,
  customer_id,
  sale_date::date AS sale_date,
  SUM(quantity) AS total_quantity,
  SUM(total_amount) AS total_amount
FROM fact_sales
GROUP BY product_id, customer_id, sale_date::date
ORDER BY product_id, customer_id, sale_date::date;