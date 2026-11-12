-- =============================================================
-- SQL Engineering Academy
-- Engine  : PostgreSQL 16
-- Module  : 04 — Aggregating Data
-- File    : 04_aggregate.sql
-- Author  : SQL Engineering Academy
-- =============================================================

\c university

-- ----------------------------------------------------------------
-- SECTION 1: Basic aggregate functions
-- ----------------------------------------------------------------

SELECT COUNT(*) AS total_students FROM students;

SELECT
    COUNT(*)        AS total_rows,
    COUNT(phone)    AS rows_with_phone,
    COUNT(*) - COUNT(phone) AS rows_without_phone
FROM students;

SELECT
    COUNT(*)   AS total_students,
    SUM(gpa)   AS gpa_sum,
    AVG(gpa)   AS gpa_average,
    MIN(gpa)   AS lowest_gpa,
    MAX(gpa)   AS highest_gpa
FROM students;

-- ----------------------------------------------------------------
-- SECTION 2: COUNT(DISTINCT col)
-- ----------------------------------------------------------------

SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;

SELECT COUNT(DISTINCT EXTRACT(YEAR FROM enrolled_at)) AS distinct_years FROM students;

-- ----------------------------------------------------------------
-- SECTION 3: AVG and NULL treatment
-- ----------------------------------------------------------------

INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Test', 'NullGPA', 'test.nullgpa@example.com', '2024-09-01');

SELECT
    COUNT(*)    AS total_rows,
    COUNT(gpa)  AS rows_with_gpa,
    AVG(gpa)    AS avg_ignoring_null,
    AVG(COALESCE(gpa, 0.00)) AS avg_treating_null_as_zero
FROM students;

DELETE FROM students WHERE email = 'test.nullgpa@example.com';

-- ----------------------------------------------------------------
-- SECTION 4: MIN and MAX on non-numeric types
-- ----------------------------------------------------------------

SELECT
    MIN(enrolled_at) AS first_enrollment,
    MAX(enrolled_at) AS most_recent_enrollment
FROM students;

SELECT
    MIN(department_name) AS first_alpha,
    MAX(department_name) AS last_alpha
FROM departments;

-- ----------------------------------------------------------------
-- SECTION 5: GROUP BY — single column
-- ----------------------------------------------------------------

SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
ORDER BY student_count DESC;

SELECT
    department_id,
    COUNT(*)                     AS students,
    ROUND(AVG(gpa)::NUMERIC, 2)  AS avg_gpa,
    MIN(gpa)                     AS min_gpa,
    MAX(gpa)                     AS max_gpa
FROM   students
GROUP BY department_id
ORDER BY avg_gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 6: GROUP BY — multiple columns
-- ----------------------------------------------------------------

SELECT
    department_id,
    EXTRACT(YEAR FROM enrolled_at) AS enrollment_year,
    COUNT(*)                       AS student_count
FROM   students
GROUP BY department_id, EXTRACT(YEAR FROM enrolled_at)
ORDER BY department_id, enrollment_year;

SELECT
    department_id,
    is_active,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id, is_active
ORDER BY department_id, is_active;

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

SELECT
    department_id,
    COUNT(*)                    AS students,
    ROUND(AVG(gpa)::NUMERIC, 2) AS avg_gpa
FROM   students
WHERE  is_active = TRUE
GROUP BY department_id
HAVING AVG(gpa) > 3.50
ORDER BY avg_gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 8: STRING_AGG (PostgreSQL equivalent of GROUP_CONCAT)
-- ----------------------------------------------------------------

SELECT
    department_id,
    COUNT(*) AS student_count,
    STRING_AGG(last_name, ', ' ORDER BY last_name) AS student_last_names
FROM   students
GROUP BY department_id
ORDER BY department_id;

-- ----------------------------------------------------------------
-- SECTION 9: ROLLUP (PostgreSQL syntax)
-- ----------------------------------------------------------------

-- PostgreSQL uses ROLLUP() as a function argument, not WITH ROLLUP
SELECT
    department_id,
    EXTRACT(YEAR FROM enrolled_at) AS yr,
    COUNT(*)                       AS student_count
FROM   students
GROUP BY ROLLUP(department_id, EXTRACT(YEAR FROM enrolled_at))
ORDER BY department_id NULLS LAST, yr NULLS LAST;

-- Use GROUPING() to label the synthetic NULL rows
SELECT
    CASE WHEN GROUPING(department_id) = 1 THEN 'ALL DEPTS'
         ELSE department_id::TEXT END AS dept,
    CASE WHEN GROUPING(EXTRACT(YEAR FROM enrolled_at)) = 1 THEN 'ALL YEARS'
         ELSE EXTRACT(YEAR FROM enrolled_at)::TEXT END AS yr,
    COUNT(*) AS student_count
FROM   students
GROUP BY ROLLUP(department_id, EXTRACT(YEAR FROM enrolled_at));

-- ----------------------------------------------------------------
-- SECTION 10: Combined query
-- ----------------------------------------------------------------

SELECT
    department_id,
    COUNT(*)                                                    AS total_students,
    SUM(CASE WHEN is_active = TRUE  THEN 1 ELSE 0 END)         AS active_students,
    SUM(CASE WHEN is_active = FALSE THEN 1 ELSE 0 END)         AS inactive_students,
    ROUND(AVG(gpa)::NUMERIC, 2)                                 AS avg_gpa,
    MAX(gpa)                                                    AS top_gpa,
    MIN(enrolled_at)                                            AS earliest_enroll
FROM   students
GROUP BY department_id
HAVING COUNT(*) >= 1
ORDER BY avg_gpa DESC;
