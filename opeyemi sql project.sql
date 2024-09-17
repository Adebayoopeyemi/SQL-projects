--Question 1 : Retrieve all employees who are assigned to the Sales department.
SELECT 
    P.FirstName, 
    P.LastName, 
    D.Name AS Department
FROM 
    HumanResources.Employee E
JOIN 
    HumanResources.EmployeeDepartmentHistory EDH ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN 
    HumanResources.Department D ON EDH.DepartmentID = D.DepartmentID
JOIN 
    Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
WHERE 
    D.Name = 'Sales' AND EDH.EndDate IS NULL;

	--Question 2 : List all products along with their category and subcategory names.
	SELECT 
    P.Name AS ProductName, 
    PSC.Name AS SubCategoryName, 
    PC.Name AS CategoryName
FROM 
    Production.Product P
JOIN 
    Production.ProductSubcategory PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN 
    Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID;


--Question 3:Get the total sales for each salesperson, filtering those who made over $100,000.

SELECT 
    P.FirstName, 
    P.LastName, 
    TotalSales
FROM 
    Person.Person P
JOIN 
    Sales.SalesPerson SP ON P.BusinessEntityID = SP.BusinessEntityID
JOIN 
    (SELECT 
        SalesPersonID, 
        SUM(TotalDue) AS TotalSales 
     FROM 
        Sales.SalesOrderHeader 
     GROUP BY 
        SalesPersonID 
     HAVING 
        SUM(TotalDue) > 100000) AS SalesData
ON 
    SP.BusinessEntityID = SalesData.SalesPersonID;

	--Question 4: Fetching Top 10 customers with the most sales?

SELECT Top 10
    P.FirstName, 
    P.LastName, 
    C.CustomerID, 
    SUM(SOH.TotalDue) AS TotalSales
FROM 
    Sales.Customer C
JOIN 
    Person.Person P ON C.PersonID = P.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader SOH ON C.CustomerID = SOH.CustomerID
GROUP BY 
    P.FirstName, 
    P.LastName, 
    C.CustomerID
ORDER BY 
    TotalSales DESC
	

--Question 5:Find the average sales amount for each territory and the corresponding average discount applied.

SELECT 
    ST.Name AS TerritoryName, 
    AVG(SOH.TotalDue) AS AvgSalesAmount, 
    AVG(SOD.UnitPriceDiscount) AS AvgDiscount
FROM 
    Sales.SalesTerritory ST
JOIN 
    Sales.SalesOrderHeader SOH ON ST.TerritoryID = SOH.TerritoryID
JOIN 
    Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY 
    ST.Name;

--Question 6:Find customers who have placed orders only in 2012

SELECT 
    C.CustomerID, 
    P.FirstName, 
    P.LastName
FROM 
    Sales.Customer C
JOIN 
    Person.Person P ON C.PersonID = P.BusinessEntityID
WHERE 
    C.CustomerID IN (
        SELECT 
            DISTINCT SOH.CustomerID 
        FROM 
            Sales.SalesOrderHeader SOH 
        WHERE 
            YEAR(SOH.OrderDate) = 2012
    );

--Question 7:Find the average sales amount for each territory and the corresponding average discount applied.

SELECT 
    ST.Name AS TerritoryName, 
    AVG(SOH.TotalDue) AS AvgSalesAmount, 
    AVG(SOD.UnitPriceDiscount) AS AvgDiscount
FROM 
    Sales.SalesTerritory ST
JOIN 
    Sales.SalesOrderHeader SOH ON ST.TerritoryID = SOH.TerritoryID
JOIN 
    Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY 
    ST.Name;

--Question 8: Get the details of employees who have been in the company for more than 10 years

SELECT 
    P.FirstName, 
    P.LastName, 
    E.HireDate
FROM 
    HumanResources.Employee E
JOIN 
    Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
WHERE 
    DATEDIFF(YEAR, E.HireDate, GETDATE()) > 10;

--Question 9: Retrieve the most expensive product sold in each sales order

WITH MostExpensiveProduct AS (
    SELECT 
        SOH.SalesOrderID, 
        MAX(SOD.UnitPrice) AS MaxPrice
    FROM 
        Sales.SalesOrderHeader SOH
    JOIN 
        Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
    GROUP BY 
        SOH.SalesOrderID
)
SELECT 
    
    P.Name AS ProductName, 
    SOD.UnitPrice AS Price
FROM 
    MostExpensiveProduct MEP
JOIN 
    Sales.SalesOrderDetail SOD ON MEP.SalesOrderID = SOD.SalesOrderID AND MEP.MaxPrice = SOD.UnitPrice
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID;

--Question 10:Find all employees who have never placed a sales order
SELECT 
    P.FirstName, 
    P.LastName
FROM 
    HumanResources.Employee E
JOIN 
    Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
LEFT JOIN 
    Sales.SalesOrderHeader SOH ON E.BusinessEntityID = SOH.SalesPersonID
WHERE 
    SOH.SalesOrderID IS NULL;

--Question 11: List the departments with more than 5 employees

WITH DepartmentCounts AS (
    SELECT 
        D.Name AS DepartmentName, 
        COUNT(E.BusinessEntityID) AS EmployeeCount
    FROM 
        HumanResources.Department D
    JOIN 
        HumanResources.EmployeeDepartmentHistory EDH ON D.DepartmentID = EDH.DepartmentID
    JOIN 
        HumanResources.Employee E ON EDH.BusinessEntityID = E.BusinessEntityID
    WHERE 
        EDH.EndDate IS NULL
    GROUP BY 
        D.Name
)
SELECT 
    DepartmentName, 
    EmployeeCount
FROM 
    DepartmentCounts
WHERE 
    EmployeeCount > 5
ORDER BY 
    EmployeeCount DESC;

--Question 12: Retrieve product details for products with list prices higher than the average price.

SELECT 
    Name, 
    ListPrice
FROM 
    Production.Product
WHERE 
    ListPrice > (SELECT AVG(ListPrice) FROM Production.Product);

--Question 13: Find the territories with the highest sales revenue

SELECT 
    ST.Name AS TerritoryName, 
    SUM(SOH.TotalDue) AS TotalSales
FROM 
    Sales.SalesTerritory ST
JOIN 
    Sales.SalesOrderHeader SOH ON ST.TerritoryID = SOH.TerritoryID
GROUP BY 
    ST.Name
ORDER BY 
    TotalSales DESC;

--Question 14:To get the top 5 employees by HireDate from the HumanResources.Employee table.

WITH TopEmployeesByHireDate AS (
    SELECT 
        P.FirstName, 
        P.LastName, 
        E.HireDate,
        ROW_NUMBER() OVER (ORDER BY E.HireDate ASC) AS RowNum
    FROM 
        HumanResources.Employee E
    JOIN 
        Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
)
SELECT 
    FirstName, 
    LastName, 
    HireDate
FROM 
    TopEmployeesByHireDate
WHERE 
    RowNum <= 5;

--Question 15: retrieve all customers and their orders from the Sales.Customer and Sales.SalesOrderHeader tables.

SELECT 
    P.FirstName + ' ' + P.LastName AS CustomerName, 
    SOH.SalesOrderID AS OrderID, 
    SOH.TotalDue
FROM 
    Sales.Customer C
INNER JOIN 
    Sales.SalesOrderHeader SOH ON C.CustomerID = SOH.CustomerID
INNER JOIN 
    Person.Person P ON C.PersonID = P.BusinessEntityID
ORDER BY 
    CustomerName;

