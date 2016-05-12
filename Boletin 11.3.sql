--Unidad 11. Programación avanzada de SQL Server
Use TransLeo
go
--Ejercicio 1
--La empresa de logística (transportes y algo más) TransLeo tiene una base de datos con la información 
--de los envíos que realiza. Hay una tabla llamada TL_PaquetesNormales en la que se guardan los datos 
--de los paquetes que pueden meterse en una caja normal. Las cajas normales son paralelepípedos de base rectangular. 
--Las columnas alto, ancho y largo, de tipo entero, contienen las dimensiones de cada paquete en centímetros.

--1. Crea un función fn_VolumenPaquete que reciba el código de un paquete y nos devuelva su volumen.
--El volumen se expresa en litros (dm3) y será de tipo decimal(6,2).
CREATE FUNCTION fn_VolumenPaquete (@codigo int) RETURNS decimal(6,2) AS
BEGIN
	declare @resultado decimal(6,2)
	Select @resultado=(cast(Alto as decimal(6,2))*Ancho*Largo /1000) from TL_PaquetesNormales
		Where Codigo=@codigo
	RETURN @resultado

END 
GO
declare @paquete decimal(6,2)
EXECUTE @paquete=fn_VolumenPaquete 600
print @paquete
go
--2. Los paquetes normales han de envolverse. Se calcula que la cantidad de papel necesaria para envolver el paquete es 1,8 veces su superficie. 
--Crea una función fn_PapelEnvolver que reciba un código de paquete y nos devuelva la cantidad de papel necesaria para envolverlo, en metros cuadrados.

ALTER FUNCTION fn_PapelEnvolver (@codigo int) RETURNS decimal(6,2) AS
BEGIN
	declare @resultado decimal(6,2)
	Select @resultado=(cast((Alto*Ancho+Alto*Largo+Ancho*Largo)as decimal(10,2))*2/10000)*1.8 from TL_PaquetesNormales
		where Codigo=@codigo
	RETURN @resultado
END
GO

GO
declare @papel decimal(6,2)
EXECUTE @papel=fn_PapelEnvolver 600
print @papel
go
--3. Crea una función fn_OcupacionFregoneta a la que se pase el código de un vehículo y una fecha y nos indique 
--cuál es el volumen total que ocupan los paquetes que ese vehículo entregó en el día en cuestión. 
--Usa las funciones de fecha y hora para comparar sólo el día, independientemente de la hora.
ALTER FUNCTION fn_OcupacionFregoneta (@codigo int,@fecha Date) RETURNS decimal(6,2) AS
BEGIN
	declare @resultado decimal(6,2)
	declare @mitabla table (
	codigo int null,
	volumen decimal(6,2) null
	)
	insert into @mitabla(codigo)
		Select Codigo
		From TL_PaquetesNormales
		where codigoFregoneta=@codigo and cast(fechaEntrega as date)=@fecha
	update @mitabla
		set volumen=dbo.fn_VolumenPaquete(codigo)
		select @resultado=sum(volumen) from @mitabla
	RETURN @resultado
END
GO

GO
SET NOCOUNT ON
declare @ocupación decimal(6,2)
EXECUTE @ocupación=fn_OcupacionFregoneta 6,'2015-04-01'
print @ocupación
Select * from TL_PaquetesNormales
go


--4. Crea una función fn_CuantoPapel a la que se pase una fecha y nos diga la cantidad total de papel de envolver que se gastó 
--para los paquetes entregados ese día. Trata la fecha igual que en el anterior.
GO
CREATE FUNCTION fn_CuantoPapel (@fecha Date) RETURNS decimal(6,2) AS
BEGIN
	declare @resultado decimal(6,2)
	declare @mitabla table (
	codigo int null,
	papel decimal(6,2) null
	)
	insert into @mitabla(codigo)
		Select Codigo
		From TL_PaquetesNormales
		where cast(fechaEntrega as date)=@fecha
	update @mitabla
		set papel=dbo.fn_PapelEnvolver(codigo)
		select @resultado=sum(papel) from @mitabla
	RETURN @resultado
END
GO

GO
SET NOCOUNT ON
declare @papel decimal(6,2)
EXECUTE @papel=fn_CuantoPapel '2015-04-01'
print @papel
go
--5. Modifica la función anterior para que en lugar de aceptar una fecha, acepte un rango de fechas (inicio y fin). 
--Si el inicio y fin son iguales, calculará la cantidad gastada ese día. Si el fin es anterior al inicio devolverá 0.
GO
ALTER FUNCTION fn_CuantoPapelFechas (@fechainicio Date,@fechafin Date) RETURNS decimal(6,2) AS
BEGIN
	declare @resultado decimal(6,2)=0.00
	if(@fechainicio<@fechafin)
	BEGIN
		declare @mitabla table (
		codigo int null,
		papel decimal(6,2) null
		)
		insert into @mitabla(codigo)
			Select Codigo
			From TL_PaquetesNormales
			where cast(fechaEntrega as date) between @fechainicio and @fechafin
		update @mitabla
			set papel=dbo.fn_PapelEnvolver(codigo)
			select @resultado=sum(papel) from @mitabla
	END
	ELSE
	BEGIN
		if(@fechainicio=@fechafin)
		BEGIN
		EXECUTE @resultado=fn_CuantoPapel @fechainicio
		END
	END
	RETURN @resultado
END
GO

GO
SET NOCOUNT ON
declare @papel decimal(6,2)
EXECUTE @papel=fn_CuantoPapelFechas '2015-04-01','2015-04-25'
print @papel
go

--6. Crea una función fn_Entregas a la que se pase un rango de fechas y nos devuelva una tabla con los códigos 
--de los paquetes entregados y los vehículos que los entregaron entre esas fechas.
go
CREATE FUNCTION fn_Entregas (@Fechainicio Date,@FechaFin Date) RETURNS TABLE AS
RETURN (Select Codigo,
			   codigoFregoneta
		From TL_PaquetesNormales
		where cast(fechaEntrega as date)>=@fechainicio and cast(fechaEntrega as date)<=@fechafin
		)
go

Select * from fn_Entregas('2013-03-01','2015-04-06')




--Ejercicio 2:
Use AirLeo
go
set dateformat 'ymd'
--1. Diseña una función fn_distancia recorrida a la que se pase un código de avión y 
--un rango de fechas y nos devuelva la distancia total recorrida por ese avión en ese rango de fechas.
GO
CREATE FUNCTION fn_distancia(@codigo char(10),@fechainicio Date,@fechafin Date) Returns decimal(8,2) as 
BEGIN
Declare @resultado decimal(8,2)
Select @resultado=SUM(Distancia) from AL_Distancias as D
	inner join AL_Vuelos as V
	on D.Origen=V.Aeropuerto_Llegada and D.Destino=V.Aeropuerto_Salida
return @resultado
END
GO
--2. Diseña una función fn_horasVuelo a la que se pase un código de avión y un rango de fechas 
--y nos devuelva las horas totales que ha volado ese avión en ese rango de fechas.
GO
ALTER FUNCTION fn_horasVuelo (@codigo char(10),@fechainicio SmallDateTime,@fechafin SmallDateTime) RETURNS int as
BEGIN
DECLARE @resultado int=-1
	if(@fechainicio<@fechafin)
	BEGIN
		Select @resultado=sum(DATEDIFF(MINUTE,salida,llegada))/60
		from AL_Vuelos
		where Salida>=@fechainicio and Llegada<=@fechafin
				and Matricula_Avion=@codigo
	END
RETURN @resultado
END
GO

Select * from AL_Vuelos where Matricula_Avion='ESP4502'
declare @horas int
Execute @horas=fn_horasVuelo 'ESP4502','2010-11-13 15:00:00','2015-11-14 18:00:00' 
print @horas

--3. Diseña una función a la que se pase un código de avión y un rango de fechas y nos devuelva 
--una tabla con los nombres y fechas de todos los aeropuertos en que ha estado el avión en ese intervalo.
GO
ALTER FUNCTION fn_EstacionamientoAvion (@codigo char(10),@fechainicio SmallDateTime,@fechafin SmallDateTime) 
			   RETURNS @tabla TABLE(
					Nombre_Aeropuerto varchar(30) null,
					Fecha DATE null
) AS
BEGIN
	Insert into @tabla
			(Nombre_Aeropuerto,
			 Fecha)
		SELECT 
			A.Nombre,
			cast(Llegada as Date)
			FROM AL_Vuelos as V
			inner join AL_Aeropuertos as A
			on V.Aeropuerto_Salida=A.Codigo
				where V.Matricula_Avion=@codigo and Salida>=@fechainicio and Llegada<=@fechafin
	
	Insert into @tabla
		(Nombre_Aeropuerto,
		 Fecha)
		SELECT 
			A.Nombre,
			cast(Llegada as Date)
			FROM AL_Vuelos as V
			inner join AL_Aeropuertos as A
			on V.Aeropuerto_Llegada=A.Codigo
				where V.Matricula_Avion=@codigo and Salida>=@fechainicio and Llegada<=@fechafin
	
RETURN
END
GO
Select * from AL_Vuelos where Matricula_Avion='USA5068'
order by Salida
Select * from fn_EstacionamientoAvion('USA5068','2012-01-14 00:00:00','2012-01-30 00:00:00')
order by Fecha
--4. Diseña una función fn_ViajesCliente que nos devuelva nombre y apellidos, 
--kilómetros recorridos y número de vuelos efectuados por cada cliente en un rango de fechas, 
--ordenado de mayor a menor distancia recorrida.