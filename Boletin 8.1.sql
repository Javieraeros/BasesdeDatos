Use Northwind
go

--1. Nombre del país y número de clientes de cada país, ordenados alfabéticamente por el nombre del país.

select Country
	  ,count(*) as [Número de Clientes]
from Customers
group by Country
order by Country
go

--2. ID de producto y número de unidades vendidas de cada producto. 

select OD.ProductID
	  ,ProductName
	  ,sum(Quantity) as [Unidades Vendidas]

from [Order Details] as OD
inner join Products as P
on OD.ProductID=P.ProductID
group by OD.ProductID,P.ProductName
go

--3. ID del cliente y número de pedidos que nos ha hecho.

select CustomerID
	  ,count(OrderID)
from Orders
group by CustomerID
go

--4. ID del cliente, año y número de pedidos que nos ha hecho cada año.

select CustomerID
	  ,year(Orderdate) as Año
	  ,count(OrderID) as [Numero de Pedidos]
from Orders
group by CustomerID,year(OrderDate)
order by CustomerID
go

--5. ID del producto, precio unitario y total facturado de ese producto, ordenado por cantidad facturada de mayor a menor. 
--Si hay varios precios unitarios para el mismo producto tomaremos el mayor.

Select ProductID
	  ,max(UnitPrice)
	  ,sum(Quantity*UnitPrice) as CantidadTotal
From [Order Details]
group by ProductID
order by CantidadTotal DESC
go

--6. ID del proveedor e importe total del stock acumulado de productos correspondientes a ese proveedor.

Select SupplierID
	  ,sum(UnitPrice*UnitsInStock) as [Importe total]
from Products
group by SupplierID
go

--7. Número de pedidos registrados mes a mes de cada año.

Select Count(OrderID) as [Número de Pedidos]
	  ,month(OrderDate) as Mes
	  ,YEAR(OrderDate) as Año

from Orders
group by month(OrderDate),YEAR(OrderDate)
order by year(OrderDate),month(OrderDate)
go

--8. Año y tiempo medio transcurrido entre la fecha de cada pedido (OrderDate) y la fecha en la que lo hemos enviado (ShipDate), 
--en días para cada año.

Select YEAR(OrderDate) as Año
	  ,AVG(cast (ShippedDate-OrderDate as int)) as Media
from [Orders]
group by YEAR(OrderDate)
 
Select YEAR(OrderDate) as Año
	  ,AVG(DATEDIFF(dd,OrderDate,ShippedDate)) as Media
from [Orders]
group by YEAR(OrderDate)
go
--9. ID del distribuidor y número de pedidos enviados a través de ese distribuidor.

Select ShipVia
	  ,COUNT(OrderID) as [Numero de Pedidos]
from Orders
group by ShipVia
go

--10. ID de cada proveedor y número de productos distintos que nos suministra.

select SupplierID
	  ,COUNT(ProductID) as [Número de Productos]

from Products
group by SupplierID
go