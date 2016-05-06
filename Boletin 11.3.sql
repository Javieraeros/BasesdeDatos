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

CREATE FUNCTION fn_PapelEnvolver (@codigo int) RETURNS decimal(6,2) AS
BEGIN
	SET NOCOUNT ON
	declare @resultado decimal(6,2)
	Select @resultado=(cast((Alto*Ancho+Alto*Largo+Ancho*Largo)as decimal(6,2))*2/10000)*1.8 from TL_PaquetesNormales
		where Codigo=@codigo
	RETURN @resultado
END
GO
--3. Crea una función fn_OcupacionFregoneta a la que se pase el código de un vehículo y una fecha y nos indique 
--cuál es el volumen total que ocupan los paquetes que ese vehículo entregó en el día en cuestión. 
--Usa las funciones de fecha y hora para comparar sólo el día, independientemente de la hora.
CREATE FUNCTION fn_OcupacionFregoneta (@codigo int,@fecha Date) RETURNS decima(6,2) AS
BEGIN
	SET NOCOUNT ON
	declare @resultado decimal(6,2)
	declare @mitabla table (
	codigo int null,
	volumen decimal(6,2) null
	)
	insert into @mitabla
	EXEC @resultado=fn_VolumenPaquete Select codigo from TL_PaquetesNormales
		where codigoFregoneta=@codigo and cast(fechaEntrega as date)=@fecha
	RETURN @resultado
END
GO
--4. Crea una función fn_CuantoPapel a la que se pase una fecha y nos diga la cantidad total de papel de envolver que se gastó 
--para los paquetes entregados ese día. Trata la fecha igual que en el anterior.
--5. Modifica la función anterior para que en lugar de aceptar una fecha, acepte un rango de fechas (inicio y fin). 
--Si el inicio y fin son iguales, calculará la cantidad gastada ese día. Si el fin es anterior al inicio devolverá 0.
--6. Crea una función fn_Entregas a la que se pase un rango de fechas y nos devuelva una tabla con los códigos 
--de los paquetes entregados y los vehículos que los entregaron entre esas fechas.