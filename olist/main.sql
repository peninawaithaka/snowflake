CREATE STORAGE INTEGRATION olist_datasets_1
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = ''
  STORAGE_ALLOWED_LOCATIONS = ('s3://olistdataset/')
 -- [ STORAGE_BLOCKED_LOCATIONS = ('s3://<bucket>/<path>/', 's3://<bucket>/<path>/') ]

 DESC INTEGRATION olist_datasets_1;

GRANT CREATE STAGE ON SCHEMA raw TO ROLE accountadmin;

GRANT USAGE ON INTEGRATION olist_dataset TO ROLE accountadmin;


USE SCHEMA olist.raw;

CREATE STAGE raw_olist
  STORAGE_INTEGRATION = olist_datasets_1
  URL = 's3://olistdataset/'
  --FILE_FORMAT = csv;

create or replace table raw_customers_dataset(
    customer_id	varchar,
    customer_unique_id varchar,
    customer_zip_code_prefix varchar,
    customer_city string,
    customer_state string
);

copy into raw_customers_dataset(
    customer_id	,
    customer_unique_id ,
    customer_zip_code_prefix ,
    customer_city ,
    customer_state 
)
from s3://olistdataset/olist_customers_dataset.csv credentials=()
FILE_FORMAT = (type = 'CSV' skip_header = 1);

create or replace table raw_geolocation_dataset(
    geolocation_zip_code_prefix	varchar,
    geolocation_lat varchar,
    geolocation_lng varchar,
    geolocation_city string,
    geolocation_state string
);

copy into raw_geolocation_dataset(
    geolocation_zip_code_prefix	,
    geolocation_lat ,
    geolocation_lng ,
    geolocation_city ,
    geolocation_state 
)
from s3://olistdataset/olist_geolocation_dataset.csv credentials=()
FILE_FORMAT = (type = 'CSV' skip_header = 1);

create or replace table raw_order_items_dataset(
    order_id varchar,
    order_item_id varchar,
    product_id varchar,
    seller_id string,
    shipping_limit_date string,
    price float,
    freight_value float
);

copy into raw_order_items_dataset(
    order_id ,
    order_item_id ,
    product_id ,
    seller_id ,
    shipping_limit_date ,
    price ,
    freight_value
)
from s3://olistdataset/olist_order_items_dataset.csv credentials=()
FILE_FORMAT = (type = 'CSV' skip_header = 1);


create or replace table raw_order_payments_dataset(
    order_id varchar,
    payment_sequential integer,
    payment_type string,
    payment_installments integer,
    payment_value float
);

copy into raw_order_payments_dataset(
    order_id ,
    payment_sequential ,
    payment_type ,
    payment_installments ,
    payment_value 
)
from s3://olistdataset/olist_order_payments_dataset.csv credentials=()
FILE_FORMAT = (type = 'CSV' skip_header = 1);


create or replace table raw_order_reviews_dataset(
    review_id varchar,
    order_id varchar,
    review_score integer,
    review_comment_title string,
    review_comment_message string,
    review_answer_timestamp string
);

copy into raw_order_reviews_dataset(
    review_id ,
    order_id ,
    review_score ,
    review_comment_title ,
    review_comment_message ,
    review_answer_timestamp 
)
from s3://olistdataset/olist_order_reviews_dataset.csv credentials=()
FILE_FORMAT = (type = 'CSV' skip_header = 1 )
on_error = 'continue';


create or replace table raw_orders_dataset(
    order_id varchar,
    customer_id varchar,
    order_status string,
    order_purchase_timestamp string,
    order_approved_at string,
    order_delivered_carrier_date string,
    order_delivered_customer_date string,
    order_estimated_delivery_date string
);

copy into raw_orders_dataset(
    order_id ,
    customer_id ,
    order_status ,
    order_purchase_timestamp ,
    order_approved_at ,
    order_delivered_carrier_date ,
    order_delivered_customer_date ,
    order_estimated_delivery_date 
)
from s3://olistdataset/olist_orders_dataset.csv credentials=()
FILE_FORMAT = (type = 'CSV' skip_header = 1 )
on_error = 'continue';

create or replace table raw_products_dataset(
    product_id varchar,
    product_category_name varchar,
    product_name_lenght integer,
    product_description_lenght integer,
    product_photos_qty integer,
    product_weight_g integer,
    product_length_cm integer,
    product_height_cm integer,
    product_width_cm integer
);

copy into raw_products_dataset(
    product_id ,
    product_category_name ,
    product_name_lenght ,
    product_description_lenght ,
    product_photos_qty ,
    product_weight_g ,
    product_length_cm ,
    product_height_cm ,
    product_width_cm 
)
from s3://olistdataset/olist_products_dataset.csv credentials=()
FILE_FORMAT = (type = 'CSV' skip_header = 1 )
on_error = 'continue';

create or replace table raw_sellers_dataset(
    seller_id varchar,
    seller_zip_code_prefix varchar,
    seller_city string,
    seller_state string
);

copy into raw_sellers_dataset(
   seller_id ,
    seller_zip_code_prefix ,
    seller_city ,
    seller_state 
)
from s3://olistdataset/olist_sellers_dataset.csv credentials=()
FILE_FORMAT = (type = 'CSV' skip_header = 1 )
on_error = 'continue';


select 
    replace(customer_id, '"', ''),
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
from raw_customers_dataset
where customer_id is not null and customer_unique_id is not null
group by customer_id



USE ROLE ACCOUNTADMIN;

-- Create the `transform` role
CREATE ROLE IF NOT EXISTS transform;
GRANT ROLE TRANSFORM TO ROLE ACCOUNTADMIN;

-- Create the default warehouse if necessary
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;

-- Create the `dbt` user and assign to role
CREATE USER IF NOT EXISTS olistdbt
  PASSWORD=''
  LOGIN_NAME='olistdbt'
  MUST_CHANGE_PASSWORD=FALSE
  DEFAULT_WAREHOUSE='COMPUTE_WH'
  DEFAULT_ROLE='transform'
  DEFAULT_NAMESPACE='OLIST.RAW'
  COMMENT='DBT user used for data transformation';
GRANT ROLE transform to USER olistdbt;










