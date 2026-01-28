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
    nullif(trim(status), '') as status
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
    case
      when order_date_raw is not null and order_date_raw ~ '^\d{4}-\d{2}-\d{2}'
      then order_date_raw::timestamp
      else null
    end as order_date,
    status
  from deduped
)

select order_id, user_id, product_id, quantity, amount, order_date, status from with_ts
