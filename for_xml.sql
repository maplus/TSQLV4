USE AdventureWorks2017;
GO

SELECT Cust.CustomerID,
       OrderHeader.CustomerID,
       OrderHeader.SalesOrderID,
       OrderHeader.Status
FROM Sales.Customer Cust
    INNER JOIN Sales.SalesOrderHeader OrderHeader
        ON Cust.CustomerID = OrderHeader.CustomerID
FOR XML AUTO;

/*
<Cust CustomerID="29825">
  <OrderHeader CustomerID="29825" SalesOrderID="43659" Status="5" />
</Cust>
<Cust CustomerID="29672">
  <OrderHeader CustomerID="29672" SalesOrderID="43660" Status="5" />
</Cust>
...
*/


SELECT Cust.CustomerID,
       OrderHeader.CustomerID,
       OrderHeader.SalesOrderID,
       OrderHeader.Status
FROM Sales.Customer Cust
    INNER JOIN Sales.SalesOrderHeader OrderHeader
        ON Cust.CustomerID = OrderHeader.CustomerID
FOR XML PATH;

/*
<row>
  <CustomerID>2982529825</CustomerID>
  <SalesOrderID>43659</SalesOrderID>
  <Status>5</Status>
</row>
<row>
  <CustomerID>2967229672</CustomerID>
  <SalesOrderID>43660</SalesOrderID>
  <Status>5</Status>
</row>
...
*/


SELECT OrderHeader.CustomerID,
       OrderHeader.SalesOrderID,
       OrderHeader.Status
FROM Sales.Customer Cust
    INNER JOIN Sales.SalesOrderHeader OrderHeader
        ON Cust.CustomerID = OrderHeader.CustomerID
FOR XML RAW;

/*
<row CustomerID="29825" SalesOrderID="43659" Status="5" />
<row CustomerID="29672" SalesOrderID="43660" Status="5" />
...
*/

SELECT 1 AS TAG,
       NULL AS PARENT,
       C.CustomerID AS [Customer!1!CustomerID],
       C.PersonID AS [Customer!1!PersonID!ELEMENT],
       C.AccountNumber AS [Customer!1!AccountNumber!ELEMENT],
       NULL AS [Order!2!SalesOrderID],
       NULL AS [Order!2!Status!ELEMENT]
FROM Sales.Customer C
UNION ALL
SELECT 2 AS TAG,
       1 AS PARENT,
       C.CustomerID,
       C.PersonID,
       C.AccountNumber,
       O.SalesOrderID,
       O.Status
FROM Sales.Customer C
    INNER JOIN Sales.SalesOrderHeader O
        ON C.CustomerID = O.CustomerID
ORDER BY [Customer!1!CustomerID],
         [Order!2!SalesOrderID]
FOR XML EXPLICIT;

/*
...
<Customer CustomerID="28043">
  <PersonID>10995</PersonID>
  <AccountNumber>AW00028043</AccountNumber>
  <Order SalesOrderID="56709">
    <Status>5</Status>
  </Order>
</Customer>
<Customer CustomerID="28044">
  <PersonID>15644</PersonID>
  <AccountNumber>AW00028044</AccountNumber>
  <Order SalesOrderID="44001">
    <Status>5</Status>
  </Order>
</Customer>
...
*/


