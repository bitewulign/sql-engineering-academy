-- =============================================================
-- SQL Engineering Academy
-- Engine  : SQL Server 2022
-- Module  : 04 — Aggregating Data
-- File    : 04_aggregate.sql
-- Author  : SQL Engineering Academy
-- =============================================================

USE university;
GO

-- ----------------------------------------------------------------
-- SECTION 1: Basic aggregate functions
-- ----------------------------------------------------------------

SELECT COUNT(*) AS total_students FROM students;
GO

SELECT
    COUNT(*)        AS total_rows,
    COUNT(phone)    AS rows_with_phone,
    COUNT(*) - COUNT(phone) AS rows_without_phone
FROM students;
GO

SELECT
    COUNT(*)   AS total_students,
    SUM(gpa)   AS gpa_sum,
    AVG(gpa)   AS gpa_average,
    MIN(gpa)   AS lowest_gpa,
    MAX(gpa)   AS highest_gpa
FROM students;
GO

-- ----------------------------------------------------------------
-- SECTION 2: COUNT(DISTINCT col)
-- ----------------------------------------------------------------

SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;
GO

SELECT COUNT(DISTINCT YEAR(enrolled_at)) AS distinct_years FROM students;
GO

-- ----------------------------------------------------------------
-- SECTION 3: AVG and integer division (SQL Server caveat)
-- ----------------------------------------------------------------
-- SQL Server truncates AVG to integer when the column is INTEGER.
-- GPA is DECIMAL so this is fine here, but be aware with INT columns.

-- Demonstrate the problem with an integer column:
-- AVG(1 + 2 + 3 + 4) = 10/4 = 2 (truncated), not 2.5
SELECT AVG(CAST(1 AS INT)) AS bad_avg_int_example; -- placeholder

-- Safe pattern: always cast INTEGER columns before AVG
-- SELECT AVG(CAST(integer_col AS DECIMAL(10,2))) FROM table;

-- AVG with NULL: SQL Server also skips NULLs
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES (N'Test', N'NullGPA', N'test.nullgpa@example.com', '2024-09-01');

SELECT
    COUNT(*)    AS total_rows,
    COUNT(gpa)  AS rows_with_gpa,
    AVG(gpa)    AS avg_ignoring_null,
    AVG(COALESCE(gpa, 0.00)) AS avg_treating_null_as_zero
FROM students;

DELETE FROM students WHERE email = N'test.nullgpa@example.com';
GO

-- ----------------------------------------------------------------
-- SECTION 4: MIN and MAX on non-numeric types
-- ----------------------------------------------------------------

SELECT
    MIN(enrolled_at) AS first_enrollment,
    MAX(enrolled_at) AS most_recent_enrollment
FROM students;
GO

SELECT
    MIN(department_name) AS first_alpha,
    MAX(department_name) AS last_alpha
FROM departments;
GO

-- ----------------------------------------------------------------
-- SECTION 5: GROUP BY — single column
-- ----------------------------------------------------------------

SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
ORDER BY student_count DESC;
GO

SELECT
    department_id,
    COUNT(*)        AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa,
    MIN(gpa)        AS min_gpa,
    MAX(gpa)        AS max_gpa
FROM   students
GROUP BY department_id
ORDER BY avg_gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 6: GROUP BY — multiple columns
-- ----------------------------------------------------------------

SELECT
    department_id,
    YEAR(enrolled_at) AS enrollment_year,
    COUNT(*)          AS student_count
FROM   students
GROUP BY department_id, YEAR(enrolled_at)
ORDER BY department_id, enrollment_year;
GO

SELECT
    department_id,
    is_active,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id, is_active
ORDER BY department_id, is_active;
GO

-- ----------------------------------------------------------------
-- SECTION 7: HAVING
-- ----------------------------------------------------------------

SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
HAVING COUNT(*) > 1
ORDER BY student_count DESC;
GO

SELECT
    department_id,
    COUNT(*)           AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM   students
WHERE  is_active = 1
GROUP BY department_id
HAVING AVG(gpa) > 3.50
ORDER BY avg_gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 8: STRING_AGG (SQL Server 2017+)
-- ----------------------------------------------------------------
-- Note: WITHIN GROUP (ORDER BY ...) controls the order of concatenation

SELECT
    department_id,
    COUNT(*) AS student_count,
    STRING_AGG(last_name, N', ') WITHIN GROUP (ORDER BY last_name) AS student_last_names
FROM   students
GROUP BY department_id
ORDER BY department_id;
GO

-- ----------------------------------------------------------------
-- SECTION 9: ROLLUP — subtotals
-- ----------------------------------------------------------------

-- SQL Server uses WITH ROLLUP (same syntax as MySQL)
SELECT
    department_id,
    YEAR(enrolled_at) AS yr,
    COUNT(*)          AS student_count
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP
ORDER BY department_id, yr;
GO

-- Label the ROLLUP NULL rows using GROUPING()
SELECT
    CASE WHEN GROUPING(department_id)      = 1 THEN N'ALL DEPTS' ELSE CAST(department_id AS NVARCHAR(10)) END AS dept,
    CASE WHEN GROUPING(YEAR(enrolled_at))  = 1 THEN N'ALL YEARS' ELSE CAST(YEAR(enrolled_at) AS NVARCHAR(4)) END AS yr,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP;
GO

-- ----------------------------------------------------------------
-- SECTION 10: Combined query
-- ----------------------------------------------------------------

SELECT
    department_id,
    COUNT(*)                                                AS total_students,
    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END)         AS active_students,
    SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END)         AS inactive_students,
    ROUND(AVG(gpa), 2)                                      AS avg_gpa,
    MAX(gpa)                                                AS top_gpa,
    MIN(enrolled_at)                                        AS earliest_enroll
FROM   students
GROUP BY department_id
HAVING COUNT(*) >= 1
ORDER BY avg_gpa DESC;
GO
