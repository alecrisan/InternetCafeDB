USE Internet_Cafe


--INSERT

INSERT INTO Employee(eid, Name, Salary, Age) VALUES(1,'Ben', 1000, 24)
SELECT * FROM Employee

INSERT INTO Category(CategoryId, Name) VALUES(1, 'Snacks')
SELECT * FROM Category

INSERT INTO Product(pid, Name, CategoryId, Price) VALUES(1,'Chips', 6, 0)
--INCORRECT, PRICE MUST BE BETWEEN 0 AND 100
SELECT * FROM Product

INSERT INTO OrderFromC(oid, Cid) VALUES(1, 1)
SELECT * FROM OrderFromC

INSERT INTO TransactionDetails(oid, pid, noOfP) VALUES(1, 1, 3)
SELECT * FROM TransactionDetails

INSERT INTO ITGuy(itid, Name, Salary) VALUES(1, NULL, 234)
--INCORRECT, NAME CANNOT BE NULL
SELECT * FROM ITGuy


--UPDATE

UPDATE Employee
SET Salary = Salary + 50
SELECT * FROM Employee

UPDATE PC
SET PricePerH = 30
WHERE pcid = 2
SELECT * FROM PC

UPDATE PCCheck
SET ok = 'No'
WHERE pcid > 2
SELECT * FROM PCCheck

UPDATE Customer
SET bid = 1006
WHERE Name LIKE 'M%'
SELECT * FROM Customer

UPDATE ITGuy
SET Name = 'Leah'
WHERE Salary IN (140, 160)
SELECT * FROM ITGuy

--DELETE

DELETE FROM Product
WHERE Price > 20 AND CategoryId NOT IN (6, 7)
SELECT * FROM Product

DELETE FROM Employee
WHERE Name LIKE '%a' AND Age < 18
SELECT * FROM Employee

DELETE FROM Booth
WHERE eid IS NULL OR eid BETWEEN 10 AND 20
SELECT * FROM Booth

--SELECT QUERIES
--a. UNION, OR
--shows all the products that are in Category 1 or 3
SELECT P.Name, C.Name
FROM Product P, Category C
WHERE P.CategoryId = C.CategoryId AND P.CategoryId = 3
UNION
SELECT P2.Name, C2.Name
FROM Product P2, Category C2
WHERE P2.CategoryId = C2.CategoryId AND P2.CategoryId = 1

SELECT P.Name, C.Name
FROM Product P JOIN Category C ON P.CategoryId = C.CategoryId 
WHERE P.CategoryId = 1 OR P.CategoryId = 3

--b. INTERSECT, IN
--shows all the Customers with the pcid 3 or 2 and the customer id 4
SELECT C.cid, C.Name, C.pcid
FROM  Customer C JOIN PC P ON C.pcid = P.pcid
WHERE C.pcid = 3 OR C.pcid = 2
INTERSECT 
SELECT C2.cid, C2.Name, C2.pcid
FROM  Customer C2 JOIN PC P2 ON C2.pcid = P2.pcid
WHERE C2.cid = 4


SELECT C.cid, C.Name, C.pcid
FROM Customer C JOIN PC P ON C.pcid = P.pcid
WHERE C.pcid IN(3,2) AND C.cid = 4
ORDER BY C.Name


--c.EXCEPT, NOT IN
--shows all the Employees with age greater than 19, except 20 (and the table they wait on, ordered by the booth id)
SELECT E.Name, E.Age, B.bid
FROM Employee E, Booth B
WHERE E.eid = B.eid AND E.Age > 19
EXCEPT
SELECT E2.Name, E2.Age, B2.bid
FROM Employee E2, Booth B2
WHERE E2.eid = B2.eid AND E2.Age = 20 

SELECT E.Name, E.Age, B.bid
FROM Employee E JOIN Booth B ON  E.eid = B.eid
WHERE E.Age > 19 AND E.Age NOT IN(20)
ORDER BY B.bid
use InternetCafe
--d.JOINS
--shows all the orders, along with the products name, their price, the quantity, the customer who made each order,
--the pc used by each customer and the IT guy who fixed it
SELECT P.Name, P.Price, O.oid AS Order_nr, T.noOfP as Number_of_Products, C.Name as Customer, PC.pcid as PC, I.Name as ITGuy
FROM Product P INNER JOIN TransactionDetails T ON P.pid = T.pid
	INNER JOIN OrderFromC O ON T.oid = O.oid INNER JOIN Customer C ON O.cid = C.cid
	INNER JOIN PC Pc ON C.pcid = Pc.pcid INNER JOIN PCCheck Pcc ON Pc.pcid = Pcc.pcid
	INNER JOIN ITGuy I ON Pcc.itid = I.itid

--shows all the customers, their table and the employee who is in charge of it
SELECT C.Name, B.bid, E.Name
FROM Employee E LEFT JOIN Booth B ON E.eid = B.eid LEFT JOIN Customer C ON B.bid = C.bid

--shows all the products and their category
SELECT P.Name, C.Name
FROM Product P RIGHT JOIN Category C ON P.CategoryId = C.CategoryId

--shows all the tables, the customers for each one, and the pc used by each one(ordered by the pcid)
SELECT B.bid, C.Name, P.pcid
FROM Booth B FULL JOIN Customer C ON B.bid = C.bid FULL JOIN PC P ON C.pcid = P.pcid
ORDER BY P.pcid

--e. IN
--shows all employees' id and their name, but only those that contain 'e' in their name
SELECT E.eid, E.Name
FROM Employee E
WHERE E.Name LIKE '%e%' AND E.eid IN(SELECT B.eid
									 FROM BOOTH B
									 WHERE E.eid = B.eid)

--shows the top 5 products that were ordered by customers with id between 2 and 8
SELECT TOP 5 *
FROM Product P
WHERE P.pid IN(SELECT T.pid
			   FROM TransactionDetails T
			   WHERE T.oid IN(SELECT O.oid
							  FROM OrderFromC O
							  WHERE O.cid BETWEEN 2 AND 8))

--f. EXISTS
--shows all the IT guys, their id, name and salary, only if they marked a PC check as NOT ok
SELECT *
FROM ITGuy I 
WHERE EXISTS(SELECT *
			 FROM PCCheck P
			 WHERE P.ok = 'No' AND P.itid = I.itid)


--shows the top 5 products, their category and their price, only if their price is greater than 5
SELECT TOP 5 *
FROM Product P
WHERE P.Price > 5 AND EXISTS(SELECT *
							 FROM Category C
							 WHERE C.CategoryId = P.CategoryId)



--g. FROM
--shows all the customers and the pc's that they use
SELECT a.Name, a.pcid
FROM (SELECT P.pcid, C.Name
	  FROM PC P FULL JOIN Customer C ON P.pcid = C.pcid) a

--shows the top 10 orders, with the products name, the quantity and the customer that made the order
SELECT TOP 10 *
FROM (SELECT P.Name, T.noOfP, O.oid as Order_nr, O.cid as Customer
	  FROM Product P INNER JOIN TransactionDetails T ON P.pid = T.pid 
	  INNER JOIN OrderFromC O ON T.oid = O.oid) a


--h. GROUP BY, HAVING
--shows all the employees and the number of tables they wait on(grouped by their name)
SELECT E.Name, COUNT(B.bid) as NumberOfTables
FROM Employee E JOIN Booth B ON E.eid = B.eid
GROUP BY E.Name


--shows all the categories of products, and the average price for each(only if the avg is greater than 5)
SELECT C.Name, AVG(P.Price) as AveragePrice
FROM Product P INNER JOIN Category C ON P.CategoryId = C.CategoryId
GROUP BY C.Name
HAVING AVG(P.Price) > 5 

--shows all the pc id's that were checked
SELECT P.pcid
FROM PC P JOIN PCCheck Pc ON P.pcid = Pc.pcid
GROUP BY P.pcid
HAVING 1 < (SELECT COUNT(*)
			FROM PCCheck Pc)

--shows the maximum salary of an employee, and the salary with a bonus
SELECT DISTINCT E.Salary, E.Salary+50 as SalaryPlusBonus
FROM Employee E
GROUP BY E.Salary
HAVING MAX(E.Salary) >= (SELECT MAX(B.bid)
						 FROM Booth B)

--i. ANY, ALL

--ANY
--shows the IT guy's salaries (with cuts also), only if the salary equals any of the salaries of the employees
SELECT I.Salary, I.Salary/15 AS Cuts
FROM ITGuy I 
WHERE I.Salary = ANY(SELECT E.Salary
					  FROM Employee E)

--IN
SELECT I.Salary
FROM ITGuy I 
WHERE I.Salary IN (SELECT E.Salary
					  FROM Employee E)

--ALL
--shows the ages of employees, only if they're greater than all of the products' prices
SELECT DISTINCT E.Age
FROM Employee E
WHERE E.Age > ALL(SELECT P.Price
				   FROM Product P)

--MAX
SELECT DISTINCT E.Age
FROM Employee E
WHERE E.Age > (SELECT MAX(P.Price)
				   FROM Product P)

--ALL
--shows the pc's price per hour(with a discount also), only if it isn't equal with any of the products' prices
SELECT P.PricePerH, P.PricePerH-2 AS DiscountPrice
FROM PC P 
WHERE P.PricePerH <> ALL(SELECT P2.Price
						FROM Product P2)

--NOT IN
SELECT P.PricePerH
FROM PC P 
WHERE P.PricePerH NOT IN(SELECT P2.Price
						FROM Product P2)


--ANY
--shows the number of products ordered, only if it's smaller than their product id
SELECT DISTINCT *
FROM TransactionDetails T
WHERE T.noOfP < ANY(SELECT P.pid
					 FROM Product P
					 WHERE T.pid = P.pid)


--MIN
SELECT DISTINCT *
FROM TransactionDetails T
WHERE T.noOfP < (SELECT MIN(P.pid)
				 FROM Product P
				 WHERE T.pid = P.pid)