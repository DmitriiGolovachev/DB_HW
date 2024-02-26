CREATE DATABASE postgres_hw3;

CREATE TABLE customer_hw3 (	
	customer_id int4 PRIMARY KEY
	,first_name varchar(50)
	,last_name varchar(50)
	,gender varchar(30)
	,dob varchar(50)
	,job_title varchar(50)
	,job_industry_category varchar(50)
	,wealth_segment varchar(50)
	,deceased_indicator varchar(50)
	,owns_car varchar(30)
	,address varchar(50)
	,postcode varchar(30)
	,state varchar(30)
	,country varchar(30)
	,property_valuation int4
);

CREATE TABLE transaction_hw3 (
	transaction_id int4 PRIMARY KEY
	,product_id int4
	,customer_id int4
	,transaction_date varchar(30)
	,online_order varchar(30)
	,order_status varchar(30)
	,brand varchar(30)
	,product_line varchar(30)
	,product_class varchar(30)
	,product_size varchar(30)
	,list_price float4
	,standard_cost float4
	,FOREIGN key (customer_id) references customer_hw3 (customer_id) 
);

--1
select  job_industry_category, count(*) as number_of_customers
from customer_hw3 cust 
group by job_industry_category 
order by number_of_customers desc;

--2
select to_char(date_trunc('month', trans.transaction_date::date), 'YYYY-MM') as transaction_month
,cust.job_industry_category
,sum(trans.list_price) as transaction_sum
from transaction_hw3 trans
inner join customer_hw3 cust
on trans.customer_id = cust.customer_id 
group by cust.job_industry_category , transaction_month
order by transaction_month, cust.job_industry_category;

--3
select trans.brand , count(*)
from transaction_hw3 trans
inner join customer_hw3 cust
on trans.customer_id = cust.customer_id
where cust.job_industry_category = 'IT' 
  and trans.online_order = 'True' 
  and trans.order_status = 'Approved'
group by trans.brand 
order by trans.brand desc;

--4.1
select customer_id
  ,sum(list_price) as sum_of_transactions
  ,max(list_price) as max_of_transactions
  ,min(list_price) as min_of_transactions
  ,count(transaction_id) as number_of_transactions
from transaction_hw3 trans
group by customer_id
order by sum_of_transactions desc, number_of_transactions desc;

--4.2
select distinct customer_id
  ,sum(list_price) over(partition by customer_id) as sum_of_transactions
  ,max(list_price) over(partition by customer_id) as max_of_transactions
  ,min(list_price) over(partition by customer_id) as min_of_transactions
  ,count(transaction_id) over(partition by customer_id) as number_of_transactions
from transaction_hw3 trans
order by sum_of_transactions desc, number_of_transactions desc;

--5.1
with grouped_table as
(select cust.customer_id, cust.first_name , cust.last_name , sum(trans.list_price) as sum_of_transactions
from transaction_hw3 trans 
inner join customer_hw3 cust
on trans.customer_id = cust.customer_id 
group by cust.customer_id, cust.first_name , cust.last_name)
select *
from grouped_table
where sum_of_transactions = (select min(sum_of_transactions) from grouped_table);

--5.2
with grouped_table as
(select cust.customer_id, cust.first_name , cust.last_name , sum(trans.list_price) as sum_of_transactions
from transaction_hw3 trans
inner join customer_hw3 cust
on trans.customer_id = cust.customer_id 
group by cust.customer_id, cust.first_name , cust.last_name)
select *
from grouped_table
where sum_of_transactions = (select max(sum_of_transactions) from grouped_table);

--6
select customer_id, transaction_date, transaction_id
from (select transaction_id, transaction_date, customer_id,
      RANK() over(partition by customer_id order by transaction_date) as rank
      from transaction_hw3 trans)
where rank=1;

--7
with grouped_table as 
  (with window_table as
    (select  cust.customer_id, cust.first_name, cust.last_name, cust.job_title
	   ,trans.transaction_date::date as first_transaction_date
	   ,lead(trans.transaction_date::date) over(partition by cust.first_name, cust.last_name order by trans.transaction_date::date) as second_transaction_date
    from transaction_hw3 trans 
    inner join customer_hw3 cust
    on trans.customer_id = cust.customer_id)
select *, max(second_transaction_date - first_transaction_date) as transaction_time_delta
from window_table
where second_transaction_date - first_transaction_date notnull
group by customer_id, first_name, last_name, job_title, first_transaction_date, second_transaction_date
order by transaction_time_delta desc)
select *
from grouped_table
where transaction_time_delta = (select max(transaction_time_delta) from grouped_table);