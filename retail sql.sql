select * from dataset;
CREATE OR REPLACE VIEW retail_cleaned AS
SELECT
    Order_ID,
    Order_Date,
    COALESCE(NULLIF(TRIM(Region), ''), 'Unknown') AS Region,
    Category,
    Sub_Category,
    Season,
    Quantity_Sold,
    COALESCE(Stock_Qty, 0) AS Stock_Qty,
    Inventory_Days,
    Unit_Price,
    Unit_Cost,
    COALESCE(Discount, 0) AS Discount,
    Revenue,
    Cost,
    Profit,
    Profit_Margin_Pct
FROM dataset;
-- 2. Profit margin by category
SELECT
    Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Cost), 2) AS Total_Cost,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100, 2) AS Profit_Margin_Pct
FROM retail_cleaned
GROUP BY Category
ORDER BY Profit_Margin_Pct DESC;
-- 3. Profit margin by sub-category
SELECT
    Category,
    Sub_Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Cost), 2) AS Total_Cost,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100, 2) AS Profit_Margin_Pct
FROM retail_cleaned
GROUP BY Category, Sub_Category
ORDER BY Profit_Margin_Pct DESC;
-- 4. Identify profit-draining categories
-- Low profit margin and/or high inventory days
SELECT
    Category,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100, 2) AS Profit_Margin_Pct,
    ROUND(AVG(Inventory_Days), 2) AS Avg_Inventory_Days
FROM retail_cleaned
GROUP BY Category
HAVING
    SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100 < 20
    OR AVG(Inventory_Days) > 40
ORDER BY Profit_Margin_Pct ASC;

-- 5. Slow-moving products
SELECT
    Category,
    Sub_Category,
    SUM(Quantity_Sold) AS Units_Sold,
    ROUND(AVG(Inventory_Days), 2) AS Avg_Inventory_Days,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_cleaned
GROUP BY Category, Sub_Category
HAVING AVG(Inventory_Days) >= 40
ORDER BY Avg_Inventory_Days DESC;

-- 6. Overstocked products
SELECT
    Category,
    Sub_Category,
    ROUND(AVG(Stock_Qty), 2) AS Avg_Stock_Qty,
    ROUND(AVG(Inventory_Days), 2) AS Avg_Inventory_Days,
    SUM(Quantity_Sold) AS Units_Sold,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_cleaned
GROUP BY Category, Sub_Category
HAVING
    AVG(Stock_Qty) >= 100
    AND AVG(Inventory_Days) >= 35
ORDER BY Avg_Stock_Qty DESC;

-- 7. Seasonal product behavior
SELECT
    Season,
    Category,
    SUM(Quantity_Sold) AS Units_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Pct
FROM retail_cleaned
GROUP BY Season, Category
ORDER BY Season, Total_Revenue DESC;
