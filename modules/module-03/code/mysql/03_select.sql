-- ============================================================
-- SQL Engineering Academy
-- Engine:  MySQL 8.0
-- Module:  03 — Querying Data
-- File:    03_select.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Prerequisites: Module 02 script must have been run first.
-- USE university; before running this script.
-- ============================================================

USE university;

-- ────────────────────────────────────────────────────────────
-- SECTION 1: Basic SELECT
-- ────────────────────────────────────────────────────────────

-- 1.1  All columns (exploration only)
SELECT * FROM students;

-- 1.2  Specific columns
SELECT student_id, first_name, last_name, gpa
FROM   students;

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
    gpa * 25 AS gpa_as_percent   -- scale 4.0 → 100
FROM students;

-- 1.5  String concatenation
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    email
FROM students;


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
WHERE  building <> 'Tech Hall';

-- 2.4  AND
SELECT first_name, last_name, gpa, is_active
FROM   students
WHERE  is_active = 1
  AND  gpa >= 3.80;

-- 2.5  OR
SELECT department_name, building
FROM   departments
WHERE  building = 'Tech Hall'
   OR  building = 'Science Wing';

-- 2.6  NOT
SELECT first_name, last_name
FROM   students
WHERE  NOT (gpa < 3.50);

-- 2.7  Parentheses for clarity
SELECT *
FROM   students
WHERE  gpa >= 3.90
   OR  (gpa >= 3.70 AND is_active = 1);


-- ────────────────────────────────────────────────────────────
-- SECTION 3: BETWEEN, IN, LIKE
-- ────────────────────────────────────────────────────────────

-- 3.1  BETWEEN (inclusive)
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa BETWEEN 3.50 AND 3.80;

-- 3.2  Date range with BETWEEN
SELECT first_name, enrolled_at
FROM   students
WHERE  enrolled_at BETWEEN '2024-01-01' AND '2024-12-31';

-- 3.3  IN
SELECT department_name, budget
FROM   departments
WHERE  department_name IN ('Computer Science', 'Physics', 'Data Engineering');

-- 3.4  NOT IN
SELECT department_name
FROM   departments
WHERE  department_name NOT IN ('Mathematics', 'Physics');

-- 3.5  LIKE — starts with
SELECT * FROM students WHERE last_name LIKE 'S%';

-- 3.6  LIKE — contains
SELECT * FROM students WHERE email LIKE '%@example.com';

-- 3.7  LIKE — single-character wildcard
SELECT * FROM students WHERE last_name LIKE '_r%';  -- e.g. Eriksson

-- 3.8  NOT LIKE
SELECT * FROM students WHERE email NOT LIKE '%@test%';

-- 3.9  MySQL LIKE is case-insensitive by default (utf8mb4_unicode_ci)
SELECT * FROM students WHERE last_name LIKE 'osei';  -- matches Osei


-- ────────────────────────────────────────────────────────────
-- SECTION 4: NULL handling
-- ────────────────────────────────────────────────────────────

-- 4.1  IS NULL — find students with no phone on record
SELECT first_name, last_name, phone
FROM   students
WHERE  phone IS NULL;

-- 4.2  IS NOT NULL
SELECT first_name, last_name, phone
FROM   students
WHERE  phone IS NOT NULL;

-- 4.3  NULL comparison trap — this returns 0 rows, not matching NULLs
SELECT first_name FROM students WHERE phone = NULL;    -- never correct
SELECT first_name FROM students WHERE phone IS NULL;   -- correct

-- 4.4  MySQL NULL-safe equality operator (unique to MySQL)
-- <=> returns TRUE if both sides are NULL or both are equal
SELECT 1 WHERE NULL <=> NULL;    -- returns 1 (TRUE)
SELECT 1 WHERE NULL = NULL;      -- returns nothing (UNKNOWN)

-- 4.5  COALESCE — return first non-NULL value
SELECT
    first_name,
    COALESCE(phone, 'Not provided') AS phone_display
FROM students;

-- 4.6  IFNULL — MySQL-specific alias for COALESCE with 2 args
SELECT
    first_name,
    IFNULL(phone, 'Not provided') AS phone_display
FROM students;


-- ────────────────────────────────────────────────────────────
-- SECTION 5: ORDER BY
-- ────────────────────────────────────────────────────────────

-- 5.1  Simple ascending (default)
SELECT first_name, last_name, gpa
FROM   students
ORDER BY last_name;

-- 5.2  Descending
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC;

-- 5.3  Multi-column sort
SELECT first_name, last_name, gpa, enrolled_at
FROM   students
ORDER BY enrolled_at DESC, gpa DESC;

-- 5.4  Order by alias
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    gpa AS grade
FROM students
ORDER BY grade DESC;

-- 5.5  MySQL NULLs sort first in ASC
SELECT first_name, phone
FROM   students
ORDER BY phone ASC;    -- NULLs appear first


-- ────────────────────────────────────────────────────────────
-- SECTION 6: LIMIT and OFFSET
-- ────────────────────────────────────────────────────────────

-- 6.1  Top 3 by GPA
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3;

-- 6.2  OFFSET for pagination
-- Page 1: rows 1–3
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3 OFFSET 0;

-- Page 2: rows 4–6
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3 OFFSET 3;

-- 6.3  Shorthand: LIMIT offset, count (MySQL-specific, avoid in new code)
SELECT first_name, gpa FROM students ORDER BY gpa DESC LIMIT 3, 3;


-- ────────────────────────────────────────────────────────────
-- SECTION 7: DISTINCT
-- ────────────────────────────────────────────────────────────

-- 7.1  Unique buildings
SELECT DISTINCT building FROM departments ORDER BY building;

-- 7.2  Distinct combination
SELECT DISTINCT is_active FROM students;

-- 7.3  Count distinct (preview of aggregation)
SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;


-- ────────────────────────────────────────────────────────────
-- SECTION 8: CASE WHEN
-- ────────────────────────────────────────────────────────────

-- 8.1  Computed label
SELECT
    first_name,
    last_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.00 THEN 'Merit'
        WHEN gpa >= 2.00 THEN 'Pass'
        ELSE 'At Risk'
    END AS academic_standing
FROM students
ORDER BY gpa DESC;

-- 8.2  Simple CASE (matches a value, not a condition)
SELECT
    department_name,
    CASE building
        WHEN 'Tech Hall'    THEN 'Technology'
        WHEN 'Science Wing' THEN 'Natural Sciences'
        ELSE 'Other'
    END AS faculty
FROM departments;


-- ────────────────────────────────────────────────────────────
-- SECTION 9: Filtering dates
-- ────────────────────────────────────────────────────────────

-- 9.1  Exact date
SELECT * FROM students WHERE enrolled_at = '2024-09-01';

-- 9.2  Open range (safer than BETWEEN for dates)
SELECT first_name, enrolled_at
FROM   students
WHERE  enrolled_at >= '2024-01-01'
  AND  enrolled_at <  '2025-01-01';

-- 9.3  Current date
SELECT first_name, enrolled_at
FROM   students
WHERE  enrolled_at <= CURDATE();

-- 9.4  Extract year (MySQL function)
SELECT first_name, enrolled_at
FROM   students
WHERE  YEAR(enrolled_at) = 2024;


-- ────────────────────────────────────────────────────────────
-- SECTION 10: Putting it all together
-- ────────────────────────────────────────────────────────────

-- Active students with GPA ≥ 3.50 enrolled in 2024, sorted by GPA
SELECT
    CONCAT(first_name, ' ', last_name) AS student_name,
    email,
    gpa,
    enrolled_at,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.50 THEN 'Merit'
        ELSE 'Pass'
    END AS standing
FROM   students
WHERE  is_active = 1
  AND  gpa >= 3.50
  AND  enrolled_at >= '2024-01-01'
ORDER BY gpa DESC
LIMIT 10;

-- ============================================================
-- END OF MODULE 03 — MYSQL
-- Key MySQL-specific points:
--   - CONCAT() for string concatenation (not || operator)
--   - IFNULL() as a 2-arg shorthand for COALESCE
--   - LIKE is case-insensitive by default with utf8mb4_unicode_ci
--   - <=> operator for NULL-safe equality
--   - CURDATE() for today's date
--   - YEAR() / MONTH() / DAY() for date parts
--   - NULLs sort first in ASC order
-- ============================================================
