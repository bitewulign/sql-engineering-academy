-- =============================================================
-- Module 09 — Schema Design & DDL
-- Platform: MySQL 8.0
-- Database: university
-- Data: Synthetic only. No real personal information.
-- =============================================================

USE university;

-- =============================================================
-- Section 1: Review the existing schema
-- =============================================================

-- See all tables in the database
SHOW TABLES;

-- See the CREATE TABLE statement MySQL generated for students
SHOW CREATE TABLE students\G

-- See column details
DESCRIBE students;
DESCRIBE departments;
DESCRIBE enrollments;

-- =============================================================
-- Section 2: Normalization walk-through
-- =============================================================

-- Bad design — stores multiple phone numbers in one column (1NF violation)
-- We will NOT create this — just illustrate the problem:
-- CREATE TABLE bad_students (
--     student_id INT,
--     name       VARCHAR(200),
--     phones     VARCHAR(500)   -- '555-1234, 555-5678' — NOT atomic
-- );

-- 3NF violation if we stored dept_name in students:
-- students(student_id, dept_id, dept_name)
-- dept_name depends on dept_id, not student_id → transitive dependency
-- Our existing design avoids this by keeping dept_name in departments.

-- =============================================================
-- Section 3: CREATE TABLE — departments (clean recreation)
-- =============================================================

DROP TABLE IF EXISTS dept_demo;

CREATE TABLE dept_demo (
    department_id   INT             NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100)    NOT NULL,
    building        VARCHAR(50),
    budget          DECIMAL(12, 2)  DEFAULT 0.00,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (department_id),
    UNIQUE KEY uq_dept_name (department_name)
);

SHOW CREATE TABLE dept_demo\G

-- =============================================================
-- Section 4: CREATE TABLE — students with full constraints
-- =============================================================

DROP TABLE IF EXISTS students_demo;

CREATE TABLE students_demo (
    student_id    INT              NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(100)     NOT NULL,
    last_name     VARCHAR(100)     NOT NULL,
    email         VARCHAR(200)     NOT NULL,
    gpa           DECIMAL(3, 2)    NOT NULL DEFAULT 0.00,
    department_id INT              NOT NULL,
    enrolled_at   DATE             NOT NULL DEFAULT (CURDATE()),
    is_active     TINYINT(1)       NOT NULL DEFAULT 1,
    PRIMARY KEY (student_id),
    UNIQUE KEY uq_student_email (email),
    CONSTRAINT chk_gpa     CHECK (gpa BETWEEN 0.00 AND 4.00),
    CONSTRAINT fk_std_dept FOREIGN KEY (department_id)
        REFERENCES dept_demo(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

DESCRIBE students_demo;

-- =============================================================
-- Section 5: Composite PRIMARY KEY — enrollments
-- =============================================================

DROP TABLE IF EXISTS courses_demo;
DROP TABLE IF EXISTS enrollments_demo;

CREATE TABLE courses_demo (
    course_id   INT             NOT NULL AUTO_INCREMENT,
    course_name VARCHAR(150)    NOT NULL,
    credits     TINYINT         NOT NULL DEFAULT 3,
    PRIMARY KEY (course_id)
);

CREATE TABLE enrollments_demo (
    student_id  INT             NOT NULL,
    course_id   INT             NOT NULL,
    grade       DECIMAL(4, 2),
    enrolled_on DATE            NOT NULL DEFAULT (CURDATE()),
    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enr_student FOREIGN KEY (student_id)
        REFERENCES students_demo(student_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_enr_course  FOREIGN KEY (course_id)
        REFERENCES courses_demo(course_id)
        ON DELETE RESTRICT
);

-- =============================================================
-- Section 6: AUTO_INCREMENT — getting the generated ID
-- =============================================================

INSERT INTO dept_demo (department_name, building, budget)
VALUES ('Computer Science', 'Tech Hall', 500000.00);

SELECT LAST_INSERT_ID() AS new_dept_id;

-- Multiple inserts — LAST_INSERT_ID() returns the FIRST id of the batch
INSERT INTO dept_demo (department_name, building)
VALUES
    ('Mathematics', 'Science Block'),
    ('Physics',     'Science Block');

SELECT LAST_INSERT_ID() AS first_id_of_batch;
SELECT * FROM dept_demo;

-- =============================================================
-- Section 7: Indexes
-- =============================================================

-- Index on FK column (MySQL does not auto-index FK columns)
CREATE INDEX idx_students_dept
    ON students_demo(department_id);

-- Composite index — left-prefix rule
-- This index helps: WHERE department_id = ? AND gpa > ?
-- This index ALSO helps: WHERE department_id = ?
-- This index does NOT help: WHERE gpa > ?  (no leading department_id)
CREATE INDEX idx_students_dept_gpa
    ON students_demo(department_id, gpa DESC);

-- Unique index (equivalent to UNIQUE constraint)
CREATE UNIQUE INDEX uq_std_email2
    ON students_demo(email);  -- will fail: uq_student_email already exists
-- DROP INDEX uq_std_email2 ON students_demo;

-- Check indexes on a table
SHOW INDEX FROM students_demo;

-- =============================================================
-- Section 8: ALTER TABLE — add, modify, drop column
-- =============================================================

-- Add a column
ALTER TABLE students_demo
    ADD COLUMN phone VARCHAR(20) AFTER last_name;

DESCRIBE students_demo;

-- Set a default on the new column
ALTER TABLE students_demo
    MODIFY COLUMN phone VARCHAR(20) DEFAULT 'unknown';

-- Rename a column (MySQL 8.0+)
ALTER TABLE students_demo
    RENAME COLUMN phone TO contact_phone;

DESCRIBE students_demo;

-- Drop the column
ALTER TABLE students_demo
    DROP COLUMN contact_phone;

DESCRIBE students_demo;

-- =============================================================
-- Section 9: ALTER TABLE — add and drop constraints
-- =============================================================

-- Add a CHECK constraint
ALTER TABLE students_demo
    ADD CONSTRAINT chk_first_name CHECK (LENGTH(first_name) >= 2);

-- Verify: try to insert a single-character name
-- INSERT INTO students_demo (first_name, last_name, email, gpa, department_id)
-- VALUES ('A', 'Test', 'a@example.com', 3.00, 1);  -- will fail CHECK

-- Drop the CHECK constraint
ALTER TABLE students_demo
    DROP CHECK chk_first_name;

-- Add a unique constraint
ALTER TABLE students_demo
    ADD CONSTRAINT uq_first_last UNIQUE (first_name, last_name);

-- Drop it
ALTER TABLE students_demo
    DROP INDEX uq_first_last;  -- MySQL drops UNIQUE as an index

-- =============================================================
-- Section 10: Referential actions — CASCADE vs RESTRICT
-- =============================================================

-- ON DELETE CASCADE: deleting a dept removes all its students
-- ON DELETE RESTRICT: cannot delete a dept that has students

-- Test RESTRICT (fk_std_dept is ON DELETE RESTRICT)
INSERT INTO students_demo (first_name, last_name, email, gpa, department_id, enrolled_at)
VALUES ('Amara', 'Diallo', 'amara@example.com', 3.80, 1, CURDATE());

-- This will fail because student references dept 1:
-- DELETE FROM dept_demo WHERE department_id = 1;

-- DROP TABLE order matters: children before parents
-- DROP TABLE enrollments_demo;
-- DROP TABLE students_demo;
-- DROP TABLE courses_demo;
-- DROP TABLE dept_demo;

-- =============================================================
-- Section 11: Safe DROP with IF EXISTS
-- =============================================================

DROP TABLE IF EXISTS temp_import;

-- Pattern for conditional table creation
CREATE TABLE IF NOT EXISTS temp_import (
    import_id   INT          NOT NULL AUTO_INCREMENT,
    raw_data    TEXT,
    imported_at DATETIME     DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (import_id)
);

DROP TABLE IF EXISTS temp_import;

-- =============================================================
-- Section 12: SHOW and INFORMATION_SCHEMA
-- =============================================================

-- Check all constraints on a table
SELECT
    tc.CONSTRAINT_NAME,
    tc.CONSTRAINT_TYPE,
    kcu.COLUMN_NAME,
    kcu.REFERENCED_TABLE_NAME,
    kcu.REFERENCED_COLUMN_NAME
FROM   information_schema.TABLE_CONSTRAINTS  tc
JOIN   information_schema.KEY_COLUMN_USAGE   kcu
    ON kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
    AND kcu.TABLE_SCHEMA   = tc.TABLE_SCHEMA
    AND kcu.TABLE_NAME     = tc.TABLE_NAME
WHERE  tc.TABLE_SCHEMA = 'university'
  AND  tc.TABLE_NAME   = 'students_demo'
ORDER BY tc.CONSTRAINT_TYPE, tc.CONSTRAINT_NAME;

-- Check all indexes
SELECT
    INDEX_NAME,
    NON_UNIQUE,
    SEQ_IN_INDEX,
    COLUMN_NAME,
    INDEX_TYPE
FROM   information_schema.STATISTICS
WHERE  TABLE_SCHEMA = 'university'
  AND  TABLE_NAME   = 'students_demo'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- =============================================================
-- Section 13: GENERATED columns (MySQL 8.0)
-- =============================================================

DROP TABLE IF EXISTS products_demo;

CREATE TABLE products_demo (
    product_id    INT              NOT NULL AUTO_INCREMENT,
    unit_price    DECIMAL(10, 2)   NOT NULL,
    tax_rate      DECIMAL(5, 4)    NOT NULL DEFAULT 0.13,
    price_with_tax DECIMAL(10, 2) GENERATED ALWAYS AS
                  (unit_price * (1 + tax_rate)) STORED,
    PRIMARY KEY (product_id)
);

INSERT INTO products_demo (unit_price, tax_rate) VALUES (100.00, 0.13);
SELECT * FROM products_demo;
-- price_with_tax = 113.00 — computed automatically

-- =============================================================
-- Section 14: Cleanup
-- =============================================================

DROP TABLE IF EXISTS enrollments_demo;
DROP TABLE IF EXISTS students_demo;
DROP TABLE IF EXISTS courses_demo;
DROP TABLE IF EXISTS dept_demo;
DROP TABLE IF EXISTS products_demo;
