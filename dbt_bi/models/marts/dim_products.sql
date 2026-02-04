{{
  config(
    materialized='table'
  )
}}

with products as (
  select * from {{ ref('stg_products') }}
),

with_category_clean as (
  select
    product_id,
    name,
    coalesce(nullif(trim(category), ''), 'Uncategorized') as category,
    price
  from products
  where product_id is not null
)

select
  product_id,
  name,
  category,
  price,
  case when price is not null and price > 0 then 'Yes' else 'No' end as has_price
from with_category_clean
