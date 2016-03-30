--Boletin 7.3
--Consultas sobre una sola Tabla sin agregados
USE [AdventureWorks2014]
GO
--Nombre, numero de producto, precio y color de los productos de color rojo o amarillo cuyo precio esté comprendido entre 50 y 500
SELECT [Name]
      ,[ProductNumber]
	  ,[ListPrice]
      ,[Color]
      
  FROM [Production].[Product]
  WHERE color in ('Yellow','Red') and ListPrice between 50 and 500
GO

--Nombre, número de producto, precio de coste,  precio de venta, margen de beneficios total y margen de beneficios en % del precio de venta de los productos 
--de categorías inferiores a 16
SELECT [ProductID]
      ,[Name]
      ,[StandardCost]
      ,[ListPrice]
      ,ListPrice-StandardCost AS Beneficios
	  ,(ListPrice-StandardCost)/StandardCost*100 AS Porcentaje
  FROM [Production].[Product]
  WHERE ProductSubcategoryID<16
GO

--Empleados cuyo nombre o apellidos contenga la letra "r". Los empleados son los que tienen el valor "EM" en la columna PersonType de la tabla Person
SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[AdditionalContactInfo]
      ,[Demographics]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Person].[Person]
  WHERE PersonType='EM' and (FirstName like '%r%' or LastName like '%r%')
GO


--LoginID, nationalIDNumber, edad y puesto de trabajo (jobTitle) de los empleados (tabla Employees) de sexo femenino que tengan más de cinco años de antigüedad
SELECT [NationalIDNumber]
      ,[LoginID]
      
      ,[JobTitle]
      ,year(CURRENT_TIMESTAMP- cast ([BirthDate] as datetime))-1900 as Edad
  FROM [HumanResources].[Employee]
  WHERE Gender='F' and year(CURRENT_TIMESTAMP- cast (HireDate as datetime))-1900>=5
GO

--Ciudades correspondientes a los estados 11, 14, 35 o 70, sin repetir. Usar la tabla Person.Address
SELECT distinct City
FROM Person.Address
Where  StateProvinceID in (11,14,35,70) 
go
