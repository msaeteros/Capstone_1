USE sample_sales;

-- 1. What is total revenue overall for sales in the assigned territory, plus the start date and end date
-- that tell you what period the data covers?

SELECT
    SUM(revenue) AS Total_Revenue,
    MIN(sale_date) AS Start_Date,
    MAX(sale_date) AS End_Date
FROM (
    SELECT
        Store_Sales.Sale_Amount AS revenue,
        Store_Sales.Transaction_Date AS sale_date
    FROM Store_Sales 
    JOIN Store_Locations sl
        ON Store_Sales.Store_ID = sl.StoreId
    WHERE sl.State = 'Maine'

    UNION ALL

    SELECT
        Online_Sales.SalesTotal AS revenue,
        Online_Sales.Date AS sale_date
    FROM Online_Sales 
    WHERE Online_Sales.ShiptoState = 'Maine'
) AS Maine_Sales;

-- 2. What is the revenue breakdown by year and month for the sales territory 

SELECT YEAR(sale_date) AS Year_Sales,
	MONTHNAME(sale_date) AS Month_Sales,
    SUM(total_revenue) AS Monthly_Revenue
FROM (

-- Online Sales 

SELECT SalesTotal AS total_revenue,
		DATE AS sale_date 
	FROM Online_Sales
    WHERE ShiptoState ='Maine'
    
    UNION ALL 
    
-- Store_Sales 

SELECT
		store_Sales.Sale_Amount AS total_revenue,
		store_sales.Transaction_Date AS sale_date
FROM store_sales 
JOIN store_locations sl
    ON store_sales.Store_ID = sl.StoreId
WHERE sl.State = 'Maine'
)AS combineds_sales
	
GROUP BY YEAR(sale_date),
	MONTHNAME(sale_date)
    
ORDER BY Year_Sales,
	MIN(MONTH(sale_date));

-- 3. Provide a comparison of total revenue for the specific sales territory and the region it belongs to. 

SELECT
    'Maine' AS Comparison_Group,
    SUM(revenue) AS Total_Revenue
FROM (
    SELECT
        Online_Sales.SalesTotal AS Revenue,
        Online_Sales.ShiptoState AS state,
        m.Region AS region
    FROM Online_Sales
    JOIN Management m
        ON Online_Sales.ShiptoState = m.State

    UNION ALL

    SELECT
        Store_Sales.Sale_Amount AS revenue,
        sl.State AS state,
        m.Region AS region
    FROM Store_Sales
    JOIN Store_Locations sl
        ON Store_Sales.Store_ID = sl.StoreID
    JOIN Management m
        ON sl.State = m.State
) AS Combined_sales
WHERE state = 'Maine'

UNION ALL

-- Northeast Region total revenue
SELECT
    'Northeast Region' AS Comparison_Group,
    SUM(revenue) AS Total_Revenue
FROM (
    SELECT
        Online_Sales.SalesTotal AS Revenue,
        Online_Sales.ShiptoState AS state,
        m.Region AS region
    FROM Online_Sales
    JOIN Management m
        ON Online_Sales.ShiptoState = m.State

    UNION ALL

    SELECT
        Store_Sales.Sale_Amount AS revenue,
        sl.State AS state,
        m.Region AS region
    FROM Store_Sales
    JOIN Store_Locations sl
        ON Store_Sales.Store_ID = sl.StoreID
    JOIN Management m
        ON sl.State = m.State
) AS Combined_sales
WHERE region = 'Northeast';


-- 4. What is the number of transactions per month and average transaction amount by product
-- category for the sales territory?

SELECT
    YEAR(sale_date) AS 	Year_Sales,
    MONTHNAME(sale_date) AS Month_Sales,
    ic.Category AS Product_Category,
    COUNT(*) AS number_of_transactions,
   ROUND( AVG(transaction_amount),2) AS average_transaction_amount

FROM (
    -- Online sales
    SELECT
        os.Date AS sale_date,
        os.ShiptoState AS state,
        p.CategoryID AS product_category,
        os.SalesTotal AS transaction_amount

    FROM Online_Sales os
    JOIN Products p
        ON os.ProdNum = p.ProdNum

    UNION ALL

    -- In-store sales
    SELECT
        ss.Transaction_Date AS sale_date,
        sl.State AS state,
        p.CategoryID AS product_category,
        ss.Sale_Amount AS transaction_amount

    FROM Store_Sales ss
    JOIN Store_Locations sl
        ON ss.Store_ID = sl.StoreID
    JOIN Products p
        ON ss.Prod_Num = p.ProdNum

) AS Combined_Sales

JOIN Inventory_Categories ic 
	ON Combined_Sales.Product_Category = ic.CategoryID 

WHERE state = 'Maine'

GROUP BY
    YEAR(sale_date),
    MONTH(sale_date),
    MONTHNAME(sale_date),
    ic.Category

ORDER BY
    YEAR(sale_date),
    MONTH(sale_date),
    ic.Category;
    
-- 5. Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
-- ranking of online sales performance by state within an online sales territory? 

SELECT
    Store_Locations.StoreLocation,
    SUM(Store_Sales.Sale_Amount) AS Sales_Performance,

    RANK() OVER (
        ORDER BY SUM(Store_Sales.Sale_Amount) DESC
    ) AS InStore_Sales_Rank

FROM Store_Sales

JOIN Store_Locations
    ON Store_Sales.Store_ID = Store_Locations.StoreID

WHERE Store_Locations.State = 'Maine'

GROUP BY
    Store_Locations.StoreID,
    Store_Locations.StoreLocation

ORDER BY
    InStore_Sales_Rank;


/* RECOMMENDATION FOR NEXT QUARTER:
	For the next quarter, the business should focus on promoting Technology & Accessories because it generated the
    highest in total revenue among the product categories in Maine. 
    
     I was able to identify Technology & Accessories asthe top-performing category by analysising the 
     total_revenue, number of transcation, and Total_Revenue.
    
    Continuing to promot this product category will keep a strong sales performace. Additionally, the business can also 
    also consider bundling products with less-purchsed products which can encourage customers to explore and be curious 
    about other product categories.
    
*/

-- Top-Performing Product Category 

  SELECT
    ic.Category AS Product_Category,
    COUNT(*) AS Number_of_Transactions,
    SUM(transaction_amount) AS Total_Revenue

FROM (
    -- Online sales
    SELECT
        os.SalesTotal AS transaction_amount,
        os.ShiptoState AS state,
        p.CategoryID AS product_category
    FROM Online_Sales os
    JOIN Products p
        ON os.ProdNum = p.ProdNum

    UNION ALL

    -- In-store sales
    SELECT
        ss.Sale_Amount AS transaction_amount,
        sl.State AS state,
        p.CategoryID AS product_category
    FROM Store_Sales ss
    JOIN Store_Locations sl
        ON ss.Store_ID = sl.StoreID
    JOIN Products p
        ON ss.Prod_Num = p.ProdNum

) AS Combined_Sales

JOIN Inventory_Categories ic
    ON Combined_Sales.product_category = ic.CategoryID

WHERE state = 'Maine'

GROUP BY
    ic.Category

ORDER BY
    Total_Revenue DESC;      

    


		



    
            
