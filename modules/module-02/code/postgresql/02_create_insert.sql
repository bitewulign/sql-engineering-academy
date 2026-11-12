-- ============================================================
-- SQL Engineering Academy
-- Engine:  PostgreSQL 16
-- Module:  02 — Creating Tables and Inserting Data
-- File:    02_create_insert.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Run in pgAdmin 4 or psql.
-- Connect to: localhost:5432  User: postgres
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: Create and connect to the academy database
-- ────────────────────────────────────────────────────────────

-- Run this command while connected to the 'postgres' default database:
CREATE DATABASE academy;

-- After creation, connect:
--   psql:    \c academy
--   pgAdmin: select 'academy' in the object tree → open Query Tool

-- For the rest of this script, we assume you are connected to 'academy'.

-- PostgreSQL has no USE statement.
-- Verify the current database:
SELECT current_database() AS connected_to;


-- ────────────────────────────────────────────────────────────
-- SECTION 2: Data types demonstration
-- ────────────────────────────────────────────────────────────

-- Integer types
SELECT
    32767::SMALLINT      AS smallint_max_demo,
    2147483647::INT      AS int_max_demo,
    9223372036854775807::BIGINT AS bigint_max_demo;

-- Decimal vs float
SELECT
    (0.1 + 0.2)::NUMERIC(10,2)  AS numeric_sum,   -- 0.30 (exact)
    0.1::FLOAT + 0.2::FLOAT     AS float_sum;      -- 0.30000000000000004 (approximate)

-- PostgreSQL TEXT type (no length limit — same storage as VARCHAR)
SELECT
    'Hello'::VARCHAR(50)   AS varchar_example,
    'Hello'::TEXT          AS text_example,
    LENGTH('Hello')        AS length_check;

-- Boolean in PostgreSQL (true native type)
SELECT
    TRUE  AS pg_true,
    FALSE AS pg_false,
    TRUE::INT AS true_as_int,  -- 1
    'yes'::BOOLEAN AS yes_bool,
    'no'::BOOLEAN  AS no_bool;


-- ────────────────────────────────────────────────────────────
-- SECTION 3: CREATE TABLE — students
-- Using GENERATED ALWAYS AS IDENTITY (SQL standard, recommended)
-- ────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id   INT             GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name   VARCHAR(50)     NOT NULL,
    last_name    VARCHAR(50)     NOT NULL,
    email        VARCHAR(100)    NOT NULL,
    phone        VARCHAR(20),
    gpa          NUMERIC(3,2),
    enrolled_at  DATE            NOT NULL,
    is_active    BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_students_email  UNIQUE (email),
    CONSTRAINT chk_students_gpa   CHECK (gpa BETWEEN 0.00 AND 4.00)
);

-- Alternative: SERIAL (classic PostgreSQL style)
-- student_id  SERIAL  PRIMARY KEY
-- Both work; GENERATED ALWAYS AS IDENTITY is preferred in new code.

-- View the table structure
\d students    -- psql only; skip in pgAdmin

-- Or use information_schema (works everywhere)
SELECT column_name, data_type, is_nullable, column_default
FROM   information_schema.columns
WHERE  table_name = 'students'
ORDER  BY ordinal_position;


-- ────────────────────────────────────────────────────────────
-- SECTION 4: CREATE TABLE — courses and enrollments
-- ────────────────────────────────────────────────────────────

CREATE TABLE courses (
    course_id    INT             GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code  VARCHAR(10)     NOT NULL,
    course_name  VARCHAR(100)    NOT NULL,
    credits      SMALLINT        NOT NULL DEFAULT 3,
    max_students SMALLINT        NOT NULL DEFAULT 30,

    CONSTRAINT uq_courses_code    UNIQUE (course_code),
    CONSTRAINT chk_credits        CHECK (credits BETWEEN 1 AND 6),
    CONSTRAINT chk_max_students   CHECK (max_students > 0)
);

CREATE TABLE enrollments (
    enrollment_id  INT       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id     INT       NOT NULL,
    course_id      INT       NOT NULL,
    enrolled_on    DATE      NOT NULL,
    grade          NUMERIC(4,1),

    CONSTRAINT uq_enrollment     UNIQUE (student_id, course_id),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_course  FOREIGN KEY (course_id)
        REFERENCES courses (course_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- ────────────────────────────────────────────────────────────
-- SECTION 5: INSERT — with RETURNING (PostgreSQL superpower)
-- ────────────────────────────────────────────────────────────

-- 5.1  Single row insert — RETURNING gives back the new ID atomically
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES ('Amara', 'Osei', 'amara.osei@example.com', 3.80, '2024-09-01')
RETURNING student_id;

-- 5.2  Multi-row insert with RETURNING
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES
    ('Priya',   'Sharma',   'priya.sharma@example.com',   3.50, '2024-09-01'),
    ('Carlos',  'Mendez',   'carlos.mendez@example.com',  3.90, '2024-01-15'),
    ('Sofia',   'Eriksson', 'sofia.eriksson@example.com', 3.70, '2023-09-01'),
    ('Yuki',    'Tanaka',   'yuki.tanaka@example.com',    3.60, '2024-09-01'),
    ('Ibrahim', 'Al-Farsi', 'ibrahim.alfarsi@example.com',3.85, '2023-01-10')
RETURNING student_id, first_name, last_name;

-- Verify
SELECT * FROM students ORDER BY student_id;

-- 5.3  Insert courses
INSERT INTO courses (course_code, course_name, credits)
VALUES
    ('SQL101', 'Introduction to SQL',   3),
    ('SQL201', 'Intermediate SQL',      3),
    ('DB301',  'Database Design',       4),
    ('PY101',  'Python for Data',       3)
RETURNING course_id, course_code;

-- 5.4  Insert enrollments
INSERT INTO enrollments (student_id, course_id, enrolled_on, grade)
VALUES
    (1, 1, '2024-09-05', 92.5),
    (1, 2, '2024-09-05', NULL),
    (2, 1, '2024-09-05', 88.0),
    (3, 3, '2024-01-20', 95.0),
    (4, 1, '2024-09-05', 79.5);


-- ────────────────────────────────────────────────────────────
-- SECTION 6: UPDATE — with RETURNING
-- ────────────────────────────────────────────────────────────

-- 6.1  Update GPA
UPDATE students
SET    gpa = 3.95
WHERE  student_id = 1
RETURNING student_id, first_name, gpa;    -- shows the new value immediately

-- 6.2  Update multiple columns
UPDATE students
SET    phone     = '416-555-0101',
       is_active = TRUE
WHERE  student_id = 2;

-- 6.3  Verify
SELECT student_id, first_name, gpa, phone, is_active
FROM   students
ORDER BY student_id;


-- ────────────────────────────────────────────────────────────
-- SECTION 7: DELETE — with RETURNING
-- ────────────────────────────────────────────────────────────

-- 7.1  Insert a throwaway row
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Test', 'Delete', 'test.delete@example.com', CURRENT_DATE)
RETURNING student_id;

-- 7.2  Delete it and confirm which row was removed
DELETE FROM students
WHERE  email = 'test.delete@example.com'
RETURNING student_id, first_name, last_name;    -- PostgreSQL: RETURNING on DELETE

-- 7.3  Count check
SELECT COUNT(*) AS student_count FROM students;


-- ────────────────────────────────────────────────────────────
-- SECTION 8: TRUNCATE
-- ────────────────────────────────────────────────────────────

-- Demo with a temporary table
CREATE TEMP TABLE demo_truncate (
    id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    val  TEXT
);

INSERT INTO demo_truncate (val) VALUES ('a'), ('b'), ('c');
SELECT * FROM demo_truncate;         -- ids 1, 2, 3

TRUNCATE TABLE demo_truncate RESTART IDENTITY;
-- RESTART IDENTITY resets the sequence counter
-- Without it, the sequence continues from where it was

INSERT INTO demo_truncate (val) VALUES ('x');
SELECT * FROM demo_truncate;         -- id = 1 again

DROP TABLE demo_truncate;


-- ────────────────────────────────────────────────────────────
-- SECTION 9: ALTER TABLE
-- ────────────────────────────────────────────────────────────

-- 9.1  Add a column
ALTER TABLE students ADD COLUMN bio TEXT;

-- 9.2  Add a column with default
ALTER TABLE students ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();

-- 9.3  Change a column type
ALTER TABLE students ALTER COLUMN phone TYPE VARCHAR(30);

-- 9.4  Rename a column
ALTER TABLE students RENAME COLUMN bio TO notes;

-- 9.5  Set a default on an existing column
ALTER TABLE students ALTER COLUMN notes SET DEFAULT '';

-- 9.6  Drop a column
ALTER TABLE students DROP COLUMN notes;

-- Verify
SELECT column_name, data_type
FROM   information_schema.columns
WHERE  table_name = 'students'
ORDER  BY ordinal_position;


-- ────────────────────────────────────────────────────────────
-- SECTION 10: Sequences (the mechanism behind SERIAL/IDENTITY)
-- ────────────────────────────────────────────────────────────

-- PostgreSQL sequences are first-class objects
-- See the sequence created for students.student_id:
SELECT sequencename, last_value, increment_by, min_value, max_value
FROM   pg_sequences
WHERE  schemaname = 'public';

-- Peek at the next value without consuming it:
SELECT currval(pg_get_serial_sequence('students', 'student_id'));


-- ────────────────────────────────────────────────────────────
-- SECTION 11: Cleanup
-- ────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- ============================================================
-- END OF MODULE 02 — POSTGRESQL
-- Key PostgreSQL-specific points:
--   - GENERATED ALWAYS AS IDENTITY (or SERIAL) for auto-increment
--   - RETURNING clause on INSERT/UPDATE/DELETE — extremely useful
--   - TIMESTAMPTZ (timestamp with time zone) is preferred over TIMESTAMP
--   - TEXT type has no length limit and same performance as VARCHAR
--   - TRUNCATE ... RESTART IDENTITY to reset sequence
--   - Sequences are independent objects (pg_sequences catalog)
-- ============================================================
