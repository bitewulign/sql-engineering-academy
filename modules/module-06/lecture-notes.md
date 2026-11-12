# Module 06 — Lecture Notes
## Subqueries

---

## 1. What Is a Subquery?

A **subquery** (also called an inner query or nested query) is a SELECT statement written inside another SQL statement. The outer statement uses the subquery's result as a value, a list, or a table.

```sql
-- Structure
SELECT …
FROM   …
WHERE  col = (SELECT … FROM … WHERE …);
--            ↑ subquery
```

The database evaluates the inner query first, then uses its result in the outer query.

---

## 2. Scalar Subquery

A **scalar subquery** returns exactly one column and one row — a single value. It can appear anywhere a value expression is legal: SELECT list, WHERE, HAVING, ON, or even in a computed column.

```sql
-- In WHERE: students above average GPA
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students);

-- In SELECT: compare each student's GPA to the average
SELECT
    first_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2) AS school_avg,
    gpa - (SELECT AVG(gpa) FROM students)      AS diff_from_avg
FROM students;
```

**Constraint:** A scalar subquery that returns more than one row causes a runtime error. Use aggregate functions (MAX, MIN, AVG, COUNT) or LIMIT 1 to ensure a single row.

---

## 3. Subquery in WHERE with IN

`IN (subquery)` checks whether a value appears in the subquery's result set.

```sql
-- Students enrolled in any course in the 'CS' department
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (
    SELECT e.student_id
    FROM   enrollments e
    JOIN   courses     c ON c.course_id = e.course_id
    WHERE  c.department_code = 'CS'
);
```

The subquery returns a list of student IDs. The outer query returns students whose ID is in that list. Equivalent to a semi-join.

---

## 4. NOT IN — The NULL Trap

`NOT IN` has a critical behavior with NULLs that returns 0 rows silently.

```sql
-- If ANY value in the subquery result is NULL:
-- NOT IN returns 0 rows for every outer row
SELECT first_name FROM students
WHERE  student_id NOT IN (SELECT manager_id FROM employees);
-- If manager_id contains NULLs → result is ALWAYS EMPTY
```

**Why:** SQL three-valued logic. `1 NOT IN (2, 3, NULL)` → `1 <> NULL` → UNKNOWN → the row is filtered out. When any element is NULL, every comparison produces UNKNOWN, so no row passes.

**Fix:** Use `NOT EXISTS` or filter NULLs from the subquery:

```sql
-- Safe version 1: NOT EXISTS
SELECT first_name FROM students s
WHERE  NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.manager_id = s.student_id
);

-- Safe version 2: filter NULLs from subquery
SELECT first_name FROM students
WHERE  student_id NOT IN (
    SELECT manager_id FROM employees WHERE manager_id IS NOT NULL
);
```

---

## 5. EXISTS and NOT EXISTS

`EXISTS (subquery)` returns TRUE if the subquery produces at least one row. It does not care about the values returned — `SELECT 1` is the convention.

```sql
-- Students who are enrolled in at least one course
SELECT first_name, last_name
FROM   students s
WHERE  EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
);

-- Students with NO enrollments
SELECT first_name, last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
);
```

**EXISTS vs IN:**
- EXISTS is NULL-safe (the subquery never contributes NULLs to a comparison)
- EXISTS can short-circuit: once one row is found, it stops scanning
- IN materializes the full subquery result; EXISTS evaluates row by row

---

## 6. Correlated Subquery

A **correlated subquery** references a column from the outer query. It executes once per outer row (conceptually), making it more powerful but potentially slower.

```sql
-- For each student, find their rank within their department by GPA
-- (before window functions — the subquery approach)
SELECT
    s.first_name,
    s.gpa,
    s.department_id,
    (SELECT COUNT(*) + 1
     FROM   students s2
     WHERE  s2.department_id = s.department_id   -- ← correlated
       AND  s2.gpa > s.gpa) AS dept_rank
FROM students s;
```

The inner query uses `s.department_id` and `s.gpa` from the outer row. For each outer student row, the inner query runs with that student's values.

**Common use:** EXISTS/NOT EXISTS anti-join (Section 5), computing per-row aggregates, finding the latest record per group.

---

## 7. Subquery in HAVING

Aggregate comparisons can use scalar subqueries in HAVING.

```sql
-- Departments with more students than the average across all departments
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
);
```

The innermost subquery computes per-department counts; the middle subquery averages them; HAVING compares each department's count to that average.

---

## 8. Derived Tables (Subquery in FROM)

A **derived table** is a subquery used as a table in the FROM clause. It must always have an alias.

```sql
-- Average GPA by department, then find departments above the school average
SELECT dept_stats.department_name, dept_stats.avg_gpa
FROM (
    SELECT
        d.department_name,
        AVG(s.gpa) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
) AS dept_stats                                    -- alias required
WHERE dept_stats.avg_gpa > (SELECT AVG(gpa) FROM students);
```

The derived table `dept_stats` exists only for the duration of this query. All three platforms require the alias; PostgreSQL and SQL Server also allow naming individual columns.

---

## 9. Common Table Expressions (CTEs)

A **CTE** (Common Table Expression) is a named, temporary result set defined with `WITH`. It improves readability and can be referenced multiple times in the same query.

```sql
-- Same query as Section 8, rewritten as CTE
WITH dept_stats AS (
    SELECT
        d.department_name,
        AVG(s.gpa) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
)
SELECT department_name, avg_gpa
FROM   dept_stats
WHERE  avg_gpa > (SELECT AVG(gpa) FROM students)
ORDER BY avg_gpa DESC;
```

**Multiple CTEs:**

```sql
WITH
  cte1 AS (SELECT …),
  cte2 AS (SELECT … FROM cte1 …)   -- cte2 can reference cte1
SELECT … FROM cte2;
```

**CTE vs derived table:**
- CTE is more readable, especially for multi-step logic
- CTE can be referenced more than once in the main query
- Derived table must be re-written every time it is used
- Performance is usually identical (the optimizer treats them the same)

---

## 10. CTE Support by Platform

```sql
-- MySQL 8.0 (CTEs supported since 8.0; not in 5.x)
WITH top_students AS (
    SELECT student_id, first_name, gpa
    FROM   students
    WHERE  gpa >= 3.80
)
SELECT ts.first_name, d.department_name
FROM   top_students ts
JOIN   departments  d ON d.department_id = ...;

-- PostgreSQL 16 (CTEs are fully supported; can be materialized)
WITH dept_averages AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT s.first_name, s.gpa, da.avg_gpa
FROM   students      s
JOIN   dept_averages da ON da.department_id = s.department_id;

-- SQL Server 2022 (CTEs fully supported; can reference multiple times)
WITH active_students AS (
    SELECT * FROM students WHERE is_active = 1
)
SELECT department_id, COUNT(*) AS active_count
FROM   active_students
GROUP BY department_id;
```

---

## 11. Subquery vs JOIN

Both can answer the same question. Use judgment:

| Scenario | Prefer |
|----------|--------|
| Simple existence check ("students who have enrollments") | EXISTS or JOIN |
| Anti-join ("students with no enrollments") | NOT EXISTS (NULL-safe) |
| Multi-step logic building on a previous aggregation | CTE or derived table |
| Need columns from both tables in SELECT | JOIN |
| Need only a single value comparison | Scalar subquery |
| Complex correlated logic per row | Correlated subquery |

**Performance note:** Modern optimizers often rewrite IN as a semi-join and EXISTS as an equivalent plan. Profile on real data before optimizing based on subquery form alone.

---

## 12. Subquery Pitfalls

### Pitfall 1 — Scalar subquery returns more than one row
```sql
-- Error: subquery returns more than 1 row
WHERE gpa = (SELECT gpa FROM students WHERE department_id = 1)
-- Fix: use MAX/MIN/AVG, or add LIMIT 1
WHERE gpa = (SELECT MAX(gpa) FROM students WHERE department_id = 1)
```

### Pitfall 2 — NOT IN with NULLs
```sql
-- Always returns 0 rows if subquery contains NULLs
WHERE student_id NOT IN (SELECT manager_id FROM employees)
-- Fix: WHERE student_id NOT IN (SELECT manager_id FROM employees WHERE manager_id IS NOT NULL)
-- Or: NOT EXISTS
```

### Pitfall 3 — Derived table missing alias
```sql
-- Error: Every derived table must have its own alias
FROM (SELECT …)        -- ← missing alias
FROM (SELECT …) AS t   -- ← correct
```

### Pitfall 4 — Column reference ambiguity in correlated subquery
```sql
-- If outer and inner tables share a column name, qualify both
WHERE e.student_id = s.student_id   -- e = inner, s = outer alias
```

---

## 13. Logical Processing with Subqueries

Subqueries follow the same logical processing order as the main query:

```
Outer query logical order:
FROM (derived tables / CTEs evaluated here)
→ WHERE (scalar / correlated subqueries evaluated here)
→ GROUP BY
→ HAVING (scalar / correlated subqueries evaluated here)
→ SELECT (scalar subqueries evaluated here)
→ ORDER BY
→ LIMIT / FETCH
```

Correlated subqueries in WHERE execute once per outer candidate row, before GROUP BY. Scalar subqueries in SELECT execute once per output row, after GROUP BY.

---

## 14. Summary Table

| Subquery type | Location | Rows returned | Correlated? | Use |
|---------------|----------|--------------|-------------|-----|
| Scalar | SELECT / WHERE / HAVING | Exactly 1 | Optional | Single-value comparison |
| IN list | WHERE | 1 column, N rows | No | Membership test |
| NOT IN list | WHERE | 1 column, N rows | No | Exclusion (avoid NULLs) |
| EXISTS | WHERE | Any (presence only) | Yes (typical) | Existence check |
| NOT EXISTS | WHERE | Any (absence test) | Yes (typical) | Anti-join |
| Derived table | FROM | Table | No | Multi-step logic |
| CTE | WITH … | Table | No | Reusable named query |
