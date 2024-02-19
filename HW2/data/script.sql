-- create table
CREATE DATABASE postgres_hw2;

CREATE TABLE customer_hw2 (	
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

CREATE TABLE transaction_hw2 (
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
	,FOREIGN key (customer_id) references customer_hw2 (customer_id) 
);

-- 1
select  distinct  brand
from transaction_hw2
where standard_cost  > 1500;

-- 2
select transaction_id, transaction_date, order_status
from transaction_hw2
where order_status = 'Approved' and 
	transaction_date::date between '2017-04-01' and '2017-04-09'
order by transaction_date;

--3
select  distinct  job_title 
from customer_hw2
where job_industry_category in ('IT', 'Financial Services') and 
	job_title  like 'Senior%';

--4
select distinct brand
from transaction_hw2
where customer_id in
	(select customer_id
	 from customer_hw2
	 where job_industry_category = 'Financial Services'
	);
	
--5
select customer_id, first_name, last_name
from customer_hw2
where customer_id in
	(select distinct customer_id
	 from transaction_hw2
	 where brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles') and
	 online_order = 'True')
limit 10;

--6
select ch.customer_id, ch.first_name, ch.last_name, th.transaction_id 
from customer_hw2 ch
left join transaction_hw2 th
on ch.customer_id = th.customer_id 
where th.customer_id is null

--7
select ch.customer_id, ch.first_name, ch.last_name, max(th.standard_cost)
from customer_hw2 ch
inner join transaction_hw2 th 
on ch.customer_id = th.customer_id 
where job_industry_category = 'IT' and
	th.standard_cost = (select max(standard_cost) 
						from transaction_hw2 th)
group by ch.customer_id;

--8
select distinct ch.customer_id, ch.first_name, ch.last_name
from customer_hw2 ch 
inner join transaction_hw2 th
on ch.customer_id = th.customer_id 
where th.transaction_date::date between '2017-07-07' and '2017-07-17' and 
	th.order_status = 'Approved' and 
	ch.job_industry_category in ('IT', 'Health');