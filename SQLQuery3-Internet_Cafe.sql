use Internet_Cafe
--a.modify the type of a column

CREATE OR ALTER PROCEDURE D1
AS
	BEGIN
		ALTER TABLE Employee
		ALTER COLUMN Salary FLOAT
		PRINT('Table Employee: Salary changed from INT to FLOAT')
	END
GO

CREATE OR ALTER PROCEDURE I1
AS
	BEGIN
		ALTER TABLE Employee
		ALTER COLUMN Salary INT
		PRINT('Table Employee: Salary changed from FLOAT to INT')
	END
GO

--b.add/remove a column

CREATE OR ALTER PROCEDURE D2
AS
	BEGIN
		ALTER TABLE PC
		ADD Year INT
		PRINT('Table PC: Added a new column Year')
	END
GO

CREATE OR ALTER PROCEDURE I2
AS
	BEGIN
		ALTER TABLE PC
		DROP COLUMN Year
		PRINT('Table PC: Dropped the column Year')
	END
GO

--c.add/remove a DEFAULT constraint

CREATE OR ALTER PROCEDURE D3
AS
	BEGIN
		ALTER TABLE PCCheck
		ADD CONSTRAINT df_ok DEFAULT 'Yes' FOR ok
		PRINT('Table PCCheck: Added a new constraint, default value for ok = Yes')
	END
GO

CREATE OR ALTER PROCEDURE I3
AS
	BEGIN
		ALTER TABLE PCCheck
		DROP CONSTRAINT df_ok 
		PRINT('Table PCCheck: Dropped the constraint df_ok')
	END
GO


--d.add/remove a primary key

CREATE OR ALTER PROCEDURE D4
AS
	BEGIN
		CREATE TABLE Game(Gid INT IDENTITY, Name VARCHAR(50) NOT NULL)
		ALTER TABLE Game
		ADD CONSTRAINT pk_game PRIMARY KEY(Gid)
		PRINT('Table Game: Added a new table Game and a new PK')
	END
GO


CREATE OR ALTER PROCEDURE I4
AS
	BEGIN
		ALTER TABLE Game
		DROP CONSTRAINT pk_game
		DROP TABLE Game
		PRINT('Table Game: Dropped the PK constraint and the table Game')
	END
GO


--e.add/remove a candidate key

CREATE OR ALTER PROCEDURE D5
AS
	BEGIN
		CREATE TABLE ITCompany(itcid INT, Name VARCHAR(50) NOT NULL)
		ALTER TABLE ITCompany
		ADD CONSTRAINT uk_company UNIQUE(itcid)
		PRINT('Table ITCompany: Added a new table ITCompany and a unique key')
	END
GO

CREATE OR ALTER PROCEDURE I5
AS
	BEGIN
		ALTER TABLE ITCompany
		DROP CONSTRAINT uk_company 
		DROP TABLE ITCompany
		PRINT('Table ITCompany: Dropped the unique key constraint and the table ITCompany')
	END
GO


--f.add/remove a foreign key

CREATE OR ALTER PROCEDURE D6
AS
	BEGIN
		CREATE TABLE SideJob(Sid INT PRIMARY KEY,Name VARCHAR(50) NOT NULL)
		ALTER TABLE Employee
		ADD sid INT
		ALTER TABLE Employee
		ADD CONSTRAINT fk_sidejob FOREIGN KEY(sid) REFERENCES SideJob(sid)
		PRINT('Table Employee: Added a new table SideJob and a new FK for Employee')
	END
GO

CREATE OR ALTER PROCEDURE I6
AS
	BEGIN
		ALTER TABLE Employee
		DROP CONSTRAINT fk_sidejob
		DROP TABLE SideJob

		ALTER TABLE Employee
		DROP COLUMN sid
		PRINT('Table Employee: Dropped the FK constraint and the SideJob table')
	END
GO


--g.create/remove a table

CREATE OR ALTER PROCEDURE D7
AS
	BEGIN
		CREATE TABLE SpecialOffer(SOid INT PRIMARY KEY,
		Name VARCHAR(50) NOT NULL,
		Price INT,
		pid INT CONSTRAINT fg_product FOREIGN KEY(pid) REFERENCES Product(pid))
		PRINT('Table SpecialOffer: Created a new table SpecialOffer')
	END
GO

CREATE OR ALTER PROCEDURE I7
AS
	BEGIN
		DROP TABLE SpecialOffer
		PRINT('Table SpecialOffer: Dropped the table SpecialOffer')
	END
GO

-----------

CREATE TABLE Version(Vid INT PRIMARY KEY)

INSERT INTO Version(Vid) VALUES(0)

UPDATE Version
SET Vid = 0

CREATE OR ALTER PROCEDURE P @v INT
AS
	BEGIN

	DECLARE @nr INT
	DECLARE @stmtI VARCHAR(100)
	DECLARE @stmtD VARCHAR(100)

	SET @nr = (SELECT top 1 Vid FROM Version)

	IF(@v < 0 OR @v > 7)
		PRINT('Optiune invalida')
	ELSE
	BEGIN
	IF(@nr > @v) 
		--apelam I-urile
		WHILE(@nr > @v)
		BEGIN
			SET @stmtI = 'I' + CAST(@nr AS varchar);
			EXEC @stmtI
			SET @nr = @nr - 1
		END
	ELSE
	BEGIN
		--apelam D-urile
		WHILE(@nr < @v)
		BEGIN
			SET @stmtD = 'D' + CAST(@nr+1 AS varchar);
			EXEC @stmtD
			SET @nr = @nr + 1
		END
	END
	UPDATE Version
	SET Vid = @v
	END
	
	SET @nr = (SELECT top 1 Vid FROM Version)

	PRINT('Version: ' + CAST(@nr AS varchar))
	END
GO


EXEC P 0