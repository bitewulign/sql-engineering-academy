-- =============================================================
-- SQL Engineering Academy
-- Engine  : SQL Server 2022
-- Module  : 05 — Joining Tables
-- File    : 05_joins.sql
-- Author  : SQL Engineering Academy
-- =============================================================

USE university;
GO

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
GO

SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   students   s
INNER JOIN departments d ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 2: LEFT JOIN
-- ----------------------------------------------------------------

SELECT
    s.first_name,
    s.last_name,
    COALESCE(d.department_name, N'Unassigned') AS department
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name;
GO

-- Anti-join: students with no department
SELECT s.first_name, s.last_name
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.department_id IS NULL;
GO

-- All departments with student count (zero-student depts included)
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;
GO

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
ORDER BY d.department_name, s.last_name;
GO

-- ----------------------------------------------------------------
-- SECTION 4: FULL OUTER JOIN (native in SQL Server)
-- ----------------------------------------------------------------

SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name, d.department_name;
GO

-- Unmatched rows only
SELECT
    s.first_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL OR d.department_id IS NULL;
GO

-- ----------------------------------------------------------------
-- SECTION 5: CROSS JOIN
-- ----------------------------------------------------------------

SELECT
    s.first_name,
    d.department_name
FROM   students   s
CROSS JOIN departments d
ORDER BY s.last_name, d.department_name;
GO

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
GO

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
GO

-- ----------------------------------------------------------------
-- SECTION 7: JOIN + GROUP BY
-- ----------------------------------------------------------------

SELECT
    d.department_name,
    COUNT(s.student_id)      AS students,
    ROUND(AVG(s.gpa), 2)     AS avg_gpa
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 8: SELF JOIN
-- ----------------------------------------------------------------

IF OBJECT_ID(N'dbo.employees', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.employees (
        employee_id   INT IDENTITY(1,1) PRIMARY KEY,
        first_name    NVARCHAR(60)      NOT NULL,
        manager_id    INT               NULL,
        CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id)
            REFERENCES dbo.employees(employee_id)
    );

    SET IDENTITY_INSERT dbo.employees ON;
    INSERT INTO dbo.employees (employee_id, first_name, manager_id)
    VALUES
        (1, N'Amara',   NULL),
        (2, N'Priya',   1),
        (3, N'Carlos',  1),
        (4, N'Sofia',   2),
        (5, N'Yuki',    2),
        (6, N'Ibrahim', 3);
    SET IDENTITY_INSERT dbo.employees OFF;
END;
GO

SELECT
    e.first_name  AS employee,
    ISNULL(m.first_name, N'(no manager)') AS manager
FROM   dbo.employees e
LEFT JOIN dbo.employees m ON e.manager_id = m.employee_id
ORDER BY m.first_name, e.first_name;
GO

-- ----------------------------------------------------------------
-- SECTION 9: ON vs WHERE with LEFT JOIN
-- ----------------------------------------------------------------

-- Filter in WHERE
SELECT s.first_name, d.department_name, d.building
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.building = N'Tech Hall';
GO

-- Filter in ON (preserves unmatched left rows)
SELECT s.first_name, d.department_name, d.building
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
  AND  d.building = N'Tech Hall';
GO

-- ----------------------------------------------------------------
-- SECTION 10: USING syntax note
-- ----------------------------------------------------------------
-- SQL Server supports USING(col) with JOIN … USING in limited contexts.
-- The ON syntax is universally preferred in SQL Server; use it always.

SELECT s.first_name, d.department_name
FROM   students s
JOIN   departments d ON s.department_id = d.department_id
ORDER BY s.last_name;
GO
