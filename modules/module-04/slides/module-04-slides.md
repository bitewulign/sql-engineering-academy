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
    --color-text: #e8eaf0;
    --color-muted: #8892a4;
    --color-code-bg: #21253a;
  }
  section {
    background: var(--color-bg);
    color: var(--color-text);
    font-family: 'Segoe UI', system-ui, sans-serif;
    font-size: 22px;
    padding: 40px 50px;
  }
  h1 { color: var(--color-accent); font-size: 2em; }
  h2 { color: var(--color-accent2); font-size: 1.3em; border-bottom: 1px solid #2e3250; padding-bottom: 6px; }
  h3 { color: #b0b8d0; font-size: 1.05em; }
  code { background: var(--color-code-bg); color: var(--color-accent2); border-radius: 4px; padding: 1px 5px; }
  pre { background: var(--color-code-bg); border-left: 3px solid var(--color-accent); border-radius: 6px; padding: 14px 18px; font-size: 0.78em; }
  pre code { background: transparent; padding: 0; }
  table { font-size: 0.82em; border-collapse: collapse; width: 100%; }
  th { background: var(--color-surface); color: var(--color-accent); padding: 7px 10px; text-align: left; }
  td { padding: 6px 10px; border-bottom: 1px solid #2e3250; }
  tr:last-child td { border-bottom: none; }
  .warn { color: var(--color-warn); font-weight: bold; }
  .green { color: var(--color-accent2); font-weight: bold; }
  .muted { color: var(--color-muted); }
  footer { font-size: 0.65em; color: var(--color-muted); }
---

<!-- _paginate: false -->

# Module 04
## Aggregating Data

**COUNT · SUM · AVG · MIN · MAX · GROUP BY · HAVING**

SQL Engineering Academy
Track A · MySQL 8.0 | Track B · PostgreSQL 16 | Track C · SQL Server 2022

---

## What You Will Learn

1. The five standard aggregate functions
2. How NULLs are treated in aggregates
3. The difference between `COUNT(*)` and `COUNT(col)`
4. Grouping rows with `GROUP BY`
5. Filtering groups with `HAVING`
6. `WHERE` vs `HAVING` — when to use each
7. Conditional aggregation with `CASE`
8. `ROLLUP` for subtotals (intro)

---

## Aggregate Functions Overview

An aggregate takes a **set of rows** and returns **one value**.

| Function | Returns |
|----------|---------|
| `COUNT(*)` | Number of rows (including NULLs) |
| `COUNT(col)` | Number of non-NULL values |
| `SUM(col)` | Sum of non-NULL values |
| `AVG(col)` | Average of non-NULL values |
| `MIN(col)` | Smallest non-NULL value |
| `MAX(col)` | Largest non-NULL value |

```sql
SELECT
    COUNT(*) AS students,
    AVG(gpa) AS avg_gpa,
    MIN(gpa) AS min_gpa,
    MAX(gpa) AS max_gpa
FROM students;
```

---

## COUNT(*) vs COUNT(col)

```sql
-- Table has 10 rows; 3 have NULL phone

SELECT
    COUNT(*)        AS all_rows,     -- 10
    COUNT(phone)    AS with_phone,   -- 7
    COUNT(*) - COUNT(phone) AS without_phone  -- 3
FROM students;
```

<div class="warn">COUNT(col) silently skips NULLs.</div>

**Rule of thumb:**
- `COUNT(*)` → count rows (how many exist)
- `COUNT(col)` → count populated values (how many have data)

---

## NULLs and Aggregates

All aggregate functions (except `COUNT(*)`) **ignore NULLs**.

```sql
-- Values: 100, 200, NULL, 300

SELECT SUM(bonus)  FROM t;  -- 600  (not 600+NULL)
SELECT AVG(bonus)  FROM t;  -- 200  (600 ÷ 3, not 600 ÷ 4)
SELECT MIN(bonus)  FROM t;  -- 100
SELECT MAX(bonus)  FROM t;  -- 300
```

If you want NULLs treated as zero:

```sql
SELECT AVG(COALESCE(bonus, 0)) FROM t;  -- 150  (600 ÷ 4)
```

---

## SQL Server Integer AVG Trap

<div class="warn">SQL Server truncates AVG when the input is an integer type.</div>

```sql
-- score INT, values: 1, 2, 3, 4
SELECT AVG(score)                        AS wrong;  -- 2 (truncated)
SELECT AVG(CAST(score AS DECIMAL(5,2)))  AS right;  -- 2.50
```

MySQL and PostgreSQL return a decimal result for `AVG` on integer columns.  
SQL Server does not — always cast before averaging an `INT` column.

---

## GROUP BY

Splits rows into groups and applies aggregates to each group.

```sql
-- How many students per department?
SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
ORDER BY student_count DESC;
```

**Rule:** Any column in `SELECT` that is NOT inside an aggregate must appear in `GROUP BY`.

```sql
-- WRONG: last_name not aggregated, not in GROUP BY
SELECT last_name, COUNT(*) FROM students GROUP BY department_id;
```

---

## Logical Processing Order with GROUP BY

```
1. FROM        -- source table(s)
2. WHERE       -- filter rows BEFORE grouping
3. GROUP BY    -- partition into groups
4. HAVING      -- filter groups AFTER aggregation
5. SELECT      -- compute output columns
6. ORDER BY    -- sort
7. LIMIT/TOP   -- clip
```

This order has a critical implication:
- Aggregate functions are computed at step 3–4
- You **cannot** use an aggregate in `WHERE`
- You **must** use `HAVING` to filter on an aggregate

---

## HAVING — Filter Groups

```sql
-- Departments with more than 1 student
SELECT department_id, COUNT(*) AS students
FROM   students
GROUP BY department_id
HAVING COUNT(*) > 1
ORDER BY students DESC;
```

```sql
-- Active-students-only departments with avg GPA > 3.50
SELECT department_id, ROUND(AVG(gpa), 2) AS avg_gpa
FROM   students
WHERE  is_active = 1          -- filters ROWS (before grouping)
GROUP BY department_id
HAVING AVG(gpa) > 3.50        -- filters GROUPS (after aggregation)
ORDER BY avg_gpa DESC;
```

---

## WHERE vs HAVING

| | WHERE | HAVING |
|-|-------|--------|
| Runs | Before GROUP BY | After GROUP BY |
| Filters | Individual rows | Aggregated groups |
| Can use aggregates | ❌ No | ✓ Yes |
| Typical use | Row conditions | Group conditions |

```sql
-- WRONG: cannot use aggregate in WHERE
SELECT dept, AVG(gpa) FROM students
WHERE AVG(gpa) > 3.5 GROUP BY dept;

-- RIGHT:
SELECT dept, AVG(gpa) FROM students
GROUP BY dept HAVING AVG(gpa) > 3.5;
```

---

## COUNT(DISTINCT col)

```sql
-- How many unique buildings do our departments use?
SELECT COUNT(DISTINCT building) AS unique_buildings
FROM departments;

-- How many distinct enrollment years?
SELECT COUNT(DISTINCT YEAR(enrolled_at)) AS distinct_years
FROM students;
```

DISTINCT inside COUNT removes duplicate values before counting.  
It does **not** deduplicate the full result set.

---

## Conditional Aggregation

Count rows that match a condition using `CASE` inside `SUM`:

```sql
SELECT
    department_id,
    COUNT(*) AS total,
    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active,
    SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) AS inactive
FROM   students
GROUP BY department_id;
```

This computes multiple counts in a **single pass** over the table.  
More efficient than running separate queries for each condition.

---

## Aggregate String — Platform Comparison

| Feature | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Function | `GROUP_CONCAT` | `STRING_AGG` | `STRING_AGG` |
| Order | `ORDER BY col` inside function | `ORDER BY col` inside function | `WITHIN GROUP (ORDER BY col)` |

```sql
-- MySQL
GROUP_CONCAT(last_name ORDER BY last_name SEPARATOR ', ')

-- PostgreSQL
STRING_AGG(last_name, ', ' ORDER BY last_name)

-- SQL Server
STRING_AGG(last_name, N', ') WITHIN GROUP (ORDER BY last_name)
```

---

## ROLLUP — Subtotals

ROLLUP adds subtotal and grand total rows automatically.

```sql
-- MySQL / SQL Server
SELECT department_id, YEAR(enrolled_at) AS yr, COUNT(*) AS n
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP;

-- PostgreSQL
SELECT department_id, EXTRACT(YEAR FROM enrolled_at) AS yr, COUNT(*) AS n
FROM   students
GROUP BY ROLLUP(department_id, EXTRACT(YEAR FROM enrolled_at));
```

Output adds:
- One subtotal row per `department_id` (NULL in `yr`)
- One grand total row (NULL in both)

---

## GROUPING() — Label ROLLUP Rows

```sql
SELECT
    CASE WHEN GROUPING(department_id) = 1 THEN 'ALL DEPTS'
         ELSE CAST(department_id AS CHAR) END AS dept,
    CASE WHEN GROUPING(YEAR(enrolled_at)) = 1 THEN 'ALL YEARS'
         ELSE CAST(YEAR(enrolled_at) AS CHAR) END AS yr,
    COUNT(*) AS students
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP;
```

`GROUPING(col)` returns `1` for NULL rows introduced by ROLLUP,  
`0` for real data NULLs. Identical syntax on all three platforms.

---

## Platform Summary — Module 04

| Feature | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| ROLLUP syntax | `WITH ROLLUP` | `ROLLUP(...)` | `WITH ROLLUP` |
| String aggregate | `GROUP_CONCAT` | `STRING_AGG` | `STRING_AGG WITHIN GROUP` |
| Year from date | `YEAR(col)` | `EXTRACT(YEAR FROM col)` | `YEAR(col)` |
| AVG integer | Returns decimal | Returns decimal | Truncates — cast needed |
| GROUPING() | ✓ | ✓ | ✓ |
| Conditional count | CASE in SUM | CASE in SUM | CASE in SUM |

---

## Common Mistakes — Module 04

| Mistake | Fix |
|---------|-----|
| Using aggregate in WHERE | Move to HAVING |
| Non-aggregate column not in GROUP BY | Add to GROUP BY or wrap in aggregate |
| `COUNT(col)` expecting NULLs counted | Use `COUNT(*)` |
| SQL Server `AVG` on INT truncates | Cast to `DECIMAL` first |
| Confusing ROLLUP NULLs with data NULLs | Use `GROUPING()` to distinguish |
| `AVG` surprising when NULLs exist | Use `COALESCE` if 0 is the right default |

---

## Module 04 — Summary

You can now:

✓ Use `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`  
✓ Understand how NULLs affect each aggregate function  
✓ Distinguish `COUNT(*)` from `COUNT(col)`  
✓ Group rows with `GROUP BY` (single and multi-column)  
✓ Filter groups with `HAVING`  
✓ Use `WHERE` for rows and `HAVING` for groups  
✓ Apply conditional aggregation with `CASE`  
✓ Use `ROLLUP` for subtotals  

---

## Next: Module 05 — Joining Tables

**INNER JOIN · LEFT JOIN · RIGHT JOIN · FULL OUTER JOIN**

You will learn to:
- Combine data from multiple tables
- Understand how each join type handles non-matching rows
- Write multi-table queries with proper join conditions
- Avoid common join mistakes (Cartesian products)

**Before then:** Complete the Module 04 lab and quiz.
