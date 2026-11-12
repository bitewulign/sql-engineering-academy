-- =============================================================
-- Module 10 — Subqueries & CTEs
-- Platform: MySQL 8.0
-- Database: university
-- =============================================================

USE university;

-- ─────────────────────────────────────────────────────────────
-- SECTION 1: Scalar Subqueries
-- ─────────────────────────────────────────────────────────────

-- 1a. School-wide average GPA (scalar subquery in WHERE)
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students)
ORDER BY gpa DESC;

-- 1b. Scalar subquery in SELECT list — adds avg column to every row
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2)      AS school_avg,
    ROUND(gpa - (SELECT AVG(gpa) FROM students), 2) AS diff_from_avg
FROM students
ORDER BY diff_from_avg DESC;

-- 1c. Scalar subquery in HAVING
SELECT department_id, ROUND(AVG(gpa), 2) AS dept_avg
FROM   students
GROUP BY department_id
HAVING AVG(gpa) > (SELECT AVG(gpa) FROM students)
ORDER BY dept_avg DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 2: Table Subqueries (Derived Tables)
-- ─────────────────────────────────────────────────────────────

-- 2a. Students with above-department-average GPA
--     Step 1: build department averages as a derived table
--     Step 2: join students to that derived table
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

-- 2b. Top department by average GPA (derived table in FROM)
SELECT dep.department_name, ranking.avg_gpa
FROM (
    SELECT department_id, ROUND(AVG(gpa), 2) AS avg_gpa
    FROM   students
    GROUP BY department_id
    ORDER BY avg_gpa DESC
    LIMIT 1
) AS ranking
JOIN departments dep ON dep.department_id = ranking.department_id;

-- ─────────────────────────────────────────────────────────────
-- SECTION 3: Correlated Subqueries
-- ─────────────────────────────────────────────────────────────

-- 3a. Each student's GPA vs their own department average (correlated)
--     Inner query runs once per outer row (references s.department_id)
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    ROUND((
        SELECT AVG(s2.gpa)
        FROM   students s2
        WHERE  s2.department_id = s.department_id   -- outer column reference
    ), 2) AS dept_avg
FROM students s
ORDER BY s.department_id, s.gpa DESC;

-- 3b. Students whose GPA is above their own department average
SELECT s.first_name, s.last_name, s.department_id, s.gpa
FROM   students s
WHERE  s.gpa > (
    SELECT AVG(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = s.department_id
)
ORDER BY s.department_id, s.gpa DESC;

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

-- 4b. Students with NO enrollments (NULL-safe approach)
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY s.last_name;

-- 4c. NOT IN trap demo — if any student_id in enrollments is NULL,
--     NOT IN returns 0 rows for ALL students!
--     Use NOT EXISTS instead (always safe)
-- DANGEROUS:
-- SELECT * FROM students WHERE student_id NOT IN (SELECT student_id FROM enrollments);
-- SAFE:
SELECT s.student_id, s.first_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id
);

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

-- 5b. Courses taught by faculty in the Computer Science department
SELECT course_name, credits
FROM   courses
WHERE  course_id IN (
    SELECT DISTINCT course_id
    FROM   faculty_courses fc
    JOIN   faculty f ON f.faculty_id = fc.faculty_id
    JOIN   departments d ON d.department_id = f.department_id
    WHERE  d.department_name = 'Computer Science'
)
ORDER BY course_name;

-- ─────────────────────────────────────────────────────────────
-- SECTION 6: Subqueries in UPDATE and DELETE
-- ─────────────────────────────────────────────────────────────

-- 6a. Demo table to show DML with subqueries safely
DROP TABLE IF EXISTS gpa_staging;

CREATE TABLE gpa_staging AS
    SELECT student_id, department_id, gpa FROM students;

-- SELECT first to verify what will change
SELECT gs.student_id, gs.gpa,
       (SELECT AVG(gs2.gpa) FROM gpa_staging gs2
        WHERE gs2.department_id = gs.department_id) AS dept_avg
FROM   gpa_staging gs
WHERE  gs.gpa < (
    SELECT AVG(gs2.gpa) FROM gpa_staging gs2
    WHERE  gs2.department_id = gs.department_id
);

-- Update: raise below-average students to their department average
UPDATE gpa_staging gs
JOIN (
    SELECT department_id, AVG(gpa) AS dept_avg
    FROM   gpa_staging
    GROUP BY department_id
) d ON d.department_id = gs.department_id
SET    gs.gpa = ROUND(d.dept_avg, 2)
WHERE  gs.gpa < d.dept_avg;

SELECT * FROM gpa_staging;

-- 6b. DELETE using NOT EXISTS (NULL-safe)
DROP TABLE IF EXISTS enrollment_staging;

CREATE TABLE enrollment_staging AS
    SELECT student_id FROM enrollments WHERE 1=0;   -- empty copy

-- Students with no enrollments → safe to delete from staging
DELETE FROM enrollment_staging
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = enrollment_staging.student_id
);

DROP TABLE IF EXISTS gpa_staging;
DROP TABLE IF EXISTS enrollment_staging;

-- ─────────────────────────────────────────────────────────────
-- SECTION 7: WITH Clause (CTE) — Basics
-- ─────────────────────────────────────────────────────────────

-- 7a. Single CTE: department averages
WITH dept_averages AS (
    SELECT
        department_id,
        ROUND(AVG(gpa), 2) AS avg_gpa,
        COUNT(*)            AS student_count
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

-- 7b. CTE used twice in the same query (write once, reference twice)
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    da.avg_gpa AS dept_avg,
    ROUND(s.gpa - da.avg_gpa, 2) AS delta
FROM   students s
JOIN   dept_avg da ON da.department_id = s.department_id
WHERE  s.gpa > da.avg_gpa       -- CTE used here
  AND  da.avg_gpa > 3.0         -- and here
ORDER BY delta DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 8: Stacked CTEs
-- ─────────────────────────────────────────────────────────────

-- 8a. Three-step CTE chain
WITH
-- Step 1: per-department enrollment counts and avg GPA
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
-- Step 2: rank departments by avg GPA (references Step 1)
dept_ranked AS (
    SELECT
        department_id,
        student_count,
        enrolled_count,
        avg_gpa,
        RANK() OVER (ORDER BY avg_gpa DESC) AS gpa_rank
    FROM dept_stats
),
-- Step 3: add department name (references Step 2)
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

-- ─────────────────────────────────────────────────────────────
-- SECTION 9: CTE for Window Function Filtering (Top N per Group)
-- ─────────────────────────────────────────────────────────────

-- 9a. Top student per department using ROW_NUMBER in CTE
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

-- 9b. Top 3 students per department
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

-- ─────────────────────────────────────────────────────────────
-- SECTION 10: Recursive CTEs
-- MySQL 8.0 uses WITH RECURSIVE
-- ─────────────────────────────────────────────────────────────

-- 10a. Set up a demo org hierarchy
DROP TABLE IF EXISTS employees_demo;

CREATE TABLE employees_demo (
    employee_id   INT          NOT NULL AUTO_INCREMENT,
    name          VARCHAR(100) NOT NULL,
    title         VARCHAR(100) NOT NULL,
    manager_id    INT          NULL,       -- NULL = top of hierarchy
    PRIMARY KEY (employee_id),
    CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id)
        REFERENCES employees_demo(employee_id) ON DELETE RESTRICT
);

INSERT INTO employees_demo (name, title, manager_id) VALUES
    ('Sofia Chen',    'CEO',               NULL),  -- id 1
    ('Omar Farouq',   'VP Engineering',    1),     -- id 2
    ('Priya Sharma',  'VP Marketing',      1),     -- id 3
    ('Carlos Rivera', 'Engineering Lead',  2),     -- id 4
    ('Amara Diallo',  'Senior Engineer',   4),     -- id 5
    ('Yuki Tanaka',   'Engineer',          4),     -- id 6
    ('Ibrahim Hassan','Marketing Manager', 3),     -- id 7
    ('Lena Müller',   'Campaign Manager',  3),     -- id 8
    ('Mia Torres',    'Junior Engineer',   5);     -- id 9

-- 10b. Recursive CTE — traverse the full hierarchy
WITH RECURSIVE org_tree AS (
    -- Anchor: top-level (CEO — no manager)
    SELECT
        employee_id,
        name,
        title,
        manager_id,
        0                            AS depth,
        CAST(name AS CHAR(500))      AS path,
        CAST(employee_id AS CHAR(50)) AS id_path
    FROM employees_demo
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive step: direct reports of each node
    SELECT
        e.employee_id,
        e.name,
        e.title,
        e.manager_id,
        t.depth + 1,
        CONCAT(t.path, ' → ', e.name),
        CONCAT(t.id_path, ',', e.employee_id)
    FROM   employees_demo e
    JOIN   org_tree t ON t.employee_id = e.manager_id
)
SELECT
    CONCAT(REPEAT('  ', depth), name) AS hierarchy,
    title,
    depth,
    path
FROM   org_tree
ORDER BY path;

-- 10c. Find all reports under a specific manager (Omar Farouq = id 2)
WITH RECURSIVE reports AS (
    SELECT employee_id, name, title, 0 AS depth
    FROM   employees_demo
    WHERE  employee_id = 2          -- anchor = Omar

    UNION ALL

    SELECT e.employee_id, e.name, e.title, r.depth + 1
    FROM   employees_demo e
    JOIN   reports r ON r.employee_id = e.manager_id
)
SELECT depth, name, title
FROM   reports
ORDER BY depth, name;

-- 10d. Number sequence (classic recursive CTE demo)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT n FROM numbers;

-- 10e. Fibonacci sequence (depth guard prevents runaway)
WITH RECURSIVE fib (a, b, step) AS (
    SELECT 0, 1, 1
    UNION ALL
    SELECT b, a + b, step + 1
    FROM fib
    WHERE step < 15
)
SELECT step, a AS fibonacci_number FROM fib;

-- ─────────────────────────────────────────────────────────────
-- SECTION 11: Controlling Recursion Depth (MySQL)
-- ─────────────────────────────────────────────────────────────

-- Check current setting
SELECT @@cte_max_recursion_depth;

-- Raise limit for a session that needs deeper traversal
SET SESSION cte_max_recursion_depth = 500;

-- Always include a depth counter as a safety guard
WITH RECURSIVE safe_tree AS (
    SELECT employee_id, name, manager_id, 0 AS depth
    FROM   employees_demo
    WHERE  manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.name, e.manager_id, t.depth + 1
    FROM   employees_demo e
    JOIN   safe_tree t ON t.employee_id = e.manager_id
    WHERE  t.depth < 20     -- explicit guard
)
SELECT depth, name FROM safe_tree ORDER BY depth, name;

-- Reset to default
SET SESSION cte_max_recursion_depth = 1000;

-- ─────────────────────────────────────────────────────────────
-- SECTION 12: Running Totals with Recursive CTEs
-- ─────────────────────────────────────────────────────────────

-- Running total of GPA across sorted students (window function is better,
-- but this shows the recursive technique)
WITH RECURSIVE gpa_running AS (
    SELECT
        student_id,
        first_name,
        gpa,
        ROW_NUMBER() OVER (ORDER BY gpa DESC) AS rn
    FROM students
    LIMIT 5
),
running_total AS (
    SELECT student_id, first_name, gpa, rn,
           gpa AS running_sum
    FROM   gpa_running
    WHERE  rn = 1

    UNION ALL

    SELECT g.student_id, g.first_name, g.gpa, g.rn,
           ROUND(rt.running_sum + g.gpa, 2)
    FROM   gpa_running g
    JOIN   running_total rt ON rt.rn = g.rn - 1
)
SELECT rn, first_name, gpa, running_sum FROM running_total;

-- ─────────────────────────────────────────────────────────────
-- SECTION 13: CTE vs Subquery — Performance Pattern
-- ─────────────────────────────────────────────────────────────

-- Both queries produce identical results.
-- CTE version is more readable and the optimizer may cache the result.

-- Subquery version (inline)
SELECT s.first_name, s.gpa, sub.avg_gpa
FROM   students s
JOIN   (SELECT department_id, AVG(gpa) AS avg_gpa
        FROM students GROUP BY department_id) sub
    ON sub.department_id = s.department_id
WHERE  s.gpa > sub.avg_gpa;

-- CTE version (identical plan in MySQL; preferred for readability)
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT s.first_name, s.gpa, da.avg_gpa
FROM   students s
JOIN   dept_avg da ON da.department_id = s.department_id
WHERE  s.gpa > da.avg_gpa;

-- ─────────────────────────────────────────────────────────────
-- SECTION 14: Real-World Patterns
-- ─────────────────────────────────────────────────────────────

-- 14a. Courses with no enrolled students (NOT EXISTS)
SELECT c.course_id, c.course_name, c.credits
FROM   courses c
WHERE  NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.course_id = c.course_id
)
ORDER BY c.course_name;

-- 14b. Students enrolled in ALL courses (division problem using NOT EXISTS)
-- "Find students where there is no course for which they have no enrollment"
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

-- 14c. Department report with enrollment rate using stacked CTEs
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
    COALESCE(de.enrolled_students, 0)                        AS enrolled_students,
    ROUND(100.0 * COALESCE(de.enrolled_students, 0) / ds.total_students, 1) AS enrollment_pct
FROM   dept_students ds
JOIN   departments d  ON d.department_id  = ds.department_id
LEFT JOIN dept_enrolled de ON de.department_id = ds.department_id
ORDER BY enrollment_pct DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 15: Cleanup
-- ─────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS employees_demo;
