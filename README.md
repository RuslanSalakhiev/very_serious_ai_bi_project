# BI Analytics Sandbox

**Учебный репозиторий** для пошаговой установки и прохождения end-to-end кейса: Cursor (MCP) → dbt → Lightdash на тестовых данных в **PostgreSQL**. Весь Python-инструментарий (dbt) работает в **одном виртуальном окружении** `venv` в корне проекта.

## Цель

Показать, как с помощью Cursor и MCP (Database) анализировать бизнес-задачу, строить dbt-модели (staging → marts), настраивать семантический слой для Lightdash и собирать дашборд без дублирования SQL. Все компоненты связаны в одной «песочнице» — можно пройти по шагам и повторить у себя.

## Пошаговая установка

**Главная инструкция:** [docs/installation.md](docs/installation.md)

В ней по порядку описаны:

| Шаг | Действие |
|-----|----------|
| 0 | Проверить, что установлены Python 3.10+, контейнеры (Colima на macOS / Podman на Windows), Git, Cursor |
| 1 | Клонировать репозиторий |
| 2 | Создать и активировать виртуальное окружение `venv` |
| 3 | Установить зависимости в `venv` (`pip install -r scripts/requirements.txt` — dbt) |
| 4 | Настроить `.env` (PGPASSWORD, LIGHTDASH_SECRET, DBT_PROJECT_DIR) |
| 5 | Запустить Postgres и Lightdash (Colima: `docker compose up -d`; Podman: `podman compose up -d`) |
| 6 | Загрузить тестовые данные в Postgres (импорт `data/main_seed.sql`) |
| 7 | Выполнить `dbt run`, `dbt compile` (подключение к Postgres из `.env`) |
| 8 | Подключить проект dbt в Lightdash (CLI или UI) и проверить метрики |
| 9 | Настроить MCP в Cursor для Postgres |
| 10 | Пройти сценарий кейса (анализ задачи, модели, дашборд) |

В конце инструкции — раздел «Частые проблемы» и ссылки на остальные документы.

## Требования

- **Python 3.10+** — dbt
- **Контейнеры** — Postgres и Lightdash: Colima (macOS) или Podman (Windows); см. [installation.md](docs/installation.md)
- **dbt-core + dbt-postgres** — трансформации
- **Cursor** — редактор с MCP (Postgres)

## Структура проекта

| Каталог / файл | Назначение |
|----------------|------------|
| **data/** | SQL-дамп тестовых данных (`main_seed.sql`) |
| **scripts/** | Скрипт загрузки дампа в Postgres (`load_seed_to_postgres.sh`) |
| **dbt_bi/** | dbt-проект: staging (stg_orders, stg_users), marts (fct_orders), schema.yml с тестами и meta для Lightdash |
| **docker/** | Скрипт `init-minio.sh` для Lightdash |
| **docs/** | Инструкции и материалы кейса |
| **.cursor/** | Пример `mcp.json` для Postgres |

## Документация в docs/

| Файл | Содержание |
|------|------------|
| [installation.md](docs/installation.md) | **Пошаговая установка** — основная инструкция |
| [data_schema_and_dashboards.md](docs/data_schema_and_dashboards.md) | **Схема данных** и кейсы дашбордов (Sales, Promotions, Products, Geography, Refunds, Events) |
| [scenario.md](docs/scenario.md) | Сценарий кейса: проблема → решение через AI → результат |
| [prompts.md](docs/prompts.md) | Готовые промпты для Cursor (dbt, schema.yml, Lightdash) |
| [checklist.md](docs/checklist.md) | Чек-лист перед записью/статьёй |
| [visual_setup.md](docs/visual_setup.md) | Настройка экрана для записи видео |

## Быстрый старт (после установки по инструкции)

Если вы уже прошли шаги 1–7 из [docs/installation.md](docs/installation.md):

```bash
# В корне проекта, с активированным venv
# macOS (Colima): docker compose up -d
# Windows (Podman): podman compose up -d
bash scripts/load_seed_to_postgres.sh
cd dbt_bi && set -a && source ../.env && set +a && dbt run && dbt compile && cd ..
```

Затем откройте http://localhost:8080 и подключите проект dbt в Lightdash (шаг 8).

## Лицензия и вклад

Репозиторий учебный; используйте код и инструкции по своему усмотрению. Если будете делиться кейсом — ссылка на этот репозиторий поможет другим повторить шаги.
