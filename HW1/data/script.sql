CREATE TABLE product (
  id int4 PRIMARY KEY
  ,product_id int4 not null
  ,brand varchar(30)
  ,product_line varchar(30)
  ,product_class varchar(10)
  ,product_size varchar(10)
  ,list_price float4
  ,standard_cost float4
);

CREATE TABLE customer (
  customer_id int8 PRIMARY KEY
  ,first_name varchar(30) not null
  ,last_name varchar(30) not null
  ,gender varchar(10)
  ,DOB date
  ,job_title varchar(50)
  ,job_industry_category varchar(50)
  ,wealth_segment varchar(30)
  ,deceased_indicator varchar(10)
  ,owns_car varchar(10)
);

CREATE TABLE address (
  address_id int4 PRIMARY KEY
  ,postcode int4
  ,state varchar(30)
  ,country varchar(30)
  ,property_valuation int4
  ,house_number int4
  ,street text
);

CREATE TABLE transaction (
  transaction_id int4 PRIMARY KEY
  ,product_id int4 not null
  ,customer_id int8 not null
  ,transaction_date date 
  ,online_order bool
  ,order_status varchar(30)
  ,list_price float4
  ,standard_cost float4
  ,address_id int4 not null
  ,FOREIGN key (product_id) references product (id)
  ,FOREIGN key (address_id) references address (address_id)
  ,FOREIGN key (customer_id) references customer (customer_id)
);
