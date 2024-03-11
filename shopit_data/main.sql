--create a DBT user
set database_name = 'SHOPIT_ANALYTICS';           -- The database to capture from
set warehouse_name = 'COMPUTE_WH';                -- The warehouse to execute queries in
set dbt_user = 'DBT_USER';                        -- The name of the capture user
set dbt_password = '';               -- The password of the capture user
set dbt_role = 'DBT_ROLE';                -- A role for the capture user's permissions
set dbt_schema = 'ANALYTICS';

--create DBT role
create role if not exists identifier($dbt_role);
grant role identifier($dbt_role) to role SYSADMIN;

-- create a user for DBT
create user if not exists identifier($dbt_user)
password = $dbt_password
default_role = $dbt_role
default_warehouse = $warehouse_name;
grant role identifier($dbt_role) to user identifier($dbt_user);
grant all on schema identifier($dbt_schema) to identifier($dbt_role);
grant select on all tables in schema SHOPIT_ANALYTICS.ANALYTICS to role DBT_ROLE;
grant select on all tables in schema SHOPIT_ANALYTICS.estuary_schema to role DBT_ROLE;

--grant usage for the compute warehous
grant USAGE
on warehouse identifier($warehouse_name)
to role identifier($dbt_role);

--grant permissions for the shopit_analytics database
grant CREATE SCHEMA, MONITOR, USAGE on database identifier($database_name) to role identifier($dbt_role);


--creating an enstuary user
set database_name = 'SHOPIT_ANALYTICS';         -- The database to capture from
set warehouse_name = 'COMPUTE_WH';       -- The warehouse to execute queries in
set estuary_user = 'ESTUARY_USER';       -- The name of the capture user
set estuary_password = '';         -- The password of the capture user
set estuary_role = 'ESTUARY_ROLE';          -- A role for the capture user's permissions
set estuary_schema = 'ESTUARY_SCHEMA';


-- create role for Estuary
create role if not exists identifier($estuary_role);
grant role identifier($estuary_role) to role SYSADMIN;


-- Create snowflake DB
create database if not exists identifier($database_name);
use database identifier($database_name);
create schema if not exists identifier($estuary_schema);


-- create a user for Estuary
create user if not exists identifier($estuary_user)
password = $estuary_password
default_role = $estuary_role
default_warehouse = $warehouse_name;
grant role identifier($estuary_role) to user identifier($estuary_user);
grant all on schema identifier($estuary_schema) to identifier($estuary_role);


-- create a warehouse for estuary
create warehouse if not exists identifier($warehouse_name)
warehouse_size = xsmall
warehouse_type = standard
auto_suspend = 60
auto_resume = true
initially_suspended = true;


-- grant Estuary role access to warehouse
grant USAGE
on warehouse identifier($warehouse_name)
to role identifier($estuary_role);


-- grant Estuary access to database
grant CREATE SCHEMA, MONITOR, USAGE on database identifier($database_name) to role identifier($estuary_role);


-- change role to ACCOUNTADMIN for STORAGE INTEGRATION support to Estuary (only needed for Snowflake on GCP)
use role ACCOUNTADMIN;
grant CREATE INTEGRATION on account to role identifier($estuary_role);
use role sysadmin;
COMMIT;


--create a reporter role and preset user
USE ROLE ACCOUNTADMIN;
CREATE ROLE IF NOT EXISTS REPORTER;
CREATE USER IF NOT EXISTS PRESET
 PASSWORD=''
 LOGIN_NAME='preset'
 MUST_CHANGE_PASSWORD=FALSE
 DEFAULT_WAREHOUSE='COMPUTE_WH'
 DEFAULT_ROLE='REPORTER'
 DEFAULT_NAMESPACE='SHOPIT_ANALYTICS.ANALYTICS'
 COMMENT='Preset user for creating reports';
GRANT ROLE REPORTER TO USER PRESET;
GRANT ROLE REPORTER TO ROLE ACCOUNTADMIN;
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE REPORTER;
GRANT USAGE ON DATABASE SHOPIT_ANALYTICS TO ROLE REPORTER;
GRANT USAGE ON SCHEMA SHOPIT_ANALYTICS.ANALYTICS TO ROLE REPORTER;
GRANT ALL ON SCHEMA ANALYTICS TO ROLE REPORTER;
grant select on all tables in schema SHOPIT_ANALYTICS.ANALYTICS to role reporter;
grant select on all tables in schema SHOPIT_ANALYTICS.estuary_schema to role reporter;





