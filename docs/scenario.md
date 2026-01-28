# Сценарий кейса: BI Analytics Sandbox

## Проблема

Маркетинг просит отчитаться: **Retention Rate** и **выручка по категориям**. Данные лежат в «сырых» таблицах (users, orders, products, events) с дублями, пустыми значениями и разными форматами дат. Нужно связать задачу из Jira, данные в БД, dbt-модели и BI-инструмент так, чтобы всё было повторяемо и понятно.

## Решение через AI (Cursor + MCP)

1. **Анализ задачи (Cursor + Jira)**  
   В чате Cursor упоминаешь @Jira и просишь проанализировать текущую задачу. Cursor читает тикет («Рассчитать Retention Rate и выручку по категориям») и, видя схему через Database MCP, объясняет, какие таблицы и поля нужны.

2. **dbt-модели (Cursor + dbt)**  
   Просишь Cursor: создать staging для orders и users (очистка дублей, приведение дат к TIMESTAMP), затем mart fct_orders с метриками. Выделяешь код и просишь сгенерировать schema.yml с тестами и описаниями.

3. **Семантический слой (Cursor + Lightdash)**  
   В schema.yml для marts просишь добавить meta для Lightdash: метрики total_revenue, unique_customers и измерения. Cursor помогает не запутаться в синтаксисе YAML.

4. **Визуализация**  
   Запускаешь `dbt run` и `dbt compile`, подключаешь проект dbt в локальном Lightdash (localhost:8080). Метрики из кода появляются в UI (drag-and-drop), создаёшь один дашборд.

## Результат

- Задача из Jira связана с конкретными таблицами и моделями.
- «Грязные» данные очищены в dbt (staging → marts).
- Метрики и измерения заданы в коде (schema.yml + meta Lightdash), без дублирования SQL в BI.
- Кейс повторяем: clone → .env → docker-compose up → generate data (Postgres) → dbt run → подключить dbt в Lightdash.
