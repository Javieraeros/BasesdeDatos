--Boletin 7.2
--Consultas sobre una sola Tabla sin agregados

use pubs
go
--Título, precio y notas de los libros (titles) que tratan de cocina, ordenados de mayor a menor precio.
select title,price,notes from titles where type like '%cook%' order by price desc


--ID, descripción y nivel máximo y mínimo de los puestos de trabajo (jobs) que pueden tener un nivel 110.
select * from jobs where min_lvl<=110 and max_lvl>=110


--Título, ID y tema de los libros que contengan la palabra "and” en las notas
select title,title_id,type from titles where notes like '%and%'


--Nombre y ciudad de las editoriales (publishers) de los Estados Unidos que no estén en California ni en Texas
select pub_name,city from publishers where country='USA' and state<>'CA' and state<>'TX'


--Título, precio, ID de los libros que traten sobre psicología o negocios y cuesten entre diez y 20 dólares.
select title,price,title_id from titles where (type='psychology' or type='business') and price between 10 and 20


--Nombre completo (nombre y apellido) y dirección completa de todos los autores que no viven en California ni en Oregón.
select au_lname,au_fname,address,city,state from authors where state not in ('CA','OR')


--Nombre completo y dirección completa de todos los autores cuyo apellido empieza por D, G o S.
select au_lname,au_fname,address,city,state from authors where au_lname like '[DGS]%'


--ID, nivel y nombre completo de todos los empleados con un nivel inferior a 100, ordenado alfabéticamente
select emp_id,job_lvl,fname,lname from employee where job_lvl<=100 order by fname,lname



--Modificaciones de datos
--Inserta un nuevo autor.
begin transaction 
insert into authors
 values ('123-54-1237',
		'Ruiz',
		'Javier',
		'627173419111',
		'C\Platino nº42',
		'Utrera', 
		'SE',
		'41710',
		1)
select * from authors
commit
--Inserta dos libros, escritos por el autor que has insertado antes y publicados por la editorial "Ramona publishers”.
begin transaction 
INSERT INTO [dbo].[titles]
           ([title_id]
           ,[title]
           ,[type]
           ,[pub_id]
           ,[price]
           ,[advance]
           ,[royalty]
           ,[ytd_sales]
           ,[notes]
           ,[pubdate])
     VALUES
           (240209
           ,'Historia de una ida y de un regreso'
           ,'trad_cook'
           ,1756
           ,20
           ,2000
           ,13
           ,3210
           ,'Gran Libro, mejor persona'
           ,current_timestamp
		   )

INSERT INTO [dbo].[titles]
           ([title_id]
           ,[title]
           ,[type]
           ,[pub_id]
           ,[price]
           ,[advance]
           ,[royalty]
           ,[ytd_sales]
           ,[notes]
           ,[pubdate])
     VALUES
           (240209
           ,'Harry Popotter'
           ,'trad_cook'
           ,1756
           ,60
           ,20000
           ,15
           ,3210
           ,'Nada tiene que ver con el de JK Rowling'
           ,'20151119 00:00:00'
		   )
select * from titles
rollback
--Modifica la tabla jobs para que el nivel mínimo sea 90.
begin transaction
update jobs
set min_lvl=90 where min_lvl<=90
select * from jobs
rollback
--Crea una nueva editorial (publihers) con ID 9908, nombre Mostachon Books y sede en Utrera.
begin transaction
INSERT INTO [dbo].[publishers]
           ([pub_id]
           ,[pub_name]
           ,[city]
           ,[state]
           ,[country])
     VALUES
           ('9908'
           ,'Mostachon Books'
           ,'Utrera'
           ,'SE'
           ,'Spain')
select * from publishers
rollback
--Cambia el nombre de la editorial con sede en Alemania para que se llame "Machen Wücher" y traslasde su sede a Stuttgart
begin transaction
update publishers
   SET [pub_name] = 'Machen Wücher'
      ,[city] = 'Stuttgart'
 WHERE country='Germany'
GO
select * from publishers
rollback