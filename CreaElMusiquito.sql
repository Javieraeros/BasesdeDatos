Use master
drop database ElMusiquito
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
	Nombre nvarchar(100) not null,
	Contrasenya nvarchar(100) not null,
	Apellido1 nvarchar(100) not null,
	Apellido2 nvarchar(100) not null,
	Tipo_acceso int not null,
	constraint PK_Personas primary key (Dni) 
	)
CREATE TABLE Clientes(
	Dni bigint not null,
	Direccion nvarchar(100) not null,
	Correoe nvarchar(100) unique,
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
	Marca nvarchar(100) not null,
	Descripcion nvarchar(100) null,
	Modelo nvarchar(100) null,
	Precio_Venta float not null,
	constraint PK_Instrumentos primary key(Id),
	constraint CK_Precio check (Precio_Venta>0)
	)

CREATE TABLE Vientos(
	Id int not null,
	Afinacion char(1) not null,
	Tesitura nvarchar(100) not null,
	Boquilla binary(1) not null,
	constraint PK_Vientos primary key(Id),
	constraint CK_VientosAfinacion check (Afinacion like '[ABCDEFGabcdefg]')
	)

CREATE TABLE Saxofones(
	Id int not null,
	Familia nvarchar(100) not null,
	Boquilla nvarchar(100) null,
	Material nvarchar(100) null,
	Acabado nvarchar(100) null,
	constraint PK_Saxofones primary key(Id),
	)

CREATE TABLE Percusion(
	Id int not null,
	Afinacion char(1) not null,
	Material nvarchar(100) null,
	Accesorio bit null,
	constraint PK_Percusion primary key(Id),
	constraint CK_PercusionAfinacion check (Afinacion like '[ABCDEFGabcdefg]')
	)

CREATE TABLE Cuerdas(
	Id int not null,
	Cuerdas int null,
	Registro nvarchar(100) null,
	Tipo_Cuerda binary(1) null,
	constraint PK_Cuerdas primary key(Id),
	constraint CK_CuerdasNumero check (Cuerdas>0)
	)

CREATE TABLE Guitarras(
	Id int not null,
	Tipo nvarchar(100) not null,
	PuenteFlotante bit not null,
	Controles int not null
	constraint PK_Guitarras primary key (Id),
	constraint CK_Controles check (Controles>0)
	)

CREATE TABLE Pastillas(
	Id int not null,
	Marca nvarchar(100) null,
	Modelo nvarchar(100) null,
	Bobinas int not null,
	constraint PK_Pastillas primary key (Id),
	constraint CK_Bobinas check (Bobinas between 1 and 3)
	)

CREATE TABLE Compras(
	DniCliente Bigint Not null,
	IdInstrumento int not null,
	constraint PK_Compras primary key (DniCliente,IdInstrumento)
	)

CREATE TABLE RelacionesPastillas(
	IdGuitarra int not null,
	IdPastilla int not null,
	constraint PK_RelacionesPastillas primary key(IdGuitarra,IdPastilla)
	/*Crear Triguer para evitar más de 3 apstillas por guitarra!!*/
	)

/*Foreing keys*/
Go
Alter Table Clientes add constraint FK_ClientesPersonas foreign key (Dni) references Personas (Dni) on delete cascade on update cascade
Alter Table Empleados add constraint FK_EmpleadosPersonas foreign key (Dni) references Personas (Dni) on delete cascade on update cascade
Alter Table Vientos add constraint FK_VientosInstrumentos foreign key (Id) references Instrumentos (Id) on delete cascade on update cascade
Alter Table Saxofones add constraint FK_SaxofonesInstrumentos foreign key (Id) references Vientos (Id) on delete cascade on update cascade
Alter Table Percusion add constraint FK_PercusionInstrumentos foreign key (Id) references Instrumentos (Id) on delete cascade on update cascade
Alter Table Cuerdas add constraint FK_CuerdasInstrumentos foreign key (Id) references Instrumentos (Id) on delete cascade on update cascade
Alter Table Guitarras add constraint FK_GuitarrasCuerdas foreign key (Id) references Cuerdas (Id) on delete cascade on update cascade
Alter Table Compras add constraint FK_ComprasPersonas foreign key (DniCliente) references Personas(Dni) on delete cascade on update cascade
Alter Table Compras add constraint FK_ComprasInstrumentos foreign key (IdInstrumento) references Instrumentos(Id) on delete cascade on update cascade
Alter Table RelacionesPastillas add constraint FK_RelacionesGuitarras foreign key (IdGuitarra) references Guitarras(Id) 
Alter Table RelacionesPastillas add constraint FK_RelacionesPastillas foreign key (IdPastilla) references Pastillas(Id)
/*Procedimientos y funciones*/
go
--Introduce una persona para poder loguearse
Create Procedure CreaPersona @Dni Bigint,
							 @Nombre nvarchar(100),
							 @Contrasenya nvarchar(100),
							 @Apellido1 nvarchar(100),
							 @Apellido2 nvarchar(100) as
BEGIN
	If @Dni Not In (Select Dni from Personas)  
	BEGIN
		Insert Into Personas(Dni,
							 Nombre,
							 Contrasenya,
							 Apellido1,
							 Apellido2,
							 Tipo_acceso)
					  Values(@Dni,
						     @Nombre,
							 ENCRYPTBYPASSPHRASE('password',@Contrasenya),
							 @Apellido1,
							 @Apellido2,
							 0)
	END
	ELSE
	BEGIN
		RAISERROR('Dicha persona ya se encuentra en la base de datos',-1,-1)
	END
END
Go

/* 
	 * Interfaz 
	 * Cabecera:function fn_LogIn (@Dni Bigint,@Contrasenya nvarchar(100)) returns int
	 * Proceso:Comprueba si existe una persona en la base de datos
	 * Precondiciones:Ninguna
	 * Entrada:1 big int para el dni, 1 cadena para la contraseña
	 * Salida:1 entero indicando los privilegios del usuario
	 * Entrada/Salida:Nada
	 * Postcondiciones:Entero asociado al nombre, devolver´´a -1 si el usuario no existe, o si la contraseña no coincide
	 */

CREATE function fn_LogIn (@Dni Bigint,@Contrasenya nvarchar(100)) returns int AS
BEGIN
	Declare @devolver int
	Declare @ContrasenyaDecodificada nvarchar(600)
	Declare @ContrasenyaCodificada nvarchar(600)
	--Inicializo a -1 por si el usuario no se encuentra en la base de datos
	set @devolver=-1
	Select @ContrasenyaCodificada=Contrasenya from Personas where Dni=@Dni
	set @ContrasenyaDecodificada=ENCRYPTBYPASSPHRASE(
	Select @devolver=Tipo_Acceso from Personas where Dni=@Dni
	RETURN @devolver
END
Go
/*Triggers*/
Go

GO
