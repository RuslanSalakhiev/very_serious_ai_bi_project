{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('main', 'orders') }}
)

select
  order_id,
  user_id,
  product_id,
  quantity,
  amount,
  nullif(trim(order_date), '') as order_date,
  nullif(trim(status), '') as status,
  promo_id
from source
where order_id is not null
