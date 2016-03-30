USE [TransLeo]
GO

INSERT INTO [dbo].[Provincias]
           ([Código_Postal]
           ,[Provincia])
     VALUES(
           48080
		   , 'Madriles')
GO
INSERT INTO [dbo].[Provincias]
           ([Código_Postal]
           ,[Provincia])
     VALUES(
           41710
		   ,'Seviya')
GO


INSERT INTO [dbo].[Centros]
           ([Denominación]
           ,[Dirección]
           ,[Ciudad]
           ,[Código_Postal]
           ,[Teléfono]
           ,[Teléfono_Alternativo])
     VALUES
           ('Sentro Educatibo'
           ,'Al lao der Mah, prehmo'
           ,'Seviya'
           ,41710
           ,555555555
           ,555555569)
GO
INSERT INTO [dbo].[Centros]
           ([Denominación]
           ,[Dirección]
           ,[Ciudad]
           ,[Código_Postal]
           ,[Teléfono])
     VALUES
           ('Centro Educativo Serio'
           ,'C\San Juan Bosco nº59'
           ,'Madriles'
           ,48080
           ,955432121
		   )
go

select * Provincias