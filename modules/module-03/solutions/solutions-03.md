# Module 03 — Exercise Solutions
## Querying Data: SELECT, WHERE, ORDER BY

> Try each exercise yourself before reading the solution.

---

## Exercise 1 — Retrieve all columns

```sql
SELECT * FROM departments ORDER BY department_name;
```

---

## Exercise 2 — Retrieve specific columns

```sql
SELECT first_name, last_name, email
FROM   students
ORDER BY last_name;
```

---

## Exercise 3 — Column alias

```sql
SELECT
    first_name,
    last_name,
    gpa AS grade_point_average
FROM   students
ORDER BY grade_point_average DESC;
```

Note: the alias `grade_point_average` is available in `ORDER BY` because ORDER BY is evaluated after SELECT.

---

## Exercise 4 — Filter with WHERE

```sql
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > 3.70
ORDER BY gpa DESC;
```

---

## Exercise 5 — AND condition

```sql
-- MySQL / SQL Server
SELECT first_name, last_name, gpa
FROM   students
WHERE  is_active = 1
  AND  gpa >= 3.60;

-- PostgreSQL
SELECT first_name, last_name, gpa
FROM   students
WHERE  is_active = TRUE
  AND  gpa >= 3.60;
```

---

## Exercise 6 — Filter by date

```sql
SELECT first_name, enrolled_at
FROM   students
WHERE  enrolled_at >= '2024-01-01'
ORDER BY enrolled_at;
```

---

## Exercise 7 — IS NULL

```sql
SELECT first_name, last_name, phone
FROM   students
WHERE  phone IS NULL;
```

If all students have phone numbers in your dataset, this returns 0 rows — that is correct. Try inserting a student without a phone to test the query:

```sql
-- MySQL / PostgreSQL
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('No', 'Phone', 'no.phone@example.com', CURRENT_DATE);

-- SQL Server
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES (N'No', N'Phone', N'no.phone@example.com', CAST(GETDATE() AS DATE));
```

---

## Exercise 8 — LIKE

```sql
-- MySQL / SQL Server (case-insensitive by default)
SELECT first_name, last_name
FROM   students
WHERE  last_name LIKE 'S%';

-- PostgreSQL (case-sensitive LIKE; use ILIKE for case-insensitive)
SELECT first_name, last_name
FROM   students
WHERE  last_name ILIKE 'S%';
```

---

## Exercise 9 — BETWEEN

```sql
SELECT department_name, budget
FROM   departments
WHERE  budget BETWEEN 300000 AND 600000
ORDER BY budget DESC;
```

Expected rows: Mathematics (320,000), Physics (410,000), Computer Science (550,000 after the 10% update from Module 02).

---

## Exercise 10 — IN

```sql
SELECT department_name, building, budget
FROM   departments
WHERE  building IN ('Tech Hall', 'Science Wing');
```

---

## Exercise 11 — OR with parentheses

```sql
SELECT first_name, last_name, gpa, enrolled_at
FROM   students
WHERE  gpa > 3.80
   OR  (enrolled_at < '2024-01-01' AND gpa > 3.60);
-- The parentheses are essential: without them, AND binds tighter than OR,
-- and the query would mean: gpa > 3.80 OR (enrolled_at < '2024-01-01' AND gpa > 3.60)
-- which is what we want here — but write it explicitly to make intent clear.
```

---

## Exercise 12 — CASE WHEN

```sql
SELECT
    first_name,
    last_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.00 THEN 'Merit'
        WHEN gpa >= 2.00 THEN 'Pass'
        ELSE 'At Risk'
    END AS academic_standing
FROM   students
ORDER BY gpa DESC;
```

---

## Exercise 13 — LIMIT / TOP

```sql
-- MySQL / PostgreSQL: Top 3
SELECT first_name, last_name, gpa
FROM   students ORDER BY gpa DESC LIMIT 3;

-- MySQL / PostgreSQL: Rows 4–6
SELECT first_name, last_name, gpa
FROM   students ORDER BY gpa DESC LIMIT 3 OFFSET 3;

-- SQL Server: Top 3
SELECT TOP 3 first_name, last_name, gpa
FROM   students ORDER BY gpa DESC;

-- SQL Server: Rows 4–6
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;

-- Smallest budget department (all platforms)
SELECT TOP 1 department_name, budget FROM departments ORDER BY budget ASC;  -- SQL Server
SELECT department_name, budget FROM departments ORDER BY budget ASC LIMIT 1;  -- MySQL/PG
```

---

## Exercise 14 — DISTINCT

```sql
-- 1. Unique buildings
SELECT DISTINCT building FROM departments ORDER BY building;

-- 2. Count distinct buildings
SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;

-- 3. Distinct is_active values
SELECT DISTINCT is_active FROM students;
```

---

## Exercise 15 — Computed column

```sql
SELECT
    department_name,
    budget,
    budget * 1.10 AS budget_after_10pct_increase
FROM   departments
ORDER BY budget_after_10pct_increase DESC;
```

---

## Challenge 16 — NULL trap

```sql
-- The query:
SELECT * FROM students WHERE phone NOT IN (NULL, '416-555-0101');
-- Returns 0 rows.
--
-- Why: NOT IN expands to:
--   phone <> NULL AND phone <> '416-555-0101'
-- The first comparison (phone <> NULL) is always UNKNOWN.
-- UNKNOWN AND anything = UNKNOWN or FALSE — never TRUE.
-- So no row passes the filter.
```

**Correct query:**
```sql
-- MySQL / PostgreSQL / SQL Server
SELECT * FROM students
WHERE  (phone <> '416-555-0101' OR phone IS NULL);
```

This explicitly handles the NULL case. Rows with phone IS NULL are included because we added the OR clause.

---

## Challenge 17 — CASE in ORDER BY

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
FROM   students
ORDER BY
    CASE
        WHEN gpa >= 3.70 THEN 1
        WHEN gpa >= 3.00 THEN 2
        WHEN gpa >= 2.00 THEN 3
        ELSE 4
    END ASC,
    gpa DESC;
```

The CASE in ORDER BY assigns a sort key (1=Distinction, 2=Merit …) so each category is grouped together, then within each category students are sorted by GPA descending.

---

## Challenge 18 — Cross-platform pagination

```sql
-- MySQL / PostgreSQL: page 2 (rows 4-6)
SELECT first_name, last_name, enrolled_at
FROM   students
ORDER BY enrolled_at DESC
LIMIT 3 OFFSET 3;

-- SQL Server: OFFSET…FETCH (cleanest)
SELECT first_name, last_name, enrolled_at
FROM   students
ORDER BY enrolled_at DESC
OFFSET 3 ROWS
FETCH NEXT 3 ROWS ONLY;

-- SQL Server: Can you use TOP to get rows 4-6?
-- Not cleanly with a single TOP. You would need a subquery:
SELECT TOP 3 *
FROM (
    SELECT TOP 6 first_name, last_name, enrolled_at
    FROM   students
    ORDER BY enrolled_at DESC
) sub
ORDER BY enrolled_at ASC;  -- reverse to get the bottom 3 of the top 6
-- This is awkward and ordering gets confusing. Use OFFSET…FETCH instead.
```

---

## Interview Question Answers

1. `= NULL` always returns UNKNOWN (no rows); `IS NULL` returns TRUE when the value is absent.
2. DISTINCT removes duplicate rows from the output. Be careful on wide SELECT lists — it deduplicates the entire row combination, not individual columns.
3. `LIKE 'S%'` matches strings starting with S; `LIKE '%S%'` matches any string containing S anywhere.
4. Without ORDER BY, row order is non-deterministic — the same query run twice may return different rows in different order. LIMIT without ORDER BY gives arbitrary results.
5. BETWEEN is inclusive: `BETWEEN 10 AND 20` includes 10 and 20.
6. FROM → WHERE → SELECT → ORDER BY → LIMIT/TOP
7. No. Aliases defined in SELECT are not available in WHERE because WHERE is evaluated before SELECT. Use the original expression in WHERE.
8. ILIKE is PostgreSQL-only case-insensitive pattern matching. It is equivalent to `LOWER(col) LIKE LOWER('pattern')`.
9. SQL Server has no ILIKE. Use `LIKE` with the default case-insensitive collation, or use `LOWER(col) LIKE LOWER('pattern')` explicitly.
10. Use `ORDER BY col ASC NULLS LAST` (or `NULLS FIRST`). MySQL and SQL Server have no equivalent clause — use a CASE trick: `ORDER BY CASE WHEN col IS NULL THEN 1 ELSE 0 END, col`.
