from cassandra.cluster import Cluster
from cassandra import ConsistencyLevel
from datetime import date
from decimal import Decimal
import time

KEYSPACES = [
    ("c22391076_ks_rf1", 1),
    ("c22391076_ks_rf2", 2),
    ("c22391076_ks_rf3", 3),
]

INSERT_CQL = """
INSERT INTO customer_daily_sales (customer_id, sale_date, total_amount, product_ids)
VALUES (?, ?, ?, ?)
"""

SELECT_CQL = """
SELECT * FROM customer_daily_sales
WHERE customer_id = ?
"""

TESTS = [
    ("ONE", ConsistencyLevel.ONE),
    ("QUORUM", ConsistencyLevel.QUORUM),
    ("ALL", ConsistencyLevel.ALL),
]

def run_for_keyspace(session, ks_name, rf):
    print(f"=== Efficiency Report (RF={rf}) ===")
    print("CL      | Status   | Client (ms)")
    print("-------------------------------")

    customer_id = 9000

    for label, cl in TESTS:
        try:
            stmt_insert = session.prepare(INSERT_CQL)
            stmt_insert.consistency_level = cl

            stmt_select = session.prepare(SELECT_CQL)
            stmt_select.consistency_level = cl

            # writes
            start = time.perf_counter()
            for i in range(30):
                session.execute(
                    stmt_insert,
                    (customer_id,
                     date(2025, 9, 1 + i),
                     Decimal('10.0'),
                     [1, 2, 3])
                )
            write_ms = (time.perf_counter() - start) * 1000

            # reads
            start = time.perf_counter()
            rows = list(session.execute(stmt_select, (customer_id,)))
            read_ms = (time.perf_counter() - start) * 1000

            avg_ms = (write_ms + read_ms) / 2.0
            print(f"{label:<7} | Success  | {avg_ms:6.2f}")
        except Exception as e:
            print(f"{label:<7} | FAIL     |   n/a   ({e.__class__.__name__})")

if __name__ == "__main__":
    cluster = Cluster(['127.0.0.1'], port=9042)

    for ks_name, rf in KEYSPACES:
        session = cluster.connect(ks_name)
        run_for_keyspace(session, ks_name, rf)
        print()
        session.shutdown()

    cluster.shutdown()
