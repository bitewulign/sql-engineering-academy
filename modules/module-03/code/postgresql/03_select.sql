-- ============================================================
-- SQL Engineering Academy
-- Engine:  PostgreSQL 16
-- Module:  03 — Querying Data
-- File:    03_select.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Prerequisites: Module 02 script must have been run first.
-- Connect: \c university  (psql) or select database in pgAdmin
-- ============================================================


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

-- 1.5  String concatenation — PostgreSQL uses || operator
SELECT
    first_name || ' ' || last_name AS full_name,
    email
FROM students;

-- Also works with CONCAT() (ANSI-compatible):
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name
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
WHERE  is_active = TRUE
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
   OR  (gpa >= 3.70 AND is_active = TRUE);


-- ────────────────────────────────────────────────────────────
-- SECTION 3: BETWEEN, IN, LIKE / ILIKE
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
WHERE  department_name IN ('Computer Science', 'Physics', 'Data Engineering');

-- 3.4  NOT IN
SELECT department_name
FROM   departments
WHERE  department_name NOT IN ('Mathematics', 'Physics');

-- 3.5  LIKE — case-sensitive in PostgreSQL
SELECT * FROM students WHERE last_name LIKE 'S%';     -- matches Sharma, not sharma

-- 3.6  ILIKE — case-insensitive (PostgreSQL-only)
SELECT * FROM students WHERE last_name ILIKE 's%';    -- matches Sharma AND sharma

-- 3.7  LIKE with underscore
SELECT * FROM students WHERE last_name LIKE '_r%';

-- 3.8  NOT ILIKE
SELECT * FROM students WHERE email NOT ILIKE '%@test%';


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
SELECT first_name FROM students WHERE phone = NULL;    -- returns 0 rows (WRONG)
SELECT first_name FROM students WHERE phone IS NULL;   -- correct

-- 4.4  IS NOT DISTINCT FROM — PostgreSQL's NULL-safe equality
-- Treats NULL = NULL as TRUE (useful in WHERE / JOIN conditions)
SELECT 1 WHERE NULL IS NOT DISTINCT FROM NULL;  -- returns 1 (TRUE)
SELECT 1 WHERE NULL = NULL;                     -- returns nothing (UNKNOWN)

-- 4.5  COALESCE
SELECT
    first_name,
    COALESCE(phone, 'Not provided') AS phone_display
FROM students;

-- 4.6  NULLIF — returns NULL if two values are equal (useful to avoid division by zero)
SELECT
    department_name,
    budget / NULLIF(budget, 0) AS ratio    -- avoids division by zero
FROM departments;


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
    first_name || ' ' || last_name AS full_name,
    gpa AS grade
FROM students
ORDER BY grade DESC;

-- 5.5  NULLS FIRST / NULLS LAST — PostgreSQL control over NULL position
SELECT first_name, phone FROM students ORDER BY phone ASC  NULLS LAST;
SELECT first_name, phone FROM students ORDER BY phone DESC NULLS FIRST;


-- ────────────────────────────────────────────────────────────
-- SECTION 6: LIMIT and OFFSET
-- ────────────────────────────────────────────────────────────

-- 6.1  Top 3 by GPA
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3;

-- 6.2  Pagination
-- Page 1
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3 OFFSET 0;

-- Page 2
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3 OFFSET 3;

-- 6.3  ANSI standard (also works in PostgreSQL 16)
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
OFFSET 3 ROWS
FETCH NEXT 3 ROWS ONLY;


-- ────────────────────────────────────────────────────────────
-- SECTION 7: DISTINCT
-- ────────────────────────────────────────────────────────────

-- 7.1  Unique buildings
SELECT DISTINCT building FROM departments ORDER BY building;

-- 7.2  Distinct boolean values present
SELECT DISTINCT is_active FROM students;

-- 7.3  Count distinct
SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;


-- ────────────────────────────────────────────────────────────
-- SECTION 8: CASE WHEN
-- ────────────────────────────────────────────────────────────

-- 8.1  Searched CASE
SELECT
    first_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.00 THEN 'Merit'
        WHEN gpa >= 2.00 THEN 'Pass'
        ELSE 'At Risk'
    END AS academic_standing
FROM students
ORDER BY gpa DESC;

-- 8.2  Simple CASE
SELECT
    department_name,
    CASE building
        WHEN 'Tech Hall'    THEN 'Technology'
        WHEN 'Science Wing' THEN 'Natural Sciences'
        ELSE 'Other'
    END AS faculty
FROM departments;

-- 8.3  CASE in ORDER BY (sort Distinction first)
SELECT first_name, gpa
FROM   students
ORDER BY
    CASE
        WHEN gpa >= 3.70 THEN 1
        WHEN gpa >= 3.00 THEN 2
        ELSE 3
    END, gpa DESC;


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
SELECT first_name FROM students WHERE enrolled_at <= CURRENT_DATE;

-- 9.4  Extract parts (PostgreSQL)
SELECT first_name, enrolled_at
FROM   students
WHERE  EXTRACT(YEAR FROM enrolled_at) = 2024;

-- 9.5  Date_trunc (truncate to month boundary)
SELECT
    DATE_TRUNC('month', enrolled_at) AS enrollment_month,
    COUNT(*) AS students
FROM   students
GROUP BY 1
ORDER BY 1;


-- ────────────────────────────────────────────────────────────
-- SECTION 10: Putting it all together
-- ────────────────────────────────────────────────────────────

SELECT
    first_name || ' ' || last_name AS student_name,
    email,
    gpa,
    enrolled_at,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.50 THEN 'Merit'
        ELSE 'Pass'
    END AS standing
FROM   students
WHERE  is_active = TRUE
  AND  gpa >= 3.50
  AND  enrolled_at >= '2024-01-01'
ORDER BY gpa DESC NULLS LAST
LIMIT 10;

-- ============================================================
-- END OF MODULE 03 — POSTGRESQL
-- Key PostgreSQL-specific points:
--   - || operator for string concatenation (also supports CONCAT())
--   - ILIKE for case-insensitive LIKE
--   - IS NOT DISTINCT FROM for NULL-safe equality
--   - NULLS FIRST / NULLS LAST in ORDER BY
--   - EXTRACT() and DATE_TRUNC() for date arithmetic
--   - CURRENT_DATE for today (ANSI standard)
-- ============================================================
