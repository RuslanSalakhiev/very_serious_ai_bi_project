# Схема данных

## Сырые таблицы (schema `main`)

### users

| Поле | Тип | Ключ | Описание |
|------|-----|------|----------|
| user_id | int | PK | Идентификатор пользователя |
| email | string | | Email |
| name | string | | Имя |
| country | string | | Страна |
| created_at | timestamp | | Дата регистрации |
| is_active | boolean | | Активен ли пользователь |

### products

| Поле | Тип | Ключ | Описание |
|------|-----|------|----------|
| product_id | int | PK | Идентификатор товара |
| name | string | | Название |
| category | string | | Категория |
| price | decimal | | Цена |

### promotions

| Поле | Тип | Ключ | Описание |
|------|-----|------|----------|
| promo_id | int | PK | Идентификатор промо |
| code | string | | Промокод |
| discount_pct | decimal | | Процент скидки |
| valid_from | date | | Начало действия |
| valid_to | date | | Конец действия |

### orders

| Поле | Тип | Ключ | Описание |
|------|-----|------|----------|
| order_id | int | PK | Идентификатор заказа |
| user_id | int | FK → users | Кто сделал заказ |
| product_id | int | FK → products | Какой товар |
| promo_id | int | FK → promotions | Промокод (опционально) |
| quantity | int | | Количество |
| amount | decimal | | Сумма |
| order_date | date | | Дата заказа |
| status | string | | Статус (completed/pending/cancelled) |

### Связи между таблицами

```
users ─────► orders ◄──────── products
                  │
                  ▼
             promotions
```

| Связь | Описание |
|-------|----------|
| orders → users | Кто сделал заказ |
| orders → products | Какой товар заказан |
| orders → promotions | Применённый промокод (опционально) |
| refunds → orders | К какому заказу относится возврат |

---

## Витрины dbt (после трансформаций)

| Витрина | Назначение | Ключевые поля |
|---------|------------|---------------|
| **fct_orders** | Заказы с пользователем, товаром и промо | order_id, user_id, product_id, amount, amount_after_promo, order_date, order_year, status, user_country, product_category, promo_code |
| **dim_products** | Справочник товаров | product_id, name, category, price, has_price |

---

