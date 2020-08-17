create database Bikes;
use Bikes;

create table Employee
(EmployeeID integer not null,
EmployeeFirstName varchar(15),
EmployeeLastName varchar(15),
DepartmentID  integer,
EmployeeAddress varchar(50),
Gender varchar(10),
EmployeeBirthDate date,
Salary real,
RegionID integer,
constraint Employee_PK primary key (EmployeeID),
constraint Employee_FK1 foreign key (DepartmentID) references Department(DepartmentID),
constraint Employee_FK2 foreign key (RegionID) references Region(RegionID));

create table Product
(ProductID integer not null, 
ProductName varchar(50), 
Cost real, 
WholeSalePrice real, 
MSRP real,
constraint Product_PK primary key (ProductID));

create table Customer
(CustomerID integer not null, 
CustomerFirstName varchar(15), 
CustomerLastName varchar(15), 
CustomerAddress varchar(50), 
CustomerAge integer, 
CustomerExperience integer,
constraint Customer_PK primary key (CustomerID));

create table Department
(DepartmentID integer not null, 
DepartmentName varchar(50),
constraint Department_PK primary key (DepartmentID));

create table Region
(RegionID integer not null, 
RegionName varchar(10),
constraint Region_PK primary key (RegionID));

create table SalesOrder
(OrderID integer not null, 
PODate date, 
ProductID integer, 
CustomerID integer,
CustomerPO integer, 
EmployeeID integer, 
Quantity integer, 
UnitPrice real,
constraint SalesOrder_PK primary key (OrderID),
constraint SalesOrder_FK1 foreign key (ProductID) references Product(ProductID),
constraint SalesOrder_FK2 foreign key (CustomerID) references Customer(CustomerID),
constraint SalesOrder_FK3 foreign key (EmployeeID) references Employee(EmployeeID));

BULK
INSERT Employee
FROM 'C:\Users\rajja\Desktop\MSBA\Database\Data\Employee.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT Product
FROM 'C:\Users\rajja\Desktop\MSBA\Database\Data\Product.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT Customer
FROM 'C:\Users\rajja\Desktop\MSBA\Database\Data\Customer.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT Department
FROM 'C:\Users\rajja\Desktop\MSBA\Database\Data\Department.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT Region
FROM 'C:\Users\rajja\Desktop\MSBA\Database\Data\Region.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT SalesOrder
FROM 'C:\Users\rajja\Desktop\MSBA\Database\Data\SalesOrder.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

---------------------------------------------------------------Query 1
Select Region.RegionName, SUM(Quantity*UnitPrice) AS 'Total Sales'
From Region, SalesOrder, Product, Employee
Where Product.ProductName IN ('Extreme Mountain Bike','Extreme Plus Mountain Bike','Extreme Ultra Mountain Bike')
AND SalesOrder.ProductID = Product.ProductID
AND SalesOrder.EmployeeID = Employee.EmployeeID
AND Employee.RegionID = Region.RegionID
Group By Region.RegionName
Order By Region.RegionName;

---------------------------------------------------------------Query 2

SELECT Product.ProductID , Product.ProductName , Product.Cost
FROM Product
WHERE Product.ProductID NOT IN 
(SELECT Product.ProductID FROM SalesOrder , Customer , Product
WHERE Product.ProductID = SalesOrder.ProductID
AND Customer.CustomerID = SalesOrder.CustomerID
AND Customer.CustomerFirstName = 'Dan'
AND Customer.CustomerLastName = 'Connor'
GROUP BY Product.ProductID);

---------------------------------------------------------------Query 3

Select Customer.CustomerID, Customer.CustomerFirstName, Customer.CustomerLastName, Customer.CustomerAge , AvgAge
From (Select AVG(Customer.CustomerAge) From Customer) Derived_t (AvgAge), Customer, SalesOrder
Where Customer.CustomerID = SalesOrder.CustomerID
AND Customer.CustomerAge >  AvgAge
Group By Customer.CustomerID,Customer.CustomerAge,Customer.CustomerFirstName,Customer.CustomerLastName,AvgAge
Having COUNT(SalesOrder.OrderID) > 1000
Order By Customer.CustomerAge;


---------------------------------------------------------------Query 4

SELECT MAX(Table1.SUM1) AS [Max Sales Q1], MAX(Table2.SUM2) AS [Max Sales Q2], MAX(Table3.SUM3) AS [Max Sales Q3], MAX(Table4.SUM4) AS [Max Sales Q4] 
FROM
(SELECT SalesOrder.CustomerID,
SUM (UnitPrice*Quantity) AS SUM1 
FROM SalesOrder
WHERE SalesOrder.PODate BETWEEN '2014-01-01' AND '2014-03-31'
GROUP BY SalesOrder.CustomerID) Table1,

(SELECT SalesOrder.CustomerID,
SUM (UnitPrice*Quantity) AS SUM2
FROM SalesOrder
WHERE PODate BETWEEN '2014-04-01' AND '2014-06-30'
GROUP BY SalesOrder.CustomerID) Table2,

(SELECT SalesOrder.CustomerID,
SUM (UnitPrice*Quantity) AS SUM3 
FROM SalesOrder
WHERE PODate BETWEEN '2014-07-01' AND '2014-09-30'
GROUP BY SalesOrder.CustomerID) Table3,

(SELECT SalesOrder.CustomerID,
SUM (UnitPrice*Quantity) AS SUM4 
FROM SalesOrder
WHERE PODate BETWEEN '2014-10-01' AND '2014-12-31'
GROUP BY SalesOrder.CustomerID) Table4;

-------------------------------------------------------------------Query5

SELECT ProductName, SUM (Quantity * (UnitPrice - Cost)) "Over Avg Profit"
FROM Product, SalesOrder,
(SELECT AVG (Average_Profit.Profit) "AvgProfit"
FROM
(SELECT ProductName, SUM (Quantity * (UnitPrice - Cost)) "Profit"
FROM Product, SalesOrder
WHERE SalesOrder.ProductID= Product.ProductID
GROUP BY Product.ProductName) Average_Profit) AverageProfit
WHERE SalesOrder.ProductID= Product.ProductID
GROUP BY Product.ProductName, AvgProfit
HAVING SUM (Quantity * (UnitPrice - Cost)) > AvgProfit;
