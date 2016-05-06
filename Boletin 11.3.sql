--Unidad 11. Programaci�n avanzada de SQL Server
Use TransLeo
go
--Ejercicio 1
--La empresa de log�stica (transportes y algo m�s) TransLeo tiene una base de datos con la informaci�n 
--de los env�os que realiza. Hay una tabla llamada TL_PaquetesNormales en la que se guardan los datos 
--de los paquetes que pueden meterse en una caja normal. Las cajas normales son paralelep�pedos de base rectangular. 
--Las columnas alto, ancho y largo, de tipo entero, contienen las dimensiones de cada paquete en cent�metros.

--1. Crea un funci�n fn_VolumenPaquete que reciba el c�digo de un paquete y nos devuelva su volumen.
--El volumen se expresa en litros (dm3) y ser� de tipo decimal(6,2).
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
--Crea una funci�n fn_PapelEnvolver que reciba un c�digo de paquete y nos devuelva la cantidad de papel necesaria para envolverlo, en metros cuadrados.

CREATE FUNCTION fn_PapelEnvolver (@codigo int) RETURNS decimal(6,2) AS
BEGIN
	SET NOCOUNT ON
	declare @resultado decimal(6,2)
	Select @resultado=(cast((Alto*Ancho+Alto*Largo+Ancho*Largo)as decimal(6,2))*2/10000)*1.8 from TL_PaquetesNormales
		where Codigo=@codigo
	RETURN @resultado
END
GO
--3. Crea una funci�n fn_OcupacionFregoneta a la que se pase el c�digo de un veh�culo y una fecha y nos indique 
--cu�l es el volumen total que ocupan los paquetes que ese veh�culo entreg� en el d�a en cuesti�n. 
--Usa las funciones de fecha y hora para comparar s�lo el d�a, independientemente de la hora.
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
--4. Crea una funci�n fn_CuantoPapel a la que se pase una fecha y nos diga la cantidad total de papel de envolver que se gast� 
--para los paquetes entregados ese d�a. Trata la fecha igual que en el anterior.
--5. Modifica la funci�n anterior para que en lugar de aceptar una fecha, acepte un rango de fechas (inicio y fin). 
--Si el inicio y fin son iguales, calcular� la cantidad gastada ese d�a. Si el fin es anterior al inicio devolver� 0.
--6. Crea una funci�n fn_Entregas a la que se pase un rango de fechas y nos devuelva una tabla con los c�digos 
--de los paquetes entregados y los veh�culos que los entregaron entre esas fechas.