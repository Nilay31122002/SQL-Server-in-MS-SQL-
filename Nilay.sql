use DBNilay

select * from production.brands
select * from production.categories
select * from production.products
select * from production.stocks
select * from sales.customers
select * from sales.order_items
select * from sales.orders
select * from sales.staffs
select * from sales.stores

/* Order count as per order status.*/
/* Use online bike store database and design a query that returns count of orders as per order status. 
Result should include following columns: 
Pending, Processing, Rejected, Completed 
Note: order_status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed.*/

SELECT    
    SUM(CASE WHEN order_status = 1 THEN 1 ELSE 0 END) AS 'Pending', 
    SUM(CASE WHEN order_status = 2 THEN 1 ELSE 0 END) AS 'Processing', 
    SUM(CASE WHEN order_status = 3 THEN 1 ELSE 0 END) AS 'Rejected', 
    SUM(CASE WHEN order_status = 4 THEN 1 ELSE 0 END) AS 'Completed' 
FROM    
    sales.orders

/* Products categorisation */
/* Use online bike store database and design a query that returns distribution of 
products as per product list price over 5 price groups as Luxurious, Expensive, Premium, Budget, Low cost. 
Result should include following columns: 
Product_name, list_price, Price Group.*/

SELECT product_name,list_price, 
    CASE
        WHEN (list_price) < 500  THEN 'Low cost'
        WHEN (list_price) < 1000  THEN 'Budget'
        WHEN (list_price) < 1500  THEN 'Premium'
        WHEN (list_price) < 2000 THEN 'Expensive'
        WHEN (list_price) > 2000 THEN 'Luxurious' 
    END as PriceGroup
FROM    
    production.products

/* Basic Data Retrieval  */ 
/* Use online bike store database and perform following actions:	
(1)Find all customers not living in NY state.*/

select * from  sales.customers where not state ='NY'

/*(2)Find name of customer and their phone number who have registered their phone number in 
     alphabetical order of first name and last name like telephone directory.*/

select  concat(first_name ,' ', last_name) 
as customer_name,phone 
from sales.customers 
where NOT phone = 'NULL'
order by customer_name 

/*(3)Find name of customer and their email having email domain in either msn.com or hotmail.com.*/

select concat(first_name ,' ', last_name) 
as customer_name,email 
from sales.customers 
where  email  LIKE '%@msn.com' or email like '%@hotmail.com';

/*(4)Find customers whose name contains rob keyword.*/

select * from sales.customers 
where first_name  like '%ROB%' or last_name like '%rob%'; 

/*(5)Find name of customer and address having exact 4 digits in house/flat no. in street address.*/ 

select concat(first_name ,' ', last_name) 
as customer_name,street 
from sales.customers 
where street like '%[0-9][0-9][0-9][0-9]%';

/*(6)Find state-wise Total number of cities and total number of customers. */

select state, count(city) 
as total_cities,count(*) 
as total_customer
from sales.customers
group by state
order by state;

/*(7)Find list of customer emails separated with semicolon (;) who is living in Jackson Heights, New York, Baldwin and Oakland.*/

select a.city,STRING_AGG(email, ';') as customer_email
from sales.customers as a
where a.city in ('Jackson Heights','New York','Baldwin','Oakland')
group by a.city

/*(8)Find all cities and states having total customers more than 10.*/

select state,city, count(*) 
as total_customer
from sales.customers
group by city,state
having count (*)>10

/*(9)Find all email domains with which all customers are registered with.*/

select substring( email, charindex ('@', email)+1,
	   len (email)-charindex ('@',email) 
	   )domain 
from sales.customers
group by substring(email, charindex('@', email)+1,
		 len(email)-charindex('@',email)
);

/*(10)Find store wise staff headcount.*/

select store_id , 
count (staff_id) as Staff_headcount
from sales.staffs
group by store_id;

/*(11)Find order_id having highest and lowest order amount.*/

select * from
( select top 1 order_id,amount=sum((quantity*(list_price-(list_price*discount))))
  from sales.order_items group by order_id order by amount asc) maximum
  union
select * from
( select top 1 order_id,amount=sum((quantity*(list_price-(list_price*discount))))
  from sales.order_items group by order_id order by amount desc) minimum

/*(12)Find order wise products' count and total quantity.*/

select order_id , count (*) as total_products,
sum (quantity) as total_quantity
from sales.order_items
group by order_id

/*(13)Find all products designed for females (i.e. girls, women or ladies).*/

select * from production.products
where product_name like '%females%'
or product_name like '%girls%' 
or product_name like '%women%' 
or product_name like '%ladies%' 

/*(14)Find all bikes designed by Trek and Electra brands in the year 2017.*/

select * from production.products
where (brand_id=1 or brand_id=9)  and model_year = 2017

/*(15)Find total revenue generated and discount provided till date.*/  

select sum(list_price) as total_revenue,
       sum(discount) as total_dicout 
from sales.order_items

/* Retrieve store-wise and year-wise total number of orders received.*/
/* Retrieve store-wise and year-wise total number of orders received. Result must include following columns:
   Store_id, year, TotalOrdersReceived.*/

   select store_id , year (order_date) as year, 
   count(*) as totalorderrecivied
   from sales.orders 
   group by store_id , year (order_date) 

/* Retrieve All the products having Nth highest list price*/
/* Retrieve all the products having nth highest list price.*/

select * from production.products
where list_price=6499.99

/* Staff incentive calculation.*/
/* Use online bike store sample database and retrieve names of all staffs along with names of his/her manager. 
   Result should include following columns: 
   Staff Name, Manager Name, Store Name, Incentive Amount 
   Note: Incentive amount = 5% of Sales by individual staff considering only completed orders.*/

   select concat(s.first_name,'',s.last_name) as staff_name, concat(s1.first_name,'',s1.last_name) as manager_name,
   store_name,(0.05* sum(quantity*(list_price-(list_price*discount)))) as amount 
   from sales.orders
   join sales.stores on sales.stores.store_id = sales.orders.store_id
   join sales.staffs s on sales.orders.staff_id = s.staff_id
   join sales.order_items on sales.order_items.order_id = sales.orders.order_id
   join sales.staffs s1 on sales.orders.staff_id = s1.manager_id
   where shipped_date is not null
   group by store_name,
   concat (s.first_name,'',s.last_name),concat(s1.first_name,'',s1.last_name)
   
/* Order details with final order amount.*/
/* Use online bike store sample database and design a query that returns a table containing following columns: 
   order_id, customer_name, order_date, shipped_date, store_name, staff_name, final_order_amount.*/
   
SELECT sales.orders.order_id,concat(s.first_name,'',s.last_name) as customer_name,order_date,shipped_date,store_name,
	            concat(s1.first_name,'',s1.last_name) as staff_name,sum((list_price*quantity)-(list_price*quantity*discount))
				as final_orders_amounts
FROM sales.orders
join sales.customers s on s.customer_id = sales.orders.customer_id
join sales.stores on sales.stores.store_id = sales.orders.store_id
join sales.staffs s1 on s1.staff_id = sales.orders.staff_id
join sales.order_items on sales.order_items.order_id = sales.orders.order_id
group by sales.orders.order_id,concat(s.first_name,'',s.last_name),order_date,shipped_date,store_name,
	            concat(s1.first_name,'',s1.last_name) 

/* Total available stock of all products */
/* Use online bike store sample database and design a query that returns a table containing following columns: 
   brand_name, category_name, product_name, model_year, total_available_stock.*/

select brand_name, category_name, product_name, model_year,
sum(quantity) as total_available_stock
from production.products
join production.brands on production.brands.brand_id = production.products.brand_id
join production.categories on production.categories.category_id = production.products.category_id
join production.stocks on production.products.product_id = production.stocks.product_id 
group by brand_name, category_name, product_name, model_year


select sum(quantity) as total_available_stock 
from production.stocks
group by product_id

/* Design a schema for Employee management as per XInfo portal (like My Own SSM->Employee Details) and 
   populate all tables using your information using SSMS.
   Schema Name: XInfo
   List of Tables:
   Employees
   Department
   CostCentre
   For submission of this assignment, upload screenshot of database diagram of schema designed by you.*/

use DBNilay

create schema XInfo

create table XInfo.Employees
(
employees_id int primary key,
employees_name varchar(30),
employees_email varchar(30),
department_id int ,
department_name varchar(30),
employees_phone int,
);

create table XInfo.Department
(
department_id int primary key,
department_name varchar(30),
employees_id int,
employees_name varchar(30),
);

create table XInfo.CostCentre
(
costcenter_id int primary key,
costcenter_name varchar(30),
employees_id int,
employees_phone int,
department_id int,
);

/* Quarterly Sales Analysis.*/
/* Design a view to retrieve year-wise quarterly sales records for all stores. 
   The view must have following columns: store_name, year, Q1, Q2, Q3, Q4.*/

   select s.store_name, YEAR(o.order_date) as year,
   SUM (case when month(o.order_date) between 1 and 2 then l.list_price else 0 end) as Q1,
   SUM (case when month(o.order_date) between 4 and 5 then l.list_price else 0 end) as Q2,
   SUM (case when month(o.order_date) between 7 and 8 then l.list_price else 0 end) as Q3,
   SUM (case when month(o.order_date) between 10 and 12 then l.list_price else 0 end) as Q4
   from sales.orders o
   join sales.stores s on o.store_id =s.store_id
   join production.products l on l.list_price = l.list_price
   group by s.store_name , year (o.order_date);
   
/* Brand-wise quarterly profit(+) or loss(-) */
/* Use online bike store database and design a query that returns brand-wise quarterly profit(+) or loss(-). 
   Result should include following columns: 
   BrandName, Year, Quarter, QuarterlyNetSale, Profit/Loss (+/-), SalesDifference 
   Note: get only single symbol i.e. ‘+’ for profit and ‘–‘ for loss.*/

 SELECT  b.brand_name as Brand_name, year(o.order_date)as year,
 'Q'+ cast (ceiling(month(o.order_date)/3.0) as varchar) as quarter,
 sum(oi.list_price *(1-discount)*quantity) as quartly_net_sales,
 case when sum(oi.list_price) >= lag (sum(oi.list_price),1,0) over (partition by b.brand_name, year(o.order_date)
 order by  year(o.order_date), ceiling(month(o.order_date)/3.0)) then '+' else '-' end as profit_loss,
		   sum(oi.list_price) - lag (sum(oi.list_price),1,0) over(partition by b.brand_name, year(o.order_date)
 order by  year(o.order_date), ceiling(month(o.order_date)/3.0))as sales_difference
 from sales.orders o
 join sales.order_items oi on o.order_id = oi.order_id
 join production.products p on oi.product_id = p.product_id
 join production.brands b on p.brand_id = b.brand_id
 group by b.brand_name, year(o.order_date), ceiling(month(o.order_date)/3.0)
 order by b.brand_name, year , quarter;

/* Retrieve store-wise and year-wise total number of orders received.*/
/* Use online bike store database and design a query that returns brand-wise product details having highest list price and lowest list price. 
   Result should include following column: 
   BrandName, ProductNameWithMaxListPrice, Category, MaxListPrice, ProductNameWithMinListPrice, Category, MinListPrice.*/
SELECT
    production.brands.brand_name as BrandName,
	p1.product_name as ProductNamewithMAXlistPrice,
	c1.category_name as category,
	p1.list_price as MAXlistPrice,
	p2.product_name as ProductNamewithMINlistPrice,
	c2.category_name as category,
	p2.list_price as MINlistPrice
	FROM production.brands
JOIN production.products p1 ON production.brands.brand_id = p1.brand_id
JOIN production.categories c1 ON p1.category_id = c1.category_id
JOIN production.products p2  ON production.brands.brand_id = p2.brand_id
JOIN production.categories c2  ON p2.category_id = c2.category_id
WHERE p1.list_price = (SELECT MAX(list_price) FROM production.products 
WHERE brand_id = production.brands.brand_id)
  AND p2.list_price = (SELECT MIN(list_price) FROM production.products
WHERE brand_id = production.brands.brand_id)

GROUP BY production.brands.brand_id, p1.list_price, p2.list_price;

/* Store wise, Brand wise and Category wise yearly sales analysis.*/
/* Use online bike store sample database and design a query that returns a table containing following columns: 
   store_name, brand_name, category_name, sales_year, total_orders_received, total_products_sold, total_quantity_sold, revenue.*/

select s.store_name , b.brand_name , c.category_name,
year(o.order_date) as sales_year,
count(distinct o.order_id) as totalorderrecived,
count(distinct p.product_id) as totalproductssold,
sum(oi.quantity) as totalquantitysold,
sum(oi.quantity * oi.list_price*(1-discount)) as revanue
from sales.orders o
join sales.order_items oi on o.order_id = oi.order_id
join production.products p on oi.product_id = p.product_id
join production.brands b on p.brand_id = b.brand_id
join production.categories c on p.category_id = c.category_id
join sales.stores s on o.store_id =s.store_id
group by s.store_name, b.brand_name , c.category_name, year(o.order_date)
order by s.store_name, b.brand_name, c.category_name, sales_year;