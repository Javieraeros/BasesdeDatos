USE Northwind
go

--1. Nombre de la compañía y dirección completa (dirección, cuidad, país) de todos los
--clientes que no sean de los Estados Unidos.
Select CompanyName,Address,City,Country from Customers
where Country<>'USA'
go
--2. La consulta anterior ordenada por país y ciudad.
Select CompanyName,Address,City,Country from Customers
where Country<>'USA' order by Country,City
go
--3. Nombre, Apellidos, Ciudad y Edad de todos los empleados, ordenados por antigüedad en
--la empresa.
Select FirstName,LastName,City,Year(Current_Timestamp-BirthDate)-1900 As Edad from Employees
order by HireDate
go
--4. Nombre y precio de cada producto, ordenado de mayor a menor precio.
Select ProductName,UnitPrice from Products order by UnitPrice desc

--5. Nombre de la compañía y dirección completa de cada proveedor de algún país de
--América del Norte.
Select CompanyName,Address,City,Country from Suppliers
where Country in ('Canada','USA','Mexico')

--6. Nombre del producto, número de unidades en stock y valor total del stock, de los
--productos que no sean de la categoría 4.

Select ProductName,UnitsInStock,UnitsInStock*UnitPrice as TotalValor from Products
where CategoryID<>4
--7. Clientes (Nombre de la Compañía, dirección completa, persona de contacto) que no
--residan en un país de América del Norte y que la persona de contacto no sea el
--propietario de la compañía
Select CustomerID,CompanyName,Address,City,Country,ContactName from Customers
where Country not in ('USA','Canada','Mexico') and ContactTitle<>'Owner'

--8. ID del cliente y número de pedidos realizados por cada cliente, ordenado de mayor a
--menor número de pedidos.
Select CustomerID
	  ,count(*) as [Número de pedidos]
From Orders
Group by CustomerID
Order by [Número de pedidos] DESC
go

--9. Número de pedidos enviados a cada ciudad, incluyendo el nombre de la ciudad.

Select Count(*) as [Número de pedidos]
	  ,ShipCity
From Orders
Group By ShipCity
go
--10. Número de productos de cada categoría. 
Select CategoryID
	  ,count(*) as [Número de productos]
From Products
Group by CategoryID
go