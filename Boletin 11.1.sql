--Boletín 11.1
--Unidad 11. Programación en T-SQL
Use NorthWind

--Ejercicios
--1.Deseamos incluir un producto en la tabla Products llamado "Cruzcampo botellín” pero no estamos seguros si se ha insertado o no.
--El precio son 2,40, el proveedor es el 16, la categoría 1 y la cantidad por unidad son "Pack de seis botellines” 
--El resto de columnas se dejarán a NULL.
--Escribe un script que compruebe si existe un producto con ese nombre.Caso afirmativo, actualizará el precio y en caso negativo insertarlo. 
Select * From Products
Begin Transaction

IF 'Cruzcampo botellín' in (Select Products.ProductName from Products)
Begin
Update Products
	Set UnitPrice=2.40
End
ELSE
Begin
INSERT INTO [dbo].[Products]
           ([ProductName]
           ,[SupplierID]
           ,[CategoryID]
           ,[QuantityPerUnit]
           ,[UnitPrice]
           ,[UnitsInStock]
           ,[UnitsOnOrder]
           ,[ReorderLevel]
           ,[Discontinued])
     VALUES
           ('Cruzcampo botellín'
           ,16
           ,1
           ,'Pack de 6 botellines'
           ,2.40
           ,Null
           ,Null
           ,Null
		   ,1)
End
Select * from Products
Rollback

--2.Comprueba si existe una tabla llamada ProductSales. Esta tabla ha de tener de cada producto el ID, el Nombre, 
--el Precio unitario, el número total de unidades vendidas y el total de dinero facturado con ese producto. Si no existe, créala

Begin Transaction
If Object_ID('ProductSales') is Null
Begin
Create Table ProductSales(
ID int constraint PK_ProductSales primary key  Not Null
, Nombre nvarchar(40)  null
, PrecioUnitario money null 
, UnidadesVendidas int not null constraint CK_UnidadesMinimas check ([UnidadesVendidas]>=0)
, Facturado money null
,constraint FK_Product_ProductSales foreign key (ID) references Products (ProductID)
on delete no action on update cascade
)
Insert into ProductSales(ID,Nombre,PrecioUnitario,UnidadesVendidas,Facturado)
Select P.ProductID, P.ProductName, P.UnitPrice, Sum(O.Quantity), Sum(O.Quantity*O.UnitPrice)
from Products as P
inner join [Order Details] as O
on P.ProductID=O.ProductID
group by P.ProductID,P.ProductName,P.UnitPrice
End
Select * from ProductSales
rollback
--3.Comprueba si existe una tabla llamada ShipShip. Esta tabla ha de tener de cada Transportista el ID, el Nombre de la compañía, 
--el número total de envíos que ha efectuado y el número de países diferentes a los que ha llevado cosas. Si no existe, créala
Begin Transaction
If Object_ID('ShipshipJavi') is Null
Begin
Create Table ShipShipJavi(
ID int constraint PK_Shipship primary key  Not Null constraint FK_IDShippers references Shippers 
, NombreCompañía nvarchar(40)  null 
, Envios int not null constraint CK_UnidadesMinimas check ([Envios]>=0)
, Paises int null
)
Insert Into ShipShipJavi(ID,NombreCompañía,Envios,Paises)
Select ShipperID,
	   CompanyName,
	   count(shipvia),
	   count(distinct shipCountry)
	   From Shippers as S
	   inner join Orders as O
	   on O.ShipVia=S.ShipperID
	   group by ShipperID,CompanyName
End
Select*from ShipShipJavi
rollback

--4.Comprueba si existe una tabla llamada EmployeeSales. Esta tabla ha de tener de cada empleado su ID, el Nombre completo, 
--el número de ventas totales que ha realizado, el número de clientes diferentes a los que ha vendido y el total de dinero facturado. 
--Si no existe, créala
Begin Transaction
If Object_ID('EmployeeSales') is Null
Begin
Create Table ShipShip(
ID int constraint PK_Shipship primary key  Not Null
, NombreCompleto nvarchar(50)  null 
, VentasRealizadas int not null constraint CK_UnidadesMinimas check ([VentasRealizadas]>=0)
, Clientes int null
,DineroFacturado money null
)
End
rollback

--5.Entre los años 96 y 97 hay productos que han aumentado sus ventas y otros que las han disminuido. 
--Queremos cambiar el precio unitario según la siguiente tabla:
--Incremento de ventas	Incremento de precio
--Negativo	            -10%
--Entre 0 y 10%           No varía
--Entre 10% y 50%         +5%
--Mayor del 50%			10% con un máximo de 2,25

--Creamos una vista que nos diga las diferencias de un año a otro
go
create view PorcentajeVentas as 
Select P.ProductID,
	   (V97.[Ventas Totales del 97]-V96.[Ventas Totales del 96])/V96.[Ventas Totales del 96]*100 as DiferenciaDeVentas
from [Ventas 97] as V97
inner join [Ventas 96] as V96
on V97.ProductName=V96.ProductName
inner join Products as P
on V97.ProductName=P.ProductName
go

Begin Transaction
Select * From Products
Update Products SET
	UnitPrice=
		Case
		when DiferenciaDeVentas>=50 Then
			case
				when 1.10*UnitPrice>=2.25 then UnitPrice+2.25
				else 1.10*UnitPrice
				End
		when DiferenciaDeVentas>=10 Then 1.05*UnitPrice --Puesto qeu se devuelve la primera, omito las condicioens innecesarias
		when DiferenciaDeVentas>=0  Then UnitPrice
		when DiferenciaDeVentas<0 Then 0.9*UnitPrice
		End
	From PorcentajeVentas
	Where PorcentajeVentas.ProductID=Products.ProductID
Select * From Products
Rollback transaction
