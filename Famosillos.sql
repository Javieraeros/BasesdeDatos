create database Famosillos
go
use Famosillos
go
create table Famosillos (
Código_Fam smallint Not Null
, Nombre nvarchar(50) Not Null
, Nombre_Publico nvarchar(30) Null
, Fecha_Nacimiento date Not Null
, Lugar_Nacimiento nvarchar(30) Not Null
, Dirección nvarchar(30) Null
, CP_Famosillo nvarchar(6) Not Null
, Provincia nvarchar(20) Not Null
, Email nvarchar(30) Not null
, Nacionalidad nvarchar(20) Not Null
, constraint PK_F_Famosillos primary key (Código_Fam)
)
create table Locales (
Id_Local smallint Not Null
, Nombre nvarchar(20) Not Null
, Dirección nvarchar(30) Not Null
, CP_Locales nvarchar(6) Not Null
, Provincia nvarchar(20) Not null
, Teléfono nvarchar(9) Null
, Email nvarchar(30) Null
, Tipo nvarchar(50) Null
, constraint PK_F_Locales primary key (Id_Local)
)
create table Medios (
Nombre nvarchar(30) Not Null
, Tipo nvarchar(50) Not Null
, Dirección nvarchar(30) Not Null
, CP_Medios nvarchar(6) Not null
, Provincia nvarchar(20) Null
, Teléfono nvarchar(10) Null
, constraint PK_F_Medios primary key (Nombre)
)
 
create table Exclusivas (
Código_Exc smallint Not null
, Fecha date Null
, Descripción nvarchar(100) Null
, Precio smallmoney Not Null
, Nombre_Medio nvarchar(30) Not Null
, constraint PK_F_Exclusivas primary key (Código_Exc)
, constraint FK_F_MediosExclusivas foreign key (Nombre_Medio) references Medios (Nombre)
 on delete no action on update cascade
)
create table Grupos (
Id_Grupo smallint Not Null
, Nombre nvarchar(30) Not Null
, Estilo nvarchar(30) Not Null
, Teléfono nvarchar(10) Null
, Email nvarchar(30) null
, constraint PK_F_Grupos primary key (Id_Grupo)
)
create table Fiestas (
Id_Fiesta smallint Not Null
, Fecha_Hora datetime Not Null Unique
, Tema nvarchar(50) Null
, Id_Local smallint Not Null
, constraint PK_F_Fiestas primary key (Id_Fiesta)
, constraint FK_F_FiestasLocales foreign key (Id_Local) references Locales (Id_Local)
on delete no action on update cascade
)
create table Artistas (
Id_Artista smallint Not Null
, Nombre nvarchar(30) Not Null
, Instrumento nvarchar(20) Not null
, Id_Grupo smallint Not Null
, constraint PK_F_Artistas primary key (Id_Artista)
, constraint FK_F_ArtistasGrupos foreign key (Id_Grupo) references Grupos (Id_Grupo)
 on delete no action on update cascade
 )
 create table Famosillos_Fiestas (
