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

# Module 03
## Querying Data

**SELECT · WHERE · ORDER BY · LIMIT / TOP**

SQL Engineering Academy
Track A · MySQL 8.0 | Track B · PostgreSQL 16 | Track C · SQL Server 2022

---

## What You Will Learn

1. How SQL processes a SELECT statement
2. Retrieving specific columns and using aliases
3. Filtering rows with WHERE — comparison, AND/OR/NOT
4. BETWEEN, IN, LIKE for specialized filtering
5. How NULL behaves in predicates — the NULL trap
6. Sorting results with ORDER BY
7. Limiting results with LIMIT / TOP / FETCH
8. DISTINCT, CASE WHEN, computed columns

---

## SELECT Statement Structure

```sql
SELECT  column1, column2        -- Step 3: pick columns
FROM    table_name              -- Step 1: identify source
WHERE   condition               -- Step 2: filter rows
ORDER BY column1 ASC            -- Step 4: sort
LIMIT   n;                      -- Step 5: clip
```

The **logical processing order** is not the same as the written order:

```
FROM → WHERE → SELECT → ORDER BY → LIMIT
```

**Key implication:** Column aliases defined in SELECT  
are **available** in ORDER BY but **not** in WHERE.

---

## SELECT * vs SELECT columns

```sql
-- Exploration (fine for ad-hoc queries)
SELECT * FROM students;

-- Production (always prefer this)
SELECT student_id, first_name, last_name, gpa
FROM   students;
```

<div class="warn">SELECT * in production:</div>

- Returns columns you don't need (wasteful)
- Silently breaks if columns are added/removed
- Makes code harder to read

**Always list the columns you need.**

---

## Column Aliases

```sql
SELECT
    first_name  AS given_name,
    last_name   AS family_name,
    gpa         AS grade_point_average,
    gpa * 25    AS gpa_as_percent   -- computed column
FROM students;
```

Aliases with spaces require quoting:

```sql
-- MySQL / PostgreSQL
SELECT gpa AS "Grade Point Average" FROM students;

-- SQL Server
SELECT gpa AS [Grade Point Average] FROM students;
```

Alias is available in `ORDER BY` — but not in `WHERE`.

---

## WHERE — Comparison Operators

| Operator | Meaning |
|----------|---------|
| `=` | Equal |
| `<>` / `!=` | Not equal |
| `>` / `>=` | Greater than / or equal |
| `<` / `<=` | Less than / or equal |

```sql
-- Students with GPA above 3.70
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > 3.70;

-- Active students with high GPA
SELECT first_name, gpa
FROM   students
WHERE  is_active = 1
  AND  gpa >= 3.80;
```

---

## AND, OR, NOT

```sql
-- AND: both conditions must be TRUE
WHERE is_active = 1 AND gpa >= 3.80

-- OR: either condition must be TRUE
WHERE building = 'Tech Hall'
   OR building = 'Science Wing'

-- NOT: negates a condition
WHERE NOT (gpa < 3.50)
```

<div class="warn">AND binds tighter than OR — use parentheses!</div>

```sql
-- Ambiguous:
WHERE a = 1 OR b = 2 AND c = 3

-- Clear:
WHERE a = 1 OR (b = 2 AND c = 3)
```

---

## BETWEEN, IN, LIKE

```sql
-- BETWEEN: inclusive range
WHERE gpa BETWEEN 3.50 AND 3.80
-- Same as: WHERE gpa >= 3.50 AND gpa <= 3.80

-- IN: match any value in a list
WHERE department_name IN ('Computer Science', 'Physics', 'Math')
-- Same as: ... = 'CS' OR ... = 'Physics' OR ... = 'Math'

-- LIKE: pattern matching
-- %  = any number of characters
-- _  = exactly one character
WHERE last_name LIKE 'S%'       -- starts with S
WHERE email     LIKE '%@example.com'  -- ends with
WHERE last_name LIKE '_r%'      -- second char is r
```

---

## LIKE — Case Sensitivity

| Platform | Default LIKE | Case-insensitive option |
|----------|-------------|------------------------|
| MySQL | Case-insensitive | default |
| PostgreSQL | **Case-sensitive** | `ILIKE` |
| SQL Server | Case-insensitive | default |

```sql
-- PostgreSQL: 'S%' matches Smith but not smith
SELECT * FROM students WHERE last_name LIKE 'S%';

-- PostgreSQL: ILIKE matches both
SELECT * FROM students WHERE last_name ILIKE 's%';
```

---

## NULL — The Most Misunderstood Topic in SQL

NULL means **unknown** or **absent** — it is not a value.

```sql
-- WRONG: returns 0 rows even if phone IS NULL
SELECT * FROM students WHERE phone = NULL;

-- RIGHT:
SELECT * FROM students WHERE phone IS NULL;
SELECT * FROM students WHERE phone IS NOT NULL;
```

**Three-valued logic:**

| Expression | Result |
|-----------|--------|
| `NULL = NULL` | UNKNOWN |
| `NULL IS NULL` | TRUE |
| `1 = NULL` | UNKNOWN |

WHERE only passes rows where the predicate = **TRUE**.  
UNKNOWN rows are excluded — just like FALSE.

---

## The NOT IN / NULL Trap

```sql
-- alumni last_name contains: 'Smith', 'Jones', NULL
SELECT * FROM students
WHERE last_name NOT IN ('Smith', 'Jones', NULL);
-- Returns 0 rows!
```

**Why:** NOT IN expands to:
```sql
last_name <> 'Smith' AND last_name <> 'Jones' AND last_name <> NULL
```
The last condition is **UNKNOWN** → entire expression is UNKNOWN → row excluded.

**Safe alternative:**
```sql
-- Use NOT EXISTS or handle NULL explicitly
WHERE last_name NOT IN ('Smith', 'Jones')
  OR  last_name IS NULL
```

---

## ORDER BY

```sql
-- Ascending (default)
ORDER BY last_name

-- Descending
ORDER BY gpa DESC

-- Multi-column: primary then secondary
ORDER BY enrolled_at DESC, gpa DESC

-- By alias (allowed — ORDER BY runs after SELECT)
SELECT gpa AS grade FROM students ORDER BY grade DESC;
```

**Without ORDER BY, row order is undefined** — the same query run twice may return rows in a different order.

---

## NULL Position in ORDER BY

| Platform | Default ASC | Control |
|----------|-------------|---------|
| MySQL | NULLs first | No built-in control |
| PostgreSQL | NULLs last | `NULLS FIRST` / `NULLS LAST` |
| SQL Server | NULLs first | CASE trick |

```sql
-- PostgreSQL: control NULL position
ORDER BY phone ASC NULLS LAST

-- SQL Server / MySQL: CASE trick to push NULLs last
ORDER BY
  CASE WHEN phone IS NULL THEN 1 ELSE 0 END,
  phone ASC
```

---

## Limiting Result Sets

| Syntax | MySQL | PostgreSQL | SQL Server |
|--------|-------|------------|------------|
| First 5 rows | `LIMIT 5` | `LIMIT 5` | `TOP 5` |
| Rows 6–10 | `LIMIT 5 OFFSET 5` | `LIMIT 5 OFFSET 5` | `OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY` |

```sql
-- MySQL / PostgreSQL
SELECT * FROM students ORDER BY gpa DESC LIMIT 5;

-- SQL Server
SELECT TOP 5 * FROM students ORDER BY gpa DESC;

-- ANSI standard (PostgreSQL + SQL Server)
SELECT * FROM students ORDER BY gpa DESC
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;
```

<div class="warn">Always pair with ORDER BY. Without it, results are non-deterministic.</div>

---

## DISTINCT

```sql
-- What unique buildings exist?
SELECT DISTINCT building FROM departments ORDER BY building;

-- How many unique buildings?
SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;
```

DISTINCT applies to the **full row** combination:

```sql
-- Returns distinct (first_name, last_name) pairs
SELECT DISTINCT first_name, last_name FROM students;
-- NOT distinct first_names
```

---

## CASE WHEN

Works identically on all three platforms:

```sql
SELECT
    first_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.00 THEN 'Merit'
        WHEN gpa >= 2.00 THEN 'Pass'
        ELSE 'At Risk'
    END AS academic_standing
FROM students
ORDER BY gpa DESC;
```

CASE can also appear in **ORDER BY** (sort by category) and  
**WHERE** (rarely needed but valid).

---

## Platform Summary — Module 03

| Feature | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Limit rows | `LIMIT n` | `LIMIT n` | `TOP n` |
| Pagination | `LIMIT n OFFSET m` | `LIMIT n OFFSET m` | `OFFSET m FETCH NEXT n` |
| Case-insensitive LIKE | default | `ILIKE` | default |
| Concat | `CONCAT()` | `||` or `CONCAT()` | `+` or `CONCAT()` |
| NULL-safe equal | `<=>` | `IS NOT DISTINCT FROM` | — |
| NULL in sort | NULLs first | `NULLS LAST` clause | CASE trick |
| Today's date | `CURDATE()` | `CURRENT_DATE` | `CAST(GETDATE() AS DATE)` |
| NULL default | `IFNULL()` | `COALESCE()` | `ISNULL()` |

---

## Common Mistakes — Module 03

| Mistake | Fix |
|---------|-----|
| `WHERE col = NULL` | `WHERE col IS NULL` |
| `NOT IN` with subquery containing NULLs | Use `NOT EXISTS` or add `OR IS NULL` |
| `SELECT *` in production | List columns explicitly |
| `LIMIT`/`TOP` without `ORDER BY` | Always ORDER BY first |
| Forgetting AND/OR precedence | Add parentheses |
| Using alias in WHERE | Use original expression |
| `LIKE '%pattern%'` on 10M rows | Consider full-text indexes |

---

## Module 03 — Summary

You can now:

✓ Write SELECT with specific columns and computed expressions  
✓ Filter rows with WHERE, AND, OR, NOT  
✓ Use BETWEEN, IN, LIKE for expressive filtering  
✓ Correctly handle NULLs with IS NULL / IS NOT NULL  
✓ Avoid the NOT IN / NULL trap  
✓ Sort results with ORDER BY (including NULL position control)  
✓ Limit results with LIMIT / TOP / FETCH  
✓ Write CASE WHEN for conditional logic  

---

## Next: Module 04 — Aggregating Data

**COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING**

You will learn to:
- Summarize data with aggregate functions
- Group rows with GROUP BY
- Filter groups with HAVING
- Understand the difference between WHERE and HAVING
- Combine aggregates with joins (preview)

**Before then:** Complete the Module 03 lab and quiz.
