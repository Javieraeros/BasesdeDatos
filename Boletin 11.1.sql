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

--1,5.Comprueba si existe una tabla llamada ProductSales. Esta tabla ha de tener de cada producto el ID, el Nombre, 
--el Precio unitario, el número total de unidades vendidas y el total de dinero facturado con ese producto. Si no existe, créala

Begin Transaction
If Object_ID('ProductSales') is Null
Begin
Create Table ProductSales(
ID int constraint PK_ProductSales primary key  Not Null
, Nombre nvarchar(20)  null
, PrecioUnitario money null 
, UnidadesVendidas int not null constraint CK_UnidadesMinimas check ([UnidadesVendidas]>=0)
, Facturado as PrecioUnitario*UnidadesVendidas
,constraint FK_Product_ProductSales foreign key (ID) references Products (ProductID)
on delete no action on update cascade
)
End
rollback
Use Northwind
--2.Comprueba si existe una tabla llamada ShipShip. Esta tabla ha de tener de cada Transportista el ID, el Nombre de la compañía, 
--el número total de envíos que ha efectuado y el número de países diferentes a los que ha llevado cosas. Si no existe, créala

--3.Comprueba si existe una tabla llamada EmployeeSales. Esta tabla ha de tener de cada empleado su ID, el Nombre completo, 
--el número de ventas totales que ha realizado, el número de clientes diferentes a los que ha vendido y el total de dinero facturado. 
--Si no existe, créala