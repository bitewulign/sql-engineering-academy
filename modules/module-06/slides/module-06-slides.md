---
marp: true
theme: default
paginate: true
style: |
  :root {
    --color-bg:      #0f1117;
    --color-surface: #1a1d2e;
    --color-accent:  #7c6af7;
    --color-accent2: #3ecf8e;
    --color-warn:    #e96f4a;
    --color-text:    #e2e8f0;
    --color-muted:   #94a3b8;
  }
  section {
    background: var(--color-bg);
    color: var(--color-text);
    font-family: 'Segoe UI', system-ui, sans-serif;
    padding: 48px 56px;
  }
  h1 { color: var(--color-accent); font-size: 2rem; margin-bottom: 0.4em; }
  h2 { color: var(--color-accent2); font-size: 1.5rem; }
  h3 { color: var(--color-accent); font-size: 1.1rem; }
  code, pre {
    background: var(--color-surface);
    color: var(--color-accent2);
    border-radius: 6px;
  }
  pre { padding: 1em; font-size: 0.82rem; }
  table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
  th { background: var(--color-surface); color: var(--color-accent); padding: 8px 12px; }
  td { padding: 7px 12px; border-bottom: 1px solid #2a2d3e; }
  .warn  { color: var(--color-warn); }
  .good  { color: var(--color-accent2); }
  .muted { color: var(--color-muted); font-size: 0.85rem; }
---

# Module 06
## Subqueries

Scalar · IN / NOT IN · EXISTS · Correlated · Derived Tables · CTEs

---

# What Is a Subquery?

A SELECT statement **nested inside** another SQL statement.

```sql
SELECT first_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students);
--             ↑ subquery — evaluated first
```

The database runs the **inner query first**, then uses its result in the outer query.

---

# Subquery Types

| Type | Location | Returns | Example |
|------|----------|---------|---------|
| **Scalar** | SELECT / WHERE / HAVING | 1 row × 1 col | `WHERE gpa > (SELECT AVG(gpa)…)` |
| **Column list** | WHERE IN | 1 col, N rows | `WHERE id IN (SELECT id…)` |
| **Correlated** | WHERE / SELECT | Varies | References outer column |
| **Derived table** | FROM | Table | `FROM (SELECT …) AS t` |
| **CTE** | WITH | Table | `WITH name AS (SELECT …)` |

---

# Scalar Subquery

Returns **exactly one column, one row**. Acts as a constant in its context.

```sql
-- In WHERE
WHERE gpa > (SELECT AVG(gpa) FROM students)

-- In SELECT
SELECT
    first_name,
    gpa,
    (SELECT AVG(gpa) FROM students) AS school_avg
FROM students;
```

⚠️ If the subquery returns **more than one row** → runtime error.

Use `MAX()`, `MIN()`, `AVG()`, or `LIMIT 1` to guarantee one row.

---

# IN with Subquery

Checks whether a value is **in the list** returned by the subquery.

```sql
-- Students with at least one enrollment
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (
    SELECT DISTINCT student_id FROM enrollments
);
```

Equivalent to: "return a row only if the student's ID appears in the enrollment list."

The subquery returns a **single-column list**. The outer query does a membership test.

---

# NOT IN — The NULL Trap

The most common silent data bug in SQL.

```sql
-- If manager_id contains NULLs → returns 0 rows
SELECT first_name FROM employees
WHERE  employee_id NOT IN (SELECT manager_id FROM employees);
```

**Why:**
- SQL three-valued logic: `x <> NULL` = **UNKNOWN**
- `NOT IN (2, 3, NULL)` → `1 <> 2 AND 1 <> 3 AND 1 <> NULL`
- `1 <> NULL` = UNKNOWN → entire expression = UNKNOWN
- No row passes

---

# NOT IN — The Fix

**Option 1:** Filter NULLs from the subquery

```sql
WHERE employee_id NOT IN (
    SELECT manager_id FROM employees
    WHERE  manager_id IS NOT NULL
)
```

**Option 2:** Use NOT EXISTS (preferred)

```sql
WHERE NOT EXISTS (
    SELECT 1 FROM employees m
    WHERE  m.manager_id = e.employee_id
)
```

NOT EXISTS is **always NULL-safe** — it tests row existence, not value equality.

---

# EXISTS and NOT EXISTS

`EXISTS` returns TRUE if the subquery finds **any matching row**.

```sql
-- Students WITH enrollments
WHERE EXISTS (
    SELECT 1 FROM enrollments e
    WHERE  e.student_id = s.student_id
)

-- Students WITHOUT enrollments (anti-join)
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e
    WHERE  e.student_id = s.student_id
)
```

The `SELECT 1` is convention — the value selected doesn't matter, only whether a row exists.

---

# IN vs EXISTS

| | IN | EXISTS |
|-|-------|--------|
| **NULL safe** | ⚠️ NOT IN dangerous | ✅ Always safe |
| **Short circuit** | No | Yes (stops at first match) |
| **Columns returned** | 1 col | Any (not used) |
| **Correlated** | Usually no | Usually yes |
| **Performance** | Optimizer-dependent | Optimizer-dependent |

Modern optimizers treat both as semi-joins internally. The semantic difference matters most with **NOT IN vs NOT EXISTS**.

---

# Correlated Subquery

A subquery that **references a column from the outer query**.

```sql
-- Count each student's enrollments (per row)
SELECT
    s.first_name,
    (SELECT COUNT(*)
     FROM   enrollments e
     WHERE  e.student_id = s.student_id)  -- ← s.student_id from outer
         AS course_count
FROM students s;
```

The inner query uses `s.student_id` — a value that **changes with each outer row**. The inner query runs once per outer row.

---

# Correlated Subquery — Top Per Group

Find the best student in each department:

```sql
SELECT s.first_name, s.gpa, s.department_id
FROM   students s
WHERE  s.gpa = (
    SELECT MAX(s2.gpa)         -- max GPA in this department
    FROM   students s2
    WHERE  s2.department_id = s.department_id  -- ← correlated
);
```

For each outer student `s`, the inner query finds the maximum GPA in `s`'s department. The outer WHERE keeps only students who match that maximum (handles ties naturally).

---

# Derived Table

A **subquery in the FROM clause** — treated as a temporary table.

```sql
SELECT dept_stats.department_name, dept_stats.avg_gpa
FROM (
    SELECT
        d.department_name,
        ROUND(AVG(s.gpa), 2) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
) AS dept_stats                    -- ← ALIAS IS MANDATORY
WHERE dept_stats.avg_gpa > 3.50;
```

The derived table exists only for this query. The alias is **required** on all three platforms.

---

# CTE — Common Table Expression

A **named temporary result** defined with `WITH`. Lives at the top of the statement.

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
WHERE  avg_gpa > 3.50;
```

Same result as the derived table — cleaner to read, and the CTE can be referenced **more than once**.

---

# Multiple CTEs

```sql
WITH
  cte1 AS (
      SELECT department_id, COUNT(*) AS active_count
      FROM   students WHERE is_active = 1
      GROUP BY department_id
  ),
  cte2 AS (
      SELECT AVG(CAST(active_count AS FLOAT)) AS avg_active
      FROM   cte1          -- ← cte2 can reference cte1
  )
SELECT d.department_name, c1.active_count
FROM   departments d
JOIN   cte1 c1 ON c1.department_id = d.department_id
WHERE  c1.active_count > (SELECT avg_active FROM cte2);
```

Each CTE is separated by a comma. Later CTEs can reference earlier ones.

---

# Subquery in HAVING

Compare an aggregate to a dynamically computed threshold:

```sql
SELECT d.department_name, COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.student_id) > (
    SELECT AVG(dept_count)
    FROM (
        SELECT COUNT(student_id) AS dept_count
        FROM   students GROUP BY department_id
    ) AS dept_sizes
);
```

The subquery inside HAVING produces the average department size; each group is compared to it.

---

# Platform Summary

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| Scalar subquery | ✅ | ✅ | ✅ |
| IN / NOT IN | ✅ | ✅ | ✅ |
| EXISTS / NOT EXISTS | ✅ | ✅ | ✅ |
| Derived table alias | Required | Required | Required |
| CTE (WITH) | ✅ 8.0+ | ✅ | ✅ |
| ROUND cast | No | `::NUMERIC` | No |
| AVG INT trap | No | No | CAST needed |
| CTE MATERIALIZED | No | ✅ 12+ | No |

---

# Common Mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Scalar subquery → multiple rows | Runtime error | Use MAX/MIN/AVG or LIMIT 1 |
| `NOT IN` with NULLs | 0 rows silently | Add `IS NOT NULL` or use `NOT EXISTS` |
| Derived table missing alias | Syntax error | Add `AS alias_name` |
| CTE not available in MySQL 5.x | Syntax error | Upgrade to 8.0 or use derived table |
| PostgreSQL ROUND without cast | Type error | Use `::NUMERIC` |
| SQL Server AVG on INT | Truncated result | `CAST(col AS FLOAT)` before AVG |

---

# Module 06 — Key Takeaways

✅ **Scalar subquery** = one row, one column  
✅ **NOT IN + NULL** = 0 rows; use **NOT EXISTS** instead  
✅ **EXISTS** = NULL-safe existence check; `SELECT 1` convention  
✅ **Correlated subquery** = references outer query column; runs per row  
✅ **Derived table** = subquery in FROM; alias mandatory  
✅ **CTE** = named query with WITH; reusable; better readability  
✅ **Multiple CTEs** = comma-separated; later CTEs reference earlier ones  

---

# Module 07 Preview
## Window Functions

- `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()` — ranking rows
- `PARTITION BY` — restart ranking per group
- `LAG()` / `LEAD()` — access previous / next row values
- Running totals with `SUM() OVER (ORDER BY …)`
- Moving averages with `ROWS BETWEEN`
- Replace correlated ranking subqueries with cleaner window syntax

<span class="muted">Subqueries (Module 06) are prerequisites — window functions solve many of the same problems more elegantly.</span>
