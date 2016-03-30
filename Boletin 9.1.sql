--Boletin 9.1
--Escribe las siguientes consultas sobre la base de datos NorthWind.
Use Northwind
--Pon el enunciado como comentario junta a cada una

--1.Nombre de los proveedores y número de productos que nos vende cada uno

select S.CompanyName
	  ,count(*) as [Total Productos] 
from Suppliers as S
inner join Products as P
on S.SupplierID=P.SupplierID
group by S.CompanyName

--2.Nombre completo y telefono de los vendedores que trabajen en New York, Seattle, Vermont, Columbia, Los Angeles, Redmond o Atlanta.

Select Distinct FirstName
	  ,LastName
	  ,HomePhone
from Employees as E
inner join EmployeeTerritories as ET
on E.EmployeeID=ET.EmployeeID
inner join Territories as T
on ET.TerritoryID=T.TerritoryID
where TerritoryDescription in ('New York','Seattle','Vermont','Columbia','Los Angeles','Redmond','Atlanta')


--3.Número de productos de cada categoría y nombre de la categoría.

Select C.CategoryName
	  ,count(*) as [Numero de Productos]
from Products as P
inner join Categories as C
on P.CategoryID=C.CategoryID
group by C.CategoryName

--4.Nombre de la compañía de todos los clientes que hayan comprado queso de cabrales o tofu.

Select Distinct C.CompanyName
from Customers as C
inner join Orders as O
on C.CustomerID=O.CustomerID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
where P.ProductName in ('queso cabrales','tofu')

--5.Empleados (ID, nombre, apellidos y teléfono) que han vendido algo a Bon app' o Meter Franken.

Select distinct E.EmployeeID
	  ,E.FirstName
	  ,E.LastName
	  ,E.HomePhone
from Employees as E
inner join Orders as O
on E.EmployeeID=O.EmployeeID
inner join Customers as C
on O.CustomerID=C.CustomerID
where C.CompanyName in ('Bon app''','Meter Franken')

--6.Empleados (ID, nombre, apellidos, mes y día de su cumpleaños) que no han vendido nunca nada a ningún cliente de Francia. *

Select E.EmployeeID,
	   E.FirstName,
	   E.LastName,
	   month(E.BirthDate) as [Mes de Nacimiento],
	   day(E.BirthDate) as [Día de Nacimiento]
from Employees as E
EXCEPT 
Select E.EmployeeID,
	   E.FirstName,
	   E.LastName,
	   month(E.BirthDate) as [Mes de Nacimiento],
	   day(E.BirthDate) as [Día de Nacimiento]
from Employees as E
inner join Orders as O
on E.EmployeeID=O.EmployeeID
inner join Customers as C
on O.CustomerID=C.CustomerID
where C.Country='France'

--7.Total de ventas en US$ de productos de cada categoría (nombre de la categoría).

Select C.CategoryName
	  ,sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas
from Categories as C
inner join Products as P
on C.CategoryID=P.CategoryID
inner join [Order Details] as OD
on P.ProductID=OD.ProductID
group by C.CategoryName

--8.Total de ventas en US$ de cada empleado cada año (nombre, apellidos, dirección).

Select E.FirstName
	  ,E.LastName
	  ,E.Address
	  ,sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas
	  ,year(O.OrderDate) as Año
from Employees as E
inner join Orders as O
on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
group by E.FirstName,E.LastName,E.Address,year(O.OrderDate)
order by  E.FirstName,E.LastName,year(O.OrderDate)

--9.Ventas de cada producto en el año 97. Nombre del producto y unidades.

Select P.ProductName
	  ,sum(OD.Quantity) as Unidades
	  ,sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas
from Products as P
inner join [Order Details] as OD
on P.ProductID=OD.ProductID
inner join Orders as O
on OD.OrderID=O.OrderID
where year(O.OrderDate)=1997
group by P.ProductName


--10.Cuál es el producto del que hemos vendido más unidades en cada país. *
Select P.ProductName,
	   C.Country,
	   SUM(OD.Quantity) as [Cantidad Vendida]
from Products as P
inner join [Order Details] as OD
on P.ProductID=OD.ProductID
inner join Orders as O
on OD.OrderID=O.OrderID
inner join Customers as C
on O.CustomerID=C.CustomerID
inner join 
	(Select C.Country,
			max(C.[Cantidad Vendida]) as [Cantidad Producto]
	from (
		Select P.ProductName,
			   C.Country,
			   SUM(OD.Quantity) as [Cantidad Vendida]
		from Products as P
		inner join [Order Details] as OD
		on P.ProductID=OD.ProductID
		inner join Orders as O
		on OD.OrderID=O.OrderID
		inner join Customers as C
		on O.CustomerID=C.CustomerID
		group by P.ProductName,C.Country
		) as C
	group by C.Country
	) as maximo
on C.Country=maximo.Country
group by P.ProductName,C.Country, maximo.[Cantidad Producto]
having SUM(OD.Quantity)=maximo.[Cantidad Producto]

----OTRA FORMA DE HACERLO-----


Select PVP.[Nombre de Producto],
	   PVP.[Pais],
	   PVP.[Cantidad Vendida]
from ProductosVendidosPais as PVP
inner join 
	(Select PVP.Pais,
			max(PVP.[Cantidad Vendida]) as [Cantidad Producto]
	from ProductosVendidosPais as PVP
	group by PVP.Pais
	) as maximo
on PVP.PAis=maximo.Pais
where PVP.[Cantidad Vendida]=maximo.[Cantidad Producto]


go
create view [ProductosVendidosPais] as (
Select P.ProductName as [Nombre de Producto],
	   C.Country as [Pais],
	   SUM(OD.Quantity) as [Cantidad Vendida]
from Products as P
inner join [Order Details] as OD
on P.ProductID=OD.ProductID
inner join Orders as O
on OD.OrderID=O.OrderID
inner join Customers as C
on O.CustomerID=C.CustomerID
group by P.ProductName,C.Country
)
go

--11.Empleados (nombre y apellidos) que trabajan a las órdenes de Andrew Fuller.

Select FirstName
	  ,LastName
from Employees
where ReportsTo=2

--12.Número de subordinados que tiene cada empleado, incluyendo los que no tienen ninguno. Nombre, apellidos, ID.

Select E.FirstName
	  ,E.LastName
	  ,E.EmployeeID
	  ,count(E1.EmployeeID) as [Subordinados]
from Employees as E
left join Employees as E1
on E.EmployeeID=E1.ReportsTo 
group by E.FirstName
	  ,E.LastName
	  ,E.EmployeeID

--* Se necesitan subconsultas