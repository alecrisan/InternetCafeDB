use Internet_Cafe

--Views

--1 table

CREATE VIEW View1
AS
	SELECT *
	FROM Employee
	WHERE Age >= 20

GO

--2 tables

SELECT *
FROM View1


CREATE VIEW View2
AS
	SELECT T.oid, T.pid, P.Name, P.Price, T.noOfP
	FROM Product P INNER JOIN TransactionDetails T ON P.pid = T.pid

GO

SELECT * 
FROM View2


--2 tables + GROUP BY

CREATE OR ALTER VIEW View3
AS
	SELECT T.oid as Order_number, C.Name as Category, P.Name, T.noOfP, P.Price
	FROM Category C INNER JOIN Product P ON C.CategoryId = P.CategoryId 
	INNER JOIN TransactionDetails T ON P.pid = T.pid
	GROUP BY C.Name, P.Name, T.oid, T.noOfP, P.Price

GO

SELECT *
FROM View3


--tests

--insert

CREATE OR ALTER PROCEDURE insert_test @table VARCHAR(30)
AS
	BEGIN  
		DECLARE @NoOfRows INT
		DECLARE @n INT 
		DECLARE @name VARCHAR(30)
		DECLARE @tableId INT
		
		SELECT TOP 1 @tableId = TableID FROM Tables 
		WHERE Name = @table

		SELECT TOP 1 @NoOfRows = NoOfRows FROM TestTables 
		WHERE TableID = @tableId AND TestID = 1
		 
		SET @n = 1 
	
		DECLARE @rest1 INT 
		SET @rest1 = @n % 21
		DECLARE @rest2 INT
		SET @rest2 = @n % 7

		WHILE @n < @NoOfRows 
		BEGIN  
			IF @tableId = 1
			BEGIN
				SET @name = 'Employee' + CONVERT (VARCHAR(5), @n)   
				INSERT INTO Employee (eid, Name, Salary, Age) VALUES (10+@n, @name, @n+200, 20)   
				SET @n = @n+1
			END

			ELSE IF @tableId = 2
			BEGIN
				DECLARE @rest INT 
				SET @rest = @n % 7
				SET @name = 'Product' + CONVERT (VARCHAR(5), @n)   
				INSERT INTO Product (pid, Name, CategoryId, Price) VALUES (6+@n, @name, 1, @n)   
				SET @n = @n+1
			END

			ELSE IF @tableId = 3
			BEGIN
				SET @name = 'Transaction' + CONVERT (VARCHAR(5), @n)  
				INSERT INTO TransactionDetails (oid, pid, noOfP) VALUES (@rest1, @rest2, @n)
				IF @rest2 = 6
					BEGIN
					SET @rest2 = 1 
					SET @rest1 = @rest1 + 1
					END
				ELSE
					SET @rest2 = @rest2 + 1
				   
				SET @n = @n+1
			END
		END
		
	END

GO

--delete

CREATE OR ALTER PROCEDURE delete_test @table VARCHAR(30)
AS
	BEGIN
		DECLARE @NoOfRows INT
		DECLARE @n INT 
		DECLARE @tableId INT
		
		SELECT TOP 1 @tableId = TableID FROM Tables 
		WHERE Name = @table

		SELECT TOP 1 @NoOfRows = NoOfRows FROM TestTables 
		WHERE TableID = @tableId AND TestID = 2
		 
		SET @n = 1

		WHILE @n < @NoOfRows 
		BEGIN
			IF @tableId = 1
			BEGIN
				DELETE FROM Employee
				WHERE eid >= 11

				SET @n = @n + 1
			END

			ELSE IF @tableId = 2
			BEGIN
				DELETE FROM Product
				WHERE pid >= 7

				SET @n = @n + 1
			END

			ELSE IF @tableId = 3
			BEGIN
				DELETE FROM TransactionDetails
				WHERE oid >= 0 AND pid IN (select pid from product)

				SET @n = @n + 1
			END
		END
	END

GO


CREATE OR ALTER PROCEDURE evaluate_test @view VARCHAR(30)
AS
	BEGIN 
		DECLARE @viewId INT
		
		SELECT TOP 1 @viewId = ViewID FROM Views
		WHERE Name = @view

		IF @viewId = 1
		BEGIN
			SELECT * FROM View1
		END

		ELSE IF @viewId = 2
		BEGIN
			SELECT * FROM View2
		END

		ELSE IF @viewId = 3
		BEGIN
			SELECT * FROM View3
		END

	END

GO

INSERT INTO Tests(Name) VALUES ('insert_test'), ('delete_test'), ('evaluate_test')

INSERT INTO TestViews(TestID, ViewID) VALUES (3, 1), (3, 2), (3, 3)

INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES (1, 1, 100, 1), (1, 2, 100, 2), (1, 3, 100, 3), (2, 1, 100, 3), (2, 2, 100, 2), (2, 3, 100, 1) 
 

CREATE OR ALTER PROCEDURE main_table1
AS
	BEGIN
		DECLARE @t1 DATETIME
		DECLARE @t2 DATETIME
		DECLARE @t3 DATETIME
		DECLARE @id INT

		SET @t1 = GETDATE()

		EXEC insert_test  'Employee'
		SELECT * FROM Employee
		EXEC delete_test 'Employee'

		SET @t2 = GETDATE()

		EXEC evaluate_test 'View1'

		SET @t3 = GETDATE()

		INSERT INTO TestRuns(Description, StartAt, EndAt) VALUES('test on table Employee and view 1', @t1, @t3)

		SELECT @id = TestRunID FROM TestRuns WHERE StartAt = @t1 AND EndAt = @t3

		INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt) VALUES(@id, 1, @t1, @t2)
	
		INSERT INTO TestRunViews(TestRunID, ViewID, StartAt, EndAt) VALUES(@id, 1, @t2, @t3)

		SELECT * FROM TestRuns
		SELECT * FROM TestRunTables
		SELECT * FROM TestRunViews
	END

GO

CREATE OR ALTER PROCEDURE main_table2
AS
	BEGIN
		DECLARE @t1 DATETIME
		DECLARE @t2 DATETIME
		DECLARE @t3 DATETIME
		DECLARE @id INT

		SET @t1 = GETDATE()

		EXEC insert_test 'Product'
		SELECT * FROM Product
		EXEC delete_test 'Product'

		SET @t2 = GETDATE()

		EXEC evaluate_test 'View2'

		SET @t3 = GETDATE()

		INSERT INTO TestRuns(Description, StartAt, EndAt) VALUES('test on table Product and view 2', @t1, @t3)

		SELECT @id = TestRunID FROM TestRuns WHERE StartAt = @t1 AND EndAt = @t3

		INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt) VALUES(@id, 2, @t1, @t2)
	
		INSERT INTO TestRunViews(TestRunID, ViewID, StartAt, EndAt) VALUES(@id, 2, @t2, @t3)

		SELECT * FROM TestRuns
		SELECT * FROM TestRunTables
		SELECT * FROM TestRunViews
	END

GO

CREATE OR ALTER PROCEDURE main_table3
AS
	BEGIN
		DECLARE @t1 DATETIME
		DECLARE @t2 DATETIME
		DECLARE @t3 DATETIME
		DECLARE @id INT

		SET @t1 = GETDATE()

		EXEC insert_test 'TransactionDetails'
		SELECT * FROM TransactionDetails
		EXEC delete_test 'TransactionDetails'

		SET @t2 = GETDATE()

		EXEC evaluate_test 'View3'
		 
		SET @t3 = GETDATE()

		INSERT INTO TestRuns(Description, StartAt, EndAt) VALUES('test on table TransactionDetails and view 3', @t1, @t3)

		SELECT @id = TestRunID FROM TestRuns WHERE StartAt = @t1 AND EndAt = @t3

		INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt) VALUES(@id, 3, @t1, @t2)
	
		INSERT INTO TestRunViews(TestRunID, ViewID, StartAt, EndAt) VALUES(@id, 3, @t2, @t3)

		SELECT * FROM TestRuns
		SELECT * FROM TestRunTables
		SELECT * FROM TestRunViews
	END

GO

EXEC main_table1
EXEC main_table2 
EXEC main_table3

