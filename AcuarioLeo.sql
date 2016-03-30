CREATE DATABASE ACUARISTAS
Go
USE ACUARISTAS
go
create table Tierras(
Código Int constraint PK_Tierras primary key,
Nombre nvarchar(20) Unique,
Arcillas decimal(5,2) Not Null default 0,
Silicatos decimal(5,2) Not Null default 0,
Nitratos decimal(5,2) Not Null default 0,
Sustratos decimal(5,2) Not Null default 0,
Otros decimal(5,2) Not Null default 0
)
Create table [Ser Vivo] (
Especie nvarchar(20) constraint PK_SerVivo primary key,
Temp_Máxima numeric(5,1) Null,
Temp_Mínima numeric(5,1) Null,
constraint CK_SerVivo check (Temp_Máxima>=Temp_Mínima)
)
Create table Acuarios (
Código Int identity (1,1) constraint PK_Acuario primary key,
Capacidad Int Null,
Alto Int Null,
Largo Int Null,
Ancho Int Null,
Temperatura decimal(5,1) Null,
Marca nvarchar(20) Not Null,
Modelo nvarchar(20) Not Null,
Código_Tierras Int Null
)
Create table Bombas(
Marca nvarchar(20) Not Null,
Modelo nvarchar(20) Not Null,
Caudal real Null,
Consumo Int Null,
constraint PK_Bomba primary key (Marca,Modelo)
)
Create table Peces(
Nombre_Común nvarchar(20) constraint PK_Peces primary key,
Color nvarchar(20) Null,
Tipo nvarchar(20) Null,
Tamaño_Medio real Null,
Especie nvarchar(20) Not Null,
Código_Alimentos Int Not Null
)
Create table Plantas(
Nombre_Común nvarchar(20) constraint PK_Plantas primary key,
Tamaño_Máximo real Null,
Necesidad_Luz Int Null,
Especie nvarchar(20) 
)
Create table Socios(
Número Int constraint PK_Socios primary key,
Nombre nvarchar(20) Not Null,
Apellidos nvarchar(30) Null,
Dirección nvarchar(30) Null,
Email nvarchar(30) Null,
Teléfono char(9) Null,
Código Int Null,
constraint CK_Socios_Email check (Email like '%@%')
)

Create table Alimentos(
Código Int identity (1,1) constraint PK_Alimentos primary key,
Tipo nvarchar(20) Null,
Nombre nvarchar(20) Null,
Valor_Energético Int Null
)
GO
create table SerVivo_Acuario(
Especie nvarchar(20) Not Null,
Código Int Not Null,
Cantidad Int Null,
constraint PK_Servivo_Acuario primary key (Especie,Código),
constraint FK_Acuario foreign key (Código) references Acuarios(Código) on update cascade on delete no action,
constraint FK_SerVivo foreign key (Especie) references [Ser Vivo](Especie) on update cascade on delete no action,
)
Create table Peces_Incompatibles(
Nombre_Común nvarchar(20) Not Null,
Nombre_Común2 nvarchar(20) Not Null,
constraint PK_Peces_Incompatibles primary key (Nombre_Común, Nombre_Común2),
constraint FK_Peces foreign key (Nombre_Común) references Peces(Nombre_Común) on update cascade on delete cascade,
constraint FK_Peces2 foreign key (Nombre_Común2) references Peces(Nombre_Común) on update no action on delete no action,
)
Create table PlantasTierras(
Nombre_Común nvarchar(20) Not Null constraint FK_Plantas foreign key references Plantas(Nombre_Común) on update cascade on delete no action,
Código_Tierras Int Not Null constraint FK_Tierras foreign key references Tierras(Código) on update cascade on delete no action,
constraint PK_PlantasTierras primary key (Nombre_Común,Código_Tierras)
)
GO
alter table Acuarios add constraint FK_AcuariosBombas Foreign key (Marca,Modelo) references Bombas(Marca,Modelo) on update cascade on delete no action
alter table Socios add constraint FK_AcuariosSocios Foreign key (Código) references Acuarios(Código) on update cascade on delete cascade
alter table Peces add constraint FK_PecesSerVivo Foreign key (Especie) references [Ser Vivo](Especie) on update cascade on delete no action
alter table Plantas add constraint FK_PlantasSerVivo Foreign key (Especie) references [Ser Vivo](Especie) on update cascade on delete no action
alter table Peces add constraint FK_PecesAlimentos Foreign key (Código_Alimentos) references Alimentos(Código) on update cascade on delete no action
GO
alter table Acuarios add constraint CK_Dimensiones check (alto>0 and ancho>0 and largo>0)
alter table Acuarios add constraint CK_Temperaturas check (Temperatura between 10 and 30)
alter table Peces alter column Tipo char(1) NUll
alter table Peces add constraint CK_TipoPeces check (Tipo LIKE '[TRPSAL]')
alter table Plantas add constraint CK_Necesidad_Luz check (Necesidad_Luz between 1 and 4)
alter table Peces_Incompatibles add constraint CK_Incompatibilidad check (Nombre_Común<>Nombre_Común2)
alter table Tierras add constraint CK_Porcentajes check (Arcillas+Silicatos+Nitratos+Sustratos+Otros=100)
alter table Socios add constraint UQ_Email Unique (Email)
GO 