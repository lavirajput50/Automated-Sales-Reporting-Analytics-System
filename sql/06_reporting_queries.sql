/*
=========================================================
Project Name - Automated Sales Reporting & Analysis 
File Name- 06_reporting_queries.sql
Database - SQL (postgresql 18)

=========================================================
*/

--01:- Master Summary View
CREATE OR REPLACE VIEW vm_overall_summary AS
(
SELECT SUM(Revenue_USD) as total_revenue,
SUM(Profit_USD) as total_profit,
AVG(Order_Value_USD) as avg_order_value,
AVG(Customer_Rating) as avg_rating,
AVG(Churn_Risk) as avg_churn_risk
FROM sales_data
);

--02: City Performance View
CREATE OR REPLACE VIEW vm_city_performance AS
(
SELECT City, 
SUM(Revenue_USD) as total_revenue,
SUM(Profit_USD) as total_profit,
AVG(Order_Value_USD) as avg_order_value,
AVG(Customer_Rating) as avg_rating,
AVG(Churn_Risk) as churn_risk,
ROUND((SUM(Profit_USD)*100.0/SUM(Revenue_USD))::NUMERIC,2)  as profit_margin_pct
FROM sales_data
GROUP BY City
);

--03: Restaurant/Cuisine Performance View
CREATE OR REPLACE VIEW vm_restaurant_cuisine 
AS
(
SELECT Restaurant_Type,
Cuisine_Type,
SUM(Revenue_USD) as Total_Revenue,
ROUND((SUM(Profit_USD)*100.0/SUM(Revenue_USD)),2) as Profit_margin,
COUNT(Order_ID) as Orders,
ROUND((SUM(CASE WHEN Complaint_Flag='Complaint' THEN 1 ELSE 0 END)*100.0/COUNT(*)),2)as Complaint_Rate
FROM sales_data
GROUP BY Restaurant_Type,Cuisine_Type
);


--04: Time-Based Trend View 

CREATE OR REPLACE VIEW vm_montly_revenue_profit --  month wise 
AS (
SELECT Month,
SUM(Revenue_USD) as Revenue,
SUM(Profit_USD) as Profit
FROM sales_data 
GROUP BY Month
);

CREATE OR REPLACE VIEW vm_quarter_revenue_profit --  Quarter wise 
AS (
SELECT Quarter,
SUM(Revenue_USD) as Revenue,
SUM(Profit_USD) as Profit
FROM sales_data 
GROUP BY Quarter
);

--05: Customer Segment View
CREATE OR REPLACE VIEW customer_segment 
AS (
SELECT Customer_Type,
SUM(Revenue_USD) as Revenue,
AVG(Churn_Risk) as Avg_churn_risk,
ROUND((SUM(CASE WHEN Complaint_Flag= 'Complaint' THEN 1
ELSE 0 END)*100.0/COUNT(*)),2) as Complaint_Rate,
ROUND((SUM(CASE WHEN Refund_Flag='Refund' THEN 1
ELSE 0 END)*100.0/COUNT(*)),2) as Refund_Rate
FROM sales_data
GROUP BY Customer_Type
ORDER BY SUM(Revenue_USD) DESC
);




