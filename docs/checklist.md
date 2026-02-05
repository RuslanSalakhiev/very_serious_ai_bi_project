# Чек-лист перед записью/статьёй

- [ ] **Установка по шагам**  
  Все шаги из [installation.md](installation.md) выполнены (clone → venv → данные → .env → Colima/Podman → dbt → Lightdash → MCP).

- [ ] **Сценарий/текст**  
  О чём говоришь: проблема → решение через AI → результат (см. [scenario.md](scenario.md)).

- [ ] **Prompt-инструкции**  
  Сохранены удачные промпты в [prompts.md](prompts.md).

- [ ] **Репозиторий**  
  Код на GitHub; в README указано: clone → venv → pip install -r scripts/requirements.txt → cp .env.example .env и заполнить PGPASSWORD, LIGHTDASH_SECRET, DBT_PROJECT_DIR → Colima/Podman (compose up) → python scripts/generate_test_data.py → открыть Lightdash и подключить dbt.

- [ ] **Визуальный стиль**  
  Если видео: экран показывает чат Cursor, дерево файлов и браузер с Lightdash (см. [visual_setup.md](visual_setup.md)).

- [ ] **Данные**  
  Данные сгенерированы в Postgres (скрипт `python scripts/generate_test_data.py`, схема main); dbt run и dbt compile выполняются без ошибок.

- [ ] **Lightdash**  
  Проект dbt подключён, метрики total_revenue и unique_customers видны в UI; один дашборд собран.

- [ ] **MCP**  
  Database MCP указывает на Postgres (localhost, schema main).
