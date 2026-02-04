{{
  config(
    materialized='table'
  )
}}

with events as (
  select * from {{ ref('stg_events') }}
),
users as (
  select * from {{ ref('stg_users') }}
)

select
  e.event_id,
  e.user_id,
  e.event_type,
  e.event_at,
  extract(year from e.event_at)::int as event_year,
  extract(month from e.event_at)::int as event_month,
  e.page,
  u.email as user_email,
  u.country as user_country
from events e
left join users u on e.user_id = u.user_id
where e.event_at is not null
