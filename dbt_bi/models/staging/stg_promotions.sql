{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('main', 'promotions') }}
),

cleaned as (
  select
    promo_id,
    nullif(trim(code), '') as code,
    discount_pct,
    nullif(trim(valid_from), '') as valid_from_raw,
    nullif(trim(valid_to), '') as valid_to_raw
  from source
  where promo_id is not null
),

with_ts as (
  select
    promo_id,
    code,
    discount_pct,
    {{ parse_date_raw('valid_from_raw') }} as valid_from,
    {{ parse_date_raw('valid_to_raw') }} as valid_to
  from cleaned
)

select promo_id, code, discount_pct, valid_from, valid_to from with_ts
