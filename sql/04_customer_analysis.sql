/*
=========================================================
Project Name - Automated Sales Reporting & Analysis 
File Name- 04_customer_analysis.sql
Database - SQL (postgresql 18)

=========================================================
*/

--01:- Customer_Type Wise Summary 
WITH customer_summary AS 
(
SELECT Customer_Type,
SUM(Revenue_USD) as Total_Revenue,
AVG(Order_Value_USD) as Avg_Order_Value,
AVG(Customer_Rating) as Avg_Raing,
COUNT(Order_ID) as Order_Count
FROM sales_data
GROUP BY Customer_Type
)
SELECT*FROM customer_summary;

--02:- Churn Risk By Customer_Type 
WITH churn_risk_summary AS 
(
SELECT Customer_Type,
AVG(Churn_Risk) AS average_churn_risk
FROM sales_data
GROUP BY Customer_Type
ORDER BY AVG(Churn_Risk) DESC
)
SELECT*FROM churn_risk_summary;

--03:- High-Value Customers Identification
-- Find the customers or orders with the highest order value or revenue, such as the Top 10 orders by order value.
WITH highest_summary AS (
    SELECT 
        order_id,
        customer_type,
        SUM(revenue_usd) AS total_revenue
    FROM sales_data
    GROUP BY order_id, customer_type
    ORDER BY total_revenue DESC
    LIMIT 10
)
SELECT *FROM highest_summary;
/*
04:- Customer Rating Distribution by Segment
Calculate the rating distribution for each Customer_Type, 
including the minimum, maximum, and average rating, 
and compare the satisfaction levels across different customer types.
*/

SELECT Customer_Type, 
MIN(Customer_Rating) as Min_Rating,
MAX(Customer_Rating)as Max_Rating,
AVG(Customer_Rating) as Avg_Rating
FROM sales_data
GROUP BY Customer_Type


--05: Age Group Wise Analysis (Bonus)
SELECT 
SUM(CASE WHEN Customer_Age>=18 AND Customer_Age<=25 THEN Revenue_USD END) as "(18-25)",
SUM(CASE WHEN Customer_Age>=26 AND Customer_Age<=35 THEN Revenue_USD END) as "(26-35)",
SUM(Case WHEN Customer_Age>=36 AND Customer_Age<=45 THEN Revenue_USD END) as "(36-45)",
SUM(CASE  WHEN Customer_Age>=46 AND Customer_Age<=55 THEN Revenue_USD END) as "(46-55)",
SUM(CASE WHEN Customer_Age>=56 AND Customer_Age<=65 THEN Revenue_USD END) as  "(56-65)",
SUM(CASE WHEN Customer_Age>=66 AND Customer_Age<=75  THEN Revenue_USD END) as "(66-75)'",
SUM(CASE WHEN Customer_Age>76 THEN Revenue_USD END) as "UPTO 76"
FROM sales_data

/*
06:- Complaint & Refund Rate by Customer_Type
Calculate the percentage of complaints and refunds for each Customer_Type.
*/
SELECT 
    customer_type,
    (SUM(CASE WHEN complaint_flag = 'Complaint' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS percentage_complaint,
    (SUM(CASE WHEN refund_flag = 'Refund' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS percentage_refund
FROM sales_data
GROUP BY customer_type;

/*
07:- Customer_Type Vs City Combination
Analyze which Customer_Type generates the highest revenue in each City 
using a cross-analysis grouped by Customer_Type and City.
*/
WITH cross_analysis AS 
(
SELECT Customer_Type, 
City, 
Total_Revenue FROM(SELECT Customer_Type, 
City,
SUM(Revenue_USD) as Total_Revenue,
RANK()OVER(PARTITION BY City ORDER BY SUM(Revenue_USD)DESC) as rnk
FROM sales_data
GROUP BY Customer_Type,City)
WHERE rnk=1)
SELECT*FROM cross_analysis;


/*
CONCLUSION - Customer Analysis Overview:

1. Customer_Type Summary: Revenue, average order value, average rating, and 
   order count are nearly identical across New, Returning, and Premium 
   customers (~$3.18M revenue each, ~152-154 avg order value, ~3.0 avg rating). 
   No customer segment significantly outperforms another.

2. Churn Risk: Average churn risk is nearly the same across all segments 
   (49.96-50.17), showing Customer_Type has no meaningful influence on churn 
   likelihood — consistent with earlier EDA findings.

3. High-Value Orders: The top 10 orders by value (~$499-500) are spread 
   across New, Returning, and Premium customers with no single segment 
   dominating high-value transactions.

4. Rating Distribution: Min (1), max (5), and average (~3.0) ratings are 
   identical across all customer types, indicating no difference in 
   satisfaction levels by segment.

5. Age Group Revenue: Revenue increases from the 18-25 bracket (~$1.32M) 
   up to the 46-55 bracket (~$1.75M), then declines in older brackets. 
   This suggests middle-aged customers (36-55) contribute the most revenue, 
   a mild but genuine pattern worth noting compared to the otherwise flat 
   trends seen elsewhere in this dataset.

6. Complaint & Refund Rates: Complaint rates (~9.8-10.0%) and refund rates 
   (~4.6-4.8%) are nearly identical across all customer types, confirming 
   no segment is disproportionately dissatisfied.

7. Customer_Type vs City: The top-revenue customer type varies by city 
   (e.g., Returning leads in London/Singapore/Sydney, New leads in Mumbai, 
   Premium leads in New York), but the revenue differences are modest — 
   this is more a ranking curiosity than a strong business signal, given 
   how close overall segment performance is.

Overall Insight: Customer_Type has minimal influence on revenue, ratings, 
churn, or complaint behavior — reinforcing the dataset-wide pattern of 
independence. The one mild, genuine signal is the age-group revenue trend, 
where middle-aged customers (36-55) contribute disproportionately more revenue.
*/

