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

# Module 05
## Joining Tables

INNER · LEFT · RIGHT · FULL OUTER · CROSS · SELF

---

# Why Joins?

Relational databases store data in **separate tables** to avoid repetition.

Joins **reassemble** related data at query time.

```
students         enrollments        courses
─────────        ───────────        ───────
student_id  ──►  student_id         course_id
first_name       course_id  ──►     course_name
department_id    grade              credits
```

One query. Three tables. Any combination you need.

---

# Join Types Overview

| Join | What it returns |
|------|----------------|
| **INNER JOIN** | Only matched rows (both sides) |
| **LEFT JOIN** | All left rows + matched right (NULLs if no match) |
| **RIGHT JOIN** | All right rows + matched left (NULLs if no match) |
| **FULL OUTER JOIN** | All rows from both sides; NULLs for unmatched |
| **CROSS JOIN** | Every row from left × every row from right |
| **SELF JOIN** | A table joined to itself (via two aliases) |

---

# INNER JOIN

Returns only rows **where a match exists on both sides**.

```sql
SELECT s.first_name, d.department_name
FROM   students   s
INNER JOIN departments d
  ON   s.department_id = d.department_id;
```

```
students (8 rows)      departments (4 rows)
  ○ student A  ──────►  dept 1
  ○ student B  ──────►  dept 2
  ○ student C           ← no dept  (excluded)
  ○ student D  ──────►  dept 1
```

Unassigned students are **excluded**.

---

# LEFT JOIN

Returns **all rows from the left table**; NULLs where no right match.

```sql
SELECT s.first_name,
       COALESCE(d.department_name, 'Unassigned') AS dept
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id;
```

```
student C → department_name = NULL → COALESCE → 'Unassigned'
```

Unassigned students **appear**. Missing right data = NULL.

---

# Anti-Join Pattern

Find rows in the left table with **no match** in the right table.

```sql
-- Students with no department
SELECT s.first_name, s.last_name
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.department_id IS NULL;
```

**How it works:**
1. LEFT JOIN runs — unmatched students get `d.*` = NULL
2. WHERE filters to only the NULL rows

The result = the "gap" between students and departments.

---

# ON vs WHERE with LEFT JOIN

This is the most commonly misunderstood part of LEFT JOIN.

| Filter location | Effect |
|----------------|--------|
| `ON … AND right.col = 'X'` | Controls **which right rows match**; unmatched left rows still appear |
| `WHERE right.col = 'X'` | Filters **the result**; removes rows where right cols are NULL |

```sql
-- WHERE: excludes students not in Tech Hall (like INNER JOIN)
LEFT JOIN departments d ON … WHERE d.building = 'Tech Hall'

-- ON: all students appear; non-Tech-Hall dept columns = NULL
LEFT JOIN departments d ON … AND d.building = 'Tech Hall'
```

---

# Zero-Safe COUNT with LEFT JOIN

```sql
-- departments LEFT JOIN students
-- A department with 0 students produces: s.student_id = NULL
```

| Expression | Result for empty dept | Correct? |
|------------|----------------------|----------|
| `COUNT(*)` | **1** | ❌ |
| `COUNT(s.student_id)` | **0** | ✅ |

```sql
SELECT d.department_name,
       COUNT(s.student_id) AS students   -- skips NULLs
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name;
```

**Rule:** Always reference the right-side PK in COUNT() after a LEFT JOIN.

---

# FULL OUTER JOIN

Returns **all rows from both tables**; NULLs where no match on either side.

```sql
-- PostgreSQL / SQL Server (native support)
SELECT s.first_name, d.department_name
FROM   students   s
FULL OUTER JOIN departments d
  ON   s.department_id = d.department_id;
```

Result includes:
- Matched students + their departments
- Students with no department (`d.*` = NULL)
- Departments with no students (`s.*` = NULL)

---

# FULL OUTER JOIN in MySQL

MySQL **does not support** FULL OUTER JOIN natively.

**Simulation: LEFT JOIN UNION RIGHT JOIN**

```sql
SELECT s.first_name, d.department_name
FROM   students s
LEFT JOIN departments d ON s.department_id = d.department_id

UNION

SELECT s.first_name, d.department_name
FROM   students s
RIGHT JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL;
```

UNION removes duplicates. The WHERE on the second SELECT avoids re-including already-matched rows.

---

# CROSS JOIN

Produces the **Cartesian product** — every left row paired with every right row.

```sql
SELECT s.first_name, d.department_name
FROM   students   s
CROSS JOIN departments d;
```

**Row count = students × departments**

```
6 students × 4 departments = 24 rows
```

**Use cases:** scheduling matrices, test data generation, combinatorics.
**Caution:** large tables × large tables = enormous result sets.

---

# Three-Table JOIN

Chain multiple JOINs by following the foreign key path.

```sql
SELECT s.first_name, c.course_name, e.grade
FROM   students    s
JOIN   enrollments e ON e.student_id = s.student_id
JOIN   courses     c ON c.course_id  = e.course_id
ORDER BY s.last_name, c.course_name;
```

```
students ──► enrollments ──► courses
(1 row)      (N rows each)   (1 per enrollment)
```

A student enrolled in 3 courses returns 3 rows.

---

# SELF JOIN

A table joined **to itself** to relate rows within the same table.

**Use case:** Employee–manager hierarchy where both are in one table.

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name  VARCHAR(60),
    manager_id  INT REFERENCES employees(employee_id)
);

SELECT e.first_name AS employee,
       COALESCE(m.first_name, '(CEO)') AS manager
FROM   employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

**Two aliases are required:** `e` = employee role; `m` = manager role.

---

# SELF JOIN — Org Chart

```
Amara  (CEO — no manager)
  ├── Priya
  │     ├── Sofia
  │     └── Yuki
  └── Carlos
        └── Ibrahim
```

The self join reconstructs this tree in flat SQL output:

```
employee   | manager
-----------|----------
Amara      | (CEO)
Priya      | Amara
Carlos     | Amara
Sofia      | Priya
Yuki       | Priya
Ibrahim    | Carlos
```

---

# Platform Summary

| Feature | MySQL | PostgreSQL | SQL Server |
|---------|-------|-----------|------------|
| INNER JOIN | ✅ | ✅ | ✅ |
| LEFT / RIGHT JOIN | ✅ | ✅ | ✅ |
| FULL OUTER JOIN | ❌ (simulate) | ✅ | ✅ |
| CROSS JOIN | ✅ | ✅ | ✅ |
| SELF JOIN | ✅ | ✅ | ✅ |
| USING(col) | ✅ | ✅ | ⚠️ limited |
| NULLS FIRST/LAST | ❌ | ✅ | ❌ |
| NULL substitute | IFNULL / COALESCE | COALESCE | ISNULL / COALESCE |

---

# Common Mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| `COUNT(*)` after LEFT JOIN | Zero-student depts show 1 | Use `COUNT(right_table.pk)` |
| WHERE on right-side column | Loses all unmatched left rows | Move filter to ON clause |
| Missing alias on SELF JOIN | Ambiguous column error | Use two distinct aliases |
| FULL OUTER JOIN in MySQL | Syntax error | Use LEFT UNION RIGHT pattern |
| No join condition on CROSS JOIN | Accidentally created | Add ON; or use explicit CROSS JOIN |
| Filtering after GROUP BY with WHERE | Invalid use of aggregate | Use HAVING for group-level filters |

---

# Module 05 — Key Takeaways

✅ **INNER JOIN** = matched rows only  
✅ **LEFT JOIN** = all left rows; NULLs for unmatched right  
✅ **Anti-join** = LEFT JOIN … WHERE right.pk IS NULL  
✅ **ON filter** vs **WHERE filter** = fundamentally different for LEFT JOIN  
✅ **COUNT(col)** not COUNT(*) for zero-safe counts  
✅ **FULL OUTER JOIN** = MySQL needs LEFT UNION RIGHT simulation  
✅ **SELF JOIN** = two aliases; LEFT JOIN to handle NULLs (CEO)  
✅ **CROSS JOIN** = intentional Cartesian product  

---

# Module 06 Preview
## Subqueries

- Scalar subqueries: `SELECT (SELECT MAX(gpa) FROM students)`
- Subqueries in WHERE: `IN`, `NOT IN`, `EXISTS`, `NOT EXISTS`
- Correlated subqueries: reference the outer query row by row
- Derived tables: `FROM (SELECT … ) AS alias`
- Common Table Expressions (CTEs): `WITH cte AS (…)`
- Subquery vs JOIN: when each is preferred

<span class="muted">Join fundamentals (Module 05) are prerequisites — subqueries often appear inside or alongside joins.</span>
