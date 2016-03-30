--Ejercicio 1
--Queremos saber nombre, apellidos y edad de cada miembro y el número de regatas que ha disputado en barcos de cada clase.
SELECT M.Nombre, M.apellidos, YEAR(GETDATE()-M.f_nacimiento)-1900 AS Edad, B.nombre_clase, COUNT (*) AS Regatas 
	FROM EV_Miembros AS M
		JOIN EV_Miembros_Barcos_Regatas AS MBR ON M.licencia_federativa = MBR.licencia_miembro
		JOIN EV_Barcos AS B ON MBR.n_vela = B.n_vela
	WHERE B.nombre_clase IS NOT NULL
	GROUP BY M.licencia_federativa, M.Nombre, M.apellidos, M.f_nacimiento, B.nombre_clase


--Ejercicio 2
--Miembros que tengan más de 250 horas de cursos y que nunca hayan disputado una regata compartiendo barco con Esteban Dido.
SELECT M.nombre, M.apellidos, SUM(C.duracion) AS Horas
	FROM EV_Miembros AS M
		JOIN EV_Miembros_Cursos AS MC ON M.licencia_federativa = MC.licencia_federativa
		JOIN EV_Cursos AS C ON MC.codigo_curso = c.codigo_curso
	WHERE M.licencia_federativa NOT IN (		-- Los que han compartido barco con Esteban
		SELECT M1.licencia_federativa 
			FROM EV_Miembros AS M1 
				JOIN EV_Miembros_Barcos_Regatas AS MBR1 ON M1.licencia_federativa = MBR1.licencia_miembro
				JOIN EV_Miembros_Barcos_Regatas AS MBR2 ON MBR1.f_inicio_regata = MBR2.f_inicio_regata AND MBR1.n_vela = MBR2.n_vela
				JOIN EV_Miembros AS M2 ON MBR2.licencia_miembro = M2.licencia_federativa
			WHERE M2.nombre = 'Esteban' AND M2.apellidos = 'Dido'
		)
	GROUP BY M.licencia_federativa, M.nombre, M.apellidos
	HAVING SUM(C.duracion) > 250

-- En realidad, no hace falta tener en la consulta las horas de curso, porque no nos las piden, con lo que podemos hacerla con EXCEPT
SELECT M.nombre, M.apellidos
	FROM EV_Miembros AS M
		JOIN EV_Miembros_Cursos AS MC ON M.licencia_federativa = MC.licencia_federativa
		JOIN EV_Cursos AS C ON MC.codigo_curso = c.codigo_curso
	GROUP BY M.licencia_federativa, M.nombre, M.apellidos
	HAVING SUM(C.duracion) > 250
EXCEPT
SELECT DISTINCT M1.nombre, M1.apellidos			-- Los que han compartido barco con Esteban
			FROM EV_Miembros AS M1 
				JOIN EV_Miembros_Barcos_Regatas AS MBR1 ON M1.licencia_federativa = MBR1.licencia_miembro
				JOIN EV_Miembros_Barcos_Regatas AS MBR2 ON MBR1.f_inicio_regata = MBR2.f_inicio_regata AND MBR1.n_vela = MBR2.n_vela
				JOIN EV_Miembros AS M2 ON MBR2.licencia_miembro = M2.licencia_federativa
			WHERE M2.nombre = 'Esteban' AND M2.apellidos = 'Dido' AND M1.nombre <> 'Esteban' AND M1.apellidos <> 'Dido'

--Ejercicio 3
--Crea una vista VTrabajoMonitores que contenga número de licencia, nombre y apellidos de cada monitor, número de cursos y número total de horas que ha impartido, así como el número total de alumnos que han participado en sus cursos. A la hora de contar los asistentes, se contaran participaciones, no personas. Es decir, si un mismo miembro ha asistido a tres cursos distintos, se contará como tres, no como uno. Deben incluirse los monitores a cuyos cursos no haya asistido nadie, para echarles una buena bronca.
GO
-- Esta vista añade a los datos del curso el número de asistentes
CREATE VIEW VAsistentesCursos AS
	SELECT C.codigo_curso, C.denominacion, C.duracion, C.f_inicio, C.licencia, COUNT (MC.licencia_federativa) AS Asistentes 
		FROM EV_Cursos AS C 
			JOIN EV_Miembros_Cursos AS MC ON C.codigo_curso = MC.codigo_curso
		GROUP BY C.codigo_curso, C.denominacion, C.duracion, C.f_inicio, C.licencia
GO
-- Esta vista nos da número de cursos y horas totales de cada monitor
CREATE VIEW V_TrabajoMonitores AS
	SELECT M.nombre, M.apellidos, COUNT (*) AS [Cursos Impartidos], SUM(C.duracion) AS [Horas Totales], SUM(C.Asistentes) AS TotalAlumnos
		FROM EV_Miembros AS M 
			JOIN EV_Monitores As Mo ON M.licencia_federativa = Mo.licencia_federativa
			JOIN VAsistentesCursos As C ON Mo.licencia_federativa = C.licencia
		GROUP BY M.nombre, M.apellidos


GO
--Ejercicio 4
--Número de horas de cursos acumuladas por cada miembro que no haya disputado una regata en la clase 470 en los dos últimos años (2013 y 2014). Se contarán únicamente las regatas que se hayan disputado en un campo de regatas situado en longitud Oeste (W). Se sabe que la longitud es W porque el número es negativo.
SELECT M.nombre, M.apellidos, ISNULL(SUM(C.duracion),0) AS [Horas cursos]
	FROM EV_Miembros AS M
		LEFT JOIN EV_Miembros_Cursos AS MC ON M.licencia_federativa = MC.licencia_federativa
		LEFT JOIN EV_Cursos AS C ON MC.codigo_curso = C.codigo_curso
	WHERE M.licencia_federativa NOT IN (
		SELECT DISTINCT MBR.licencia_miembro
			FROM EV_Miembros_Barcos_Regatas AS MBR 
				JOIN EV_Barcos AS B ON MBR.n_vela = B.n_vela
				JOIN EV_Regatas AS R ON MBR.f_inicio_regata = R.f_inicio
				JOIN EV_Campo_Regatas AS CR ON R.nombre_campo = CR.nombre_campo
			WHERE B.nombre_clase ='470' AND YEAR (R.f_inicio) BETWEEN 2013 AND 2014 AND CR.longitud_llegada < 0
		) 
	GROUP BY M.licencia_federativa, M.nombre, M.apellidos

--Ejercicio 5
--El comité de competiciones está preocupado por el bajo rendimiento de los regatistas en las clases Tornado y 49er, así que decide organizar unos cursos para repasar las técnicas más importantes. Los cursos se titulan "Perfeccionamiento Tornado” y "Perfeccionamiento 49er”, ambos de 120 horas de duración. Comezarán los días 21 de marzo y 10 de abril, respectivamente. El primero será impartido por Salud Itos y el segundo por Fernando Minguero.
--Escribe un INSERT-SELECT para matricular en estos cursos a todos los miembros que hayan participado en regatas en alguna de estas clases desde el 1 de Abril de 2014, cuidando de que los propios monitores no pueden ser también alumnos.
-- Insertamos los dos cursos con los códigos 21 y 22

-- Previamente hemos comprobado que los códigos de los monitores son 507 y 207, respectivamente
INSERT INTO EV_Cursos (codigo_curso,denominacion,f_inicio,duracion,licencia)
     VALUES (21,'Perf Tornado',DATEFROMPARTS(2015,3,21),120,507)
		,(22,'Perf 49r',DATEFROMPARTS(2015,4,10),120,207)

-- Ahora insertamos a los que cumplan las condiciones
INSERT INTO EV_Miembros_Cursos (licencia_federativa, codigo_curso)	
	SELECT DISTINCT MBR.licencia_miembro, 21 FROM EV_Miembros_Barcos_Regatas AS MBR
		JOIN EV_Barcos AS B ON MBR.n_vela = B.n_vela
		WHERE B.nombre_clase = 'Tornado' AND mbr.f_inicio_regata >= DATEFROMPARTS (2014, 4, 1) AND MBR.licencia_miembro <> 507

INSERT INTO EV_Miembros_Cursos (licencia_federativa, codigo_curso)	
	SELECT DISTINCT MBR.licencia_miembro, 22 FROM EV_Miembros_Barcos_Regatas AS MBR
		JOIN EV_Barcos AS B ON MBR.n_vela = B.n_vela
		WHERE B.nombre_clase = '49r' AND mbr.f_inicio_regata >= DATEFROMPARTS (2014, 4, 1) AND MBR.licencia_miembro <> 207
GO





SELECT * FROM EV_Miembros
SELECT * FROM EV_Cursos