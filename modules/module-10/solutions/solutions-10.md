# Module 10 — Solutions
## Subqueries & CTEs

> **Instructor only.** Do not distribute with learner-facing materials.

---

## Exercise 1

```sql
-- MySQL / PostgreSQL / SQL Server
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students)
ORDER BY gpa DESC;
```

---

## Exercise 2

```sql
-- MySQL
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2)       AS school_avg,
    ROUND(gpa - (SELECT AVG(gpa) FROM students), 2) AS diff
FROM students;

-- PostgreSQL (cast needed for ROUND)
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students)::NUMERIC, 2)              AS school_avg,
    ROUND((gpa - (SELECT AVG(gpa) FROM students))::NUMERIC, 2)      AS diff
FROM students;

-- SQL Server
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2)       AS school_avg,
    ROUND(gpa - (SELECT AVG(gpa) FROM students), 2) AS diff
FROM students;
```

---

## Exercise 3

```sql
-- All platforms
SELECT department_id, ROUND(AVG(gpa), 2) AS dept_avg
FROM   students
GROUP BY department_id
HAVING AVG(gpa) > (SELECT AVG(gpa) FROM students)
ORDER BY dept_avg DESC;
```

*Note: PostgreSQL requires the cast: `ROUND(AVG(gpa)::NUMERIC, 2)`*

---

## Exercise 4

```sql
-- MySQL / SQL Server
SELECT s.first_name, s.last_name, s.gpa, d.dept_avg
FROM   students s
JOIN (
    SELECT department_id, ROUND(AVG(gpa), 2) AS dept_avg
    FROM   students
    GROUP BY department_id
) AS d ON d.department_id = s.department_id
WHERE s.gpa > d.dept_avg
ORDER BY s.department_id, s.gpa DESC;

-- PostgreSQL
SELECT s.first_name, s.last_name, s.gpa, d.dept_avg
FROM   students s
JOIN (
    SELECT department_id, ROUND(AVG(gpa)::NUMERIC, 2) AS dept_avg
    FROM   students
    GROUP BY department_id
) AS d ON d.department_id = s.department_id
WHERE s.gpa > d.dept_avg
ORDER BY s.department_id, s.gpa DESC;
```

---

## Exercise 5 — Correlated subquery in SELECT list

```sql
-- MySQL
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((
        SELECT AVG(s2.gpa)
        FROM   students s2
        WHERE  s2.department_id = s.department_id
    ), 2) AS dept_avg
FROM students s;

-- PostgreSQL
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((
        SELECT AVG(s2.gpa)
        FROM   students s2
        WHERE  s2.department_id = s.department_id
    )::NUMERIC, 2) AS dept_avg
FROM students s;

-- SQL Server (identical to MySQL here)
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((
        SELECT AVG(s2.gpa)
        FROM   students s2
        WHERE  s2.department_id = s.department_id
    ), 2) AS dept_avg
FROM students s;
```

---

## Exercise 6 — EXISTS

```sql
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY s.last_name;
```

---

## Exercise 7 — NOT EXISTS

```sql
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY s.last_name;
```

---

## Exercise 8 — IN with subquery

```sql
SELECT course_name, credits
FROM   courses
WHERE  course_id IN (
    SELECT DISTINCT course_id FROM enrollments
)
ORDER BY course_name;
```

---

## Exercise 9 — CTE

```sql
WITH dept_summary AS (
    SELECT
        department_id,
        ROUND(AVG(gpa), 2) AS avg_gpa,
        COUNT(*)            AS student_count
    FROM students
    GROUP BY department_id
)
SELECT d.department_name, ds.avg_gpa, ds.student_count
FROM   dept_summary ds
JOIN   departments d ON d.department_id = ds.department_id
WHERE  ds.student_count > 2
ORDER BY ds.avg_gpa DESC;
```

*PostgreSQL: `ROUND(AVG(gpa)::NUMERIC, 2)`*

---

## Exercise 10 — Top student per department with ROW_NUMBER

```sql
-- MySQL / PostgreSQL / SQL Server
WITH ranked AS (
    SELECT
        student_id,
        first_name,
        last_name,
        department_id,
        gpa,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rn
    FROM students
)
SELECT d.department_name, r.first_name, r.last_name, r.gpa
FROM   ranked r
JOIN   departments d ON d.department_id = r.department_id
WHERE  r.rn = 1
ORDER BY r.gpa DESC;
```

---

## Exercise 11 — Stacked CTEs with RANK

```sql
WITH
dept_stats AS (
    SELECT
        department_id,
        COUNT(*)            AS student_count,
        ROUND(AVG(gpa), 2)  AS avg_gpa
    FROM students
    GROUP BY department_id
),
dept_ranked AS (
    SELECT
        department_id,
        student_count,
        avg_gpa,
        RANK() OVER (ORDER BY avg_gpa DESC) AS gpa_rank
    FROM dept_stats
)
SELECT
    d.department_name,
    dr.avg_gpa,
    dr.student_count,
    dr.gpa_rank
FROM dept_ranked dr
JOIN departments d ON d.department_id = dr.department_id
ORDER BY gpa_rank;
```

---

## Exercise 12 — Top 3 per department

```sql
WITH ranked AS (
    SELECT
        first_name,
        last_name,
        department_id,
        gpa,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rn
    FROM students
)
SELECT
    d.department_name,
    r.first_name,
    r.last_name,
    r.gpa,
    r.rn AS dept_rank
FROM ranked r
JOIN departments d ON d.department_id = r.department_id
WHERE r.rn <= 3
ORDER BY d.department_name, r.rn;
```

---

## Exercise 13 — Enrollment rate report

```sql
WITH
dept_total AS (
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
    dt.total_students,
    COALESCE(de.enrolled_students, 0)                                       AS enrolled_students,
    ROUND(100.0 * COALESCE(de.enrolled_students, 0) / dt.total_students, 1) AS enrollment_pct
FROM   dept_total dt
JOIN   departments d  ON d.department_id  = dt.department_id
LEFT JOIN dept_enrolled de ON de.department_id = dt.department_id
ORDER BY enrollment_pct DESC;
```

---

## Exercise 14 — Courses with no enrollments

```sql
SELECT c.course_id, c.course_name, c.credits
FROM   courses c
WHERE  NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.course_id = c.course_id
)
ORDER BY c.course_name;
```

---

## Exercise 15 — NOT EXISTS vs NOT IN

```sql
-- NOT EXISTS (NULL-safe — preferred)
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
      AND  e.course_id  = 1
)
ORDER BY s.last_name;

-- NOT IN (dangerous if enrollments.student_id has NULLs)
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  s.student_id NOT IN (
    SELECT student_id FROM enrollments WHERE course_id = 1
)
ORDER BY s.last_name;

-- Why NOT IN fails with NULLs:
-- NOT IN uses three-valued logic. For each outer student_id x:
--   x NOT IN (1, 2, NULL) is evaluated as:
--     x <> 1 AND x <> 2 AND x <> NULL
--   x <> NULL evaluates to UNKNOWN (not FALSE).
--   TRUE AND TRUE AND UNKNOWN = UNKNOWN (not TRUE).
--   The WHERE clause only passes rows where the condition is TRUE.
-- Result: ZERO rows returned for every outer student_id.
```

---

## Exercise 16 — Recursive CTE: Hierarchy

### Part A — Full hierarchy

```sql
-- MySQL 8.0 (WITH RECURSIVE)
WITH RECURSIVE org AS (
    SELECT
        id,
        name,
        title,
        manager_id,
        0                           AS depth,
        CAST(name AS CHAR(500))     AS path
    FROM org_demo
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.id,
        e.name,
        e.title,
        e.manager_id,
        o.depth + 1,
        CONCAT(o.path, ' → ', e.name)
    FROM   org_demo e
    JOIN   org o ON o.id = e.manager_id
    WHERE  o.depth < 20
)
SELECT depth, CONCAT(REPEAT('  ', depth), name) AS hierarchy, title, path
FROM   org
ORDER BY path;

-- SQL Server 2022 (WITH, no RECURSIVE)
WITH org AS (
    SELECT
        id,
        name,
        title,
        manager_id,
        0                                      AS depth,
        CAST(name AS NVARCHAR(2000))           AS path
    FROM org_demo
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.id,
        e.name,
        e.title,
        e.manager_id,
        o.depth + 1,
        CAST(o.path + N' → ' + e.name AS NVARCHAR(2000))
    FROM   org_demo e
    JOIN   org o ON o.id = e.manager_id
)
SELECT depth, REPLICATE(N'  ', depth) + name AS hierarchy, title, path
FROM   org
ORDER BY path
OPTION (MAXRECURSION 50);
```

### Part B — All reports under Sofia Chen (id = 2)

```sql
-- MySQL / PostgreSQL (WITH RECURSIVE)
WITH RECURSIVE reports AS (
    SELECT id, name, title, 0 AS depth
    FROM   org_demo
    WHERE  id = 2

    UNION ALL

    SELECT e.id, e.name, e.title, r.depth + 1
    FROM   org_demo e
    JOIN   reports r ON r.id = e.manager_id
    WHERE  r.depth < 10
)
SELECT depth, name, title FROM reports ORDER BY depth, name;

-- SQL Server (no RECURSIVE)
WITH reports AS (
    SELECT id, name, title, 0 AS depth
    FROM   org_demo
    WHERE  id = 2

    UNION ALL

    SELECT e.id, e.name, e.title, r.depth + 1
    FROM   org_demo e
    JOIN   reports r ON r.id = e.manager_id
)
SELECT depth, name, title FROM reports ORDER BY depth, name
OPTION (MAXRECURSION 20);
```

---

## Exercise 17 — Relational Division

```sql
-- Find students enrolled in EVERY course (double NOT EXISTS)
SELECT s.student_id, s.first_name, s.last_name
FROM   students s
WHERE  NOT EXISTS (
    -- Is there any course …
    SELECT c.course_id
    FROM   courses c
    WHERE  NOT EXISTS (
        -- … for which this student has no enrollment?
        SELECT 1
        FROM   enrollments e
        WHERE  e.student_id = s.student_id
          AND  e.course_id  = c.course_id
    )
)
ORDER BY s.last_name;
-- Translation: "students for whom there is no course they haven't enrolled in"
```

---

## Exercise 18 — 4-step CTE Analytics Pipeline

```sql
WITH
-- Step 1: per-student stats
student_stats AS (
    SELECT
        s.student_id,
        s.first_name,
        s.last_name,
        s.department_id,
        s.gpa,
        COUNT(e.course_id) AS enrollment_count
    FROM      students s
    LEFT JOIN enrollments e ON e.student_id = s.student_id
    GROUP BY  s.student_id, s.first_name, s.last_name, s.department_id, s.gpa
),
-- Step 2: per-department summary
dept_summary AS (
    SELECT
        department_id,
        COUNT(*)                   AS student_count,
        ROUND(AVG(gpa), 2)         AS avg_gpa,
        ROUND(AVG(enrollment_count), 2) AS avg_enrollments
    FROM student_stats
    GROUP BY department_id
),
-- Step 3: rank departments
dept_ranked AS (
    SELECT
        department_id,
        student_count,
        avg_gpa,
        avg_enrollments,
        RANK() OVER (ORDER BY avg_gpa DESC)         AS gpa_rank,
        RANK() OVER (ORDER BY avg_enrollments DESC)  AS enroll_rank
    FROM dept_summary
),
-- Step 4: add department name
dept_labeled AS (
    SELECT
        d.department_name,
        dr.student_count,
        dr.avg_gpa,
        dr.avg_enrollments,
        dr.gpa_rank,
        dr.enroll_rank
    FROM dept_ranked dr
    JOIN departments d ON d.department_id = dr.department_id
)
SELECT *
FROM   dept_labeled
ORDER BY gpa_rank;
```

*PostgreSQL: use `ROUND(AVG(gpa)::NUMERIC, 2)` throughout.*

---

## Inquiry Question Answers

**IQ 1 — Correlated vs non-correlated:**  
A non-correlated subquery has no reference to the outer query. It executes once and its result is reused for all outer rows. A correlated subquery references at least one outer column; it executes once per outer row. Performance: correlated subqueries are potentially O(N) scans of the inner table for each outer row.

**IQ 2 — NOT IN with NULLs:**  
SQL uses three-valued logic. `x NOT IN (1, 2, NULL)` expands to `x <> 1 AND x <> 2 AND x <> NULL`. Since `x <> NULL` is always UNKNOWN (never TRUE or FALSE), the entire expression evaluates to UNKNOWN. WHERE only passes TRUE rows, so zero rows qualify.

**IQ 3 — Scalar subquery returning zero rows:**  
Yes, a scalar subquery can return zero rows. In that case, the outer query receives NULL for that column. Only returning *more than one row* causes a runtime error.

**IQ 4 — CTE vs temporary table:**  
A CTE is scoped to a single statement and disappears after it executes. A temporary table persists for the duration of the session and can be indexed, have statistics collected on it, and be reused across multiple statements. Use a CTE for single-statement logic; use a temporary table when the intermediate result is large, needs an index, or is needed in multiple separate statements.

**IQ 5 — WITH RECURSIVE on SQL Server:**  
SQL Server does not recognize the `RECURSIVE` keyword. Writing `WITH RECURSIVE` in a SQL Server script causes a syntax error. All recursive CTEs on SQL Server use just `WITH`.

**IQ 6 — UNION vs UNION ALL in recursive CTE:**  
`UNION ALL` retains all rows at each step, which is correct for hierarchical traversal where the same path should not be collapsed. `UNION` removes duplicates at every recursion step — this can suppress valid hierarchy rows that happen to share the same column values, and it also adds a sort/dedup overhead at each step.

**IQ 7 — Leftmost prefix rule:**  
Index on `(dept_id, gpa, last_name)`:
- `WHERE dept_id = 1` → uses index ✅
- `WHERE dept_id = 1 AND gpa > 3.0` → uses index ✅
- `WHERE dept_id = 1 AND gpa > 3.0 AND last_name = 'Chen'` → uses index ✅
- `WHERE gpa > 3.0` → cannot use index (skips leading column) ❌
- `WHERE last_name = 'Chen'` → cannot use index (skips two leading columns) ❌

**IQ 8 — Real-world recursive CTE scenarios:**
1. **Org charts / management hierarchy** — finding all reports under a manager, computing span of control.
2. **Category trees** — an e-commerce site with Product → Subcategory → Category → Department hierarchy; recursive CTE traverses all ancestor/descendant categories of a node.

Both require an unknown depth of traversal that cannot be handled with a fixed number of JOINs. A recursive CTE handles arbitrary depth cleanly; a non-recursive approach requires multiple self-joins or application-side looping.
