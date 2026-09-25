/*
=========================================================
Project Name - Automated Sales Reporting & Analysis 
File Name- 02_data_validation.sql
Database - SQL (postgresql 18)

=========================================================
*/

--=======================================================
-- Check Row Count 
SELECT COUNT(*) FROM sales_data;
-- so, total rows: 37957

-- Check Null Values In All Numerical Columns
CREATE OR REPLACE PROCEDURE check_null_values(col TEXT) -- Create stroed procedure 
LANGUAGE plpgsql 
AS $$
DECLARE 
v_sql TEXT ; 
total_count INT;
BEGIN
v_sql:='SELECT COUNT(*) FROM sales_data WHERE '||col||' IS NULL';
EXECUTE 
v_sql INTO total_count;

RAISE NOTICE ' Null Values In % :- %',col,total_count;
END ;
$$

/*
Call Procedure for numerical columns - Customer_Age, Delivery_Distance_KM,
Delivery_Time_Min, Order_Value_USD, Item_Count, Customer_Rating,
Revenue_USD, Profit_USD, Quarter, Churn_Risk
*/
-- for Customer_Age
call check_null_values('Customer_Age')
-- for Order_Value_USD
call check_null_values('Order_Value_USD')
-- for Delivery_Distance_KM
call check_null_values('Delivery_Distance_KM')
-- for Delivery_Time_Min
call check_null_values('Delivery_Time_Min')
-- for Item_Count
call check_null_values('Item_Count')
-- for Customer_Rating
call check_null_values('Customer_Rating')
-- for Revenue_USD
call check_null_values('Revenue_USD')
-- for Profit_USD
call check_null_values('Profit_USD')

-- for Quarter
call check_null_values('Quarter')

-- for Churn_Risk
call check_null_values('Churn_Risk')

/* 
Range Validation In Numerical Columns
Numerical Columns :- Customer_Age, Delivery_Distance_KM, Delivery_Time_Min,
Order_Value_USD, Item_Count, Customer_Rating, Revenue_USD, Profit_USD,
Quarter, Churn_Risk
*/
CREATE OR REPLACE PROCEDURE range_validation(col TEXT)
LANGUAGE plpgsql
AS $$
DECLARE 
v_sql1 TEXT;
v_sql2 TEXT;
min_values INT;
max_values INT;
BEGIN
   -- Build dynamic SQL for MIN and MAX
  v_sql1='SELECT MIN(' ||col||') FROM sales_data';
  v_sql2='SELECT MAX('||col||') FROM sales_data';
  
   -- Execute separately
  EXECUTE v_sql1 INTO min_values;
  EXECUTE v_sql2 INTO max_values; 
RAISE NOTICE '% | Range Validation | MIN:- %, MAX :- %',col,min_values,max_values;
END;
$$

-- CALL PROCEDURE FOR RANGE VALIDATION

-- for customer_age
CALL range_validation('Customer_Age')

-- for Delivery_Distance_KM
CALL range_validation('Delivery_Distance_KM')

-- for Delivery_Time_Min
CALL range_validation('Delivery_Time_Min')

-- for Order_Value_USD
CALL range_validation('Item_Count')

-- for Customer_Rating
CALL range_validation('Customer_Rating')

-- for Revenue_USD
CALL range_validation('Revenue_USD')

-- for Profit_USD
CALL range_validation('Profit_USD')

--for Quarter
CALL range_validation('Quarter')

--for Churn_Risk
CALL range_validation('Churn_Risk')

/*
CONCLUSION - Range Validation:
All numerical columns show logically valid ranges: Customer_Age (18-74), 
Customer_Rating (1-5), and Quarter (1-4) match their expected scales exactly, 
while Delivery_Distance_KM, Delivery_Time_Min, Revenue_USD, and Churn_Risk show 
no negative or out-of-range values. Profit_USD includes negative values (min: -20), 
which is business-valid since some orders can result in a loss. Item_Count and 
Order_Value_USD still need to be validated to complete this check.
*/

/*
Business Logic Violations Check 
Purpose: Confirm that no business rules are being violated — check for negative values where they shouldn't exist, 
and verify that ratings/scales fall within their defined ranges.
*/

CREATE OR REPLACE PROCEDURE logic_violations (col TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
v_sql TEXT;
total_count INT;
BEGIN
v_sql='SELECT COUNT(*)  FROM sales_data WHERE '||col|| '< 0';
EXECUTE v_sql INTO total_count;

RAISE NOTICE '% |Business Logic Violations Check| %',col,total_count;

END;
$$

-- CALL PROCEDURE 
-- for Customer_Age
CALL logic_violations('Customer_Age')

--for Delivery_Distance_KM
CALL logic_violations('Delivery_Distance_KM')

-- for Delivery_Time_Min
CALL logic_violations('Delivery_Time_Min')

-- for Order_Value_USD
CALL logic_violations('Order_Value_USD')

-- for Item_Count
CALL logic_violations('Item_Count')

-- for Customer_Rating
CALL logic_violations('Customer_Rating')

-- for Revenue_USD
CALL logic_violations('Revenue_USD')
-- for Profit_USD
CALL logic_violations('Profit_USD')

-- for Quarter
CALL logic_violations('Quarter')

--for Churn_Risk
CALL logic_violations('Churn_Risk')

/*
CONCLUSION - Business Logic Violations Check:
All numerical columns show zero negative-value violations except Profit_USD, 
which has 3,509 rows (~9.2% of total) with negative values. This is business-valid 
rather than a data quality issue, as some orders can legitimately result in a loss. 
No further correction needed for this column.
*/
