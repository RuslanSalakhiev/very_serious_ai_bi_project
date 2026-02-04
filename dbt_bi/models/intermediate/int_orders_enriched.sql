{{
  config(
    materialized='view'
  )
}}

with orders as (
  select * from {{ ref('stg_orders') }}
),
users as (
  select * from {{ ref('stg_users') }}
),
products as (
  select * from {{ ref('stg_products') }}
),
promotions as (
  select * from {{ ref('stg_promotions') }}
)

select
  o.order_id,
  o.user_id,
  o.product_id,
  o.quantity,
  o.amount,
  o.order_date,
  extract(year from o.order_date)::int as order_year,
  o.status,
  o.promo_id,
  u.email as user_email,
  u.country as user_country,
  u.created_at as user_created_at,
  p.name as product_name,
  p.category as product_category,
  p.price as product_price,
  pr.code as promo_code,
  pr.discount_pct as promo_discount_pct,
  case
    when pr.discount_pct is not null and o.amount is not null
    then round(o.amount * (1 - pr.discount_pct / 100.0), 2)
    else o.amount
  end as amount_after_promo
from orders o
left join users u on o.user_id = u.user_id
left join products p on o.product_id = p.product_id
left join promotions pr on o.promo_id = pr.promo_id
