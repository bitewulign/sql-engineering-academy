-- ============================================================
-- SQL Engineering Academy
-- Engine:  MySQL 8.0
-- Module:  02 — Creating Tables and Inserting Data
-- File:    02_create_insert.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Run in MySQL Workbench or mysql CLI.
-- Connect to: localhost:3306  User: root (or academy)
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: Create and select the academy database
-- ────────────────────────────────────────────────────────────

-- Create with explicit character set (always use utf8mb4 in MySQL)
CREATE DATABASE IF NOT EXISTS academy
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE academy;

-- Verify
SELECT DATABASE() AS current_database;


-- ────────────────────────────────────────────────────────────
-- SECTION 2: Data types demonstration
-- ────────────────────────────────────────────────────────────

-- Integer types
SELECT
    CAST(32767  AS SIGNED)    AS smallint_max,     -- SMALLINT max
    CAST(2147483647 AS SIGNED) AS int_max,          -- INT max
    255                        AS tinyint_max;      -- TINYINT max

-- Decimal vs float
SELECT
    CAST(0.1 + 0.2 AS DECIMAL(10,2)) AS decimal_sum,  -- 0.30 (exact)
    0.1 + 0.2                         AS float_sum;    -- 0.30000000000000004 (approximate!)

-- String types
SELECT
    'Hello'                          AS char_example,
    REPEAT('x', 65535)               AS varchar_max_check,
    LENGTH(REPEAT('x', 65535))       AS varchar_length;

-- Boolean in MySQL
SELECT
    TRUE  AS bool_true,     -- 1
    FALSE AS bool_false,    -- 0
    TRUE + 0 AS true_as_int; -- 1


-- ────────────────────────────────────────────────────────────
-- SECTION 3: CREATE TABLE — students
-- ────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id   INT             NOT NULL AUTO_INCREMENT,
    first_name   VARCHAR(50)     NOT NULL,
    last_name    VARCHAR(50)     NOT NULL,
    email        VARCHAR(100)    NOT NULL,
    phone        VARCHAR(20),
    gpa          DECIMAL(3,2),
    enrolled_at  DATE            NOT NULL,
    is_active    BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_students         PRIMARY KEY (student_id),
    CONSTRAINT uq_students_email   UNIQUE (email),
    CONSTRAINT chk_students_gpa    CHECK (gpa >= 0.00 AND gpa <= 4.00)
) ENGINE=InnoDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Verify the table structure
DESCRIBE students;

-- Check the AUTO_INCREMENT starting value
SELECT AUTO_INCREMENT
FROM   information_schema.TABLES
WHERE  TABLE_SCHEMA = DATABASE()
  AND  TABLE_NAME = 'students';


-- ────────────────────────────────────────────────────────────
-- SECTION 4: CREATE TABLE — courses (with FK)
-- ────────────────────────────────────────────────────────────

CREATE TABLE courses (
    course_id    INT             NOT NULL AUTO_INCREMENT,
    course_code  VARCHAR(10)     NOT NULL,
    course_name  VARCHAR(100)    NOT NULL,
    credits      TINYINT         NOT NULL DEFAULT 3,
    max_students SMALLINT        NOT NULL DEFAULT 30,

    CONSTRAINT pk_courses         PRIMARY KEY (course_id),
    CONSTRAINT uq_courses_code    UNIQUE (course_code),
    CONSTRAINT chk_courses_credits CHECK (credits BETWEEN 1 AND 6),
    CONSTRAINT chk_max_students    CHECK (max_students > 0)
) ENGINE=InnoDB CHARACTER SET utf8mb4;


CREATE TABLE enrollments (
    enrollment_id  INT          NOT NULL AUTO_INCREMENT,
    student_id     INT          NOT NULL,
    course_id      INT          NOT NULL,
    enrolled_on    DATE         NOT NULL,
    grade          DECIMAL(4,1),

    CONSTRAINT pk_enrollments    PRIMARY KEY (enrollment_id),
    CONSTRAINT uq_enrollment     UNIQUE (student_id, course_id),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_course  FOREIGN KEY (course_id)
        REFERENCES courses (course_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB CHARACTER SET utf8mb4;


-- ────────────────────────────────────────────────────────────
-- SECTION 5: INSERT — single and multi-row
-- ────────────────────────────────────────────────────────────

-- 5.1  Single row insert (auto_increment generates student_id)
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES ('Amara', 'Osei', 'amara.osei@example.com', 3.80, '2024-09-01');

-- 5.2  Get the auto-assigned ID
SELECT LAST_INSERT_ID() AS new_student_id;

-- 5.3  Multi-row insert (much faster than individual inserts)
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES
    ('Priya',   'Sharma',   'priya.sharma@example.com',   3.50, '2024-09-01'),
    ('Carlos',  'Mendez',   'carlos.mendez@example.com',  3.90, '2024-01-15'),
    ('Sofia',   'Eriksson', 'sofia.eriksson@example.com', 3.70, '2023-09-01'),
    ('Yuki',    'Tanaka',   'yuki.tanaka@example.com',    3.60, '2024-09-01'),
    ('Ibrahim', 'Al-Farsi', 'ibrahim.alfarsi@example.com',3.85, '2023-01-10');

-- Verify
SELECT * FROM students ORDER BY student_id;

-- 5.4  Insert courses
INSERT INTO courses (course_code, course_name, credits)
VALUES
    ('SQL101', 'Introduction to SQL',   3),
    ('SQL201', 'Intermediate SQL',      3),
    ('DB301',  'Database Design',       4),
    ('PY101',  'Python for Data',       3);

-- 5.5  Insert enrollments (reference real IDs)
INSERT INTO enrollments (student_id, course_id, enrolled_on, grade)
VALUES
    (1, 1, '2024-09-05', 92.5),
    (1, 2, '2024-09-05', NULL),    -- NULL grade = not yet graded
    (2, 1, '2024-09-05', 88.0),
    (3, 3, '2024-01-20', 95.0),
    (4, 1, '2024-09-05', 79.5);


-- ────────────────────────────────────────────────────────────
-- SECTION 6: UPDATE
-- ────────────────────────────────────────────────────────────

-- 6.1  Update a single column
UPDATE students
SET   gpa = 3.95
WHERE student_id = 1;

-- 6.2  Update multiple columns
UPDATE students
SET   phone      = '416-555-0101',
      is_active  = TRUE
WHERE student_id = 2;

-- 6.3  Verify
SELECT student_id, first_name, gpa, phone, is_active
FROM   students
ORDER BY student_id;

-- 6.4  Conditional update: cap all GPAs above 4.0 (safety clamp)
UPDATE students
SET    gpa = 4.00
WHERE  gpa > 4.00;


-- ────────────────────────────────────────────────────────────
-- SECTION 7: DELETE
-- ────────────────────────────────────────────────────────────

-- 7.1  Delete a specific row
-- (First insert a throwaway row to delete)
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Test', 'Delete', 'test.delete@example.com', CURDATE());

SELECT student_id FROM students WHERE email = 'test.delete@example.com';

DELETE FROM students
WHERE email = 'test.delete@example.com';

-- 7.2  Verify the row is gone
SELECT COUNT(*) AS student_count FROM students;


-- ────────────────────────────────────────────────────────────
-- SECTION 8: TRUNCATE vs DELETE
-- ────────────────────────────────────────────────────────────

-- Create a demo table to demonstrate TRUNCATE
CREATE TEMPORARY TABLE demo_truncate (
    id   INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    val  VARCHAR(10)
);

INSERT INTO demo_truncate (val) VALUES ('a'), ('b'), ('c');
SELECT * FROM demo_truncate;             -- ids 1, 2, 3

TRUNCATE TABLE demo_truncate;

INSERT INTO demo_truncate (val) VALUES ('x');
SELECT * FROM demo_truncate;             -- id restarts at 1 (AUTO_INCREMENT reset)

DROP TEMPORARY TABLE demo_truncate;


-- ────────────────────────────────────────────────────────────
-- SECTION 9: ALTER TABLE
-- ────────────────────────────────────────────────────────────

-- 9.1  Add a column
ALTER TABLE students ADD COLUMN notes TEXT;

-- 9.2  Add a column with default
ALTER TABLE students ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP;

-- 9.3  Modify a column (MySQL uses MODIFY COLUMN)
ALTER TABLE students MODIFY COLUMN phone VARCHAR(30);

-- 9.4  Rename a column (MySQL 8.0+)
ALTER TABLE students RENAME COLUMN notes TO bio;

-- 9.5  Drop a column
ALTER TABLE students DROP COLUMN bio;

-- Verify final structure
DESCRIBE students;


-- ────────────────────────────────────────────────────────────
-- SECTION 10: DROP TABLE (cleanup)
-- ────────────────────────────────────────────────────────────

-- Drop in correct order: children before parents
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- ============================================================
-- END OF MODULE 02 — MYSQL
-- Key MySQL-specific points:
--   - AUTO_INCREMENT for auto-incrementing PKs
--   - LAST_INSERT_ID() to get the new ID
--   - utf8mb4 for full Unicode support (always specify this)
--   - BOOLEAN is TINYINT(1) under the hood
--   - ON UPDATE CURRENT_TIMESTAMP for audit timestamps
--   - ENGINE=InnoDB is required for foreign keys
-- ============================================================
