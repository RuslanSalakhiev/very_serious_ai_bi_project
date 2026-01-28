# Удачные промпты для Cursor (dbt, schema.yml, Lightdash)

Сохраняй сюда промпты, которые дали лучший результат при записи кейса.

---

## Анализ задачи

- «Открой @Jira и проанализируй текущую задачу. Какие данные из наших таблиц (вижу через Database MCP) нужны для расчёта Retention Rate и выручки по категориям?»

---

## Staging-модели

- «Создай staging-модели для таблиц orders и users: очисти дубли по primary key, приведи даты к формату TIMESTAMP, обработай пустые значения. Источники — main.orders и main.users (Postgres, схема main).»

- «Добавь в stg_orders и stg_users тесты на unique и not_null для ключей и описание колонок в schema.yml.»

---

## Mart и метрики

- «Напиши финальную витрину fct_orders: объединение stg_orders и stg_users, все поля для выручки и по пользователям. Материализация — table.»

- «Создай schema.yml для fct_orders с тестами и описанием колонок.»

---

## Lightdash (сематический слой)

- «В schema.yml для модели fct_orders добавь meta для Lightdash: метрики total_revenue (sum amount, формат usd) и unique_customers (count distinct user_id), а также dimensions order_date, status, user_id. Используй актуальный синтаксис Lightdash meta.»

- «Проверь синтаксис YAML для Lightdash meta в нашем schema.yml — нет ли ошибок в отступах или ключах?»

---

## Общие

- «У нас Postgres и dbt-postgres. Все даты в сырых таблицах — строки в ISO формате; в staging приведи их к TIMESTAMP (проверка формата через regex, затем ::timestamp).»
