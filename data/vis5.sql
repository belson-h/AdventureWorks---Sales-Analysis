USE AdventureWorks2025


SELECT * FROM Production.Product
SELECT * FROM Sales.SalesOrderDetail

-- Top 10 products

SELECT TOP 10
    p.ProductID,
    p.Name AS ProductName,
    CAST(ROUND(SUM(sod.LineTotal), 0) AS BIGINT) AS TotalProductSales
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalProductSales DESC;

