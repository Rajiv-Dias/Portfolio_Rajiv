# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `p1_retail_db`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `ProjectSQL_db`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sales date, sales time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sales amount.

```sql
CREATE DATABASE ProjectSQL_db;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sales_date DATE,	
    sales_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sales FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
-- a. Record Count
SELECT COUNT (*) AS total_row
FROM public.retail_sales

-- b. Customer Count
SELECT COUNT (DISTINCT customer_id) 
FROM public.retail_sales

-- c. Category Count
SELECT DISTINCT category 
FROM retail_sales;

-- d. Null Value Check
-- a. Finding Null Values 🆗 
SELECT * 
FROM public.retail_sales
WHERE 
	transaction_id IS NULL OR sales_date IS NULL OR sales_time IS NULL OR             customer_id IS NULL OR gender IS NULL OR age IS NULL OR category IS NULL
	OR quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sales      IS NULL

-- b. Remove null values 🆗
DELETE 
FROM public.retail_sales
WHERE 
transaction_id IS NULL OR sales_date IS NULL OR sales_time IS NULL OR             customer_id IS NULL OR gender IS NULL OR age IS NULL OR category IS NULL
	OR quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sales      IS NULL
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Retrieve all columns for sales made on '2022-11-05'**:
```sql
SELECT *
FROM public.retail_sales
WHERE sales_date = '2022-11-05'
```

2. **Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 2 in the month of Nov-2022**:
```sql
SELECT *
FROM public.retail_sales
WHERE 
	category = 'Clothing'
	AND 
	quantity >= 3
	AND 
	sales_date BETWEEN '2022-11-01' AND '2022-11-30'
ORDER BY sales_date ASC
```

3. **Calculate  order volume and the total sales (revenue) for each category.**:
```sql
SELECT 
	category, COUNT(*) AS total_orders, 
	SUM (total_sales) AS revenue
FROM public.retail_sales
GROUP BY 1
```

4. **Find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT 
	ROUND (AVG (age),2) AS avg_age
FROM public.retail_sales
WHERE 
	category = 'Beauty'
```

5. **find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000
```

6. **Find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT 
	category, 
	gender, 
	COUNT (transaction_id) AS Tot_Transaction
FROM public.retail_sales
GROUP BY 
	gender, 
	category
ORDER BY 1,3 DESC
```
**a. Male**:
```sql
SELECT gender, category, COUNT (transaction_id) AS Tot_Num_of_Transaction
FROM public.retail_sales
WHERE gender = 'Male'
GROUP BY gender, category
ORDER BY Tot_Num_of_Transaction DESC
```

**b. Female**:
```sql
SELECT gender, category, COUNT (total_sales) AS Tot_Num_of_Transaction
FROM public.retail_sales
WHERE gender = 'Female'
GROUP BY gender, category
ORDER BY Tot_Num_of_Transaction DESC
```

7. **Calculate the average sale for each month. Find out best selling month in each year.**:
```sql
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
```

8. **Find the top 5 customers based on the highest total sales **:
```sql
SELECT
	customer_id,
	SUM (total_sales) AS total_sales
FROM public.retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5
```

9. **Find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category
```

10. **Create each shift and find volume of sales & total sales for each shift (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)**:
```sql
-- CTE (Common Table Expression) 
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
```

## Findings

- **Customer Demographics**: The dataset comprises male and female consumers across various age demographics with sales distributed across different categories such as Clothing, Electronic, and Beauty.
- **High-Value Transactions**: Several transactions had a total sales amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly and shift-based analysis reveals variations in sales performance, helping to identify peak sales periods and seasonal trends.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.


## Author - Rajiv Noor Said
