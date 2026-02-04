{{
  config(
    materialized='table'
  )
}}

with int_orders as (
  select * from {{ ref('int_orders_enriched') }}
)

select
  order_id,
  user_id,
  product_id,
  quantity,
  amount,
  amount_after_promo,
  order_date,
  order_year,
  status,
  promo_id,
  user_email,
  user_country,
  product_name,
  product_category,
  product_price,
  promo_code,
  promo_discount_pct
from int_orders
