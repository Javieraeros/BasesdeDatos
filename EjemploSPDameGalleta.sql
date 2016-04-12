GO
/*
Procedimiento simple para mostrar la sintaxis
*/
CREATE PROCEDURE DameGalleta -- No hay parámetros
AS
	BEGIN
	Print 'Galleta'
	END -- Procedure DameGalleta
GO
-- Prueba
EXECUTE DameGalleta



GO
/*
Versión 2
Le añadimos un parámetro
Vamos a configurar un valor por defecto para que los cambios sean transparentes al código
Es decir, las llamadas al procedimeinto anterior seguirán funcionando
Si no es posible, debemos mantener el antiguo y crear uno nuevo
*/
ALTER PROCEDURE DameGalleta @NumGalletas SmallInt = 1
AS
	BEGIN
	DECLARE @cont SmallInt = 1
	WHILE @cont <= @NumGalletas
		BEGIN
		Print CAST(@cont AS VarChar) + ' Galletas'
		SET @cont += 1
		END
	END -- Procedure DameGalleta
GO

-- Probamos la llamada antigua
EXECUTE DameGalleta

-- Y algunas nuevas
EXECUTE DameGalleta 7
EXECUTE DameGalleta 115
EXECUTE DameGalleta 0
EXECUTE DameGalleta -10



GO
/* Versión 3
Controlamos rango de valores de entrada entre 1 y 20
VALORES DE SALIDA:
	1 Número demasiado grande
	5 Número demasiado pequeño
*/
ALTER PROCEDURE DameGalleta @NumGalletas SmallInt = 1
AS
	BEGIN
	DECLARE @Error Int = 0
	DECLARE @cont TinyInt = 1
	IF @NumGalletas < 1
		SET @Error = 5
	ELSE
		IF  @NumGalletas >20 
			SET @Error = 1
		ELSE
			WHILE @cont <= @NumGalletas
				BEGIN
				Print 'Galleta'
				SET @cont += 1
				END -- While
	RETURN @Error
	END -- Procedure DameGalleta
GO

-- Pruebas
DECLARE @Salida Int
EXECUTE @Salida = DameGalleta
PRINT 'Salida: '+CAST (@Salida AS VarChar)
GO
DECLARE @Salida Int
EXECUTE @Salida = DameGalleta 7
PRINT 'Salida: '+CAST (@Salida AS VarChar)
GO
DECLARE @Salida Int
EXECUTE @Salida = DameGalleta 115 
PRINT 'Salida: '+CAST (@Salida AS VarChar)
GO
DECLARE @Salida Int
EXECUTE @Salida = DameGalleta -10
PRINT 'Salida: '+CAST (@Salida AS VarChar)
GO
/* Versión 4
Controlamos rango de valores de entrada entre 1 y 20
VALORES DE SALIDA (en un parámetro):
	"Grande" Número demasiado grande
	"Chico" Número demasiado pequeño
*/
ALTER PROCEDURE DameGalleta @NumGalletas SmallInt = 1 ,  @Error VarChar(6) OUTPUT
AS
	BEGIN
	DECLARE @cont TinyInt = 1
	SET @Error = NULL
	IF @NumGalletas < 1
		SET @Error = 'Chico'
	ELSE
		IF  @NumGalletas > 20 
			SET @Error = 'Grande'
		ELSE
			WHILE @cont <= @NumGalletas
				BEGIN
				Print CAST(@cont AS VarChar) + ' Galletas'
				SET @cont += 1
				END -- While
	END -- Procedure DameGalleta
GO
-- Pruebas
DECLARE @Salida VarChar(6)
EXECUTE DameGalleta @Error  = @Salida OUTPUT
PRINT 'Salida: '+ @Salida
GO
DECLARE @Salida VarChar(6)
EXECUTE  DameGalleta 7, @Salida OUTPUT
PRINT 'Salida: '+ @Salida
GO
DECLARE @Salida VarChar(6)
EXECUTE DameGalleta 115 , @Salida OUTPUT
PRINT 'Salida: '+ @Salida
GO
DECLARE @Salida VarChar(6)
EXECUTE DameGalleta -10 , @Salida OUTPUT
PRINT 'Salida: '+ @Salida