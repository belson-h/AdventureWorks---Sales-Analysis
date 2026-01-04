USE AdventureWorks2025

--Product portfolio analysis

--Sales info
SELECT * FROM Sales.SalesOrderHeader 
SELECT * FROM Sales.SalesOrderDetail

--Product and cost info
SELECT * FROM Production.Product
SELECT * FROM Production.ProductSubcategory
SELECT * FROM Production.ProductCategory

--Table - sales and cost overview
SELECT
    sod.ProductID,
    p.Name AS ProductName,
    pc.Name AS Category,
    psc.Name AS Subcategory,
    SUM(sod.OrderQty) AS TotalQuantity,
    SUM(sod.LineTotal) AS TotalSales,
    SUM(sod.OrderQty * p.StandardCost) AS TotalCost,
    SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost) AS GrossMargin,
    (SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost)) 
        / NULLIF(SUM(sod.LineTotal), 0) AS MarginPercent,
    (SUM(sod.LineTotal) / NULLIF(SUM(sod.OrderQty), 0)) AS AvgRevenuePerUnit
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p
    ON sod.ProductID = p.ProductID
LEFT JOIN Production.ProductSubcategory psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc 
    ON psc.ProductSubcategoryID = pc.ProductCategoryID
WHERE p.DiscontinuedDate IS NULL
GROUP BY 
    sod.ProductID,
    p.Name,
    pc.Name,
    psc.Name
ORDER BY TotalSales DESC;


--Vis 8: Winners/losers-products

WITH ProductPerformance AS (
    SELECT
        sod.ProductID,
        p.Name AS ProductName,
        pc.Name AS Category,
        psc.Name AS Subcategory,
        SUM(sod.OrderQty) AS TotalQuantity,
        SUM(sod.LineTotal) AS TotalSales,
        SUM(sod.OrderQty * p.StandardCost) AS TotalCost,
        SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost) AS GrossMargin,
        (SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost))
            / NULLIF(SUM(sod.LineTotal), 0) AS MarginPercent
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p
        ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory psc
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc
        ON psc.ProductCategoryID = pc.ProductCategoryID
    WHERE p.DiscontinuedDate IS NULL
    GROUP BY
        sod.ProductID,
        p.Name,
        pc.Name,
        psc.Name
)

SELECT 
    ProductID,
    ProductName,
    Category,
    Subcategory,
    TotalQuantity,
    TotalSales,
    GrossMargin,
    MarginPercent,

    CASE
        WHEN TotalSales >= (SELECT AVG(TotalSales) FROM ProductPerformance)
        AND MarginPercent >= (SELECT AVG(MarginPercent) FROM ProductPerformance)
            THEN 'Winner'
        
        WHEN GrossMargin < 0
        OR TotalSales < (SELECT AVG(TotalSales) FROM ProductPerformance)
            THEN 'Loser'
        
        ELSE 'Middle'
    END AS ProductStatus

FROM ProductPerformance
ORDER BY TotalSales DESC;


--Vis 9: Exit/Invest-analysis

WITH ProductPerformance AS (
    SELECT
        sod.ProductID,
        p.Name AS ProductName,
        pc.Name AS Category,
        psc.Name AS Subcategory,
        SUM(sod.OrderQty) AS TotalQuantity,
        SUM(sod.LineTotal) AS TotalSales,
        SUM(sod.OrderQty * p.StandardCost) AS TotalCost,
        SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost) AS GrossMargin,
        (SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost))
            / NULLIF(SUM(sod.LineTotal), 0) AS MarginPercent
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p
        ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory psc
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc
        ON psc.ProductCategoryID = pc.ProductCategoryID
    WHERE p.DiscontinuedDate IS NULL
    GROUP BY
        sod.ProductID,
        p.Name,
        pc.Name,
        psc.Name
)
SELECT 
    ProductID,
    ProductName,
    Category,
    Subcategory,
    TotalQuantity,
    TotalSales,
    GrossMargin,
    MarginPercent,

    CASE
        WHEN GrossMargin < 0
            THEN 'Exit'
        
        WHEN TotalSales < (SELECT AVG(TotalSales) FROM ProductPerformance)
            AND MarginPercent < (SELECT AVG(MarginPercent) FROM ProductPerformance)
            THEN 'Exit'

        WHEN TotalSales >= (SELECT AVG(TotalSales) FROM ProductPerformance)
            AND MarginPercent >= (SELECT AVG(MarginPercent) FROM ProductPerformance)
            THEN 'Invest'
        
        ELSE 'Keep/Opt'
    END AS Recommendation

FROM ProductPerformance
ORDER BY Recommendation, TotalSales DESC;


--Vis 10: High qty, Low rev

WITH ProductPerformance AS (
    SELECT
        sod.ProductID,
        p.Name AS ProductName,
        pc.Name AS Category,
        psc.Name AS Subcategory,
        SUM(sod.OrderQty) AS TotalQuantity,
        SUM(sod.LineTotal) AS TotalSales,
        SUM(sod.OrderQty * p.StandardCost) AS TotalCost,
        SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost) AS GrossMargin,
        (SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost))
            / NULLIF(SUM(sod.LineTotal), 0) AS MarginPercent,
        (SUM(sod.LineTotal) / NULLIF(SUM(sod.OrderQty), 0)) AS AvgRevenuePerUnit
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p
        ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory psc
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc
        ON psc.ProductCategoryID = pc.ProductCategoryID
    WHERE p.DiscontinuedDate IS NULL
    GROUP BY
        sod.ProductID,
        p.Name,
        pc.Name,
        psc.Name
)

SELECT
    ProductID,
    ProductName,
    Category,
    Subcategory,
    TotalQuantity,
    TotalSales,
    AvgRevenuePerUnit,

    CASE
        WHEN TotalQuantity >= (SELECT AVG(TotalQuantity) FROM ProductPerformance)
         AND AvgRevenuePerUnit <= (SELECT AVG(AvgRevenuePerUnit) FROM ProductPerformance)
            THEN 'High qty / Low rev'
        ELSE 'Normal'
    END AS QuantityRevenueFlag

FROM ProductPerformance
WHERE
    TotalQuantity >= (SELECT AVG(TotalQuantity) FROM ProductPerformance)
    AND AvgRevenuePerUnit <= (SELECT AVG(AvgRevenuePerUnit) FROM ProductPerformance)
ORDER BY TotalQuantity DESC;