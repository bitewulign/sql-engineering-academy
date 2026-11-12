-- =============================================================
-- SQL Engineering Academy
-- Engine  : PostgreSQL 16
-- Module  : 06 — Subqueries
-- File    : 06_subqueries.sql
-- Author  : SQL Engineering Academy
-- =============================================================

\c university

-- ----------------------------------------------------------------
-- SECTION 1: Scalar subquery in WHERE
-- ----------------------------------------------------------------

-- Students with GPA above the school average
SELECT
    first_name,
    last_name,
    gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students)
ORDER BY gpa DESC;

-- Students with the highest GPA
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa = (SELECT MAX(gpa) FROM students);

-- ----------------------------------------------------------------
-- SECTION 2: Scalar subquery in SELECT
-- ----------------------------------------------------------------

-- PostgreSQL: AVG returns NUMERIC for numeric columns; ROUND works directly
SELECT
    first_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students)::NUMERIC, 2)        AS school_avg,
    ROUND((gpa - (SELECT AVG(gpa) FROM students))::NUMERIC, 2) AS diff
FROM   students
ORDER BY diff DESC;

-- ----------------------------------------------------------------
-- SECTION 3: IN with subquery
-- ----------------------------------------------------------------

-- Students with at least one enrollment
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (
    SELECT DISTINCT student_id FROM enrollments
)
ORDER BY last_name;

-- Students enrolled in CS courses
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (
    SELECT e.student_id
    FROM   enrollments e
    JOIN   courses     c ON c.course_id = e.course_id
    WHERE  c.department_code = 'CS'
)
ORDER BY last_name;

-- ----------------------------------------------------------------
-- SECTION 4: NOT IN — and the NULL trap
-- ----------------------------------------------------------------

-- UNSAFE: returns 0 rows when manager_id column contains NULLs
SELECT first_name
FROM   employees
WHERE  employee_id NOT IN (SELECT manager_id FROM employees);

-- SAFE version 1: filter NULLs
SELECT first_name
FROM   employees
WHERE  employee_id NOT IN (
    SELECT manager_id FROM employees WHERE manager_id IS NOT NULL
);

-- SAFE version 2: NOT EXISTS (preferred)
SELECT e.first_name
FROM   employees e
WHERE  NOT EXISTS (
    SELECT 1 FROM employees m WHERE m.manager_id = e.employee_id
);

-- ----------------------------------------------------------------
-- SECTION 5: EXISTS / NOT EXISTS
-- ----------------------------------------------------------------

-- Students with at least one enrollment
SELECT first_name, last_name
FROM   students s
WHERE  EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
);

-- Students with no enrollments
SELECT first_name, last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
);

-- ----------------------------------------------------------------
-- SECTION 6: Correlated subquery
-- ----------------------------------------------------------------

-- Per-student course count (correlated)
SELECT
    s.first_name,
    s.last_name,
    (SELECT COUNT(*)
     FROM   enrollments e
     WHERE  e.student_id = s.student_id) AS course_count
FROM   students s
ORDER BY course_count DESC;

-- Students above their own department's average GPA
SELECT s.first_name, s.last_name, s.gpa, s.department_id
FROM   students s
WHERE  s.gpa > (
    SELECT AVG(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = s.department_id
)
ORDER BY s.department_id, s.gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 7: Subquery in HAVING
-- ----------------------------------------------------------------

SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.student_id) > (
    SELECT AVG(dept_count)
    FROM (
        SELECT COUNT(student_id) AS dept_count
        FROM   students
        GROUP BY department_id
    ) AS dept_sizes
)
ORDER BY student_count DESC;

-- ----------------------------------------------------------------
-- SECTION 8: Derived table (subquery in FROM)
-- ----------------------------------------------------------------

SELECT dept_stats.department_name, dept_stats.avg_gpa
FROM (
    SELECT
        d.department_name,
        ROUND(AVG(s.gpa)::NUMERIC, 2) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
) AS dept_stats
WHERE dept_stats.avg_gpa > (SELECT AVG(gpa) FROM students)
ORDER BY dept_stats.avg_gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 9: CTE (WITH)
-- ----------------------------------------------------------------

WITH dept_stats AS (
    SELECT
        d.department_name,
        ROUND(AVG(s.gpa)::NUMERIC, 2) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
)
SELECT department_name, avg_gpa
FROM   dept_stats
WHERE  avg_gpa > (SELECT AVG(gpa) FROM students)
ORDER BY avg_gpa DESC;

-- Multiple CTEs
WITH
active_students AS (
    SELECT * FROM students WHERE is_active = TRUE
),
active_per_dept AS (
    SELECT department_id, COUNT(*) AS active_count
    FROM   active_students
    GROUP BY department_id
)
SELECT
    d.department_name,
    COALESCE(a.active_count, 0) AS active_students
FROM   departments    d
LEFT JOIN active_per_dept a ON a.department_id = d.department_id
ORDER BY active_students DESC;

-- PostgreSQL CTE materialization hint (PostgreSQL 12+)
-- By default CTEs may be inlined (treated as derived tables).
-- MATERIALIZED forces the CTE to run once and cache its result.
WITH top_students AS MATERIALIZED (
    SELECT student_id, first_name, gpa
    FROM   students
    WHERE  gpa >= 3.80
)
SELECT ts.first_name, d.department_name
FROM   top_students  ts
JOIN   students      s  ON s.student_id    = ts.student_id
JOIN   departments   d  ON d.department_id = s.department_id;

-- ----------------------------------------------------------------
-- SECTION 10: Subquery vs JOIN
-- ----------------------------------------------------------------

-- Students with at least one enrollment — three equivalent forms
-- A: IN
SELECT first_name, last_name FROM students
WHERE  student_id IN (SELECT student_id FROM enrollments);

-- B: EXISTS
SELECT first_name, last_name FROM students s
WHERE  EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id);

-- C: JOIN + DISTINCT
SELECT DISTINCT s.first_name, s.last_name
FROM   students s JOIN enrollments e ON e.student_id = s.student_id;
