#!/usr/bin/env python3
"""
Generate dirty test data for BI sandbox: users, orders, products, events.
Data is intentionally messy (duplicates, nulls) for dbt cleaning demo.
Writes to PostgreSQL (schema main). Requires Postgres running: docker compose up -d.
Uses PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE from environment (e.g. from .env).
"""
import os
import random
from pathlib import Path

import psycopg2
from faker import Faker

fake = Faker()
Faker.seed(42)
random.seed(42)

PROJECT_ROOT = Path(__file__).resolve().parent.parent


def load_dotenv():
    env_file = PROJECT_ROOT / ".env"
    if not env_file.exists():
        return
    for line in env_file.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        v = v.strip().strip('"').strip("'")
        if k and v and k not in os.environ:
            os.environ[k] = v


def get_pg_conn():
    load_dotenv()
    return psycopg2.connect(
        host=os.environ.get("PGHOST", "localhost"),
        port=int(os.environ.get("PGPORT", "5432")),
        user=os.environ.get("PGUSER", "postgres"),
        password=os.environ.get("PGPASSWORD", ""),
        dbname=os.environ.get("PGDATABASE", "postgres"),
    )


def create_schema_and_tables(conn):
    with conn.cursor() as cur:
        cur.execute("CREATE SCHEMA IF NOT EXISTS main;")
        cur.execute("""
            CREATE TABLE IF NOT EXISTS main.users (
                user_id INTEGER,
                email VARCHAR,
                name VARCHAR,
                country VARCHAR,
                created_at VARCHAR,
                is_active VARCHAR
            )
        """)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS main.products (
                product_id INTEGER,
                name VARCHAR,
                category VARCHAR,
                price DECIMAL(10, 2)
            )
        """)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS main.orders (
                order_id INTEGER,
                user_id INTEGER,
                product_id INTEGER,
                quantity INTEGER,
                amount DECIMAL(10, 2),
                order_date VARCHAR,
                status VARCHAR
            )
        """)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS main.events (
                event_id INTEGER,
                user_id INTEGER,
                event_type VARCHAR,
                event_at VARCHAR,
                page VARCHAR
            )
        """)
        conn.commit()


def truncate_tables(conn):
    with conn.cursor() as cur:
        for t in ("users", "products", "orders", "events"):
            cur.execute(f"TRUNCATE TABLE main.{t} CASCADE")
        conn.commit()


def insert_dirty_users(conn, n: int = 80):
    rows = []
    for i in range(1, n + 1):
        user_id = i if random.random() > 0.1 else random.randint(1, max(1, i - 1))
        email = fake.email() if random.random() > 0.15 else None
        name = fake.name()
        country = fake.country_code() if random.random() > 0.1 else ""
        created_at = fake.date_time_this_year().isoformat() if random.random() > 0.05 else None
        is_active = random.choice(["true", "false", ""])
        rows.append((user_id, email, name, country, created_at, is_active))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.users (user_id, email, name, country, created_at, is_active) VALUES (%s, %s, %s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def insert_dirty_products(conn, n: int = 30):
    categories = ["Electronics", "Clothing", "Home", "Sports", None, ""]
    rows = []
    for i in range(1, n + 1):
        product_id = i
        name = fake.catch_phrase()
        category = random.choice(categories)
        price = round(random.uniform(5.0, 500.0), 2) if random.random() > 0.05 else None
        rows.append((product_id, name, category, price))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.products (product_id, name, category, price) VALUES (%s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def insert_dirty_orders(conn, n: int = 200):
    statuses = ["completed", "pending", "cancelled", "COMPLETED", ""]
    rows = []
    for i in range(1, n + 1):
        order_id = i
        user_id = random.randint(1, 80) if random.random() > 0.05 else None
        product_id = random.randint(1, 30) if random.random() > 0.05 else None
        quantity = random.randint(1, 5) if random.random() > 0.1 else None
        amount = round(random.uniform(10.0, 1000.0), 2) if random.random() > 0.05 else None
        order_date = fake.date_time_this_year().isoformat() if random.random() > 0.05 else None
        status = random.choice(statuses)
        rows.append((order_id, user_id, product_id, quantity, amount, order_date, status))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.orders (order_id, user_id, product_id, quantity, amount, order_date, status) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def insert_dirty_events(conn, n: int = 300):
    event_types = ["page_view", "signup", "purchase", "login", None]
    pages = ["/", "/cart", "/checkout", "/product", ""]
    rows = []
    for i in range(1, n + 1):
        event_id = i
        user_id = random.randint(1, 80) if random.random() > 0.1 else None
        event_type = random.choice(event_types)
        event_at = fake.date_time_this_year().isoformat() if random.random() > 0.05 else None
        page = random.choice(pages)
        rows.append((event_id, user_id, event_type, event_at, page))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.events (event_id, user_id, event_type, event_at, page) VALUES (%s, %s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def main():
    load_dotenv()
    if not os.environ.get("PGPASSWORD"):
        print("Set PGPASSWORD (e.g. in .env). Ensure Postgres is running: docker compose up -d")
        raise SystemExit(1)

    conn = get_pg_conn()
    create_schema_and_tables(conn)
    truncate_tables(conn)
    insert_dirty_users(conn)
    insert_dirty_products(conn)
    insert_dirty_orders(conn)
    insert_dirty_events(conn)
    conn.close()

    host = os.environ.get("PGHOST", "localhost")
    db = os.environ.get("PGDATABASE", "postgres")
    print(f"Done. Data in Postgres: {host}/{db}, schema main (users, orders, products, events)")


if __name__ == "__main__":
    main()
