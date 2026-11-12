# Module 10 — Lecture Notes
## Subqueries & CTEs

---

## 1. What Is a Subquery?

A **subquery** is a SELECT statement nested inside another SQL statement. The database executes the inner query and uses its result as part of the outer query.

```sql
-- Outer query uses the result of the inner query
SELECT first_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students);
--           └─── inner query returns one number ───┘
```

Subqueries can appear in:
- **WHERE** clause — to filter rows
- **SELECT** list — as a computed column value
- **FROM** clause — as a derived table (inline view)
- **HAVING** clause — to filter groups
- **JOIN … ON** condition

---

## 2. Scalar Subqueries

A **scalar subquery** returns exactly one row and one column. It can be used anywhere a single value is expected.

```sql
-- In WHERE
SELECT first_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students);

-- In SELECT list (adds the school average to every row)
SELECT
    first_name,
    gpa,
    (SELECT AVG(gpa) FROM students) AS school_avg,
    gpa - (SELECT AVG(gpa) FROM students) AS diff_from_avg
FROM students;

-- In HAVING
SELECT department_id, AVG(gpa) AS dept_avg
FROM   students
GROUP BY department_id
HAVING AVG(gpa) > (SELECT AVG(gpa) FROM students);
```

> If a scalar subquery returns more than one row, the database raises an error.  
> If it returns zero rows, it returns NULL.

---

## 3. Table Subqueries (Derived Tables / Inline Views)

A **table subquery** in the FROM clause acts as a temporary named result set. Every database requires it to have an alias.

```sql
-- Find students with above-department-average GPA
-- Step 1: compute department averages as a derived table
-- Step 2: join students to that derived table

SELECT s.first_name, s.gpa, d.dept_avg
FROM   students s
JOIN (
    SELECT department_id, AVG(gpa) AS dept_avg
    FROM   students
    GROUP BY department_id
) AS d ON d.department_id = s.department_id
WHERE s.gpa > d.dept_avg
ORDER BY s.department_id, s.gpa DESC;
```

The derived table `d` is computed once and treated like a real table for the outer query.

---

## 4. Non-Correlated vs Correlated Subqueries

### Non-correlated
The inner query runs **once** and produces a fixed result. It has no dependency on the outer query's current row.

```sql
-- AVG(gpa) is computed once from all students
SELECT first_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students);
```

### Correlated
The inner query references a column from the outer query. It runs **once per row** of the outer query.

```sql
-- For each student, compare their GPA to their OWN department's average
SELECT s.first_name, s.department_id, s.gpa
FROM   students s
WHERE  s.gpa > (
    SELECT AVG(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = s.department_id  -- s.department_id = outer column
);
```

**Performance:** correlated subqueries can be slow on large tables. A JOIN or CTE with window function is usually faster — but write correct SQL first, then optimize.

---

## 5. EXISTS and NOT EXISTS

`EXISTS` returns TRUE if the subquery returns at least one row; FALSE if it returns zero rows. It stops scanning as soon as the first row is found.

```sql
-- Students who have at least one enrollment
SELECT s.first_name
FROM   students s
WHERE  EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
);
```

`NOT EXISTS` returns TRUE if the subquery returns **zero** rows — a safe way to test absence.

```sql
-- Students with NO enrollments
SELECT s.first_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
);
```

### Why NOT EXISTS is safer than NOT IN

```sql
-- NOT IN trap: if enrollments.student_id has even one NULL,
-- the NOT IN predicate returns UNKNOWN for ALL outer rows → 0 results!
WHERE s.student_id NOT IN (SELECT student_id FROM enrollments)

-- NOT EXISTS: NULL-safe — it checks for the absence of a matching row,
-- and NULL rows simply don't match any condition
WHERE NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id)
```

> **Rule:** Prefer `NOT EXISTS` over `NOT IN` whenever the subquery column might contain NULLs.

---

## 6. IN with a Subquery

`IN` with a subquery is equivalent to multiple OR conditions:

```sql
-- Students in Computer Science or Mathematics departments
SELECT first_name
FROM   students
WHERE  department_id IN (
    SELECT department_id
    FROM   departments
    WHERE  department_name IN ('Computer Science', 'Mathematics')
);
```

For positive membership tests, `IN` and `EXISTS` are both safe. `IN` is simpler to read when the subquery is small. For large subqueries, `EXISTS` often performs better because it can short-circuit.

---

## 7. Subqueries in UPDATE and DELETE

Subqueries are frequently used to scope DML operations:

```sql
-- UPDATE: set GPA to department average for below-average students
UPDATE students
SET    gpa = (
    SELECT AVG(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = students.department_id
)
WHERE gpa < (
    SELECT AVG(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = students.department_id
);

-- DELETE: remove students with no enrollments (NULL-safe)
DELETE FROM students
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = students.student_id
);
```

---

## 8. Common Table Expressions (WITH)

A **CTE** names a subquery and makes it reusable within the same statement. It is defined once in a `WITH` block and can be referenced multiple times.

```sql
WITH dept_averages AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT
    s.first_name,
    s.gpa,
    d.avg_gpa AS dept_avg,
    s.gpa - d.avg_gpa AS diff
FROM   students s
JOIN   dept_averages d ON d.department_id = s.department_id
ORDER BY diff DESC;
```

**Benefits over inline subqueries:**
- Write the logic once, reference multiple times
- Readable, top-down structure
- Easier to debug — you can SELECT from the CTE in isolation

---

## 9. Stacking Multiple CTEs

Multiple CTEs can be chained in a single `WITH` block. Each CTE can reference the ones defined before it.

```sql
WITH
-- Step 1: department-level stats
dept_stats AS (
    SELECT
        department_id,
        COUNT(*)    AS student_count,
        AVG(gpa)    AS avg_gpa,
        MAX(gpa)    AS max_gpa
    FROM students
    GROUP BY department_id
),
-- Step 2: rank departments by average GPA
dept_ranked AS (
    SELECT
        department_id,
        avg_gpa,
        student_count,
        RANK() OVER (ORDER BY avg_gpa DESC) AS gpa_rank
    FROM dept_stats
)
-- Final: join to department names and show top 3
SELECT
    dep.department_name,
    dr.avg_gpa,
    dr.student_count,
    dr.gpa_rank
FROM   dept_ranked dr
JOIN   departments dep ON dep.department_id = dr.department_id
WHERE  dr.gpa_rank <= 3
ORDER BY dr.gpa_rank;
```

---

## 10. CTEs for Filtering Window Function Results

Window functions cannot appear in WHERE. The canonical fix is to wrap the window query in a CTE (or subquery) and filter outside:

```sql
WITH ranked AS (
    SELECT
        student_id,
        first_name,
        department_id,
        gpa,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rn
    FROM students
)
SELECT student_id, first_name, department_id, gpa
FROM   ranked
WHERE  rn = 1;   -- top student per department
```

This is the canonical **Top N per Group** pattern — using a CTE makes it readable.

---

## 11. Recursive CTEs

A **recursive CTE** references itself. It is used for hierarchical data: org charts, category trees, bill of materials, path finding.

### Structure

```sql
WITH RECURSIVE cte_name AS (
    -- Anchor member: base case (terminates recursion)
    SELECT … WHERE parent_id IS NULL

    UNION ALL

    -- Recursive member: joins the CTE to itself
    SELECT … FROM source JOIN cte_name ON …
)
SELECT * FROM cte_name;
```

### Example — organizational hierarchy

```sql
-- employees(employee_id, name, manager_id)
WITH RECURSIVE org_tree AS (
    -- Anchor: CEO has no manager
    SELECT employee_id, name, manager_id, 0 AS depth,
           CAST(name AS VARCHAR(1000)) AS path
    FROM   employees
    WHERE  manager_id IS NULL

    UNION ALL

    -- Recursive: employees under their manager
    SELECT e.employee_id, e.name, e.manager_id,
           t.depth + 1,
           CONCAT(t.path, ' → ', e.name)
    FROM   employees e
    JOIN   org_tree t ON t.employee_id = e.manager_id
)
SELECT depth, path, name
FROM   org_tree
ORDER BY path;
```

**Platform difference:** MySQL 8.0 and PostgreSQL require `WITH RECURSIVE`. SQL Server uses `WITH` — the keyword `RECURSIVE` is not needed and not supported.

---

## 12. Infinite Recursion Guard

Recursive CTEs can loop forever if the data has a cycle (employee is their own manager, or circular path).

```sql
-- MySQL / PostgreSQL: set max recursion depth
SET SESSION cte_max_recursion_depth = 100;  -- MySQL
SET max_recursion_depth = 100;              -- alternative MySQL syntax

-- PostgreSQL: no built-in depth limit; control with depth counter
-- SQL Server: MAXRECURSION hint (default 100, 0 = unlimited)
WITH org_tree AS (…)
SELECT * FROM org_tree
OPTION (MAXRECURSION 50);   -- SQL Server
```

Always include a `depth` counter in recursive CTEs and add a `WHERE depth < 20` or similar guard.

---

## 13. Subquery vs CTE vs JOIN — When to Use Each

| Scenario | Recommendation |
|----------|---------------|
| Filter by aggregate (above average) | Subquery or CTE |
| Membership test (exists in another table) | EXISTS or IN |
| NOT membership (safe) | NOT EXISTS |
| Complex multi-step logic | CTE (readable, debuggable) |
| Same result set needed twice | CTE (define once, reference twice) |
| Filter window function result | CTE wrapping the window query |
| Hierarchical / tree data | Recursive CTE |
| Performance-critical large table | JOIN (planner optimizes better) |
| Simple look-up | Scalar subquery |

---

## 14. Common Mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Scalar subquery returns > 1 row | Runtime error | Add GROUP BY or LIMIT 1; use table subquery instead |
| NOT IN with nullable column | Returns 0 rows silently | Use NOT EXISTS |
| Correlated subquery on large table | Very slow (N × inner scan) | Rewrite as JOIN or window function |
| Recursive CTE without depth guard | Infinite loop / max recursion error | Add depth counter and WHERE depth < N |
| SQL Server `WITH RECURSIVE` | Syntax error | SQL Server: use `WITH` only (no RECURSIVE) |
| Referencing later CTE from earlier CTE | Error | CTEs can only reference CTEs defined before them in the same WITH block |
| Forgetting alias on derived table | SQL error | All derived tables in FROM must have an alias |
