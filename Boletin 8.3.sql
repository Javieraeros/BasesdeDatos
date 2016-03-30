--Consultas 8.3
USE AdventureWorks2012
go

--Consultas sencillas
--1.Nombre del producto, código y precio, ordenado de mayor a menor precio
select ProductID
	  ,Name
	  ,ListPrice
from Production.Product
order by ListPrice desc


--2.Número de direcciones de cada Estado/Provincia
select A.StateProvinceID
	  ,count(*) as [Número de direcciones por provincia]
	  ,SP.Name
from Person.Address as A
inner join Person.StateProvince as SP
on A.StateProvinceID=SP.StateProvinceID
group by A.StateProvinceID,SP.Name
--3.Nombre del producto, código, número, tamaño y peso de los productos que estaban a la venta durante todo el mes de septiembre de 2002. 
--No queremos que aparezcan aquellos cuyo peso sea superior a 2000.
Select Name
	  ,ProductID
	  ,ProductNumber
	  ,Weight
From Production.Product
where Weight<2000  and SellStartDate<DATEFROMPARTS(2002,09,01) and (SellEndDate>=DATEFROMPARTS(2002,10,01) or SellEndDate is null)
go


--4.Margen de beneficio de cada producto (Precio de venta menos el coste), y porcentaje que supone respecto del precio de venta.
Select (ListPrice-StandardCost) as [Margen de beneficio]
	  ,(ListPrice-StandardCost)/ListPrice*100 as [Porcentaje de beneficios]
from Production.Product
where ListPrice<>0


--Consultas de dificultad media
--5.Número de productos de cada categoría

Select ProductSubcategoryID
	  ,count(ProductID) as [Número de productos de cada categoria]
from Production.Product
where ProductSubcategoryID is not null
group by ProductSubcategoryID
go

--6.Igual a la anterior, pero considerando las categorías generales (categorías de categorías).

Select C.ProductCategoryID
	  ,count(P.ProductID) as [Número de productos de cada categoria]
from Production.Product as P
inner join Production.ProductSubcategory as C
on P.ProductSubcategoryID=C.ProductSubcategoryID
where C.ProductcategoryID is not null
group by ProductCategoryID
go


--7.Número de unidades vendidas de cada producto cada año.

Select ProductID
	  ,sum(OrderQty) as [Número de productos]
	  ,year(OrderDate) as Año
from Sales.SalesOrderDetail as SOD
inner join Sales.SalesOrderHeader as S
on SOD.SalesOrderID=S.SalesOrderID
group by ProductID,year(OrderDate)

--8.Nombre completo, compañía y total facturado a cada cliente
Select P.FirstName
	  ,P.MiddleName
	  ,P.LastName
	  ,S.Name
	  ,sum(SOD.OrderQty*(SOD.UnitPrice*(1-SOD.UnitPriceDiscount))) as [Total Facturado ]
from Sales.Customer as C
inner join Person.Person as P
on C.PersonID=P.BusinessEntityID
inner join Sales.Store as S
on C.StoreID=S.BusinessEntityID
inner join Sales.SalesOrderHeader as SOH
on C.CustomerID=SOH.CustomerID
inner join sales.SalesOrderDetail as SOD
on SOH.SalesOrderID=SOD.SalesOrderID
group by P.FirstName,P.MiddleName,P.LastName,S.Name


--9.Número de producto, nombre y precio de todos aquellos en cuya descripción aparezcan las palabras "race”, "competition” o "performance”

Select P.ProductNumber
	  ,P.Name
	  ,P.ListPrice
	  ,PD.Description
from Production.Product as P
inner join Production.ProductModel as PM
on P.ProductModelID=PM.ProductModelID
inner join Production.ProductModelProductDescriptionCulture as PMPDC
on PMPDC.ProductModelID=PM.ProductModelID
inner join Production.ProductDescription as PD
on PMPDC.ProductDescriptionID=PD.ProductDescriptionID
where PD.Description like '%race%' or PD.Description like '%competition%' or PD.Description like '%performance%'

--Consultas avanzadas
--10.Facturación total en cada país

Select sum(SOD.OrderQty*(SOD.UnitPrice*(1-SOD.UnitPriceDiscount))) as [Total Facturado ]
	  ,ST.CountryRegionCode
from Sales.SalesOrderHeader as SOH
inner join Sales.SalesOrderDetail as SOD
on SOH.SalesOrderID=SOD.SalesOrderID
inner join Sales.SalesTerritory as ST
on SOH.TerritoryID=ST.TerritoryID
group by CountryRegionCode

--11.Facturación total en cada Estado

Select sum(SOD.OrderQty*(SOD.UnitPrice*(1-SOD.UnitPriceDiscount))) as [Total Facturado ]
	  ,SP.Name
from Sales.SalesOrderHeader as SOH
inner join Sales.SalesOrderDetail as SOD
on SOH.SalesOrderID=SOD.SalesOrderID
inner join Person.Address as A
on SOH.ShipToAddressID=A.AddressID
inner join Person.StateProvince as SP
on A.StateProvinceID=SP.StateProvinceID
group by SP.Name
order by SP.Name
--12.Margen medio de beneficios y total facturado en cada país

Select ST.CountryRegionCode 
	  ,avg(SOD.OrderQty*(SOD.UnitPrice*(1-SOD.UnitPriceDiscount)-P.StandardCost)) as [Total Facturado]
from Sales.SalesOrderDetail as SOD
inner join Production.Product as P
on SOD.ProductID=P.ProductID
inner join Sales.SalesOrderHeader as SOH
on SOD.SalesOrderID=SOH.SalesOrderID
inner join Sales.SalesTerritory as ST
on SOH.TerritoryID=ST.TerritoryID
group by CountryRegionCode