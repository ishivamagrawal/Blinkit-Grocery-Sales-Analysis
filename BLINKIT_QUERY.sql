-- Create table
CREATE TABLE blinkit(
            Item_Fat_Content TEXT,	
            Item_Type TEXT,
            Item_MRP DECIMAL(5,2),	
            Outlet_Location_Type TEXT,	
            Outlet_Size TEXT,
            Outlet_Type TEXT,
            Item_Visibility REAL,
            Rating REAL,
            Item_Outlet_Sales REAL,	
            Total_Sales REAL
);

SELECT * FROM blinkit;

-- Check for inconsistent fat content labels
SELECT DISTINCT Item_Fat_Content
FROM blinkit;

-- Standardise: 'LF' and 'low fat' → 'Low Fat', 'reg' → 'Regular'
UPDATE blinkit
SET Item_Fat_Content = 'Low Fat'
WHERE Item_Fat_Content IN ('LF','low fat');

UPDATE blinkit 
SET Item_Fat_Content = 'Regular'
WHERE Item_Fat_Content = 'reg' ;

-- KPI 1: Total Sales Revenue
SELECT ROUND(CAST(SUM(Item_Outlet_Sales) AS NUMERIC),2) AS total_sales
FROM blinkit;

-- KPI 2: Average Sales per item
SELECT ROUND(CAST(AVG(Item_Outlet_Sales) AS NUMERIC),2) AS avg_sales
FROM blinkit;

-- KPI 3: Average customer rating
SELECT ROUND(CAST(AVG(rating) AS NUMERIC),2) AS avg_rating
FROM blinkit;

-- KPI 4: Total number of items
SELECT COUNT(*) AS total_items
FROM blinkit;

-- Q1: Sales by Fat Content — do customers prefer Low Fat?
SELECT Item_Fat_Content,
       ROUND(CAST(SUM(Item_Outlet_Sales) AS NUMERIC), 2) AS total_sales,
       COUNT(*) AS item_count,
       ROUND(CAST(AVG(Rating) AS NUMERIC), 2) AS avg_rating
FROM blinkit
GROUP BY Item_Fat_Content;

-- Q2: Which item types generate the most revenue?
SELECT item_type, 
       ROUND(CAST(SUM(Item_Outlet_Sales) AS NUMERIC),2) AS item_revenue,
	   COUNT(*) AS item_count
FROM blinkit
GROUP BY item_type
ORDER BY item_revenue DESC;

-- Q3: Sales performance by outlet size
SELECT outlet_size,
       ROUND(CAST(SUM(Item_Outlet_Sales) AS NUMERIC),2) AS outlet_sales,
	   ROUND(CAST(AVG(Item_Outlet_Sales) AS NUMERIC),2) AS avg_outlet_sales,
	   COUNT(*) AS outlet_count
FROM blinkit
GROUP BY outlet_size
ORDER BY outlet_sales DESC;

-- Q4: Which location tier performs best?
SELECT outlet_location_type,
       ROUND(CAST(SUM(Item_Outlet_Sales) AS NUMERIC),2) AS outlet_location_sales,
	   ROUND(CAST(AVG(rating) AS NUMERIC),2) AS avg_outlet_rating,
	   COUNT(*) AS outlet_count
FROM blinkit
GROUP BY outlet_location_type
ORDER BY outlet_location_sales DESC;

-- Q5: Sales by outlet type
SELECT outlet_type,
       ROUND(CAST(SUM(Item_Outlet_Sales) AS NUMERIC),2) AS outlet_type_sales,
	   ROUND(CAST(AVG(Item_Outlet_Sales) AS NUMERIC),2) AS avg_outlet_type,
	   COUNT(*) AS outlet_type_count
FROM blinkit
GROUP BY outlet_type
ORDER BY outlet_type_sales DESC;

-- Q6: Top 10 highest selling items by MRP range
SELECT
CASE
   WHEN item_mrp <50 THEN 'Budget (Under 50)'
   WHEN item_mrp BETWEEN 50 AND 100 THEN 'Mid (50-100)'
   WHEN item_mrp BETWEEN 100 AND 200 THEN 'Premium (100-200)'
   ELSE 'Luxury (200+)'
END AS price_range,
COUNT(*) AS item_count, item_type,
ROUND(CAST(SUM(Item_Outlet_Sales) AS NUMERIC),2) AS total_sales,
ROUND(CAST(AVG(rating) AS NUMERIC),2) AS avg_rating
FROM blinkit
GROUP BY price_range, item_type
ORDER BY total_sales DESC
LIMIT 10;

-- Q7: Best performing outlet type + location combo
SELECT outlet_location_type, outlet_type,
       ROUND(CAST(SUM(Item_Outlet_Sales) AS NUMERIC),2) AS total_sales,
	   ROUND(CAST(AVG(Item_Outlet_Sales) AS NUMERIC),2) AS avg_outlet_type,
	   ROUND(CAST(AVG(rating) AS NUMERIC),2) AS avg_rating
FROM blinkit
GROUP BY outlet_location_type, outlet_type
ORDER BY total_sales DESC
LIMIT 10;

-- Using Window Function
SELECT DISTINCT 
    outlet_location_type, 
    outlet_type,
    ROUND(CAST(SUM(Item_Outlet_Sales) OVER (PARTITION BY outlet_location_type, outlet_type) AS NUMERIC), 2) AS total_sales,
    ROUND(CAST(AVG(Item_Outlet_Sales) OVER (PARTITION BY outlet_location_type, outlet_type) AS NUMERIC), 2) AS avg_outlet_type,
    ROUND(CAST(AVG(rating) OVER (PARTITION BY outlet_location_type, outlet_type) AS NUMERIC), 2) AS avg_rating
FROM blinkit
ORDER BY total_sales DESC
LIMIT 10;
