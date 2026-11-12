# Module 06 — Guided Lab
## Subqueries

**Prerequisites:** Module 06 lecture notes read; `06_subqueries.sql` executed on your platform.  
**Estimated time:** 60–90 minutes  
**Platforms:** MySQL 8.0 (Part A) · PostgreSQL 16 (Part B) · SQL Server 2022 (Part C)

---

## Learning Objectives

By the end of this lab you will be able to:
- Write scalar subqueries in WHERE and SELECT
- Use IN, NOT IN, EXISTS, NOT EXISTS
- Demonstrate the NOT IN NULL trap and fix it
- Write correlated subqueries
- Build derived tables and CTEs for multi-step logic

---

## Part A — MySQL 8.0

### Step A1 — Scalar subquery in WHERE

```sql
USE university;

-- Students above school average GPA
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students)
ORDER BY gpa DESC;
```

**Note the inner query:** `SELECT AVG(gpa) FROM students` returns a single number. That number is substituted into the WHERE clause before the outer query filters rows.

**Try:** Change `>` to `<`. Which students appear now?

---

### Step A2 — Scalar subquery in SELECT

```sql
SELECT
    first_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2) AS school_avg,
    ROUND(gpa - (SELECT AVG(gpa) FROM students), 2) AS diff_from_avg
FROM students
ORDER BY diff_from_avg DESC;
```

**Observation:** Every row shows the same `school_avg` value (it's a constant from the subquery). Students with positive `diff_from_avg` are above average; negative means below.

---

### Step A3 — IN vs EXISTS (same result, different mechanism)

```sql
-- Version A: IN
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (SELECT DISTINCT student_id FROM enrollments);

-- Version B: EXISTS
SELECT first_name, last_name
FROM   students s
WHERE  EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id
);
```

Run both. The row counts should match. IN materializes the enrollment IDs and checks membership; EXISTS tests row-by-row.

---

### Step A4 — The NOT IN NULL trap

```sql
-- Setup: the employees table has NULLs in manager_id (Amara is CEO)

-- Step 1: Look at the manager_id column
SELECT employee_id, first_name, manager_id FROM employees;

-- Step 2: Try NOT IN (UNSAFE)
SELECT first_name
FROM   employees
WHERE  employee_id NOT IN (SELECT manager_id FROM employees);
-- Expected: employees who are NOT managers (Sofia, Yuki, Ibrahim)
-- Actual: 0 rows — because NULL is in the list

-- Step 3: Fix with IS NOT NULL guard
SELECT first_name
FROM   employees
WHERE  employee_id NOT IN (
    SELECT manager_id FROM employees WHERE manager_id IS NOT NULL
);
-- Now returns the correct 3 rows

-- Step 4: Fix with NOT EXISTS (preferred)
SELECT e.first_name
FROM   employees e
WHERE  NOT EXISTS (
    SELECT 1 FROM employees m WHERE m.manager_id = e.employee_id
);
```

**Key takeaway:** The NULL in Amara's `manager_id = NULL` row causes `NOT IN` to silently return 0 rows. `NOT EXISTS` is not affected.

---

### Step A5 — Correlated subquery

```sql
-- Count each student's enrollments
SELECT
    s.first_name,
    s.last_name,
    (SELECT COUNT(*)
     FROM   enrollments e
     WHERE  e.student_id = s.student_id) AS course_count
FROM   students s
ORDER BY course_count DESC;
```

**Understand the correlation:** The inner query uses `s.student_id` — a column from the outer query's current row. For each student row, the inner query runs with that student's ID.

---

### Step A6 — Derived table

```sql
-- Compute avg GPA per department, then filter
SELECT dept_stats.department_name, dept_stats.avg_gpa
FROM (
    SELECT
        d.department_name,
        ROUND(AVG(s.gpa), 2) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
) AS dept_stats
WHERE dept_stats.avg_gpa > 3.50
ORDER BY dept_stats.avg_gpa DESC;
```

**Rule:** The derived table MUST have an alias (`AS dept_stats`). Without it, MySQL returns an error.

**Try:** Remove the alias. Observe the error message.

---

### Step A7 — CTE

```sql
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
WHERE  avg_gpa > 3.50
ORDER BY avg_gpa DESC;
```

Compare to Step A6. The logic is identical; the CTE version defines the named query first, making the main SELECT cleaner.

---

### Step A8 — Multiple CTEs

```sql
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
```

`active_per_dept` can reference `active_students` because CTEs are defined in order. The main SELECT then joins the departments list to the aggregated result.

---

## Part B — PostgreSQL 16

### Step B1 — ROUND with ::NUMERIC cast

```sql
\c university

-- PostgreSQL requires ::NUMERIC for ROUND with AVG result
SELECT
    first_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students)::NUMERIC, 2) AS school_avg
FROM   students
ORDER BY gpa DESC;
```

Without the `::NUMERIC` cast, PostgreSQL may raise: `function round(double precision, integer) does not exist`.

---

### Step B2 — CTE with MATERIALIZED hint

```sql
-- PostgreSQL 12+ supports materialization hints
WITH top_students AS MATERIALIZED (
    SELECT student_id, first_name, gpa
    FROM   students
    WHERE  gpa >= 3.80
)
SELECT ts.first_name, d.department_name, ts.gpa
FROM   top_students ts
JOIN   students      s  ON s.student_id    = ts.student_id
JOIN   departments   d  ON d.department_id = s.department_id
ORDER BY ts.gpa DESC;
```

`MATERIALIZED` forces the CTE to execute once and cache its result. Without it, PostgreSQL's optimizer may inline the CTE (treat it like a derived table). Use `MATERIALIZED` when the CTE is referenced multiple times or when inlining causes a performance regression.

---

### Step B3 — NOT EXISTS anti-join

```sql
-- Students in no courses
SELECT first_name, last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY last_name;
```

---

### Step B4 — Correlated subquery per row

```sql
-- Top student per department (correlated)
SELECT s.first_name, s.last_name, s.gpa, s.department_id
FROM   students s
WHERE  s.gpa = (
    SELECT MAX(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = s.department_id
)
ORDER BY s.department_id;
```

---

### Step B5 — Subquery in HAVING

```sql
SELECT
    d.department_name,
    COUNT(s.student_id) AS students
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.student_id) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(student_id) AS cnt
        FROM   students
        GROUP BY department_id
    ) AS dept_counts
)
ORDER BY students DESC;
```

---

## Part C — SQL Server 2022

### Step C1 — Scalar subquery and AVG integer trap

```sql
USE university;
GO

-- AVG on FLOAT column works fine; CAST ensures accuracy for INT columns
SELECT
    first_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2) AS school_avg
FROM   students
ORDER BY gpa DESC;
GO
```

---

### Step C2 — HAVING with derived table (CAST for AVG)

```sql
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.student_id) > (
    SELECT AVG(CAST(dept_count AS FLOAT))
    FROM (
        SELECT COUNT(student_id) AS dept_count
        FROM   students
        GROUP BY department_id
    ) AS dept_sizes
)
ORDER BY student_count DESC;
GO
```

**SQL Server note:** `dept_count` is an `INT`. Without `CAST(… AS FLOAT)`, `AVG(dept_count)` truncates to an integer. For example, AVG of 3 and 4 would be 3, not 3.5.

---

### Step C3 — CTE with ISNULL

```sql
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
    ISNULL(a.active_count, 0) AS active_students
FROM   departments    d
LEFT JOIN active_per_dept a ON a.department_id = d.department_id
ORDER BY active_students DESC;
GO
```

---

### Step C4 — NOT EXISTS vs NOT IN

```sql
-- NOT IN (unsafe)
SELECT first_name FROM dbo.employees
WHERE  employee_id NOT IN (SELECT manager_id FROM dbo.employees);
GO

-- NOT EXISTS (safe)
SELECT e.first_name FROM dbo.employees e
WHERE  NOT EXISTS (
    SELECT 1 FROM dbo.employees m WHERE m.manager_id = e.employee_id
);
GO
```

---

## Lab Summary

| Concept | Key rule |
|---------|---------|
| Scalar subquery | Must return exactly one row and one column |
| NOT IN + NULL | Returns 0 rows if subquery contains NULLs |
| NOT EXISTS | NULL-safe; preferred for anti-joins |
| Correlated subquery | References outer query column; runs per outer row |
| Derived table | Subquery in FROM; alias is mandatory |
| CTE | Named query defined with WITH; reusable in same statement |
| PostgreSQL ROUND | Requires `::NUMERIC` cast on AVG result |
| SQL Server AVG | CAST INT column to FLOAT for fractional averages |

---

## Check Your Understanding

1. What does a scalar subquery return, and what happens if it returns more rows?
2. Why does `NOT IN` with a NULL-containing list return 0 rows?
3. What is the difference between EXISTS and IN?
4. Why does a derived table require an alias?
5. When can the second CTE reference the first in a WITH clause?
