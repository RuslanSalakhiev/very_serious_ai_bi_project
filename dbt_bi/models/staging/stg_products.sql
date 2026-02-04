{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('main', 'products') }}
),

cleaned as (
  select
    product_id,
    nullif(trim(name), '') as name,
    nullif(trim(category), '') as category,
    price
  from source
  where product_id is not null
),

deduped as (
  select *
  from (
    select *, row_number() over (partition by product_id order by product_id) as rn
    from cleaned
  ) t
  where rn = 1
)

select product_id, name, category, price from deduped
