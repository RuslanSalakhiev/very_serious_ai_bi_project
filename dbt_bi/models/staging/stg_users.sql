{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('main', 'users') }}
),

cleaned as (
  select
    user_id,
    nullif(trim(email), '') as email,
    nullif(trim(name), '') as name,
    nullif(trim(country), '') as country,
    nullif(trim(created_at), '') as created_at_raw,
    lower(trim(is_active)) in ('true', '1', 'yes') as is_active
  from source
  where user_id is not null
),

numbered as (
  select
    *,
    row_number() over (partition by user_id order by user_id) as rn
  from cleaned
),

deduped as (
  select * from numbered where rn = 1
),

with_ts as (
  select
    user_id,
    email,
    name,
    country,
    case
      when created_at_raw is not null and created_at_raw ~ '^\d{4}-\d{2}-\d{2}'
      then created_at_raw::timestamp
      else null
    end as created_at,
    is_active
  from deduped
)

select user_id, email, name, country, created_at, is_active from with_ts
