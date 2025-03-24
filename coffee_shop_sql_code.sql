create database databrew;           
use databrew;
show tables;

SET SQL_SAFE_UPDATES = 0

DELETE FROM customer
WHERE customer_id IS NULL;

select count(*) from customer
where birthdate is null;

#updating gender column
update customer 
set gender="O" where gender="N";

#checking for unique data 
select customer_id,
row_number()over(partition by customer_id order by customer_id)as rn
from customer;

#checking for datatype of columns
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'customer';

#updating column datatype
alter table customer
modify column customer_since date,
modify column birthdate date,
modify column loyalty_card_number int;


#DATES TABLE
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'dates';
    
    
#updating column datatype
alter table dates
modify column Date_Id date,
modify column transaction_date date;

#creating temporary column
alter table dates
add column transaction_data_temp date;

update dates
set transaction_data_temp=str_to_date(transaction_date,'%m/%d/%Y');

alter table dates
drop transaction_date;

alter table dates
change column transaction_data_temp transaction_date date;

select * from dates
limit 5;

show tables;
select * from generations;

alter table generations
drop birth_year_temp;

#CHECKING FOR DATATYPE
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'pastry_inventory';
    
ALTER TABLE pastry_inventory
CHANGE COLUMN `% waste` per_waste DECIMAL(5,2);

select*from pastry_inventory;

#CREATING TEMPORARY COLUMN
alter table pastry_inventory
add column transaction_data_temp date;

update pastry_inventory
set transaction_data_temp=str_to_date(transaction_date,'%m/%d/%Y');

alter table pastry_inventory
drop transaction_date;

alter table pastry_inventory
CHANGE column transaction_data_temp transaction_date date;

select * from product
limit 5;

#CHECKING FOR DATATYPE
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'product';
    
update product
set current_retail_price=replace(current_retail_price,"$"," ");

alter table product
modify column current_retail_price decimal(5,2);

alter table product 
add column profit decimal(5,2);

update product
set profit=current_retail_price - current_wholesale_price;

SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'sales_targets';
    
alter table sales_targets
modify column year_month date;

#CREATING TEMPORARY COLUMN
alter table sales_targets
add column year_month_temp date;

UPDATE sales_targets
SET year_month_temp = STR_TO_DATE(year_month, '%m/%d/%Y');


alter table sales_targets
drop year_month_temp;

select* from staff;



#CHECKING FOR THE DATATYPE 
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'staff';

#ADDING A NEW COLUMN AND UPDATING THE EXISTING VALUES INTO THE NEW COLUMN
alter table staff
add column staff_name varchar(50);
update staff
set staff_name=concat(first_name," ", last_name);

#DROPING COLUMNS
alter table staff
drop first_name,
drop last_name,
drop column `MyUnknownColumn_[0]`;

#CREATING TEMPORARY COLUMN
alter table staff
add column start_date_temp date;

update staff
set start_date_temp=str_to_date(start_date,'%m/%d/%Y');

alter table staff
drop start_date;

alter table staff
CHANGE column start_date_temp start_date date;

select * from sales_outlet;
#CHECKING FOR THE DATATYPE 
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'sales_outlet';
    
#DELETING COLUMNS
alter table sales_outlet
drop column neighorhood,
drop column store_latitude,
drop column store_longitude;

alter table sales_outlet
drop column store_postal_code;

#CHANGING DATATYPE
alter table sales_outlet
modify column manager int;

select*from sales_reciepts;
#CHECKING FOR THE DATATYPE 
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'sales_reciepts';
    
alter table sales_reciepts
modify column transaction_time time;

alter table sales_reciepts
drop line_item_amount,
drop line_item_id;

alter table sales_reciepts
modify column transaction_date date;

#SALES TREND
#What are the total monthly sales for Data Brew over the past year? 

#VIEWING THE TABLE
select * from sales_reciepts;

#ADDING A NEW COLUMN IN THE TABLE
alter table sales_reciepts
add column total_sales_$ double(5,2);

#UPDATING THE VALUES IN THE COLUMN
update sales_reciepts
set total_sales_$= unit_price*quantity;

select transaction_date, sum(total_sales_$) as daily_sales
from sales_reciepts
where transaction_date between "2019-04-01" and "2019-04-30"
group by transaction_date
order by transaction_date;

select transaction_date from sales_reciepts
order by transaction_date desc;

select distinct(transaction_date) from sales_reciepts;

select transaction_date,sum(line_item_amount)as daily_sales
from 201904sales
where transaction_date between "2019-04-01" and "2019-04-30"
group by transaction_date
order by transaction_date desc;


select transaction_date from 201904sales
order by transaction_date desc;

SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = '201904sales';

#On which day does Data Brew experience peak sales in April 2019? 
select extract(day from transaction_date)as day,sum(line_item_amount)as daily_sales
from 201904sales
where transaction_date between "2019-04-01" and "2019-04-30"
group by day
order by daily_sales desc;

# What are the peak sales hours during the day for Data Brew in April 2019? 
select transaction_time, sum(line_item_amount)as hourly_sales_$ from 201904sales
group by transaction_time
order by hourly_sales_$ desc;

# Are there any notable variations in sales on different days of the week in April 2019? 
select dayname(transaction_date) as weekday,
sum(line_item_amount)as daily_sales
from 201904sales
where transaction_date between "2019-04-01" and "2019-04-30"
group by weekday
order by field(weekday,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') ;

# How do sales trends compare between different store locations in April 2019? 
select s.sales_outlet_id,
sum(line_item_amount) as sales,
o.store_address,
o.store_city
from 201904sales as s
join sales_outlet o
on s.sales_outlet_id=o.sales_outlet_id
group by
s.sales_outlet_id, 
    o.store_address, 
    o.store_city
order by sales desc;

# CUSTOMER SEGMENTATION
# Who are the top 10 customers based on total spending at Data Brew? 
SELECt s.customer_id,
c.customer_name,
sum(line_item_amount)as sales
from 201904sales s
join customer c
on s.customer_id=c.customer_id
group  by s.customer_id,
c.customer_name
order by sales desc
limit 10;

# What is the average transaction value for frequent customers compared to infrequent customers? 
with customer_transaction_count as (
  select 
  customer_id,
  count(transaction_id)as total_transaction
  from 201904sales
  where transaction_date between"2019-04-01" and "2019-04-30"
  group by customer_id
  ),
  customized_customer as (
  select
  customer_id,
  total_transaction,
  CASE 
  when total_transaction>=10 then "FREQUENT CUSTOMER"
  else "INFREQUENT CUSTOMER"
  end as customer_type
  from customer_transaction_count
  )
  select c.customer_type,
  AVG(s.line_item_amount) AS avg_transaction_amount
  from 201904sales s
  join customized_customer c
  on s.customer_id=c.customer_id
  where s.transaction_date between "2019-04-01" and "2019-04-30"
  group by c.customer_type;
  
# How do customer demographics (e.g., age, gender) influence purchasing behavior at Data Brew? 
select g.generation,
       c.gender,
       count(s.transaction_id)as purchase_count,
       avg(s.line_item_amount)as average_sales
from generations g
join customer c on g.birth_year=c.birth_year
join 201904sales s on s.customer_id=c.customer_id
group by g.generation, c.gender
order by g.generation;


# Which generational cohort (e.g., Baby Boomers, Millennials) represents the largest customer base at Data Brew? 
select generation,
count(generation)as gen_count 
from generations
group by generation
order by gen_count desc;

# What are the purchase patterns of loyal customers compared to new customers? 
WITH customer_purchase_count AS (
    SELECT 
        customer_id,
        COUNT(transaction_id) AS total_purchases
    FROM 201904sales
    WHERE transaction_date BETWEEN '2019-04-01' AND '2019-04-30'  -- April only
    GROUP BY customer_id
)
SELECT 
    customer_type,
    count(customer_type)as customer_type
FROM (
    SELECT 
        customer_id,
        total_purchases,
        CASE 
            WHEN total_purchases >= 10 THEN 'Loyal Customer'
            WHEN total_purchases BETWEEN 1 AND 2 THEN 'New Customer'
            ELSE 'Occasional Customer'
        END AS customer_type
    FROM customer_purchase_count
) categorized_customers
group by customer_type
order by customer_type;

# PRODUCT PERFORMANCE ANALYSIS
# What are the top 10 best-selling products at Data Brew? 
select product_category,
count(product_category)as product_count
from product
group by product_category
order by product_count desc
limit 10;

# Which products have the highest profit margins at Data Brew? 
select product_category,
sum(profit)as profit_margin
from product
group by product_category
order by profit_margin desc;

# How does the performance of promotional products compare to non-promotional products? 
select 
p.promo_yn as promo,
count(p.product_id) as product_count,
sum(s.quantity)as total_quantity,
sum(s.line_item_amount)as total_sales,
avg(s.line_item_amount)as avg_sales
from product p
join 201904sales s
on p.product_id=s.product_id
group by promo;

# INVENTORY MANAGEMENT  
select 
p.product_type,
sum(pi.per_waste) as per_waste
from pastry_inventory pi
join product p
on pi.product_id=p.product_id
group by p.product_type
order by p.product_type desc;

# CUSTOMER ANALYSIS
# What is the distribution of customers by birth year?
SELECT 
    birth_year, 
    COUNT(customer_id) AS customer_count
FROM customer
GROUP BY birth_year
ORDER BY birth_year;

# GEOGRAPHIC ANALYSIS
select s.sales_outlet_id,
so.store_address,
so.store_city,
count(s.sales_outlet_id)as total_footfall
from 201904sales s
join sales_outlet so
on s.sales_outlet_id=so.sales_outlet_id
group by s.sales_outlet_id,so.store_address,so.store_City
order by total_footfall desc;

