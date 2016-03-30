/**Sandra`s database**/

/**Tablas en formas normales**/

/*
Couples(Name Woman, Name Man,Couple number, country)
Choreographies(ID,Technique, idea,Couple number[FK Couples])
Performances(ID, Day,ID Choreographie[FK Choreographies], Couple Number[FK Couples])
Judges(Name, Last name,Country,ID number, Degree)
Judgement(ID number[FK Judges], Couple number[FK Performances],Choreographie_ID [FK_Choreographies], Rythm,ComplexityCostumes,originality,Body expression, natural movements)
*/

create database [Dance]
go
use [Dance]
go

create table Couples(
Name_Woman nvarchar(40) Not Null,
Name_Man nvarchar(40) Not Null,
Couple_Number Int identity(1,1) constraint PK_Couples primary key,
Country nvarchar(30) Unique Not Null
)

create table Choreographies(
ID Int constraint PK_Choreographies primary key,
Technique nvarchar(40) Null,
Idea nvarchar(100) Null,
Couple_Number Int Not Null,
constraint FK_CouplesChoreographies foreign key (Couple_Number) references Couples(Couple_Number)
on update cascade on delete cascade
)

create table Performances(
ID int identity (0,1) constraint PK_Performances primary key,
Day_Per date Not Null,
ID_Choreographie Int,
Couple_Number Int,
constraint FK_ChoreographiesPerformances foreign key (ID_Choreographie) references Choreographies(ID)
on update cascade on delete no action,
constraint FK_PerformancesCouples foreign key (Couple_Number) references Couples(Couple_Number)
on update no action on delete no action
)
create table Judges(
Name nvarchar(20) Not Null,
Last_Name nvarchar(20) Null,
Country nvarchar(40) Not Null,
ID_Number Int constraint PK_Judges primary key,
Degree nvarchar(20) Null
)
create table Judgement(
ID_Number Int,
ID_Performance Int,
Rythm decimal(4,2),
ComplexityCostumes decimal(4,2),
Originality decimal(4,2),
Body_Expression decimal(4,2),
Natural_Movements decimal(4,2),
constraint PK_Judgement primary key (ID_Number,ID_Performance),
constraint FK_JudgementJudges foreign key (ID_Number) references Judges(ID_Number)
on update cascade on delete no action,
constraint FK_JudgementPerformances foreign key (ID_Performance) references Performances(ID)
on update cascade on delete no action,
constraint CK_Rythm check (Rythm between 0 and 10),
constraint CK_ComplexityCostumes check (ComplexityCostumes between 0 and 10),
constraint CK_Originality check (Originality between 0 and 10),
constraint CK_Body_Expression check (Body_Expression between 0 and 10),
constraint CK_Natural_Movements check (Natural_Movements between 0 and 10),
)

