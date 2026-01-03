USE AdventureWorks2025


SELECT * FROM Sales.SalesTerritory
SELECT * FROM Sales.SalesOrderHeader
SELECT * FROM Sales.Customer


SELECT
    CONCAT(st.Name, ', ', st.CountryRegionCode) AS RegionNameCode,
    CAST(ROUND(SUM(soh.SubTotal), 0) AS BIGINT) AS TotalRegionSales,
    COUNT(DISTINCT c.CustomerID) AS UniqueCustomers
FROM Sales.SalesTerritory st
INNER JOIN Sales.SalesOrderHeader soh 
    ON st.TerritoryID = soh.TerritoryID
INNER JOIN Sales.Customer c 
    ON st.TerritoryID = c.TerritoryID
GROUP BY st.Name, st.CountryRegionCode
ORDER BY TotalRegionSales DESC;