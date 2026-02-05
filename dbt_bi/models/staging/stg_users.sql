{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('main', 'users') }}
)

select
  user_id,
  nullif(trim(email), '') as email,
  nullif(trim(name), '') as name,
  nullif(trim(country), '') as country,
  nullif(trim(created_at), '') as created_at,
  is_active
from source
where user_id is not null
