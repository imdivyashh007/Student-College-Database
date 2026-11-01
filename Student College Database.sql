-- Student–College Database
-- MySQL 8.0+
-- Based on the supplied ER diagram and relational model.

CREATE DATABASE IF NOT EXISTS student_college_db;
USE student_college_db;

-- Drop child tables before parent tables so this script can be rerun.
DROP TABLE IF EXISTS COLLEGE_BRANCH;
DROP TABLE IF EXISTS STUDENT;
DROP TABLE IF EXISTS COLLEGE;

CREATE TABLE COLLEGE (
    College_ID   VARCHAR(10) PRIMARY KEY,
    Name         VARCHAR(100) NOT NULL,
    Affiliation  VARCHAR(100),
    Address      VARCHAR(150),
    AICTE_Code   VARCHAR(30) UNIQUE
);

CREATE TABLE STUDENT (
    Student_ID      VARCHAR(10) PRIMARY KEY,
    Name            VARCHAR(100) NOT NULL,
    DOB             DATE NOT NULL,
    Gender          VARCHAR(20),
    Address         VARCHAR(150),
    Contact_No      VARCHAR(15),
    Father_Name     VARCHAR(100),
    College_ID      VARCHAR(10) NOT NULL,
    Enrollment_Date DATE NOT NULL,
    CONSTRAINT fk_student_college
        FOREIGN KEY (College_ID) REFERENCES COLLEGE(College_ID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- One row per branch offered by a college.
-- Composite primary key prevents duplicate branches for the same college.
CREATE TABLE COLLEGE_BRANCH (
    College_ID VARCHAR(10) NOT NULL,
    Branch     VARCHAR(30) NOT NULL,
    PRIMARY KEY (College_ID, Branch),
    CONSTRAINT fk_branch_college
        FOREIGN KEY (College_ID) REFERENCES COLLEGE(College_ID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Dummy college records
INSERT INTO COLLEGE (College_ID, Name, Affiliation, Address, AICTE_Code) VALUES
('C01', 'Green Valley College', 'AICTE', 'Delhi', 'A123'),
('C02', 'Sunrise Institute',    'AICTE', 'Jaipur', 'A456');

-- Dummy student records
INSERT INTO STUDENT
(Student_ID, Name, DOB, Gender, Address, Contact_No, Father_Name, College_ID, Enrollment_Date)
VALUES
('S101', 'Aarav Sharma', '2007-05-15', 'Male',   'Delhi',  '9876501234', 'Rajesh Sharma', 'C01', '2026-08-01'),
('S102', 'Priya Verma',  '2007-02-10', 'Female', 'Noida',  '9876502345', 'Suresh Verma',  'C01', '2026-08-02'),
('S103', 'Rohan Mehta',  '2006-11-20', 'Male',   'Jaipur', '9876503456', 'Amit Mehta',    'C02', '2026-08-05');

-- Branches offered by each college (kept consistent across the database)
INSERT INTO COLLEGE_BRANCH (College_ID, Branch) VALUES
('C01', 'CSE'),
('C01', 'ECE'),
('C01', 'AI-ML'),
('C02', 'ECE');

-- Useful example queries

-- 1. List students with their college details.
SELECT
    s.Student_ID,
    s.Name AS Student_Name,
    s.DOB,
    s.Gender,
    c.Name AS College_Name,
    s.Enrollment_Date
FROM STUDENT AS s
JOIN COLLEGE AS c ON c.College_ID = s.College_ID;

-- 2. List branches offered by each college.
SELECT
    c.College_ID,
    c.Name AS College_Name,
    cb.Branch
FROM COLLEGE AS c
JOIN COLLEGE_BRANCH AS cb ON cb.College_ID = c.College_ID
ORDER BY c.College_ID, cb.Branch;

-- 3. Count students enrolled in each college.
SELECT
    c.College_ID,
    c.Name AS College_Name,
    COUNT(s.Student_ID) AS Student_Count
FROM COLLEGE AS c
LEFT JOIN STUDENT AS s ON s.College_ID = c.College_ID
GROUP BY c.College_ID, c.Name;

-- Note: Age is derived from DOB and is intentionally not stored.
-- To calculate age in MySQL:
-- SELECT Student_ID, Name, TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS Age
-- FROM STUDENT;
