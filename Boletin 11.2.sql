--Bolet�n 11.2
Use AirLeo

/*Ejercicio 1
Escribe un procedimiento que cancele un pasaje y las tarjetas de embarque asociadas.
Recibir� como par�metros el ID del pasaje.*/

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
Escribe un procedimiento almacenado que reciba como par�metro el ID de un pasajero y devuelva en un par�metro de salida el n�mero 
de vuelos diferentes que ha tomado ese pasajero.*/
go
Create Procedure DevuelveVuelos @Id char(9),@vuelos int OUTPUT as --Muy importante: El Id es una cadena!!
Begin
Select @vuelos=count(VP.Codigo_Vuelo) From AL_Vuelos_Pasajes as VP
inner join AL_Pasajes as P
on VP.Numero_Pasaje=P.Numero
inner join AL_Pasajeros as Ps
on P.ID_Pasajero=Ps.ID
Where Ps.ID=@Id
return @vuelos
end
go


Declare @Vuelos int
Execute DevuelveVuelos 'B007',@Vuelos OUTPUT
print 'N�mero de Vuelos: '+ cast(@Vuelos as varchar(5))


/*Ejercicio 3
Escribe un procedimiento almacenado que reciba como par�metro el ID de un pasajero y dos fechas y nos devuelva en otro par�metro 
(de salida) el n�mero de horas que ese pasajero ha volado durante ese intervalo de fechas.*/
go
create Procedure VuelaPasajero @Id varchar(9),@entrada smalldatetime,@salida smalldatetime,@tiempo int OutPut AS --Minutos 
Begin
If(
	Select  
	From AL_Pasajeros as Ps
	inner join AL_Pasajes as P
	on Ps.ID=P.ID_Pasajero
	inner join AL_Vuelos_Pasajes as VP
	on P.Numero=VP.Numero_Pasaje
	inner join Al_Vuelos as V
	on VP.Codigo_Vuelo=V.Codigo
)
End
go
/*Ejercicio 4
Escribe un procedimiento que reciba como par�metro todos los datos de un pasajero y un n�mero de vuelo y realice el siguiente proceso:
En primer lugar, comprobar� si existe el pasajero. Si no es as�, lo dar� de alta.
A continuaci�n comprobar� si el vuelo tiene plazas disponibles (hay que consultar la capacidad del avi�n) y en caso afirmativo 
crear� un nuevo pasaje para ese vuelo.*/

/*Ejercicio 5
Escribe un procedimiento almacenado que cancele un vuelo y reubique a sus pasajeros en otro. Se ocupar�n los asientos libres en el 
vuelo sustituto. Se comprobar� que ambos vuelos realicen el mismo recorrido. Se borrar�n todos los pasajes y las tarjetas de embarque 
y se generar�n nuevos pasajes. No se generar�n nuevas tarjetas de embarque. El vuelo a cancelar y el sustituto se pasar�n como par�metros. 
Si no se pasa el vuelo sustituto, se buscar� el primer vuelo inmediatamente posterior al cancelado que realice el mismo recorrido.*/

/*Ejercicio 6
Escribe un procedimiento al que se pase como par�metros un c�digo de un avi�n y un momento (dato fecha-hora) y nos escriba un mensaje 
que indique d�nde se encontraba ese avi�n en ese momento. El mensaje puede ser "En vuelo entre los aeropuertos de NombreAeropuertoSalida 
y NombreaeropuertoLlegada� si el avi�n estaba volando en ese momento, o "En tierra en el aeropuerto NombreAeropuerto� si no est� volando. 
Para saber en qu� aeropuerto se encuentra el avi�n debemos consultar el �ltimo vuelo que realiz� antes del momento indicado.
Si se omite el segundo par�metro, se tomar� el momento actual.*/