-- =============================================================
-- SQL Engineering Academy
-- Engine  : MySQL 8.0
-- Module  : 04 — Aggregating Data
-- File    : 04_aggregate.sql
-- Author  : SQL Engineering Academy
-- =============================================================

USE university;

-- ----------------------------------------------------------------
-- SECTION 1: Basic aggregate functions
-- ----------------------------------------------------------------

-- Count all rows
SELECT COUNT(*) AS total_students FROM students;

-- Count non-NULL values vs all rows
SELECT
    COUNT(*)        AS total_rows,
    COUNT(phone)    AS rows_with_phone,
    COUNT(*)  - COUNT(phone) AS rows_without_phone
FROM students;

-- All five aggregate functions on GPA
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

-- How many unique buildings?
SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;

-- How many distinct enrollment years?
SELECT COUNT(DISTINCT YEAR(enrolled_at)) AS distinct_years FROM students;

-- ----------------------------------------------------------------
-- SECTION 3: AVG and NULL treatment
-- ----------------------------------------------------------------

-- AVG ignores NULLs — this demonstrates the difference
-- Insert a student with NULL GPA for testing
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Test', 'NullGPA', 'test.nullgpa@example.com', '2024-09-01');

SELECT
    COUNT(*)    AS total_rows,
    COUNT(gpa)  AS rows_with_gpa,
    AVG(gpa)    AS avg_ignoring_null,
    AVG(COALESCE(gpa, 0.00)) AS avg_treating_null_as_zero
FROM students;

-- Clean up
DELETE FROM students WHERE email = 'test.nullgpa@example.com';

-- ----------------------------------------------------------------
-- SECTION 4: MIN and MAX on non-numeric types
-- ----------------------------------------------------------------

-- Date range
SELECT
    MIN(enrolled_at) AS first_enrollment,
    MAX(enrolled_at) AS most_recent_enrollment
FROM students;

-- Alphabetical first and last
SELECT
    MIN(department_name) AS first_alpha,
    MAX(department_name) AS last_alpha
FROM departments;

-- ----------------------------------------------------------------
-- SECTION 5: GROUP BY — single column
-- ----------------------------------------------------------------

-- Student count per department
SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
ORDER BY student_count DESC;

-- Average GPA per department
SELECT
    department_id,
    COUNT(*)   AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa,
    MIN(gpa)   AS min_gpa,
    MAX(gpa)   AS max_gpa
FROM   students
GROUP BY department_id
ORDER BY avg_gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 6: GROUP BY — multiple columns
-- ----------------------------------------------------------------

-- Students per department per enrollment year
SELECT
    department_id,
    YEAR(enrolled_at) AS enrollment_year,
    COUNT(*)          AS student_count
FROM   students
GROUP BY department_id, YEAR(enrolled_at)
ORDER BY department_id, enrollment_year;

-- Active vs inactive count per department
SELECT
    department_id,
    is_active,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id, is_active
ORDER BY department_id, is_active;

-- ----------------------------------------------------------------
-- SECTION 7: HAVING — filter groups after aggregation
-- ----------------------------------------------------------------

-- Only departments with more than 1 student
SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
HAVING COUNT(*) > 1
ORDER BY student_count DESC;

-- Departments where average GPA exceeds 3.50 (active students only)
SELECT
    department_id,
    COUNT(*)           AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM   students
WHERE  is_active = 1
GROUP BY department_id
HAVING AVG(gpa) > 3.50
ORDER BY avg_gpa DESC;

-- WHERE vs HAVING contrast:
-- WHERE  filters rows   BEFORE grouping
-- HAVING filters groups AFTER  grouping

-- ----------------------------------------------------------------
-- SECTION 8: GROUP_CONCAT (MySQL-specific)
-- ----------------------------------------------------------------

-- List student last names per department as a comma-separated string
SELECT
    department_id,
    COUNT(*) AS student_count,
    GROUP_CONCAT(last_name ORDER BY last_name SEPARATOR ', ') AS student_last_names
FROM   students
GROUP BY department_id
ORDER BY department_id;

-- ----------------------------------------------------------------
-- SECTION 9: ROLLUP — subtotals and grand total
-- ----------------------------------------------------------------

-- Students per department per year with subtotals
SELECT
    department_id,
    YEAR(enrolled_at) AS yr,
    COUNT(*)          AS student_count
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP
ORDER BY department_id, yr;

-- GROUPING() returns 1 for the NULL rows added by ROLLUP
SELECT
    CASE WHEN GROUPING(department_id) = 1 THEN 'ALL DEPTS'
         ELSE CAST(department_id AS CHAR) END AS dept,
    CASE WHEN GROUPING(YEAR(enrolled_at)) = 1 THEN 'ALL YEARS'
         ELSE CAST(YEAR(enrolled_at) AS CHAR) END AS yr,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP;

-- ----------------------------------------------------------------
-- SECTION 10: Combined query — full aggregation example
-- ----------------------------------------------------------------

SELECT
    department_id,
    COUNT(*)                                            AS total_students,
    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END)     AS active_students,
    SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END)     AS inactive_students,
    ROUND(AVG(gpa), 2)                                  AS avg_gpa,
    MAX(gpa)                                            AS top_gpa,
    MIN(enrolled_at)                                    AS earliest_enroll
FROM   students
GROUP BY department_id
HAVING COUNT(*) >= 1
ORDER BY avg_gpa DESC;
