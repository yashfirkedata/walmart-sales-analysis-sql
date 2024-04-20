-- 1. Data Wrangling
-- Build a database, create table, insert data
CREATE TABLE sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
	branch VARCHAR(5) NOT NULL,
	city VARCHAR(30) NOT NULL,
	customer_type VARCHAR(30) NOT NULL,
	gender VARCHAR(10) NOT NULL,
	product_line VARCHAR(100) NOT NULL,
	unit_price DECIMAL(10,2) NOT NULL,
	quantity INT NOT NULL,
	vat FLOAT NOT NULL,
	total DECIMAL NOT NULL,
	date TIMESTAMP NOT NULL,
	time TIME NOT NULL,
	payment VARCHAR(15) NOT NULL,
	cogs DECIMAL NOT NULL,
	gross_margin_pct FLOAT,
	gross_income DECIMAL,
	rating FLOAT
);

-- 2. Feature Engineering

1. Time_of_day 

SELECT time,
(CASE 
    WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
    WHEN time BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
    ELSE 'Evening' 
END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20)

UPDATE sales
SET time_of_day = (
	CASE 
    WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
    WHEN time BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
    ELSE 'Evening' 
END
)

2. Day_name

SELECT date,
to_char(date, 'Day') AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name = to_char(date,'Day')

3. Month_name

SELECT date,
to_char(date,'MONTH') AS month_name
FROM sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(15)
UPDATE sales
SET month_name = to_char(date,'MONTH')

------------------------------------------------------------------------------
------------ Exploratory Data Analysis -------------
------------------------------------------------------------------------------
SELECT * FROM sales
GENERIC QUESTIONS
-- 1. How many distinct cities are present in the dataset?
SELECT DISTINCT city FROM sales

-- 2. In which city is each branch situated?
SELECT DISTINCT branch, city FROM sales

Product Analysis
-- 1. How many distinct product lines are there in the dataset?
SELECT COUNT(DISTINCT product_line) FROM sales

-- 2. What is the most common payment method?
SELECT payment, COUNT(payment)
FROM sales
GROUP BY payment 
ORDER BY COUNT(payment) DESC
LIMIT 1

-- 3. What is the most selling product line?
SELECT product_line, COUNT(product_line)
FROM sales
GROUP BY product_line 
ORDER BY COUNT(product_line) DESC
LIMIT 1

-- 4. What is the total revenue by month?
SELECT month_name, SUM(total) AS s
FROM sales
GROUP BY month_name
ORDER BY s DESC
LIMIT 1

-- 5. Which month recorded the highest Cost of Goods Sold (COGS)?
SELECT month_name, SUM(cogs) AS s
FROM sales
GROUP BY month_name
ORDER BY s DESC
LIMIT 1

-- 6. Which product line generated the highest revenue?
SELECT product_line, SUM(total) AS s
FROM sales
GROUP BY product_line 
ORDER BY COUNT(product_line) DESC
LIMIT 1

-- 7. Which city has the highest revenue?
SELECT city, SUM(total) AS s
FROM sales
GROUP BY city
ORDER BY COUNT(city) DESC
LIMIT 1

-- 8. Which product line incurred the highest VAT?
SELECT product_line, SUM(vat) AS vat
FROM sales
GROUP BY product_line 
ORDER BY COUNT(product_line) DESC
LIMIT 1

-- 9. Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,' based on whether its sales are above the average.
ALTER TABLE sales ADD COLUMN product_category VARCHAR(20);

UPDATE sales 
SET product_category= 
(CASE 
	WHEN total >= (SELECT AVG(total) FROM sales) THEN 'Good'
    ELSE 'Bad'
END);

-- 10. Which branch sold more products than average product sold?
SELECT branch , SUM(quantity)
FROM sales
GROUP BY branch
HAVING SUM(quantity)> AVG(quantity)
ORDER BY SUM(quantity) DESC 
LIMIT 1

-- 11. What is the most common product line by gender?
SELECT product_line , gender, COUNT(gender) AS total_count
FROM sales
GROUP BY gender , product_line 
ORDER BY total_count DESC 
LIMIT 1;

--12. What is the average rating of each product line?
SELECT product_line, AVG(rating) AS ag
FROM sales
GROUP BY product_line

SALES ANALYSIS 
-- 1. Number of sales made in each time of the day per weekday.
SELECT day_name, time_of_day, COUNT(invoice_id) AS total_sales
FROM sales 
GROUP BY day_name, time_of_day 
HAVING day_name NOT IN ('Sunday','Saturday');

-- 2. Identify the customer type that generates the highest revenue.
SELECT customer_type, SUM(total)
FROM sales
GROUP BY customer_type
ORDER BY SUM(total) DESC
LIMIT 1

-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, SUM(VAT) AS total_VAT
FROM sales 
GROUP BY city 
ORDER BY total_VAT DESC 
LIMIT 1;

-- 4.Which customer type pays the most in VAT?
SELECT customer_type, SUM(VAT) AS total_VAT
FROM sales 
GROUP BY customer_type 
ORDER BY total_VAT DESC 
LIMIT 1;

Customer Analysis
-- 1.How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) 
FROM sales;

-- 2.How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) 
FROM sales;

-- 3.Which is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS common_customer
FROM sales 
GROUP BY customer_type 
ORDER BY common_customer DESC 
LIMIT 1;

-- 4.Which customer type buys the most?
SELECT customer_type, SUM(total) as total_sales
FROM sales 
GROUP BY customer_type 
ORDER BY total_sales
LIMIT 1;

SELECT customer_type, COUNT(*) AS most_buyer
FROM sales 
GROUP BY customer_type 
ORDER BY most_buyer DESC 
LIMIT 1;

-- 5.What is the gender of most of the customers?
SELECT gender, COUNT(*) AS all_genders 
FROM sales 
GROUP BY gender 
ORDER BY all_genders DESC 
LIMIT 1;

-- 6.What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS gender_distribution
FROM sales 
GROUP BY branch, gender 
ORDER BY branch;

-- 7.Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS average_rating
FROM sales 
GROUP BY time_of_day 
ORDER BY average_rating DESC 
LIMIT 1;

-- 8.Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, AVG(rating) AS average_rating
FROM sales 
GROUP BY branch, time_of_day 
ORDER BY average_rating 
DESC;

SELECT branch, time_of_day, rating,
AVG(rating) OVER(PARTITION BY branch) AS avg_rating_per_branch
FROM sales;


-- 9.Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) AS average_rating
FROM sales 
GROUP BY day_name 
ORDER BY average_rating DESC 
LIMIT 1;

-- 10.Which day of the week has the best average ratings per branch?
SELECT  branch, day_name, AVG(rating) AS average_rating
FROM sales 
GROUP BY day_name, branch 
ORDER BY average_rating DESC;

SELECT  branch, day_name,rating,
AVG(rating) OVER(PARTITION BY branch) AS ratingg
FROM sales
ORDER BY ratingg DESC;