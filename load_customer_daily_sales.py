from cassandra.cluster import Cluster
import csv
from datetime import datetime
from decimal import Decimal

cluster = Cluster(['localhost']) 
session = cluster.connect('c22391076_ks')

insert_cql = """
INSERT INTO customer_daily_sales (customer_id, sale_date, total_amount, product_ids)
VALUES (%s, %s, %s, %s)
"""

with open('customer_daily_sales.csv', newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        customer_id = int(row['customer_id'])
        sale_date = datetime.strptime(row['sale_date'], '%Y-%m-%d').date()
        total_amount = Decimal(row['total_amount'])
        # pg ARRAY -> {1,2,3} or similar
        raw = row['product_ids'].strip('{}')
        product_ids = [int(x) for x in raw.split(',') if x]
        session.execute(insert_cql, (customer_id, sale_date, total_amount, product_ids))
