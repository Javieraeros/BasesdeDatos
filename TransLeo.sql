--1. TransLeo sólo realiza envíos en España.


--5. Las relaciones se recoge, traslada y entrega tienen un atributo fecha.

--6. Cuando un cliente deposita un paquete en un centro, se dan de alta en la base de datos remitente y destinatario (si no teníamos ya sus datos) 
--y se asigna unnúmero de referencia al paquete. Al cliente se le asigna un nombre de usuario (cadena variable de longitud máxima 15) y 
--una contraseña (cadena variable de longitud máxima 10), para que pueda consultar el estado de su envío. Estos datos deben ser incorporados como atributos de la entidad cliente.

--7. El paquete puede ser trasladado de un centro a otro o entregado directamente al destinatario. Puede ser trasladado varias veces de centro antes de ser entregado. 
--Todos los movimientos del paquete se registran en labase de datos, al partir y al llegar. 

--8. El traslado de un paquete debe iniciarse en el centro donde fue entregado o donde terminó el traslado anterior. Las fechas deben estar correctamente encadenadas.

--10. Todos los movimientos de vehículos se registran en la base de datos como traslados, aunque no lleven ningún paquete. 
--Cada movimiento de un vehículo debe comenzar en el centro donde terminó el anterior. Cuando un vehículo sale a entregar paquetes a clientes siempre vuelve al centro de origen.

CREATE DATABASE TransLeo
go
use TransLeo
go

--2. Tenemos una serie de clientes, que actúan como remitentes o destinatarios de cada envío. 
--Los atributos del cliente son nombre (cadena variable de longitud máxima 20), apellidos (cadena variable de longitud máxima 40), 
--código (entero), dirección (cadena variable de longitud máxima 80), ciudad (cadena variable de longitud máxima 20), código postal (entero), 
--provincia (cadena variable de longitud máxima 20), teléfono (cadena fija de longitud 9), teléfono alternativo (cadena fija de longitud 9).

CREATE TABLE Clientes(
Código Int identity (1,1) constraint PK_Clientes primary key ,
Nombre nvarchar(20) Not Null,
Apellidos nvarchar(40) Not Null,
Dirección nvarchar(80) Null,
Ciudad nvarchar(20) Null,
Código_Postal Int Not Null,
Teléfono char(9) Not Null,
Teléfono2 char(9) Null,
Nombre_Usuario nvarchar(15) Null,
Contraseña nvarchar(10) Null
)

--3. Un cliente puede ser remitente de uno o varios envíos y destinatario de uno o varios. 
--Cada envío consta de un único paquete. Los atributos del paquete son: código (entero largo), alto (entero), ancho (entero), largo (entero), peso (entero). 


CREATE TABLE Paquetes(
Código BigInt identity (1,1) constraint PK_Paquetes primary key,
Alto Int Null,
Ancho Int Null,
Largo Int Null,
Peso Int Not Null,
Código_Remitente Int Not Null,
Código_Destinatario Int Not Null,
Código_Centro Int Not Null,
Matrícula char(7) Not Null,
Fecha_Entrega datetime Null,
Fecha_Envío datetime Null,
 constraint CK_Paquetes check (Fecha_Envío>=Fecha_Entrega)
)


--4. TransLeo tiene centros en distintas ciudades. La empresa realiza dos tipos de traslados: entre oficinas de la empresa y de una oficina a la dirección del destinatario. 
--Estos últimos se conocen como entregas. Los atributos del centro son código(entero), denominacion (cadena variable de longitud máxima 40), 
--dirección (cadena variable de longitud máxima 80), ciudad (cadena variable de longitud máxima 20), código postal (entero), provincia (cadena variable de longitud máxima 20),
-- teléfono (cadena fija de longitud 9), teléfono alternativo (cadena fija de longitud 9).

CREATE TABLE Centros(
Código Int identity (1,1) constraint PK_Centros primary key,
Denominación nvarchar(40) Null,
Dirección nvarchar(80) Null,
Ciudad nvarchar(20) Null,
Código_Postal int Not Null,
Teléfono nchar(9),
Teléfono_Alternativo nchar(9)
)

--9. Transleo dispone de una flota de vehículos que realizan los traslados y entregas. 
--Los atributos del vehículo son matricula (cadena fija de longitud 7), tipo (carácter), fecha adquisicion, fecha matriculacion, tipo carnet (cadena de longitud 3), 
--capacidad (entero), peso máximo transportable (entero).


CREATE TABLE Vehículos(
Matrícula char(7) Not Null constraint PK_Vehículo primary key,
Tipo char(1) Null,
Fecha_Adquisición date Null,
Fecha_Matriculación date Null,
Tipo_Carnet varchar (3),
Capacidad Int Null,
Peso_Máximo Int Not Null
)


--11. La relación dista tiene un atributo distancia (entero) que indica la distancia en kilómetros entre dos centros.


Create Table Centros_Centros(
Código_CentroA Int,
Código_CentroB Int,
Distancia Int,
constraint PK_CentroCentro primary key (Código_centroA,Código_CentroB),
constraint CK_CentrosCentros check (Código_centroA<>Código_CentroB),
constraint FK_CentroCentro foreign key (Código_CentroA) references Centros (Código) ON UPDATE CASCADE ON DELETE NO ACTION,
constraint FK_CentroCentro2 foreign key (Código_CentroB) references Centros (Código) ON UPDATE NO ACTION ON DELETE NO ACTION
)

--Para cumplir las formas normales, creamos la siguiente tabla

Create Table Provincias(
Código_Postal Int Not Null constraint PK_Provincias primary key, 
Provincia nvarchar(20) Not Null
)

--Create Table Clientes_Paquetes(
--Código_Remitente Int Not Null,
--Código_Destinatario Int Not Null,
--Código_Paquete BigInt Not Null,
--constraint PK_ClientesPaquetes primary key (Código_Remitente,Código_Destinatario,Código_Paquete),
--constraint FK_ClientesPaquetes_Clientes foreign key (Código_Remitente) references Clientes (Código) ON UPDATE CASCADE ON DELETE NO ACTION,
--constraint FK_CLientesPaquetes_Clientes2 foreign key (Código_Destinatario) references Clientes(Código) ON UPDATE NO ACTION ON DELETE NO ACTION,
--constraint FK_ClientesPaquetes_Paquetes foreign key (Código_Paquete) references Paquetes (Código) ON UPDATE CASCADE ON DELETE NO ACTION
--)

Create Table Centros_Paquetes_Vehículos(
Código_Traslado Int Identity (1,1) Not Null,
Código_Centro_Remitente Int Not Null,
Código_Centro_Destinatario Int Not Null,
Código_Paquete BigInt  Null,
Matrícula char(7) Not Null,
Fecha_Traslado_Salida smalldatetime Null, --No conocemos aún los medios para las restricciones entre tablas--
Fecha_Traslado_Llegada smalldatetime Null,
constraint PK_CentrosPaquetesVehículos primary key (Código_Traslado), --¿Fecha Traslado?--
constraint FK_CentrosPaquetesVehículos_Centros foreign key (Código_Centro_Remitente) references Centros (Código) ON UPDATE CASCADE ON DELETE NO ACTION,
constraint FK_CentrosPaquetesVehículos_Paquetes foreign key (Código_Paquete) references Paquetes (Código) ON UPDATE CASCADE ON DELETE NO ACTION,
constraint FK_CentrosPaquetesVehículos_Vehículos foreign key (Matrícula) references Vehículos (Matrícula) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO 

alter table Centros_Paquetes_Vehículos add constraint FK_CentrosPaquetesVehículos_Centros2 foreign key (Código_Centro_Destinatario) references Centros (Código) ON UPDATE NO ACTION ON DELETE cascade
alter table Clientes add constraint FK_Clientes_Provincias foreign key (Código_Postal) references Provincias (Código_Postal) on update CASCADE ON DELETE CASCADE
alter table Centros add constraint FK_Centros_Provincias foreign key (Código_Postal) references Provincias (Código_Postal) on update NO ACTION ON DELETE CASCADE
alter table Paquetes add constraint FK_ClientesPaquetes_Clientes foreign key (Código_Remitente) references Clientes (Código) ON UPDATE CASCADE ON DELETE NO ACTION
alter table Paquetes add constraint FK_CLientesPaquetes_Clientes2 foreign key (Código_Destinatario) references Clientes(Código) ON UPDATE NO ACTION ON DELETE NO ACTION
go
alter table Paquetes add constraint FK_Paquetes_Centros foreign key (Código_Centro) references Centros (Código) ON UPDATE NO ACTION ON DELETE NO ACTION
alter table Paquetes add constraint FK_Paquetes_Vehículos foreign key (Matrícula) references Vehículos (Matrícula) ON UPDATE NO ACTION ON DELETE NO ACTION