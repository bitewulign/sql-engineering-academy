# Module 03 — Lecture Notes
## Querying Data: SELECT, WHERE, ORDER BY

---

## 1. The SELECT Statement

`SELECT` is the most frequently used SQL command. It retrieves data from one or more tables without modifying anything.

### Basic Structure

```sql
SELECT  column1, column2, ...   -- what to return
FROM    table_name              -- where to look
WHERE   condition               -- which rows (optional)
ORDER BY column1 ASC|DESC       -- how to sort (optional)
LIMIT   n;                      -- how many rows (optional)
```

The order of these clauses is fixed. SQL processes them in a different order than they are written — this matters for understanding aliases:

```
Logical processing order:
1. FROM      -- identify the source table(s)
2. WHERE     -- filter rows
3. SELECT    -- compute output columns
4. ORDER BY  -- sort
5. LIMIT     -- clip to n rows
```

Aliases defined in `SELECT` are **not available in WHERE** because WHERE is evaluated before SELECT.

### SELECT *

`SELECT *` retrieves every column. Useful for exploration, but avoid it in production queries:
- It retrieves columns you may not need (wasteful)
- Adding or removing columns from the table silently changes your query's output
- It makes code harder to read and maintain

```sql
SELECT * FROM students;              -- exploration
SELECT student_id, first_name, last_name FROM students;  -- production
```

---

## 2. Column Aliases

Aliases rename output columns for readability. The `AS` keyword is optional but always include it for clarity.

```sql
SELECT
    first_name  AS given_name,
    last_name   AS family_name,
    gpa         AS grade_point_average
FROM students;
```

Aliases with spaces or reserved words require quoting:

```sql
-- MySQL / PostgreSQL
SELECT gpa AS "Grade Point Average" FROM students;

-- SQL Server
SELECT gpa AS [Grade Point Average] FROM students;
-- or:
SELECT gpa AS "Grade Point Average" FROM students;
```

**Rule:** Aliases appear in ORDER BY but not in WHERE (use the original expression).

---

## 3. The WHERE Clause

`WHERE` filters which rows are returned. Only rows where the condition evaluates to TRUE are included.

### Comparison Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Equal | `gpa = 4.00` |
| `<>` or `!=` | Not equal | `gpa <> 4.00` |
| `>` | Greater than | `gpa > 3.50` |
| `<` | Less than | `budget < 500000` |
| `>=` | Greater than or equal | `gpa >= 3.00` |
| `<=` | Less than or equal | `credits <= 3` |

```sql
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa >= 3.75;
```

### BETWEEN

`BETWEEN low AND high` is inclusive on both ends. It is shorthand for `column >= low AND column <= high`.

```sql
SELECT first_name, gpa
FROM   students
WHERE  gpa BETWEEN 3.50 AND 4.00;

-- Equivalent to:
WHERE  gpa >= 3.50 AND gpa <= 4.00
```

**Date ranges with BETWEEN:**
```sql
SELECT * FROM students
WHERE  enrolled_at BETWEEN '2024-01-01' AND '2024-12-31';
```

---

## 4. Logical Operators: AND, OR, NOT

Combine multiple conditions with `AND` (both must be true), `OR` (either must be true), `NOT` (negates).

```sql
-- AND: student is active AND has high GPA
SELECT first_name, last_name, gpa
FROM   students
WHERE  is_active = 1
  AND  gpa >= 3.80;

-- OR: student is in CS OR in Math department
SELECT s.first_name, d.department_name
FROM   students s
JOIN   enrollments e ON s.student_id = e.student_id
JOIN   departments d ON e.department_id = d.department_id
WHERE  d.department_name = 'Computer Science'
   OR  d.department_name = 'Mathematics';

-- NOT: students who are NOT active
SELECT first_name, last_name
FROM   students
WHERE  NOT is_active = 1;
-- Equivalent: WHERE is_active = 0  or  WHERE is_active <> 1
```

### Operator Precedence

`NOT` binds tighter than `AND`, which binds tighter than `OR`. Use parentheses to be explicit:

```sql
-- Ambiguous: which OR applies to?
WHERE  gpa >= 3.5 OR department_id = 2 AND enrolled_at > '2024-01-01'

-- Clear intent with parentheses:
WHERE  gpa >= 3.5
   OR  (department_id = 2 AND enrolled_at > '2024-01-01')
```

---

## 5. IN and NOT IN

`IN` tests whether a value matches any item in a list. More readable than multiple `OR` conditions.

```sql
-- Without IN:
WHERE department_name = 'Computer Science'
   OR department_name = 'Mathematics'
   OR department_name = 'Physics'

-- With IN (equivalent, cleaner):
WHERE department_name IN ('Computer Science', 'Mathematics', 'Physics')

-- NOT IN:
WHERE department_name NOT IN ('English Literature', 'Philosophy')
```

**Warning:** `NOT IN` with a subquery can produce unexpected results if any value in the subquery is NULL. This is a common trap — covered in the NULL section below.

---

## 6. LIKE and Pattern Matching

`LIKE` matches string patterns using two wildcard characters:

| Wildcard | Meaning | Example |
|----------|---------|---------|
| `%` | Zero or more characters | `'S%'` matches Smith, SQL, S |
| `_` | Exactly one character | `'_at'` matches cat, bat, hat |

```sql
-- Last names starting with 'S'
SELECT * FROM students WHERE last_name LIKE 'S%';

-- Email addresses from example.com
SELECT * FROM students WHERE email LIKE '%@example.com';

-- Names with exactly 5 characters
SELECT * FROM students WHERE last_name LIKE '_____';

-- NOT LIKE: exclude a pattern
SELECT * FROM students WHERE email NOT LIKE '%@test%';
```

### Case Sensitivity

| Platform | Behavior |
|----------|----------|
| MySQL | Case-insensitive by default (depends on collation) |
| PostgreSQL | `LIKE` is case-sensitive; use `ILIKE` for case-insensitive |
| SQL Server | Case-insensitive by default (depends on collation) |

```sql
-- PostgreSQL case-insensitive pattern match
SELECT * FROM students WHERE last_name ILIKE 's%';  -- matches Smith and smith
```

---

## 7. NULL Handling in WHERE

NULL is not a value — it means "unknown" or "absent". Comparing NULL with any operator returns `UNKNOWN`, not TRUE or FALSE.

```sql
-- Wrong: this returns no rows even if phone IS NULL
SELECT * FROM students WHERE phone = NULL;

-- Correct:
SELECT * FROM students WHERE phone IS NULL;
SELECT * FROM students WHERE phone IS NOT NULL;
```

**Three-valued logic:**

| Expression | Result |
|-----------|--------|
| `NULL = NULL` | UNKNOWN (not TRUE) |
| `NULL <> NULL` | UNKNOWN |
| `NULL > 5` | UNKNOWN |
| `NULL IS NULL` | TRUE |
| `NULL IS NOT NULL` | FALSE |

**NOT IN trap:** If any value in a NOT IN list is NULL, the entire result is empty:

```sql
-- Suppose some_table has (1, 2, NULL)
SELECT * FROM students WHERE student_id NOT IN (1, 2, NULL);
-- Returns 0 rows — because NOT IN expands to:
-- student_id <> 1 AND student_id <> 2 AND student_id <> NULL
-- The last condition is UNKNOWN, so the whole expression is UNKNOWN
```

Safe alternative: `NOT EXISTS` or `LEFT JOIN … WHERE IS NULL`.

---

## 8. ORDER BY

`ORDER BY` sorts results. Without it, row order is not guaranteed by the database.

```sql
-- Ascending (default)
SELECT * FROM students ORDER BY last_name;
SELECT * FROM students ORDER BY last_name ASC;   -- same

-- Descending
SELECT * FROM students ORDER BY gpa DESC;

-- Multi-column sort: primary sort by department, secondary by last name
SELECT s.first_name, s.last_name, d.department_name
FROM   students s
JOIN   enrollments e  ON s.student_id  = e.student_id
JOIN   departments d  ON e.department_id = d.department_id
ORDER BY d.department_name ASC, s.last_name ASC;

-- Sort by alias (available in ORDER BY)
SELECT first_name AS given_name, gpa AS grade
FROM   students
ORDER BY grade DESC;
```

### NULL Sort Position

When NULLs are present in sorted columns, their position depends on the platform:

| Platform | Default NULL position |
|----------|-----------------------|
| MySQL | NULLs sort first in ASC, last in DESC |
| PostgreSQL | NULLs sort last in ASC; use `NULLS FIRST` / `NULLS LAST` to control |
| SQL Server | NULLs sort first in ASC |

```sql
-- PostgreSQL: explicitly push NULLs to the end
SELECT first_name, gpa FROM students ORDER BY gpa DESC NULLS LAST;
```

---

## 9. Limiting Result Sets

Three different syntaxes for the same operation:

```sql
-- MySQL and PostgreSQL
SELECT * FROM students ORDER BY gpa DESC LIMIT 5;

-- MySQL and PostgreSQL: with offset (pagination)
SELECT * FROM students ORDER BY gpa DESC LIMIT 5 OFFSET 10;

-- SQL Server: TOP N
SELECT TOP 5 * FROM students ORDER BY gpa DESC;

-- SQL Server: WITH TIES (include ties at the boundary)
SELECT TOP 5 WITH TIES * FROM students ORDER BY gpa DESC;

-- SQL Server / PostgreSQL: ANSI standard fetch (SQL:2008)
SELECT * FROM students
ORDER BY gpa DESC
OFFSET 10 ROWS
FETCH NEXT 5 ROWS ONLY;
```

**Important:** Always pair `LIMIT` / `TOP` / `FETCH` with `ORDER BY`. Without `ORDER BY`, which rows you get is non-deterministic — the same query run twice may return different rows.

---

## 10. Computed Columns and CASE

The SELECT list can include expressions, not just column names.

```sql
-- String concatenation
SELECT first_name || ' ' || last_name AS full_name FROM students;  -- PostgreSQL
SELECT first_name + ' ' + last_name   AS full_name FROM students;  -- SQL Server
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM students;  -- MySQL / all

-- Arithmetic
SELECT department_name, budget, budget * 1.10 AS proposed_budget
FROM   departments;

-- CASE expression (works identically on all three platforms)
SELECT
    first_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.00 THEN 'Merit'
        WHEN gpa >= 2.00 THEN 'Pass'
        ELSE 'At Risk'
    END AS academic_standing
FROM students;
```

---

## 11. DISTINCT

`DISTINCT` removes duplicate rows from the output.

```sql
-- What unique buildings do we have?
SELECT DISTINCT building FROM departments ORDER BY building;

-- What department names appear in enrollments?
SELECT DISTINCT d.department_name
FROM   enrollments e
JOIN   departments d ON e.department_id = d.department_id
ORDER BY d.department_name;
```

`DISTINCT` applies to the full combination of columns in the SELECT list:

```sql
-- This returns distinct (first_name, last_name) pairs, not distinct first_names
SELECT DISTINCT first_name, last_name FROM students;
```

---

## 12. Filtering with Dates

Date literals must be quoted strings in ISO 8601 format (`'YYYY-MM-DD'`) on all three platforms.

```sql
-- Exact date
SELECT * FROM students WHERE enrolled_at = '2024-09-01';

-- Range
SELECT * FROM students
WHERE  enrolled_at >= '2024-01-01'
  AND  enrolled_at <  '2025-01-01';  -- open range (safer than BETWEEN for dates)

-- Current date
SELECT * FROM students
WHERE  enrolled_at = CURDATE();       -- MySQL
WHERE  enrolled_at = CURRENT_DATE;    -- PostgreSQL / SQL Server (also ANSI)
WHERE  enrolled_at = CAST(GETDATE() AS DATE);  -- SQL Server alternative
```

---

## 13. Cross-Platform Quick Reference

| Feature | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Limit rows | `LIMIT n` | `LIMIT n` | `TOP n` or `FETCH NEXT n ROWS ONLY` |
| Offset | `LIMIT n OFFSET m` | `LIMIT n OFFSET m` | `OFFSET m ROWS FETCH NEXT n ROWS ONLY` |
| Case-insensitive LIKE | default | `ILIKE` | default |
| Concat operator | `CONCAT()` | `||` or `CONCAT()` | `+` or `CONCAT()` |
| Current date | `CURDATE()` | `CURRENT_DATE` | `CAST(GETDATE() AS DATE)` |
| Wildcard in LIKE | `%` and `_` | `%` and `_` | `%` and `_` |
| NULL-safe equal | `<=>` | `IS NOT DISTINCT FROM` | (no operator; use `IS NULL`) |

---

## 14. Common Mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| `WHERE column = NULL` | Returns 0 rows | Use `IS NULL` |
| `NOT IN` with a subquery containing NULLs | Returns 0 rows | Use `NOT EXISTS` |
| `SELECT *` in production queries | Fragile; wastes resources | List columns explicitly |
| `LIMIT`/`TOP` without `ORDER BY` | Non-deterministic results | Always ORDER BY first |
| Forgetting parentheses with AND/OR | Wrong rows filtered | Use parentheses to clarify |
| Using aliases in WHERE | Error — alias not yet defined | Use original expression |
| `LIKE '%pattern%'` on large tables | Full table scan | Consider full-text search |

---

## Key Vocabulary

| Term | Definition |
|------|------------|
| SELECT | Retrieves rows from a table or query |
| FROM | Specifies the source table |
| WHERE | Filters rows before they reach SELECT |
| ORDER BY | Sorts the final result set |
| LIMIT / TOP | Clips the result set to N rows |
| DISTINCT | Removes duplicate rows |
| Alias | An alternative name for a column or table in a query |
| LIKE | Pattern matching with % and _ wildcards |
| ILIKE | Case-insensitive LIKE (PostgreSQL only) |
| BETWEEN | Range check: `col BETWEEN a AND b` (inclusive) |
| IN | List membership: `col IN (a, b, c)` |
| IS NULL | Tests for the absence of a value |
| Three-valued logic | TRUE / FALSE / UNKNOWN — how SQL handles NULL in conditions |
| CASE WHEN | Conditional expression (like if/else in SQL) |
| Predicate | A boolean expression used in WHERE |
