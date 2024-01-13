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


--creating a database and a table
create database shopit
create table if not exists customers(
    id int,
    first_name varchar,
    last_name varchar,
    email varchar,
    age int,
    city varchar
)

-- loading data from s3 - public bucket
copy into customers
from s3://snowflake-assignments-mc/gettingstarted/customers.csv
file_format = (
    type = csv,
    field_delimiter = ',',
    skip_header=1
);
