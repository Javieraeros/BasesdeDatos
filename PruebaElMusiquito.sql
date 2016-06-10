Use ElMusiquito
--Select * from Personas
Execute GuardaPersona 47428157,'Javier','pass','Ruiz','Rodriguez'

Declare @privilegios int
Execute @privilegios=fn_LogIn 47428157,'pass'
print @privilegios

EXECUTE BorraPersona 47428157,'pass'

Execute GuardaPersona 47428156,'Javi','nueva','Ruiz','Rodriguez'
Execute GuardaCliente 47428156,'micorreo@gmail.com','micasa'

Execute BorraPersona 47428156,'nueva'

Execute GuardaPersona	111111,'a','a','a','a'
Execute GuardaEmpleado 111111,150.32,2
Execute BorraPersona 111111,'a'

Execute GuardaInstrumento 1,'Trompeta','Fender','Esta es una peazo de trompeta güena,güena','f-500',500.23
Execute GuardaViento 1,'a','asdfasfg',0
Execute GuardaSaxofon 1,'Tenor','S80 c*','HojaLata','BronceM'
Execute GuardaPercusion 1,'b','Mezcla de madera y plástico',True
Execute GuardaCuerda 1,5,'Sib-Do',0
Execute GuardaGuitarra 1,'dfhjdgj',True,4
select * from Saxofones
Select * from Percusion
Select * from Cuerdas
Select * from Guitarras
Execute EliminaInstrumento 1

Use master