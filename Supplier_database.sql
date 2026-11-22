CREATE DATABASE SUPPLIER;
USE SUPPLIER;

-- =========================
-- TABLE CREATION
-- =========================

CREATE TABLE SUPPLIER (
    SID INT PRIMARY KEY,
    SNAME VARCHAR(30),
    ADDRESS VARCHAR(50)
);

CREATE TABLE PART (
    PID INT PRIMARY KEY,
    PNAME VARCHAR(30),
    COLOR VARCHAR(20)
);

CREATE TABLE CATALOG (
    SID INT,
    PID INT,
    COST INT,
    PRIMARY KEY (SID, PID),
    FOREIGN KEY (SID) REFERENCES SUPPLIER(SID),
    FOREIGN KEY (PID) REFERENCES PART(PID)
);

-- =========================
-- INSERT DATA
-- =========================

INSERT INTO SUPPLIER VALUES
(1,'Smith','Bangalore'),
(2,'Jones','Mumbai'),
(3,'Blake','Delhi'),
(4,'Clark','Chennai'),
(5,'Adams','Hyderabad');

INSERT INTO PART VALUES
(101,'Keyboard','Black'),
(102,'Mouse','Red'),
(103,'Monitor','Black'),
(104,'Printer','Red'),
(105,'CPU','Blue');

INSERT INTO CATALOG VALUES
(1,101,500),
(1,102,300),
(1,103,8000),
(2,101,450),
(2,104,5000),
(3,102,250),
(3,103,7500),
(3,105,12000),
(4,104,4500),
(4,105,11000),
(5,101,400),
(5,102,350);

-- =========================
-- QUERIES
-- =========================

-- 1. Find the most expensive supplier
SELECT P.PID, P.PNAME, S.SNAME, C.COST
FROM PART P
JOIN CATALOG C ON P.PID = C.PID
JOIN SUPPLIER S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MAX(COST)
    FROM CATALOG
);

-- 2. Suppliers who do not supply red parts
SELECT S.SNAME
FROM SUPPLIER S
WHERE S.SID NOT IN (
    SELECT C.SID
    FROM CATALOG C
    JOIN PART P ON C.PID = P.PID
    WHERE P.COLOR = 'Red'
);

-- 3. Total cost per supplier
SELECT S.SID, S.SNAME, SUM(C.COST) AS TOTAL_COST
FROM SUPPLIER S
JOIN CATALOG C ON S.SID = C.SID
GROUP BY S.SID, S.SNAME;

-- 4. Suppliers supplying at least 2 parts
-- costing less than 20
SELECT S.SID, S.SNAME
FROM SUPPLIER S
JOIN CATALOG C ON S.SID = C.SID
WHERE C.COST < 20
GROUP BY S.SID, S.SNAME
HAVING COUNT(DISTINCT C.PID) >= 2;

-- 5. Cheapest supplier for each part
SELECT P.PID, P.PNAME, S.SNAME, C.COST
FROM PART P
JOIN CATALOG C ON P.PID = C.PID
JOIN SUPPLIER S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MIN(C2.COST)
    FROM CATALOG C2
    WHERE C2.PID = P.PID
);

-- =========================
-- VIEW
-- =========================

-- 6. Most expensive supplier for each part
CREATE VIEW MOST_EXPENSIVE_SUPPLIERS AS
SELECT P.PID, P.PNAME, S.SNAME, C.COST
FROM PART P
JOIN CATALOG C ON P.PID = C.PID
JOIN SUPPLIER S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MAX(C2.COST)
    FROM CATALOG C2
    WHERE C2.PID = P.PID
);

SELECT * FROM MOST_EXPENSIVE_SUPPLIERS;

-- =========================
-- TRIGGER 1
-- =========================

-- Prevent cost less than 1

DELIMITER //

CREATE TRIGGER CHECK_COST
BEFORE INSERT ON CATALOG
FOR EACH ROW
BEGIN
    IF NEW.COST < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cost must be at least 1';
    END IF;
END//

DELIMITER ;

-- Trigger test
INSERT INTO CATALOG VALUES (5,103,200);

-- This insert should generate an error
INSERT INTO CATALOG VALUES (5,104,0);

-- =========================
-- TRIGGER 2
-- =========================

-- Set cost to 100 if NULL

DELIMITER //

CREATE TRIGGER DEFAULT_COST
BEFORE INSERT ON CATALOG
FOR EACH ROW
BEGIN
    IF NEW.COST IS NULL THEN
        SET NEW.COST = 100;
    END IF;
END//

DELIMITER ;

-- Trigger test
INSERT INTO CATALOG VALUES (5,105,NULL);

-- Check the inserted record
SELECT *
FROM CATALOG
WHERE SID = 5 AND PID = 105;

SELECT * FROM SUPPLIER;
SELECT * FROM PART;
SELECT * FROM CATALOG;
SELECT * FROM MOST_EXPENSIVE_SUPPLIERS;