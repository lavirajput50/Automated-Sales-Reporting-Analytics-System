/*
=========================================================
Project Name - Automated Sales Reporting & Analysis 
File Name- 03_sales_analysis.sql
Database - SQL (postgresql 18)

=========================================================
*/

--01:- Overall Business KPIs 
WITH total_revenue AS (
    SELECT SUM(revenue_usd) AS total_revenue  -- for calculate total revenue
    FROM sales_data
),
total_profit AS (
    SELECT SUM(profit_usd) AS total_profit -- for calculate total profit of sales 
    FROM sales_data
),
total_orders AS (
    SELECT COUNT(order_id) AS total_orders  -- overall count order id 
    FROM sales_data
),
avg_order AS (
    SELECT AVG(order_value_usd) AS avg_order_value  -- calculate average order value 
    FROM sales_data
)
SELECT *
FROM total_revenue, total_profit, total_orders, avg_order;  -- Print Overall KPI 


--02:- Quarter-Wise Trend 
WITH quarter_wise_trend AS (
SELECT Quarter,SUM(Revenue_USD) as quarter_wise_revenue,
SUM(Profit_USD) as quarter_wise_profit
FROM sales_data GROUP By Quarter 
)
SELECT*FROM quarter_wise_trend;

--03:- Month Wise Trend (seasonal pattern)
SELECT Month, 
SUM(Revenue_USD) as Monthly_Wise_Revenue 
FROM sales_data
GROUP BY Month 
ORDER BY Monthly_Wise_Revenue DESC; 

--04:- City Wise Revenue Performance
SELECT City,
SUM(Revenue_USD) as City_Wise_Revenue,
Rank() OVER(ORDER BY SUM(Revenue_USD)DESC) -- provide ranking on highest - lowest revenue
FROM sales_data 
GROUP BY City

--05:- Top Performing Restaurant_Type
WITH top_restaurant_revenue AS 
(SELECT Restaurant_Type as Restaurant,
SUM(Revenue_USD) as Restaurant_Wise_Revenue,
RANK()OVER(ORDER BY SUM(Revenue_USD)DESC) as Ranking
FROM sales_data
GROUP BY Restaurant_Type
)
-- Check Top Restaurant Wise Revenue
SELECT*FROM top_restaurant_revenue;

WITH top_restaurant_orders AS (
SELECT Restaurant_Type,
COUNT(Order_ID) as Orders,
RANK()OVER(ORDER BY COUNT(Order_ID)DESC) as Ranking
FROM sales_data
GROUP BY Restaurant_Type
)
-- Check Top Restaurant Wise Orders
SELECT*FROM top_restaurant_orders;

--06:- Top Performing Cuisine_Type
WITH top_cuision_type AS
(
SELECT Cuisine_Type,
SUM(Revenue_USD) as Revenue_Wise_Cuisine,
COUNT(Order_ID) as orders_Wise_Cuisine,
RANK()OVER(ORDER BY SUM(Revenue_USD)DESC,COUNT(Order_ID)DESC) as ranking
FROM sales_data
GROUP BY Cuisine_Type
)
SELECT*FROM top_cuision_type;

--07:- Order Volume Analysis
-- Total Order Wise City 
SELECT City,
COUNT(Order_ID) as Total_Orders
FROM sales_data
GROUP BY City
-- Total Order Wise Restaurant 
SELECT Restaurant_Type as Restaurant,
COUNT(Order_ID) as Total_Orders
FROM sales_data
GROUP BY Restaurant_Type

--08:- Average Order Value & Profit Margin
WITH city_summary AS (
SELECT City,
AVG(Order_Value_USD) as avg_orders,
SUM(Profit_USD)/SUM(Revenue_USD)*100 as profit_margin
FROM sales_data
GROUP BY City
)
SELECT*FROM city_summary;

WITH restaurant_summary AS
(
SELECT Restaurant_Type as Restaurant,
AVG(Order_Value_USD) as avg_orders,
SUM(Profit_USD)/SUM(Revenue_USD)*100 as Profit_margin
FROM sales_data
GROUP BY Restaurant_Type
)
SELECT*FROM restaurant_summary;


/*
CONCLUSION - Sales Analysis Overview:

1. Overall KPIs: Total revenue across the dataset is ~$9.56M, aggregated from 
   38,047 orders, confirming the dataset scale matches the cleaned data.

2. Quarter-wise Trend: Revenue and profit are fairly stable across all four 
   quarters (~$2.35M-$2.47M revenue each), with Q3 slightly ahead. No strong 
   seasonal swing at the quarterly level.

3. Month-wise Trend: August leads in revenue (~$860K) and February is lowest 
   (~$739K), but the spread across months is narrow (~$120K difference), 
   indicating a mild rather than dramatic seasonal pattern.

4. City-wise Performance: Singapore, Mumbai, New York, London, and Sydney all 
   generate similar revenue (~$1.87M-$1.92M each), showing balanced performance 
   across cities. The "Unknown" category is much lower ($96K), consistent with 
   it being a small/missing-data segment rather than a real city.

5. Restaurant & Cuisine Performance: Fast Food leads slightly in both revenue 
   and order volume, followed closely by Cloud Kitchen, Cafe, and Restaurant — 
   differences are minor (~5% spread). Similarly, Indian cuisine ranks first in 
   revenue and orders, with Mexican, Chinese, and Italian close behind.

6. Order Volume: Order counts by city and restaurant type mirror the revenue 
   rankings closely, confirming that higher revenue is driven by higher order 
   volume rather than higher per-order value.

7. Profit Margin: Profit margin is consistent across cities (~35-36%) and 
   restaurant types (~35-36%), showing no city or restaurant type has a 
   meaningfully different cost/profitability structure.

Overall Insight: Business performance is well-balanced across cities, restaurant 
types, and cuisines — no single segment dominates or underperforms significantly. 
This uniformity is consistent with the pattern seen throughout the EDA phase, 
where categorical variables showed minimal differentiation in outcomes.
*/
  