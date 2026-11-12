-- =============================================================
-- Module 10 — Subqueries & CTEs
-- Platform: PostgreSQL 16
-- Database: university
-- =============================================================

\c university

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
    ROUND((SELECT AVG(gpa) FROM students)::NUMERIC, 2)              AS school_avg,
    ROUND((gpa - (SELECT AVG(gpa) FROM students))::NUMERIC, 2)      AS diff_from_avg
FROM students
ORDER BY diff_from_avg DESC;

-- 1c. Scalar subquery in HAVING
SELECT department_id, ROUND(AVG(gpa)::NUMERIC, 2) AS dept_avg
FROM   students
GROUP BY department_id
HAVING AVG(gpa) > (SELECT AVG(gpa) FROM students)
ORDER BY dept_avg DESC;

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
    SELECT department_id, ROUND(AVG(gpa)::NUMERIC, 2) AS dept_avg
    FROM   students
    GROUP BY department_id
) AS d ON d.department_id = s.department_id
JOIN departments dep ON dep.department_id = s.department_id
WHERE s.gpa > d.dept_avg
ORDER BY dep.department_name, s.gpa DESC;

-- 2b. LATERAL subquery — per-row derived table
--     (PostgreSQL-specific; equivalent to correlated subquery in FROM)
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    lat.dept_avg
FROM   students s,
       LATERAL (
           SELECT ROUND(AVG(gpa)::NUMERIC, 2) AS dept_avg
           FROM   students s2
           WHERE  s2.department_id = s.department_id
       ) AS lat
ORDER BY s.gpa DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 3: Correlated Subqueries
-- ─────────────────────────────────────────────────────────────

-- 3a. Each student's GPA vs their department average (correlated)
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    ROUND((
        SELECT AVG(s2.gpa)
        FROM   students s2
        WHERE  s2.department_id = s.department_id
    )::NUMERIC, 2) AS dept_avg
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

-- 4b. Students with NO enrollments (NULL-safe)
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY s.last_name;

-- 4c. NOT IN trap — PostgreSQL demonstration
-- If any row in enrollments has a NULL student_id, NOT IN returns nothing.
-- NOT EXISTS is always safe.
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

-- ─────────────────────────────────────────────────────────────
-- SECTION 6: Subqueries in UPDATE and DELETE
-- ─────────────────────────────────────────────────────────────

-- 6a. Demo table for safe DML practice
DROP TABLE IF EXISTS gpa_staging;

CREATE TABLE gpa_staging AS
    SELECT student_id, department_id, gpa FROM students;

-- SELECT first to verify what will change
SELECT gs.student_id, gs.gpa,
       ROUND((SELECT AVG(gs2.gpa) FROM gpa_staging gs2
              WHERE  gs2.department_id = gs.department_id)::NUMERIC, 2) AS dept_avg
FROM   gpa_staging gs
WHERE  gs.gpa < (
    SELECT AVG(gs2.gpa) FROM gpa_staging gs2
    WHERE  gs2.department_id = gs.department_id
);

-- PostgreSQL UPDATE … FROM pattern (not UPDATE … JOIN)
UPDATE gpa_staging gs
SET    gpa = ROUND(d.dept_avg::NUMERIC, 2)
FROM (
    SELECT department_id, AVG(gpa) AS dept_avg
    FROM   gpa_staging
    GROUP BY department_id
) d
WHERE gs.department_id = d.department_id
  AND gs.gpa < d.dept_avg;

SELECT * FROM gpa_staging ORDER BY department_id, student_id;

-- 6b. DELETE using NOT EXISTS
DROP TABLE IF EXISTS enrollment_staging;

CREATE TABLE enrollment_staging AS
    SELECT student_id FROM enrollments WHERE FALSE;

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
        ROUND(AVG(gpa)::NUMERIC, 2) AS avg_gpa,
        COUNT(*)                     AS student_count
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

-- 7b. CTE in UPDATE (PostgreSQL supports CTEs in DML)
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT s.first_name, s.gpa, ROUND(da.avg_gpa::NUMERIC, 2) AS dept_avg
FROM   students s
JOIN   dept_avg da ON da.department_id = s.department_id
WHERE  s.gpa > da.avg_gpa
ORDER BY s.gpa DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 8: Stacked CTEs
-- ─────────────────────────────────────────────────────────────

WITH
dept_stats AS (
    SELECT
        s.department_id,
        COUNT(DISTINCT s.student_id)  AS student_count,
        COUNT(DISTINCT e.student_id)  AS enrolled_count,
        ROUND(AVG(s.gpa)::NUMERIC, 2) AS avg_gpa
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

-- 9b. DML CTE — PostgreSQL: WITH in UPDATE … RETURNING
WITH to_update AS (
    SELECT s.student_id
    FROM   students s
    WHERE  s.gpa < (
        SELECT AVG(s2.gpa) FROM students s2 WHERE s2.department_id = s.department_id
    )
    LIMIT 1          -- preview: just one row in demo
)
SELECT student_id FROM to_update;
-- (In production: UPDATE students SET gpa = … FROM to_update WHERE …)

-- ─────────────────────────────────────────────────────────────
-- SECTION 10: Recursive CTEs
-- PostgreSQL uses WITH RECURSIVE
-- ─────────────────────────────────────────────────────────────

-- 10a. Set up org hierarchy demo
DROP TABLE IF EXISTS employees_demo CASCADE;

CREATE TABLE employees_demo (
    employee_id  SERIAL       PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    title        VARCHAR(100) NOT NULL,
    manager_id   INT          REFERENCES employees_demo(employee_id)
);

INSERT INTO employees_demo (name, title, manager_id) VALUES
    ('Sofia Chen',    'CEO',               NULL),
    ('Omar Farouq',   'VP Engineering',    1),
    ('Priya Sharma',  'VP Marketing',      1),
    ('Carlos Rivera', 'Engineering Lead',  2),
    ('Amara Diallo',  'Senior Engineer',   4),
    ('Yuki Tanaka',   'Engineer',          4),
    ('Ibrahim Hassan','Marketing Manager', 3),
    ('Lena Müller',   'Campaign Manager',  3),
    ('Mia Torres',    'Junior Engineer',   5);

-- 10b. Full org hierarchy with path and depth
WITH RECURSIVE org_tree AS (
    -- Anchor: top-level (no manager)
    SELECT
        employee_id,
        name,
        title,
        manager_id,
        0                              AS depth,
        name::VARCHAR(1000)            AS path,
        ARRAY[employee_id]             AS id_path
    FROM employees_demo
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive step
    SELECT
        e.employee_id,
        e.name,
        e.title,
        e.manager_id,
        t.depth + 1,
        (t.path || ' → ' || e.name)::VARCHAR(1000),
        t.id_path || e.employee_id
    FROM   employees_demo e
    JOIN   org_tree t ON t.employee_id = e.manager_id
    WHERE  t.depth < 20     -- safety guard
)
SELECT
    repeat('  ', depth) || name AS hierarchy,
    title,
    depth,
    path
FROM   org_tree
ORDER BY path;

-- 10c. All direct and indirect reports under Omar Farouq (id 2)
WITH RECURSIVE reports AS (
    SELECT employee_id, name, title, 0 AS depth
    FROM   employees_demo
    WHERE  employee_id = 2

    UNION ALL

    SELECT e.employee_id, e.name, e.title, r.depth + 1
    FROM   employees_demo e
    JOIN   reports r ON r.employee_id = e.manager_id
    WHERE  r.depth < 10
)
SELECT depth, name, title
FROM   reports
ORDER BY depth, name;

-- 10d. Number sequence
WITH RECURSIVE numbers(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT n FROM numbers;

-- 10e. Date series (practical PostgreSQL pattern)
WITH RECURSIVE date_series AS (
    SELECT CURRENT_DATE - INTERVAL '6 days' AS d
    UNION ALL
    SELECT d + INTERVAL '1 day' FROM date_series WHERE d < CURRENT_DATE
)
SELECT d::DATE AS day, TO_CHAR(d, 'Dy') AS day_name
FROM   date_series;

-- 10f. Fibonacci
WITH RECURSIVE fib(a, b, step) AS (
    SELECT 0, 1, 1
    UNION ALL
    SELECT b, a + b, step + 1 FROM fib WHERE step < 15
)
SELECT step, a AS fibonacci_number FROM fib;

-- ─────────────────────────────────────────────────────────────
-- SECTION 11: LATERAL Joins (PostgreSQL extension)
-- ─────────────────────────────────────────────────────────────

-- LATERAL lets a subquery reference columns from the preceding FROM item.
-- Think of it as a correlated subquery that can return multiple rows.

-- 11a. Latest 2 enrollments per student
SELECT s.first_name, s.last_name, lat.course_id, lat.enrolled_at
FROM   students s
CROSS JOIN LATERAL (
    SELECT course_id, enrolled_at
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
    ORDER BY enrolled_at DESC
    LIMIT 2
) AS lat
ORDER BY s.last_name, lat.enrolled_at DESC;

-- 11b. Useful pattern: LATERAL with aggregation
SELECT
    d.department_name,
    top_s.first_name   AS top_student,
    top_s.gpa          AS top_gpa
FROM departments d
CROSS JOIN LATERAL (
    SELECT first_name, gpa
    FROM   students s
    WHERE  s.department_id = d.department_id
    ORDER BY gpa DESC
    LIMIT 1
) top_s
ORDER BY top_s.gpa DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 12: CTE Materialization Hint (PostgreSQL 12+)
-- ─────────────────────────────────────────────────────────────

-- By default PostgreSQL 12+ folds CTEs into the query plan (not materialized).
-- Use MATERIALIZED to force execution once and cache results.
WITH dept_avg AS MATERIALIZED (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT s.first_name, s.gpa, ROUND(da.avg_gpa::NUMERIC, 2) AS dept_avg
FROM   students s
JOIN   dept_avg da ON da.department_id = s.department_id
ORDER BY s.gpa DESC;

-- NOT MATERIALIZED = allow the planner to fold it inline (default post-12)
WITH dept_avg AS NOT MATERIALIZED (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT count(*) FROM dept_avg;

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

-- 13c. Enrollment rate by department using stacked CTEs
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
    COALESCE(de.enrolled_students, 0) AS enrolled_students,
    ROUND(
        100.0 * COALESCE(de.enrolled_students, 0) / ds.total_students
    , 1) AS enrollment_pct
FROM   dept_students ds
JOIN   departments d  ON d.department_id  = ds.department_id
LEFT JOIN dept_enrolled de ON de.department_id = ds.department_id
ORDER BY enrollment_pct DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 14: Cleanup
-- ─────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS employees_demo CASCADE;
