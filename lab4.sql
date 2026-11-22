CREATE DATABASE IF NOT EXISTS SUPPLIER_LAB7;
USE SUPPLIER_LAB7;

DROP TABLE IF EXISTS CATALOG;
DROP TABLE IF EXISTS PART;
DROP TABLE IF EXISTS SUPPLIER;

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
    COST DECIMAL(10,2),
    PRIMARY KEY (SID, PID),
    FOREIGN KEY (SID) REFERENCES SUPPLIER(SID),
    FOREIGN KEY (PID) REFERENCES PART(PID)
);

INSERT INTO SUPPLIER VALUES
(1,'Supplier A','Bangalore'),
(2,'Supplier B','Mumbai'),
(3,'Supplier C','Delhi'),
(4,'Supplier D','Chennai'),
(5,'Supplier E','Hyderabad');

INSERT INTO PART VALUES
(101,'Bolt','Red'),
(102,'Nut','Blue'),
(103,'Screw','Green'),
(104,'Gear','Red'),
(105,'Washer','Black'),
(106,'Bearing','Yellow');

INSERT INTO CATALOG VALUES
(1,101,15),
(1,102,25),
(1,103,18),
(2,101,12),
(2,104,45),
(2,105,8),
(3,102,17),
(3,103,22),
(3,106,55),
(4,101,20),
(4,104,60),
(4,106,48),
(5,102,19),
(5,105,10),
(5,106,50);

CREATE DATABASE IF NOT EXISTS SUPPLIER_LAB8;
USE SUPPLIER_LAB8;

DROP VIEW IF EXISTS MOST_EXPENSIVE_SUPPLIER;
DROP TRIGGER IF EXISTS CHECK_CATALOG_COST;
DROP TRIGGER IF EXISTS DEFAULT_CATALOG_COST;

DROP TABLE IF EXISTS CATALOG;
DROP TABLE IF EXISTS PART;
DROP TABLE IF EXISTS SUPPLIER;

-- =========================================
-- TABLE CREATION
-- =========================================

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
    COST DECIMAL(10,2) DEFAULT 10.00,
    PRIMARY KEY (SID, PID),
    FOREIGN KEY (SID) REFERENCES SUPPLIER(SID),
    FOREIGN KEY (PID) REFERENCES PART(PID)
);

-- =========================================
-- INSERT DATA
-- =========================================

INSERT INTO SUPPLIER VALUES
(1,'Supplier A','Bangalore'),
(2,'Supplier B','Mumbai'),
(3,'Supplier C','Delhi'),
(4,'Supplier D','Chennai'),
(5,'Supplier E','Hyderabad');

INSERT INTO PART VALUES
(101,'Bolt','Red'),
(102,'Nut','Blue'),
(103,'Screw','Green'),
(104,'Gear','Red'),
(105,'Washer','Black'),
(106,'Bearing','Yellow');

INSERT INTO CATALOG VALUES
(1,101,15),
(1,102,25),
(1,103,18),
(2,101,12),
(2,104,45),
(2,105,8),
(3,102,17),
(3,103,22),
(3,106,55),
(4,101,20),
(4,104,60),
(4,106,48),
(5,102,19),
(5,105,10),
(5,106,50);

-- =========================================
-- QUERY 1
-- MOST EXPENSIVE PART OVERALL AND SUPPLIER
-- =========================================

SELECT P.PID, P.PNAME, P.COLOR,
       S.SID, S.SNAME, C.COST
FROM PART P
JOIN CATALOG C ON P.PID = C.PID
JOIN SUPPLIER S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MAX(COST)
    FROM CATALOG
);

-- =========================================
-- QUERY 2
-- SUPPLIERS WHO DO NOT SUPPLY ANY RED PART
-- =========================================

SELECT S.SID, S.SNAME
FROM SUPPLIER S
WHERE NOT EXISTS (
    SELECT 1
    FROM CATALOG C
    JOIN PART P ON C.PID = P.PID
    WHERE C.SID = S.SID
      AND P.COLOR = 'Red'
);

-- =========================================
-- QUERY 3
-- EACH SUPPLIER AND TOTAL VALUE OF PARTS
-- =========================================

SELECT S.SID, S.SNAME, SUM(C.COST) AS TOTAL_VALUE
FROM SUPPLIER S
JOIN CATALOG C ON S.SID = C.SID
GROUP BY S.SID, S.SNAME;

-- =========================================
-- QUERY 4
-- SUPPLIERS WHO SUPPLY AT LEAST 2 PARTS
-- CHEAPER THAN ₹20
-- =========================================

SELECT S.SID, S.SNAME, COUNT(DISTINCT C.PID) AS PART_COUNT
FROM SUPPLIER S
JOIN CATALOG C ON S.SID = C.SID
WHERE C.COST < 20
GROUP BY S.SID, S.SNAME
HAVING COUNT(DISTINCT C.PID) >= 2;

-- =========================================
-- QUERY 5
-- CHEAPEST SUPPLIER FOR EACH PART
-- =========================================

SELECT P.PID, P.PNAME, S.SID, S.SNAME, C.COST
FROM PART P
JOIN CATALOG C ON P.PID = C.PID
JOIN SUPPLIER S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MIN(C2.COST)
    FROM CATALOG C2
    WHERE C2.PID = P.PID
);

-- =========================================
-- QUERY 6
-- VIEW OF MOST EXPENSIVE SUPPLIER FOR EACH PART
-- =========================================

CREATE VIEW MOST_EXPENSIVE_SUPPLIER AS
SELECT P.PID, P.PNAME, S.SID, S.SNAME, C.COST
FROM PART P
JOIN CATALOG C ON P.PID = C.PID
JOIN SUPPLIER S ON C.SID = S.SID
WHERE C.COST = (
    SELECT MAX(C2.COST)
    FROM CATALOG C2
    WHERE C2.PID = P.PID
);

-- DISPLAY VIEW
SELECT * FROM MOST_EXPENSIVE_SUPPLIER;

-- =========================================
-- QUERY 7
-- TRIGGER TO PREVENT COST BELOW 1
-- =========================================

DELIMITER //

CREATE TRIGGER CHECK_CATALOG_COST
BEFORE INSERT ON CATALOG
FOR EACH ROW
BEGIN
    IF NEW.COST < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cost cannot be less than 1';
    END IF;
END//

DELIMITER ;

-- =========================================
-- QUERY 8
-- TRIGGER TO SET DEFAULT COST IF NOT PROVIDED
-- =========================================

DELIMITER //

CREATE TRIGGER DEFAULT_CATALOG_COST
BEFORE INSERT ON CATALOG
FOR EACH ROW
BEGIN
    IF NEW.COST IS NULL THEN
        SET NEW.COST = 10.00;
    END IF;
END//

DELIMITER ;

-- =========================================
-- TEST THE DEFAULT COST TRIGGER
-- =========================================

INSERT INTO CATALOG (SID, PID, COST)
VALUES (5,101,NULL);

-- Check inserted record
SELECT *
FROM CATALOG
WHERE SID = 5 AND PID = 101;

-- =========================================
-- TEST THE COST VALIDATION TRIGGER
-- =========================================

-- Uncomment this to test.
-- It should return an error.

-- INSERT INTO CATALOG VALUES (5,103,0.50);