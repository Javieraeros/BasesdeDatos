--Consultas sobre una sola Tabla con agregados

--Escribe el código SQL necesario para realizar las siguientes operaciones
--sobre la base de datos "pubs”
USE pubs
go

--1. Numero de libros que tratan de cada tema

select Type
	  ,count(*) as [Numero de libros]
from titles
group by type
go

--2. Número de autores diferentes en cada ciudad y estado

Select city
	  ,state
	  ,count(*) as Autores

from authors
group by city,state
go

--3. Nombre, apellidos, nivel y antigüedad en la empresa de los empleados con un nivel entre 100 y 150.

Select fname
	  ,lname
	  ,job_lvl
	  ,datediff(yyyy,hire_date,CURRENT_TIMESTAMP) as antigüedad

from employee
where (job_lvl between 100 and 150)
go
--4. Número de editoriales en cada país. Incluye el país.

select Country
	  ,count(*) as [Numero de editoriales]

from publishers
group by Country
go

--5. Número de unidades vendidas de cada libro en cada año (title_id, unidades y año).

select title_id
	  ,sum(qty) as [Número de unidades vendidas]
	  ,year(ord_date) as Año

from sales
group by title_id,year(ord_date)
go

--6. Número de autores que han escrito cada libro (title_id y numero de autores).

select title_id
	  ,count(title_id) as [Número de autores por libro]

from titleauthor
group by title_id
go

--7. ID, Titulo, tipo y precio de los libros cuyo adelanto inicial (advance) tenga un valor superior a $7.000, ordenado por tipo y título

select title_id
	  ,title
	  ,type
	  ,price
from titles
where advance>7000
order by type,title
go