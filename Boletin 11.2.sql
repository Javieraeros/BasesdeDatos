--Boletín 11.2
Use AirLeo
set dateformat 'ymd'
/*Ejercicio 1
Escribe un procedimiento que cancele un pasaje y las tarjetas de embarque asociadas.
Recibirá como parámetros el ID del pasaje.*/

go
Create Procedure CancelarPasaje @Id int as
Begin
Delete From AL_Tarjetas
where Numero_Pasaje=@Id
Delete From AL_Vuelos_Pasajes
where Numero_Pasaje=@Id
Delete From AL_Pasajes
where Numero=@Id
End
Go
Begin Transaction
Execute CancelarPasaje 5
Rollback
/*Ejercicio 2
Escribe un procedimiento almacenado que reciba como parámetro el ID de un pasajero y devuelva en un parámetro de salida el número 
de vuelos diferentes que ha tomado ese pasajero.*/
go
create Procedure DevuelveVuelos @Id char(9),
								@vuelos int OUTPUT as --Muy importante: El Id es una cadena!!
Begin
Select @vuelos=count(distinct VP.Codigo_Vuelo) From AL_Vuelos_Pasajes as VP
inner join AL_Pasajes as P
on VP.Numero_Pasaje=P.Numero
Where P.ID_Pasajero=@Id
return @vuelos
end
go


Declare @Vuelos int
Execute DevuelveVuelos 'A003',@Vuelos OUTPUT
print 'Número de Vuelos: '+ cast(@Vuelos as varchar(5))


/*Ejercicio 3
Escribe un procedimiento almacenado que reciba como parámetro el ID de un pasajero y dos fechas y nos devuelva en otro parámetro 
(de salida) el número de horas que ese pasajero ha volado durante ese intervalo de fechas.*/
go
create Procedure VuelaPasajero @Id varchar(9),
							  @empieza smalldatetime,
							  @acaba smalldatetime,
							  @tiempo int OutPut AS --Horas
Begin

Select @tiempo=(sum(DATEDIFF(MINUTE,Salida,Llegada))/60)
From AL_Pasajeros as Ps
inner join AL_Pasajes as P
on Ps.ID=P.ID_Pasajero
inner join AL_Vuelos_Pasajes as VP
on P.Numero=VP.Numero_Pasaje
inner join Al_Vuelos as V
on VP.Codigo_Vuelo=V.Codigo
where ID_Pasajero=@Id and Salida>=@empieza and Llegada<=@acaba 

End
go
Declare @HorasVuelo int
Execute VuelaPasajero 'A007','2012-01-14 14:05:00','2014-01-14 14:05:00',@HorasVuelo OUTPUT
print 'Horas de vuelo: '+ cast(@HorasVuelo as varchar(5))
go
/*Ejercicio 4
Escribe un procedimiento que reciba como parámetro todos los datos de un pasajero y un número 
de vuelo y realice el siguiente proceso:
En primer lugar, comprobará si existe el pasajero. Si no es así, lo dará de alta.
A continuación comprobará si el vuelo tiene plazas disponibles (hay que consultar 
la capacidad del avión) y en caso afirmativo 
creará un nuevo pasaje para ese vuelo.*/

--Devolverá: -2 si crea el pasajero pero no hay plazas disponibles,
--			 -1 si el pasajero existe pero no hay plazas disponibles
--            0 si crea el pasajero y le asigna el vuelo
--            1 si el pasajero existe y le asigna el vuelo
create procedure asignaVuelo @ID varchar(9)    --se ve mejor así
           ,@Nombre varchar(20)
           ,@Apellidos varchar(50)
           ,@Direccion varchar(60)
           ,@Fecha_Nacimiento date
           ,@Nacionalidad varchar(30)
		   ,@Codigo_vuelo int
		   ,@Salida int output AS
	Begin
	--Creamos el nuevo número para la tabla pasaje
	Declare @NumeroPasaje int
	--Primero miramos si el pasajero existe, y de no existir lo creamos
	If @Id not in (Select ID from AL_Pasajeros)
		Begin
		SET @Salida=-2 --Si el pasajero no existe le damos este valor, si hay 
						--plaza le sumaremos dos, sino, lo dejaremos tal como está
		INSERT INTO [dbo].[AL_Pasajeros]
				   ([ID]
				   ,[Nombre]
				   ,[Apellidos]
				   ,[Direccion]
				   ,[Fecha_Nacimiento]
				   ,[Nacionalidad])
			 VALUES
				   (@ID
				   ,@Nombre
				   ,@Apellidos
				   ,@Direccion
				   ,@Fecha_Nacimiento
				   ,@Nacionalidad)
		End
	ELSE
		Begin
		SET @Salida=-1
		End
	--Si el numero de plazas ocupadas es menor que el número de plazas totales del avión
	IF (Select count(Codigo_vuelo) from AL_Tarjetas
		where Codigo_Vuelo=@Codigo_vuelo
		)         
		< 
		(Select Asientos_x_Fila*Filas from AL_Aviones as A
			inner join AL_Vuelos as V
			on A.Matricula=V.Matricula_Avion
		 where V.Codigo=@Codigo_vuelo)

		Begin
			--Actualizamos el valor de la salida
			SET @Salida=@Salida+2
			Begin transaction
			Set @NumeroPasaje=(Select max(Numero) from AL_Pasajes)+1
			--insertamos
			INSERT INTO [dbo].[AL_Pasajes]
				([Numero]
				,[ID_Pasajero])
			VALUES
				(@NumeroPasaje
				,@ID)
			commit transaction
			INSERT INTO [dbo].[AL_Vuelos_Pasajes]
					   ([Codigo_Vuelo]
					   ,[Numero_Pasaje]
					   ,[Embarcado])
				 VALUES
					   (@Codigo_vuelo
					   ,@NumeroPasaje
					   ,'N')

		End
	--En caso de que no exsiten plazas, se devovlerá el número correspondiente, sin tener que hacer nada más
	End
go
Declare @Resultado int
Execute asignaVuelo 1500,'Javier','Ruiz','Mi casa','1992-11-19','España',15,@Resultado OUTPUT
print @Resultado
go

/*Ejercicio 5
Escribe un procedimiento almacenado que cancele un vuelo y reubique a sus pasajeros en otro. Se ocuparán los asientos libres en el 
vuelo sustituto. Se comprobará que ambos vuelos realicen el mismo recorrido. Se borrarán todos los pasajes y las tarjetas de embarque 
y se generarán nuevos pasajes. No se generarán nuevas tarjetas de embarque. El vuelo a cancelar y el sustituto se pasarán como parámetros. 
Si no se pasa el vuelo sustituto, se buscará el primer vuelo inmediatamente posterior al cancelado que realice el mismo recorrido.*/
go
create view AsientosLibres as 
Select
	Codigo,
	Asientos_x_Fila*Filas-count(VP.Codigo_Vuelo) as Asientos_libres
from AL_Vuelos as V
inner join AL_Aviones as A
on V.Matricula_Avion=A.Matricula
inner join AL_Vuelos_Pasajes as VP
on V.Codigo=VP.Codigo_Vuelo
group by Codigo,Asientos_x_Fila,Filas
go
create Procedure ReubicaPasajeros @cancelar int, @sustituto int=null as
Begin
SET NOCOUNT ON

--Declaramos la variable pasajeros como una tabla para almacenar ahí lso pasajeros que vamos a cambiar de vuelo
declare @pasajeros as table(
	[ID] [char](9) NOT NULL,
	[Nombre] [varchar](20) NOT NULL,
	[Apellidos] [varchar](50) NOT NULL,
	[Direccion] [varchar](60) NULL,
	[Fecha_Nacimiento] [date] NOT NULL,
	[Nacionalidad] [varchar](30) NULL
)

--Insertamos los pasajeros que vayan a coger el vuelo a cancelar
Insert into @pasajeros
			(
			[ID],
			[Nombre],
			[Apellidos],
			[Direccion],
			[Fecha_Nacimiento],
			[Nacionalidad]
		)
		Select ID,
			   nombre,
			   apellidos,
			   direccion,
			   fecha_nacimiento,
			   Nacionalidad 
		from AL_Pasajeros
		where ID in (
			Select P.ID_Pasajero from AL_Vuelos_Pasajes as VP
			inner join AL_Pasajes as P
			on VP.Numero_Pasaje=P.Numero
			where VP.Codigo_Vuelo=@cancelar
			)

/*Guardamos en una tabla temporal los pasajes que vamos a crear/insertar en la tabla pasajes,
para después insertarlos en la tabla Vuelos_Pasajes*/
declare @pasajesTemporal as Table(
	[Numero] [int] NOT NULL,
	[ID_Pasajero] [char](9) NOT NULL
)

INSERT INTO @pasajesTemporal
	([Numero]
	,[ID_Pasajero])
Select
	(Select max(Numero) from AL_Pasajes)+ROW_NUMBER() OVER(ORDER BY ID DESC)
	,ID as ID
	from @pasajeros

/*Borramos todo lo relativo a ese vuelo.
Para ello, es necesario almacenar los pasajes del vuelo que vamos a eliminar,debido a las restricciones de on delete no action
de las tablas Tarjetas y Vuelos pasajes (que deben ser las primeras en eliminarse)
*/
declare @pasajesEliminar as table(
	[Codigo_Vuelo] [int] NOT NULL,
	[Numero_Pasaje] [int] NOT NULL,
	[Embarcado] [char](1) NOT NULL
	)
insert into @pasajesEliminar (
	Codigo_vuelo,
	Numero_Pasaje,
	Embarcado
	)
	Select
		Codigo_Vuelo,
		Numero_Pasaje,
		Embarcado
	from AL_Vuelos_Pasajes
		where Codigo_Vuelo=@cancelar
--Ahora borramos todo lo relativo al vuelo
delete AL_Tarjetas
	where Codigo_Vuelo=@cancelar
/*delete AL_Vuelos
	where Codigo=@cancelar*/ --No creo que sea necesario
delete AL_Vuelos_Pasajes
	where Codigo_Vuelo=@cancelar
delete AL_Pasajes
	where Numero in (
		Select Numero_Pasaje
		from @pasajesEliminar
		)
if @sustituto is not null
			and 
			(Select Aeropuerto_Salida from AL_Vuelos
				where @cancelar=Codigo)=
			(Select Aeropuerto_Salida from AL_Vuelos
				where @sustituto=Codigo)              --Comprobamos que el aeropuerto de salida sea el mismo
			and

			(Select Aeropuerto_Llegada from AL_Vuelos
				where @cancelar=Codigo)=
			(Select Aeropuerto_Llegada from AL_Vuelos
				where @sustituto=Codigo)              --Comprobamos que el aeropuerto de llegada sea el mismo
			and 

			(Select Asientos_x_Fila*Filas-count(Codigo_vuelo) from AL_Tarjetas
					inner join AL_Vuelos as V
					on Codigo_Vuelo=V.Codigo
					inner join AL_Aviones as A
					on V.Matricula_Avion=A.Matricula
					where Codigo_Vuelo=@sustituto
					group by Asientos_x_Fila,Filas
			)
				>                                      --Comprobamos que hay asientos libres
			(Select count(ID) from @pasajeros)
Begin
	--Insertamos en la tabla Pasajes los nuevos pasajes
	Insert Into AL_Pasajes
		([Numero]
		,[ID_Pasajero])
	Select
		Numero
		,ID_Pasajero
		from @pasajesTemporal
	INSERT INTO [dbo].[AL_Vuelos_Pasajes]
			([Codigo_Vuelo]
			,[Numero_Pasaje]
			,[Embarcado])
		Select
			@sustituto
			,Numero
			,'N'
		from @pasajesTemporal
End

ELSE
begin
declare @nuevoSustituto int
Select Top 1 @nuevoSustituto=Codigo from AL_Vuelos
where Aeropuerto_Salida=(Select Aeropuerto_Salida from AL_Vuelos
				where Codigo=@cancelar)
	  and
	  Aeropuerto_Llegada=(Select Aeropuerto_Llegada from AL_Vuelos
				where Codigo=@cancelar)
	  and
	  Salida>(Select Salida from AL_Vuelos
				where Codigo=@cancelar)

	  and 
	  codigo in (Select Codigo from AsientosLibres
	  where Asientos_libres>(Select count(ID) from @pasajeros))
order by Salida

--Insertamos en la tabla Pasajes los nuevos pasajes
Insert Into AL_Pasajes
	([Numero]
	,[ID_Pasajero])
Select
	Numero
	,ID_Pasajero
	from @pasajesTemporal

INSERT INTO [dbo].[AL_Vuelos_Pasajes]
		([Codigo_Vuelo]
		,[Numero_Pasaje]
		,[Embarcado])
	Select
		@nuevoSustituto
		,Numero
		,'N'
	from @pasajesTemporal

end
END
go

Begin tran
Declare @cancelar int
Set @cancelar=4
Execute ReubicaPasajeros @cancelar
rollback tran
/*Ejercicio 6
Escribe un procedimiento al que se pase como parámetros un código de un avión y un momento (dato fecha-hora) y nos escriba un mensaje 
que indique dónde se encontraba ese avión en ese momento. El mensaje puede ser "En vuelo entre los aeropuertos de NombreAeropuertoSalida 
y NombreaeropuertoLlegada” si el avión estaba volando en ese momento, o "En tierra en el aeropuerto NombreAeropuerto” si no está volando. 
Para saber en qué aeropuerto se encuentra el avión debemos consultar el último vuelo que realizó antes del momento indicado.
Si se omite el segundo parámetro, se tomará el momento actual.*/

go
alter procedure EncuentraAvion @matricula char(10), @momento smalldatetime as
Begin
	Declare @salida char(3),@llegada char(3)
	IF Exists (
			  Select Matricula_Avion from AL_Vuelos
			  where @momento between Salida and Llegada
					and
					Matricula_Avion=@matricula
			  )
		Begin
			Select @salida=Aeropuerto_Salida,@llegada=Aeropuerto_Llegada 
				from AL_Vuelos 
				where @momento between Salida and Llegada and Matricula_Avion=@matricula
			print 'El avion se encuentra volando entre ' +cast (@salida as varchar)+' y '+cast (@llegada as varchar)
		End
	ELSE
		Begin
		Select top 1 @llegada=Aeropuerto_Llegada 
			from AL_Vuelos
			where @momento>Llegada and Matricula_Avion=@matricula
			order by Llegada desc
			print 'El avion se encuentra estacionado en el aeropuerto: '+cast(@llegada as varchar)
		End
End
go

-- Establecememos el formato horario dd/mm/yyyy
SET DATEFORMAT DMY

-- Creamos la variable fecha para buscar por fecha
DECLARE @Fecha Smalldatetime
SELECT @Fecha = '01-02-2013 14:47:00'

DECLARE @Fecha2 Smalldatetime
SELECT @Fecha2 = '14-09-2013 14:45:00'

-- Creamos la variable avion para buscar por matricula del avion
DECLARE @Avion char(10)
SELECT @Avion = 'ESP4502'

-- Buscamos un avion por matricula
EXECUTE EncuentraAvion @Avion, @Fecha

-- Comprobamos si funciona 
SELECT * FROM AL_Vuelos WHERE Matricula_Avion = 'ESP4502'
ORDER BY Salida