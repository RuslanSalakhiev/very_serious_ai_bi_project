# Дашборды Lightdash

Краткие инструкции по дашбордам в Lightdash.

---

## Дашборд «Sales Analysis» (анализ продаж)

**Файлы (Dashboards as Code):**
- `dbt_bi/lightdash/charts/sales-by-country-year.yml` — продажи по странам и годам
- `dbt_bi/lightdash/charts/sales-analysis-revenue-by-month.yml` — выручка по месяцам
- `dbt_bi/lightdash/charts/sales-analysis-by-country.yml` — выручка по странам
- `dbt_bi/lightdash/dashboards/sales-analysis-dashboard.yml` — дашборд с тремя чартами

**Загрузка:** из корня проекта `lightdash upload -p dbt_bi/lightdash --force`. Затем в Lightdash откройте дашборд **Sales Analysis**.

---

## Дашборд: продажи по странам и годам (отдельный)

## Вариант A: Dashboards as Code (YAML)

Дашборд и чарт уже описаны в коде и загружаются через Lightdash CLI.

**Файлы:**
- `dbt_bi/lightdash/charts/sales-by-country-year.yml` — чарт (страна, год, выручка)
- `dbt_bi/lightdash/dashboards/sales-by-country-year-dashboard.yml` — дашборд с этим чартом

**Загрузка в Lightdash:**

1. Убедитесь, что dbt-модели и проект Lightdash синхронизированы (`dbt run`, `dbt compile`, Sync в Lightdash).
2. Из корня проекта (или из `dbt_bi`) выполните:
   ```bash
   lightdash login http://localhost:8080 --token ВАШ_ТОКЕН
   lightdash config set-project   # выберите ваш проект
   lightdash upload -p dbt_bi/lightdash --force
   ```
   Или загрузить только этот контент:
   ```bash
   lightdash upload -c sales-by-country-year -d sales-by-country-year-dashboard -p dbt_bi/lightdash --include-charts --force
   ```
3. Откройте http://localhost:8080 → дашборд **Sales by country and year**.

Если в проекте ещё нет space с slug `main`, создайте его в UI или после первой загрузки перенесите дашборд в нужный space. Метрика **Total Revenue** задана в dbt на колонке `amount` (type: sum) по [рекомендации Lightdash](https://docs.lightdash.com/references/metrics) — тогда field id в чарте будет `fct_orders_total_revenue`. После изменений в dbt выполните **Project settings → Sync** в Lightdash, затем снова `lightdash upload`. Если ошибки про fieldId остаются — выполните `lightdash download -p dbt_bi/lightdash` и сверьте имена полей в скачанных YAML.

---

## Вариант B: Сборка в UI

## Подготовка (один раз)

1. В корне проекта с активированным `venv` выполните из каталога `dbt_bi`:
   ```bash
   cd dbt_bi
   set -a && source ../.env && set +a   # macOS/Linux
   dbt run
   dbt compile
   ```
2. В Lightdash (http://localhost:8080) обновите проект: **Project settings** → **Sync** (или дождитесь автосинхронизации).

## Сборка дашборда в Lightdash

1. Откройте **http://localhost:8080** и войдите в проект.
2. Перейдите в **Explore** и выберите модель **fct_orders**.
3. Добавьте:
   - **Метрику:** **Total Revenue** (перетащите или отметьте галочкой).
   - **Измерения для группировки:** **User country** и **Order year**.
4. В таблице/графике будут строки: страна × год, значение — сумма продаж. При необходимости смените визуализацию на **Bar chart** или **Table**.
5. Сохраните как дашборд: кнопка **Save** → **Save to dashboard** → создайте новый дашборд (например, «Sales by country and year») или выберите существующий.

Готово: дашборд с распределением продаж по странам и по годам.
