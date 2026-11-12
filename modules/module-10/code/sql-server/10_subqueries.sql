-- =============================================================
-- Module 10 — Subqueries & CTEs
-- Platform: SQL Server 2022 (T-SQL)
-- Database: university
-- =============================================================

USE university;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 1: Scalar Subqueries
-- ─────────────────────────────────────────────────────────────

-- 1a. School-wide average GPA (scalar subquery in WHERE)
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students)
ORDER BY gpa DESC;
GO

-- 1b. Scalar subquery in SELECT list
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2)        AS school_avg,
    ROUND(gpa - (SELECT AVG(gpa) FROM students), 2)  AS diff_from_avg
FROM students
ORDER BY diff_from_avg DESC;
GO

-- 1c. Scalar subquery in HAVING
SELECT department_id, ROUND(AVG(gpa), 2) AS dept_avg
FROM   students
GROUP BY department_id
HAVING AVG(gpa) > (SELECT AVG(gpa) FROM students)
ORDER BY dept_avg DESC;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 2: Table Subqueries (Derived Tables)
-- ─────────────────────────────────────────────────────────────

-- 2a. Students with above-department-average GPA
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    d.dept_avg,
    dep.department_name
FROM   students s
JOIN (
    SELECT department_id, ROUND(AVG(gpa), 2) AS dept_avg
    FROM   students
    GROUP BY department_id
) AS d ON d.department_id = s.department_id
JOIN departments dep ON dep.department_id = s.department_id
WHERE s.gpa > d.dept_avg
ORDER BY dep.department_name, s.gpa DESC;
GO

-- 2b. Derived table: top department by enrollment count
SELECT dep.department_name, ranking.enroll_count
FROM (
    SELECT s.department_id, COUNT(*) AS enroll_count
    FROM   enrollments e
    JOIN   students s ON s.student_id = e.student_id
    GROUP BY s.department_id
) AS ranking
JOIN departments dep ON dep.department_id = ranking.department_id
WHERE ranking.enroll_count = (
    SELECT MAX(enroll_count)
    FROM (
        SELECT s2.department_id, COUNT(*) AS enroll_count
        FROM   enrollments e2
        JOIN   students s2 ON s2.student_id = e2.student_id
        GROUP BY s2.department_id
    ) sub
);
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 3: Correlated Subqueries
-- ─────────────────────────────────────────────────────────────

-- 3a. Each student's GPA vs their own department average
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    ROUND((
        SELECT AVG(s2.gpa)
        FROM   students s2
        WHERE  s2.department_id = s.department_id
    ), 2) AS dept_avg
FROM students s
ORDER BY s.department_id, s.gpa DESC;
GO

-- 3b. Students above their department average
SELECT s.first_name, s.last_name, s.department_id, s.gpa
FROM   students s
WHERE  s.gpa > (
    SELECT AVG(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = s.department_id
)
ORDER BY s.department_id, s.gpa DESC;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 4: EXISTS and NOT EXISTS
-- ─────────────────────────────────────────────────────────────

-- 4a. Students who have at least one enrollment
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY s.last_name;
GO

-- 4b. Students with NO enrollments (NULL-safe)
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY s.last_name;
GO

-- 4c. NOT IN trap — SQL Server demonstration
-- If any student_id in enrollments is NULL, NOT IN returns 0 rows.
-- Use NOT EXISTS for safety.
SELECT s.student_id, s.first_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id
);
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 5: IN with a Subquery
-- ─────────────────────────────────────────────────────────────

-- 5a. Students enrolled in course_id 1 or 3
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (
    SELECT DISTINCT student_id
    FROM   enrollments
    WHERE  course_id IN (1, 3)
)
ORDER BY last_name;
GO

-- 5b. Courses with more than 2 enrolled students
SELECT course_name, credits
FROM   courses
WHERE  course_id IN (
    SELECT course_id
    FROM   enrollments
    GROUP BY course_id
    HAVING COUNT(*) > 2
)
ORDER BY course_name;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 6: Subqueries in UPDATE and DELETE
-- ─────────────────────────────────────────────────────────────

-- 6a. Demo table for safe DML practice
IF OBJECT_ID('dbo.gpa_staging', 'U') IS NOT NULL DROP TABLE dbo.gpa_staging;
GO

SELECT student_id, department_id, gpa
INTO   dbo.gpa_staging
FROM   students;
GO

-- SELECT first to verify what will change
SELECT gs.student_id, gs.gpa,
       ROUND((SELECT AVG(gs2.gpa) FROM gpa_staging gs2
              WHERE  gs2.department_id = gs.department_id), 2) AS dept_avg
FROM   gpa_staging gs
WHERE  gs.gpa < (
    SELECT AVG(gs2.gpa) FROM gpa_staging gs2
    WHERE  gs2.department_id = gs.department_id
);
GO

-- SQL Server UPDATE … FROM pattern
UPDATE gs
SET    gpa = ROUND(d.dept_avg, 2)
FROM   gpa_staging gs
JOIN (
    SELECT department_id, AVG(gpa) AS dept_avg
    FROM   gpa_staging
    GROUP BY department_id
) d ON d.department_id = gs.department_id
WHERE  gs.gpa < d.dept_avg;
GO

SELECT * FROM gpa_staging ORDER BY department_id, student_id;
GO

IF OBJECT_ID('dbo.gpa_staging', 'U') IS NOT NULL DROP TABLE dbo.gpa_staging;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 7: WITH Clause (CTE) — Basics
-- SQL Server: WITH (no RECURSIVE keyword)
-- ─────────────────────────────────────────────────────────────

-- 7a. Single CTE: department averages
WITH dept_averages AS (
    SELECT
        department_id,
        ROUND(AVG(gpa), 2)  AS avg_gpa,
        COUNT(*)             AS student_count
    FROM students
    GROUP BY department_id
)
SELECT
    d.department_name,
    da.avg_gpa,
    da.student_count
FROM   dept_averages da
JOIN   departments d ON d.department_id = da.department_id
ORDER BY da.avg_gpa DESC;
GO

-- 7b. CTE used twice
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT
    s.first_name,
    s.gpa,
    ROUND(da.avg_gpa, 2) AS dept_avg,
    ROUND(s.gpa - da.avg_gpa, 2) AS delta
FROM   students s
JOIN   dept_avg da ON da.department_id = s.department_id
WHERE  s.gpa > da.avg_gpa
  AND  da.avg_gpa > 3.0
ORDER BY delta DESC;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 8: Stacked CTEs
-- ─────────────────────────────────────────────────────────────

WITH
dept_stats AS (
    SELECT
        s.department_id,
        COUNT(DISTINCT s.student_id)  AS student_count,
        COUNT(DISTINCT e.student_id)  AS enrolled_count,
        ROUND(AVG(s.gpa), 2)          AS avg_gpa
    FROM      students s
    LEFT JOIN enrollments e ON e.student_id = s.student_id
    GROUP BY  s.department_id
),
dept_ranked AS (
    SELECT
        department_id,
        student_count,
        enrolled_count,
        avg_gpa,
        RANK() OVER (ORDER BY avg_gpa DESC) AS gpa_rank
    FROM dept_stats
),
dept_final AS (
    SELECT
        d.department_name,
        dr.student_count,
        dr.enrolled_count,
        dr.avg_gpa,
        dr.gpa_rank
    FROM dept_ranked dr
    JOIN departments d ON d.department_id = dr.department_id
)
SELECT *
FROM   dept_final
ORDER BY gpa_rank;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 9: CTE for Top N per Group
-- ─────────────────────────────────────────────────────────────

-- 9a. Top student per department
WITH ranked_students AS (
    SELECT
        student_id,
        first_name,
        last_name,
        department_id,
        gpa,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rn
    FROM students
)
SELECT rs.student_id, rs.first_name, rs.last_name, d.department_name, rs.gpa
FROM   ranked_students rs
JOIN   departments d ON d.department_id = rs.department_id
WHERE  rs.rn = 1
ORDER BY rs.gpa DESC;
GO

-- 9b. Top 3 per department
WITH ranked_students AS (
    SELECT
        first_name,
        last_name,
        department_id,
        gpa,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rn
    FROM students
)
SELECT d.department_name, rs.first_name, rs.last_name, rs.gpa, rs.rn AS dept_rank
FROM   ranked_students rs
JOIN   departments d ON d.department_id = rs.department_id
WHERE  rs.rn <= 3
ORDER BY d.department_name, rs.rn;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 10: Recursive CTEs
-- SQL Server: WITH (no RECURSIVE keyword — recursion auto-detected)
-- ─────────────────────────────────────────────────────────────

-- 10a. Set up org hierarchy demo
IF OBJECT_ID('dbo.employees_demo', 'U') IS NOT NULL DROP TABLE dbo.employees_demo;
GO

CREATE TABLE dbo.employees_demo (
    employee_id   INT            NOT NULL IDENTITY(1,1),
    name          NVARCHAR(100)  NOT NULL,
    title         NVARCHAR(100)  NOT NULL,
    manager_id    INT            NULL,
    CONSTRAINT pk_employees_demo      PRIMARY KEY (employee_id),
    CONSTRAINT fk_employees_demo_mgr  FOREIGN KEY (manager_id)
        REFERENCES dbo.employees_demo(employee_id)
);
GO

INSERT INTO dbo.employees_demo (name, title, manager_id) VALUES
    (N'Sofia Chen',    N'CEO',               NULL),  -- id 1
    (N'Omar Farouq',   N'VP Engineering',    1),
    (N'Priya Sharma',  N'VP Marketing',      1),
    (N'Carlos Rivera', N'Engineering Lead',  2),
    (N'Amara Diallo',  N'Senior Engineer',   4),
    (N'Yuki Tanaka',   N'Engineer',          4),
    (N'Ibrahim Hassan',N'Marketing Manager', 3),
    (N'Lena Müller',   N'Campaign Manager',  3),
    (N'Mia Torres',    N'Junior Engineer',   5);
GO

-- 10b. Full hierarchy — SQL Server WITH (no RECURSIVE keyword)
WITH org_tree AS (
    -- Anchor: CEO (no manager)
    SELECT
        employee_id,
        name,
        title,
        manager_id,
        0                              AS depth,
        CAST(name AS NVARCHAR(2000))   AS path
    FROM dbo.employees_demo
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT
        e.employee_id,
        e.name,
        e.title,
        e.manager_id,
        t.depth + 1,
        CAST(t.path + N' → ' + e.name AS NVARCHAR(2000))
    FROM   dbo.employees_demo e
    JOIN   org_tree t ON t.employee_id = e.manager_id
)
SELECT
    REPLICATE(N'  ', depth) + name AS hierarchy,
    title,
    depth,
    path
FROM   org_tree
ORDER BY path
OPTION (MAXRECURSION 50);       -- SQL Server recursion limit hint
GO

-- 10c. All reports under Omar Farouq (id 2)
WITH reports AS (
    SELECT employee_id, name, title, 0 AS depth
    FROM   dbo.employees_demo
    WHERE  employee_id = 2

    UNION ALL

    SELECT e.employee_id, e.name, e.title, r.depth + 1
    FROM   dbo.employees_demo e
    JOIN   reports r ON r.employee_id = e.manager_id
)
SELECT depth, name, title
FROM   reports
ORDER BY depth, name
OPTION (MAXRECURSION 20);
GO

-- 10d. Number sequence
WITH numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT n FROM numbers;
GO

-- 10e. Date series (useful for filling gaps in data)
WITH date_series AS (
    SELECT CAST(DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) AS DATE) AS d
    UNION ALL
    SELECT CAST(DATEADD(DAY, 1, d) AS DATE)
    FROM   date_series
    WHERE  d < CAST(GETDATE() AS DATE)
)
SELECT d AS day, DATENAME(WEEKDAY, d) AS day_name
FROM   date_series;
GO

-- 10f. Fibonacci
WITH fib(a, b, step) AS (
    SELECT 0, 1, 1
    UNION ALL
    SELECT b, a + b, step + 1 FROM fib WHERE step < 15
)
SELECT step, a AS fibonacci_number FROM fib;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 11: MAXRECURSION Option
-- ─────────────────────────────────────────────────────────────

-- Default is 100. Use OPTION (MAXRECURSION 0) for unlimited (use with caution).
-- Always pair MAXRECURSION 0 with an explicit depth guard in the CTE.

WITH org_unlimited AS (
    SELECT employee_id, name, manager_id, 0 AS depth
    FROM   dbo.employees_demo
    WHERE  manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.name, e.manager_id, t.depth + 1
    FROM   dbo.employees_demo e
    JOIN   org_unlimited t ON t.employee_id = e.manager_id
    WHERE  t.depth < 50     -- explicit guard prevents true infinite loop
)
SELECT depth, name FROM org_unlimited ORDER BY depth, name
OPTION (MAXRECURSION 0);    -- disable built-in limit; guard above is our safety net
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 12: CTE in DML (INSERT, UPDATE, DELETE)
-- ─────────────────────────────────────────────────────────────

-- SQL Server supports CTEs directly in DML statements

-- 12a. CTE in UPDATE
IF OBJECT_ID('dbo.gpa_staging', 'U') IS NOT NULL DROP TABLE dbo.gpa_staging;
GO

SELECT student_id, department_id, gpa
INTO   dbo.gpa_staging
FROM   students;
GO

-- Preview
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   gpa_staging
    GROUP BY department_id
)
SELECT gs.student_id, gs.gpa, ROUND(da.avg_gpa, 2) AS dept_avg
FROM   gpa_staging gs
JOIN   dept_avg da ON da.department_id = gs.department_id
WHERE  gs.gpa < da.avg_gpa;
GO

-- Actual update with CTE
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   gpa_staging
    GROUP BY department_id
)
UPDATE gs
SET    gpa = ROUND(da.avg_gpa, 2)
FROM   gpa_staging gs
JOIN   dept_avg da ON da.department_id = gs.department_id
WHERE  gs.gpa < da.avg_gpa;
GO

-- 12b. CTE in DELETE — remove lowest-GPA student from each department
WITH dept_low AS (
    SELECT student_id,
           ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa ASC) AS rn
    FROM   gpa_staging
)
-- Preview only — not deleting real data
SELECT student_id FROM dept_low WHERE rn = 1;
GO

IF OBJECT_ID('dbo.gpa_staging', 'U') IS NOT NULL DROP TABLE dbo.gpa_staging;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 13: Real-World Patterns
-- ─────────────────────────────────────────────────────────────

-- 13a. Courses with no enrolled students
SELECT c.course_id, c.course_name, c.credits
FROM   courses c
WHERE  NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.course_id = c.course_id
)
ORDER BY c.course_name;
GO

-- 13b. Relational division — students enrolled in ALL courses
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT c.course_id
    FROM   courses c
    WHERE  NOT EXISTS (
        SELECT 1
        FROM   enrollments e
        WHERE  e.student_id = s.student_id
          AND  e.course_id  = c.course_id
    )
)
ORDER BY s.last_name;
GO

-- 13c. Enrollment rate report with stacked CTEs
WITH
dept_students AS (
    SELECT department_id, COUNT(*) AS total_students
    FROM   students
    GROUP BY department_id
),
dept_enrolled AS (
    SELECT s.department_id, COUNT(DISTINCT e.student_id) AS enrolled_students
    FROM   students s
    JOIN   enrollments e ON e.student_id = s.student_id
    GROUP BY s.department_id
)
SELECT
    d.department_name,
    ds.total_students,
    COALESCE(de.enrolled_students, 0)                                         AS enrolled_students,
    ROUND(100.0 * COALESCE(de.enrolled_students, 0) / ds.total_students, 1)   AS enrollment_pct
FROM   dept_students ds
JOIN   departments d  ON d.department_id  = ds.department_id
LEFT JOIN dept_enrolled de ON de.department_id = ds.department_id
ORDER BY enrollment_pct DESC;
GO

-- 13d. OUTPUT clause with CTE (SQL Server-specific)
IF OBJECT_ID('dbo.gpa_audit', 'U') IS NOT NULL DROP TABLE dbo.gpa_audit;
GO

CREATE TABLE dbo.gpa_audit (
    student_id  INT            NOT NULL,
    old_gpa     DECIMAL(3,2)   NOT NULL,
    new_gpa     DECIMAL(3,2)   NOT NULL,
    changed_at  DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);
GO

IF OBJECT_ID('dbo.gpa_staging2', 'U') IS NOT NULL DROP TABLE dbo.gpa_staging2;
SELECT student_id, department_id, gpa INTO dbo.gpa_staging2 FROM students;
GO

WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   gpa_staging2
    GROUP BY department_id
)
UPDATE gs
SET    gpa = ROUND(da.avg_gpa, 2)
OUTPUT DELETED.student_id,
       DELETED.gpa           AS old_gpa,
       INSERTED.gpa          AS new_gpa
INTO   dbo.gpa_audit (student_id, old_gpa, new_gpa)
FROM   gpa_staging2 gs
JOIN   dept_avg da ON da.department_id = gs.department_id
WHERE  gs.gpa < da.avg_gpa;

SELECT * FROM dbo.gpa_audit;
GO

-- ─────────────────────────────────────────────────────────────
-- SECTION 14: Cleanup
-- ─────────────────────────────────────────────────────────────

IF OBJECT_ID('dbo.employees_demo', 'U') IS NOT NULL DROP TABLE dbo.employees_demo;
IF OBJECT_ID('dbo.gpa_staging',    'U') IS NOT NULL DROP TABLE dbo.gpa_staging;
IF OBJECT_ID('dbo.gpa_staging2',   'U') IS NOT NULL DROP TABLE dbo.gpa_staging2;
IF OBJECT_ID('dbo.gpa_audit',      'U') IS NOT NULL DROP TABLE dbo.gpa_audit;
GO
