-- Relational: total sales by region
EXPLAIN ANALYZE
SELECT
  r.region_name,
  SUM(oi.quantity * oi.unit_price - oi.discount) AS total_sales,
  COUNT(DISTINCT o.order_id) AS order_count
FROM rel_src.orders o
JOIN rel_src.customers c ON o.customer_id = c.customer_id
JOIN rel_src.regions r   ON c.region_id = r.region_id
JOIN rel_src.order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY r.region_name
ORDER BY total_sales DESC;

-- Warehouse: total sales by region
EXPLAIN ANALYZE
SELECT
  dc.region,
  SUM(f.total) AS total_sales,
  COUNT(f.fact_id) AS order_count
FROM c22391076_dw.fact_sales f
JOIN c22391076_dw.dim_customer dc ON f.customer_key = dc.customer_key
GROUP BY dc.region
ORDER BY total_sales DESC;

-- Relational: average order value per region
EXPLAIN ANALYZE
SELECT
  r.region_name,
  AVG(oi.quantity * oi.unit_price - oi.discount) AS average_order_value
FROM rel_src.orders o
JOIN rel_src.order_items oi ON o.order_id = oi.order_id
JOIN rel_src.customers c ON o.customer_id = c.customer_id
JOIN rel_src.regions r ON c.region_id = r.region_id
WHERE o.status = 'delivered'
GROUP BY r.region_name
ORDER BY average_order_value DESC;

-- Warehouse: average order value per region
EXPLAIN ANALYZE
SELECT
  dc.region,
  AVG(f.total) AS average_order_value
FROM c22391076_dw.fact_sales f
JOIN c22391076_dw.dim_customer dc ON f.customer_key = dc.customer_key
GROUP BY dc.region
ORDER BY average_order_value DESC;
