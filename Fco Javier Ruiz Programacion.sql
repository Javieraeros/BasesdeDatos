USE ICOTR
go
set dateformat 'ymd'

--Ejercicio 1
--Escribe una función a la que se pase el nombre de un establecimeinto, un contenedor y un rango de fechas y nos devuelva el importe total
-- de los pedidos de ese establecimento que incluyan algún helado con ese contenedro en ese rango
GO
CREATE FUNCTION fn_ImporteContenedorRango(@establecimiento varchar(30),
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
Go
/*Para este procedimiento necesitaremos hacer 4 inserciones en las tablas:
					ICPedidos
					ICHelados
					ICPedidosComplementos
					ICHeladosToppings
*/
Go
ALTER PROCEDURE RepitePedido @nombre varchar(20),
							  @apellidos varchar(30),
							  @fecha smalldatetime as
BEGIN
	declare @UltimoIDPedidos int,@IDPedidoCopiar int, @UltimoIDHelados int,@IDRepartidor int
	declare @fechaInsercion smalldatetime


	--En esta tabla guardaremos la información de los helados que vamos a repetir, siendo ID el nuevo ID que le vamos a asignar
	declare @tablaHelados Table([ID] [bigint] NOT NULL,
			[IDAntiguo] [bigint] NOT NULL,
			[IDPedido] [bigint] NOT NULL,
			[TipoContenedor] [char](20) NOT NULL,
			[Sabor] [char](12) NOT NULL)

	--damos a la fecha el valor más cercano
	EXECUTE @fechaInsercion=dbo.fn_PedidoCercano @nombre,@apellidos,@fecha

	Select @IDPedidoCopiar=ID   --Guardamos el ID del pedido que vamos a copiar
	from ICPedidos
		where IDCliente in (
			Select ID
			from ICClientes
				where Nombre=@nombre and @apellidos=Apellidos)
			  and @fechaInsercion=Recibido

	--Buscamos el Id del repartidor (por legibilidad,para evitar una subconsulta en un insert-select)
	select @IDRepartidor=ID 
	from ICRepartidores 
		where Nombre='Paco' and Apellidos='Bardica'
	

	--Insertamos el pedido
	Begin Transaction                  --Para bloquear la tabla a la hora de seleccionar el nuevo id
	set @UltimoIDPedidos=(Select MAX(Id) from ICPedidos)+1
		INSERT INTO [dbo].[ICPedidos]
			   ([ID]
			   ,[Recibido]
			   ,[Enviado]
			   ,[IDCliente]
			   ,[IDEstablecimiento]
			   ,[IDRepartidor]
			   ,[Importe])
		 Select
			   @UltimoIDPedidos
			   ,CURRENT_TIMESTAMP
			   ,NULL
			   ,P.IDCliente
			   ,P.IDEstablecimiento
			   ,@IDRepartidor
			   ,P.Importe
		 from ICPedidos as P
			where P.ID=@IDPedidoCopiar
	commit transaction


	--Insertamos los helados del nuevo pedido en la tabla temporal, insertando también la ID antigua, que la usaremos para insertar los toppings
	begin transaction
	set @UltimoIDHelados=(Select MAX(Id) from ICHelados)
	INSERT INTO @TablaHelados
			   ([ID],
			    [IDAntiguo]
			   ,[IDPedido]
			   ,[TipoContenedor]
			   ,[Sabor])
		 SELECT
			   @UltimoIDHelados+ROW_NUMBER() OVER(ORDER BY H.ID DESC)
			   ,H.ID
			   ,@UltimoIDPedidos
			   ,H.TipoContenedor
			   ,H.Sabor
		 FROM ICHelados as H
		 inner join ICPedidos as P
		 on H.IDPedido=P.ID
			where P.ID=@IDPedidoCopiar
	Commit Transaction

	--Insertamos ahora en la tabla helados
	begin transaction
	Insert into dbo.ICHelados
			   ([ID]
			   ,[IDPedido]
			   ,[TipoContenedor]
			   ,[Sabor])
		 SELECT
				ID,
				IDPedido,
				TipoContenedor,
				Sabor
		 from @tablaHelados
	Commit Transaction

	--Ahora insertamos en la tabla de Pedidos Complementos los complementos del anterior pedido
	begin transaction
		INSERT INTO [dbo].[ICPedidosComplementos]
				   ([IDPedido]
				   ,[IDComplemento]
				   ,[Cantidad])
			 SELECT
				   @UltimoIDPedidos
				   ,PC.IDComplemento
				   ,PC.Cantidad
			 FROM ICPedidosComplementos as PC
			 inner join ICPedidos as P
			 on P.ID=PC.IDPedido
			 where P.ID=@IDPedidoCopiar
	commit transaction

	--Por último insertamos los toppings de los helados
	begin transaction
	INSERT INTO [dbo].[ICHeladosToppings]
			   ([IDHelado]
			   ,[IDTopping])
		 Select
				TH.ID,
				HC.IDTopping
		From ICHeladosToppings as HC
		inner join @tablaHelados as TH
		on HC.IDHelado=TH.IDAntiguo
	commit transaction
END
Go


Begin transaction
declare @fechainicio date=DATEFROMPARTS(2015,02,25)
Execute RepitePedido 'Dusti','Torres',@fechainicio
Select * from ICPedidos where IDCliente=22 order by recibido
Select * from ICHelados where IDPedido=1386
Select * from ICHeladosToppings where IDHelado=3475
rollback transaction  
--Ejercico 3:
--Escribe una función inline a la que pasemos el nombre de un establecimiento y un cpntenedor
--y nos devuelva una tabla con las ventas anueales de ese establecimiento en los últimos 4
--años de pedidos que incluyan algún helado con ese contenedor. Utiliza la función del ejercicio 1.

Go
CREATE FUNCTION fn_VentasAnualesContenedor (@nombre varchar(20),@contenedor char (20)) RETURNS TABLE AS
RETURN(
	SELECT cast(DateAdd(year,-1,Current_Timestamp) as varchar)+'-'+cast(CURRENT_TIMESTAMP as varchar) AS Fecha,
		   dbo.fn_ImporteContenedorRango(@nombre,@contenedor,DateAdd(year,-1,Current_Timestamp),CURRENT_TIMESTAMP) as Ventas
	UNION
	SELECT cast(DateAdd(year,-2,Current_Timestamp) as varchar)+'-'+cast(DateAdd(year,-1,Current_Timestamp) as varchar),
		   dbo.fn_ImporteContenedorRango(@nombre,@contenedor,DateAdd(year,-2,Current_Timestamp),DateAdd(year,-1,Current_Timestamp))
	UNION
	SELECT cast(DateAdd(year,-3,Current_Timestamp) as varchar)+'-'+cast(DateAdd(year,-2,Current_Timestamp) as varchar),
		   dbo.fn_ImporteContenedorRango(@nombre,@contenedor,DateAdd(year,-3,Current_Timestamp),DateAdd(year,-2,Current_Timestamp))
	UNION
	SELECT cast(DateAdd(year,-4,Current_Timestamp) as varchar)+'-'+cast(DateAdd(year,-3,Current_Timestamp) as varchar),
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
go
CREATE FUNCTION fnToppingsRango(@nombre varchar(30),
								@fechainicio time(0),
								@fechafin time(0)) 
								returns varchar(18) as
BEGIN
	declare @resultado varchar(18)

	declare @tabla table (IDTopping tinyint null ,cantidad int null)

	insert into @tabla (IDTopping,cantidad)
	Select HT.IDTopping as IDTopping,count(HT.IDTopping) as NumeroVendidos
		From ICHeladosToppings as HT
		inner join ICHelados as H
		on H.ID=HT.IDHelado
		inner join ICPedidos as P
		on P.ID=H.IDPedido
	where cast(P.Recibido as time(0)) between @fechainicio and @fechafin and P.IDEstablecimiento=(Select ID from ICEstablecimientos where Denominacion=@nombre)
	group by HT.IDTopping


	
	Select @resultado=T.Topping
		From (Select max(cantidad) as masvendido from @tabla) as total
		inner join @tabla as ta
		on total.masvendido=ta.cantidad
		inner join ICToppings as T
		on ta.IDTopping=T.ID
	return @resultado
END
go

Select * from ICPedidos where IDEstablecimiento=55
Select * from ICHelados where IDPedido=1137 or IDPedido=1577 or IDPedido=1929
Select * from ICHeladosToppings where IDHelado=2852  or IDHelado=2853 
						or IDHelado=2854 or IDHelado=2855 or IDHelado=3935 or IDHelado=4829 or IDHelado=4830 or IDHelado=4831 


declare @resultado varchar(18)
declare @horainicio time=cast(N'01:00:00' as time(0))
declare @horafin time=cast(N'02:00:00' as time(0))
EXECUTE @resultado=dbo.fnToppingsRango 'Chocolate',@horainicio,@horafin
print @resultado
go


ALTER FUNCTION fn_ToppingsHora (@nombre varchar(30)) 
				Returns @mitabla Table(
						Hora time(0) null,
						Topping varchar(18) null
				) as
BEGIN
	declare @horainicio time=cast(N'0:00:00' as time(0))
	declare @horafin time=cast(N'1:00:00' as time(0))
	declare @resultado time
	declare @topping varchar(18)
	Execute @topping=dbo.fnToppingsRango @nombre,@horainicio,@horafin
	INSERT INTO @mitabla(Hora,Topping) 
		values (@horainicio,@topping)
	declare @contador int=1
	while @contador<24
	Begin
		set @horainicio=cast(DATEADD(hour,1,@horainicio) as time)
		set @horafin=cast(DATEADD(hour,1,@horafin) as time)
		EXECUTE @topping=fnToppingsRango @nombre,@horainicio,@horafin 
		INSERT INTO @mitabla(Hora,Topping) 
			values (@horainicio,@topping)
		set @contador=@contador+1
	End
	Return
END
go
select * from dbo.fn_ToppingsHora ('Chocolate')

--Falta mejorar la eficiencia!!! Cansado,pero feliz!