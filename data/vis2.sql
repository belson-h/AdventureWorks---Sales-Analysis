USE AdventureWorks2025


SELECT * FROM Production.ProductCategory
SELECT * FROM Production.ProductSubcategory
SELECT * FROM Production.Product
SELECT * FROM Sales.SalesOrderDetail


--Opt1:
SELECT 
    pc.Name AS CategoryName,
    CAST(ROUND(SUM(sod.LineTotal), 0) AS BIGINT) AS CategoryRevenue

FROM Production.ProductCategory pc
INNER JOIN Production.ProductSubcategory psc ON pc.ProductCategoryID = psc.ProductCategoryID
INNER JOIN Production.Product p ON psc.ProductSubcategoryID = p.ProductSubcategoryID
INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY pc.Name
ORDER BY CategoryRevenue DESC


--Opt2:
SELECT
    pc.Name AS CategoryName,
    CAST(ROUND(SUM(sod.LineTotal), 0) AS BIGINT) AS CategoryRevenue
FROM Sales.SalesOrderDetail sod
LEFT JOIN Production.Product p ON sod.ProductID = p.ProductID
LEFT JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY CategoryRevenue DESC


--Opt1 & Opt2 gives same result