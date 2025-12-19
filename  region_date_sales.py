from cassandra.cluster import Cluster
import csv
from datetime import datetime
from decimal import Decimal

# 1. Connect to Cassandra
cluster = Cluster(['localhost'])          # or ['c22391076_cassandra1'] if running inside Docker
session = cluster.connect('c22391076_ks') # keyspace name

# 2. CQL insert statement
insert_cql = """
INSERT INTO region_date_sales (region, sale_date, total_amount)
VALUES (%s, %s, %s)
"""

# 3. Load CSV and insert rows
with open('region_date_sales.csv', newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        region = row['region']
        sale_date = datetime.strptime(row['sale_date'], '%Y-%m-%d').date()
        total_amount = Decimal(row['total_amount'])
        session.execute(insert_cql, (region, sale_date, total_amount))

print("Loaded region_date_sales.csv into Cassandra")
