--Usa la base de datos NorthWind
Use Northwind
go
--1.Inserta un nuevo cliente.

begin transaction
insert into Customers
		VALUES
           ('FJRR'
           ,'JaviCO'
           ,'Francisco Javier Ruiz'
           ,'Señor'
           ,'Platino 42'
           ,'Utrera'
           ,'Andalucia'
           ,'41710'
           ,'España'
           ,'627173419'
           ,'')


--commit transaction
--2.Véndele (hoy) tres unidades de "Pavlova”, diez de "Inlagd Sill” y 25 de "Filo Mix”. El distribuidor será Speedy Express 
--y el vendedor Laura Callahan.

Begin transaction
INSERT INTO [dbo].[Orders]
           ([CustomerID]
           ,[EmployeeID]
           ,[OrderDate]
           ,[RequiredDate]
           ,[ShippedDate]
           ,[ShipVia]
           ,[Freight]
           ,[ShipName]
           ,[ShipAddress]
           ,[ShipCity]
           ,[ShipRegion]
           ,[ShipPostalCode]
           ,[ShipCountry])
	Select distinct
           'FJRR'
           ,E.EmployeeID
           ,CURRENT_TIMESTAMP
           ,Null
           ,Null
           ,S.ShipperID
           ,0
           ,Null
           ,Null
           ,Null
           ,Null
           ,Null
           ,Null
	from Employees as E
	inner join Orders as O
	on E.EmployeeID=O.EmployeeID
	inner join Shippers as S
	on O.ShipVia=S.ShipperID
	where E.EmployeeID =(
		Select EmployeeID
		from Employees
		where FirstName='Laura' and LastName='Callahan'
		)
				and
		S.ShipperID =(
		Select ShipperID
		from Shippers
		where CompanyName='Speedy Express'
		)

INSERT INTO [dbo].[Order Details]
           ([OrderID]
           ,[ProductID]
           ,[UnitPrice]
           ,[Quantity]
           ,[Discount])
     Select distinct 
           O.OrderID
           ,P.ProductID
           ,P.UnitPrice
           ,3
           ,0.00
		   from Orders as O
		   cross join [Order Details] as OD
		   cross join Products as P
		   where O.OrderID in (Select O.OrderID from Orders as O where O.CustomerID='FJRR' ) and
				 P.ProductID in (Select P.ProductID from Products as P where P.ProductName='Pavlova')
		   


INSERT INTO [Order Details]
           ([OrderID]
           ,[ProductID]
           ,[UnitPrice]
           ,[Quantity]
           ,[Discount])
     Select distinct
           O.OrderID
           ,P.ProductID
           ,P.UnitPrice
           ,10
           ,0
		   from Orders as O
		   cross join [Order Details] as OD
		   cross join Products as P
		   where O.OrderID in (Select O.OrderID from Orders as O where O.CustomerID='FJRR' ) and
				 P.ProductID in (Select P.ProductID from Products as P where P.ProductName='Inlagd Sill')


INSERT INTO [dbo].[Order Details]
           ([OrderID]
           ,[ProductID]
           ,[UnitPrice]
           ,[Quantity]
           ,[Discount])
     Select distinct
           O.OrderID
           ,P.ProductID
           ,P.UnitPrice
           ,25
           ,0
		   from Orders as O
		   cross join [Order Details] as OD
		   cross join Products as P
		   where O.OrderID in (Select O.OrderID from Orders as O where O.CustomerID='FJRR' ) and
				 P.ProductID in (Select P.ProductID from Products as P where P.ProductName='Filo Mix')
GO
Select * from Orders
Select * from [Order Details]
Rollback transaction
--commit transaction   
GO





--3.Ante la bajada de ventas producida por la crisis, hemos de adaptar nuestros precios según las siguientes reglas:
--	Los productos de la categoría de bebidas (Beverages) que cuesten más de $10 reducen su precio en un dólar.
--	Los productos de la categoría Lácteos que cuesten más de $5 reducen su precio en un 10%.
--	Los productos de los que se hayan vendido menos de 200 unidades en el último año, reducen su precio en un 5%


--4.Inserta un nuevo vendedor llamado Michael Trump. Asígnale los territorios de Louisville, Phoenix, Santa Cruz y Atlanta.


--5.Haz que las ventas del año 97 de Robert King que haya hecho a clientes de los estados de California y Texas se le asignen al 
--nuevo empleado.


--6.Inserta un nuevo producto con los siguientes datos:
--	ProductID: 90
--	ProductName: Miel El Zangano Zumbón
--	SupplierID: 12
--	CategoryID: 3
--	QuantityPerUnit: 10 x 300g
--	UnitPrice: 2,40
--	UnitsInStock: 38
--	UnitsOnOrder: 0
--	ReorderLevel: 0
--	Discontinued: 0


--7.Inserta un nuevo producto con los siguientes datos:
--	ProductID: 91
--	ProductName: Licor de bellotas
--	SupplierID: 1
--	CategoryID: 1
--	QuantityPerUnit: 6 x 75 cl
--	UnitPrice: 7,35
--	UnitsInStock: 14
--	UnitsOnOrder: 0
--	ReorderLevel: 0
--	Discontinued: 0


--8.Todos los que han comprado "Outback Lager" han comprado cinco años después la misma cantidad de Licor de Bellota al mismo vendedor


--9.El pasado 20 de enero, Margaret Peacock consiguió vender una caja de Miel El Zangano Zumbón a todos los clientes que le habían comprado 
--algo anteriormente. Los datos de envío (dirección, transportista, etc) son los mismos de alguna de sus ventas anteriores a ese cliente).

