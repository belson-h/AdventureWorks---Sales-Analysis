USE AdventureWorks2025


SELECT * FROM Sales.SalesTerritory
SELECT * FROM Sales.SalesOrderHeader
SELECT * FROM Sales.Customer
SELECT * FROM Sales.Store

--AOV per region and customer type

--Opt1 - needs sorting AOV per region and customer type when creating vis

SELECT
    CONCAT(st.Name, ', ', st.CountryRegionCode) AS Region,
    CASE
        WHEN s.BusinessEntityID IS NULL THEN 'Individual'
        ELSE 'Store'
    END AS CustomerType,
    SUM(soh.SubTotal) / COUNT(DISTINCT soh.SalesOrderID) AS AverageOrderValue
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.Customer c 
    ON soh.CustomerID = c.CustomerID
LEFT JOIN Sales.Store s
    ON c.StoreID = s.BusinessEntityID
INNER JOIN Sales.SalesTerritory st
    ON c.TerritoryID = st.TerritoryID
GROUP BY 
    st.Name, 
    st.CountryRegionCode,
    CASE
        WHEN s.BusinessEntityID IS NULL THEN 'Individual'
        ELSE 'Store'
    END
ORDER BY AverageOrderValue DESC;



--Opt2 - with CTE and window function to pre-sort AOV per region and customer type

WITH AOV AS (
    SELECT
        CONCAT(st.Name, ', ', st.CountryRegionCode) AS Region,
        CASE
            WHEN s.BusinessEntityID IS NULL THEN 'Individual'
            ELSE 'Store'
        END AS CustomerType,
        SUM(soh.SubTotal) / COUNT(DISTINCT soh.SalesOrderID) AS AverageOrderValue
    FROM Sales.SalesOrderHeader soh
    INNER JOIN Sales.Customer c
        ON soh.CustomerID = c.CustomerID
    LEFT JOIN Sales.Store s
        ON c.StoreID = s.BusinessEntityID
    INNER JOIN Sales.SalesTerritory st
        ON c.TerritoryID = st.TerritoryID
    GROUP BY
        st.Name,
        st.CountryRegionCode,
        CASE
            WHEN s.BusinessEntityID IS NULL THEN 'Individual'
            ELSE 'Store'
        END
)
SELECT
    Region,
    CustomerType,
    CAST(ROUND(AverageOrderValue, 0) AS BIGINT) AS AverageOrderValue
FROM (
    SELECT
        *,
        AVG(AverageOrderValue) OVER (PARTITION BY Region) AS RegionAvg
    FROM AOV
) t
ORDER BY
    RegionAvg DESC,
    CustomerType;





