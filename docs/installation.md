# Пошаговая установка: BI Analytics Sandbox

Учебная инструкция. Выполняйте шаги по порядку — каждый шаг опирается на предыдущий.

**Виртуальное окружение:** весь Python-инструментарий (генерация данных и dbt) работает в **одном виртуальном окружении** `venv` в корне проекта. После активации `venv` все команды `python`, `pip` и `dbt` выполняются внутри него.

---

## Шаг 0. Что нужно установить заранее

Проверьте, что у вас есть:

| Инструмент | Версия | Зачем |
|------------|--------|--------|
| **Python** | 3.10 или выше | Генерация данных и dbt |
| **Docker** | актуальная | Запуск Lightdash |
| **Docker Compose** | v2+ | Оркестрация контейнеров |
| **Git** | любая | Клонирование репозитория |
| **Cursor** | актуальная | Редактор с MCP (Jira, Postgres) |
| **Node.js и npm** | для шага 8, вариант А | Lightdash CLI (подключение без настройки warehouse в UI) |

Проверка в терминале:

```bash
python3 --version    # должно быть 3.10+
docker --version
docker compose version
git --version
node -v; npm -v      # нужны для шага 8 (вариант А — Lightdash CLI)
```

Если `docker` или `docker compose` не найдены — установите Docker (на macOS: [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/) или Orbstack/Colima), запустите приложение/демон и при необходимости откройте новый терминал. Подробнее — в разделе «Частые проблемы» ниже.

---

## Шаг 1. Клонировать репозиторий

1. Откройте терминал.
2. Перейдите в каталог, где хотите разместить проект (например, `~/projects`).
3. Выполните:

```bash
git clone https://github.com/YOUR_ORG/very_serious_ai_bi_project.git
cd very_serious_ai_bi_project
```

Замените `YOUR_ORG` на ваш GitHub-аккаунт или организацию. Если репозиторий ещё не на GitHub — создайте его и сделайте первый push.

**Результат:** в текущей папке есть каталоги `data/`, `scripts/`, `dbt_bi/`, `docs/`, `docker/` и файлы `README.md`, `docker-compose.yml`, `.env.example`.

---

## Шаг 2. Создать виртуальное окружение Python (одно на весь проект)

1. В корне проекта выполните:

```bash
python3 -m venv venv
```

2. Активируйте окружение:

- **macOS / Linux:**
  ```bash
  source venv/bin/activate
  ```
- **Windows (PowerShell):**
  ```powershell
  venv\Scripts\Activate.ps1
  ```
- **Windows (cmd):**
  ```cmd
  venv\Scripts\activate.bat
  ```

В начале строки приглашения должно появиться `(venv)`.

**Результат:** активное виртуальное окружение; все следующие команды `pip`, `python` и `dbt` выполняются в нём. Не выходите из окружения до конца работы с проектом.

---

## Шаг 3. Установить все зависимости в виртуальном окружении

В корне проекта (с активированным `venv`) выполните:

```bash
pip install -r scripts/requirements.txt
```

Установятся пакеты для генерации данных (`faker`, `psycopg2-binary`) и для dbt (`dbt-core`, `dbt-postgres`). Проверка (в том же окружении):

```bash
dbt --version
```

**Результат:** в одном окружении доступны скрипт генерации данных и dbt; `dbt --version` показывает версии dbt-core и postgres.

---

## Шаг 4. Настроить переменные окружения

1. Скопируйте пример конфигурации:

```bash
cp .env.example .env
```

2. Откройте файл `.env` в редакторе.
3. Заполните обязательные переменные:

| Переменная | Что подставить | Пример |
|------------|----------------|--------|
| `PGPASSWORD` | Пароль для внутренней БД Postgres в Lightdash | `my_secure_password` |
| `LIGHTDASH_SECRET` | Секрет для шифрования (не менее 32 символов) | `my_lightdash_secret_key_32_chars_min` |
| `DBT_PROJECT_DIR` | Путь к папке dbt-проекта | `./dbt_bi` или полный путь, например `/Users/you/projects/very_serious_ai_bi_project/dbt_bi` |

На macOS/Linux при использовании Docker часто нужен **абсолютный путь** к `dbt_bi`, например:

```bash
DBT_PROJECT_DIR=/Users/ваш_пользователь/path/to/very_serious_ai_bi_project/dbt_bi
```

Остальные переменные в `.env` можно оставить по умолчанию.

**Результат:** файл `.env` существует, в нём заданы `PGPASSWORD`, `LIGHTDASH_SECRET` и `DBT_PROJECT_DIR`. Файл `.env` не коммитится в git (он в `.gitignore`).

---

## Шаг 5. Запустить Postgres и Lightdash в Docker

1. В корне проекта (виртуальное окружение может оставаться активным) сделайте скрипт MinIO исполняемым (на macOS/Linux после клонирования бит execute может не сохраниться):

```bash
chmod +x docker/init-minio.sh
```

2. Запустите контейнеры:

```bash
docker compose up -d
```

3. Дождитесь запуска контейнеров (Postgres, MinIO, Lightdash). Первый запуск может занять несколько минут из-за загрузки образов.

4. Проверьте, что подняты **все три** сервиса: `db`, `minio`, `lightdash`:
   ```bash
   docker compose ps
   ```
   Должны быть в состоянии `Up`: **db** (порт 5432), **minio** (9000, 9001), **lightdash** (8080). Если виден только `db` или minio падает с «permission denied» — выполните `chmod +x docker/init-minio.sh` и снова `docker compose up -d`. Подробнее — раздел «Частые проблемы».

5. Откройте в браузере: **http://localhost:8080**

**Результат:** открывается страница Lightdash (логин/регистрация). Postgres доступен на `localhost:5432` (порт проброшен из контейнера `db`). Порт Lightdash по умолчанию — 8080; если занят, в `.env` задайте другой через `PORT`.

---

## Шаг 6. Сгенерировать тестовые данные в Postgres

1. Убедитесь, что вы в корне проекта, виртуальное окружение **активно** и Postgres уже запущен (шаг 5: `docker compose up -d`). В `.env` должен быть задан `PGPASSWORD`.
2. Выполните:

```bash
python scripts/generate_test_data.py
```

3. В конце должно появиться сообщение вида: `Done. Data in Postgres: localhost/postgres, schema main (users, orders, products, events)`.

**Результат:** в Postgres (схема `main`) созданы таблицы `users`, `orders`, `products`, `events` с намеренно «грязными» данными (дубли, пустые значения, разные форматы) для демонстрации очистки в dbt.

---

## Шаг 7. Запустить dbt (Postgres, в том же venv)

1. Оставьте виртуальное окружение **активным**. Перейдите в каталог dbt-проекта и подхватите переменные из `.env` (из корня проекта):

- **macOS / Linux:**
  ```bash
  cd dbt_bi
  set -a && source ../.env && set +a
  ```
- **Windows (PowerShell):**
  ```powershell
  cd dbt_bi
  Get-Content ..\.env | ForEach-Object { if ($_ -match '^([^#=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($matches[1], $matches[2].Trim('"'), 'Process') } }
  ```

2. Проверьте подключение к Postgres:

```bash
dbt debug
```

В выводе должно быть сообщение об успешном подключении к Postgres.

3. Выполните трансформации:

```bash
dbt run
```

4. Соберите артефакты для Lightdash:

```bash
dbt compile
```

5. При необходимости вернитесь в корень проекта (окружение остаётся активным):

```bash
cd ..
```

**Результат:** модели `stg_orders`, `stg_users` и `fct_orders` успешно выполняются в Postgres; в `dbt_bi/target/` появляются скомпилированные файлы и `manifest.json`.

---

## Шаг 8. Подключить проект dbt в Lightdash

Проект использует **PostgreSQL**; Lightdash поддерживает Postgres. См. [Create your first project — Lightdash](https://docs.lightdash.com/get-started/setup-lightdash/get-project-lightdash-ready).

### Вариант А: через Lightdash CLI (рекомендуется)

1. Установите Node.js и npm, если их ещё нет (`node -v`, `npm -v`). При необходимости: [Node.js LTS](https://nodejs.org/) или [nvm](https://github.com/nvm-sh/nvm#install--update-script): `nvm install --lts`.

2. Установите Lightdash CLI:
   ```bash
   npm install -g @lightdash/cli
   ```

3. Откройте Lightdash в браузере: **http://localhost:8080**, зарегистрируйтесь или войдите.

4. Получите персональный токен: в Lightdash **Settings** → **Personal access tokens** → создайте токен и скопируйте его.

5. Войдите в CLI (подставьте свой токен):
   ```bash
   lightdash login http://localhost:8080 --token ВАШ_ТОКЕН
   ```

6. Перейдите в каталог dbt-проекта и подхватите `.env` (PGPASSWORD и др. нужны для подключения к Postgres):
   ```bash
   cd dbt_bi
   set -a && source ../.env && set +a
   ```

7. При необходимости обновите описание колонок для Lightdash:
   ```bash
   lightdash dbt run
   ```

8. Создайте проект в Lightdash из локального dbt (подключение берётся из `profiles.yml` — Postgres):
   ```bash
   lightdash deploy --create
   ```
   В выводе будет ссылка на проект — откройте её в браузере.

**Результат:** проект в Lightdash создан; таблицы, измерения и метрики подтянуты из dbt; запросы выполняются к Postgres, данные в дашбордах отображаются.

### Вариант Б: через UI

1. Откройте **http://localhost:8080**, зарегистрируйтесь или войдите.
2. Создайте организацию и проект, если Lightdash предложит.
3. На шаге **Select your warehouse** выберите **PostgreSQL**. **Важно:** запросы к складу выполняет сервер Lightdash **из контейнера**, поэтому Host должен быть **`db`** (имя сервиса Postgres в Docker), а не `localhost`. Укажите: **Host: `db`**, Port: `5432`, User: `postgres`, Password — значение `PGPASSWORD` из `.env`, Database: `postgres`, Schema: `main`. SSL mode: `disable`.
4. Добавьте dbt-проект (self-hosted, путь в контейнере `/usr/app/dbt`).
5. Дождитесь синхронизации.

> **Если в браузере «Error loading results», «ECONNREFUSED 127.0.0.1:5432»** — в настройках склада указан localhost. Зайдите в **Project settings** (шестерёнка у проекта) → **Warehouse connection** и измените **Host** на **`db`**, сохраните и обновите страницу.

**Итог шага 8:** в Lightdash отображаются таблицы/модели и метрики из dbt-проекта; дашборды можно собирать перетаскиванием полей; данные из Postgres.

---

## Шаг 9. Настроить MCP в Cursor (Postgres)

Чтобы Cursor видел схему Postgres и мог подсказывать по таблицам:

1. Откройте настройки Cursor: **Cursor → Settings → MCP** (или аналог в вашей версии).
2. Добавьте MCP-сервер для PostgreSQL (если доступен в вашей конфигурации). Пример конфигурации (значения подставьте свои):

   - **Name:** `postgres`
   - **Command / URL** и параметры подключения к вашей БД: host `localhost`, port `5432`, user `postgres`, password из `.env`, database `postgres`, schema `main`.

   Конкретный формат зависит от используемого MCP-сервера для Postgres (например, `npx`-пакет или встроенный коннектор). Укажите те же учётные данные, что в `.env` (PGUSER, PGPASSWORD, PGDATABASE).

3. Сохраните настройки и при необходимости перезапустите Cursor.
4. В чате Cursor можно упоминать базу данных — модель сможет ориентироваться на схему таблиц.

**Результат:** Cursor подключается к Postgres через MCP и «видит» таблицы `main.users`, `main.orders`, `main.products`, `main.events`.

---

## Шаг 10. Настроить MCP в Cursor (Jira)

Чтобы Cursor мог читать задачи из Jira:

1. Создайте бесплатный аккаунт в [Atlassian](https://www.atlassian.com/) и Jira Cloud, если его ещё нет.
2. Создайте в Jira проект и эпик, например «BI Analytics Setup».
3. Создайте задачу (Issue): «Рассчитать Retention Rate и выручку по категориям для маркетингового отчета».
4. В Jira получите API-токен: [Atlassian API tokens](https://id.atlassian.com/manage-profile/security/api-tokens).
5. В Cursor: **Settings → MCP** добавьте Jira MCP-сервер (например, `@modelcontextprotocol/server-jira` или аналог из документации Cursor). Укажите:
   - `JIRA_URL` (например, `https://ваш-домен.atlassian.net`),
   - `JIRA_EMAIL`,
   - `JIRA_API_TOKEN`.
6. Сохраните настройки.

**Результат:** в чате Cursor по упоминанию @Jira можно запрашивать анализ текущей задачи; Cursor будет видеть описание тикета.

---

## Шаг 11. Пройти сценарий кейса

1. В Cursor откройте чат и упомяните @Jira — попросите проанализировать задачу из шага 10. Cursor должен предложить, какие таблицы и поля использовать.
2. При необходимости попросите Cursor создать или доработать staging-модели и витрину (см. [docs/prompts.md](prompts.md)).
3. Добавьте или измените метрики и измерения в `dbt_bi/models/marts/schema.yml` (meta для Lightdash), затем снова выполните `dbt run` и `dbt compile`.
4. В Lightdash обновите проект и соберите один дашборд с метриками (например, Total Revenue, Unique Customers) и нужными срезами. Команды `dbt run` и `dbt compile` выполняйте из каталога `dbt_bi` с активированным виртуальным окружением (шаг 7).

Подробный сценарий и промпты: [docs/scenario.md](scenario.md), [docs/prompts.md](prompts.md).

---

## Частые проблемы

**`zsh: command not found: docker` или `docker compose: command not found`**  
Docker не установлен или не в PATH. Для macOS:
- Установите [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/) и запустите приложение; после запуска команды `docker` и `docker compose` станут доступны в терминале.
- Либо используйте [Orbstack](https://orbstack.dev/) или [Colima](https://github.com/abiosoft/colima) — после установки и старта демона команда `docker compose` будет работать.

После установки проверьте: `docker --version` и `docker compose version`. Новый терминал может понадобиться перезапустить.

**`connect ECONNREFUSED 127.0.0.1:5432`** (на хосте: скрипт, dbt, Lightdash CLI)  
С вашей машины нет доступа к Postgres на порту 5432. Пошаговая проверка (выполняйте из **корня проекта**):

1. **Docker запущен?** Откройте Docker Desktop (или Orbstack/Colima) и убедитесь, что демон работает.
2. **Контейнер `db` поднят и порт проброшен?**
   ```bash
   docker compose ps
   ```
   У сервиса `db` должно быть `Up` и в PORTS — `0.0.0.0:5432->5432/tcp`. Если `db` нет или статус не Up: `docker compose up -d` (без имени сервиса).
3. **Порт 5432 слушается на хосте?**
   ```bash
   nc -z 127.0.0.1 5432 && echo "OK" || echo "Порт недоступен"
   ```
   Должно вывести `OK`. Если «Порт недоступен» — перезапустите стек: `docker compose down && docker compose up -d`, подождите 30 секунд и повторите проверку.
4. **Другой Postgres не занял 5432?** Если на Mac установлен «свой» Postgres и он слушает 5432, остановите его или в `.env` задайте для контейнера другой порт (например `PGPORT=5433`) и пробросьте его в `docker-compose.yml` у сервиса `db` (`"5433:5432"`), тогда с хоста подключайтесь к `localhost:5433` (и в `.env` для скрипта/dbt: `PGPORT=5433`).

В `.env` для запуска с хоста используйте `PGHOST=localhost` (или не задавайте).

**Lightdash в логах: «connect ECONNREFUSED 127.0.0.1:5432»**  
Контейнер Lightdash (внутренняя БД приложения) пытается подключиться к Postgres по localhost. В этом репозитории в `docker-compose.yml` для Lightdash задано `PGHOST: db` — перезапустите: `docker compose down && docker compose up -d`.

**В браузере Lightdash: «Error loading results», «connect ECONNREFUSED 127.0.0.1:5432»**  
Запросы к данным выполняет сервер Lightdash **из контейнера**; подключение к складу (warehouse) берётся из настроек проекта. Если при создании проекта в поле **Host** склада вы указали `localhost`, сервер из контейнера обращается к 127.0.0.1:5432 (сам себе) и не находит Postgres. Исправление: откройте **Project settings** (иконка шестерёнки у проекта) → **Warehouse connection** → измените **Host** на **`db`** (остальное: Port `5432`, User `postgres`, Password из `.env`, Database `postgres`, Schema `main`, SSL mode `disable`). Сохраните и снова откройте дашборд или Explore.

**dbt не подключается к Postgres при `dbt debug` / `dbt run`**  
Убедитесь, что Postgres запущен (`docker compose up -d`), в `.env` заданы `PGPASSWORD`, `PGHOST` (при запуске с хоста — `localhost`). При запуске dbt из каталога `dbt_bi` подхватите переменные из корневого `.env` (`set -a && source ../.env && set +a` на macOS/Linux).

**minio: «exec /init-minio.sh: permission denied»**  
Контейнер MinIO не может выполнить скрипт инициализации. В **корне проекта** выполните: `chmod +x docker/init-minio.sh`, затем перезапустите контейнеры: `docker compose down && docker compose up -d`. После клонирования репозитория на macOS/Linux бит исполнения у `init-minio.sh` может не сохраниться — этот шаг описан в шаге 5 инструкции.

**В `docker compose ps` виден только контейнер `db` (minio и lightdash нет)**  
Запустите все сервисы из **корня проекта** (каталог с `docker-compose.yml`): `docker compose up -d`. Не указывайте имя сервиса — поднимутся `db`, `minio`, `lightdash`. Подождите 1–2 минуты и снова выполните `docker compose ps`. Если minio падает с «permission denied» — см. пункт выше. Для других ошибок: `docker compose logs minio`, `docker compose logs lightdash`. Убедитесь, что `docker/init-minio.sh` исполняемый: `chmod +x docker/init-minio.sh`, затем `docker compose up -d` снова.

**`getaddrinfo ENOTFOUND minio`**  
Имя хоста `minio` существует только внутри Docker-сети. Lightdash обращается к MinIO по имени `minio` — для этого контейнер **minio** должен быть запущен. Выполните `docker compose up -d` из корня проекта и проверьте `docker compose ps`: все три сервиса (db, minio, lightdash) должны быть в состоянии Up. Если minio не поднялся — см. пункт выше.

**Скрипт генерации данных не подключается к Postgres**  
Проверьте, что контейнер `db` запущен (`docker compose ps`) и в `.env` задан `PGPASSWORD`. Скрипт читает `.env` из корня проекта.

**Lightdash CLI: «The server does not support SSL connections»**  
Локальный Postgres в Docker по умолчанию без SSL. В `dbt_bi/profiles.yml` для профиля Postgres добавьте строку `sslmode: disable` (в этом репозитории она уже есть).

**Lightdash не видит dbt-проект**  
Проверьте, что в `.env` задан правильный **абсолютный** путь в `DBT_PROJECT_DIR` и что после изменения `.env` вы перезапустили контейнеры: `docker compose down && docker compose up -d`.

**Порт 8080 занят**  
В `.env` задайте другой порт, например `PORT=8081`, и откройте Lightdash по адресу http://localhost:8081.

**Ошибки при `pip install`**  
Используйте актуальный Python 3.10+ и убедитесь, что виртуальное окружение активировано (`source venv/bin/activate` или аналог для Windows). Все зависимости (включая dbt) ставятся одним командой: `pip install -r scripts/requirements.txt`.

---

## Что дальше

- [Сценарий кейса](scenario.md) — проблема, решение через AI, результат.
- [Промпты для Cursor](prompts.md) — готовые формулировки для dbt и Lightdash.
- [Чек-лист перед записью/статьёй](checklist.md).
- [Настройка экрана для видео](visual_setup.md).
