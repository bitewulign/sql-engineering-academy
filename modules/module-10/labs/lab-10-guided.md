# Module 10 — Guided Lab
## Subqueries & CTEs

**Estimated time:** 90–120 minutes  
**Platforms covered:** Part A — MySQL 8.0 · Part B — PostgreSQL 16 · Part C — SQL Server 2022

---

## Prerequisites

- `university` database exists and is populated with students, departments, courses, enrollments
- You have SELECT, CREATE TABLE, DROP TABLE privileges

---

## Part A — MySQL 8.0

```sql
USE university;
```

---

### A-01: Scalar Subquery — School Average

Run the following query:

```sql
SELECT
    first_name,
    last_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2) AS school_avg
FROM students
ORDER BY gpa DESC
LIMIT 10;
```

**Task:** Modify this query to add a `diff` column showing how far above or below the school average each student is. Order by `diff` descending.

**Question:** If a student has the same GPA as the school average, what will `diff` be?

---

### A-02: Correlated Subquery

```sql
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
```

**Task:** Add a `is_above_avg` column using `CASE WHEN s.gpa > (SELECT …) THEN 'YES' ELSE 'NO' END`.

**Question:** This correlated subquery executes once per student row. If the students table has 100 rows, how many times does the inner query execute?

---

### A-03: EXISTS vs NOT EXISTS

```sql
-- Students with at least one enrollment
SELECT s.first_name, s.last_name, 'has enrollments' AS status
FROM   students s
WHERE  EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id)

UNION ALL

-- Students with no enrollments
SELECT s.first_name, s.last_name, 'no enrollments' AS status
FROM   students s
WHERE  NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id);
```

**Task:** Run both halves separately. Count the rows in each set. Do they add up to the total number of students?

**Question:** What would happen if you replaced `NOT EXISTS` with `NOT IN (SELECT student_id FROM enrollments)`? Try inserting a NULL student_id into enrollments and observe the result.

---

### A-04: Table Subquery (Derived Table)

```sql
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    d.dept_avg,
    dep.department_name
FROM students s
JOIN (
    SELECT department_id, ROUND(AVG(gpa), 2) AS dept_avg
    FROM   students
    GROUP BY department_id
) AS d ON d.department_id = s.department_id
JOIN departments dep ON dep.department_id = s.department_id
WHERE s.gpa > d.dept_avg
ORDER BY dep.department_name, s.gpa DESC;
```

**Task:** How many students are above their department average? Run `SELECT COUNT(*) FROM (…) AS sub` wrapping the full query above.

**Key insight:** The derived table `d` executes once and is treated as a table for the join — more efficient than repeating the subquery in both SELECT and WHERE.

---

### A-05: First CTE

Rewrite the A-04 query using a CTE instead of an inline derived table:

```sql
WITH dept_avg AS (
    SELECT department_id, ROUND(AVG(gpa), 2) AS dept_avg
    FROM   students
    GROUP BY department_id
)
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    d.dept_avg,
    dep.department_name
FROM   students s
JOIN   dept_avg d   ON d.department_id  = s.department_id
JOIN   departments dep ON dep.department_id = s.department_id
WHERE  s.gpa > d.dept_avg
ORDER BY dep.department_name, s.gpa DESC;
```

**Question:** The query produces the same result. What advantage does the CTE provide over the inline derived table from A-04?

---

### A-06: Stacked CTEs + Window Functions

```sql
WITH
-- Step 1: rank students within each department by GPA
dept_ranked AS (
    SELECT
        student_id,
        first_name,
        last_name,
        department_id,
        gpa,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rn
    FROM students
),
-- Step 2: keep only top 2 per department
top_two AS (
    SELECT * FROM dept_ranked WHERE rn <= 2
)
SELECT
    dep.department_name,
    t.first_name,
    t.last_name,
    t.gpa,
    t.rn AS dept_rank
FROM   top_two t
JOIN   departments dep ON dep.department_id = t.department_id
ORDER BY dep.department_name, t.rn;
```

**Task:** Extend this to 3 CTEs. Add a third CTE `dept_summary` that computes the average GPA of the top 2 students per department. Then JOIN it in the final SELECT to show that value alongside each student.

---

### A-07: Recursive CTE — Org Hierarchy

```sql
-- Demo data
DROP TABLE IF EXISTS lab_org;

CREATE TABLE lab_org (
    id         INT          NOT NULL AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    title      VARCHAR(100) NOT NULL,
    manager_id INT          NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_lab_org_mgr FOREIGN KEY (manager_id) REFERENCES lab_org(id)
);

INSERT INTO lab_org (id, name, title, manager_id) VALUES
    (1, 'Raj Patel',     'CEO',              NULL),
    (2, 'Sofia Chen',    'CTO',              1),
    (3, 'Omar Farouq',   'CFO',              1),
    (4, 'Amara Diallo',  'VP Engineering',   2),
    (5, 'Carlos Rivera', 'Lead Engineer',    4),
    (6, 'Priya Sharma',  'Engineer',         5);

-- Traverse the full hierarchy
WITH RECURSIVE org AS (
    SELECT id, name, title, manager_id,
           0 AS depth,
           CAST(name AS CHAR(500)) AS path
    FROM   lab_org
    WHERE  manager_id IS NULL

    UNION ALL

    SELECT e.id, e.name, e.title, e.manager_id,
           o.depth + 1,
           CONCAT(o.path, ' → ', e.name)
    FROM   lab_org e
    JOIN   org o ON o.id = e.manager_id
    WHERE  o.depth < 10
)
SELECT depth, CONCAT(REPEAT('  ', depth), name) AS hierarchy, title
FROM   org
ORDER BY path;
```

**Task A:** Count the total number of levels in the hierarchy.

**Task B:** Modify the recursive CTE to find only the reports under Sofia Chen (id = 2), including herself as the root.

**Task C:** Add a column `team_size` that counts how many people report into each node (this requires a second CTE joining back to the first).

```sql
DROP TABLE IF EXISTS lab_org;
```

---

## Part B — PostgreSQL 16

```sql
\c university
```

---

### B-01: LATERAL Subquery

```sql
-- Latest 2 enrollments per student, using LATERAL
SELECT s.first_name, s.last_name, lat.course_id
FROM   students s
CROSS JOIN LATERAL (
    SELECT course_id
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
    ORDER BY enrolled_at DESC
    LIMIT 2
) AS lat
ORDER BY s.last_name, lat.course_id;
```

**Question:** What is the difference between `CROSS JOIN LATERAL` and `JOIN LATERAL`?  
(`CROSS JOIN LATERAL` includes outer rows even when the LATERAL subquery returns nothing; `JOIN LATERAL` acts like an INNER JOIN and excludes students with no enrollments.)

---

### B-02: CTE Materialization Hint

```sql
-- Force PostgreSQL to execute the CTE once and cache the result
EXPLAIN (ANALYZE, COSTS)
WITH dept_avg AS MATERIALIZED (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT s.first_name, s.gpa
FROM   students s
JOIN   dept_avg da ON da.department_id = s.department_id
WHERE  s.gpa > da.avg_gpa;
```

**Task:** Run the same EXPLAIN without `MATERIALIZED`. Compare the query plans. Does PostgreSQL inline the CTE or materialize it by default?

**Expected observation:** PostgreSQL 12+ folds non-MATERIALIZED CTEs into the plan by default. `MATERIALIZED` forces a separate CTE scan node.

---

### B-03: Recursive CTE with Array Path (PostgreSQL-specific)

```sql
DROP TABLE IF EXISTS lab_org CASCADE;

CREATE TABLE lab_org (
    id         SERIAL       PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    title      VARCHAR(100) NOT NULL,
    manager_id INT          REFERENCES lab_org(id)
);

INSERT INTO lab_org (id, name, title, manager_id)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 'Raj Patel',     'CEO',              NULL),
    (2, 'Sofia Chen',    'CTO',              1),
    (3, 'Omar Farouq',   'CFO',              1),
    (4, 'Amara Diallo',  'VP Engineering',   2),
    (5, 'Carlos Rivera', 'Lead Engineer',    4),
    (6, 'Priya Sharma',  'Engineer',         5);

WITH RECURSIVE org AS (
    SELECT
        id,
        name,
        title,
        0            AS depth,
        ARRAY[id]    AS id_path   -- PostgreSQL arrays track the ancestry
    FROM lab_org
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.id,
        e.name,
        e.title,
        o.depth + 1,
        o.id_path || e.id
    FROM   lab_org e
    JOIN   org o ON o.id = e.manager_id
    WHERE  o.depth < 10
      AND  e.id != ALL(o.id_path)   -- cycle guard using array membership
)
SELECT depth, repeat('  ', depth) || name AS hierarchy, id_path
FROM   org
ORDER BY id_path;

DROP TABLE IF EXISTS lab_org CASCADE;
```

**Key insight:** The `e.id != ALL(o.id_path)` guard uses PostgreSQL's native array membership to detect cycles without a depth-only counter.

---

### B-04: Date Series with Recursive CTE

```sql
-- Generate the last 7 days + count students enrolled each day
WITH RECURSIVE date_range AS (
    SELECT (CURRENT_DATE - INTERVAL '6 days')::DATE AS d
    UNION ALL
    SELECT (d + INTERVAL '1 day')::DATE
    FROM   date_range
    WHERE  d < CURRENT_DATE
)
SELECT
    dr.d AS enrollment_date,
    TO_CHAR(dr.d, 'Dy') AS day_name,
    COUNT(e.student_id) AS enrollments_on_day
FROM   date_range dr
LEFT JOIN enrollments e ON e.enrolled_at::DATE = dr.d
GROUP BY dr.d
ORDER BY dr.d;
```

**Task:** Modify this to show the last 30 days grouped by week.

---

### B-05: CTE for DML — PostgreSQL Writeable CTE

```sql
-- PostgreSQL allows CTEs in INSERT, UPDATE, DELETE and even
-- chains of modifications in one statement.

-- Demo: flag students below school average with a note
DROP TABLE IF EXISTS student_flags;

CREATE TABLE student_flags (
    student_id  INT PRIMARY KEY,
    flag        VARCHAR(50)
);

WITH below_avg AS (
    SELECT student_id
    FROM   students
    WHERE  gpa < (SELECT AVG(gpa) FROM students)
)
INSERT INTO student_flags (student_id, flag)
SELECT student_id, 'below_school_avg'
FROM   below_avg
ON CONFLICT (student_id) DO UPDATE SET flag = EXCLUDED.flag;

SELECT count(*) AS flagged_students FROM student_flags;

DROP TABLE IF EXISTS student_flags;
```

---

## Part C — SQL Server 2022

```sql
USE university;
GO
```

---

### C-01: Scalar Subquery and CTE Equivalence

Run both queries and verify they return the same result:

```sql
-- Scalar subquery version
SELECT first_name, last_name, gpa,
       ROUND((SELECT AVG(gpa) FROM students), 2) AS school_avg
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students)
ORDER BY gpa DESC;
GO

-- CTE version
WITH school_stats AS (
    SELECT AVG(gpa) AS avg_gpa FROM students
)
SELECT s.first_name, s.last_name, s.gpa,
       ROUND(ss.avg_gpa, 2) AS school_avg
FROM   students s
CROSS JOIN school_stats ss
WHERE  s.gpa > ss.avg_gpa
ORDER BY s.gpa DESC;
GO
```

**Question:** Which version is more readable? In which version is the AVG computed fewer times?

---

### C-02: Recursive CTE — No RECURSIVE Keyword

```sql
IF OBJECT_ID('dbo.lab_org', 'U') IS NOT NULL DROP TABLE dbo.lab_org;
GO

CREATE TABLE dbo.lab_org (
    id         INT IDENTITY(1,1) NOT NULL,
    name       NVARCHAR(100)     NOT NULL,
    title      NVARCHAR(100)     NOT NULL,
    manager_id INT               NULL,
    CONSTRAINT pk_lab_org     PRIMARY KEY (id),
    CONSTRAINT fk_lab_org_mgr FOREIGN KEY (manager_id) REFERENCES dbo.lab_org(id)
);
GO

INSERT INTO dbo.lab_org (name, title, manager_id) VALUES
    (N'Raj Patel',     N'CEO',              NULL),
    (N'Sofia Chen',    N'CTO',              1),
    (N'Omar Farouq',   N'CFO',              1),
    (N'Amara Diallo',  N'VP Engineering',   2),
    (N'Carlos Rivera', N'Lead Engineer',    4),
    (N'Priya Sharma',  N'Engineer',         5);
GO

-- Full hierarchy — NOTE: no RECURSIVE keyword
WITH org AS (
    SELECT
        id,
        name,
        title,
        manager_id,
        0                                   AS depth,
        CAST(name AS NVARCHAR(2000))        AS path
    FROM dbo.lab_org
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.id,
        e.name,
        e.title,
        e.manager_id,
        o.depth + 1,
        CAST(o.path + N' → ' + e.name AS NVARCHAR(2000))
    FROM   dbo.lab_org e
    JOIN   org o ON o.id = e.manager_id
)
SELECT
    REPLICATE(N'  ', depth) + name AS hierarchy,
    title,
    depth,
    path
FROM   org
ORDER BY path
OPTION (MAXRECURSION 50);
GO
```

**Task:** Modify this to show only employees at depth 2 or deeper (skipping CEO and direct reports).

---

### C-03: OUTPUT with CTE in UPDATE

```sql
IF OBJECT_ID('dbo.lab_audit', 'U') IS NOT NULL DROP TABLE dbo.lab_audit;
IF OBJECT_ID('dbo.lab_staging', 'U') IS NOT NULL DROP TABLE dbo.lab_staging;
GO

SELECT student_id, department_id, gpa
INTO   dbo.lab_staging
FROM   students;
GO

CREATE TABLE dbo.lab_audit (
    student_id INT          NOT NULL,
    old_gpa    DECIMAL(3,2) NOT NULL,
    new_gpa    DECIMAL(3,2) NOT NULL,
    changed_at DATETIME2    NOT NULL DEFAULT SYSDATETIME()
);
GO

-- Preview: students who would be updated
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   dbo.lab_staging
    GROUP BY department_id
)
SELECT ls.student_id, ls.gpa AS current_gpa, ROUND(da.avg_gpa, 2) AS dept_avg
FROM   dbo.lab_staging ls
JOIN   dept_avg da ON da.department_id = ls.department_id
WHERE  ls.gpa < da.avg_gpa;
GO

-- Actual update with OUTPUT to audit table
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   dbo.lab_staging
    GROUP BY department_id
)
UPDATE ls
SET    gpa = ROUND(da.avg_gpa, 2)
OUTPUT DELETED.student_id,
       DELETED.gpa  AS old_gpa,
       INSERTED.gpa AS new_gpa
INTO   dbo.lab_audit (student_id, old_gpa, new_gpa)
FROM   dbo.lab_staging ls
JOIN   dept_avg da ON da.department_id = ls.department_id
WHERE  ls.gpa < da.avg_gpa;
GO

SELECT COUNT(*) AS rows_audited FROM dbo.lab_audit;
SELECT * FROM dbo.lab_audit ORDER BY student_id;
GO

IF OBJECT_ID('dbo.lab_audit',   'U') IS NOT NULL DROP TABLE dbo.lab_audit;
IF OBJECT_ID('dbo.lab_staging', 'U') IS NOT NULL DROP TABLE dbo.lab_staging;
IF OBJECT_ID('dbo.lab_org',     'U') IS NOT NULL DROP TABLE dbo.lab_org;
GO
```

---

## Lab Wrap-Up

After completing all parts:

1. What is the key behavioral difference between `EXISTS` and `IN` when the subquery returns NULL values?
2. Write a single CTE that finds the department with the highest enrollment count. What would you need to change to find the top 3 departments?
3. How do you tell a SQL Server recursive CTE apart from a non-recursive one at a glance?
4. What does `OPTION (MAXRECURSION 0)` do in SQL Server? When is it safe to use?
5. In PostgreSQL, what is the difference between `WITH cte AS MATERIALIZED (…)` and `WITH cte AS NOT MATERIALIZED (…)`?
