--Unidad 9. Consultas elaboradas en SQL Server
--Escribe las siguientes consultas sobre la base de datos NorthWind.
--Pon el enunciado como comentario junta a cada una
Use Northwind
go


--1. Número de clientes de cada país.

Select Country
	  ,count(*)
from Customers
group by Country

--2. Número de clientes diferentes que compran cada producto.

Select  P.ProductName
	  ,count(Distinct O.CustomerID) as Clientes
from Orders as O
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
group by P.ProductName

--3. Número de países diferentes en los que se vende cada producto.

Select  P.ProductName
	  ,count(Distinct O.ShipCountry) as Paises
from Orders as O
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
group by P.ProductName

--4. Empleados que han vendido alguna vez “Gudbrandsdalsost”, “Lakkalikööri”,
--“Tourtière” o “Boston Crab Meat”.

Select E.FirstName,
	   E.LastName
from Employees as E
inner join Orders as O
on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
where P.ProductName in ('Gudbrandsdalsost','Lakkalikööri','Tourtière','Boston Crab Meat')


--5. Empleados que no han vendido nunca “Chartreuse verte” ni “Ravioli Angelo”.
Select distinct E.FirstName,
	   E.LastName
from Employees as E
EXCEPT
Select distinct E.FirstName,
	   E.LastName
from Employees as E
inner join Orders as O
on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
where P.ProductName in ('Chartreuse verte','Ravioli Angelo')

--6. Número de unidades de cada categoría de producto que ha vendido cada
--empleado.

Select C.CategoryName,
	   E.FirstName,
	   E.LastName,
	   sum(OD.Quantity) as [Cantidad total]
from Employees as E
inner join Orders as O
on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
inner join Categories as C
on P.ProductID=C.CategoryID
group by C.CategoryName,E.FirstName,E.LastName

--7. Total de ventas (US$) de cada categoría en el año 97.

Select C.CategoryName,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Total de Ventas]
from Orders as O
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
inner join Categories as C
on P.ProductID=C.CategoryID
where (year(O.OrderDate)=1997)
group by C.CategoryName


--8. Productos que han comprado más de un cliente del mismo país, indicando el nombre del producto, el país y el número de clientes 
--distintos de ese país que lo han comprado.

Select P.ProductName,
	   O.ShipCountry,
	   count(distinct O.CustomerID) as [Clientes]
from Customers as C 
inner join Orders as O
on C.CustomerID=O.CustomerID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
group by P.ProductName,O.ShipCountry
having count(distinct O.CustomerID)>1

--9. Total de ventas (US$) en cada país cada año.

Select O.ShipCountry,
	   year(O.ShippedDate) as Año,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Totales]
from Orders as O
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
group by O.ShipCountry,year(O.ShippedDate)


--10. Producto superventas de cada año, indicando año, nombre del producto,
--categoría y cifra total de ventas.

go
Create view [Ventas por año] as 
Select P.ProductName,
	   C.CategoryName,
	   year(O.OrderDate) as Año,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Totales]
from Products as P
inner join [Order Details] as OD
on P.ProductID=OD.ProductID
inner join Categories as C
on P.CategoryID=C.CategoryID
inner join Orders as O
on OD.OrderID=O.OrderID
group by P.ProductName,C.CategoryName,year(O.OrderDate)
go

Select [Ventas Totales] as Maximo,
	   ProductName,
	   CategoryName,
	   VA.Año
from [Ventas por año] AS VA
inner join (
Select max([Ventas Totales]) as Maximo
	   ,Año
from [Ventas por año]
group by Año) AS Max 
ON VA.[Ventas Totales] = Max.Maximo AND VA.Año = Max.Año

--11. Cifra de ventas de cada producto en el año 97 y su aumento o disminución
--respecto al año anterior en US $ y en %.
go
Create view [Ventas 97] as
Select P.ProductName,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Totales del 97]
from Products as P
inner join [Order Details] as OD
on P.ProductID=OD.ProductID
inner join Orders as O
on OD.OrderID=O.OrderID
where year(O.OrderDate)=1997
group by P.ProductName
go

create view [Ventas 96] as
Select P.ProductName,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Totales del 96]
from Products as P
inner join [Order Details] as OD
on P.ProductID=OD.ProductID
inner join Orders as O
on OD.OrderID=O.OrderID
where year(O.OrderDate)=1996
group by P.ProductName
go

Select V97.ProductName,
	   V97.[Ventas Totales del 97],
	   (V97.[Ventas Totales del 97]-V96.[Ventas Totales del 96]) as Aumento_Disminución,
	   (V97.[Ventas Totales del 97]-V96.[Ventas Totales del 96])/V97.[Ventas Totales del 97]*100 as Porcentaje
from [Ventas 97] as V97
inner join [Ventas 96] as V96
on V97.ProductName=V96.ProductName

--12. Mejor cliente (el que más nos compra) de cada país.
go
create view [Compras Clientes] as 
Select C.CustomerID,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Totales],
	   O.ShipCountry
from Customers as C
inner join Orders as O
on C.CustomerID=O.CustomerID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
group by C.CustomerID,O.ShipCountry
go

Select CustomerID,
	   [Ventas Totales],
	   C.ShipCountry
from [Compras Clientes] as C
inner join(
Select max([Ventas Totales]) as MaxVT,
	   ShipCountry
from [Compras Clientes]
group by ShipCountry
) as CMax
on C.[Ventas Totales]=CMax.MaxVT and C.ShipCountry=CMax.ShipCountry

--13. Número de productos diferentes que nos compra cada cliente.

Select C.CustomerID,
	   count(P.ProductID) as [Productos diferentes]
from Customers as C
inner join Orders as O
on C.CustomerID=O.CustomerID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
group by C.CustomerID

--14. Clientes que nos compran más de cinco productos diferentes.

Select C.CustomerID,
	   count(P.ProductID) as [Productos diferentes]
from Customers as C
inner join Orders as O
on C.CustomerID=O.CustomerID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
inner join Products as P
on OD.ProductID=P.ProductID
group by C.CustomerID
having  count(P.ProductName)>5

--15. Vendedores que han vendido una mayor cantidad que la media en US $ en el
--año 97.
Select E.EmployeeID as Empleado,
	   E.FirstName,
	   E.LastName,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Empleado en 97]
from [Order Details] as OD
inner join Orders as O
on OD.OrderID=O.OrderID
inner join Employees as E
on O.EmployeeID=E.EmployeeID
where year(O.OrderDate)=1997
group by E.EmployeeID,E.FirstName,E.LastName
	having (Select AVG([Ventas Empleado en 97]) 
	from (
		Select sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Empleado en 97]
		from [Order Details] as OD
		inner join Orders as O
		on OD.OrderID=O.OrderID
		where year(O.OrderDate)=1997
		group by O.EmployeeID
	) as VE97)<=sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount))




--16. Empleados que hayan aumentado su cifra de ventas más de un 10% entre dos
--años consecutivos, indicando el año en que se produjo el aumento.
Select Ventas97.EmployeeID,
	   Ventas97.Año,
	   Ventas97.[Ventas Empleado en 97],
	   Ventas96.[Ventas Empleado en 96]
from (Select O.EmployeeID,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Empleado en 97],
	   year(O.OrderDate) as Año
	from [Order Details] as OD
	inner join Orders as O
	on OD.OrderID=O.OrderID
	where year(O.OrderDate)=1997
	group by O.EmployeeID,year(O.OrderDate)
	) as Ventas97
inner join
	(Select O.EmployeeID,
						sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Empleado en 96]
		from [Order Details] as OD
		inner join Orders as O
		on OD.OrderID=O.OrderID
		where year(O.OrderDate)=1996
		group by O.EmployeeID
	) as Ventas96
on Ventas97.EmployeeID=Ventas96.EmployeeID
where (Ventas97.[Ventas Empleado en 97]-Ventas96.[Ventas Empleado en 96])/Ventas96.[Ventas Empleado en 96]*100>=10
group by Ventas97.EmployeeID,Ventas97.Año,Ventas97.[Ventas Empleado en 97],Ventas96.[Ventas Empleado en 96]


Select Ventas98.EmployeeID,
	   Ventas98.Año,
	   Ventas98.[Ventas Empleado en 98],
	   Ventas97.[Ventas Empleado en 97]
from (Select O.EmployeeID,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Empleado en 98],
	   year(O.OrderDate) as Año
	from [Order Details] as OD
	inner join Orders as O
	on OD.OrderID=O.OrderID
	where year(O.OrderDate)=1998
	group by O.EmployeeID,year(O.OrderDate)
	) as Ventas98
inner join
	(Select O.EmployeeID,
						sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Empleado en 97]
		from [Order Details] as OD
		inner join Orders as O
		on OD.OrderID=O.OrderID
		where year(O.OrderDate)=1997
		group by O.EmployeeID
	) as Ventas97
on Ventas98.EmployeeID=Ventas97.EmployeeID
where (Ventas98.[Ventas Empleado en 98]-Ventas97.[Ventas Empleado en 97])/Ventas97.[Ventas Empleado en 97]*100>=10
group by Ventas98.EmployeeID,Ventas98.Año,Ventas98.[Ventas Empleado en 98],Ventas97.[Ventas Empleado en 97]


------------------------------------------------------------ALTERNATIVO BUENO---------------------------------------------------------------

Select O.EmployeeID,
	   E.FirstName,
	   E.LastName,
	   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Empleado],
	   year(O.OrderDate) as AÑO2
from [Order Details] as OD
inner join Orders as O
on OD.OrderID=O.OrderID
inner join Employees as E
on O.EmployeeID=E.EmployeeID
inner join
	(
	Select O.EmployeeID,
		   sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ventas Empleado],
		   year(O.OrderDate) as AÑO
	from [Order Details] as OD
	inner join Orders as O
	on OD.OrderID=O.OrderID
	group by O.EmployeeID,year(O.OrderDate)
	) as Facturado
on O.EmployeeID=Facturado.EmployeeID and year(O.Orderdate)-AÑO=1
group by O.EmployeeID,year(O.OrderDate),Facturado.[Ventas Empleado],E.FirstName,E.LastName
having (sum(OD.Quantity*OD.UnitPrice*(1-OD.Discount))-Facturado.[Ventas Empleado])/Facturado.[Ventas Empleado]*100>=10
