USE Ejemplos
GO
Create Table Regalos (
	ID TinyInt Not NULL
	,Denominacion NVarChar (50) Not NULL
	,Ancho TinyInt NULL
	,Largo TinyInt NULL
	,Alto TinyInt NULL
	,Tipo Char(1) NULL
	,EdadMinima TinyInt Not NULL
	,Precio SmallMoney Not NULL
	,Superficie AS CAST(Ancho AS SmallInt) * Largo
	,CONSTRAINT PK_Regalos Primary Key (ID)
)
GO
USE [Ejemplos]
GO
INSERT INTO Regalos (ID,Denominacion,Ancho,Largo,Alto,Tipo,EdadMinima,Precio)
     VALUES (1,'Muñeca meona',15,10,80,'M',3,45.50)
	 ,(4,'Exin chabola',45,85,20,'C',6,17.20)
	 ,(7,'Patinete',35,90,30,'A',6,38.00)
	 ,(11,'Trompo',15,15,20,'A',4,4.80)
	 ,(13,'QuimiPum',45,75,20,'E',10,14.25)
	 ,(16,'Magia Potagia',50,80,20,'S',8,19.70)
	 ,(18,'Enredos',55,65,20,'A',5,14.85)
	 ,(22,'Action Man Skin Head',20,15,50,'M',4,17.20)
	 ,(6,'Action Man Latin King',20,15,50,'M',4,17.20)
GO
SELECT Denominacion, EdadMinima, Precio FROM Regalos 
    WHERE Precio < 15

SELECT ID, Denominacion FROM Regalos 
    WHERE EdadMinima Between 5 AND 8

SELECT ID, Superficie*Alto, Precio FROM Regalos 
    WHERE Tipo IN ('M','T','E','F') AND Precio > 15

SELECT Denominacion, YEAR(GETDATE()) - EdadMinima FROM Regalos
    WHERE ID % 3 = 0

SELECT ID, EdadMinima FROM Regalos
	WHERE Superficie < 1000 AND Alto < 50 AND EdadMinima <= 5
