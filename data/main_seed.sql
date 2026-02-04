-- Minimal учебный датасет под текущий dbt-проект (schema main).
-- Цель: быстро стартовать без генерации Python-скриптом, но оставить "грязные" данные
-- (дубли, пустые строки, разные форматы дат), чтобы dbt-cleaning имел смысл.
-- Таблицы: users, products, promotions, orders (с promo_id), refunds, events.

BEGIN;

CREATE SCHEMA IF NOT EXISTS main;

CREATE TABLE IF NOT EXISTS main.users (
  user_id     INTEGER,
  email       VARCHAR,
  name        VARCHAR,
  country     VARCHAR,
  created_at  VARCHAR,
  is_active   VARCHAR
);

CREATE TABLE IF NOT EXISTS main.products (
  product_id  INTEGER,
  name        VARCHAR,
  category    VARCHAR,
  price       DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS main.promotions (
  promo_id    INTEGER,
  code        VARCHAR,
  discount_pct DECIMAL(5, 2),
  valid_from  VARCHAR,
  valid_to    VARCHAR
);

CREATE TABLE IF NOT EXISTS main.orders (
  order_id    INTEGER,
  user_id     INTEGER,
  product_id  INTEGER,
  quantity    INTEGER,
  amount      DECIMAL(10, 2),
  order_date  VARCHAR,
  status      VARCHAR,
  promo_id    INTEGER
);

CREATE TABLE IF NOT EXISTS main.refunds (
  refund_id   INTEGER,
  order_id    INTEGER,
  amount      DECIMAL(10, 2),
  refund_date VARCHAR,
  reason      VARCHAR
);

CREATE TABLE IF NOT EXISTS main.events (
  event_id    INTEGER,
  user_id     INTEGER,
  event_type  VARCHAR,
  event_at    VARCHAR,
  page        VARCHAR
);

-- Для БД, созданных старым дампом без promo_id: добавить колонку
ALTER TABLE main.orders ADD COLUMN IF NOT EXISTS promo_id INTEGER;

TRUNCATE TABLE main.refunds, main.events, main.orders, main.promotions, main.products, main.users;

-- users (есть дубли user_id и пустые значения)
INSERT INTO main.users (user_id, email, name, country, created_at, is_active) VALUES
  (1,  'alice@example.com',          'Alice A.',  'US', '2025-01-03T10:15:00', 'true'),
  (2,  'bob@example.com',            'Bob B.',    'DE', '2025-01-10 09:00:00', 'TRUE'),
  (3,  NULL,                         'Charlie C.','',   '2025-02-01',          'false'),
  (4,  'diana@example.com',          'Diana D.',  'FR', '',                    '1'),
  (5,  'eve@example.com',            'Eve E.',    'US', 'not-a-date',          'yes'),
  (6,  'frank@example.com',          'Frank F.',  'GB', '2025-03-12T08:00:00', '0'),
  (7,  'grace@example.com',          'Grace G.',  'CA', '2025-03-15T12:30:00', ''),
  (8,  'heidi@example.com',          'Heidi H.',  'US', '2025-04-01T00:00:00', 'false'),
  (9,  'ivan@example.com',           'Ivan I.',   'RU', '2025-04-05T14:20:00', 'true'),
  (10, 'judy@example.com',           'Judy J.',   'JP', '2025-05-01T09:45:00', 'true'),
  (3,  'charlie@example.com',        'Charlie C.','US', '2025-02-01T11:00:00', 'true');

-- products (есть NULL category/price)
INSERT INTO main.products (product_id, name, category, price) VALUES
  (101, 'Wireless Mouse',       'Electronics', 29.99),
  (102, 'Mechanical Keyboard',  'Electronics', 119.00),
  (103, 'Running Shoes',        'Sports',      79.50),
  (104, 'Coffee Mug',           'Home',        12.00),
  (105, 'T-Shirt',              'Clothing',    19.90),
  (106, 'Mystery Box',          NULL,          NULL);

-- promotions (разные форматы дат, пустые значения)
INSERT INTO main.promotions (promo_id, code, discount_pct, valid_from, valid_to) VALUES
  (1, 'SAVE10',  10.00, '2025-01-01T00:00:00', '2025-12-31T23:59:59'),
  (2, 'WINTER',  15.50, '2025-01-10 09:00:00', '2025-02-28'),
  (3, NULL,      5.00,  '',                    'not-a-date');

-- orders (есть дубликат order_id, пустые/кривые даты, статусы, promo_id)
INSERT INTO main.orders (order_id, user_id, product_id, quantity, amount, order_date, status, promo_id) VALUES
  (1001, 1,  101, 1,  29.99, '2025-01-05T12:00:00', 'completed', 1),
  (1002, 2,  102, 1, 119.00, '2025-01-11 10:00:00', 'COMPLETED', 1),
  (1003, 3,  104, 2,  24.00, '2025-02-03',          'pending',    NULL),
  (1004, 4,  103, 1,  79.50, '',                    'cancelled', 2),
  (1005, 5,  106, 1,  NULL,  'not-a-date',          '',          NULL),
  (1006, 6,  105, 3,  59.70, '2025-03-13T09:10:00', 'completed', 1),
  (1007, 7,  101, 2,  59.98, '2025-03-16T18:00:00', 'pending',    NULL),
  (1008, 8,  104, 1,  12.00, '2025-04-01T11:11:11', 'completed', 2),
  (1009, 9,  103, 1,  79.50, '2025-04-06T16:40:00', 'completed', 1),
  (1010, 10, 102, 1, 119.00, '2025-05-02T10:10:10', 'completed', NULL),
  (1003, 3,  104, 2,  24.00, '2025-02-03T00:00:00', 'pending',    NULL);

-- refunds (грязные даты и reason)
INSERT INTO main.refunds (refund_id, order_id, amount, refund_date, reason) VALUES
  (1, 1004, 79.50, '2025-02-15T14:00:00', 'defect'),
  (2, 1003, 24.00, '2025-02-10',          'cancelled'),
  (3, NULL, 10.00, '',                    NULL);

-- events
INSERT INTO main.events (event_id, user_id, event_type, event_at, page) VALUES
  (5001, 1,  'page_view', '2025-01-05T11:59:00', '/'),
  (5002, 1,  'purchase',  '2025-01-05T12:00:05', '/checkout'),
  (5003, 2,  'login',     '2025-01-11T09:50:00', '/'),
  (5004, 3,  'signup',    '2025-02-01T10:00:00', '/signup'),
  (5005, NULL,'page_view', '',                   '');

COMMIT;
