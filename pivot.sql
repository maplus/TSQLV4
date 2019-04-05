USE AdventureWorks2017;

-- PIVOT static
SELECT PVT.CountryRegionCode,
       PVT.Northwest,
       PVT.Northeast,
       PVT.Southwest,
       PVT.Southeast,
       PVT.Central/*,
	   pvt.test*/
FROM
(
    SELECT T.CountryRegionCode,
           T.Name
    FROM Sales.SalesOrderHeader H
        INNER JOIN Sales.SalesTerritory T
            ON H.TerritoryID = T.TerritoryID
    WHERE T.CountryRegionCode = 'US'
) AS P
PIVOT
(
    COUNT(P.Name)
    FOR P.Name IN (Northwest, Northeast, Southwest, Southeast, Central/*, test*/)
) AS PVT;


-- PIVOT dynamic
DECLARE @sql NVARCHAR(4000);
DECLARE @tmp_pivot TABLE
(
    TerritoryId INT NOT NULL PRIMARY KEY,
    CountryRegion NVARCHAR(20) NOT NULL,
    CountryRegionCode NVARCHAR(3) NOT NULL
);

INSERT INTO @tmp_pivot
(
    TerritoryId,
    CountryRegion,
    CountryRegionCode
)
SELECT TerritoryID,
       Name,
       CountryRegionCode
FROM Sales.SalesTerritory
GROUP BY TerritoryID,
         Name,
         CountryRegionCode;

SET @sql
    = N'SELECT'
      + SUBSTRING(
        (
            SELECT N', SUM(CASE WHEN t.TerritoryId = ' + CAST(TerritoryId AS NVARCHAR(3)) + N' THEN 1 ELSE 0 END) AS '
                   + QUOTENAME(CountryRegion) AS "*"
            FROM @tmp_pivot
            FOR XML PATH('')
        ),
        2,
        4000
                 ) + N' FROM Sales.SalesOrderHeader h ' + N' INNER JOIN Sales.SalesTerritory t '
      + N' ON h.TerritoryId = t.TerritoryId; ';

PRINT @sql;

EXEC (@sql);

-- @sql
/*
SELECT SUM(   CASE
                  WHEN t.TerritoryID = 1 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Northwest],
       SUM(   CASE
                  WHEN t.TerritoryID = 2 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Northeast],
       SUM(   CASE
                  WHEN t.TerritoryID = 3 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Central],
       SUM(   CASE
                  WHEN t.TerritoryID = 4 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Southwest],
       SUM(   CASE
                  WHEN t.TerritoryID = 5 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Southeast],
       SUM(   CASE
                  WHEN t.TerritoryID = 6 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Canada],
       SUM(   CASE
                  WHEN t.TerritoryID = 7 THEN
                      1
                  ELSE
                      0
              END
          ) AS [France],
       SUM(   CASE
                  WHEN t.TerritoryID = 8 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Germany],
       SUM(   CASE
                  WHEN t.TerritoryID = 9 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Australia],
       SUM(   CASE
                  WHEN t.TerritoryID = 10 THEN
                      1
                  ELSE
                      0
              END
          ) AS [United Kingdom]
FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesTerritory t
        ON h.TerritoryID = t.TerritoryID;
*/
