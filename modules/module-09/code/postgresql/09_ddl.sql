-- =============================================================
-- Module 09 — Schema Design & DDL
-- Platform: PostgreSQL 16
-- Database: university
-- Data: Synthetic only. No real personal information.
-- =============================================================

\c university

-- =============================================================
-- Section 1: Review the existing schema
-- =============================================================

-- List all tables in the public schema
SELECT table_name
FROM   information_schema.tables
WHERE  table_schema = 'public'
ORDER BY table_name;

-- Describe a table's columns
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM   information_schema.columns
WHERE  table_schema = 'public'
  AND  table_name   = 'students'
ORDER BY ordinal_position;

-- psql shortcut (interactive only):
-- \d students
-- \d+ students   -- with extra detail

-- =============================================================
-- Section 2: CREATE TABLE — PostgreSQL-native types
-- =============================================================

DROP TABLE IF EXISTS dept_demo CASCADE;

CREATE TABLE dept_demo (
    department_id   SERIAL          PRIMARY KEY,
    department_name VARCHAR(100)    NOT NULL UNIQUE,
    building        VARCHAR(50),
    budget          NUMERIC(12, 2)  DEFAULT 0.00,
    created_at      TIMESTAMPTZ     DEFAULT NOW()
);

-- Modern alternative to SERIAL (PostgreSQL 10+)
-- SERIAL is shorthand; GENERATED ALWAYS AS IDENTITY is the SQL standard:
DROP TABLE IF EXISTS dept_identity CASCADE;

CREATE TABLE dept_identity (
    department_id   INT             GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(100)    NOT NULL UNIQUE,
    building        VARCHAR(50),
    budget          NUMERIC(12, 2)  DEFAULT 0.00,
    created_at      TIMESTAMPTZ     DEFAULT NOW()
);

-- =============================================================
-- Section 3: CREATE TABLE — students with full constraints
-- =============================================================

DROP TABLE IF EXISTS students_demo CASCADE;

CREATE TABLE students_demo (
    student_id    SERIAL           PRIMARY KEY,
    first_name    VARCHAR(100)     NOT NULL,
    last_name     VARCHAR(100)     NOT NULL,
    email         VARCHAR(200)     NOT NULL UNIQUE,
    gpa           NUMERIC(3, 2)    NOT NULL DEFAULT 0.00,
    department_id INT              NOT NULL,
    enrolled_at   DATE             NOT NULL DEFAULT CURRENT_DATE,
    is_active     BOOLEAN          NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_gpa     CHECK (gpa BETWEEN 0.00 AND 4.00),
    CONSTRAINT chk_email   CHECK (email LIKE '%@%.%'),
    CONSTRAINT fk_std_dept FOREIGN KEY (department_id)
        REFERENCES dept_demo(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- =============================================================
-- Section 4: Composite PRIMARY KEY — enrollments
-- =============================================================

DROP TABLE IF EXISTS courses_demo CASCADE;
DROP TABLE IF EXISTS enrollments_demo CASCADE;

CREATE TABLE courses_demo (
    course_id   SERIAL          PRIMARY KEY,
    course_name VARCHAR(150)    NOT NULL,
    credits     SMALLINT        NOT NULL DEFAULT 3,
    CONSTRAINT chk_credits CHECK (credits BETWEEN 1 AND 6)
);

CREATE TABLE enrollments_demo (
    student_id  INT             NOT NULL,
    course_id   INT             NOT NULL,
    grade       NUMERIC(4, 2),
    enrolled_on DATE            NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enr_student FOREIGN KEY (student_id)
        REFERENCES students_demo(student_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_enr_course  FOREIGN KEY (course_id)
        REFERENCES courses_demo(course_id)
        ON DELETE RESTRICT
);

-- =============================================================
-- Section 5: INSERT … RETURNING — get generated PK immediately
-- =============================================================

INSERT INTO dept_demo (department_name, building, budget)
VALUES ('Computer Science', 'Tech Hall', 500000.00)
RETURNING department_id, department_name;

INSERT INTO dept_demo (department_name, building)
VALUES
    ('Mathematics', 'Science Block'),
    ('Physics',     'Science Block')
RETURNING department_id, department_name;

SELECT * FROM dept_demo;

-- =============================================================
-- Section 6: Indexes
-- =============================================================

-- Simple index on FK column
CREATE INDEX idx_students_dept
    ON students_demo(department_id);

-- Composite index
CREATE INDEX idx_students_dept_gpa
    ON students_demo(department_id, gpa DESC);

-- Partial index — only index active students
CREATE INDEX idx_active_students
    ON students_demo(department_id)
    WHERE is_active = TRUE;

-- Covering index — include columns to avoid table lookup
CREATE INDEX idx_cov_dept_name
    ON students_demo(department_id)
    INCLUDE (first_name, last_name, gpa);

-- Unique index
CREATE UNIQUE INDEX uq_std_email
    ON students_demo(email);  -- fails: UNIQUE already on email column

-- Check all indexes
SELECT
    indexname,
    indexdef
FROM   pg_indexes
WHERE  schemaname = 'public'
  AND  tablename  = 'students_demo'
ORDER BY indexname;

-- =============================================================
-- Section 7: ALTER TABLE — add, rename, drop column
-- =============================================================

-- Add a column
ALTER TABLE students_demo
    ADD COLUMN phone VARCHAR(20);

-- Set a default
ALTER TABLE students_demo
    ALTER COLUMN phone SET DEFAULT 'unknown';

-- Rename a column
ALTER TABLE students_demo
    RENAME COLUMN phone TO contact_phone;

-- Drop the column
ALTER TABLE students_demo
    DROP COLUMN contact_phone;

-- Change data type (safe widening)
ALTER TABLE students_demo
    ALTER COLUMN gpa TYPE NUMERIC(4, 2);

-- =============================================================
-- Section 8: ALTER TABLE — constraints
-- =============================================================

-- Add a named CHECK constraint
ALTER TABLE students_demo
    ADD CONSTRAINT chk_first_name CHECK (LENGTH(first_name) >= 2);

-- Drop it
ALTER TABLE students_demo
    DROP CONSTRAINT chk_first_name;

-- Add a unique constraint
ALTER TABLE students_demo
    ADD CONSTRAINT uq_first_last UNIQUE (first_name, last_name);

-- Drop it
ALTER TABLE students_demo
    DROP CONSTRAINT uq_first_last;

-- Disable a FK temporarily (PostgreSQL: NOT VALID defers enforcement)
ALTER TABLE students_demo
    ADD CONSTRAINT fk_new_dept FOREIGN KEY (department_id)
    REFERENCES dept_demo(department_id)
    NOT VALID;   -- existing rows not checked; new rows still checked

-- Validate after bulk load
ALTER TABLE students_demo
    VALIDATE CONSTRAINT fk_new_dept;

ALTER TABLE students_demo
    DROP CONSTRAINT fk_new_dept;

-- =============================================================
-- Section 9: PostgreSQL DDL is transactional!
-- =============================================================

-- PostgreSQL can roll back DDL — unique among the three platforms
BEGIN;

CREATE TABLE txn_test (
    id   SERIAL  PRIMARY KEY,
    val  TEXT    NOT NULL
);

INSERT INTO txn_test (val) VALUES ('test row');

ROLLBACK;  -- the table itself is rolled back — it no longer exists

-- Verify:
SELECT to_regclass('public.txn_test');  -- returns NULL if table doesn't exist

-- =============================================================
-- Section 10: GENERATED columns (PostgreSQL 12+)
-- =============================================================

DROP TABLE IF EXISTS products_demo;

CREATE TABLE products_demo (
    product_id      SERIAL           PRIMARY KEY,
    unit_price      NUMERIC(10, 2)   NOT NULL,
    tax_rate        NUMERIC(5, 4)    NOT NULL DEFAULT 0.13,
    price_with_tax  NUMERIC(10, 2)
        GENERATED ALWAYS AS (unit_price * (1 + tax_rate)) STORED
);

INSERT INTO products_demo (unit_price, tax_rate) VALUES (100.00, 0.13);
SELECT * FROM products_demo;
-- price_with_tax = 113.00

-- =============================================================
-- Section 11: CHECK constraint on email pattern
-- =============================================================

DROP TABLE IF EXISTS contacts_demo;

CREATE TABLE contacts_demo (
    contact_id  SERIAL        PRIMARY KEY,
    email       VARCHAR(200)  NOT NULL,
    age         INT,
    CONSTRAINT chk_email_format CHECK (email ~* '^[^@]+@[^@]+\.[^@]+$'),
    CONSTRAINT chk_age          CHECK (age IS NULL OR age BETWEEN 0 AND 150)
);

-- Valid insert
INSERT INTO contacts_demo (email, age) VALUES ('amara@example.com', 22);

-- Invalid: bad email format — will fail CHECK
-- INSERT INTO contacts_demo (email) VALUES ('not-an-email');

-- =============================================================
-- Section 12: Inspect constraints via information_schema
-- =============================================================

SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name  AS foreign_table,
    ccu.column_name AS foreign_column
FROM   information_schema.table_constraints      tc
LEFT JOIN information_schema.key_column_usage    kcu
    ON kcu.constraint_name = tc.constraint_name
    AND kcu.table_schema   = tc.table_schema
LEFT JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE  tc.table_schema = 'public'
  AND  tc.table_name   = 'students_demo'
ORDER BY tc.constraint_type, tc.constraint_name;

-- =============================================================
-- Section 13: Sequences — the engine behind SERIAL
-- =============================================================

-- See all sequences in the public schema
SELECT sequence_name, start_value, increment_by, min_value, max_value
FROM   information_schema.sequences
WHERE  sequence_schema = 'public';

-- Peek at the next value without consuming it
SELECT last_value FROM students_demo_student_id_seq;

-- Manually set a sequence (e.g., after a bulk load)
SELECT setval('students_demo_student_id_seq', 1000, TRUE);
-- Next INSERT will get 1001

-- Reset to start
SELECT setval('students_demo_student_id_seq', 1, FALSE);
-- Next INSERT will get 1

-- =============================================================
-- Section 14: Cleanup
-- =============================================================

DROP TABLE IF EXISTS enrollments_demo CASCADE;
DROP TABLE IF EXISTS students_demo    CASCADE;
DROP TABLE IF EXISTS courses_demo     CASCADE;
DROP TABLE IF EXISTS dept_demo        CASCADE;
DROP TABLE IF EXISTS dept_identity    CASCADE;
DROP TABLE IF EXISTS products_demo    CASCADE;
DROP TABLE IF EXISTS contacts_demo    CASCADE;
