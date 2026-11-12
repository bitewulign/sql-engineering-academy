-- =============================================================
-- SQL Engineering Academy
-- Engine  : MySQL 8.0
-- Module  : 08 — Data Modification (DML)
-- File    : 08_dml.sql
-- Author  : SQL Engineering Academy
-- Data    : Synthetic only — no real personal information
-- =============================================================

USE university;

-- ----------------------------------------------------------------
-- SECTION 1: INSERT — Single row
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Amara', 'Diallo', 3.90, 1, '2024-09-01', 1);

-- Verify
SELECT * FROM students WHERE first_name = 'Amara' AND last_name = 'Diallo';

-- ----------------------------------------------------------------
-- SECTION 2: INSERT — Multiple rows in one statement
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES
    ('Priya',   'Sharma',   3.85, 2, '2024-09-01', 1),
    ('Carlos',  'Reyes',    3.70, 1, '2024-01-15', 1),
    ('Sofia',   'Chen',     3.95, 3, '2023-09-01', 1),
    ('Yuki',    'Tanaka',   3.60, 2, '2024-09-01', 1),
    ('Ibrahim', 'Al-Rashid',3.75, 1, '2023-01-15', 1);

SELECT COUNT(*) AS total_students FROM students;

-- ----------------------------------------------------------------
-- SECTION 3: INSERT … SELECT — Populate from query
-- ----------------------------------------------------------------

-- Create a staging table first (run once)
CREATE TABLE IF NOT EXISTS students_staging (
    student_id  INT,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    gpa         DECIMAL(3,2),
    copied_at   DATETIME DEFAULT NOW()
);

-- Copy high-GPA students to staging
INSERT INTO students_staging (student_id, first_name, last_name, gpa)
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  gpa >= 3.80;

SELECT * FROM students_staging;

-- ----------------------------------------------------------------
-- SECTION 4: UPDATE — Single row by primary key
-- ----------------------------------------------------------------

-- Step 1: verify which row will change
SELECT student_id, first_name, gpa FROM students WHERE student_id = 1;

-- Step 2: apply the update
UPDATE students
SET    gpa = 3.95
WHERE  student_id = 1;

-- Step 3: confirm
SELECT student_id, first_name, gpa FROM students WHERE student_id = 1;

-- ----------------------------------------------------------------
-- SECTION 5: UPDATE — Multiple columns
-- ----------------------------------------------------------------

UPDATE students
SET    gpa       = 3.80,
       is_active = 1
WHERE  first_name = 'Ibrahim' AND last_name = 'Al-Rashid';

-- ----------------------------------------------------------------
-- SECTION 6: UPDATE — With expression
-- ----------------------------------------------------------------

-- Raise all CS department GPAs by 0.05 (capped at 4.00)
UPDATE students
SET    gpa = LEAST(gpa + 0.05, 4.00)
WHERE  department_id = 1;

SELECT first_name, gpa FROM students WHERE department_id = 1;

-- ----------------------------------------------------------------
-- SECTION 7: UPDATE — Multi-table (JOIN syntax, MySQL)
-- ----------------------------------------------------------------

UPDATE students s
JOIN   departments d ON d.department_id = s.department_id
SET    s.gpa = LEAST(s.gpa + 0.02, 4.00)
WHERE  d.department_name = 'Mathematics';

-- ----------------------------------------------------------------
-- SECTION 8: UPDATE — With subquery
-- ----------------------------------------------------------------

-- Flag students below their department average as needing support
UPDATE students s
SET    s.is_active = 1
WHERE  s.gpa < (
    SELECT AVG(s2.gpa)
    FROM   (SELECT department_id, AVG(gpa) AS avg_gpa
            FROM   students
            GROUP BY department_id) s2
    WHERE  s2.department_id = s.department_id
);

-- ----------------------------------------------------------------
-- SECTION 9: DELETE — Single row
-- ----------------------------------------------------------------

-- Step 1: verify
SELECT * FROM students_staging WHERE student_id = 1;

-- Step 2: delete
DELETE FROM students_staging WHERE student_id = 1;

-- Step 3: confirm
SELECT COUNT(*) FROM students_staging;

-- ----------------------------------------------------------------
-- SECTION 10: DELETE — With subquery (NOT EXISTS)
-- ----------------------------------------------------------------

-- Remove staged students who are no longer active in the main table
DELETE FROM students_staging
WHERE NOT EXISTS (
    SELECT 1 FROM students s
    WHERE  s.student_id = students_staging.student_id
      AND  s.is_active = 1
);

-- ----------------------------------------------------------------
-- SECTION 11: DELETE — Multi-table (MySQL JOIN syntax)
-- ----------------------------------------------------------------

-- Delete all staging rows for students in department 3
DELETE ss
FROM   students_staging ss
JOIN   students s ON s.student_id = ss.student_id
WHERE  s.department_id = 3;

-- ----------------------------------------------------------------
-- SECTION 12: TRUNCATE
-- ----------------------------------------------------------------

-- Remove ALL rows from staging (fast, no WHERE possible)
TRUNCATE TABLE students_staging;

SELECT COUNT(*) AS remaining FROM students_staging;  -- expect 0

-- ----------------------------------------------------------------
-- SECTION 13: UPSERT — ON DUPLICATE KEY UPDATE (MySQL)
-- ----------------------------------------------------------------

-- Create a stats table for the demo
CREATE TABLE IF NOT EXISTS course_stats (
    course_id        INT PRIMARY KEY,
    enrollment_count INT          DEFAULT 0,
    last_updated     DATETIME     DEFAULT NOW()
);

-- First run: inserts a new row
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 1, NOW())
ON DUPLICATE KEY UPDATE
    enrollment_count = enrollment_count + 1,
    last_updated     = NOW();

SELECT * FROM course_stats;

-- Second run: updates the existing row (course_id 101 already exists)
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 1, NOW())
ON DUPLICATE KEY UPDATE
    enrollment_count = enrollment_count + 1,
    last_updated     = NOW();

SELECT * FROM course_stats;  -- enrollment_count should now be 2

-- ----------------------------------------------------------------
-- SECTION 14: Transactions — COMMIT
-- ----------------------------------------------------------------

START TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Test', 'Student', 3.50, 1, NOW(), 1);

UPDATE course_stats SET enrollment_count = enrollment_count + 1 WHERE course_id = 101;

COMMIT;

SELECT * FROM students WHERE first_name = 'Test';

-- ----------------------------------------------------------------
-- SECTION 15: Transactions — ROLLBACK
-- ----------------------------------------------------------------

START TRANSACTION;

DELETE FROM students WHERE first_name = 'Test';

-- Oops — wrong decision; undo everything
ROLLBACK;

-- Test row is still there
SELECT * FROM students WHERE first_name = 'Test';

-- ----------------------------------------------------------------
-- SECTION 16: SAVEPOINT
-- ----------------------------------------------------------------

START TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Save', 'Point', 3.00, 2, NOW(), 1);

SAVEPOINT after_insert;

-- Accidentally update the wrong rows
UPDATE students SET gpa = 0.00 WHERE department_id = 2;

-- Undo only the bad UPDATE, keep the INSERT
ROLLBACK TO SAVEPOINT after_insert;

COMMIT;

SELECT first_name, gpa FROM students WHERE first_name = 'Save';
-- Should show Save Point with gpa = 3.00

-- Clean up demo row
DELETE FROM students WHERE first_name IN ('Test', 'Save');

-- ----------------------------------------------------------------
-- SECTION 17: Isolation level
-- ----------------------------------------------------------------

-- View current session isolation level
SELECT @@transaction_isolation;

-- Change for this session
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Restore default
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
