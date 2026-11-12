---
marp: true
theme: default
paginate: true
style: |
  :root {
    --color-bg: #0f1117;
    --color-surface: #1a1d2e;
    --color-accent: #7c6af7;
    --color-accent2: #3ecf8e;
    --color-warn: #e96f4a;
    --color-text: #e2e8f0;
    --color-muted: #8892a4;
    --color-border: #2d3148;
  }
  section {
    background: var(--color-bg);
    color: var(--color-text);
    font-family: 'Inter', 'Segoe UI', sans-serif;
    padding: 48px 60px;
  }
  h1 { color: var(--color-accent); font-size: 2.0em; margin-bottom: 0.2em; }
  h2 { color: var(--color-accent2); font-size: 1.4em; border-bottom: 2px solid var(--color-border); padding-bottom: 0.3em; }
  h3 { color: var(--color-accent); font-size: 1.1em; }
  code { background: var(--color-surface); color: var(--color-accent2); padding: 2px 6px; border-radius: 4px; font-size: 0.88em; }
  pre { background: var(--color-surface); border-left: 4px solid var(--color-accent); padding: 20px; border-radius: 8px; overflow: auto; }
  pre code { background: transparent; padding: 0; font-size: 0.82em; color: #cdd6f4; }
  table { width: 100%; border-collapse: collapse; font-size: 0.85em; }
  th { background: var(--color-surface); color: var(--color-accent); padding: 10px 14px; text-align: left; }
  td { padding: 9px 14px; border-bottom: 1px solid var(--color-border); }
  tr:nth-child(even) td { background: rgba(255,255,255,0.03); }
  strong { color: var(--color-accent2); }
  em { color: var(--color-warn); }
  .warn { color: var(--color-warn); font-weight: bold; }
  .ok { color: var(--color-accent2); font-weight: bold; }
  ul { line-height: 1.8; }
  li { margin-bottom: 0.2em; }
---

<!-- Slide 01: Title -->
# Module 10
## Subqueries & CTEs

**Scalar · Correlated · EXISTS · WITH · Recursive**

MySQL 8.0 · PostgreSQL 16 · SQL Server 2022

---

<!-- Slide 02: Why Subqueries? -->
## Why Subqueries?

Sometimes the answer to "which rows?" depends on another query.

```sql
-- Without subquery: cannot filter by school average in one pass
-- With a scalar subquery: computed inline
SELECT first_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students);
```

Subqueries let you:
- Use aggregates in WHERE (not normally allowed)
- Compute values per row using outer-row context
- Build multi-step logic inside a single statement

---

<!-- Slide 03: Subquery Types -->
## Subquery Types

| Type | Returns | Location |
|------|---------|----------|
| **Scalar** | 1 row × 1 col | SELECT, WHERE, HAVING |
| **Row** | 1 row × N cols | WHERE with row constructor |
| **Table (derived)** | N rows × M cols | FROM clause |
| **Correlated** | Depends on outer row | WHERE, SELECT, HAVING |
| **EXISTS** | TRUE or FALSE | WHERE |

---

<!-- Slide 04: Scalar Subquery -->
## Scalar Subquery

Returns exactly one value. Used anywhere a single value is valid.

```sql
-- In WHERE
SELECT first_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students);

-- In SELECT list — appended to every row
SELECT
    first_name, gpa,
    (SELECT AVG(gpa) FROM students) AS school_avg
FROM students;
```

> If a scalar subquery returns **more than one row** → runtime error.  
> If it returns **zero rows** → NULL.

---

<!-- Slide 05: Derived Table (Table Subquery) -->
## Derived Table in FROM

A subquery in FROM acts as a named result set (must have an alias).

```sql
-- Step 1: compute department averages
-- Step 2: join students to that inline table
SELECT s.first_name, s.gpa, d.dept_avg
FROM   students s
JOIN (
    SELECT department_id, AVG(gpa) AS dept_avg
    FROM   students
    GROUP BY department_id
) AS d ON d.department_id = s.department_id
WHERE s.gpa > d.dept_avg;
```

The derived table `d` is computed **once** and treated like a real table.

> <span class="warn">Alias is required on all derived tables in every platform.</span>

---

<!-- Slide 06: Correlated Subquery -->
## Correlated Subquery

The inner query references a column from the outer query.  
It runs **once per outer row**.

```sql
SELECT s.first_name, s.gpa
FROM   students s
WHERE  s.gpa > (
    SELECT AVG(s2.gpa)         -- references s.department_id
    FROM   students s2
    WHERE  s2.department_id = s.department_id
);
```

| Non-correlated | Correlated |
|---------------|-----------|
| Runs **once** | Runs **once per outer row** |
| No reference to outer | References outer column |
| Fast | Can be slow on large tables |

> Rewrite correlated subqueries as JOINs or CTEs for large tables.

---

<!-- Slide 07: EXISTS -->
## EXISTS and NOT EXISTS

`EXISTS` returns TRUE if the subquery returns **at least one row**.  
It **stops scanning** as soon as the first row is found.

```sql
-- Students with at least one enrollment
WHERE EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id
)

-- Students with NO enrollments (NULL-safe)
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id
)
```

The SELECT list of an EXISTS subquery does not matter — `SELECT 1`, `SELECT *`, `SELECT 42` are all equivalent.

---

<!-- Slide 08: NOT IN NULL Trap -->
## NOT IN vs NOT EXISTS

```sql
-- DANGEROUS: if student_id in enrollments has any NULL...
WHERE student_id NOT IN (SELECT student_id FROM enrollments)
-- → returns 0 rows! (three-valued logic)
```

**Why?**  
`x NOT IN (1, 2, NULL)` expands to:  
`x <> 1 AND x <> 2 AND x <> NULL`  
`x <> NULL` = **UNKNOWN** → entire expression = **UNKNOWN** → row excluded

```sql
-- SAFE: NULL-proof
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id
)
```

> <span class="warn">Use NOT EXISTS instead of NOT IN whenever the subquery column might contain NULLs.</span>

---

<!-- Slide 09: WITH Clause (CTE) -->
## Common Table Expressions (CTE)

Name a subquery. Reference it by name. Use it multiple times.

```sql
WITH dept_avg AS (
    SELECT department_id, AVG(gpa) AS avg_gpa
    FROM   students
    GROUP BY department_id
)
SELECT
    s.first_name,
    s.gpa,
    da.avg_gpa AS dept_avg,
    s.gpa - da.avg_gpa AS diff
FROM   students s
JOIN   dept_avg da ON da.department_id = s.department_id
ORDER BY diff DESC;
```

**Advantages over inline subqueries:**
- Written once, referenced multiple times
- Readable top-down structure
- Easier to debug — test each CTE in isolation

---

<!-- Slide 10: Stacked CTEs -->
## Stacking Multiple CTEs

```sql
WITH
dept_stats AS (           -- Step 1: per-department aggregates
    SELECT department_id,
           COUNT(*) AS cnt, AVG(gpa) AS avg_gpa
    FROM students GROUP BY department_id
),
dept_ranked AS (          -- Step 2: rank by avg GPA (references Step 1)
    SELECT *,
           RANK() OVER (ORDER BY avg_gpa DESC) AS gpa_rank
    FROM dept_stats
)
SELECT d.department_name, dr.avg_gpa, dr.gpa_rank
FROM   dept_ranked dr
JOIN   departments d ON d.department_id = dr.department_id
ORDER BY gpa_rank;
```

Each CTE can reference CTEs defined **before it** in the same WITH block.

---

<!-- Slide 11: CTE for Window Function Filtering -->
## Top N per Group — Canonical Pattern

Window functions cannot appear in WHERE. Solution: wrap in CTE.

```sql
WITH ranked AS (
    SELECT
        student_id, first_name, department_id, gpa,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY gpa DESC
        ) AS rn
    FROM students
)
SELECT student_id, first_name, department_id, gpa
FROM   ranked
WHERE  rn = 1;   -- top student per department
```

> This is the standard solution for "Top N per group" in all platforms.

---

<!-- Slide 12: Recursive CTE — Structure -->
## Recursive CTE

Used for hierarchical data: org charts, category trees, path finding.

```sql
WITH RECURSIVE cte_name AS (  -- MySQL / PostgreSQL
    -- Anchor: base case (no self-reference)
    SELECT … WHERE parent_id IS NULL

    UNION ALL

    -- Recursive step: joins the CTE to itself
    SELECT … FROM source JOIN cte_name ON …
    WHERE depth < 20   -- depth guard
)
SELECT * FROM cte_name;
```

**SQL Server:** Use `WITH` only — `WITH RECURSIVE` is a syntax error.

---

<!-- Slide 13: Recursive CTE — Org Hierarchy Example -->
## Org Hierarchy — Live Demo

```sql
WITH RECURSIVE org_tree AS (
    -- Anchor: CEO
    SELECT employee_id, name, title, manager_id,
           0 AS depth, CAST(name AS VARCHAR(500)) AS path
    FROM   employees WHERE manager_id IS NULL

    UNION ALL

    -- Each employee under their manager
    SELECT e.employee_id, e.name, e.title, e.manager_id,
           t.depth + 1,
           CONCAT(t.path, ' → ', e.name)
    FROM   employees e
    JOIN   org_tree t ON t.employee_id = e.manager_id
    WHERE  t.depth < 20
)
SELECT depth, CONCAT(REPEAT('  ', depth), name) AS hierarchy
FROM   org_tree ORDER BY path;
```

---

<!-- Slide 14: Platform Comparison — WITH RECURSIVE -->
## Recursive CTE — Platform Differences

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| Keyword | `WITH RECURSIVE` | `WITH RECURSIVE` | `WITH` (no RECURSIVE) |
| Depth limit | `cte_max_recursion_depth` (default 1000) | None built-in | `OPTION (MAXRECURSION N)` (default 100) |
| Cycle detection | Depth counter | Array path check | Depth counter |
| CTE in DML | No | Yes (writeable) | Yes (CTE target) |

```sql
-- SQL Server: control depth per query
SELECT * FROM org_tree
OPTION (MAXRECURSION 50);
```

---

<!-- Slide 15: Infinite Recursion Guard -->
## Preventing Infinite Recursion

If data has a cycle (A reports to B, B reports to A):

```sql
-- MySQL: session setting
SET SESSION cte_max_recursion_depth = 100;

-- PostgreSQL: use a depth counter
WHERE t.depth < 20   -- guard in recursive member

-- PostgreSQL advanced: array cycle detection
WHERE e.id != ALL(o.id_path)   -- array membership

-- SQL Server: query hint
OPTION (MAXRECURSION 50)
```

> <span class="warn">Always include a depth guard. Never set MAXRECURSION 0 without an explicit WHERE depth check.</span>

---

<!-- Slide 16: LATERAL (PostgreSQL) / APPLY (SQL Server) -->
## LATERAL / CROSS APPLY

A LATERAL subquery can reference columns from the preceding FROM item — correlated subquery that returns multiple rows.

```sql
-- PostgreSQL: latest 2 enrollments per student
SELECT s.first_name, lat.course_id
FROM   students s
CROSS JOIN LATERAL (
    SELECT course_id
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
    ORDER BY enrolled_at DESC
    LIMIT 2
) AS lat;

-- SQL Server equivalent: CROSS APPLY
SELECT s.first_name, ca.course_id
FROM   students s
CROSS APPLY (
    SELECT TOP 2 course_id
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
    ORDER BY enrolled_at DESC
) AS ca;
```

---

<!-- Slide 17: Subquery vs CTE vs JOIN -->
## Subquery vs CTE vs JOIN

| Scenario | Use |
|----------|-----|
| Filter by aggregate | Subquery or CTE |
| Membership test | EXISTS or IN |
| NOT membership (NULL-safe) | NOT EXISTS |
| Multi-step logic, readable | CTE |
| Same result used twice | CTE |
| Filter window result | CTE wrapping window |
| Hierarchical data | Recursive CTE |
| Performance-critical | JOIN (better planner hints) |

> Write for correctness first. Measure before optimizing.

---

<!-- Slide 18: Relational Division -->
## Relational Division

"Find students enrolled in EVERY course" — the double NOT EXISTS pattern:

```sql
SELECT s.student_id, s.first_name
FROM   students s
WHERE  NOT EXISTS (
    -- Is there any course …
    SELECT c.course_id FROM courses c
    WHERE NOT EXISTS (
        -- … that this student is NOT enrolled in?
        SELECT 1 FROM enrollments e
        WHERE e.student_id = s.student_id
          AND e.course_id  = c.course_id
    )
)
```

Translation: students for whom there is no unenrolled course.

---

<!-- Slide 19: Common Mistakes -->
## Common Mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Scalar subquery returns > 1 row | Runtime error | Add `LIMIT 1` or use derived table |
| `NOT IN` with nullable column | 0 rows silently | Use `NOT EXISTS` |
| Correlated subquery on large table | Very slow (N × scan) | Rewrite as JOIN or window function |
| Recursive CTE with no depth guard | Max recursion error | Add `WHERE depth < N` |
| `WITH RECURSIVE` on SQL Server | Syntax error | Use `WITH` only |
| Referencing a later CTE | Error | CTEs reference only earlier ones |
| Forgetting alias on derived table | Syntax error | All derived tables need an alias |

---

<!-- Slide 20: Key Takeaways & Module 11 Preview -->
## Key Takeaways

**Scalar subquery:** one value, used anywhere a value fits — returns NULL when empty

**Correlated subquery:** runs once per outer row — fast for small tables, slow for large ones

**NOT IN NULL trap:** `NOT IN` returns 0 rows if subquery has any NULL → always use `NOT EXISTS`

**CTE (WITH):** name a subquery, reference it multiple times, stack them for multi-step logic

**Top N per Group:** ROW_NUMBER in a CTE, filter with `WHERE rn <= N`

**Recursive CTE:** anchor + UNION ALL + recursive member + depth guard

**Platform note:** SQL Server uses `WITH` (no RECURSIVE); MySQL/PostgreSQL use `WITH RECURSIVE`

---

## Module 11 Preview

### Stored Procedures & Functions

- **CREATE PROCEDURE** — parameterized, reusable SQL blocks
- **CREATE FUNCTION** — scalar and table-valued functions
- **Flow control** — IF/ELSE, CASE, LOOP, WHILE, CURSOR
- **Error handling** — SIGNAL (MySQL), RAISE (PG), THROW (SQL Server)
- **Platform differences** — PL/SQL vs T-SQL vs PL/pgSQL

> Stored procedures move complex logic into the database — closer to the data, enforced for every caller.
