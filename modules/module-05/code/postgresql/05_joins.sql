-- =============================================================
-- SQL Engineering Academy
-- Engine  : PostgreSQL 16
-- Module  : 05 — Joining Tables
-- File    : 05_joins.sql
-- Author  : SQL Engineering Academy
-- =============================================================

\c university

-- ----------------------------------------------------------------
-- SECTION 1: INNER JOIN
-- ----------------------------------------------------------------

SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
INNER JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name;

SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   students   s
INNER JOIN departments d ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;

-- ----------------------------------------------------------------
-- SECTION 2: LEFT JOIN
-- ----------------------------------------------------------------

SELECT
    s.first_name,
    s.last_name,
    COALESCE(d.department_name, 'Unassigned') AS department
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name;

-- Anti-join: students with no department
SELECT s.first_name, s.last_name
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.department_id IS NULL;

-- All departments with student count (zero-student depts included)
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;

-- ----------------------------------------------------------------
-- SECTION 3: RIGHT JOIN
-- ----------------------------------------------------------------

SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
RIGHT JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY d.department_name, s.last_name NULLS LAST;

-- ----------------------------------------------------------------
-- SECTION 4: FULL OUTER JOIN (native in PostgreSQL)
-- ----------------------------------------------------------------

SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name NULLS LAST, d.department_name NULLS LAST;

-- Rows where either side is unmatched
SELECT
    s.first_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL OR d.department_id IS NULL;

-- ----------------------------------------------------------------
-- SECTION 5: CROSS JOIN
-- ----------------------------------------------------------------

SELECT
    s.first_name,
    d.department_name
FROM   students   s
CROSS JOIN departments d
ORDER BY s.last_name, d.department_name;

-- ----------------------------------------------------------------
-- SECTION 6: Three-table JOIN
-- ----------------------------------------------------------------

SELECT
    s.first_name,
    s.last_name,
    c.course_name,
    e.grade
FROM   students    s
JOIN   enrollments e ON e.student_id = s.student_id
JOIN   courses     c ON c.course_id  = e.course_id
ORDER BY s.last_name, c.course_name;

-- Four-table join
SELECT
    s.first_name,
    s.last_name,
    d.department_name,
    c.course_name
FROM   students    s
JOIN   departments d ON s.department_id = d.department_id
JOIN   enrollments e ON e.student_id    = s.student_id
JOIN   courses     c ON c.course_id     = e.course_id
ORDER BY s.last_name, c.course_name;

-- ----------------------------------------------------------------
-- SECTION 7: JOIN + GROUP BY
-- ----------------------------------------------------------------

SELECT
    d.department_name,
    COUNT(s.student_id)                 AS students,
    ROUND(AVG(s.gpa)::NUMERIC, 2)       AS avg_gpa
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_gpa DESC NULLS LAST;

-- ----------------------------------------------------------------
-- SECTION 8: SELF JOIN
-- ----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS employees (
    employee_id   SERIAL         PRIMARY KEY,
    first_name    VARCHAR(60)    NOT NULL,
    manager_id    INT            NULL REFERENCES employees(employee_id)
);

INSERT INTO employees (employee_id, first_name, manager_id)
VALUES
    (1, 'Amara',   NULL),
    (2, 'Priya',   1),
    (3, 'Carlos',  1),
    (4, 'Sofia',   2),
    (5, 'Yuki',    2),
    (6, 'Ibrahim', 3)
ON CONFLICT (employee_id) DO NOTHING;

SELECT
    e.first_name  AS employee,
    COALESCE(m.first_name, '(no manager)') AS manager
FROM   employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY m.first_name NULLS LAST, e.first_name;

-- ----------------------------------------------------------------
-- SECTION 9: ON vs WHERE with LEFT JOIN
-- ----------------------------------------------------------------

-- Filter in WHERE (turns LEFT JOIN into INNER effectively)
SELECT s.first_name, d.department_name, d.building
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.building = 'Tech Hall';

-- Filter in ON (preserves unmatched left rows)
SELECT s.first_name, d.department_name, d.building
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
  AND  d.building = 'Tech Hall';

-- ----------------------------------------------------------------
-- SECTION 10: USING syntax
-- ----------------------------------------------------------------

SELECT s.first_name, d.department_name
FROM   students s
JOIN   departments d USING (department_id)
ORDER BY s.last_name;
