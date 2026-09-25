-- Database Name :- SQL 
-- Now, i creating a table (sales_data)

CREATE TABLE sales_data (
    Order_ID              VARCHAR(20) PRIMARY KEY,
    Customer_Age          INTEGER,
    Customer_Type         VARCHAR(20),
    Restaurant_Type       VARCHAR(30),
    Cuisine_Type          VARCHAR(30),
    Delivery_Distance_KM  FLOAT,
    Delivery_Time_Min     FLOAT,
    Order_Value_USD       FLOAT,
    Item_Count            INTEGER,
    Weather_Condition     VARCHAR(20),
    Traffic_Level         VARCHAR(20),
    Customer_Rating       FLOAT,
    Complaint_Flag        VARCHAR(20),
    Refund_Flag           VARCHAR(20),
    Revenue_USD           FLOAT,
    Profit_USD            FLOAT,
    City                  VARCHAR(50),
    Month                 VARCHAR(20),
    Quarter               INTEGER,
    Churn_Risk            FLOAT
);

-- check data after import 
SELECT Count(*) FROM sales_data;
-- so, Total rows: 38047

 

 

