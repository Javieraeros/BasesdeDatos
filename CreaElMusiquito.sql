If OBJECT_ID('ElMusiquito') is Null
	BEGIN
	Create Database ElMusiquito
	END
GO

Use ElMusiquito
Go
/*Tipo de acceso:
	-0 para usuario normal
	-1 para empleado
	-2 para jefazo
*/
CREATE TABLE Personas(
	Dni bigint not null,
	Nombre nvarchar not null,
	Apellido1 nvarchar not null,
	Apellido2 nvarchar not null,
	Tipo_acceso int not null,
	constraint PK_Personas primary key (Dni) 
	)
CREATE TABLE Clientes(
	Dni bigint not null,
	Direccion nvarchar not null,
	Correoe nvarchar unique,
	constraint PK_Clientes primary key(Dni),
	constraint CK_CorreoValido check (Correoe like '%@%.%')
	)

CREATE TABLE Empleados(
	Dni bigint not null,
	Sueldo float not null,
	Tienda smallint not null
	constraint PK_Empleados primary key(Dni),
	constraint CK_Sueldo check (Sueldo>0)
	)

CREATE TABLE Instrumentos(
	Id int not null,
	Marca nvarchar not null,
	Descripcion nvarchar null,
	Modelo nvarchar null,
	Precio_Venta float not null,
	constraint PK_Instrumentos primary key(Id),
	constraint CK_Precio check (Precio_Venta>0)
	)

CREATE TABLE Viento(
	Id int not null,
	Afinacion char(1) not null,
	Tesitura nvarchar not null,
	Boquilla binary(1) not null
	)

CREATE TABLE

CREATE TABLE

CREATE TABLE

CREATE TABLE

CREATE TABLE


/*Añadir foreing keys*/
GO
