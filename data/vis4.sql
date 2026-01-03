USE AdventureWorks2025


SELECT * FROM Sales.SalesOrderHeader


SELECT
    YEAR(orderDate) AS OrderYear,
    CAST(ROUND(SUM(SubTotal), 0) AS BIGINT) AS TotalYearSales,
    COUNT(SalesOrderID) AS TotalOrders
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear ASC