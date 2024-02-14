// Use DBML to define your database structure
// Docs: https://dbml.dbdiagram.io/docs

Table product {
  product_table_id integer [primary key]
  product_id integer
  brand varchar
  product_line varchar
  product_class varchar
  product_size varchar
  list_price float
  standard_cost float
}

Table customer {
  customer_id integer [primary key]
  first_name varchar
  last_name varchar
  gender varchar
  DOB varchar
  job_title varchar
  job_industry_category varchar
  wealth_segment varchar
  deceased_indicator varchar
  owns_car varchar
}

Table address {
  address_id integer [primary key]
  postcode integer
  state varchar
  country varchar
  property_valuation integer
  house_number integer
  street varchar
}

Table transaction {
  transaction_id integer [primary key]
  product_id integer
  customer_id integer
  transaction_date varchar
  online_order varchar
  order_status varchar
  list_price float
  standard_cost float
  address_id integer
}

Ref: transaction.product_id > product.product_table_id

Ref: transaction.address_id > address.address_id

Ref: transaction.customer_id > customer.customer_id