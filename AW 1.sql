--Boletín AW 1
--Escribe vistas que realicen las siguientes consultas sobre la base de datos Adventure Works. Puedes escribir otras vistas adicionales para ayudarte.
--Utiliza VISTAS para simplificar las consultas
Use AdventureWorks2012 --MIERDA
go
--1.Nombre y dirección completas de todos los clientes que tengan alguna sede en Canada.

Select *
from Sales.vStoreWithAddresses
where CountryRegionName in ('Canada')
order by BusinessEntityID

--2.Nombre de cada categoría y producto más caro y más barato de la misma, incluyendo los precios.
go
create view [PreciosExtremosCategoria] as (
Select PC.Name as [Nombre de categoría],
	   max(P.ListPrice) as [Precio más caro],
	   min(P.ListPrice) as [Precio más barato]
from Production.Product as P
inner join Production.ProductSubcategory as PS
on P.ProductSubcategoryID=PS.ProductSubcategoryID
inner join Production.ProductCategory as PC
on PS.ProductCategoryID=PC.ProductCategoryID
group by PC.Name
)
go
Select PEC.[Nombre de categoría],
	   P.Name as [Nombre producto más caro],
	   PEC.[Precio más caro],
	   PMB.[Nombre producto más barato],
	   PEC.[Precio más barato]
from PreciosExtremosCategoria as PEC
inner join Production.ProductCategory as PC
on PEC.[Nombre de categoría]=PC.Name
inner join Production.ProductSubcategory as PSC
on PC.ProductCategoryID=PSC.ProductCategoryID
inner join Production.Product as P
on PSC.ProductSubcategoryID=p.ProductSubcategoryID
inner join (
	Select PEC.[Nombre de categoría],
		   P.Name as [Nombre producto más barato],
		   PEC.[Precio más barato]
	from PreciosExtremosCategoria as PEC
	inner join Production.ProductCategory as PC
	on PEC.[Nombre de categoría]=PC.Name
	inner join Production.ProductSubcategory as PSC
	on PC.ProductCategoryID=PSC.ProductCategoryID
	inner join Production.Product as P
	on PSC.ProductSubcategoryID=p.ProductSubcategoryID
	where P.ListPrice=PEC.[Precio más barato]
) as PMB --Precio más barato
on PEC.[Nombre de categoría]=PMB.[Nombre de categoría]
where P.ListPrice=PEC.[Precio más caro]


--3.Total de Ventas en cada país en dinero (Ya hecha en el boletín 9.3).
go
alter view [Ventas por Pais] as (
Select CR.Name as Pais,
	   sum(SOD.OrderQty*(SOD.UnitPrice*(1-SOD.UnitPriceDiscount))) as [Total Facturado ]
from Sales.SalesOrderHeader as SOH
inner join Sales.SalesOrderDetail as SOD
on SOH.SalesOrderID=SOD.SalesOrderID
inner join Sales.SalesTerritory as ST
on SOH.TerritoryID=ST.TerritoryID
inner join Person.CountryRegion as CR
on ST.CountryRegionCode=CR.CountryRegionCode
group by CR.Name
)
go

--4.Número de clientes que tenemos en cada país. Contaremos cada dirección como si fuera un cliente distinto.
Select CR.Name,
	   count(BEA.AddressID) as [Numero de Clientes]
From Person.Person as P
inner join Person.BusinessEntityAddress as BEA
on P.BusinessEntityID=BEA.AddressID
inner join Person.Address as A
on BEA.AddressID=A.AddressID
inner join Person.StateProvince as SP
on A.StateProvinceID=SP.StateProvinceID
inner join Person.CountryRegion as CR
on SP.CountryRegionCode=CR.CountryRegionCode
group by CR.Name

--5.Repite la consulta anterior pero contando cada cliente una sola vez. Si el cliente tiene varias direcciones, 
--sólo consideraremos aquella en la que nos haya comprado la última vez.
go
Alter view [Ultima compra] as 
Select BEA.BusinessEntityID,
	  max(SOH.OrderDate) as [Fecha última compra],
	  BEA.AddressID as Lugar
From Person.BusinessEntityAddress as BEA
inner join Person.Person as PP
on BEA.BusinessEntityID=PP.BusinessEntityID
inner join Sales.Customer as C
on PP.BusinessEntityID=C.CustomerID
inner join Sales.SalesOrderHeader as SOH
on C.CustomerID=SOH.CustomerID
inner join person.Address as A
on SOH.ShipToAddressID=A.AddressID
group by BEA.BusinessEntityID,BEA.AddressID
go


Select CR.Name,
	   count(BEA.BusinessEntityID) as [Numero de Clientes]
From Person.Person as P
inner join Person.BusinessEntityAddress as BEA
on P.BusinessEntityID=BEA.BusinessEntityID
inner join Person.Address as A
on BEA.AddressID=A.AddressID
inner join Person.StateProvince as SP
on A.StateProvinceID=SP.StateProvinceID
inner join Person.CountryRegion as CR
on SP.CountryRegionCode=CR.CountryRegionCode
where BEA.BusinessEntityID in ( Select BusinessEntityID from [Ultima compra]) 
and BEA.AddressID in (Select Lugar from [Ultima compra])
group by CR.Name
--6.Repite la consulta anterior pero en este caso si el cliente tiene varias direcciones, sólo consideraremos aquella en la que nos 
--haya comprado más.
go
Alter View [Ventas por Direccion] as 
Select BEA.BusinessEntityID,
	  BEA.AddressID,
	  sum(SOD.OrderQty*(SOD.UnitPrice*(1-SOD.UnitPriceDiscount))) as [Total Facturado por Lugar]
From Person.BusinessEntityAddress as BEA
inner join Person.Person as PP
on BEA.BusinessEntityID=PP.BusinessEntityID
inner join Sales.Customer as C
on PP.BusinessEntityID=C.CustomerID
inner join Sales.SalesOrderHeader as SOH
on C.CustomerID=SOH.CustomerID
inner join Sales.SalesOrderDetail as SOD
on SOH.SalesOrderID=SOD.SalesOrderID
inner join person.Address as A
on SOH.ShipToAddressID=A.AddressID
group by BEA.BusinessEntityID,BEA.AddressID
go

Create view [Ventas Maximas] as 
Select BusinessEntityID,
	   AddressID,
	   max([Total Facturado por Lugar])
From [Ventas por Direccion]
go




Select CR.Name,
	   count(BEA.BusinessEntityID) as [Numero de Clientes]
From Person.Person as P
inner join Person.BusinessEntityAddress as BEA
on P.BusinessEntityID=BEA.BusinessEntityID
inner join Person.Address as A
on BEA.AddressID=A.AddressID
inner join Person.StateProvince as SP
on A.StateProvinceID=SP.StateProvinceID
inner join Person.CountryRegion as CR
on SP.CountryRegionCode=CR.CountryRegionCode
inner join [Ventas por Direccion] as VPD
on BEA.BusinessEntityID=VPD.BusinessEntityID
group by CR.Name



--7.Los tres países en los que más hemos vendido, incluyendo la cifra total de ventas y la fecha de la última venta.

Select * from Sales.SalesOrderHeader
order by OrderDate desc

Select top 3
	   CR.Name as Pais,
	   sum(SOD.OrderQty*SOD.UnitPrice*(1-SOD.UnitPriceDiscount)) as [Total Ventas],
	   max(SOH.OrderDate) as [Fecha Última Venta]
from Sales.SalesOrderHeader as SOH
inner join Sales.SalesOrderDetail as SOD
on SOH.SalesOrderID=SOD.SalesOrderID
inner join Sales.SalesTerritory as ST
on SOH.TerritoryID=ST.TerritoryID
inner join Person.CountryRegion as CR
on ST.CountryRegionCode=CR.CountryRegionCode
group by CR.Name
order by  [Total Ventas] desc

--8.Sobre la consulta tres de ventas por país, calcula el valor medio y repite la consulta tres pero incluyendo solamente los países 
--cuyas ventas estén por encima de la media.


Select *
from [Ventas por Pais]
where [Total Facturado] >(
	Select sum([Total Facturado])/count(Pais) 
	from [Ventas por Pais]
	)



--9.Nombre de la categoría y número de clientes diferentes que han comprado productos de cada una.

Select PC.Name,
	   count(Distinct SOH.CustomerID) as [Clientes Diferentes]
from Production.ProductCategory as PC
inner join Production.ProductSubcategory as PS
on PC.ProductCategoryID=PS.ProductCategoryID
inner join Production.Product as P
on PS.ProductSubcategoryID=P.ProductSubcategoryID
inner join Sales.SalesOrderDetail as SOD
on P.ProductID=SOD.ProductID
inner join Sales.SalesOrderHeader as SOH
on SOD.SalesOrderID=SOH.SalesOrderID
group by PC.Name


--10.Clientes que nunca han comprado ninguna bicicleta (discriminarlas por categorías)
go
alter view [Clientes no bicicletas] as (
Select PP.BusinessEntityID,
	   PP.FirstName,
	   PP.LastName
from Production.ProductCategory as PC
inner join Production.ProductSubcategory as PS
on PC.ProductCategoryID=PS.ProductCategoryID
inner join Production.Product as P
on PS.ProductSubcategoryID=P.ProductSubcategoryID
inner join Sales.SalesOrderDetail as SOD
on P.ProductID=SOD.ProductID
inner join Sales.SalesOrderHeader as SOH
on SOD.SalesOrderID=SOH.SalesOrderID
inner join Sales.Customer as C
on SOH.CustomerID=C.CustomerID
inner join Person.Person as PP
on C.PersonID=PP.BusinessEntityID
EXCEPT

Select PP.BusinessEntityID,
	   PP.FirstName,
	   PP.LastName
from Production.ProductCategory as PC
inner join Production.ProductSubcategory as PS
on PC.ProductCategoryID=PS.ProductCategoryID
inner join Production.Product as P
on PS.ProductSubcategoryID=P.ProductSubcategoryID
inner join Sales.SalesOrderDetail as SOD
on P.ProductID=SOD.ProductID
inner join Sales.SalesOrderHeader as SOH
on SOD.SalesOrderID=SOH.SalesOrderID
inner join Sales.Customer as C
on SOH.CustomerID=C.CustomerID
inner join Person.Person as PP
on C.PersonID=PP.BusinessEntityID
where PC.Name in ('Bikes')

)
go
--11.A la consulta anterior, añádele el total de compras (en dinero) efectuadas por cada cliente.
Select *
from [Clientes no bicicletas]


Select P.FirstName,
	   P.LastName,
	   sum(SOD.OrderQty*SOD.UnitPrice*(1-SOD.UnitPriceDiscount)) as [Total de Compras]
from [Clientes no bicicletas] as P
inner join Sales.Customer as C
on P.BusinessEntityID=C.PersonID
inner join Sales.SalesOrderHeader as SOH
on C.CustomerID=SOH.CustomerID
inner join Sales.SalesOrderDetail as SOD
on SOH.SalesOrderID=SOD.SalesOrderID
group by P.Lastname,P.FirstName

