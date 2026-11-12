-- =============================================================
-- Module 09 — Schema Design & DDL
-- Platform: SQL Server 2022
-- Database: university
-- Data: Synthetic only. No real personal information.
-- =============================================================

USE university;
GO

-- =============================================================
-- Section 1: Review the existing schema
-- =============================================================

-- List all tables
SELECT table_name, table_type
FROM   information_schema.tables
WHERE  table_schema = 'dbo'
ORDER BY table_name;
GO

-- Describe a table's columns
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM   information_schema.columns
WHERE  table_schema = 'dbo'
  AND  table_name   = 'students'
ORDER BY ordinal_position;
GO

-- =============================================================
-- Section 2: CREATE TABLE — SQL Server-native types
-- =============================================================

-- Note: Always use NVARCHAR for user-generated text (Unicode, UTF-16)
--       Use VARCHAR only for ASCII-safe codes (email addresses, ISO codes)

IF OBJECT_ID('dbo.dept_demo', 'U') IS NOT NULL
    DROP TABLE dbo.dept_demo;
GO

CREATE TABLE dept_demo (
    department_id   INT             NOT NULL IDENTITY(1,1),
    department_name NVARCHAR(100)   NOT NULL,
    building        NVARCHAR(50),
    budget          DECIMAL(12, 2)  NOT NULL DEFAULT 0.00,
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_dept_demo    PRIMARY KEY (department_id),
    CONSTRAINT uq_dept_name    UNIQUE      (department_name)
);
GO

-- =============================================================
-- Section 3: CREATE TABLE — students with full constraints
-- =============================================================

IF OBJECT_ID('dbo.students_demo', 'U') IS NOT NULL
    DROP TABLE dbo.students_demo;
GO

CREATE TABLE students_demo (
    student_id    INT             NOT NULL IDENTITY(1,1),
    first_name    NVARCHAR(100)   NOT NULL,
    last_name     NVARCHAR(100)   NOT NULL,
    email         VARCHAR(200)    NOT NULL,   -- email is ASCII-safe
    gpa           DECIMAL(3, 2)   NOT NULL DEFAULT 0.00,
    department_id INT             NOT NULL,
    enrolled_at   DATE            NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    is_active     BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_students_demo PRIMARY KEY (student_id),
    CONSTRAINT uq_std_email     UNIQUE      (email),
    CONSTRAINT chk_gpa          CHECK       (gpa BETWEEN 0.00 AND 4.00),
    CONSTRAINT fk_std_dept      FOREIGN KEY (department_id)
        REFERENCES dept_demo(department_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- =============================================================
-- Section 4: Composite PRIMARY KEY — enrollments
-- =============================================================

IF OBJECT_ID('dbo.enrollments_demo', 'U') IS NOT NULL
    DROP TABLE dbo.enrollments_demo;
IF OBJECT_ID('dbo.courses_demo', 'U') IS NOT NULL
    DROP TABLE dbo.courses_demo;
GO

CREATE TABLE courses_demo (
    course_id   INT             NOT NULL IDENTITY(1,1),
    course_name NVARCHAR(150)   NOT NULL,
    credits     TINYINT         NOT NULL DEFAULT 3,
    CONSTRAINT pk_courses_demo PRIMARY KEY (course_id),
    CONSTRAINT chk_credits     CHECK (credits BETWEEN 1 AND 6)
);

CREATE TABLE enrollments_demo (
    student_id  INT             NOT NULL,
    course_id   INT             NOT NULL,
    grade       DECIMAL(4, 2),
    enrolled_on DATE            NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT pk_enrollments_demo PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enr_student      FOREIGN KEY (student_id)
        REFERENCES students_demo(student_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_enr_course       FOREIGN KEY (course_id)
        REFERENCES courses_demo(course_id)
        ON DELETE NO ACTION
);
GO

-- =============================================================
-- Section 5: IDENTITY — getting the generated PK
-- =============================================================

INSERT INTO dept_demo (department_name, building, budget)
VALUES (N'Computer Science', N'Tech Hall', 500000.00);

SELECT SCOPE_IDENTITY() AS new_dept_id;
-- @@IDENTITY is session-wide; SCOPE_IDENTITY() is scoped to current statement — always prefer it

-- Multi-row insert + OUTPUT to capture all generated IDs
INSERT INTO dept_demo (department_name, building)
OUTPUT INSERTED.department_id, INSERTED.department_name
VALUES
    (N'Mathematics', N'Science Block'),
    (N'Physics',     N'Science Block');
GO

-- =============================================================
-- Section 6: Indexes
-- =============================================================

-- Index on FK column
CREATE NONCLUSTERED INDEX idx_students_dept
    ON students_demo(department_id);
GO

-- Composite index
CREATE NONCLUSTERED INDEX idx_students_dept_gpa
    ON students_demo(department_id ASC, gpa DESC);
GO

-- Covering index — INCLUDE avoids key lookup back to clustered index
CREATE NONCLUSTERED INDEX idx_cov_dept_name
    ON students_demo(department_id)
    INCLUDE (first_name, last_name, gpa);
GO

-- Filtered index — partial index equivalent
CREATE NONCLUSTERED INDEX idx_active_students
    ON students_demo(department_id)
    WHERE is_active = 1;
GO

-- Unique index
CREATE UNIQUE NONCLUSTERED INDEX uq_std_email
    ON students_demo(email);  -- fails: uq_std_email constraint already adds one
-- DROP INDEX IF EXISTS students_demo.uq_std_email;
GO

-- View all indexes on the table
SELECT
    i.name       AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS key_columns
FROM   sys.indexes          i
JOIN   sys.index_columns    ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
JOIN   sys.columns          c  ON c.object_id  = i.object_id AND c.column_id = ic.column_id
WHERE  i.object_id = OBJECT_ID('students_demo')
GROUP BY i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY i.name;
GO

-- =============================================================
-- Section 7: ALTER TABLE — add, rename, drop column
-- =============================================================

-- Add a column
ALTER TABLE students_demo
    ADD contact_phone NVARCHAR(20) NULL;
GO

-- Set a default on existing column
ALTER TABLE students_demo
    ADD CONSTRAINT df_contact_phone DEFAULT N'unknown' FOR contact_phone;
GO

-- Rename a column (SQL Server uses sp_rename)
EXEC sp_rename 'students_demo.contact_phone', 'phone', 'COLUMN';
GO

-- Drop the default constraint first, then drop the column
-- (SQL Server: a column with a DEFAULT cannot be dropped without first removing the constraint)
DECLARE @dfName NVARCHAR(200);
SELECT  @dfName = dc.name
FROM    sys.default_constraints dc
JOIN    sys.columns             c  ON c.object_id  = dc.parent_object_id
                                   AND c.column_id = dc.parent_column_id
WHERE   dc.parent_object_id = OBJECT_ID('students_demo')
  AND   c.name = 'phone';

IF @dfName IS NOT NULL
    EXEC ('ALTER TABLE students_demo DROP CONSTRAINT ' + @dfName);
GO

ALTER TABLE students_demo
    DROP COLUMN phone;
GO

-- =============================================================
-- Section 8: ALTER TABLE — add and drop constraints
-- =============================================================

-- Add a CHECK constraint
ALTER TABLE students_demo
    ADD CONSTRAINT chk_first_name CHECK (LEN(first_name) >= 2);
GO

-- Drop it
ALTER TABLE students_demo
    DROP CONSTRAINT chk_first_name;
GO

-- Add a unique constraint
ALTER TABLE students_demo
    ADD CONSTRAINT uq_first_last UNIQUE (first_name, last_name);
GO

-- Drop it
ALTER TABLE students_demo
    DROP CONSTRAINT uq_first_last;
GO

-- =============================================================
-- Section 9: SCOPE_IDENTITY() vs @@IDENTITY
-- =============================================================

-- @@IDENTITY returns the last identity inserted by the session,
-- even if a trigger inserted into another table that also has IDENTITY.
-- SCOPE_IDENTITY() is scoped to the current batch — always safer.

INSERT INTO dept_demo (department_name, building)
VALUES (N'Chemistry', N'Lab Wing');

SELECT
    SCOPE_IDENTITY() AS scope_identity,
    @@IDENTITY       AS at_identity;
-- Both return the same value here (no trigger involved)
-- In production: ALWAYS use SCOPE_IDENTITY()
GO

-- =============================================================
-- Section 10: Computed columns
-- =============================================================

IF OBJECT_ID('dbo.products_demo', 'U') IS NOT NULL
    DROP TABLE dbo.products_demo;
GO

CREATE TABLE products_demo (
    product_id      INT              NOT NULL IDENTITY(1,1),
    unit_price      DECIMAL(10, 2)   NOT NULL,
    tax_rate        DECIMAL(5, 4)    NOT NULL DEFAULT 0.13,
    price_with_tax  AS (unit_price * (1 + tax_rate)) PERSISTED,
    CONSTRAINT pk_products_demo PRIMARY KEY (product_id)
);
GO

INSERT INTO products_demo (unit_price, tax_rate) VALUES (100.00, 0.13);
SELECT * FROM products_demo;
-- price_with_tax = 113.00
GO

-- =============================================================
-- Section 11: Inspect constraints via system catalog
-- =============================================================

-- All constraints on students_demo
SELECT
    cc.name            AS constraint_name,
    cc.type_desc       AS constraint_type,
    c.name             AS column_name,
    cc.definition      AS check_definition
FROM   sys.check_constraints cc
LEFT JOIN sys.columns c
    ON c.object_id = cc.parent_object_id
    AND c.column_id = cc.parent_column_id
WHERE  cc.parent_object_id = OBJECT_ID('students_demo')

UNION ALL

SELECT
    fk.name,
    'FOREIGN_KEY',
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id),
    OBJECT_NAME(fk.referenced_object_id)
FROM   sys.foreign_keys        fk
JOIN   sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
WHERE  fk.parent_object_id = OBJECT_ID('students_demo');
GO

-- =============================================================
-- Section 12: DROP TABLE — safe patterns
-- =============================================================

-- Drop in FK-safe order: children before parents
IF OBJECT_ID('dbo.enrollments_demo', 'U') IS NOT NULL
    DROP TABLE dbo.enrollments_demo;
IF OBJECT_ID('dbo.students_demo', 'U') IS NOT NULL
    DROP TABLE dbo.students_demo;
IF OBJECT_ID('dbo.courses_demo', 'U') IS NOT NULL
    DROP TABLE dbo.courses_demo;
IF OBJECT_ID('dbo.dept_demo', 'U') IS NOT NULL
    DROP TABLE dbo.dept_demo;
IF OBJECT_ID('dbo.products_demo', 'U') IS NOT NULL
    DROP TABLE dbo.products_demo;
GO

-- =============================================================
-- Section 13: Nvarchar vs VARCHAR reminder
-- =============================================================

-- VARCHAR: 1 byte per ASCII char; cannot store emoji, Amharic, Arabic, etc.
-- NVARCHAR: 2 bytes per char (UTF-16); handles any Unicode

-- Always store user names and free-text with NVARCHAR in SQL Server:
-- NVARCHAR(100) for names, NVARCHAR(MAX) for long text, VARCHAR(200) for emails

-- String literals: prefix N to avoid silent truncation
-- N'Amara Diallo'  -- correct NVARCHAR literal
-- 'Amara Diallo'   -- treated as VARCHAR; works for ASCII, fails for Amharic

-- =============================================================
-- Section 14: SQL Server DDL is NOT transactional (mostly)
-- =============================================================

-- Unlike PostgreSQL, SQL Server auto-commits DDL.
-- CREATE TABLE inside a transaction CAN be rolled back,
-- but ALTER TABLE and DROP TABLE can also be rolled back inside an explicit transaction.
-- However, truncation of system metadata during large DDL may not be fully reversible.
-- Best practice: test DDL in a dev environment before running on production.

PRINT 'Module 09 SQL Server DDL — complete.';
GO
