{% macro parse_date_raw(column_name) %}
  {#
    Parse dirty varchar date into timestamp.
    Accepts: YYYY-MM-DD, YYYY-MM-DDTHH:MI:SS, YYYY-MM-DD HH:MI:SS, empty -> null.
  #}
  case
    when nullif(trim({{ column_name }}), '') is null then null
    when nullif(trim({{ column_name }}), '') ~ '^\d{4}-\d{2}-\d{2}' then nullif(trim({{ column_name }}), '')::timestamp
    else null
  end
{% endmacro %}
