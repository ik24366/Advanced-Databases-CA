from cassandra.cluster import Cluster
import csv
from datetime import datetime
from decimal import Decimal

cluster = Cluster(['localhost'])
session = cluster.connect('c22391076_ks')

insert_cql = """
INSERT INTO product_sales_by_customer
(product_id, customer_id, sale_date, quantity, total_amount)
VALUES (%s, %s, %s, %s, %s)
"""

with open('product_sales_by_customer.csv', newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        product_id = int(row['product_id'])
        customer_id = int(row['customer_id'])
        sale_date = datetime.strptime(row['sale_date'], '%Y-%m-%d').date()
        quantity = int(row['total_quantity'])
        total_amount = Decimal(row['total_amount'])
        session.execute(insert_cql, (product_id, customer_id, sale_date, quantity, total_amount))
