-- =============================================================
-- SQL Engineering Academy
-- Engine  : PostgreSQL 16
-- Module  : 08 — Data Modification (DML)
-- File    : 08_dml.sql
-- Author  : SQL Engineering Academy
-- Data    : Synthetic only — no real personal information
-- =============================================================

\c university

-- ----------------------------------------------------------------
-- SECTION 1: INSERT — Single row
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Amara', 'Diallo', 3.90, 1, '2024-09-01', TRUE);

-- Verify
SELECT * FROM students WHERE first_name = 'Amara' AND last_name = 'Diallo';

-- ----------------------------------------------------------------
-- SECTION 2: INSERT — Multiple rows
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES
    ('Priya',   'Sharma',    3.85, 2, '2024-09-01', TRUE),
    ('Carlos',  'Reyes',     3.70, 1, '2024-01-15', TRUE),
    ('Sofia',   'Chen',      3.95, 3, '2023-09-01', TRUE),
    ('Yuki',    'Tanaka',    3.60, 2, '2024-09-01', TRUE),
    ('Ibrahim', 'Al-Rashid', 3.75, 1, '2023-01-15', TRUE);

SELECT COUNT(*) AS total_students FROM students;

-- ----------------------------------------------------------------
-- SECTION 3: INSERT … SELECT
-- ----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS students_staging (
    student_id  INT,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    gpa         NUMERIC(3,2),
    copied_at   TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO students_staging (student_id, first_name, last_name, gpa)
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  gpa >= 3.80;

SELECT * FROM students_staging;

-- ----------------------------------------------------------------
-- SECTION 4: INSERT … RETURNING (PostgreSQL-specific)
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Yuki', 'Tanaka', 3.88, 2, NOW(), TRUE)
RETURNING student_id, first_name, gpa;
-- Returns the new row's auto-generated student_id immediately

-- ----------------------------------------------------------------
-- SECTION 5: UPDATE — Single row
-- ----------------------------------------------------------------

SELECT student_id, first_name, gpa FROM students WHERE student_id = 1;

UPDATE students
SET    gpa = 3.95
WHERE  student_id = 1;

SELECT student_id, first_name, gpa FROM students WHERE student_id = 1;

-- ----------------------------------------------------------------
-- SECTION 6: UPDATE — Multiple columns
-- ----------------------------------------------------------------

UPDATE students
SET    gpa       = 3.80,
       is_active = TRUE
WHERE  first_name = 'Ibrahim' AND last_name = 'Al-Rashid';

-- ----------------------------------------------------------------
-- SECTION 7: UPDATE — With expression
-- ----------------------------------------------------------------

UPDATE students
SET    gpa = LEAST(gpa + 0.05, 4.00)
WHERE  department_id = 1;

SELECT first_name, gpa FROM students WHERE department_id = 1;

-- ----------------------------------------------------------------
-- SECTION 8: UPDATE … FROM (PostgreSQL join syntax)
-- ----------------------------------------------------------------

UPDATE students s
SET    gpa = LEAST(s.gpa + 0.02, 4.00)
FROM   departments d
WHERE  d.department_id = s.department_id
  AND  d.department_name = 'Mathematics';

-- ----------------------------------------------------------------
-- SECTION 9: UPDATE … RETURNING
-- ----------------------------------------------------------------

UPDATE students
SET    gpa = 3.90
WHERE  student_id = 2
RETURNING student_id, first_name, gpa AS new_gpa;

-- ----------------------------------------------------------------
-- SECTION 10: DELETE — Single row
-- ----------------------------------------------------------------

SELECT * FROM students_staging WHERE student_id = 1;

DELETE FROM students_staging WHERE student_id = 1;

SELECT COUNT(*) FROM students_staging;

-- ----------------------------------------------------------------
-- SECTION 11: DELETE … RETURNING
-- ----------------------------------------------------------------

DELETE FROM students_staging
WHERE gpa < 3.85
RETURNING student_id, first_name, gpa;
-- Shows which rows were actually deleted

-- ----------------------------------------------------------------
-- SECTION 12: DELETE — With NOT EXISTS
-- ----------------------------------------------------------------

DELETE FROM students_staging
WHERE NOT EXISTS (
    SELECT 1 FROM students s
    WHERE  s.student_id = students_staging.student_id
      AND  s.is_active = TRUE
);

-- ----------------------------------------------------------------
-- SECTION 13: TRUNCATE
-- ----------------------------------------------------------------

TRUNCATE TABLE students_staging;

SELECT COUNT(*) AS remaining FROM students_staging;  -- expect 0

-- ----------------------------------------------------------------
-- SECTION 14: UPSERT — ON CONFLICT DO UPDATE (PostgreSQL)
-- ----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS course_stats (
    course_id        INT PRIMARY KEY,
    enrollment_count INT          DEFAULT 0,
    last_updated     TIMESTAMPTZ  DEFAULT NOW()
);

-- First run: inserts
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 1, NOW())
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = course_stats.enrollment_count + 1,
        last_updated     = NOW();

SELECT * FROM course_stats;

-- Second run: updates (course_id 101 exists)
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 1, NOW())
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = course_stats.enrollment_count + 1,
        last_updated     = NOW();

SELECT * FROM course_stats;  -- enrollment_count = 2

-- Using EXCLUDED to reference the attempted row
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (102, 5, NOW())
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = EXCLUDED.enrollment_count + course_stats.enrollment_count,
        last_updated     = EXCLUDED.last_updated;

-- ON CONFLICT DO NOTHING — ignore duplicates silently
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 99, NOW())
ON CONFLICT (course_id) DO NOTHING;

SELECT * FROM course_stats;  -- course 101 unchanged

-- ----------------------------------------------------------------
-- SECTION 15: Transactions — COMMIT
-- ----------------------------------------------------------------

BEGIN;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Test', 'Student', 3.50, 1, NOW(), TRUE);

UPDATE course_stats SET enrollment_count = enrollment_count + 1 WHERE course_id = 101;

COMMIT;

SELECT * FROM students WHERE first_name = 'Test';

-- ----------------------------------------------------------------
-- SECTION 16: Transactions — ROLLBACK
-- ----------------------------------------------------------------

BEGIN;

DELETE FROM students WHERE first_name = 'Test';

ROLLBACK;

SELECT * FROM students WHERE first_name = 'Test';  -- still there

-- ----------------------------------------------------------------
-- SECTION 17: SAVEPOINT
-- ----------------------------------------------------------------

BEGIN;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Save', 'Point', 3.00, 2, NOW(), TRUE);

SAVEPOINT after_insert;

UPDATE students SET gpa = 0.00 WHERE department_id = 2;  -- mistake

ROLLBACK TO SAVEPOINT after_insert;

COMMIT;

SELECT first_name, gpa FROM students WHERE first_name = 'Save';
-- gpa = 3.00 (the bad UPDATE was rolled back)

-- Clean up demo rows
DELETE FROM students WHERE first_name IN ('Test', 'Save');

-- ----------------------------------------------------------------
-- SECTION 18: Isolation level
-- ----------------------------------------------------------------

-- Current session level
SHOW TRANSACTION ISOLATION LEVEL;

-- Set for the current transaction
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- ... statements ...
COMMIT;
