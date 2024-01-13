--create custom roles
-- Analyst: can use the compute_warehouse, usage on shopit.public 

--Analyst>>accountadmin

use role accountadmin;

create role Analyst;

--verify is there is any privilege associated with the role
show grants to role Analyst;

--Grant role to my user
grant role analyst to user Lavendaire;
grant usage on warehouse compute_wh to role Analyst;
grant usage on schema SHOPIT.PUBLIC to role Analyst;
grant select on all tables in schema SHOPIT.PUBLIC to role Analyst;

use role Analyst;

select * from shopit.public.customers