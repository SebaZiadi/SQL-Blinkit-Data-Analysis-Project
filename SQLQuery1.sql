Select * from blinkit_data

-- No. rows
select count(*) from blinkit_data 

-------------------- CLEANING THE DATA --------------------
UPDATE blinkit_data 
SET Item_Fat_Content =  --column name 
CASE    -- similar to IF ELSE satement 
WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat' 
WHEN Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END

-- to check if values actually changed:
Select DISTINCT (Item_Fat_Content) FROM blinkit_data


-------------------- Business Requiremants --------------------

---------------------------------------------------------------
-------------------- KPI's Requiremants -----------------------
------ 1. Total Sales ------
-- using CAST to get a 2 decimal no
SELECT CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10, 2) )
AS Total_Sales_Millions FROM blinkit_data

-- to get the total sales for 'Low Fat' using filter condition:
SELECT CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10, 2) )
AS Total_Sales_Millions FROM blinkit_data
WHERE (Item_Fat_Content) = 'Low Fat' 

------ 2. Average Sales ------
-- using CAST to get a round value
SELECT CAST(AVG (Total_Sales) AS DECIMAL(10, 0)) AS AVG_Sales FROM blinkit_data 

------ 3. Number of Items ------
SELECT COUNT(*) AS Number_Of_Items FROM blinkit_data

-- no of items in a particular yaer:
SELECT COUNT(*) AS No_Of_Items FROM blinkit_data
WHERE Outlet_Establishment_Year = 2022

------ 4. Average Rating ------
SELECT CAST(AVG(Rating) AS DECIMAL (10, 2)) AS AVG_Rating FROM blinkit_data

---------------------------------------------------------------
-------------------- Granular Requiremants --------------------
------ 1. Total Sales by Fat Content ------
SELECT Item_Fat_Content, CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales_By_Fat
FROM blinkit_data
GROUP BY Item_Fat_Content
ORDER BY Total_Sales_By_Fat DESC

--- to Emerge the work at the top with this quesry:
SELECT Item_Fat_Content, 
		CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales_By_Fat, 
		CAST(AVG (Total_Sales) AS DECIMAL(10, 0)) AS AVG_Sales, 
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL (10, 2)) AS AVG_Rating
FROM blinkit_data
GROUP BY Item_Fat_Content
ORDER BY Total_Sales_By_Fat DESC


--- to Emerge the work at the top with this quesry:
SELECT Item_Fat_Content, 
		CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales_By_Fat, 
		CAST(AVG (Total_Sales) AS DECIMAL(10, 0)) AS AVG_Sales, 
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL (10, 2)) AS AVG_Rating
FROM blinkit_data
GROUP BY Item_Fat_Content
ORDER BY Total_Sales_By_Fat DESC

-- using a condition 
SELECT Item_Fat_Content, 
		CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales_By_Fat, 
		CAST(AVG (Total_Sales) AS DECIMAL(10, 0)) AS AVG_Sales, 
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL (10, 2)) AS AVG_Rating
FROM blinkit_data
WHERE Outlet_Establishment_Year = 2020
GROUP BY Item_Fat_Content
ORDER BY Total_Sales_By_Fat DESC

------ 2. Total Sales by Item Type ------
SELECT Item_Type, 
		CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales_By_Fat, 
		CAST(AVG (Total_Sales) AS DECIMAL(10, 0)) AS AVG_Sales, 
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL (10, 2)) AS AVG_Rating
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales_By_Fat DESC

-- only retrive the top 5 best sellers :
SELECT TOP 5 Item_Type, 
		CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales_By_Fat, 
		CAST(AVG (Total_Sales) AS DECIMAL(10, 0)) AS AVG_Sales, 
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL (10, 2)) AS AVG_Rating
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales_By_Fat ASC


------ 3. Fat Content by Outlet for Total Sales ------
SELECT Outlet_Location_Type, Item_Fat_Content, 
		CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales_By_Fat, 
		CAST(AVG (Total_Sales) AS DECIMAL(10, 0)) AS AVG_Sales, 
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL (10, 2)) AS AVG_Rating
FROM blinkit_data
GROUP BY Outlet_Location_Type, Item_Fat_Content
ORDER BY Total_Sales_By_Fat ASC

-- to have 'Location' at rows, and 'fat' in columns
SELECT Outlet_Location_Type, 
       ISNULL([Low Fat], 0) AS Low_Fat, 
       ISNULL([Regular], 0) AS Regular
FROM 
(
    SELECT Outlet_Location_Type, Item_Fat_Content, 
           CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT 
(
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;

------ 4. Total Sales by Outlet Establishment ------
SELECT Outlet_Establishment_Year, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year

---------------------------------------------------------------
-------------------- Chart’s Requiremants ---------------------
------ 1. Percentage of Sales by Outlet Size ------
SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

------ 2. Sales by Outlet Location ------
SELECT Outlet_Location_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC

------ 3. All Metrics by Outlet Type ------
SELECT Outlet_Type, 
CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
		CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
		CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC
