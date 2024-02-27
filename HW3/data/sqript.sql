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
SELECT job_industry_category, COUNT(*) AS client_count
FROM customer_hw3 cust
GROUP BY job_industry_category
ORDER BY client_count DESC;

--2
SELECT to_char(date_trunc('month', trans.transaction_date::date), 'YYYY-MM') AS month,
       cust.job_industry_category,
       SUM(trans.list_price) AS total_transaction_amount
FROM transaction_hw3 trans
JOIN customer_hw3 cust ON trans.customer_id = cust.customer_id
GROUP BY month, cust.job_industry_category
ORDER BY month, total_transaction_amount;

--3
SELECT brand, COUNT(*) AS online_orders_count
FROM transaction_hw3 trans
WHERE trans.order_status = 'Approved'
  AND trans.online_order = 'True'
  AND trans.customer_id IN (
    SELECT customer_id 
    FROM customer_hw3 cust 
    WHERE job_industry_category = 'IT')
GROUP BY brand
ORDER BY brand DESC;

--4.1
SELECT trans.customer_id,
       SUM(trans.list_price) AS total_transaction_amount,
       MAX(trans.list_price) AS max_transaction_amount,
       MIN(trans.list_price) AS min_transaction_amount,
       COUNT(*) AS transaction_count
FROM transaction_hw3 trans
GROUP BY trans.customer_id
ORDER BY total_transaction_amount DESC, transaction_count DESC;

--4.2
SELECT DISTINCT
       customer_id,
       SUM(list_price) OVER (PARTITION BY customer_id) AS total_transaction_amount,
       MAX(list_price) OVER (PARTITION BY customer_id) AS max_transaction_amount,
       MIN(list_price) OVER (PARTITION BY customer_id) AS min_transaction_amount,
       COUNT(*) OVER (PARTITION BY customer_id) AS transaction_count
FROM transaction_hw3 trans
ORDER BY total_transaction_amount DESC, transaction_count DESC;

--5.1
-- Создаем временную таблицу для хранения сумм транзакций по каждому клиенту
CREATE TEMPORARY TABLE transaction_totals AS
SELECT customer_id, SUM(list_price) AS total_transaction_amount
FROM transaction_hw3 trans
GROUP BY customer_id;
-- Находим клиента с минимальной суммой транзакций
SELECT cust.customer_id,
       cust.first_name, 
       cust.last_name, 
       tratns_total.total_transaction_amount
FROM customer_hw3 cust
JOIN transaction_totals tratns_total ON cust.customer_id = tratns_total.customer_id
WHERE tratns_total.total_transaction_amount = (SELECT MIN(total_transaction_amount) FROM transaction_totals);
--5.2
-- Находим клиента с максимальной суммой транзакций
SELECT cust.customer_id,
       cust.first_name, 
       cust.last_name, 
       tratns_total.total_transaction_amount
FROM customer_hw3 cust
JOIN transaction_totals tratns_total ON cust.customer_id = tratns_total.customer_id
WHERE tratns_total.total_transaction_amount = (SELECT MAX(total_transaction_amount) FROM transaction_totals);
-- Очищаем временную таблицу
DROP TABLE transaction_totals;

--6
SELECT customer_id, transaction_id, transaction_date
FROM (
    SELECT transaction_id, customer_id, transaction_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY transaction_date) AS rn
    FROM transaction_hw3 trans)
WHERE rn = 1;

--7
CREATE TEMPORARY TABLE table_1 AS
  (WITH table_2 AS
    (SELECT  cust.customer_id, cust.first_name, cust.last_name, cust.job_title
	   ,trans.transaction_date::date AS first_transaction_date
	   ,LEAD(trans.transaction_date::date) OVER(PARTITION BY cust.first_name, cust.last_name ORDER BY trans.transaction_date::date) AS second_transaction_date
    FROM transaction_hw3 trans 
    INNER JOIN customer_hw3 cust
    ON trans.customer_id = cust.customer_id)
  SELECT *, MAX(second_transaction_date - first_transaction_date) AS transaction_time_delta
  FROM table_2
  WHERE second_transaction_date - first_transaction_date NOTNULL
  GROUP BY customer_id, first_name, last_name, job_title, first_transaction_date, second_transaction_date
  ORDER BY transaction_time_delta DESC)
SELECT *
FROM table_1
WHERE transaction_time_delta = (SELECT MAX(transaction_time_delta) FROM table_1);
DROP TABLE table_1;
