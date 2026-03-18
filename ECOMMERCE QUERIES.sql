Create database ecommerce_project;
Use ecommerce_project;
Create table ecommerce_sales(
id INT auto_increment PRIMARY KEY,
order_id INT,
product VARCHAR(255),
quantity_ordered INT,
price_each DECIMAL (10.2),
order_date DATETIME,
purchase_address VARCHAR(255)
);

-- STEP 3 import the csv files
LOAD DATA INFILE '/path/Sales_January_2019.csv'
INTO TABLE ecommerce_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, product, quantity_ordered, price_each, order_date, purchase_address);
 select * from ecommerce_sales
 limit 10;
 -- this query thre error so i opted to use table data import wizard to import all the csv files
 select distinct month(order_date) as months 
 from ecommerce_sales
 order by months;
 
 -- step 4 cleaning invalid rows
 SELECT count(*) from ecommerce_sales;
 
 SELECT *
FROM ecommerce_sales
WHERE quantity_ordered IS NULL
OR price_each IS NULL;

SELECT 
MIN(order_date) AS first_order,
MAX(order_date) AS last_order
FROM ecommerce_sales;

SET SQL_SAFE_UPDATES = 0;
UPDATE ecommerce_sales
SET order_date = STR_TO_DATE(order_date, '%m/%d/%y %H:%i');

SELECT DISTINCT YEAR(order_date)
FROM ecommerce_sales
ORDER BY YEAR(order_date);

UPDATE ecommerce_sales
SET order_date = DATE_ADD(order_date, INTERVAL 18 YEAR);

UPDATE ecommerce_sales
SET order_date = TIMESTAMP(
    CONCAT('2019-', DATE_FORMAT(order_date,'%m-%d %H:%i:%s'))
);

SELECT 
MIN(order_date),
MAX(order_date)
FROM ecommerce_sales;

SELECT 
MONTH(order_date) AS month,
COUNT(*) AS orders
FROM ecommerce_sales
GROUP BY month
ORDER BY month;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS total_rows
FROM ecommerce_sales;

SELECT 
MONTH(order_date) AS month,
COUNT(*) AS orders
FROM ecommerce_sales
GROUP BY month
ORDER BY month;

-- step 4 create the revenue table
ALTER TABLE ecommerce_sales
ADD revenue DECIMAL(10,2);
UPDATE ecommerce_sales
SET revenue = quantity_ordered * price_each;

SELECT 
quantity_ordered,
price_each,
revenue
FROM ecommerce_sales
LIMIT 10;


-- step 5 questions to solve 
-- For SALES PERFORMANCE
-- 1 Best sales month for the year
select month(order_date) as months,
sum(revenue) as total_sales from ecommerce_sales
group by months
order by total_sales desc;

-- 2 Which product sold more units
select product, sum(quantity_ordered) as total_quantity
from ecommerce_sales
group by product
order by total_quantity desc;

-- 3 Which product generated more revenue
select product, sum(revenue) as total_sales from ecommerce_sales
group by product
order by total_sales desc;

-- 4 Which city generates more revenue
Select SUBSTRING_INDEX(SUBSTRING_INDEX(purchase_address, ',', 2), ',', -1) AS city,
SUM(revenue) AS city_revenue
FROM ecommerce_sales
GROUP BY city
ORDER BY city_revenue DESC;

-- 5 What time of the day do customers buy the most
select hour(order_date) as hour, count(*) as total_orders from ecommerce_sales
group by hour
order by total_orders desc;

-- 6 What time generates more revenue
select time(order_date) as hour, sum(revenue) as revenue
from ecommerce_sales
group by hour
order by revenue desc;

-- 7 What products are often bought together
select a.product AS product_1, b.product AS product_2,
count(*) as frequency from ecommerce_sales a
join ecommerce_sales b on a.order_id = b.order_id
and a.product < b.product
group by product_1, product_2
order by frequency desc;