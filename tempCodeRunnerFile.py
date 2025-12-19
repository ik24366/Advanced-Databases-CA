from cassandra.cluster import Cluster
from cassandra import ConsistencyLevel
from cassandra.query import SimpleStatement
from datetime import date
from decimal import Decimal
import time

# Connect via node1's exposed port
cluster = Cluster(['127.0.0.1'], port=9042)
session = cluster.connect('c22391076_ks')

insert_cql = """
INSERT INTO customer_daily_sales (customer_id, sale_date, total_amount, product_ids)
VALUES (?, ?, ?, ?)
"""

select_cql = """
SELECT * FROM customer_daily_sales
WHERE customer_id = ?
"""

def run_test(label, consistency):
    # Prepare statements
    stmt_insert = session.prepare(insert_cql)
    stmt_insert.consistency_level = consistency

    stmt_select = SimpleStatement(select_cql, consistency_level=consistency)

    customer_id = 9000

    # WRITE TEST
    start = time.perf_counter()
    for i in range(30):   # 30 valid days in September
        session.execute(
            stmt_insert,
            (customer_id,
             date(2025, 9, 1 + i),
             Decimal('10.0'),
             [1, 2, 3])
        )
    write_time = time.perf_counter() - start

    # READ TEST
    start = time.perf_counter()
    rows = list(session.execute(stmt_select, (customer_id,)))
    read_time = time.perf_counter() - start

    print(f"{label}: writes={write_time:.4f}s reads={read_time:.4f}s rows={len(rows)}")

tests = [
    ("ONE", ConsistencyLevel.ONE),
    ("QUORUM", ConsistencyLevel.QUORUM),
    ("ALL", ConsistencyLevel.ALL),
]

for label, cl in tests:
    run_test(label, cl)

cluster.shutdown()
