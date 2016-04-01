--Examen de Francisco Javier Ruiz Rodríguez
Use ICOTR
go
SET DATEFORMAT YMD
--Especificaciones
--La cadena de Heladerías "Ice Cream On The Road" gestiona una serie de establecimientos dedicados a elaborar helados y servirlos a domicilio.
--Los clientes hacen sus pedidos por teléfono o por internet. Un pedido puede constar de uno o varios helados. 
--Cada helado es de un sabor, se sirve en un contenedor (tarrina, cucurucho, etc) y puede llevar uno o varios toppings (nata, caramelo, etc.
--El pedido puede incluir algunos complementos, como bebidas.En los pedidos se incorpora el momento en que se ha recibido y el momento en
--que el repartidor lo ha entregado.Para calcular el precio de un pedido se tendrán en cuenta todos estos factores


--Ejercicio 1
--Escribe una consulta que nos devuelva el importe total de los pedidos que ha transportado cada repartidor en el año 2014 
--y el tiempo medio que ha transcurrido entre que se hicieron los pedidos hasta que se sirvieron (en segundos). 
--Incluye también nombre, apellidos e ID del repartidor


Select R.Nombre,
	   R.Apellidos,
	   R.ID,
	   sum(P.Importe) as [Total Ventas 2014],
	   sum(DATEDIFF(SECOND,P.Recibido,P.Enviado))/count(P.Enviado) as Media --Suponiendo que todos los pedidos estén entregados
from ICRepartidores as R													--nos da igual poner enviado o recibido
inner join ICPedidos as P									
on R.ID=P.IDRepartidor
where year(P.Enviado)=2014
group by R.Nombre,R.Apellidos,R.ID


--Ejercicio 2
--Para optimizar nuestro servicio, queremos borrar los 3 complementos que menos se hayan vendido entre el 17 de marzo de 2013 
--y el 8 de septiembre de 2014.Como eso implicaría violar la restricción FKPedidosComplementosHelados de la tabla ICPedidosComplementos, 
--previamente hemos de cambiar las filas donde aparezcan sus IDs por el valor 111

--Creo la tabla ventas donde almaceno los 3 productos menos vendidos
go
create view Ventas as 
Select top 3 PC.IDComplemento,
	   sum(PC.Cantidad) as Cantidad
from ICPedidosComplementos as PC
inner join ICPedidos as P
on PC.IDPedido=P.ID
where P.Recibido>=CAST(N'2013-03-17 00:00:00' as smalldatetime) and P.Recibido<=CAST(N'2014-09-08 00:00:00' as smalldatetime)
group by PC.IDComplemento
order by Cantidad
go

--Actualizo los valores de la tabla ICPedidosComplementos 
Begin transaction 
Update ICPedidosComplementos 
	set IDComplemento=111
	where IDComplemento in (Select IDComplemento from Ventas)
--Nos da error porque la primary key queda duplicada, ya que son 3 complementos los que actualizamos a 111,
--y en un pedido pueden existir varios complementos, por lo que tendríamos una primary key con un IDPedido
--y un IDComplemento igual(duplicada)

--Elimino los complementos
Delete From ICComplementos
where ID in (Select IDComplemento from Ventas)
--Nos vuelve a dar error porque no hemos actualizado lso valores anteriormente
rollback transaction
--commit transaction


--VERSION BUENA BUENA BUENA-- 
--Primero creo una vista donde almaceno los datos que voy a eliminar, dicese las filas que contengan un complemento que vayamos a eliminar
go
create view PedidosAEliminar as 
Select PC.IDPedido,
	   PC.IDComplemento,
	   PC.Cantidad
from ICPedidosComplementos as PC
where IDComplemento in (Select IDComplemento from Ventas)
go
--Después calculo el total de complementos que pasan a estar descatalogados y los meto en la tabla PedidosComplementos
begin transaction
INSERT INTO [dbo].[ICPedidosComplementos]
           ([IDPedido]
           ,[IDComplemento]
           ,[Cantidad])
     Select
           PAE.IDPedido
           ,111
           ,sum(PAE.Cantidad)
	 from PedidosAEliminar as PAE
	 group by PAE.IDPedido


--Por último elimino los pedidosComplementos que tenga algún complemento poco vendido(los 3 menos vendidos)
Delete From ICPedidosComplementos
where IDComplemento in (Select IDComplemento from Ventas)
Delete From ICComplementos
where ID in (Select IDComplemento from Ventas)
rollback transaction
--ME FALTA COMPROBARLO!!!


--Ejercicio 3
--Nuestro cliente Ramón Tañero de Málaga ha hecho un pedido ahora mismo al establecimiento Atracón. El pedido está formado por dos helados, 
--uno de caramelo con topping de nata y otro de alcachofa con topping de gominolas y lacasitos, ambos en un contenedor de tarrina cerámica. 
--Además se añade un café.Crea ese pedido insertando las nuevas filas que correspondan con una sola instrucción INSERT-SELECT para 
--cada tabla sin usar más datos que los que se te han proporcionado o los que tu añadas (ID del pedido e ID del helado). Cada
--helado vale 4€ y cada topping 0,60€. El repartidor y la fecha de envío se dejan a NULL.


Select * from ICPedidos --Lo uso para saber el ID del pedido, puesto que hay 2500 uso 25001
Begin transaction
--Creamos el pedido
INSERT INTO [dbo].[ICPedidos]
           ([ID]
           ,[Recibido]
           ,[Enviado]
           ,[IDCliente]
           ,[IDEstablecimiento]
           ,[IDRepartidor]
           ,[Importe])
     Select distinct
           2501
           ,CURRENT_TIMESTAMP
           ,NULL
           ,C.ID
           ,E.ID
           ,NULL
           ,9.80+Comp.Importe
	 from ICClientes as C
	 inner join ICPedidos as P
	 on C.ID=P.IDCliente
	 inner join ICEstablecimientos as E
	 on P.IDEstablecimiento=E.ID
	 inner join ICPedidosComplementos as PC
	 on P.ID=PC.IDPedido
	 inner join ICComplementos as Comp
	 on PC.IDComplemento=Comp.ID
	 where C.Id in (
					Select C.ID
					from ICClientes as C
					where C.Nombre='Ramon' and C.Apellidos='Tañero' and C.Ciudad='Málaga')
		   and
		   E.ID in (
					Select E.ID
					from ICEstablecimientos as E
					where E.Denominacion='Atracon')
		   and
		   Comp.Importe in (
					Select Comp.Importe
					from ICComplementos as Comp
					where Comp.Complemento='Café')

--Creamos la fila de los Pedidoscomplementos
INSERT INTO [dbo].[ICPedidosComplementos]
           ([IDPedido]
           ,[IDComplemento]
           ,[Cantidad])
     Select distinct
            2501
           ,ID
           ,1
	 from ICComplementos
	 where Complemento='Café'


--Creamos las filas de los helados
--Select * from ICHelados  Para saber que ID ponerle a los helados
INSERT INTO [dbo].[ICHelados]
           ([ID]
           ,[IDPedido]
           ,[TipoContenedor]
           ,[Sabor])
     Values
           (6236
           ,2501
           ,'Tarrina Ceramica'
           ,'caramelo')

INSERT INTO [dbo].[ICHelados]
           ([ID]
           ,[IDPedido]
           ,[TipoContenedor]
           ,[Sabor])
     Values
           (6237
           ,2501
           ,'Tarrina Ceramica'
           ,'alcachofa')

--Insertamos ahora los topping
INSERT INTO [dbo].[ICHeladosToppings]
           ([IDHelado]
           ,[IDTopping])
     Select distinct
            6236
           ,ID
	 from ICToppings
	 where Topping='Nata'

INSERT INTO [dbo].[ICHeladosToppings]
           ([IDHelado]
           ,[IDTopping])
     Select distinct
            6237
           ,ID
	 from ICToppings
	 where Topping='Lacasitos' or Topping='Gominolas'

rollback transaction
--commit transaction

--Ejercicio 4
--Crea una vista que nos muestre, para cada establecimiento, nombre, dirección, número de pedidos servidos en el año 2014, 
--total facturado en el mismo año y número de repartidores diferentes que han trabajado en él.
go
Create View Establecimientos2014 as 
Select E.Denominacion as Nombre,
	   E.Direccion,
	   count(P.ID) as [Número de pedidos],
	   sum(P.Importe) as [Total facturado],
	   count(distinct P.IDRepartidor) as [Número de Repartidores]
from ICEstablecimientos as E
inner join ICPedidos as P
on E.ID=P.IDEstablecimiento
where YEAR(P.Recibido)=2014
group by Denominacion,Direccion
go
--Ejercicio 5
--Haz una vista que nos muestre la popularidad de cada sabor de helado en %. Para calcularlo tienes que contar el número de helados de cada 
--sabor, dividirlo entre el número total de helados y multiplicarlo por 100. El resultado debe ser un Decimal con un decimal.


go
Create view PopularidadHelados as 
Select H.Sabor,
	   cast(cast(count(H.ID) as float)/Hel.totalHelados*100 as decimal(3,1)) as PorcentajedeVentas
from ICHelados as H
cross join (
	Select count(ID) as totalHelados
	from ICHelados
	) as Hel
group by H.Sabor,Hel.totalHelados
go
