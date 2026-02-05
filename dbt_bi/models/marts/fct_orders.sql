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
),
products as (
  select * from {{ source('main', 'products') }}
),
promotions as (
  select * from {{ source('main', 'promotions') }}
),

joined as (
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
    p.name as product_name,
    p.category as product_category,
    p.price as product_price,
    pr.code as promo_code,
    pr.discount_pct as promo_discount_pct
  from orders o
  left join users u on o.user_id = u.user_id
  left join products p on o.product_id = p.product_id
  left join promotions pr on o.promo_id = pr.promo_id
),

final as (
  select
    order_id,
    user_id,
    product_id,
    quantity,
    amount,
    case
      when promo_discount_pct is not null and amount is not null
      then round(amount * (1 - promo_discount_pct / 100.0), 2)
      else amount
    end as amount_after_promo,
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
  from joined
)

select * from final
