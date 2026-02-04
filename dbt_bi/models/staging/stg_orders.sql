{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('main', 'orders') }}
),

cleaned as (
  select
    order_id,
    user_id,
    product_id,
    quantity,
    amount,
    nullif(trim(order_date), '') as order_date_raw,
    nullif(trim(status), '') as status,
    promo_id
  from source
  where order_id is not null
),

numbered as (
  select
    *,
    row_number() over (partition by order_id order by order_id) as rn
  from cleaned
),

deduped as (
  select * from numbered where rn = 1
),

with_ts as (
  select
    order_id,
    user_id,
    product_id,
    quantity,
    amount,
    {{ parse_date_raw('order_date_raw') }} as order_date,
    status,
    promo_id
  from deduped
)

select order_id, user_id, product_id, quantity, amount, order_date, status, promo_id from with_ts
