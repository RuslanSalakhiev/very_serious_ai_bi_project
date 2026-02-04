#!/usr/bin/env python3
"""
Generate dirty test data for BI sandbox: users, orders, products, events, promotions, refunds.
Data is intentionally messy (duplicates, nulls, multiple date formats) for dbt cleaning demo.
Writes to PostgreSQL (schema main). Requires Postgres running: docker compose up -d.
Uses PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE from environment (e.g. from .env).
"""
import argparse
import os
import random
from datetime import datetime, timedelta
from pathlib import Path

import psycopg2
from faker import Faker

PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Seeds set in main() after parsing args so --seed is respected


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


# --------------- Date format generators (intentionally messy) ---------------
def _random_date_in_range(base_date: datetime, days_back: int) -> datetime:
    return base_date - timedelta(days=random.randint(0, days_back))


def format_date_iso_ts(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%dT%H:%M:%S")


def format_date_iso_date_only(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d")


def format_date_slash(dt: datetime) -> str:
    return dt.strftime("%d/%m/%Y %H:%M")


def format_date_us(dt: datetime) -> str:
    return dt.strftime("%m-%d-%Y")


def format_date_spaced(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d %H:%M:%S")


DATE_FORMATTERS = [
    format_date_iso_ts,
    format_date_iso_date_only,
    format_date_slash,
    format_date_us,
    format_date_spaced,
]


def random_dirty_date(fake: Faker, days_back: int = 365) -> str | None:
    if random.random() < 0.05:
        return None
    if random.random() < 0.05:
        return random.choice(["not-a-date", "", "2025-13-45", "01/02/2025"])
    base = fake.date_time_this_year()
    dt = _random_date_in_range(base, days_back)
    return random.choice(DATE_FORMATTERS)(dt)


# --------------- Schema and tables ---------------
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
            CREATE TABLE IF NOT EXISTS main.promotions (
                promo_id INTEGER,
                code VARCHAR,
                discount_pct DECIMAL(5, 2),
                valid_from VARCHAR,
                valid_to VARCHAR
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
                status VARCHAR,
                promo_id INTEGER
            )
        """)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS main.refunds (
                refund_id INTEGER,
                order_id INTEGER,
                amount DECIMAL(10, 2),
                refund_date VARCHAR,
                reason VARCHAR
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
        for t in ("refunds", "events", "orders", "promotions", "products", "users"):
            cur.execute(f"TRUNCATE TABLE main.{t} CASCADE")
        conn.commit()


# --------------- Inserts ---------------
def insert_dirty_users(conn, n: int, fake: Faker):
    rows = []
    for i in range(1, n + 1):
        user_id = i if random.random() > 0.08 else random.randint(1, max(1, i - 1))
        email = fake.email() if random.random() > 0.12 else None
        name = fake.name()
        # Intentionally messy country: code, full name, typo
        country_choice = random.random()
        if country_choice < 0.6:
            country = fake.country_code()
        elif country_choice < 0.85:
            country = fake.country()[:20]  # long name
        else:
            country = random.choice(["", "XX", "USA", "UK", None])
        created_at = random_dirty_date(fake)
        is_active = random.choice(["true", "false", "1", "0", "yes", "", "TRUE"])
        rows.append((user_id, email, name, country, created_at, is_active))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.users (user_id, email, name, country, created_at, is_active) VALUES (%s, %s, %s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def insert_dirty_products(conn, n: int, fake: Faker):
    categories = ["Electronics", "Clothing", "Home", "Sports", "Books", None, "", "ELECTRONICS"]
    rows = []
    for i in range(1, n + 1):
        product_id = i
        name = fake.catch_phrase()
        category = random.choice(categories)
        price = round(random.uniform(5.0, 500.0), 2) if random.random() > 0.04 else None
        rows.append((product_id, name, category, price))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.products (product_id, name, category, price) VALUES (%s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def insert_dirty_promotions(conn, n: int, fake: Faker):
    rows = []
    for i in range(1, n + 1):
        promo_id = i
        code = fake.bothify(text="???###").upper() if random.random() > 0.1 else None
        discount_pct = round(random.uniform(5.0, 30.0), 2) if random.random() > 0.05 else None
        valid_from = random_dirty_date(fake, days_back=180)
        valid_to = random_dirty_date(fake, days_back=90)
        rows.append((promo_id, code, discount_pct, valid_from, valid_to))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.promotions (promo_id, code, discount_pct, valid_from, valid_to) VALUES (%s, %s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def insert_dirty_orders(conn, n: int, n_users: int, n_products: int, n_promos: int, fake: Faker):
    statuses = ["completed", "pending", "cancelled", "COMPLETED", "Completed", ""]
    rows = []
    for i in range(1, n + 1):
        order_id = i
        user_id = random.randint(1, n_users) if random.random() > 0.04 else None
        product_id = random.randint(1, n_products) if random.random() > 0.04 else None
        quantity = random.randint(1, 5) if random.random() > 0.08 else None
        amount = round(random.uniform(10.0, 1000.0), 2) if random.random() > 0.05 else None
        order_date = random_dirty_date(fake)
        status = random.choice(statuses)
        promo_id = random.randint(1, n_promos) if n_promos and random.random() > 0.7 else None
        rows.append((order_id, user_id, product_id, quantity, amount, order_date, status, promo_id))
    with conn.cursor() as cur:
        cur.executemany(
            """INSERT INTO main.orders (order_id, user_id, product_id, quantity, amount, order_date, status, promo_id)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
            rows,
        )
    conn.commit()


def insert_dirty_refunds(conn, n: int, max_order_id: int, fake: Faker):
    reasons = ["defect", "wrong_item", "cancelled", "other", None, ""]
    rows = []
    for i in range(1, n + 1):
        refund_id = i
        order_id = random.randint(1, max_order_id) if max_order_id and random.random() > 0.1 else None
        amount = round(random.uniform(5.0, 200.0), 2) if random.random() > 0.05 else None
        refund_date = random_dirty_date(fake)
        reason = random.choice(reasons)
        rows.append((refund_id, order_id, amount, refund_date, reason))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.refunds (refund_id, order_id, amount, refund_date, reason) VALUES (%s, %s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def insert_dirty_events(conn, n: int, n_users: int, fake: Faker):
    event_types = ["page_view", "signup", "purchase", "login", "logout", None, ""]
    pages = ["/", "/cart", "/checkout", "/product", "/search", ""]
    rows = []
    for i in range(1, n + 1):
        event_id = i
        user_id = random.randint(1, n_users) if n_users and random.random() > 0.08 else None
        event_type = random.choice(event_types)
        event_at = random_dirty_date(fake)
        page = random.choice(pages)
        rows.append((event_id, user_id, event_type, event_at, page))
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO main.events (event_id, user_id, event_type, event_at, page) VALUES (%s, %s, %s, %s, %s)",
            rows,
        )
    conn.commit()


def main():
    parser = argparse.ArgumentParser(description="Generate dirty test data for BI sandbox (Postgres, schema main).")
    parser.add_argument("--users", type=int, default=80, help="Number of user rows")
    parser.add_argument("--products", type=int, default=30, help="Number of product rows")
    parser.add_argument("--promos", type=int, default=15, help="Number of promotion rows")
    parser.add_argument("--orders", type=int, default=200, help="Number of order rows")
    parser.add_argument("--refunds", type=int, default=25, help="Number of refund rows")
    parser.add_argument("--events", type=int, default=400, help="Number of event rows")
    parser.add_argument("--seed", type=int, default=42, help="Random seed for reproducibility")
    parser.add_argument("--no-truncate", action="store_true", help="Do not truncate tables before insert (append)")
    args = parser.parse_args()

    Faker.seed(args.seed)
    random.seed(args.seed)
    fake = Faker()
    # Use locale for more variety (optional)
    try:
        fake = Faker(["en_US", "de_DE", "fr_FR"])
        Faker.seed(args.seed)
    except Exception:
        pass

    load_dotenv()
    if not os.environ.get("PGPASSWORD"):
        print("Set PGPASSWORD (e.g. in .env). Ensure Postgres is running: docker compose up -d")
        raise SystemExit(1)

    conn = get_pg_conn()
    create_schema_and_tables(conn)
    if not args.no_truncate:
        truncate_tables(conn)

    insert_dirty_users(conn, args.users, fake)
    insert_dirty_products(conn, args.products, fake)
    insert_dirty_promotions(conn, args.promos, fake)
    insert_dirty_orders(conn, args.orders, args.users, args.products, args.promos, fake)
    insert_dirty_refunds(conn, args.refunds, args.orders, fake)
    insert_dirty_events(conn, args.events, args.users, fake)
    conn.close()

    host = os.environ.get("PGHOST", "localhost")
    db = os.environ.get("PGDATABASE", "postgres")
    print(
        f"Done. Data in Postgres: {host}/{db}, schema main "
        f"(users={args.users}, products={args.products}, promos={args.promos}, "
        f"orders={args.orders}, refunds={args.refunds}, events={args.events})"
    )


if __name__ == "__main__":
    main()
