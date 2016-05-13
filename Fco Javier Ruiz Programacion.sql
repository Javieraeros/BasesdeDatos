USE ICOTR
go
set dateformat 'ymd'

--Ejercicio 1
--Escribe una función a la que se pase el nombre de un establecimeinto, un contenedor y un rango de fechas y nos devuelva el importe total
-- de los pedidos de ese establecimento que incluyan algún helado con ese contenedro en ese rango
GO
ALTER FUNCTION fn_ImporteContenedorRango(@establecimiento varchar(30),
										  @contendor char(20),
										  @fechainicio date,
										  @fechafin date) 
										  RETURNS decimal(8,2) as
Begin
	Declare @importe decimal(8,2)=0.00

	Select @importe=sum(Importe)        --Tambien podríamos igualar todo el select a @importe con un set.
	From ICPedidos as P
	inner join ICHelados as H
	on P.ID=H.IDPedido
	inner join ICEstablecimientos as E
	on P.IDEstablecimiento=E.ID
	where E.Denominacion=@establecimiento and H.TipoContenedor=@contendor
		  and P.Recibido between @fechainicio and @fechafin    --Tambien podriamos poner con <= y >=,pero así queda más "profesional".
	return @importe
End
GO


Declare @resultado varchar(30)
declare @fechainicio date=DATEFROMPARTS(2014,11,25)
declare @fechafin date=DATEFROMPARTS(2014,12,1)

Execute @resultado=fn_ImporteContenedorRango 'Bolitas fresquitas','Cucurucho',@fechainicio,@fechafin
print @resultado

--Ejerccicio 2:
--A algunos clientes les gusta repetir sus pedidos. Crea un procedimiento al que se pase el nombre de un cliente y una fecha/hora
--y busque el pedido de ese cliente más cercano a esa fecha hora(puede haber un margen de error de más o de menos) y duplique ese pedido
--con los mismos helados,toppings y complementos, en el mismo establecimiento, pero asignándole la fecha/hora actual.Deja la fecha de 
--envío a NULL y asignale como repartido a Paco Bardica.

--Lo primero que haremos será crear ua función que determine el pedido más cercano de un cliente en una fecha determinada.

Go
CREATE FUNCTION fn_PedidoCercano (@nombre varchar(20),
								 @apellidos varchar(30),
								  @fecha smalldatetime) RETURNS smalldatetime as
BEGIN
	declare @fechamayor smalldatetime
	declare @fechamenor smalldatetime
	declare @fechasalida smalldatetime

	--A continuación guardamos seleccionamos y guardamos la fecha anterior y siguiente
	Set @fechamayor=
		(Select MIN(Recibido) 
		 from ICPedidos as P
		 inner join ICClientes as C
		 on P.IDCliente=C.ID
		 where C.Nombre=@nombre and C.Apellidos=@apellidos and Recibido>=@fecha
		 )
	Set @fechamenor=
		(Select MAX(Recibido) 
		 from ICPedidos as P
		 inner join ICClientes as C
		 on P.IDCliente=C.ID
		 where C.Nombre=@nombre and C.Apellidos=@apellidos and Recibido<=@fecha
		 )
	--Ahora comprobamos cual es la más cercana, y asignamos a la fecha de salida la más cercana
	IF(DATEDIFF(MINUTE,@fecha,@fechamayor)<DATEDIFF(MINUTE,@fechamenor,@fecha))
	BEGIN
		SET @fechasalida=@fechamayor
	END
	ELSE
	BEGIN
		SET @fechasalida=@fechamenor
	END
	return @fechasalida
END
Go
Select * from ICPedidos where IDCliente=1
order by Recibido
declare @fechasalida smalldatetime
declare @fechaentrada smalldatetime=cast(N'2012-2-6 16:00:00' as smalldatetime)
EXECUTE @fechasalida=dbo.fn_PedidoCercano 'Aitor','Tilla Perez',@fechaentrada
print @fechasalida



--Para este procedimiento necesitaremos hacer 4 inserciones en las tablas:
--					ICPedidos
--					ICHelados
--					ICPedidosComplementos
--					ICHeladosToppings
Go
CREATE PROCEDURE RepitePedido @nombre varchar(20),
							  @apellidos varchar(30),
							  @fecha smalldatetime as
BEGIN
declare @IDPedidos int
declare @IDHelados int
declare @fechaInsercion smalldatetime
--damos a la fecha el valor más cercano
EXECUTE @fecha=dbo.fn_PedidoCercano @nombre,@apellidos,@fecha
EXECUTE @fechaInsercion=dbo.fn_PedidoCercano @nombre,@apellidos,@fecha

Begin Transaction                  --Para no tener problemas a la hora de seleccionar el nuevo id
set @IDPedidos=(Select MAX(Id) from ICPedidos)+1
	INSERT INTO [dbo].[ICPedidos]
           ([ID]
           ,[Recibido]
           ,[Enviado]
           ,[IDCliente]
           ,[IDEstablecimiento]
           ,[IDRepartidor]
           ,[Importe])
     Select
           @IDPedidos
           ,CURRENT_TIMESTAMP
           ,NULL
           ,IDCliente
           ,P.IDEstablecimiento
           ,R.ID
           ,Importe
	 from ICPedidos as P
	 inner join ICRepartidores as R
	 on P.IDRepartidor=R.ID
	 where R.Nombre='Paco Bardica' and 
		P.Recibido=@fecha
commit transaction

begin transaction
set @IDHelados=(Select MAX(Id) from ICPedidos)+1
INSERT INTO [dbo].[ICHelados]
           ([ID]
           ,[IDPedido]
           ,[TipoContenedor]
           ,[Sabor])
     SELECT
           @IDHelados
           ,p.ID
           ,H.TipoContenedor
           ,H.Sabor
	 FROM ICHelados as H
	 inner join ICPedidos as P
	 on H.IDPedido=P.ID
	 inner join ICClientes as C
	 on P.IDCliente=C.ID
	 where C.Nombre=@nombre and C.Apellidos=@apellidos and P.Recibido=@fecha
Commit Transaction

begin transaction
	INSERT INTO [dbo].[ICPedidosComplementos]
			   ([IDPedido]
			   ,[IDComplemento]
			   ,[Cantidad])
		 SELECT
			   IDPedido
			   ,<IDComplemento, tinyint,>
			   ,<Cantidad, tinyint,>
		 FROM ICPedidosComplementos
commit transaction

END
Go

--Ejercico 3:
--Escribe una función inline a la que pasemos el nombre de un establecimiento y un cpntenedor
--y nos devuelva una tabla con las ventas anueales de ese establecimiento en los últimos 4
--años de pedidos que incluyan algún helado con ese contenedor. Utiliza la función del ejercicio 1.

Go
alter FUNCTION fn_VentasAnualesContenedor (@nombre varchar(20),@contenedor char (20)) RETURNS TABLE AS
RETURN(
	SELECT dbo.fn_ImporteContenedorRango(@nombre,@contenedor,DateAdd(year,-1,Current_Timestamp),CURRENT_TIMESTAMP) as Ventas_Año
	UNION
	SELECT
		   dbo.fn_ImporteContenedorRango(@nombre,@contenedor,DateAdd(year,-2,Current_Timestamp),DateAdd(year,-1,Current_Timestamp))
	UNION
	SELECT
		   dbo.fn_ImporteContenedorRango(@nombre,@contenedor,DateAdd(year,-3,Current_Timestamp),DateAdd(year,-2,Current_Timestamp))
	UNION
	SELECT
		   dbo.fn_ImporteContenedorRango(@nombre,@contenedor,DateAdd(year,-4,Current_Timestamp),DateAdd(year,-3,Current_Timestamp))
)
Go
Select * from ICPedidos
order by Recibido
Select * from fn_VentasAnualesContenedor ('Bolitas fresquitas','cucurucho')

--Ejercicio4:
--Crea una funcion a la que se pase como parametro el nombre de un establecimiento y nos devuelva
--una tabla con dos columnas,hora y topping. La tabla tendrá 24 filas, correspondientes a las 24 horas
--del día y nos dirá qué topping se vende más a cada hora. La fila de hora 0 abarcará desde las 0:00-0:59.

CREATE FUNCTION fn_ToppingsHora (@nombre varchar(30)) 
				Returns @mitabla Table(
						Hora time null,
						Topping vachar(18) null
				) as
Begin

End