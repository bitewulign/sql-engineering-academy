-- ============================================================
-- SQL Engineering Academy
-- Engine:  Microsoft SQL Server 2022
-- Module:  02 — Creating Tables and Inserting Data
-- File:    02_create_insert.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Run in SSMS or Azure Data Studio.
-- Connect to: localhost,1433  User: SA
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: Create and switch to the academy database
-- ────────────────────────────────────────────────────────────

-- GO separates T-SQL batches (required after CREATE DATABASE)
CREATE DATABASE academy;
GO

USE academy;
GO

-- Verify
SELECT DB_NAME() AS current_database;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 2: Data types demonstration
-- ────────────────────────────────────────────────────────────

-- Integer types
SELECT
    CAST(32767 AS SMALLINT)  AS smallint_max,
    2147483647               AS int_max,
    CAST(255 AS TINYINT)     AS tinyint_max;

-- Decimal vs float
SELECT
    CAST(0.1 + 0.2 AS DECIMAL(10,2))  AS decimal_sum,  -- 0.30 (exact)
    CAST(0.1 AS FLOAT) + CAST(0.2 AS FLOAT) AS float_sum;  -- approximate

-- SQL Server string types
-- VARCHAR  = variable-length, non-Unicode (Latin-1)
-- NVARCHAR = variable-length, Unicode (use for international text)
SELECT
    'Hello'            AS varchar_example,
    N'Héllo wörld'     AS nvarchar_example,    -- N prefix = Unicode literal
    LEN('Hello')       AS char_count,
    DATALENGTH('Hello')     AS byte_len_varchar,  -- 5
    DATALENGTH(N'Hello')    AS byte_len_nvarchar;  -- 10 (2 bytes per char)

-- SQL Server BIT (boolean)
SELECT
    CAST(1 AS BIT) AS bit_true,
    CAST(0 AS BIT) AS bit_false;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 3: CREATE TABLE — students
-- Using IDENTITY(1,1) for auto-incrementing PK
-- ────────────────────────────────────────────────────────────

-- Drop in correct order: children before parents
IF OBJECT_ID('enrollments', 'U') IS NOT NULL DROP TABLE enrollments;
IF OBJECT_ID('courses',     'U') IS NOT NULL DROP TABLE courses;
IF OBJECT_ID('students',    'U') IS NOT NULL DROP TABLE students;
GO

CREATE TABLE students (
    student_id   INT             NOT NULL IDENTITY(1,1),
    first_name   NVARCHAR(50)    NOT NULL,
    last_name    NVARCHAR(50)    NOT NULL,
    email        NVARCHAR(100)   NOT NULL,
    phone        NVARCHAR(20)    NULL,
    gpa          DECIMAL(3,2)    NULL,
    enrolled_at  DATE            NOT NULL,
    is_active    BIT             NOT NULL CONSTRAINT df_students_active DEFAULT 1,
    created_at   DATETIME2       NOT NULL CONSTRAINT df_students_created DEFAULT SYSDATETIME(),

    CONSTRAINT pk_students        PRIMARY KEY (student_id),
    CONSTRAINT uq_students_email  UNIQUE (email),
    CONSTRAINT chk_students_gpa   CHECK (gpa BETWEEN 0.00 AND 4.00)
);
GO

-- View the table structure (T-SQL way)
EXEC sp_help 'students';
GO

-- Or use standard catalog views
SELECT
    c.name            AS column_name,
    t.name            AS data_type,
    c.max_length,
    c.is_nullable,
    c.is_identity
FROM   sys.columns c
JOIN   sys.types   t ON c.user_type_id = t.user_type_id
WHERE  c.object_id = OBJECT_ID('students')
ORDER  BY c.column_id;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 4: CREATE TABLE — courses and enrollments
-- ────────────────────────────────────────────────────────────

CREATE TABLE courses (
    course_id    INT             NOT NULL IDENTITY(1,1),
    course_code  VARCHAR(10)     NOT NULL,
    course_name  NVARCHAR(100)   NOT NULL,
    credits      TINYINT         NOT NULL CONSTRAINT df_credits DEFAULT 3,
    max_students SMALLINT        NOT NULL CONSTRAINT df_max_students DEFAULT 30,

    CONSTRAINT pk_courses         PRIMARY KEY (course_id),
    CONSTRAINT uq_courses_code    UNIQUE (course_code),
    CONSTRAINT chk_credits        CHECK (credits BETWEEN 1 AND 6),
    CONSTRAINT chk_max_students   CHECK (max_students > 0)
);
GO

CREATE TABLE enrollments (
    enrollment_id  INT          NOT NULL IDENTITY(1,1),
    student_id     INT          NOT NULL,
    course_id      INT          NOT NULL,
    enrolled_on    DATE         NOT NULL,
    grade          DECIMAL(4,1) NULL,

    CONSTRAINT pk_enrollments    PRIMARY KEY (enrollment_id),
    CONSTRAINT uq_enrollment     UNIQUE (student_id, course_id),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_course  FOREIGN KEY (course_id)
        REFERENCES courses (course_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 5: INSERT
-- ────────────────────────────────────────────────────────────

-- 5.1  Single row insert
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES (N'Amara', N'Osei', N'amara.osei@example.com', 3.80, '2024-09-01');

-- 5.2  Get the auto-assigned identity value
SELECT SCOPE_IDENTITY() AS new_student_id;
-- SCOPE_IDENTITY() is preferred over @@IDENTITY
-- @@IDENTITY can be misleading if a trigger inserts into another identity table

-- 5.3  Multi-row insert
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES
    (N'Priya',   N'Sharma',   N'priya.sharma@example.com',   3.50, '2024-09-01'),
    (N'Carlos',  N'Mendez',   N'carlos.mendez@example.com',  3.90, '2024-01-15'),
    (N'Sofia',   N'Eriksson', N'sofia.eriksson@example.com', 3.70, '2023-09-01'),
    (N'Yuki',    N'Tanaka',   N'yuki.tanaka@example.com',    3.60, '2024-09-01'),
    (N'Ibrahim', N'Al-Farsi', N'ibrahim.alfarsi@example.com',3.85, '2023-01-10');

-- 5.4  OUTPUT clause (SQL Server equivalent of PostgreSQL RETURNING)
-- Returns data from rows as they are inserted
INSERT INTO students (first_name, last_name, email, enrolled_at)
OUTPUT INSERTED.student_id, INSERTED.first_name, INSERTED.last_name
VALUES (N'Extra', N'Student', N'extra.student@example.com', '2024-09-01');

-- 5.5  Verify
SELECT * FROM students ORDER BY student_id;

-- 5.6  Insert courses
INSERT INTO courses (course_code, course_name, credits)
VALUES
    ('SQL101', N'Introduction to SQL',   3),
    ('SQL201', N'Intermediate SQL',      3),
    ('DB301',  N'Database Design',       4),
    ('PY101',  N'Python for Data',       3);

-- 5.7  Enrollments
INSERT INTO enrollments (student_id, course_id, enrolled_on, grade)
VALUES
    (1, 1, '2024-09-05', 92.5),
    (1, 2, '2024-09-05', NULL),
    (2, 1, '2024-09-05', 88.0),
    (3, 3, '2024-01-20', 95.0),
    (4, 1, '2024-09-05', 79.5);
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 6: UPDATE — with OUTPUT clause
-- ────────────────────────────────────────────────────────────

-- 6.1  Update GPA with OUTPUT to see old and new values
UPDATE students
SET    gpa = 3.95
OUTPUT DELETED.gpa AS old_gpa, INSERTED.gpa AS new_gpa,
       INSERTED.first_name
WHERE  student_id = 1;

-- 6.2  Update multiple columns
UPDATE students
SET    phone     = N'416-555-0101',
       is_active = 1
WHERE  student_id = 2;

-- 6.3  Verify
SELECT student_id, first_name, gpa, phone, is_active
FROM   students
ORDER BY student_id;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 7: DELETE — with OUTPUT
-- ────────────────────────────────────────────────────────────

-- 7.1  Insert a throwaway row
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES (N'Test', N'Delete', N'test.delete@example.com', GETDATE());

-- 7.2  Delete with OUTPUT to log what was removed
DELETE FROM students
OUTPUT DELETED.student_id, DELETED.first_name, DELETED.last_name
WHERE  email = N'test.delete@example.com';

-- 7.3  Count check
SELECT COUNT(*) AS student_count FROM students;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 8: TRUNCATE
-- ────────────────────────────────────────────────────────────

CREATE TABLE #demo_truncate (
    id   INT IDENTITY(1,1) PRIMARY KEY,
    val  VARCHAR(10)
);

INSERT INTO #demo_truncate (val) VALUES ('a'), ('b'), ('c');
SELECT * FROM #demo_truncate;        -- ids 1, 2, 3

TRUNCATE TABLE #demo_truncate;       -- resets IDENTITY counter

INSERT INTO #demo_truncate (val) VALUES ('x');
SELECT * FROM #demo_truncate;        -- id = 1

DROP TABLE #demo_truncate;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 9: ALTER TABLE
-- ────────────────────────────────────────────────────────────

-- 9.1  Add a column
ALTER TABLE students ADD bio NVARCHAR(MAX);

-- 9.2  Add a column with default
ALTER TABLE students ADD updated_at DATETIME2 DEFAULT SYSDATETIME();

-- 9.3  Alter a column type
ALTER TABLE students ALTER COLUMN phone NVARCHAR(30);

-- 9.4  Rename a column (SQL Server 2022 syntax)
EXEC sp_rename 'students.bio', 'notes', 'COLUMN';
GO

-- 9.5  Drop a column (must drop default constraint first if one exists)
-- Check for and drop any default constraint on 'notes'
DECLARE @constraintName NVARCHAR(200);
SELECT  @constraintName = dc.name
FROM    sys.default_constraints dc
JOIN    sys.columns c ON dc.parent_object_id = c.object_id
                      AND dc.parent_column_id = c.column_id
WHERE   c.object_id = OBJECT_ID('students')
  AND   c.name = 'notes';

IF @constraintName IS NOT NULL
    EXEC ('ALTER TABLE students DROP CONSTRAINT ' + @constraintName);

ALTER TABLE students DROP COLUMN notes;
GO

-- Verify
SELECT
    c.name AS column_name,
    t.name AS data_type
FROM   sys.columns c
JOIN   sys.types   t ON c.user_type_id = t.user_type_id
WHERE  c.object_id = OBJECT_ID('students')
ORDER  BY c.column_id;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 10: Cleanup
-- ────────────────────────────────────────────────────────────

IF OBJECT_ID('enrollments', 'U') IS NOT NULL DROP TABLE enrollments;
IF OBJECT_ID('courses',     'U') IS NOT NULL DROP TABLE courses;
IF OBJECT_ID('students',    'U') IS NOT NULL DROP TABLE students;
GO

-- ============================================================
-- END OF MODULE 02 — SQL SERVER
-- Key SQL Server-specific points:
--   - IDENTITY(seed, increment) for auto-incrementing PKs
--   - SCOPE_IDENTITY() to get the last identity value
--   - OUTPUT clause (INSERTED / DELETED) on INSERT/UPDATE/DELETE
--   - Use NVARCHAR for Unicode text (not VARCHAR)
--   - N'' prefix for Unicode string literals
--   - DATETIME2 is preferred over DATETIME
--   - GO separates T-SQL batches
--   - sp_rename to rename columns (no RENAME COLUMN in older versions)
-- ============================================================
