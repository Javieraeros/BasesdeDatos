Use master
If Exists(Select * from dbo.sysdatabases where name='ElMusiquito')
	BEGIN
	Drop Database ElMusiquito
	END
GO

Create Database ElMusiquito

Go
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
	constraint PK_Personas primary key (Dni),
	constraint CK_TipoAcceso check (Tipo_Acceso between 0 and 2)
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
	Nombre nvarchar(100) not null,
	Marca nvarchar(100) not null,
	Descripcion nvarchar(1000) null,
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
	constraint CK_VientosAfinacion check (Afinacion like '[ABCDEFGabcdefg]'),
	constraint CK_VientosBoquilla check (Boquilla=0 or Boquilla=1)
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
	constraint CK_CuerdasNumero check (Cuerdas>0),
	constraint CK_TiopCuerda check (Tipo_Cuerda=0 or Tipo_Cuerda=1)
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
Alter Table Compras add constraint FK_ComprasClientes foreign key (DniCliente) references Clientes(Dni) on delete cascade on update cascade
Alter Table Compras add constraint FK_ComprasInstrumentos foreign key (IdInstrumento) references Instrumentos(Id) on delete cascade on update cascade
Alter Table RelacionesPastillas add constraint FK_RelacionesGuitarras foreign key (IdGuitarra) references Guitarras(Id) 
Alter Table RelacionesPastillas add constraint FK_RelacionesPastillas foreign key (IdPastilla) references Pastillas(Id)
/*Procedimientos y funciones*/
go
--Introduce una persona para poder loguearse
Create Procedure GuardaPersona @Dni Bigint,
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
		RAISERROR('Dicha persona ya se encuentra en la base de datos',16,-1)
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
	set @ContrasenyaDecodificada=DECRYPTBYPASSPHRASE('password',@ContrasenyaCodificada)
	if (@Contrasenya=@ContrasenyaDecodificada)
	BEGIN
		Select @devolver=Tipo_Acceso from Personas where Dni=@Dni
	END
	RETURN @devolver
END
GO
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure BorraUsuario @Dni Bigint, @Pass nvarchar(100)
	 * Proceso:Borra el usuario de la tabla personas
	 * Precondiciones:El usuario debe existir
	 * Entrada:1 bigint para el dni
				1 cadena para la contraseña
	 * Salida:Borrará el usuario
	 * Entrada/Salida:Nada
	 * Postcondiciones:el usuario qeudará borrado
	 */

Create Procedure BorraPersona @Dni Bigint, @Pass nvarchar(100) AS
Begin
	Declare @ContrasenyaDecodificada nvarchar(100)
	Declare @ContrasenyaCodificada nvarchar(600)

	Select @ContrasenyaCodificada=Contrasenya from Personas where Dni=@Dni
	Set @ContrasenyaDecodificada=DECRYPTBYPASSPHRASE('password',@ContrasenyaCodificada)
	IF(@ContrasenyaDecodificada=@Pass)
	Begin
		Delete From Personas Where dni=@Dni
	End
	Else
	Begin
		Raiserror('Error, la contraseña no coincide',16,1)
	End
End
Go
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure GuardaCliente @Dni Bigint,@Correoe nvarchar(100),@Direccion nvarchar(100)
	 * Proceso:Añade una persona a la tabla clientes (en asos de que ya no exista)
	 * Precondiciones:Ninguna
	 * Entrada:1 bigint para el dni
				1 cadena para el correoe
				1 cadena para la direccion
	 * Salida:la tabla con el nuevo cliente
	 * Entrada/Salida:Nada
	 * Postcondiciones:De existir dicho cliente en la tabla, mostrará un mensaje de error
	 */

Create Procedure GuardaCliente @Dni Bigint,@Correoe nvarchar(100),@Direccion nvarchar(100) AS
Begin
	If @Dni in(Select Dni from Clientes)
	Begin
		RAISERROR('Error, el cliente ya se encuentra en la base de datos',16,1)
	End
	Else
	Begin
		Insert into Clientes(Dni,Correoe,Direccion)
		Values(@Dni,@Correoe,@Direccion)
	end
End
GO
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure GuardaEmpleado @Dni Bigint,@sueldo float,@Tienda smallint
	 * Proceso:Añade una persona a la tabla empleados (en asos de que ya no exista)
	 * Precondiciones:El id debe estar en latabla de personas, el sueldo debe ser mayor qeu 0
	 * Entrada:1 bigint para el dni
				1 float para el sueldo
				1 smallint para la tienda
	 * Salida:la tabla con el nuevo empleado
	 * Entrada/Salida:Nada
	 * Postcondiciones:De existir dicho empleado en la tabla, mostrará un mensaje de error
	 */
Create Procedure GuardaEmpleado @Dni Bigint,@Sueldo float,@Tienda smallint AS
Begin
	If @Dni in(Select Dni from empleados)
	Begin
		RAISERROR('Error, el empleado ya se encuentra en la base de datos',16,1)
	End
	Else
	Begin
		Insert into empleados(Dni,Sueldo,Tienda)
		Values(@Dni,@Sueldo,@Tienda)
	end
End
Go

/* 
	 * Interfaz 
	 * Cabecera:Create Procedure GuardaInstrumento @Id Int,@Marca nvarchar(100),@Descripcion nvarchar(1000),@Modelo nvarchar(100),@Precio float
	 * Proceso:Crea un nuevo instrumento
	 * Precondiciones:El precio debe ser mayor que 0, sino mostrará error
	 * Entrada:1 entero para el id
				1 cadena para la marca
				1 cadena para la descripción
				1 cadena para el modelo
				1 float para el precio
	 * Salida:La tabla con el nuevo instrumento
	 * Entrada/Salida:nada
	 * Postcondiciones:El id del instrumento no debe estar en la tabla, de ser así mostrará un mensaje de error.
	 */
Create Procedure GuardaInstrumento @Id Int,@Nombre nvarchar(100),@Marca nvarchar(100),@Descripcion nvarchar(1000),@Modelo nvarchar(100),@Precio float AS
Begin
	If @Id Not in(Select Id from Instrumentos)
	Begin
		Insert into Instrumentos(Id,Nombre,Marca,Descripcion,Modelo,Precio_Venta)
		Values (@Id,@Nombre,@Marca,@Descripcion,@Modelo,@Precio)
	End
	Else
	Begin
		RAISERROR('Error, el instrumento ya se encuentra en la base de datos',16,1)
	End
End
Go
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure EliminaInstrumento @Id Int
	 * Proceso:Elimina un isntrumento
	 * Precondiciones:ninguna
	 * Entrada:1 entero para el id
	 * Salida:La talba sin el instrumento
	 * Entrada/Salida:Nada
	 * Postcondiciones:Si el instrumento no existe, mostrará un mensaje de error
	 */
Create Procedure EliminaInstrumento @Id int As
Begin
	If @Id In(Select Id from Instrumentos)
	Begin
		Delete from Instrumentos where Id=@Id
	End
	Else
	Begin
		RAISERROR('Error, el instrumento no se encuentra en la base de datos',16,1)
	End
End
Go
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure GuardaViento @Id int,@Afinacion char(1),@tesitura nvarchar(100),@Boquilla binary(1)
	 * Proceso:Guarda un instrumento de viento
	 * Precondiciones:Debe existir un instrumento con dicho id en la tabla instrumentos
	 * Entrada:1 entero para el id
				1 caracter para la afinación
				1 cadena para la tesitura
				1 binario para la boquilla
	 * Salida:La tabla con el nuevo instrumento de viento
	 * Entrada/Salida:Nada
	 * Postcondiciones:Mostrará un mensaje de error si la afinación no es válida, o si la boquilla no es válida
	 */

Create Procedure GuardaViento @Id int,@Afinacion char(1),@Tesitura nvarchar(100),@Boquilla binary(1) AS
Begin
	Insert into Vientos(Id,Afinacion,Tesitura,Boquilla)
	Values (@Id,@Afinacion,@Tesitura,@Boquilla)
End
Go
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure GuardaSaxofon @Id int,@Familia nvarchar(100),@Boquilla nvarchar(100),@Material nvarchar(100),@Acabado nvarchar(100)
	 * Proceso:Guarda un saxofon en la correspondiente tabla
	 * Precondiciones:El id debe encontrase en la tabla de vientos
	 * Entrada:1 entero para el id
				4 cadenas para los diferentes atributos
	 * Salida:La tabla con el nuevo saxofon
	 * Entrada/Salida:Nada
	 * Postcondiciones:Si el id no se encuentra en la tabla de vientos, mostrará mensaje de error
	 */
Create Procedure GuardaSaxofon @Id int,@Familia nvarchar(100),@Boquilla nvarchar(100),@Material nvarchar(100),@Acabado nvarchar(100) AS
Begin
	Insert into Saxofones(Id,Familia,Boquilla,Material,Acabado)
	Values (@Id,@Familia,@Boquilla,@Material,@Acabado)
End
go
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure guardaPercusion @Id int,@Afinacion char(1),@Material nvarchar(100),@Accesorio bit
	 * Proceso:Guarda un instrumento de percusión en la correspondiente tabla
	 * Precondiciones:el id debe encontrase en al tabla de instrumentos
	 * Entrada:1 entero para el id
				1 caracter para la afinacion
				1 cadena para el material
				1 bit para el accesorio
	 * Salida:La tabla con el nuevo percusión
	 * Entrada/Salida:nada
	 * Postcondiciones:si el id no se encuentra en la tabla de instrumentos, mostrará mensaje de error
	 */
Create Procedure GuardaPercusion @Id int,@Afinacion char(1),@Material nvarchar(100),@Accesorio bit AS
Begin
	Insert into Percusion(Id,Afinacion,Material,Accesorio)
	Values(@Id,@Afinacion,@Material,@Accesorio)
End
go
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure GuardaCuerda @Id int,@Cuerdas int,@registro nvarchar(100),@TipoCuerda binary(1)
	 * Proceso:Guarda un instrumento de Cuerda en la correspondiente tabla
	 * Precondiciones:El id debe encontrarse en la tabla de instrumentos
	 * Entrada:1 entero para el id
				1 entero para el número de cuerdas
				1 cadena para el registro
				1 binario para el tipo de cuerda
	 * Salida:La tabla con el nuevo instrumento de cuerda
	 * Entrada/Salida:Nada
	 * Postcondiciones:Si el id no se encuentra en la tabla de instrumentos,mostrará mensaje de error
	 */

Create Procedure GuardaCuerda @Id int,@Cuerdas int,@registro nvarchar(100),@TipoCuerda binary(1) AS
Begin
	Insert into Cuerdas(Id,Cuerdas,Registro,Tipo_Cuerda)
	Values (@Id,@Cuerdas,@registro,@TipoCuerda)
End
Go
/* 
	 * Interfaz 
	 * Cabecera:Create Procedure GuardaGuitarra @Id int, @Tipo nvarchar(100),@PuenteFlotante bit,@Controles int
	 * Proceso:Guarda un instrumendo Guitarra eleéctrica en la correspondiente tabla
	 * Precondiciones:El id debe encontrarse en la tabla de cuerdas
	 * Entrada:1 entero para el id
				1 cadena para el tipo
				1 bit para el puenteFlotante
				1 entero para los controles
	 * Salida:La tabla con el nuevo instrumento de guitarra
	 * Entrada/Salida:nada
	 * Postcondiciones:Si el ide no se encuentra en la tabla de instrumentos, mostrará mensaje de error
	 */
Create Procedure GuardaGuitarra @Id int, @Tipo nvarchar(100),@PuenteFlotante bit,@Controles int AS
Begin
	Insert into Guitarras(Id,Tipo,PuenteFlotante,Controles)
	Values(@Id,@Tipo,@PuenteFlotante,@Controles)
End
Go

/* 
	 * Interfaz 
	 * Cabecera:CreateProcedure GuardaPastilla @Id int,@Marca nvarchar(100),@Modelo nvarchar(100),@Bobinas int
	 * Proceso:
	 * Precondiciones:
	 * Entrada:
	 * Salida:
	 * Entrada/Salida:
	 * Postcondiciones:
	 */

go
/*Triggers*/
Go

GO
/* 
	 * Interfaz 
	 * Cabecera:
	 * Proceso:
	 * Precondiciones:
	 * Entrada:
	 * Salida:
	 * Entrada/Salida:
	 * Postcondiciones:
	 */
	 