create database [Starbutts Cafe]
go
use [Starbutts Cafe]
go
create table SC_Cafes(
Nombre_Cafe nvarchar(20) Not Null
,Origen nvarchar (20) Null
,Precio_Kilo smallmoney Not Null
,Propiedades nvarchar(300) Null
,constraint PK_SC_Cafes primary key (Nombre_cafe)
)
create table SC_Clientes(
Nombre_Cliente nvarchar(50) Not Null
,Nick varchar(10) Not Null 
,Contraseña nvarchar(50) Not Null
,Dirección nvarchar (50) Null
constraint PK_SC_Clientes primary key (Nick)
)
create table SC_Mezclas(
Id_Mezcla smallint Not Null
,Nombre_Mezcla nvarchar(20) Not Null
,Nick varchar(10) Not null 
,constraint PK_SC_Mezcla primary key (Id_Mezcla)
,constraint FK_SC_Clientes_Mezcla foreign key (nick) references SC_Clientes (nick)
on delete no action on update cascade
)
create table SC_CafesMezclas(
Nombre_Cafe nvarchar(20) Not Null
,Id_Mezcla smallint Not Null
,Proporción nvarchar(50) Not null
,constraint PK_SC_CafesMezclas primary key (Id_Mezcla,Nombre_Cafe)
,constraint FK_SC_Cafes_CafesMezclas foreign key(Nombre_Cafe) references SC_Cafes (Nombre_Cafe)
on delete no action on update cascade
,constraint FK_SC_Mezclas_CafesMezclas foreign key(Id_Mezcla) references SC_Mezclas(Id_Mezcla)
on delete no action on update cascade
)