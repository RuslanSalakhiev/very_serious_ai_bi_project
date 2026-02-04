{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('main', 'refunds') }}
),

cleaned as (
  select
    refund_id,
    order_id,
    amount,
    nullif(trim(refund_date), '') as refund_date_raw,
    nullif(trim(reason), '') as reason
  from source
  where refund_id is not null
),

with_ts as (
  select
    refund_id,
    order_id,
    amount,
    {{ parse_date_raw('refund_date_raw') }} as refund_date,
    reason
  from cleaned
)

select refund_id, order_id, amount, refund_date, reason from with_ts
