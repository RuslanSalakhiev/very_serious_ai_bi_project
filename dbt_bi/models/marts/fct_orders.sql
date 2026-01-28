{{
  config(
    materialized='table'
  )
}}

with orders as (
  select * from {{ ref('stg_orders') }}
),
users as (
  select * from {{ ref('stg_users') }}
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
  u.email as user_email,
  u.country as user_country
from orders o
left join users u on o.user_id = u.user_id
