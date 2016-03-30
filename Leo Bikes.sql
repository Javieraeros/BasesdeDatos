create database [Leo Bikes]
go
use [Leo Bikes]
go

create table Productos(
Código smallint constraint PK_Productos primary key  Not Null
, Nombre nvarchar(20) not null
, Stock smallint not null constraint CK_Stock check (Stock>=0)
, [Stock Mínimo] smallint not null constraint CK_StockMinimo check ([Stock Mínimo]>=0)
)

create table Clientes(
DI nvarchar(9) constraint PK_Cliente primary key Not Null constraint CK_DI check (DI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]')
, Nombre nvarchar(20) Not null
, Apellidos nvarchar(30) Not Null
, Localidad nvarchar(30) Null
, Descuento smallmoney Null
, [Saldo Puntos] smallint constraint CK_SaldoPuntos check ([Saldo Puntos]>=0)
)

create table FacturaPedidos(
ID smallint constraint PK_FacturaPedidos primary key identity(1,1)
, [Fecha Pedido] datetime not null
, [Fecha Envío] datetime null
, [Fecha Cobro] datetime null
, Importe smallmoney constraint CK_Importe check (Importe>=0)
, DI nvarchar(9)
, constraint FK_FacturaPedidos_Productos foreign key (DI) references Clientes (DI)
on delete no action on update cascade
, constraint CK_FechaEnvio check ([Fecha Envío]>=[Fecha Pedido])
)


create table FacturaPedidosProductos(
ID smallint Not Null
, Código smallint Not Null
, Cantidad smallint Not Null
, Precio smallmoney constraint CK_Precio check (Precio>=0)
, constraint PK_FacturaPedidosProductos primary key (ID,Código)
, constraint FK_FacturaPedidosProductos_FacturasPedidos foreign key (ID) references FacturaPedidos (ID)
on delete no action on update cascade
, constraint FK_FacturaPedidosProductos_ foreign key (Código) references Productos (Código)
on delete no action on update cascade
)