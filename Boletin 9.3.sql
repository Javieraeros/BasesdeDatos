--Boletin 9.3
--Unidad 9. Boletin 4
--Escribe las siguientes consultas sobre la base de datos pubs.
Use pubs
go

--Consultas
--1. Título y tipo de todos los libros en los que alguno de los autores vive en California (CA).

Select t.title,
	   t.type
from titles as t
inner join titleauthor as ta
on t.title_id=ta.title_id
inner join authors as a
on ta.au_id=a.au_id
where state='CA'
group by t.title,t.type

--2. Título y tipo de todos los libros en los que ninguno de los autores vive en California (CA).

Select t.title,
	   t.type
from titles as t
inner join titleauthor as ta
on t.title_id=ta.title_id
inner join authors as a
on ta.au_id=a.au_id
group by t.title,t.type
EXCEPT
Select t.title,
	   t.type
from titles as t
inner join titleauthor as ta
on t.title_id=ta.title_id
inner join authors as a
on ta.au_id=a.au_id
where a.state='CA'
group by t.title,t.type

--3. Número de libros en los que ha participado cada autor, incluidos los que no han publicado nada.

Select a.au_fname,
	   a.au_lname,
	   count(ta.title_id) as [Número de libros escritos]
from authors as a
left join titleauthor as ta
on a.au_id=ta.au_id
group by a.au_fname,a.au_lname

--4. Número de libros que ha publicado cada editorial, incluidas las que no han publicado ninguno.

Select P.pub_name,
	   count(t.title_id) as [Número de libros publicados]
from publishers as p
left join titles as t
on p.pub_id=t.pub_id
group by P.pub_name

--5. Número de empleados de cada editorial.

Select p.pub_name,
	   count(e.emp_id) as [Número de empleados]
from employee as e
full join publishers as p
on e.pub_id=p.pub_id
group by p.pub_name

--6. Calcular la relación entre número de ejemplares publicados y número de empleados de cada editorial, incluyendo el nombre de la misma.

Select p.pub_name,
	   cast(count(distinct t.title_id)as real)/count(distinct e.emp_id)  as [Ejemplares publicados/Empleados]
from publishers as p
inner join employee as e
on p.pub_id=e.pub_id
left join titles as t
on p.pub_id=t.pub_id
group by p.pub_name
having count(distinct e.emp_id)>0

--7. Nombre, Apellidos y ciudad de todos los autores que han trabajado para la editorial "Binnet & Hardley” o "Five Lakes Publishing”

Select a.au_fname,
	   a.au_lname,
	   a.address
from authors as a
inner join titleauthor as ta
on a.au_id=ta.au_id
inner join titles as t
on ta.title_id=t.title_id
inner join publishers as p
on t.pub_id=p.pub_id
where p.pub_name in ('Binnet & Hardley','Five Lakes Publishing')

--8. Empleados que hayan trabajado en alguna editorial que haya publicado algún libro en el que alguno de los autores fuera Marjorie Green o 
--Michael O'Leary.

Select e.fname,
	   e.lname
from authors as a
inner join titleauthor as ta
on a.au_id=ta.au_id
inner join titles as t
on ta.title_id=t.title_id
inner join publishers as p
on t.pub_id=p.pub_id
inner join employee as e
on p.pub_id=e.pub_id
where a.au_fname='Marjorie' and a.au_lname='Green' or a.au_fname='Michael' and a.au_lname='O''Leary' 
group by e.fname,e.lname

--9. Número de ejemplares vendidos de cada libro, especificando el título y el tipo.
go
create view [Ventas por libro] as (
Select t.title,
	   t.type,
	   sum(s.qty) as Cantidad
from sales as s
inner join titles as t
on s.title_id=t.title_id
group by T.title,t.type
)
go
--10.  Número de ejemplares de todos sus libros que ha vendido cada autor.

Select a.au_fname,
	   a.au_lname,
	   sum(cantidad) as [Total de libros vendidos]
from authors as a
inner join titleauthor as ta
on a.au_id=ta.au_id
inner join titles as t
on ta.title_id=t.title_id
inner join [Ventas por libro] as VPL
on t.title=VPL.title
group by a.au_fname,a.au_lname

--11.  Número de empleados de cada categoría (jobs).

Select j.job_desc as [Categoria],
	   count(e.emp_id) as [total]
from employee as e
right join jobs as j
on e.job_id=j.job_id
group by j.job_desc


--12.  Número de empleados de cada categoría (jobs) que tiene cada editorial, incluyendo aquellas categorías en las que no haya ningún empleado.

Select p.pub_name as [Nombre de la editorial],
	   j.job_desc as [Categoría],
	   count(e.job_id) as [Numero de empleados]
from publishers as p
cross join jobs as j
left join employee as e
on p.pub_id=e.pub_id and j.job_id=e.job_id
group by p.pub_name,j.job_desc
order by p.pub_name
--13.  Autores que han escrito libros de dos o más tipos diferentes

Select a.au_fname,
	   a.au_lname
from authors as a
inner join titleauthor as ta
on a.au_id=ta.au_id
inner join titles as t
on ta.title_id=t.title_id
group by a.au_fname,a.au_lname
having count(distinct t.type)>=2

--14.  Empleados que no trabajan en editoriales que han publicado libros cuya columna notes contenga la palabra "and”
Select e.fname,
	   e.lname
from employee as e

EXCEPT
Select distinct e.fname,
	   e.lname
from employee as e
inner join publishers as p
on e.pub_id=p.pub_id
inner join titles as t
on p.pub_id=t.pub_id
where t.notes like ('%and%')
order by e.fname