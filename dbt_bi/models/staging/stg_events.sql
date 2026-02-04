{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('main', 'events') }}
),

cleaned as (
  select
    event_id,
    user_id,
    nullif(trim(event_type), '') as event_type,
    nullif(trim(event_at), '') as event_at_raw,
    nullif(trim(page), '') as page
  from source
  where event_id is not null
),

with_ts as (
  select
    event_id,
    user_id,
    event_type,
    {{ parse_date_raw('event_at_raw') }} as event_at,
    page
  from cleaned
)

select event_id, user_id, event_type, event_at, page from with_ts
