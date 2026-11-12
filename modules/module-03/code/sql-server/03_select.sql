-- ============================================================
-- SQL Engineering Academy
-- Engine:  Microsoft SQL Server 2022
-- Module:  03 — Querying Data
-- File:    03_select.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Prerequisites: Module 02 script must have been run first.
-- Connect: localhost,1433  User: SA
-- ============================================================

USE university;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 1: Basic SELECT
-- ────────────────────────────────────────────────────────────

-- 1.1  All columns
SELECT * FROM students;

-- 1.2  Specific columns
SELECT student_id, first_name, last_name, gpa FROM students;

-- 1.3  Column aliases
SELECT
    first_name  AS given_name,
    last_name   AS family_name,
    gpa         AS grade_point_average
FROM students;

-- 1.4  Computed column
SELECT
    first_name,
    last_name,
    gpa,
    gpa * 25 AS gpa_as_percent
FROM students;

-- 1.5  String concatenation — SQL Server uses + operator for NVARCHAR
SELECT
    first_name + N' ' + last_name AS full_name,
    email
FROM students;

-- Also supports CONCAT() (NULL-safe — treats NULL as empty string):
SELECT
    CONCAT(first_name, N' ', last_name) AS full_name
FROM students;
-- Note: + concatenation propagates NULL; CONCAT() does not.
-- 'Amara' + NULL + 'Osei' = NULL
-- CONCAT('Amara', NULL, 'Osei') = 'AmaraOsei'
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 2: WHERE — comparison operators
-- ────────────────────────────────────────────────────────────

-- 2.1  Exact match
SELECT * FROM students WHERE gpa = 3.80;

-- 2.2  Greater than
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > 3.70;

-- 2.3  Not equal
SELECT department_name, budget
FROM   departments
WHERE  building <> N'Tech Hall';

-- 2.4  AND
SELECT first_name, last_name, gpa, is_active
FROM   students
WHERE  is_active = 1
  AND  gpa >= 3.80;

-- 2.5  OR
SELECT department_name, building
FROM   departments
WHERE  building = N'Tech Hall'
   OR  building = N'Science Wing';

-- 2.6  NOT
SELECT first_name, last_name
FROM   students
WHERE  NOT (gpa < 3.50);

-- 2.7  Parentheses for clarity
SELECT *
FROM   students
WHERE  gpa >= 3.90
   OR  (gpa >= 3.70 AND is_active = 1);
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 3: BETWEEN, IN, LIKE
-- ────────────────────────────────────────────────────────────

-- 3.1  BETWEEN (inclusive)
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa BETWEEN 3.50 AND 3.80;

-- 3.2  Date range
SELECT first_name, enrolled_at
FROM   students
WHERE  enrolled_at BETWEEN '2024-01-01' AND '2024-12-31';

-- 3.3  IN
SELECT department_name, budget
FROM   departments
WHERE  department_name IN (N'Computer Science', N'Physics', N'Data Engineering');

-- 3.4  NOT IN
SELECT department_name
FROM   departments
WHERE  department_name NOT IN (N'Mathematics', N'Physics');

-- 3.5  LIKE
SELECT * FROM students WHERE last_name LIKE N'S%';

-- 3.6  LIKE contains
SELECT * FROM students WHERE email LIKE N'%@example.com';

-- 3.7  Single-character wildcard
SELECT * FROM students WHERE last_name LIKE N'_r%';

-- 3.8  NOT LIKE
SELECT * FROM students WHERE email NOT LIKE N'%@test%';

-- 3.9  SQL Server LIKE is case-insensitive with the default collation
SELECT * FROM students WHERE last_name LIKE N'osei';  -- matches Osei
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 4: NULL handling
-- ────────────────────────────────────────────────────────────

-- 4.1  IS NULL
SELECT first_name, last_name, phone
FROM   students
WHERE  phone IS NULL;

-- 4.2  IS NOT NULL
SELECT first_name, last_name, phone
FROM   students
WHERE  phone IS NOT NULL;

-- 4.3  NULL comparison trap
SELECT first_name FROM students WHERE phone = NULL;    -- 0 rows (wrong)
SELECT first_name FROM students WHERE phone IS NULL;   -- correct

-- 4.4  SQL Server: SET ANSI_NULLS OFF (never do this in production)
-- With ANSI_NULLS OFF: WHERE phone = NULL works — but it's non-standard
-- Default is ANSI_NULLS ON, which enforces IS NULL

-- 4.5  COALESCE
SELECT
    first_name,
    COALESCE(phone, N'Not provided') AS phone_display
FROM students;

-- 4.6  ISNULL — SQL Server 2-arg shorthand for COALESCE
SELECT
    first_name,
    ISNULL(phone, N'Not provided') AS phone_display
FROM students;
-- ISNULL is SQL Server-specific; COALESCE is ANSI standard — prefer COALESCE

-- 4.7  NULLIF
SELECT
    department_name,
    NULLIF(building, N'Unknown') AS building_display  -- returns NULL if 'Unknown'
FROM departments;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 5: ORDER BY
-- ────────────────────────────────────────────────────────────

-- 5.1  Ascending
SELECT first_name, last_name, gpa FROM students ORDER BY last_name;

-- 5.2  Descending
SELECT first_name, last_name, gpa FROM students ORDER BY gpa DESC;

-- 5.3  Multi-column
SELECT first_name, last_name, gpa, enrolled_at
FROM   students
ORDER BY enrolled_at DESC, gpa DESC;

-- 5.4  Order by alias
SELECT
    first_name + N' ' + last_name AS full_name,
    gpa AS grade
FROM students
ORDER BY grade DESC;

-- 5.5  NULLs: SQL Server sorts NULLs first in ASC by default
-- To sort NULLs last, use a CASE expression:
SELECT first_name, phone
FROM   students
ORDER BY
    CASE WHEN phone IS NULL THEN 1 ELSE 0 END,
    phone ASC;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 6: TOP and FETCH
-- ────────────────────────────────────────────────────────────

-- 6.1  TOP N — SQL Server-specific
SELECT TOP 3 first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC;

-- 6.2  TOP N WITH TIES — include all rows tied at the boundary
SELECT TOP 3 WITH TIES first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC;

-- 6.3  TOP with PERCENT
SELECT TOP 50 PERCENT first_name, gpa
FROM   students
ORDER BY gpa DESC;

-- 6.4  OFFSET … FETCH (ANSI SQL:2008 — works in SQL Server 2012+)
-- Page 1 (rows 1-3)
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
OFFSET 0 ROWS
FETCH NEXT 3 ROWS ONLY;

-- Page 2 (rows 4-6)
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
OFFSET 3 ROWS
FETCH NEXT 3 ROWS ONLY;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 7: DISTINCT
-- ────────────────────────────────────────────────────────────

-- 7.1  Unique buildings
SELECT DISTINCT building FROM departments ORDER BY building;

-- 7.2  Distinct BIT values
SELECT DISTINCT is_active FROM students;

-- 7.3  Count distinct
SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 8: CASE WHEN
-- ────────────────────────────────────────────────────────────

-- 8.1  Searched CASE
SELECT
    first_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN N'Distinction'
        WHEN gpa >= 3.00 THEN N'Merit'
        WHEN gpa >= 2.00 THEN N'Pass'
        ELSE N'At Risk'
    END AS academic_standing
FROM students
ORDER BY gpa DESC;

-- 8.2  Simple CASE
SELECT
    department_name,
    CASE building
        WHEN N'Tech Hall'    THEN N'Technology'
        WHEN N'Science Wing' THEN N'Natural Sciences'
        ELSE N'Other'
    END AS faculty
FROM departments;

-- 8.3  IIF — SQL Server shorthand for two-branch CASE
SELECT
    first_name,
    is_active,
    IIF(is_active = 1, N'Active', N'Inactive') AS status
FROM students;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 9: Filtering dates
-- ────────────────────────────────────────────────────────────

-- 9.1  Exact date
SELECT * FROM students WHERE enrolled_at = '2024-09-01';

-- 9.2  Open range
SELECT first_name, enrolled_at
FROM   students
WHERE  enrolled_at >= '2024-01-01'
  AND  enrolled_at <  '2025-01-01';

-- 9.3  Current date
SELECT first_name FROM students WHERE enrolled_at <= CAST(GETDATE() AS DATE);
-- Or: WHERE enrolled_at <= CONVERT(DATE, GETDATE())

-- 9.4  YEAR() / MONTH() / DAY()
SELECT first_name, enrolled_at
FROM   students
WHERE  YEAR(enrolled_at) = 2024;

-- 9.5  DATEPART
SELECT first_name, enrolled_at
FROM   students
WHERE  DATEPART(YEAR, enrolled_at) = 2024
  AND  DATEPART(MONTH, enrolled_at) = 9;
GO


-- ────────────────────────────────────────────────────────────
-- SECTION 10: Putting it all together
-- ────────────────────────────────────────────────────────────

SELECT TOP 10
    first_name + N' ' + last_name AS student_name,
    email,
    gpa,
    enrolled_at,
    CASE
        WHEN gpa >= 3.70 THEN N'Distinction'
        WHEN gpa >= 3.50 THEN N'Merit'
        ELSE N'Pass'
    END AS standing
FROM   students
WHERE  is_active = 1
  AND  gpa >= 3.50
  AND  enrolled_at >= '2024-01-01'
ORDER BY gpa DESC;
GO

-- ============================================================
-- END OF MODULE 03 — SQL SERVER
-- Key SQL Server-specific points:
--   - + operator for NVARCHAR concatenation (use CONCAT() for NULL safety)
--   - ISNULL() as 2-arg shorthand for COALESCE (prefer COALESCE for portability)
--   - TOP n / TOP n WITH TIES / TOP n PERCENT instead of LIMIT
--   - OFFSET … FETCH for pagination (ANSI standard)
--   - IIF() as a 2-branch CASE shorthand
--   - GETDATE() for current datetime; CAST(GETDATE() AS DATE) for today's date
--   - YEAR() / MONTH() / DATEPART() for date extraction
--   - NULLs sort first in ASC; use CASE trick to push them last
-- ============================================================
