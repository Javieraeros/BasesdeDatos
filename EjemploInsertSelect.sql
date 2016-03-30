go
use Northwind
go

select EmployeeID, LastName, FirstName
from Employees

select EmployeeID, LastName, FirstName into #Empleados
from Employees

select * 
from #Empleados

insert into #Empleados (LastName, FirstName)
	values('Irving','Lloyd'),
	('Brunel','Colette')

begin transaction

insert into Employees (LastName, FirstName)
	select LastName, FirstName
	from #Empleados
	where EmployeeID not in
	(
		select EmployeeID
			from Employees
	)

select * from Employees

rollback transaction
--commit transaction