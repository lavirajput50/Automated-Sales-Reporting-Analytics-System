/*
=========================================================
Project Name - Automated Sales Reporting & Analysis 
File Name- 05_vendor_analysis.sql
Database - SQL (postgresql 18)

=========================================================
*/

/*
01:- Restaurant_Type Wise Full Performance Summary
For each Restaurant_Type, calculate the total revenue, 
total profit, total number of orders, 
and the average customer rating. 
Compare performance across different restaurant types to identify 
which segments are most profitable and deliver the highest satisfaction.
*/

WITH restaurant_summary AS
(
SELECT Restaurant_Type,
SUM(Revenue_USD) as Total_Revenue,
SUM(Profit_USD) as Total_Profit,
COUNT(Order_ID) as Number_Of_Orders,
AVG(Customer_Rating) as Customer_Rating
FROM sales_data
GROUP BY Restaurant_Type 
)
SELECT*FROM restaurant_summary 
ORDER BY Total_Revenue DESC;

/* 
02:-Cuisine_Type Wise Full Performance Summary
For each Cuisine_Type, calculate the total revenue, 
total profit, total number of orders, 
and the average customer rating. 
Compare performance across different restaurant types to identify 
which segments are most profitable and deliver the highest satisfaction.
*/
WITH Cuisine_summary AS
(
SELECT Cuisine_Type,
SUM(Revenue_USD) as Total_Revenue,
SUM(Profit_USD) as Total_Profit,
COUNT(Order_ID) as Number_Of_Orders,
AVG(Customer_Rating) as Customer_Rating
FROM sales_data
GROUP BY Cuisine_Type 
)
SELECT*FROM Cuisine_summary 
ORDER BY Total_Revenue DESC;

/*
03:- Restaurant_Type + Cuisine_Type Combination Analysis
Identify which combination of Restaurant_Type and Cuisine_Type generates the highest revenue. 
Perform a cross-analysis grouped by both attributes to compare revenue contributions across different restaurant–cuisine pairs.
*/
WITH restaurant_cuisine_cross_analysis AS
(SELECT Restaurant_Type,
Cuisine_Type,
Total_Revenue
FROM (
SELECT Restaurant_Type,
Cuisine_Type,
SUM(Revenue_USD) as Total_Revenue,
RANK()OVER(PARTITION BY Cuisine_Type 
ORDER BY SUM(Revenue_USD)DESC) as rnk
FROM sales_data
GROUP BY Restaurant_Type,Cuisine_Type
) sub
WHERE rnk=1)
SELECT*
FROM restaurant_cuisine_cross_analysis;

/*
04:-Best & Worst Performing Combinations (Ranking)
Using RANK(), find the Top 5 and Bottom 5 Restaurant_Type + Cuisine_Type combinations based on revenue. 
Perform a cross-analysis to compare which pairs generate the highest and lowest revenue contributions.
*/
WITH summary_top_bottom AS (
SELECT Restaurant_Type,
Cuisine_Type,
SUM(Revenue_USD) as Total_Revenue,
RANK()OVER(ORDER BY Sum(Revenue_USD)DESC) as rnk_desc,
RANK()OVER(ORDER BY SUM(Revenue_USD)ASC) as rnk_asc
FROM sales_data
GROUP BY Restaurant_Type,Cuisine_Type
)
SELECT 'Top 5'as category, Restaurant_Type, Cuisine_Type,
Total_Revenue FROM summary_top_bottom WHERE rnk_desc<=5
UNION ALL
SELECT 'Bottom 5' as category, Restaurant_Type, Cuisine_Type,
Total_Revenue FROM summary_top_bottom WHERE rnk_asc<=5

/*
05: Complaint Rate by Restaurant_Type
Which Restaurant_Type attracts the highest percentage of customer complaints?
*/

SELECT Restaurant_Type, 
(SUM(CASE WHEN Complaint_Flag = 'Complaint' THEN 1 ELSE 0 END )*100.0 /
COUNT(*))as Highest_complaint
FROM sales_data
GROUP BY Restaurant_Type
ORDER BY Highest_complaint DESC
LIMIT 1;

/*
06:- Profit Margin by Restaurant_Type & Cuisine_Type
Which Restaurant_Type is the most profitable in terms of margin (Profit ÷ Revenue × 100), 
rather than just total revenue?
*/
SELECT Restaurant_Type,
(SUM(Profit_USD)*100.0/SUM(Revenue_USD)) as Profit_margin
FROM sales_data
GROUP BY Restaurant_Type
ORDER BY Profit_margin DESC;

/*
