-- =============================================================
-- SQL Engineering Academy
-- Engine  : SQL Server 2022
-- Module  : 08 — Data Modification (DML)
-- File    : 08_dml.sql
-- Author  : SQL Engineering Academy
-- Data    : Synthetic only — no real personal information
-- =============================================================

USE university;
GO

-- ----------------------------------------------------------------
-- SECTION 1: INSERT — Single row
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES (N'Amara', N'Diallo', 3.90, 1, '2024-09-01', 1);

-- Verify
SELECT * FROM students WHERE first_name = N'Amara' AND last_name = N'Diallo';
GO

-- ----------------------------------------------------------------
-- SECTION 2: INSERT — Multiple rows
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES
    (N'Priya',   N'Sharma',    3.85, 2, '2024-09-01', 1),
    (N'Carlos',  N'Reyes',     3.70, 1, '2024-01-15', 1),
    (N'Sofia',   N'Chen',      3.95, 3, '2023-09-01', 1),
    (N'Yuki',    N'Tanaka',    3.60, 2, '2024-09-01', 1),
    (N'Ibrahim', N'Al-Rashid', 3.75, 1, '2023-01-15', 1);

SELECT COUNT(*) AS total_students FROM students;
GO

-- ----------------------------------------------------------------
-- SECTION 3: INSERT … SELECT
-- ----------------------------------------------------------------

IF OBJECT_ID('students_staging', 'U') IS NULL
BEGIN
    CREATE TABLE students_staging (
        student_id  INT,
        first_name  NVARCHAR(100),
        last_name   NVARCHAR(100),
        gpa         DECIMAL(3,2),
        copied_at   DATETIME2 DEFAULT GETDATE()
    );
END;
GO

INSERT INTO students_staging (student_id, first_name, last_name, gpa)
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  gpa >= 3.80;

SELECT * FROM students_staging;
GO

-- ----------------------------------------------------------------
-- SECTION 4: INSERT … OUTPUT (SQL Server — returns inserted rows)
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
OUTPUT INSERTED.student_id, INSERTED.first_name, INSERTED.gpa
VALUES (N'Yuki', N'Tanaka', 3.88, 2, GETDATE(), 1);
GO

-- ----------------------------------------------------------------
-- SECTION 5: UPDATE — Single row
-- ----------------------------------------------------------------

SELECT student_id, first_name, gpa FROM students WHERE student_id = 1;

UPDATE students
SET    gpa = 3.95
WHERE  student_id = 1;

SELECT student_id, first_name, gpa FROM students WHERE student_id = 1;
GO

-- ----------------------------------------------------------------
-- SECTION 6: UPDATE — Multiple columns
-- ----------------------------------------------------------------

UPDATE students
SET    gpa       = 3.80,
       is_active = 1
WHERE  first_name = N'Ibrahim' AND last_name = N'Al-Rashid';
GO

-- ----------------------------------------------------------------
-- SECTION 7: UPDATE — With expression
-- ----------------------------------------------------------------

UPDATE students
SET    gpa = CASE WHEN gpa + 0.05 > 4.00 THEN 4.00 ELSE gpa + 0.05 END
WHERE  department_id = 1;

SELECT first_name, gpa FROM students WHERE department_id = 1;
GO

-- ----------------------------------------------------------------
-- SECTION 8: UPDATE … FROM (SQL Server join syntax)
-- ----------------------------------------------------------------

UPDATE s
SET    s.gpa = CASE WHEN s.gpa + 0.02 > 4.00 THEN 4.00 ELSE s.gpa + 0.02 END
FROM   students s
JOIN   departments d ON d.department_id = s.department_id
WHERE  d.department_name = N'Mathematics';
GO

-- ----------------------------------------------------------------
-- SECTION 9: UPDATE … OUTPUT
-- ----------------------------------------------------------------

UPDATE students
SET    gpa = 3.90
OUTPUT DELETED.gpa AS old_gpa, INSERTED.gpa AS new_gpa, INSERTED.first_name
WHERE  student_id = 2;
GO

-- ----------------------------------------------------------------
-- SECTION 10: DELETE — Single row
-- ----------------------------------------------------------------

SELECT * FROM students_staging WHERE student_id = 1;

DELETE FROM students_staging WHERE student_id = 1;

SELECT COUNT(*) FROM students_staging;
GO

-- ----------------------------------------------------------------
-- SECTION 11: DELETE … OUTPUT
-- ----------------------------------------------------------------

DELETE FROM students_staging
OUTPUT DELETED.student_id, DELETED.first_name, DELETED.gpa
WHERE gpa < 3.85;
GO

-- ----------------------------------------------------------------
-- SECTION 12: DELETE — With NOT EXISTS
-- ----------------------------------------------------------------

DELETE FROM students_staging
WHERE NOT EXISTS (
    SELECT 1 FROM students s
    WHERE  s.student_id = students_staging.student_id
      AND  s.is_active = 1
);
GO

-- ----------------------------------------------------------------
-- SECTION 13: TRUNCATE
-- ----------------------------------------------------------------

TRUNCATE TABLE students_staging;

SELECT COUNT(*) AS remaining FROM students_staging;  -- expect 0
GO

-- ----------------------------------------------------------------
-- SECTION 14: MERGE — UPSERT (SQL Server)
-- ----------------------------------------------------------------

IF OBJECT_ID('course_stats', 'U') IS NULL
BEGIN
    CREATE TABLE course_stats (
        course_id        INT PRIMARY KEY,
        enrollment_count INT       DEFAULT 0,
        last_updated     DATETIME2 DEFAULT GETDATE()
    );
END;
GO

-- MERGE: insert if new, update if exists
MERGE INTO course_stats AS target
USING (VALUES (101, 1)) AS source(course_id, increment)
    ON target.course_id = source.course_id
WHEN MATCHED THEN
    UPDATE SET
        enrollment_count = target.enrollment_count + source.increment,
        last_updated     = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (course_id, enrollment_count, last_updated)
    VALUES (source.course_id, source.increment, GETDATE());

SELECT * FROM course_stats;
GO

-- Run again — should UPDATE this time
MERGE INTO course_stats AS target
USING (VALUES (101, 1)) AS source(course_id, increment)
    ON target.course_id = source.course_id
WHEN MATCHED THEN
    UPDATE SET
        enrollment_count = target.enrollment_count + source.increment,
        last_updated     = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (course_id, enrollment_count, last_updated)
    VALUES (source.course_id, source.increment, GETDATE());

SELECT * FROM course_stats;  -- enrollment_count = 2
GO

-- MERGE with OUTPUT to track what happened
MERGE INTO course_stats AS target
USING (VALUES (102, 5), (101, 1)) AS source(course_id, increment)
    ON target.course_id = source.course_id
WHEN MATCHED THEN
    UPDATE SET
        enrollment_count = target.enrollment_count + source.increment,
        last_updated     = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (course_id, enrollment_count, last_updated)
    VALUES (source.course_id, source.increment, GETDATE())
OUTPUT $action AS merge_action, INSERTED.course_id, INSERTED.enrollment_count;
GO

-- ----------------------------------------------------------------
-- SECTION 15: Transactions — COMMIT
-- ----------------------------------------------------------------

BEGIN TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES (N'Test', N'Student', 3.50, 1, GETDATE(), 1);

UPDATE course_stats SET enrollment_count = enrollment_count + 1 WHERE course_id = 101;

COMMIT TRANSACTION;

SELECT * FROM students WHERE first_name = N'Test';
GO

-- ----------------------------------------------------------------
-- SECTION 16: Transactions — ROLLBACK
-- ----------------------------------------------------------------

BEGIN TRANSACTION;

DELETE FROM students WHERE first_name = N'Test';

ROLLBACK TRANSACTION;

SELECT * FROM students WHERE first_name = N'Test';  -- still there
GO

-- ----------------------------------------------------------------
-- SECTION 17: SAVE TRANSACTION (SQL Server savepoint)
-- ----------------------------------------------------------------

BEGIN TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES (N'Save', N'Point', 3.00, 2, GETDATE(), 1);

SAVE TRANSACTION after_insert;

UPDATE students SET gpa = 0.00 WHERE department_id = 2;  -- mistake

ROLLBACK TRANSACTION after_insert;  -- undo only the bad UPDATE

COMMIT TRANSACTION;

SELECT first_name, gpa FROM students WHERE first_name = N'Save';
-- gpa = 3.00

-- Clean up demo rows
DELETE FROM students WHERE first_name IN (N'Test', N'Save');
GO

-- ----------------------------------------------------------------
-- SECTION 18: Isolation level
-- ----------------------------------------------------------------

-- View current level (session level)
SELECT CASE transaction_isolation_level
    WHEN 1 THEN 'READ UNCOMMITTED'
    WHEN 2 THEN 'READ COMMITTED'
    WHEN 3 THEN 'REPEATABLE READ'
    WHEN 4 THEN 'SERIALIZABLE'
    WHEN 5 THEN 'SNAPSHOT'
    ELSE 'UNKNOWN'
END AS isolation_level
FROM sys.dm_exec_sessions
WHERE session_id = @@SPID;
GO

-- Set isolation level for current session
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;
-- ... statements here ...
COMMIT TRANSACTION;

-- Restore default
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
