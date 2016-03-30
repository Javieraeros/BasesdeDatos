USE Northwind

Select * FROM Employees

Select * INTO Empleados1 FROM Employees

SELECT * FROM Empleados1

--Eliminar empleados que hayan vendido a Bon app'
Begin transaction
DELETE
	FROM Empleados1
WHERE EmployeeID IN (
	SELECT DISTINCT
		Pedido.EmployeeID
	FROM Orders as Pedido 
	INNER JOIN Customers as Cliente 
	ON Pedido.CustomerID=Cliente.CustomerID 
	Where Cliente.CompanyName IN ('Bon app'''/*,'Alfreds Futterkiste','Meter Franken'*/)
)


ROLLBACK TRANSACTION

--Eliminar categorías 2,4, 6

Select * INTO Categorias1 FROM Categories
SELECT * FROM Categorias1

BEGIN TRANSACTION
DELETE
	FROM 
		Categorias1
	WHERE CategoryID IN
	(
	SELECT DISTINCT
		c.CategoryID
	FROM Products as p 
	LEFT JOIN Categories as c 
	ON  p.CategoryID = c.CategoryID 
	WHERE p.CategoryID IN (2,4,6)
	)

ROLLBACK TRANSACTION
	
--Eliminar emplados que hayan hecho un envio a Francia

SELECT * FROM empleados1
GO
BEGIN TRANSACTION
DELETE FROM	
	Empleados1
WHERE EmployeeID IN(
	SELECT
		E.EmployeeID
	FROM Employees as E
	INNER JOIN Orders as O
		ON E.EmployeeID=O.EmployeeID
	WHERE O.ShipCountry LIKE 'France'
)

ROLLBACK TRANSACTION