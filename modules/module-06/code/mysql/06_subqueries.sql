-- =============================================================
-- SQL Engineering Academy
-- Engine  : MySQL 8.0
-- Module  : 06 — Subqueries
-- File    : 06_subqueries.sql
-- Author  : SQL Engineering Academy
-- =============================================================

USE university;

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

-- Students with the maximum GPA in the school
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa = (SELECT MAX(gpa) FROM students);

-- ----------------------------------------------------------------
-- SECTION 2: Scalar subquery in SELECT
-- ----------------------------------------------------------------

-- Compare each student's GPA to the school average
SELECT
    first_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2)   AS school_avg,
    ROUND(gpa - (SELECT AVG(gpa) FROM students), 2) AS diff
FROM   students
ORDER BY diff DESC;

-- ----------------------------------------------------------------
-- SECTION 3: IN with subquery
-- ----------------------------------------------------------------

-- Students enrolled in at least one course (semi-join via IN)
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (
    SELECT DISTINCT student_id
    FROM   enrollments
)
ORDER BY last_name;

-- Students enrolled in courses belonging to the CS department
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

-- Demo: employees table with NULLs in manager_id
-- If manager_id contains NULL, NOT IN returns 0 rows

-- UNSAFE: will return 0 rows if any manager_id is NULL
SELECT first_name
FROM   employees
WHERE  employee_id NOT IN (SELECT manager_id FROM employees);

-- SAFE version 1: filter NULLs from the subquery
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
-- SECTION 5: EXISTS
-- ----------------------------------------------------------------

-- Students who have at least one enrollment
SELECT first_name, last_name
FROM   students s
WHERE  EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
);

-- Students with NO enrollments (anti-join via NOT EXISTS)
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

-- For each student, count their enrolled courses (correlated)
SELECT
    s.first_name,
    s.last_name,
    (SELECT COUNT(*)
     FROM   enrollments e
     WHERE  e.student_id = s.student_id) AS course_count
FROM   students s
ORDER BY course_count DESC;

-- Students whose GPA is above their department's average
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

-- Departments with more students than the average department size
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

-- Average GPA per department, then filter to above school average
SELECT dept_stats.department_name, dept_stats.avg_gpa
FROM (
    SELECT
        d.department_name,
        ROUND(AVG(s.gpa), 2) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
) AS dept_stats
WHERE dept_stats.avg_gpa > (SELECT AVG(gpa) FROM students)
ORDER BY dept_stats.avg_gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 9: Common Table Expression (CTE) — MySQL 8.0+
-- ----------------------------------------------------------------

-- Rewrite Section 8 as a CTE
WITH dept_stats AS (
    SELECT
        d.department_name,
        ROUND(AVG(s.gpa), 2) AS avg_gpa
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
    SELECT * FROM students WHERE is_active = 1
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

-- ----------------------------------------------------------------
-- SECTION 10: Subquery vs JOIN comparison
-- ----------------------------------------------------------------

-- Semi-join: students who have at least one enrollment
-- Version A: IN subquery
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (SELECT student_id FROM enrollments);

-- Version B: EXISTS
SELECT first_name, last_name
FROM   students s
WHERE  EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id);

-- Version C: JOIN + DISTINCT (produces same result)
SELECT DISTINCT s.first_name, s.last_name
FROM   students    s
JOIN   enrollments e ON e.student_id = s.student_id;

-- All three produce the same result. The optimizer typically uses similar plans.
