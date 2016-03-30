CREATE DATABASE Votaciones
GO
USE Votaciones
GO
/*
Las FK que unen tablas de nombres largos, tienen puesto como nombre la tabla a la que hacen referencia unicamente
*/

Create table Formaciones(
ID Int constraint PK_Formaciones primary key,
Nombre_Completo nvarchar(30) Not Null,
Nombre_Abreviado nvarchar(10) Null,
Fecha_Fundación date Null
)

Create table Partidos(
ID_Partido Int constraint PK_Partidos primary key, --No creo un identity para evitar conflictos entre los partidos--
Ideología nvarchar(50) Null, --No se que tipo de datos van aquí--
Nombre_Lider nvarchar(50) Null,
constraint FK_Formaciones_Partidos foreign key (ID_Partido) references Formaciones(ID) 
	on update cascade on delete cascade
)

Create table Coaliciones(
ID_Coalición Int constraint PK_Coaliciones primary key,
Ámbito varchar(10),
constraint FK_Formaciones_Coaliciones foreign key (ID_Coalición) references Formaciones(ID) 
	on update cascade on delete cascade
)

/*Creamos 3 tablas diferentes para que la tabla Candidaturas, no tenga 
uno de sus atributos (ID_Partido o ID_Coalición) siempre nulo, es decir,
para evitar que una tupla tenga obligatoriamente un valor nulo*/

Create table Partidos_Coaliciones(
ID_Partido Int,
ID_Coalición Int,
constraint PK_Partidos_Coaliciones primary key (ID_Partido,ID_Coalición),
constraint FK_Partidos foreign key (ID_Partido) references Partidos(ID_Partido),
constraint FK_Coaliciones foreign key (ID_Coalición) references Coaliciones(ID_Coalición)
	on update cascade on delete no action --por si queremos mantener una coalición (para echárselo después en cara a un partido que se unió con otro  :`D )
)

Create table Candidaturas(
ID_Candidatura Int identity(1,1) constraint PK_Candidatura primary key,
Nombre nvarchar(30) Not Null,
Nombre_Representante nvarchar(20) Null,
Apellidos_Representante nvarchar(30) Null,
Teléfono char(9) Null,
ID_Formación Int Not Null, --cardinalidad 1,n--
Código Int Null, --cardinalidad 0,n--
constraint FK_Formaciones_Candidaturas Foreign key (ID_Formación) references Formaciones(ID)
	on update cascade on delete cascade
)

Create table Candidatos(
DNI char(9) constraint PK_Candidatos primary key,
Nombre nvarchar(20) Not Null,
Apellidos nvarchar(30) Null,
Fecha_Nacimiento date Null,
Orden_Elección Int Unique Null, --Dejamos a Nulo, por si no queremos guardar el orden en el que ha sido elegido--
ID_Candidatura Int Not Null, --No contemplamos el caso de un candidato que vaya por libre--
Numero_Orden  Int Unique Not Null,  --Orden en la lista de la formación--
constraint FK_Candidaturas_Candidatos foreign key (ID_Candidatura) references Candidaturas(ID_Candidatura)
	on update cascade on delete cascade --No contemplamos el caso de un candidato que vaya por libre--
)

Create table Apoderados(
DNI char(9) constraint PK_Apoderados primary key,
Nombre nvarchar(20) Not Null,
Apellidos nvarchar(30) Null,
Fecha_Nacimiento date Null,
ID_Candidatura Int Not Null,
constraint FK_Candidaturas_Apoderados foreign key (ID_Candidatura) references Candidaturas(ID_Candidatura)
	on update cascade on delete cascade --borramos por tratarse de una relación de existencia--
)

Create table Interventores(
DNI char(9) constraint PK_Interventores primary key,
Nombre nvarchar(20) Not Null,
Apellidos nvarchar(30) Null,
Fecha_Nacimiento date Null,
ID_Candidatura Int Not Null,
Número_Distrito Int Not Null,
Número_Sección Int Not Null,
Número_Mesa Int Not Null,
constraint FK_Candidaturas_Interventores foreign key (ID_Candidatura) references Candidaturas(ID_Candidatura)
	on update cascade on delete no action
)

Create table Circunscripciones(
Código Int constraint PK_Circunscripciones primary key,
Nombre nvarchar(30) Not Null --no pongo unique porque no sé si hay dos circunscripciones con el mismo nombre--
)

Create table Mesas(
Número_Distrito Int Unique,
Número_Sección Int,
Número_Mesa Int,
Direcciones nvarchar(1200) Null,
Número_Electores Int Not Null,
Código Int Not Null,
constraint PK_Mesas primary key (Número_Distrito,Número_Sección,Número_Mesa),
constraint FK_Circunscripciones_Mesas foreign key (Código) references Circunscripciones(Código)
	on update cascade on delete no action
)

Create table VotaCongreso(
Número_Distrito Int Not Null,
Número_Sección Int Not Null,
Número_Mesa Int Not Null,
ID_Candidatura Int Not Null,
Número_Votos Int Null,
constraint PK_VotaCongreso primary key (Número_Distrito,Número_Sección,Número_Mesa,ID_Candidatura),
constraint FK_Mesas_VotaCongreso foreign key (Número_Distrito,Número_Sección,Número_Mesa) references Mesas(Número_Distrito,Número_Sección,Número_Mesa)
	on update cascade on delete no action,
constraint FK_Candidaturas_VotaCongreso foreign key (ID_Candidatura) references Candidaturas(ID_Candidatura)
	on update cascade on delete no action
)
Create table VotaSenado(
Número_Distrito Int Not Null,
Número_Sección Int Not Null,
Número_Mesa Int Not Null,
Código_Circunscripción Int Not Null,
Número_Votos Int Null,
constraint PK_VotaSenado primary key (Número_Distrito,Número_Sección,Número_Mesa,Código_Circunscripción),
constraint FK_Mesas_VotaSenado foreign key (Número_Distrito,Número_Sección,Número_Mesa) references Mesas(Número_Distrito,Número_Sección,Número_Mesa)
	on update cascade on delete no action,
constraint FK_Circunscripciones_VotaSenado foreign key (Código_Circunscripción) references Circunscripciones(Código)
	on update no action on delete no action
)


GO
alter table Candidaturas add constraint FK_Circunscripciones_Candidaturas foreign key (Código) references Circunscripciones(Código) on update no action on delete no action
alter table Interventores add constraint FK_Mesas_Interventores foreign key (Número_Distrito,Número_Sección,Número_Mesa) references Mesas(Número_Distrito,Número_Sección,Número_Mesa)
	on update cascade on delete no action

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																				--EJERCICIO 3--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
alter table Formaciones add constraint CK_Fecha check (Fecha_Fundación<=current_timestamp)
alter table VotaCongreso add constraint CK_Votos_Congreso check (Número_Votos>=0)
alter table VotaSenado add constraint CK_Votos_Seando check (Número_Votos>=0)
alter table Candidatos add constraint CK_DNI check (DNI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_') --Cambiamos letra por carácter--
alter table Apoderados add constraint CK_DNI2 check (DNI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_')
alter table Interventores add constraint CK_DNI3 check (DNI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_')
alter table Mesas add constraint CK_Electores check (Número_electores between 10 and 1500)
alter table Coaliciones add constraint CK_Ambito check (Ámbito in '[Local]' ) 