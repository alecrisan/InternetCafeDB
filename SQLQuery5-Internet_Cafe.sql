

--TABLES: PC, ITGuy, PCCheck

--a)
--nonclustered index scan

IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'N_idx_PC_Year')        
	DROP INDEX N_idx_PC_Year ON PC

CREATE NONCLUSTERED INDEX N_idx_PC_Year ON PC(Year)
GO

SELECT * FROM PC
ORDER BY Year

--nonclustered index seek

IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'N_idx_PC_Price')        
	DROP INDEX N_idx_PC_Price ON PC

CREATE NONCLUSTERED INDEX N_idx_PC_Price ON PC(PricePerH)

SELECT * FROM PC
WHERE PricePerH = 21


--clustered index scan

SELECT * FROM PC
ORDER BY pcid

--clustered index seek 

SELECT * FROM PC
WHERE pcid = 2

--key lookup

SELECT pcid, PricePerH, Year 
FROM PC
ORDER BY PricePerH


--b)

SELECT * FROM ITGuy
WHERE Salary = 200


IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'N_idx_ITGuy_Salary')        
	DROP INDEX N_idx_ITGuy_Salary ON ITGuy

CREATE NONCLUSTERED INDEX N_idx_ITGuy_Salary ON ITGuy(Salary)

SELECT * FROM ITGuy
WHERE Salary = 200


--c)

CREATE VIEW PCChecks_View
AS
	SELECT pc.checkId,pc.ok, p.pcid, p.PricePerH, it.Name, it.Salary
	FROM PC p INNER JOIN PCCheck pc ON p.pcid = pc.pcid INNER JOIN ITGuy it ON pc.itid = it.itid
	WHERE p.PricePerH > 19
GO

SELECT * FROM PCChecks_View
ORDER BY PricePerH