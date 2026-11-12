-- =============================================================
-- SQL Engineering Academy
-- Engine  : MySQL 8.0
-- Module  : 05 — Joining Tables
-- File    : 05_joins.sql
-- Author  : SQL Engineering Academy
-- =============================================================

USE university;

-- ----------------------------------------------------------------
-- SECTION 1: INNER JOIN — matched rows only
-- ----------------------------------------------------------------

-- Students with their department name
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
INNER JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name;

-- Count students per department (only departments with students)
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   students   s
INNER JOIN departments d ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;

-- ----------------------------------------------------------------
-- SECTION 2: LEFT JOIN — all left rows, NULLs where no match
-- ----------------------------------------------------------------

-- All students, even if not assigned to a department
SELECT
    s.first_name,
    s.last_name,
    COALESCE(d.department_name, 'Unassigned') AS department
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name;

-- Anti-join: students with NO department assignment
SELECT
    s.first_name,
    s.last_name
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
WHERE  d.department_id IS NULL;

-- All departments with student count (including zero-student departments)
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count   -- COUNT(col) skips NULLs → correct 0
FROM   departments d
LEFT JOIN students s
  ON   s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;

-- ----------------------------------------------------------------
-- SECTION 3: RIGHT JOIN — all right rows, NULLs where no match
-- ----------------------------------------------------------------

-- All departments, even those with no students (same as LEFT JOIN above, reversed)
SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
RIGHT JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY d.department_name, s.last_name;

-- ----------------------------------------------------------------
-- SECTION 4: FULL OUTER JOIN simulation (MySQL has no FULL OUTER JOIN)
-- ----------------------------------------------------------------

-- Simulate FULL OUTER JOIN: all students + all departments, NULLs on unmatched side
SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students s
LEFT JOIN departments d ON s.department_id = d.department_id

UNION

SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students s
RIGHT JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL;

-- ----------------------------------------------------------------
-- SECTION 5: CROSS JOIN — Cartesian product
-- ----------------------------------------------------------------

-- Every student paired with every department (use case: scheduling matrix)
SELECT
    s.first_name,
    d.department_name
FROM   students   s
CROSS JOIN departments d
ORDER BY s.last_name, d.department_name;

-- Count of rows = students × departments
SELECT
    (SELECT COUNT(*) FROM students) AS student_count,
    (SELECT COUNT(*) FROM departments) AS dept_count,
    (SELECT COUNT(*) FROM students) * (SELECT COUNT(*) FROM departments) AS cross_join_rows;

-- ----------------------------------------------------------------
-- SECTION 6: Three-table JOIN (students → enrollments → courses)
-- ----------------------------------------------------------------

-- What courses is each student enrolled in?
SELECT
    s.first_name,
    s.last_name,
    c.course_name,
    e.grade
FROM   students    s
JOIN   enrollments e ON e.student_id = s.student_id
JOIN   courses     c ON c.course_id  = e.course_id
ORDER BY s.last_name, c.course_name;

-- Students with their department AND their enrolled courses
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

-- Average GPA per department name (LEFT JOIN to include zero-student depts)
SELECT
    d.department_name,
    COUNT(s.student_id)      AS students,
    ROUND(AVG(s.gpa), 2)     AS avg_gpa
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 8: SELF JOIN
-- ----------------------------------------------------------------
-- Assumes an employees table with manager_id FK (self-referencing).
-- Create a minimal demo table if needed:

CREATE TABLE IF NOT EXISTS employees (
    employee_id   INT            AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(60)    NOT NULL,
    manager_id    INT            NULL,
    CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

INSERT IGNORE INTO employees (employee_id, first_name, manager_id) VALUES
    (1, 'Amara',   NULL),   -- CEO, no manager
    (2, 'Priya',   1),
    (3, 'Carlos',  1),
    (4, 'Sofia',   2),
    (5, 'Yuki',    2),
    (6, 'Ibrahim', 3);

-- Self join: each employee with their manager's name
SELECT
    e.first_name  AS employee,
    COALESCE(m.first_name, '(no manager)') AS manager
FROM   employees e
LEFT JOIN employees m
  ON   e.manager_id = m.employee_id
ORDER BY m.first_name, e.first_name;

-- ----------------------------------------------------------------
-- SECTION 9: ON vs WHERE with LEFT JOIN
-- ----------------------------------------------------------------

-- Filter in WHERE: eliminates unmatched left rows (effectively INNER JOIN)
SELECT s.first_name, d.department_name, d.building
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.building = 'Tech Hall';

-- Filter in ON: unmatched left rows kept (d columns NULL for non-Tech-Hall)
SELECT s.first_name, d.department_name, d.building
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
  AND  d.building = 'Tech Hall';

-- ----------------------------------------------------------------
-- SECTION 10: USING syntax shortcut
-- ----------------------------------------------------------------

-- When both tables share the same column name, USING(col) is cleaner
SELECT s.first_name, d.department_name
FROM   students s
JOIN   departments d USING (department_id)
ORDER BY s.last_name;
