-- ============================================================
-- PROJECT: E-commerce Sales & Customer Analysis
-- Tools: MySQL
-- Purpose: Data validation, cleaning, exploratory analysis,
--          customer summaries, joins, subqueries and CTEs.
--
-- IMPORTANT:
-- 1. Create/use the database and import ecommerce_sales.csv
--    into the raw table: ecommerce_sales_customer_analysis.
-- 2. The LOAD DATA path below is specific to the original
--    computer and is intentionally left as a commented example.
-- 3. The source CSV's first column had a UTF-8 BOM, hence the
--    source column name `ï»¿Order_ID`. Adjust if your import
--    column is named differently.
-- ============================================================

USE ecommerce_project;

-- ------------------------------------------------------------
-- 1. DATABASE AND RAW DATA CHECKS
-- ------------------------------------------------------------

SHOW TABLES;
DESCRIBE ecommerce_sales_customer_analysis;

SELECT COUNT(*) AS total_rows
FROM ecommerce_sales_customer_analysis;

SELECT *
FROM ecommerce_sales_customer_analysis
LIMIT 10;

-- Optional: import example (edit the path for your computer)
-- LOAD DATA INFILE 'C:/path/to/ecommerce_sales.csv'
-- INTO TABLE ecommerce_sales_customer_analysis
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- ------------------------------------------------------------
-- 2. DATA CLEANING
-- ------------------------------------------------------------
-- Re-create the cleaned table only when you intentionally want
-- to replace the existing table. The DROP statement is commented
-- out to help prevent accidental data loss.

-- DROP TABLE IF EXISTS ecommerce_clean;

CREATE TABLE IF NOT EXISTS ecommerce_clean AS
SELECT
    `ï»¿Order_ID` AS Order_ID,
    Customer_ID,
    Customer_Name,
    STR_TO_DATE(TRIM(Order_Date), '%d-%m-%Y') AS Order_Date,
    City,
    State,
    Category,
    Product,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Unit_Price), '[^0-9.-]', ''), '') AS DECIMAL(10,2)) AS Unit_Price,
    Quantity,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Discount_Percent), '[^0-9.-]', ''), '') AS DECIMAL(5,2)) AS Discount_Percent,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Discount_Amount), '[^0-9.-]', ''), '') AS DECIMAL(10,2)) AS Discount_Amount,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Sales_Amount), '[^0-9.-]', ''), '') AS DECIMAL(12,2)) AS Sales_Amount,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Shipping_Cost), '[^0-9.-]', ''), '') AS DECIMAL(10,2)) AS Shipping_Cost,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Total_Amount), '[^0-9.-]', ''), '') AS DECIMAL(12,2)) AS Total_Amount,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Unit_Cost), '[^0-9.-]', ''), '') AS DECIMAL(10,2)) AS Unit_Cost,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Profit), '[^0-9.-]', ''), '') AS DECIMAL(12,2)) AS Profit,
    Payment_Method,
    Sales_Channel,
    Order_Status,
    Customer_Type,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Customer_Rating), '[^0-9.-]', ''), '') AS DECIMAL(3,1)) AS Customer_Rating
FROM ecommerce_sales_customer_analysis;

-- Validate cleaned data
SELECT COUNT(*) AS total_clean_rows
FROM ecommerce_clean;

SELECT
    Order_ID, Order_Date, Unit_Price, Sales_Amount,
    Profit, Customer_Rating
FROM ecommerce_clean
LIMIT 10;

-- ------------------------------------------------------------
-- 3. KEY PERFORMANCE METRICS
-- ------------------------------------------------------------

SELECT SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean;

SELECT SUM(Profit) AS Total_Profit
FROM ecommerce_clean;

SELECT COUNT(DISTINCT Order_ID) AS Total_Orders
FROM ecommerce_clean;

SELECT SUM(Quantity) AS Total_Quantity
FROM ecommerce_clean;

SELECT AVG(Sales_Amount) AS Average_Sales_Amount
FROM ecommerce_clean;

SELECT MAX(Sales_Amount) AS Maximum_Sales
FROM ecommerce_clean;

SELECT MIN(Sales_Amount) AS Minimum_Sales
FROM ecommerce_clean;

-- ------------------------------------------------------------
-- 4. SALES AND PROFIT ANALYSIS
-- ------------------------------------------------------------

-- Total sales by state
SELECT State, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY State
ORDER BY Total_Sales DESC;

-- Total sales by category
SELECT Category, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Total profit by category
SELECT Category, SUM(Profit) AS Total_Profit
FROM ecommerce_clean
GROUP BY Category
ORDER BY Total_Profit DESC;

-- Total profit by state
SELECT State, SUM(Profit) AS Total_Profit
FROM ecommerce_clean
GROUP BY State
ORDER BY Total_Profit DESC;

-- Sales by city
SELECT City, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY City
ORDER BY Total_Sales DESC;

-- Sales by product
SELECT Product, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY Product
ORDER BY Total_Sales DESC;

-- Sales by payment method
SELECT Payment_Method, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY Payment_Method
ORDER BY Total_Sales DESC;

-- Sales by sales channel
SELECT Sales_Channel, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY Sales_Channel
ORDER BY Total_Sales DESC;

-- Sales by customer type
SELECT Customer_Type, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY Customer_Type
ORDER BY Total_Sales DESC;

-- Profit margin by category
SELECT
    Category,
    (SUM(Profit) / NULLIF(SUM(Sales_Amount), 0)) * 100 AS Profit_Margin_Percent
FROM ecommerce_clean
GROUP BY Category;

-- Average profit by category
SELECT Category, AVG(Profit) AS Average_Profit
FROM ecommerce_clean
GROUP BY Category;

-- Average sales by state
SELECT State, AVG(Sales_Amount) AS Average_Sales
FROM ecommerce_clean
GROUP BY State;

-- Quantity by category
SELECT Category, SUM(Quantity) AS Total_Quantity
FROM ecommerce_clean
GROUP BY Category;

-- Average sales by payment method
SELECT Payment_Method, AVG(Sales_Amount) AS Average_Sales
FROM ecommerce_clean
GROUP BY Payment_Method;

-- Monthly sales
SELECT
    YEAR(Order_Date) AS Order_Year,
    MONTH(Order_Date) AS Order_Month,
    SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Order_Year, Order_Month;

-- Yearly sales
SELECT YEAR(Order_Date) AS Order_Year, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY YEAR(Order_Date)
ORDER BY Order_Year;

-- ------------------------------------------------------------
-- 5. ORDER STATUS AND CUSTOMER RATING ANALYSIS
-- ------------------------------------------------------------

-- Order count by status
SELECT Order_Status, COUNT(DISTINCT Order_ID) AS Total_Orders
FROM ecommerce_clean
GROUP BY Order_Status;

-- Sales by order status
SELECT Order_Status, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY Order_Status;

-- Returned orders: total sales and average sales
SELECT
    SUM(Sales_Amount) AS Returned_Total_Sales,
    AVG(Sales_Amount) AS Returned_Average_Sales
FROM ecommerce_clean
WHERE Order_Status = 'Returned';

-- Number of cancelled orders
SELECT COUNT(DISTINCT Order_ID) AS Cancelled_Orders
FROM ecommerce_clean
WHERE Order_Status = 'Cancelled';

-- Delivered orders: total sales
SELECT SUM(Sales_Amount) AS Delivered_Total_Sales
FROM ecommerce_clean
WHERE Order_Status = 'Delivered';

-- Average customer rating
SELECT AVG(Customer_Rating) AS Average_Customer_Rating
FROM ecommerce_clean;

-- Order count by customer rating (NULL ratings are not included
-- in the grouped rating values; check them separately below)
SELECT Customer_Rating, COUNT(DISTINCT Order_ID) AS Total_Orders
FROM ecommerce_clean
GROUP BY Customer_Rating
ORDER BY Customer_Rating;

SELECT COUNT(*) AS Orders_With_Blank_Rating
FROM ecommerce_clean
WHERE Customer_Rating IS NULL;

-- ------------------------------------------------------------
-- 6. TOP-PERFORMING PRODUCTS AND CUSTOMERS
-- ------------------------------------------------------------

-- Top 5 products by sales
SELECT Product, SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY Product
ORDER BY Total_Sales DESC
LIMIT 5;

-- Top 5 customers by sales (grouped by ID and name)
SELECT
    Customer_ID,
    Customer_Name,
    SUM(Sales_Amount) AS Total_Sales
FROM ecommerce_clean
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Sales DESC
LIMIT 5;

-- Customers with more than one order
SELECT
    Customer_ID,
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM ecommerce_clean
GROUP BY Customer_ID, Customer_Name
HAVING COUNT(DISTINCT Order_ID) > 1
ORDER BY Total_Orders DESC;

-- ------------------------------------------------------------
-- 7. FILTERING AND CASE-BASED CLASSIFICATION
-- ------------------------------------------------------------

-- Orders with sales amount greater than 10,000
SELECT Order_ID, Customer_Name, Sales_Amount
FROM ecommerce_clean
WHERE Sales_Amount > 10000;

-- Orders with profit greater than 5,000
SELECT Order_ID, Customer_Name, Profit
FROM ecommerce_clean
WHERE Profit > 5000;

-- Orders with discount percentage greater than 10
SELECT Order_ID, Discount_Percent, Sales_Amount
FROM ecommerce_clean
WHERE Discount_Percent > 10;

-- Sales performance classification
SELECT
    Order_ID,
    Sales_Amount,
    CASE
        WHEN Sales_Amount >= 10000 THEN 'High'
        WHEN Sales_Amount >= 5000 THEN 'Medium'
        ELSE 'Low'
    END AS Sales_Performance
FROM ecommerce_clean;

-- Profit classification
SELECT
    Order_ID,
    Profit,
    CASE
        WHEN Profit >= 5000 THEN 'High Profit'
        WHEN Profit >= 2000 THEN 'Medium Profit'
        ELSE 'Low Profit'
    END AS Profit_Category
FROM ecommerce_clean;

-- Quantity classification
SELECT
    Order_ID,
    Quantity,
    CASE
        WHEN Quantity >= 5 THEN 'High Quantity'
        WHEN Quantity >= 3 THEN 'Medium Quantity'
        ELSE 'Low Quantity'
    END AS Quantity_Category
FROM ecommerce_clean;

-- Customer rating classification
SELECT
    Customer_ID,
    Customer_Name,
    Customer_Rating,
    CASE
        WHEN Customer_Rating >= 4.5 THEN 'Excellent'
        WHEN Customer_Rating >= 3.5 THEN 'Good'
        WHEN Customer_Rating IS NULL THEN 'Not Rated'
        ELSE 'Average'
    END AS Rating_Category
FROM ecommerce_clean;

-- ------------------------------------------------------------
-- 8. CUSTOMER SUMMARY AND JOINS
-- ------------------------------------------------------------

-- Create one row per customer
CREATE TABLE IF NOT EXISTS customer_summary AS
SELECT
    Customer_ID,
    Customer_Name,
    SUM(Sales_Amount) AS Total_Sales,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM ecommerce_clean
GROUP BY Customer_ID, Customer_Name;

SELECT *
FROM customer_summary
LIMIT 10;

-- Join cleaned order data with customer summary.
-- DISTINCT prevents repeated customer rows in this result.
SELECT DISTINCT
    e.Customer_ID,
    e.Customer_Name,
    c.Total_Sales,
    c.Total_Orders
FROM ecommerce_clean AS e
INNER JOIN customer_summary AS c
    ON e.Customer_ID = c.Customer_ID
ORDER BY c.Total_Sales DESC;

-- Customers with total sales greater than 30,000
SELECT
    Customer_ID,
    Customer_Name,
    Total_Sales,
    Total_Orders
FROM customer_summary
WHERE Total_Sales > 30000
ORDER BY Total_Sales DESC;

-- Customers with more than 8 orders
SELECT
    Customer_ID,
    Customer_Name,
    Total_Sales,
    Total_Orders
FROM customer_summary
WHERE Total_Orders > 8
ORDER BY Total_Sales DESC;

-- ------------------------------------------------------------
-- 9. SUBQUERIES
-- ------------------------------------------------------------

-- Orders with sales above the average order sales
SELECT Order_ID, Customer_Name, Sales_Amount
FROM ecommerce_clean
WHERE Sales_Amount > (
    SELECT AVG(Sales_Amount)
    FROM ecommerce_clean
);

-- Orders with profit above the average profit
SELECT Order_ID, Customer_Name, Profit
FROM ecommerce_clean
WHERE Profit > (
    SELECT AVG(Profit)
    FROM ecommerce_clean
);

-- Order(s) with the maximum sales amount
SELECT Order_ID, Customer_Name, Sales_Amount
FROM ecommerce_clean
WHERE Sales_Amount = (
    SELECT MAX(Sales_Amount)
    FROM ecommerce_clean
);

-- Order(s) with the minimum profit
SELECT Order_ID, Customer_Name, Profit
FROM ecommerce_clean
WHERE Profit = (
    SELECT MIN(Profit)
    FROM ecommerce_clean
);

-- Customers with more orders than the average customer
SELECT Customer_ID, Customer_Name, Total_Orders
FROM customer_summary
WHERE Total_Orders > (
    SELECT AVG(Total_Orders)
    FROM customer_summary
);

-- Customers with sales above average customer sales
SELECT Customer_ID, Customer_Name, Total_Sales
FROM customer_summary
WHERE Total_Sales > (
    SELECT AVG(Total_Sales)
    FROM customer_summary
);

-- ------------------------------------------------------------
-- 10. COMMON TABLE EXPRESSIONS (CTEs)
-- ------------------------------------------------------------

-- Customer-wise total sales using a CTE
WITH customer_sales AS (
    SELECT
        Customer_ID,
        Customer_Name,
        SUM(Sales_Amount) AS Total_Sales
    FROM ecommerce_clean
    GROUP BY Customer_ID, Customer_Name
)
SELECT Customer_ID, Customer_Name, Total_Sales
FROM customer_sales;

-- Customers with total sales greater than 30,000
WITH customer_sales AS (
    SELECT
        Customer_ID,
        Customer_Name,
        SUM(Sales_Amount) AS Total_Sales
    FROM ecommerce_clean
    GROUP BY Customer_ID, Customer_Name
)
SELECT Customer_ID, Customer_Name, Total_Sales
FROM customer_sales
WHERE Total_Sales > 30000;

-- Top 5 customers by total sales
WITH customer_sales AS (
    SELECT
        Customer_ID,
        Customer_Name,
        SUM(Sales_Amount) AS Total_Sales
    FROM ecommerce_clean
    GROUP BY Customer_ID, Customer_Name
)
SELECT Customer_ID, Customer_Name, Total_Sales
FROM customer_sales
ORDER BY Total_Sales DESC
LIMIT 5;

-- ============================================================
-- END OF PROJECT QUERIES
-- ============================================================
