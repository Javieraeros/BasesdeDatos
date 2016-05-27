CREATE DATABASE Ejemplos
go
--Boletin 12.1
--Tabla para pruebas
USE Ejemplos

GO

CREATE TABLE Palabras (

ID SmallInt Not Null Identity Constraint PK_Palabras Primary Key

,Palabra VarChar(30) Null

)

--Nota: No olvides probar cada trigger con diferentes valores.
--Iniciación:
--Sin usar datos modificados
--1.- Queremos que cada vez que se actualice la tabla Palabras aparezca un mensaje diciendo si se han añadido, borrado o actualizado filas.
--Pista: Crea tres triggers diferentes
go
ALTER TRIGGER MensajeAñadido on Palabras AFTER INSERT AS 
declare @Añadidas int
Select @Añadidas=count(ID) from inserted
print 'Se han añadido '+cast(@Añadidas as Varchar)+' filas'
go

go
ALTER TRIGGER MensajeBorrado on Palabras AFTER Delete AS 
declare @Borradas int
Select @Borradas=count(ID) from deleted
print 'Se han borrado '+cast(@Borradas as Varchar)+' filas'
go

go
CREATE TRIGGER MensajeActualizado on Palabras AFTER UPDATE AS 
declare @Actualizadas int
Select @Actualizadas=count(ID) from inserted
print 'Se han actualizado '+cast(@Actualizadas as Varchar)+' filas'
go

Begin Transaction
Insert into Palabras(Palabra)
Values ('Palabra'),('Palabra2')
Update Palabras
	Set Palabra='Cambio'
	where Palabra='Palabra2'
Delete From Palabras
	where Palabra like 'Palab%'
Select * from Palabras
Rollback Transaction

--2.- Haz un trigger que cada vez que se aumente o disminuya el número de filas de la tabla Palabras nos diga cuántas filas hay.

GO
CREATE TRIGGER NumeroFilas ON Palabras AFTER INSERT,DELETE AS
Declare @Filas int
Select @Filas=count(Id) from Palabras
print 'Hay '+cast(@Filas as varchar)+' filas en la tabla palabras'
GO
Begin Transaction
Insert into Palabras(Palabra)
Values ('Javi'),('es'),('tonto')
Delete From Palabras
	where Palabra like 'es'
Select * from Palabras
Rollback transaction

--Medio:
--Se usan inserted y deleted. Si es complicado procesar varias filas, supón que se modifica sólo una.
--3.-  Cada vez que se inserte una fila queremos que se muestre un mensaje indicando "Insertada la palabra ________”

Select * from sys
--4.- Cada vez que se inserten filas que nos diga "XX filas insertadas”

--5.- que no permita introducir palabras repetidas (sin usar UNIQUE).


--Avanzado:
--Se incluye la posibilidad de que se modifiquen varias filas y de que haya que consultar otras tablas.
--6.- Queremos evitar que se introduzcan palabras que terminen en "azo”