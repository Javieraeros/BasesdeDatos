--SCRIPT SOLUCIÓN EXAMEN 9 DE MARZO DE 2016--
--Francisco Javier Ruiz Rodríguez--
Use CasinOnLine
go
--1.Escribe una consulta que nos devuelva el número de veces que se ha apostado a cada número con apuestas de los tipos 10,13 o 15
--Ordena el resultado de mayor a menos popularidad

Select NA.Numero,
	   count(A.Tipo) as [Número de veces apostado]
From COL_Apuestas as A
inner join COL_NumerosApuesta as NA
on A.IDJugada=NA.IDJugada
where A.Tipo in(10,13,15)
group by NA.Numero
Order by [Número de veces apostado] desc


-----------------------------------------------------COMPROBACIÓN CON OTROS DATOS-----------------------------------------------------------


--Select NA.Numero,
--	   count(A.Tipo) as [Número de veces apostado]
--From COL_Apuestas as A
--inner join COL_NumerosApuesta as NA
--on A.IDJugada=NA.IDJugada
--where A.Tipo in(8)
--group by NA.Numero
--Order by [Número de veces apostado] desc

------------------------------------------------------------------------------------------------------------------------------------------

--2.El casino quiere fomentar la participación y decide regalar saldo extra a todos los jugadores que hayan apostado más de tres veces
-- en el último mes. Se considera el mes de febrero
--La cantidad que se les regalrá será un 5% del total que hayan apostado en ese mes

go
Create view [Jugadores habituales febrero] as 
Select J.ID,      --Primero puse nombre y apellidos, pero resulta más fácil con la ID (además ésta es única)
	   count(A.IDJugada) as [Veces jugado]
from COL_Jugadores as J
inner join COL_Apuestas as A
on J.ID=A.IDJugador
inner join COL_Jugadas as JA
on A.IDJugada=JA.IDJugada
where MONTH(JA.MomentoJuega)=2
group by J.ID
having count(A.IDJugada)>3
go

Select * From COL_Jugadores

Begin Transaction
Update COL_Jugadores
	Set Saldo=Saldo*1.05
	where ID in (
		Select ID
		from [Jugadores habituales febrero]
		)

Select * From COL_Jugadores

rollback transaction
--commit Transaction



-----------------------------------------------------COMPROBACIÓN CON OTROS DATOS-----------------------------------------------------------

--go
--Create view [Jugadores habituales enero] as 
--Select J.ID,      --Primero puse nombre y apellidos, pero resulta más fácil con la ID (además ésta es única)
--	   count(A.IDJugada) as [Veces jugado]
--from COL_Jugadores as J
--inner join COL_Apuestas as A
--on J.ID=A.IDJugador
--inner join COL_Jugadas as JA
--on A.IDJugada=JA.IDJugada
--where MONTH(JA.MomentoJuega)=1
--group by J.ID
--having count(A.IDJugada)>3
--go

--Select * From COL_Jugadores

--Begin Transaction
--Update COL_Jugadores
--	Set Saldo=Saldo*1.05
--	where ID in (
--		Select ID
--		from [Jugadores habituales enero]
--		)

--Select * From COL_Jugadores

--rollback transaction
----commit Transaction
------------------------------------------------------------------------------------------------------------------------------------------


--3.El día 2 de febrero se celebró el día de la marmota. PAra conmemorarlo, el casino ha decidido volver a repetir todas las jugadas que
--se hicieron ese día, pero poniéndoles fecha de mañana(con la misma hora 10/03/2016) y permitiendo qeue lso jugadores apuesten.El número ganador
-- de cada jugada se pondrá a Null y el NoVaMas a 0.
--Crea Nuevas filas con una instrucción INSERT-Select

Select*From COL_Jugadas

Begin transaction

Insert into COL_Jugadas(
			IDJugada,
			IDMesa,
			MomentoJuega,
			NoVaMas,
			Numero)
	Select IDJugada+100000,  --Pongo un número alto para que no se repitan las jugadas (y así no se repita la Primary key)
		   IDMesa,
		   DATEADD(DAY,37,MomentoJuega),
		   0,
		   NULL
	From COL_Jugadas
	where cast(MomentoJuega as date)=DATEFROMPARTS(2016,02,02)

Select*From COL_Jugadas

RollBack Transaction
--Commit Transaction


-----------------------------------------------------COMPROBACIÓN CON OTROS DATOS-----------------------------------------------------------

--Select*From COL_Jugadas

--Begin transaction

--Insert into COL_Jugadas(
--			IDJugada,
--			IDMesa,
--			MomentoJuega,
--			NoVaMas,
--			Numero)
--	Select IDJugada+100000,  --Pongo un número alto para que no se repitan las jugadas
--		   IDMesa,
--		   DATEADD(DAY,55,MomentoJuega),
--		   0,
--		   NULL
--	From COL_Jugadas
--	where cast(MomentoJuega as date)=DATEFROMPARTS(2016,01,15)

--Select*From COL_Jugadas

--RollBack Transaction
----Commit Transaction

------------------------------------------------------------------------------------------------------------------------------------------


--4.Crea una vista que nos muestre,para cada jugador,nombre,apellidos,Nick,número de apuestas realizadas,total de dinero apostado y 
--total de dinero ganado/perdido
go
create view [Datos Jugador] as 
Select J.Nombre,
	   J.Apellidos,
	   J.Nick,
	   count(A.IDJugador) as [Número de Apuestas Realizadas],
	   sum(A.Importe) as [Total de dinero apostado],
	   G.Ganado-P.Perdido as [Ganado/Perdido]
From COL_Jugadores as J
inner join COL_Apuestas as A
on J.ID=A.IDJugador
inner join COL_Jugadas as JA
on A.IDJugada=JA.IDJugada
inner join COL_TiposApuesta as TA
on A.Tipo=TA.ID
inner join COL_NumerosApuesta as NA
on A.IDJugada=NA.IDJugada and A.IDMesa=NA.IDMesa and A.IDJugador=NA.IDJugador
inner join (
	Select J.ID,
		   sum(A.Importe*TA.Premio) as [Ganado]
	From COL_Jugadores as J
	inner join COL_Apuestas as A
	on J.ID=A.IDJugador
	inner join COL_Jugadas as JA
	on A.IDJugada=JA.IDJugada
	inner join COL_TiposApuesta as TA
	on A.Tipo=TA.ID
	inner join COL_NumerosApuesta as NA
	on A.IDJugada=NA.IDJugada and A.IDMesa=NA.IDMesa and A.IDJugador=NA.IDJugador
	where NA.Numero=JA.Numero
	group by  J.ID
) as G  --Ganado
on J.ID=G.ID
inner join (
	Select J.ID,
		   sum(A.Importe) as [Perdido]
	From COL_Jugadores as J
	inner join COL_Apuestas as A
	on J.ID=A.IDJugador
	inner join COL_Jugadas as JA
	on A.IDJugada=JA.IDJugada
	inner join COL_TiposApuesta as TA
	on A.Tipo=TA.ID
	inner join COL_NumerosApuesta as NA
	on A.IDJugada=NA.IDJugada and A.IDMesa=NA.IDMesa and A.IDJugador=NA.IDJugador
	where NA.Numero<>JA.Numero
	group by  J.ID
) as P  --Perdido
on J.ID=P.ID
group by  J.Nombre,J.Apellidos,J.Nick,G.Ganado,P.Perdido
go


--5.Nos comunican que la policía ha detenido a nuestro cliente Ombligo PAto por delitos de estafa,falsedad,administración desleal y
--mal gusto para comprar bañadores.
--Dado que nuestro csaino está ne Gibraltar, siguiendo la tracidión de estas tierras, queremos borrar todo rastro de su paso por 
--nuestro casino. Borra todas las apuestas que haya realizado, pero no busques su ID a mano en la tabla COL_Clientes. utiliza su Nick
--(bankiaman) para identificarlo en la instrucción delete

Select * From COL_Apuestas

BEGIN TRANSACTION

Delete From COL_NumerosApuesta
	where IDJugador in(
	Select ID
	From COL_Jugadores
	where Nick='bankiaman'
	)

Delete From COL_Apuestas
	where IDJugador in(
	Select ID
	From COL_Jugadores
	where Nick='bankiaman'
	)
Delete From COL_Jugadores
	where ID in(
	Select ID
	From COL_Jugadores
	where Nick='bankiaman'
	)


Select * From COL_Apuestas

ROLLBACK TRANSACTION
--COMMIT TRANSACTION