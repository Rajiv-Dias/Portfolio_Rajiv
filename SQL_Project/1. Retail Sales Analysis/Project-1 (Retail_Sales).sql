-- Data Analist Project (Sales Analysis) 

-- Note:
-- 1. 💬 = Main Point
-- 2. 🆗 = Sup Point

-- 1. DatabASe Setup 💬
-- Creating Tables AND Columns 🆗  
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


-- 2. Data Exploration & Cleaning 💬 
-- a. Record COUNT: Determine the total number of records in the datASet.
SELECT COUNT (*) AS total_row
FROM public.retail_sales

-- b. Customer COUNT: Find out how many unique customers are in the datASet.
SELECT COUNT (DISTINCT customer_id) 
FROM public.retail_sales

-- c. Category COUNT: Identify all unique product categories in the datASet.
SELECT DISTINCT category 
FROM retail_sales;

-- d. Null Value Check: Check for any null values in the datASet AND delete records with missing data.
-- a. Finding Null Values 🆗 
SELECT * 
FROM public.retail_sales
WHERE 
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
DELETE 
FROM public.retail_sales
WHERE 
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


-- 3. Data Analysis & Findings 💬💬💬
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
SELECT *
FROM public.retail_sales
WHERE sales_date = '2022-11-05'


-- Q.2 Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 2 in the month of Nov-2022 💬
SELECT *
FROM public.retail_sales
WHERE 
	category = 'Clothing'
	AND 
	quantity >= 3
	AND 
	sales_date BETWEEN '2022-11-01' AND '2022-11-30'
ORDER BY sales_date ASC

-- OR 

SELECT *
FROM public.retail_sales
WHERE
	category = 'Clothing'
	AND
	quantity >= 3
	AND
	TO_CHAR (sales_date, 'yyyy,mm') = '2022,11'
ORDER BY sales_date



-- Q.3 Calculate  order volume and the total sales (revenue) for each category. 💬
SELECT 
	category, COUNT(*) AS total_orders, 
	SUM (total_sales) AS revenue
FROM public.retail_sales
GROUP BY 1


-- Q.4 Find the average age of customers who purchased items from the 'Beauty' category.💬 
SELECT 
	ROUND (AVG (age),2) AS avg_age
FROM public.retail_sales
WHERE 
	category = 'Beauty'


-- Q.5 find all transactions where the total_sale is greater than 1000. 💬
SELECT *
FROM public.retail_sales
WHERE total_sales > 1000
ORDER BY total_sales DESC


-- Q.6 Find the total number of transactions (transaction_id) made by each gender in each category. 💬
SELECT 
	category, 
	gender, 
	COUNT (transaction_id) AS Tot_Transaction
FROM public.retail_sales
GROUP BY 
	gender, 
	category
ORDER BY 1, 3 DESC

-- a. Male 🆗
SELECT gender, category, COUNT (transaction_id) AS Tot_Num_of_Transaction
FROM public.retail_sales
WHERE gender = 'Male'
GROUP BY gender, category
ORDER BY Tot_Num_of_Transaction DESC

-- b. Female 🆗
SELECT gender, category, COUNT (total_sales) AS Tot_Num_of_Transaction
FROM public.retail_sales
WHERE gender = 'Female'
GROUP BY gender, category
ORDER BY Tot_Num_of_Transaction DESC



-- Q.7 Calculate the average sale for each month. Find out best selling month in each year. 💬

-- Query-1 (Sub Query)
SELECT 
	  EXTRACT (year FROM sales_date) AS year,
	  EXTRACT (month FROM sales_date) AS month,
	  AVG (total_sales) AS AVG,
	  RANK () OVER (PARTITION BY EXTRACT (year FROM sales_date) ORDER BY AVG (total_sales) DESC) AS rank 
FROM public.retail_sales
GROUP BY year, month

-- Query-2 (Main Query) , Find out best selling month in each year
SELECT year, month, avg
FROM ( 
	SELECT 
		  EXTRACT (year FROM sales_date) AS year,
		  EXTRACT (month FROM sales_date) AS month,
		  AVG (total_sales) AS AVG,
		  RANK () OVER (PARTITION BY EXTRACT (year FROM sales_date) ORDER BY AVG (total_sales) DESC) AS rank 
	FROM public.retail_sales
	GROUP BY year, month
	)
WHERE rank = 1


-- Q.8 Find the top 5 customers based on the highest total sales 💬
SELECT
	customer_id,
	SUM (total_sales) AS total_sales
FROM public.retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5

-- Q.9 Find the number of unique customers who purchased items from each category. 💬
SELECT 
	category, 
	COUNT (DISTINCT customer_id) AS Num_of_unique_Cus 
FROM public.retail_sales
GROUP BY category
ORDER BY Num_of_unique_Cus DESC


-- Q.10 Create each shift and find volume of sales & total sales for each shift (Example Morning <=12, Afternoon Between 12 & 17, Evening >17) 💬
-- A. Sub Query 🆗
-- Query-1 (Sub Query)
SELECT *,
	   CASE 
	   		WHEN EXTRACT (hour FROM sales_time) < 12 THEN 'Morning'
	   		WHEN EXTRACT (hour FROM sales_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	   		ELSE 'Evening'
		END AS shift
FROM public.retail_sales

-- Query-2 (Main Query)
SELECT shift, COUNT(*) AS total_order, SUM (total_sales) AS revenue
FROM (SELECT *,
	   CASE 
	   		WHEN EXTRACT (hour FROM sales_time) < 12 THEN 'Morning'
	   		WHEN EXTRACT (hour FROM sales_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	   		ELSE 'Evening'
		END AS shift
	  FROM public.retail_sales)
GROUP BY shift
ORDER BY revenue DESC



-- B. CTE (Common Table Expression) 🆗
-- Query-1
WITH new_table 	-- Creating new table
AS ( SELECT *,
	   CASE 
	   		WHEN EXTRACT (hour FROM sales_time) < 12 THEN 'Morning'
	   		WHEN EXTRACT (hour FROM sales_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	   		ELSE 'Evening'
		END AS shift  -- Creating new column
FROM public.retail_sales)

-- Query-2
SELECT shift, COUNT (transaction_id) AS Vol_sales, SUM (total_sales) AS revenue
FROM new_table
GROUP BY shift 
ORDER BY revenue DESC

-- Note:
-- Both queries must be run simultaneously.










































