-- Run after schema.sql to verify the required tables exist.
select table_name
from information_schema.tables
where table_schema='public'
  and table_name in ('addresses','cart_items','categories','customers','favorites','notifications','order_items','orders','product_images','products','search_history','suppliers','offers','admin_roles')
order by table_name;
