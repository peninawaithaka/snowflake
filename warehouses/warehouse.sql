use role accountadmin

--creating warehouses in snowflake
create warehouse compute_warehouse
with
warehouse_size = xsmall
--max_cluster_count = 3 --allows for multi-clustering incases of queued queries
auto_suspend = 200
auto_resume = true
comment = 'this is virtual warehouse of size x-small that can be used to process queries'

-- deleting warehouses
drop warehouse compute_warehouse