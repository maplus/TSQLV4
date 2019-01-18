-- The database assumed in the exercise is TSQLV4

-- 1
-- Run the following code to create the dbo.Customers table
-- in the TSQLV4 database
USE TSQLV4;

DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers
(
  custid      INT          NOT NULL PRIMARY KEY,
  companyname NVARCHAR(40) NOT NULL,
  country     NVARCHAR(15) NOT NULL,
  region      NVARCHAR(15) NULL,
  city        NVARCHAR(15) NOT NULL  
);

-- 1-1
-- Insert into the dbo.Customers table a row with:
-- custid:  100
-- companyname: Coho Winery
-- country:     USA
-- region:      WA
-- city:        Redmond

insert into dbo.Customers--(custid, companyname, country, region, city)
values(100, N'Coho Winery', N'USA', N'WA', N'Redmond');


-- 1-2
-- Insert into the dbo.Customers table 
-- all customers from Sales.Customers
-- who placed orders

insert into dbo.Customers--(custid, companyname, country, region, city)
select distinct c.custid, c.companyname, c.country, c.region, c.city
from sales.Customers c join sales.Orders o on c.custid = o.custid;

INSERT INTO dbo.Customers(custid, companyname, country, region, city)
SELECT custid, companyname, country, region, city
FROM Sales.Customers AS C
WHERE EXISTS(
	SELECT * FROM Sales.Orders AS O
    WHERE O.custid = C.custid
);


-- 1-3
-- Use a SELECT INTO statement to create and populate the dbo.Orders table
-- with orders from the Sales.Orders
-- that were placed in the years 2014 through 2016

drop table if exists dbo.Orders;
/* not working...
insert into dbo.orders([orderid], [custid], [empid], [orderdate], [requireddate], [shippeddate], [shipperid], [freight], [shipname], [shipaddress], [shipcity], [shipregion], [shippostalcode], [shipcountry])
select o.[orderid], o.[custid], o.[empid], o.[orderdate], o.[requireddate], o.[shippeddate], o.[shipperid], o.[freight], o.[shipname], o.[shipaddress], o.[shipcity], o.[shipregion], o.[shippostalcode], o.[shipcountry]
from Sales.Orders o
where o.orderdate >= cast('20140101' as date) and  o.orderdate < cast('20150101' as date)
*/

select
	* 
	--o.[orderid], o.[custid], o.[empid], o.[orderdate], o.[requireddate], o.[shippeddate], o.[shipperid], o.[freight], o.[shipname], o.[shipaddress], o.[shipcity], o.[shipregion], o.[shippostalcode], o.[shipcountry]
into dbo.orders
from Sales.Orders o
where o.orderdate >= cast('20140101' as date) and  o.orderdate < cast('20150101' as date)


-- 2
-- Delete from the dbo.Orders table
-- orders that were placed before August 2014
-- Use the OUTPUT clause to return the orderid and orderdate
-- of the deleted orders

-- Desired output:
orderid     orderdate
----------- -----------
10248       2014-07-04 
10249       2014-07-05 
10250       2014-07-08 
10251       2014-07-08 
10252       2014-07-09 
10253       2014-07-10 
10254       2014-07-11 
10255       2014-07-12 
10256       2014-07-15 
10257       2014-07-16 
10258       2014-07-17 
10259       2014-07-18 
10260       2014-07-19 
10261       2014-07-19 
10262       2014-07-22 
10263       2014-07-23 
10264       2014-07-24 
10265       2014-07-25 
10266       2014-07-26 
10267       2014-07-29 
10268       2014-07-30 
10269       2014-07-31 

(22 row(s) affected)

select orderid, orderdate from dbo.orders where orderdate < cast('20140801' as date)

delete from dbo.orders
output deleted.orderid, deleted.orderdate
where orderdate < cast('20140801' as date);


-- 3
--- Delete from the dbo.Orders table orders placed by customers from Brazil

select *
from dbo.orders o join dbo.Customers c on o.custid = c.custid
where c.country = N'Brazil';

delete from dbo.orders where custid in(
	select custid from dbo.Customers where country = N'Brazil'
);

delete from o
from dbo.orders o join dbo.Customers c on o.custid = c.custid
where c.country = N'Brazil';

delete from dbo.orders
where exists(
	select *
	from dbo.Customers c
	where orders.custid = c.custid
		and c.country = N'Brazil'
);

merge into dbo.orders o
using dbo.customers c
on o.custid = c.custid and c.country = N'Brazil'
when matched then delete;


-- 4
-- Run the following query against dbo.Customers,
-- and notice that some rows have a NULL in the region column
SELECT * FROM dbo.Customers;

-- Output:
custid      companyname    country         region     city
----------- -------------- --------------- ---------- --------------- 
1           Customer NRZBB Germany         NULL       Berlin
2           Customer MLTDN Mexico          NULL       México D.F.
3           Customer KBUDE Mexico          NULL       México D.F.
4           Customer HFBZG UK              NULL       London
5           Customer HGVLZ Sweden          NULL       Luleå
6           Customer XHXJV Germany         NULL       Mannheim
7           Customer QXVLA France          NULL       Strasbourg
8           Customer QUHWH Spain           NULL       Madrid
9           Customer RTXGC France          NULL       Marseille
10          Customer EEALV Canada          BC         Tsawassen
...

(90 row(s) affected)

-- Update the dbo.Customers table and change all NULL region values to '<None>'
-- Use the OUTPUT clause to show the custid, old region and new region

-- Desired output:
custid      oldregion       newregion
----------- --------------- ---------------
1           NULL            <None>
2           NULL            <None>
3           NULL            <None>
4           NULL            <None>
5           NULL            <None>
6           NULL            <None>
7           NULL            <None>
8           NULL            <None>
9           NULL            <None>
11          NULL            <None>
12          NULL            <None>
13          NULL            <None>
14          NULL            <None>
16          NULL            <None>
17          NULL            <None>
18          NULL            <None>
19          NULL            <None>
20          NULL            <None>
23          NULL            <None>
24          NULL            <None>
25          NULL            <None>
26          NULL            <None>
27          NULL            <None>
28          NULL            <None>
29          NULL            <None>
30          NULL            <None>
39          NULL            <None>
40          NULL            <None>
41          NULL            <None>
44          NULL            <None>
49          NULL            <None>
50          NULL            <None>
52          NULL            <None>
53          NULL            <None>
54          NULL            <None>
56          NULL            <None>
58          NULL            <None>
59          NULL            <None>
60          NULL            <None>
63          NULL            <None>
64          NULL            <None>
66          NULL            <None>
68          NULL            <None>
69          NULL            <None>
70          NULL            <None>
72          NULL            <None>
73          NULL            <None>
74          NULL            <None>
76          NULL            <None>
79          NULL            <None>
80          NULL            <None>
83          NULL            <None>
84          NULL            <None>
85          NULL            <None>
86          NULL            <None>
87          NULL            <None>
90          NULL            <None>
91          NULL            <None>

(58 row(s) affected)

update dbo.Customers
set region = '<None>'
output deleted.custid, deleted.region oldregion, inserted.region newregion
where region is null;


-- 5
-- Update in the dbo.Orders table all orders placed by UK customers
-- and set their shipcountry, shipregion, shipcity values
-- to the country, region, city values of the corresponding customers from dbo.Customers

select * from dbo.Customers where country = 'UK';

update o set o.shipcountry = c.country, o.shipregion = c.region, o.shipcity = c.city
from dbo.Orders o join dbo.Customers c on o.custid = c.custid
where c.country = N'UK';

with CTE as (
	select c.custid, c.country, c.region, c.city
	from dbo.Customers c
	where c.country = N'UK'
)
update o set o.shipcountry = c.country, o.shipregion = c.region, o.shipcity = c.city
from dbo.orders o join CTE c on o.custid = c.custid;

WITH CTE_UPD AS
(
  SELECT
    O.shipcountry AS ocountry, C.country AS ccountry,
    O.shipregion  AS oregion,  C.region  AS cregion,
    O.shipcity    AS ocity,    C.city    AS ccity
  FROM dbo.Orders AS O
    INNER JOIN dbo.Customers AS C
      ON O.custid = C.custid
  WHERE C.country = N'UK'
)
UPDATE CTE_UPD
  SET ocountry = ccountry, oregion = cregion, ocity = ccity;

merge dbo.orders o
using dbo.customers c
on o.custid = c.custid and c.country = N'UK'
when matched then update set
	o.shipcountry = c.country,
	o.shipregion = c.region,
	o.shipcity = c.city;


-- 6
-- Run the following code to create the tables Orders and OrderDetails and populate them with data

USE TSQLV4;

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

CREATE TABLE dbo.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES dbo.Orders(orderid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

-- Write and test the T-SQL code that is required to truncate both tables,
-- and make sure that your code runs successfully
-- TRUNCATE TABLE dbo.Orders; -- Cannot truncate table 'dbo.Orders' because it is being referenced by a FOREIGN KEY constraint.
TRUNCATE TABLE  dbo.OrderDetails;
-- TRUNCATE TABLE  dbo.Orders; -- Cannot truncate table 'dbo.Orders' because it is being referenced by a FOREIGN KEY constraint.
ALTER TABLE dbo.OrderDetails DROP CONSTRAINT FK_OrderDetails_Orders;
TRUNCATE TABLE  dbo.Orders;
ALTER TABLE dbo.OrderDetails ADD CONSTRAINT FK_OrderDetails_Orders
  FOREIGN KEY(orderid) REFERENCES dbo.Orders(orderid);


-- When you're done, run the following code for cleanup
DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders, dbo.Customers;
