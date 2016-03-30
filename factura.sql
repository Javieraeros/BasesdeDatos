create database Empresa_Javi
go
use Empresa_Javi
go
create table EJ_Clientes(
Cif_cliente char(9) Not Null
,Nombre varchar(30) Not Null 
,Dirección varchar(50) Not Null
, Telefono char(9) Null
, Ciudad char(20) Not Null
,constraint PK_EJ_Clientes primary key (Cif_Cliente)
)
create table EJ_Facturas(
Num_Factura SmallInt Not Null
,Fecha date Not Null Default CURRENT_TIMESTAMP
,Cif_cliente char(9) Foreign key  REFERENCES EJ_Clientes(Cif_Cliente)
 ON DELETE NO ACTION ON UPDATE CASCADE
, constraint PK_Facturas primary key (Num_Factura)
)
create table EJ_Productos(
Codigo varchar(30) Not Null
, Descripción varchar(100) Null
, Categoría varchar(30) Null
, Valor_Unit smallmoney not null
, constraint PK_EJ_Productos primary key (Codigo)
)
create table EJ_Fact_Productos(
Num_Factura SmallInt Foreign key  REFERENCES EJ_Facturas(Num_Factura)
ON DELETE NO ACTION ON UPDATE CASCADE
,Codigo varchar(30) Not Null Foreign key References EJ_Productos(Codigo) 
ON DELETE NO ACTION ON UPDATE CASCADE
,constraint PK_EJ_Fact_Productos primary key(Num_Factura,Codigo)
)