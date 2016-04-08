Create database AirLeo;
Go
Use AirLeo;
Go
-- Las "marcas" de los aviones
CREATE TABLE AL_Fabricantes(
	ID_Fabricante TinyInt Not Null ConstraInt PK_Fabricantes Primary Key
	,Nombre VarChar(25) Not Null
	);
Go
-- Los aparatos. 
-- Relacionada con Fabricantes
CREATE TABLE AL_Aviones(
	Matricula Char(10) Not Null ConstraInt PK_Aviones Primary Key,
	Nombre VarChar(30) Not Null,
	ID_Fabricante TinyInt Not Null,
	Modelo VarChar(25) Not Null,
	Fecha_Fabricacion Date Null,
	Fecha_Entrada Date Null,
	Filas SmallInt Not Null,
	Asientos_x_Fila TinyInt Not Null,
	Autonomia Int Null,
	ConstraInt CK_Fechas Check (Fecha_Fabricacion <= Fecha_Entrada),
	ConstraInt FK_Aviones_Fabricantes Foreign Key (ID_Fabricante) REFERENCES AL_FABRICANTES(ID_Fabricante)
);
go
-- Cada aeropuesto se identifica por un código de tres letras, conocido como código IATA
CREATE TABLE AL_Aeropuertos(
	Codigo Char(3) Not Null Constraint PK_Aeropuerto Primary Key
	,Nombre VarChar(30) Not Null
	,Ciudad VarChar(30) Not Null
	,Pais VarChar (30) Not Null
);
Go
-- Cada uno de los viajes que hace un avión
-- Se relaciona con el avion y con los aeropuertos de origen y destino
CREATE TABLE AL_Vuelos(
	Codigo Int IDENTITY(1,1) Not Null ConstraInt PK_Vuelos Primary Key
	,Aeropuerto_Salida Char(3) Not Null
	,Aeropuerto_Llegada Char(3) Not Null
	,Salida SmallDateTime Not Null
	,Llegada SmallDateTime Not Null
	,Matricula_Avion Char(10) Not Null
	,Precio_Pasaje SmallMoney
	,ConstraInt FK_Vuelos_AerSalida Foreign Key (Aeropuerto_Salida) References AL_Aeropuertos (Codigo) 
		On Update Cascade On Delete No Action
	,ConstraInt FK_Vuelos_AerLlegada Foreign Key (Aeropuerto_Llegada) References AL_Aeropuertos (Codigo) 
		On Update No Action On Delete No Action
	,ConstraInt FK_Vuelos_Aviones Foreign Key (Matricula_Avion) References AL_Aviones (Matricula) 
		On Update No Action On Delete No Action
	,ConstraInt CK_AeropuertosDistIntos Check (Aeropuerto_Salida != Aeropuerto_Llegada)
	,ConstraInt CK_Einstein Check (Salida < Llegada)
);
Go
-- La persona que vuela. No me refiero a Superman
CREATE TABLE AL_Pasajeros (
	ID Char(9) Not Null CONSTRAINT PK_Pasajeros Primary Key
	,Nombre VarChar(20) Not Null
	,Apellidos VarChar(50) Not Null
	,Direccion VarChar(60) Null
	,Fecha_Nacimiento Date Not Null
	,Nacionalidad VarChar(30) Null
);

Go
-- Un pasaje pertenece a un pasajero y puede incluir varios vuelos
CREATE TABLE AL_Pasajes(
	Numero Int Not Null Constraint PK_Pasajes Primary Key
	,ID_Pasajero Char(9) Not Null
	,Constraint FK_Pasajes_Pasajeros Foreign Key (ID_Pasajero) References AL_Pasajeros (ID)
		On Delete No Action On Update Cascade
)
GO
-- La tarjeta es para un solo pasajero y un solo vuelo
CREATE TABLE AL_Tarjetas(
	Codigo_Vuelo Int Not Null
	,Fila_Asiento SmallInt Not Null
	,Letra_Asiento Char (1) Not Null
	,Numero_Pasaje Int Null
	,Peso_Equipaje Decimal (3,1) Null
	,Constraint PK_Tarjetas Primary Key (Codigo_Vuelo, Fila_Asiento, Letra_Asiento)
	,Constraint FK_Tarjetas_Vuelos Foreign Key (Codigo_Vuelo) References AL_Vuelos (Codigo)
		On Delete No Action On Update Cascade
	,Constraint FK_Tarjetas_Pasajes Foreign Key (Numero_Pasaje) References AL_Pasajes (Numero)
		On Delete No Action On Update Cascade
)
Go
-- Relación N:M entre vuelos y pasajes
CREATE TABLE AL_Vuelos_Pasajes(
	Codigo_Vuelo Int Not Null
	,Numero_Pasaje Int Not Null
	,Embarcado Char(1) Not Null Default 'N'
	,Constraint PK_VuelosPasajes Primary Key (Codigo_Vuelo,Numero_Pasaje )
	,Constraint FK_VuelosPasajes_Vuelos Foreign Key (Codigo_Vuelo) References AL_Vuelos (Codigo)
		On Delete No Action On Update Cascade
	,Constraint FK_VuelosPasajes_Pasajes Foreign Key (Numero_Pasaje) References AL_Pasajes (Numero)
		On Delete No Action On Update Cascade
	)
-- Fabricantes
insert into AL_Fabricantes (ID_Fabricante, Nombre) 
	values (3,'Boeing')
,(2,'Airbus')
,(13,'Yakolev')
,(30,'Embraer')
,(31,'Canadair-Bombardier')
,(32,'Irkut')
,(33,'Comac')
,(34,'Sukhoi')
,(35,'Mitsubishi')

Go
-- Aviones
INSERT INTO AL_Aviones (Matricula,Nombre,ID_Fabricante,Modelo,Fecha_Fabricacion,Fecha_Entrada,Filas,Asientos_x_Fila,Autonomia)
     VALUES ('ESP2345', 'Rayo', 2, 'A320', '20010320','20010415', 25, 6, 3500)
,('ESP4502', 'Argonauta', 2, 'A320', '20020520','20020815', 25, 6, 2500)    
,('ESP8067', 'Santísima Trinidad', 3, 'B737', '20010124','20010218', 22, 6, 3200)
,('IRL4708', 'Guinnes', 2, 'A320', '20100404','20100711', 25, 6, 2500)  
,('ESP5077', 'Plus Ultra', 3, 'B747', '20010927','20020325', 42, 10, 6500)
,('USA5068', 'Enola Gay', 3, 'B737', '20040320','20040415', 24, 6, 2700)
,('USA5077', 'Spirit of St Louis', 3, 'B747', '20020127','20020315', 42, 10, 6500)
,('FRA0955', 'Bucentaure', 3, 'B747', '20050927','20051125', 42, 10, 6500)
,('FRA5021', 'Redoutable', 2, 'A320', '20020520','20020815', 25, 6, 2500) 
,('FRA4502', 'Acheron', 2, 'A320', '20020524','20020711', 25, 6, 2500)  
           
Go
-- Aeropuertos
INSERT Into AL_Aeropuertos (Codigo,Nombre,Ciudad,Pais) 
	VALUES('APA','Centennial','Denver','Estados Unidos de América')
,('BCN','El Prat','Barcelona','España')
,('CAI','El Cairo','El Cairo','Egipto')
,('JFK','John F. Kennedy','New York','Estados Unidos de América')
,('LGA','La Guardia','New York','Estados Unidos de América')
,('MAD','Barajas','Madrid','España')
,('MIA','Miami','Miami','Estados Unidos de América')
,('NRT','Narita','Tokio','Japón')
,('PMI','Son San Joan','Palma de Mallorca','España')
,('SVQ','San Pablo','Sevilla','España')
,('AGP','Pablo Ruiz Picasso','Málaga','España')
,('BUE','Ministro Pistarini','Buenos Aires','Argentina')
,('BOG','El Dorado','Bogotá','Colombia')
Go
-- Vuelos
INSERT INTO AL_Vuelos (Aeropuerto_Salida,Aeropuerto_Llegada,Salida,Llegada,Matricula_Avion,Precio_Pasaje)
     VALUES ('APA','JFK','20120114 14:05', '20120114 17:30', 'USA5068', 150.95)
,('MIA','JFK','20120316 14:45', '20120316 18:30', 'USA5068', 290.95)
,('APA','MIA','20120514 07:05', '20120514 14:30', 'USA5077', 150.95)
,('APA','JFK','20120214 14:05', '20120214 17:30', 'USA5068', 150.95)
,('APA','JFK','20120314 14:05', '20120314 17:30', 'USA5068', 150.95)
,('APA','JFK','20120118 14:05', '20120118 17:30', 'USA5068', 155.95)
Go
INSERT INTO AL_Vuelos (Aeropuerto_Salida,Aeropuerto_Llegada,Salida,Llegada,Matricula_Avion,Precio_Pasaje)
     VALUES ('APA','AGP','20130114 14:05', '20130114 17:30', 'ESP4502', 850.95)
,('MAD','SVQ','20130914 14:45', '20130914 18:30', 'ESP4502', 90.85)
,('APA','MAD','20130514 07:05', '20130514 14:30', 'ESP8067', 450.95)
,('AGP','SVQ','20130214 14:05', '20130214 17:30', 'ESP8067', 50.55)
,('SVQ','JFK','20130314 14:05', '20130314 17:30', 'ESP5077', 450.75)
,('PMI','NRT','20130118 14:05', '20130118 17:30', 'ESP5077', 1255.95)
Go
INSERT INTO AL_Vuelos (Aeropuerto_Salida,Aeropuerto_Llegada,Salida,Llegada,Matricula_Avion,Precio_Pasaje)
     VALUES ('APA','AGP','20131114 14:05', '20131114 17:30', 'ESP4502', 850.95)
,('MAD','SVQ','20130201 14:45', '20130201 18:30', 'ESP4502', 90.85)
,('APA','MAD','20130202 07:05', '20130202 14:30', 'ESP8067', 450.95)
,('AGP','SVQ','20130214 14:05', '20130214 17:30', 'ESP8067', 50.55)
,('SVQ','JFK','20130314 14:05', '20130314 17:30', 'ESP5077', 450.75)
,('PMI','NRT','20130118 14:05', '20130118 17:30', 'ESP5077', 1255.95)
,('BUE','BOG','20130118 10:05', '20130118 12:30', 'USA5068', 1255.95)
Go
INSERT INTO AL_Vuelos (Aeropuerto_Salida,Aeropuerto_Llegada,Salida,Llegada,Matricula_Avion,Precio_Pasaje)
     VALUES ('LGA','AGP','20131116 14:05', '20131117 07:30', 'ESP4502', 650.95)
,('MAD','LGA','20130116 14:45', '20130116 22:30', 'FRA5021', 474.85)
,('CAI','MAD','20130517 07:05', '20130517 14:30', 'FRA4502', 550.95)
,('PMI','SVQ','20130214 09:05', '20130214 10:30', 'ESP8067', 80.55)
,('PMI','SVQ','20130214 14:05', '20130214 16:30', 'ESP8067', 80.55)
,('SVQ','CAI','20130614 14:05', '20130614 17:30', 'ESP5077', 450.75)
,('LGA','NRT','20130112 14:05', '20130112 17:30', 'FRA0955', 1255.95)
 
GO
-- Pasajeros
Insert INTO AL_Pasajeros (ID,Nombre,Apellidos,Direccion,Fecha_Nacimiento,Nacionalidad)
VALUES ('A003     ','Adela','Benítez','Calle estrecha, 7','19850401','España')
,('A007     ','Rafael','Pi','Rambla del tomate, 14','19800415','España')
,('A008     ','Walter','Smith','415th Lincoln St.','19780214','Estados Unidos')
,('A011     ','Jean','Dulac',NULL,'19840330','Francia')
,('A013     ','Drazen','Tontolculic',NULL,'19700210','Yugoslavia')
,('A015     ','Pilar','Gamarra','Victoria circus, 35','19720531','United Kingdom')
,('A017     ','Rafael','García','República Argentina, 15','19680405','España')
,('A018     ','Michael','Frunze',NULL,'19840914','Alemania')
,('A023     ','Esteban','López','Cualquiera, 31','19851204','Colombia')
,('A029     ','Justiniano','López','Cucurucho, 23','19710406','España')
,('A055     ','Daniel','Cruz','A la vuelta de la esquina','19850825','España')
,('A081     ','Roberto','Guterres','Rua dos libertadores, 44','19770905','Portugal')
,('B003     ','Antonio','Rodríguez','Libertad, 16','19810930','España')
,('B007     ','Juan','López',NULL,'19900224','Perú')
,('B008     ','Michael','Smith',NULL,'19731004','Estados Unidos')
,('B011     ','Marc','Dubois','Rue de la Republique','19890326','Francia')
,('B019     ','Elisendo','Gamarra',NULL,'19670620','Mexico')
,('B028     ','Daniel','García','14 de abril, 105','19870329','España')
,('C003     ','Antonio','Benítez',NULL,'19821222','España')
,('C008     ','Joseph','Smith','34th, Wall Street','19920823','Estados Unidos')
,('C011     ','Marie','Valmont',NULL,'19940424','Francia')
,('C015     ','Carla','Pontino','Arribata, 40','19700301','Italia')
,('C017     ','Rafael','García',NULL,'19750313','España')
,('C020     ','Margarita','López',NULL,'19700827','España')
,('S011     ','Kurt','Grün','CapullenStrasse','19940116','Alemania')
,('S013     ','Doran','Tracevic',NULL,'19710422','Yugoslavia')
,('S019     ','Joao','Da Silva','Largo do comerçio, 25','19811128','Portugal')
,('S058     ','Ariel','Muñoz',NULL,'19940428','España')
,('S069     ','Stephen','King','1214th, Sunset Boulevard','19631017','Estados Unidos')
,('S087     ','Elena','López',NULL,'19700326','España')
,('T002     ','André','Galois',NULL,'19921219','Francia')
,('T003     ','Carmen','Benítez','Av. de la Constitución, 38','19800212','España')
,('T007     ','Soledad','López',NULL,'19790918','España')
,('T008     ','Jane','Smith',NULL,'19930611','Estados Unidos')
,('T011     ','Monique','Dubois',NULL,'19710109','Francia')
,('T015     ','Juan','Gamarra',NULL,'19880708','Chile')
,('T017     ','Rafael','García',NULL,'19811018','Uruguay')
,('T107     ','Rosa','López',NULL,'19860318','España')
,('T113     ','Dimitri','Blikov',NULL,'19910209','Rusia')
GO
-- Pasajes
Declare CR_Pasajeros Cursor For Select ID From AL_Pasajeros
Declare @ID Char(9), @cont SmallInt, @contP SmallInt
Set @contP = 0
Open CR_Pasajeros
Fetch Next From CR_Pasajeros INTO @ID
While @@FETCH_STATUS = 0
Begin
	Set @cont = 0
	While @cont < 10
	Begin
		Insert Into AL_Pasajes (Numero,ID_Pasajero) Values (@ContP,@ID)
		Set @cont = @cont + 1
		Set @contP = @contP + 1
	End
	Fetch Next From CR_Pasajeros INTO @ID
End
Close CR_Pasajeros
Deallocate CR_Pasajeros

Go
-- Vuelos_Pasajes
Declare @cont SmallInt = 0, @numVuelos SmallInt, @Pasaje Int, @IndiceVuelo SmallInt, @CodigoVuelo Int
Declare @FechaVuelo SmallDateTime, @Embarcado Char (1)
Declare CR_Vuelos Scroll Cursor For Select Codigo, Salida From AL_Vuelos
Declare CR_Pasajes Cursor For Select Numero From AL_Pasajes

Open CR_Vuelos
Set @NumVuelos = @@CURSOR_ROWS
Open CR_Pasajes
Fetch Next From CR_Pasajes Into @Pasaje
While @@FETCH_STATUS = 0
Begin
	Set @cont = 0
	Set @IndiceVuelo = CAST(RAND()*@numVuelos + 1 AS SmallInt)
	Fetch Absolute @IndiceVuelo From CR_Vuelos INTO @CodigoVuelo, @FechaVuelo
	While Exists(Select Codigo_Vuelo From AL_Vuelos_Pasajes Where Numero_Pasaje = @Pasaje AND Codigo_Vuelo = @CodigoVuelo) AND @cont < 20
	Begin
		Set @IndiceVuelo = CAST(RAND()*@numVuelos + 1 AS SmallInt)
		Fetch Absolute @IndiceVuelo From CR_Vuelos INTO @CodigoVuelo, @FechaVuelo
		set @cont = @cont + 1
	End
	If @cont < 100
	Begin
		If @FechaVuelo < CURRENT_TIMESTAMP
			Set @Embarcado = 'S'
		else
			Set @Embarcado = 'N'
		Insert Into AL_Vuelos_Pasajes Values (@CodigoVuelo, @Pasaje, @Embarcado)
	End
	Fetch Next From CR_Pasajes Into @Pasaje
End
Close CR_Pasajes
Close CR_Vuelos
Deallocate CR_Pasajes
Deallocate CR_Vuelos
Go

-- Tarjetas
Declare @TablaAsientos Table (indice TinyInt, letra Char (1))
Declare @Vuelo int, @NumFilas SmallInt, @Fila SmallInt, @AsientosXFila TinyInt, @numero Int
Declare @Letra char(1)
Declare CR_Vuelos Cursor For Select Codigo, Filas, Asientos_x_Fila From AL_Vuelos Join AL_Aviones ON Matricula_Avion = Matricula
Insert Into @TablaAsientos (indice, letra) Values (1, 'A')
Insert Into @TablaAsientos (indice, letra) Values (2, 'B')
Insert Into @TablaAsientos (indice, letra) Values (3, 'C')
Insert Into @TablaAsientos (indice, letra) Values (4, 'D')
Insert Into @TablaAsientos (indice, letra) Values (5, 'E')
Insert Into @TablaAsientos (indice, letra) Values (6, 'F')
Insert Into @TablaAsientos (indice, letra) Values (7, 'G')
Insert Into @TablaAsientos (indice, letra) Values (8, 'H')
Insert Into @TablaAsientos (indice, letra) Values (9, 'I')
Insert Into @TablaAsientos (indice, letra) Values (10, 'J')
Open CR_Vuelos
Fetch Next From CR_Vuelos Into @Vuelo, @NumFilas, @AsientosXFila
While @@FETCH_STATUS = 0
Begin
Declare CR_Pasajes Insensitive Cursor For Select Numero From AL_Pasajes Join AL_Vuelos_Pasajes On Numero = Numero_Pasaje
	Where Codigo_Vuelo = @Vuelo
	Open CR_Pasajes
	Fetch Next From CR_Pasajes Into @numero
	While @@FETCH_STATUS = 0
	Begin
		Set @Fila = Cast (RAND()*@NumFilas + 1 AS SmallInt)
		Select @Letra = letra From @TablaAsientos Where indice = Cast (RAND()*@AsientosXFila + 1 AS TinyInt)
		While Exists (Select * From AL_Tarjetas Where Codigo_Vuelo = @Vuelo AND Fila_Asiento = @Fila AND Letra_Asiento = @Letra)
		Begin
			Set @Fila = Cast (RAND()*@NumFilas + 1 AS SmallInt)
			Select @Letra = letra From @TablaAsientos Where indice = Cast (RAND()*@AsientosXFila + 1 AS TinyInt)
		End
		Insert Into AL_Tarjetas (Codigo_Vuelo, Fila_Asiento, Letra_Asiento, Numero_Pasaje, Peso_Equipaje) 
			Values (@Vuelo, @Fila, @Letra, @numero, CAST(RAND()*20 + 10 AS decimal(3,1)))
		Fetch Next From CR_Pasajes Into @numero
	End
	Close CR_Pasajes
	Deallocate CR_Pasajes
	Fetch Next From CR_Vuelos Into @Vuelo, @NumFilas, @AsientosXFila
End
Close CR_Vuelos
Deallocate CR_Vuelos

