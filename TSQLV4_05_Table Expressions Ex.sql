-- 1
-- The following query attempts to filter orders placed on the last day of the year.
USE TSQLV4;
GO

SELECT orderid, orderdate, custid, empid,
  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> endofyear;

-- When you try to run this query you get the following error.
/*
Msg 207, Level 16, State 1, Line 233
Invalid column name 'endofyear'.
*/
-- Explain what the problem is and suggest a valid solution.

SELECT orderid, orderdate, custid, empid,
  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> DATEFROMPARTS(YEAR(orderdate), 12, 31);

with c as
(
select orderid, orderdate, custid, empid,
  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
from Sales.Orders
)
select orderid, orderdate, custid, empid, endofyear from c where orderdate <> endofyear;


-- 2-1
-- Write a query that returns the maximum order date for each employee
-- Tables involved: TSQLV4 database, Sales.Orders table

--Desired output
empid       maxorderdate
----------- -------------
3           2016-04-30
6           2016-04-23
9           2016-04-29
7           2016-05-06
1           2016-05-06
4           2016-05-06
2           2016-05-05
5           2016-04-22
8           2016-05-06

(9 row(s) affected)

select o.empid, max(o.orderdate) maxorderdate
from Sales.Orders o
group by o.empid;


-- 2-2
-- Encapsulate the query from exercise 2-1 in a derived table
-- Write a join query between the derived table and the Sales.Orders
-- table to return the Sales.Orders with the maximum order date for 
-- each employee
-- Tables involved: Sales.Orders

-- Desired output:
empid       orderdate   orderid     custid
----------- ----------- ----------- -----------
9           2016-04-29  11058       6
8           2016-05-06  11075       68
7           2016-05-06  11074       73
6           2016-04-23  11045       10
5           2016-04-22  11043       74
4           2016-05-06  11076       9
3           2016-04-30  11063       37
2           2016-05-05  11073       58
2           2016-05-05  11070       44
1           2016-05-06  11077       65

(10 row(s) affected)

select o2.empid, o2.orderdate, o2.orderid, o2.custid
from Sales.Orders o2 join
	(
	select o.empid, max(o.orderdate) maxorderdate
	from Sales.Orders o
	group by o.empid
	) x
on o2.orderdate = x.maxorderdate and o2.empid = x.empid;


-- 3-1
-- Write a query that calculates a row number for each order
-- based on orderdate, orderid ordering
-- Tables involved: Sales.Orders

-- Desired output:
orderid     orderdate   custid      empid       rownum
----------- ----------- ----------- ----------- -------
10248       2014-07-04  85          5           1
10249       2014-07-05  79          6           2
10250       2014-07-08  34          4           3
10251       2014-07-08  84          3           4
10252       2014-07-09  76          4           5
10253       2014-07-10  34          3           6
10254       2014-07-11  14          5           7
10255       2014-07-12  68          9           8
10256       2014-07-15  88          3           9
10257       2014-07-16  35          4           10
...

(830 row(s) affected)

select orderid, orderdate, custid, empid,
	ROW_NUMBER() over(order by orderdate, orderid) rownum
from Sales.Orders o;


-- 3-2
-- Write a query that returns rows with row numbers 11 through 20
-- based on the row number definition in exercise 3-1
-- Use a CTE to encapsulate the code from exercise 3-1
-- Tables involved: Sales.Orders

-- Desired output:
orderid     orderdate   custid      empid       rownum
----------- ----------- ----------- ----------- -------
10258       2014-07-17  20          1           11
10259       2014-07-18  13          4           12
10260       2014-07-19  56          4           13
10261       2014-07-19  61          4           14
10262       2014-07-22  65          8           15
10263       2014-07-23  20          9           16
10264       2014-07-24  24          6           17
10265       2014-07-25  7           2           18
10266       2014-07-26  87          3           19
10267       2014-07-29  25          4           20

(10 row(s) affected)

with cte as (
	select orderid, orderdate, custid, empid,
		ROW_NUMBER() over(order by orderdate, orderid) rownum
	from Sales.Orders o
)
select *
from cte
where rownum between 11 and 20;


-- 4 (Optional, Advanced)
-- Write a solution using a recursive CTE that returns the 
-- management chain leading to Patricia Doyle (employee ID 9)
-- Tables involved: HR.Employees

-- Desired output:
empid       mgrid       firstname  lastname
----------- ----------- ---------- --------------------
9           5           Patricia   Doyle
5           2           Sven       Mortensen
2           1           Don        Funk
1           NULL        Sara       Davis

(4 row(s) affected)

with cte as (
  SELECT empid, mgrid, firstname, lastname
  FROM HR.Employees
  WHERE empid = 9
  UNION ALL
  SELECT P.empid, P.mgrid, P.firstname, P.lastname
  FROM cte AS C
    INNER JOIN HR.Employees AS P
      ON C.mgrid = P.empid
)
select e.empid, e.mgrid, e.firstname, e.lastname
from cte e;


-- 5-1
-- Create a view that returns the total qty
-- for each employee and year
-- Tables involved: Sales.Orders and Sales.OrderDetails

-- Desired output when running:
-- SELECT * FROM  Sales.VEmpOrders ORDER BY empid, orderyear
empid       orderyear   qty
----------- ----------- -----------
1           2014        1620
1           2015        3877
1           2016        2315
2           2014        1085
2           2015        2604
2           2016        2366
3           2014        940
3           2015        4436
3           2016        2476
4           2014        2212
4           2015        5273
4           2016        2313
5           2014        778
5           2015        1471
5           2016        787
6           2014        963
6           2015        1738
6           2016        826
7           2014        485
7           2015        2292
7           2016        1877
8           2014        923
8           2015        2843
8           2016        2147
9           2014        575
9           2015        955
9           2016        1140

(27 row(s) affected)

create view Sales.VEmpOrders as
with CTE as (
	select o.empid, DATEPART(year, o.orderdate) orderyear, d.qty
	from Sales.Orders o join Sales.OrderDetails d on o.orderid = d.orderid
)
select empid, orderyear, sum(qty) qty
from CTE
group by empid, orderyear;

SELECT * FROM  Sales.VEmpOrders ORDER BY empid, orderyear;


-- 5-2 (Optional, Advanced)
-- Write a query against Sales.VEmpOrders
-- that returns the running qty for each employee and year
-- Tables involved: TSQLV4 database, Sales.VEmpOrders view

-- Desired output:
empid       orderyear   qty         runqty
----------- ----------- ----------- -----------
1           2014        1620        1620
1           2015        3877        5497
1           2016        2315        7812
2           2014        1085        1085
2           2015        2604        3689
2           2016        2366        6055
3           2014        940         940
3           2015        4436        5376
3           2016        2476        7852
4           2014        2212        2212
4           2015        5273        7485
4           2016        2313        9798
5           2014        778         778
5           2015        1471        2249
5           2016        787         3036
6           2014        963         963
6           2015        1738        2701
6           2016        826         3527
7           2014        485         485
7           2015        2292        2777
7           2016        1877        4654
8           2014        923         923
8           2015        2843        3766
8           2016        2147        5913
9           2014        575         575
9           2015        955         1530
9           2016        1140        2670

(27 row(s) affected)

select v.empid, v.orderyear, v.qty/*,
	sum(v.qty) over (partition v.empid) runqty*/
from Sales.VEmpOrders v;

select
	v1.empid, v1.orderyear, v1.qty,
	(
	select sum(v2.qty)
	from Sales.VEmpOrders v2
	where v2.empid = v1.empid and v2.orderyear <= v1.orderyear
	) runqty
from Sales.VEmpOrders v1
order by v1.empid, v1.orderyear;


-- 6-1
-- Create an inline function that accepts as inputs
-- a supplier id (@supid AS INT), 
-- and a requested number of products (@n AS INT)
-- The function should return @n products with the highest unit prices
-- that are supplied by the given supplier id
-- Tables involved: Production.Products

-- Desired output when issuing the following query:
-- SELECT * FROM Production.TopProducts(5, 2)

productid   productname                              unitprice
----------- ---------------------------------------- ---------------------
12          Product OSFNS                            38.00
11          Product QMVUN                            21.00

(2 row(s) affected)

drop function Production.TopProducts;
create function Production.TopProducts(@supid AS INT, @n AS INT) returns table
as
return
select top(@n) p.productid, p.productname, p.unitprice
from Production.Products p
where p.supplierid = @supid
order by p.unitprice desc;

SELECT * FROM Production.TopProducts(5, 2);


-- 6-2
-- Using the CROSS APPLY operator
-- and the function you created in exercise 6-1,
-- return, for each supplier, the two most expensive products

-- Desired output 
supplierid  companyname     productid   productname     unitprice
----------- --------------- ----------- --------------- ----------
8           Supplier BWGYE  20          Product QHFFP   81.00
8           Supplier BWGYE  68          Product TBTBL   12.50
20          Supplier CIYNM  43          Product ZZZHR   46.00
20          Supplier CIYNM  44          Product VJIEO   19.45
23          Supplier ELCRN  49          Product FPYPN   20.00
23          Supplier ELCRN  76          Product JYGFE   18.00
5           Supplier EQPNC  12          Product OSFNS   38.00
5           Supplier EQPNC  11          Product QMVUN   21.00
...

(55 row(s) affected)

select s.supplierid, s.companyname, p.productid, p.productname, p.unitprice
from Production.Suppliers s cross apply Production.TopProducts(s.supplierid, 2) p


-- When you’re done, run the following code for cleanup:
DROP VIEW IF EXISTS Sales.VEmpOrders;
DROP FUNCTION IF EXISTS Production.TopProducts;
