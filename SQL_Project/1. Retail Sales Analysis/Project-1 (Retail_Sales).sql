-- Data Analist Project (Sales Analysis) 

-- Note:
-- 1. 💬 = Main Point
-- 2. 🆗 = Sup Point


-- 1. Creating Tables and Columns 💬 
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sales_date DATE,	 --the format (yyyy-mm-dd)
                sales_time TIME,	 -- the format (hh-mm-ss)
                customer_id	INT,
                gender	VARCHAR(15), -- Check Max (len) in Excel, specify varchar(x)
                age	INT,
                category VARCHAR(15), -- Check Max (len) in Excel, specify varchar(x)
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sales FLOAT
            );

-- Checking whether the data has been entered
select *
from public.retail_sales

-- 2. data cleaning 💬 
-- a. Finding Null Values 🆗 
select * 
from public.retail_sales
where 
	transaction_id IS NULL
	OR
	sales_date IS NULL
	OR
	sales_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sales IS NULL

-- b. Remove null values 🆗
delete 
from public.retail_sales
where 
transaction_id IS NULL
	OR
	sales_date IS NULL
	OR
	sales_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sales IS NULL


-- Data Exploration 💬💬💬
-- Data Analysis & Business Key Problems 

-- Q.1 Retrieve all columns for sales made on '2022-11-05'
-- Q.2 Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Calculate the total sales (total_sale) for each category.
-- Q.4 Find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Find all transactions where the total_sale is greater than 1000.
-- Q.6 Find the total number of transactions (transaction_id) made by each gender in each category.
-- a. Male
-- b. Female
-- Q.7 Calculate the average sale for each month. Find out best selling month in each year.
-- Q.8 Find the top 5 customers based on the highest total sales.
-- Q.9 Find the number of unique customers who purchased items from each category.
-- Q.10 Create each shift and find volume of sales & total sales for each shift (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



-- Data Analysis & Business Key Answers 💬💬💬
-- My Analysis & Findings 

-- Q.1 Retrieve all columns for sales made on '2022-11-05' 💬
select *
from public.retail_sales
where sales_date = '2022-11-05'


-- Q.2 Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022 💬
select *
from public.retail_sales
where 
	category = 'Clothing'
	and 
	quantity > 3
	and 
	sales_date between '2022-11-01' and '2022-11-30'
order by sales_date asc

-- OR 

select *
from public.retail_sales
where
	category = 'Clothing'
	AND
	quantity > 3
	AND
	TO_CHAR (sales_date, 'yyyy,mm') = '2022,11'
order by sales_date



-- Q.3 Calculate the order volume and the total sales (revenue) for each category. 💬
select 
	category, count(*) as total_orders, 
	sum (total_sales) as revenue
from public.retail_sales
group by 1


-- Q.4 Find the average age of customers who purchased items from the 'Beauty' category.💬 
select 
	round (avg (age),2) as avg_age
from public.retail_sales
where 
	category = 'Beauty'


-- Q.5 Find all transactions where the total_sale is greater than 1000. 💬
select *
from public.retail_sales
where total_sales > 1000
order by total_sales desc


-- Q.6 Find the total number of transactions (transaction_id) made by each gender in each category. 💬
select 
	category, 
	gender, 
	count (transaction_id) as Tot_Transaction
from public.retail_sales
group by 
	gender, 
	category
order by 3 desc

-- a. Male 🆗
select gender, category, count (transaction_id) as Tot_Num_of_Transaction
from public.retail_sales
where gender = 'Male'
group by gender, category
order by Tot_Num_of_Transaction desc

-- b. Female 🆗
select gender, category, count (total_sales) as Tot_Num_of_Transaction
from public.retail_sales
where gender = 'Female'
group by gender, category
order by Tot_Num_of_Transaction desc



-- Q.7 Calculate the average sale for each month. Find out best selling month in each year. 💬

-- Query-1 (Sub Query)
select 
	  extract (year from sales_date) as year,
	  extract (month from sales_date) as month,
	  avg (total_sales) as avg,
	  rank () over (partition by extract (year from sales_date) order by avg (total_sales) desc) as rank 
from public.retail_sales
group by year, month

-- Query-2 (Main Query) , Find out best selling month in each year
select year, month, avg
from ( 
	select 
		  extract (year from sales_date) as year,
		  extract (month from sales_date) as month,
		  avg (total_sales) as avg,
		  rank () over (partition by extract (year from sales_date) order by avg (total_sales) desc) as rank 
	from public.retail_sales
	group by year, month
	)
where rank = 1







-- Q.8 Find the top 5 customers based on the highest total sales. 💬
select customer_id, sum (total_sales) as total_sales
from public.retail_sales
group by customer_id
order by total_sales desc
limit 5

-- Q.9 Find the number of unique customers who purchased items from each category. 💬
select category, count (distinct customer_id) as Num_of_unique_Cus 
from public.retail_sales
group by category
order by Num_of_unique_Cus desc


-- Q.10 Create each shift and find volume of sales & total sales for each shift (Example Morning <=12, Afternoon Between 12 & 17, Evening >17) 💬
-- A. Sub Query 🆗
-- Query-1 (Sub Query)
SELECT *,
	   case 
	   		when extract (hour from sales_time) < 12 then 'Morning'
	   		when extract (hour from sales_time) between 12 and 17 then 'Afternoon'
	   		else 'Evening'
		end as shift
FROM public.retail_sales

-- Query-2 (Main Query)
select shift, count(*) as total_order, sum (total_sales) as revenue
from (SELECT *,
	   case 
	   		when extract (hour from sales_time) < 12 then 'Morning'
	   		when extract (hour from sales_time) between 12 and 17 then 'Afternoon'
	   		else 'Evening'
		end as shift
	  FROM public.retail_sales)
group by shift
order by revenue desc



-- B. CTE (Common Table Expression) 🆗
-- Query-1
with new_table 	-- membuat tabel baru
as ( SELECT *,
	   case 
	   		when extract (hour from sales_time) < 12 then 'Morning'
	   		when extract (hour from sales_time) between 12 and 17 then 'Afternoon'
	   		else 'Evening'
		end as shift  -- membuat kolom baru
FROM public.retail_sales)

-- Query-2
select shift, count (transaction_id) as Vol_sales, sum (total_sales) as revenue
from new_table
group by shift 
order by revenue desc

-- Note:
-- saat ingin membuat kolom baru yg rumit perlu buat tabel baru juga (CTE)
















