# Module 04 — Lecture Notes
## Aggregating Data: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

---

## 1. What Is Aggregation?

An **aggregate function** takes a set of rows and returns a single value. Instead of retrieving every row, you summarize them.

| Function | Returns |
|----------|---------|
| `COUNT(*)` | Number of rows in the group |
| `COUNT(col)` | Number of non-NULL values in `col` |
| `COUNT(DISTINCT col)` | Number of unique non-NULL values |
| `SUM(col)` | Sum of all non-NULL values |
| `AVG(col)` | Average of all non-NULL values |
| `MIN(col)` | Smallest non-NULL value |
| `MAX(col)` | Largest non-NULL value |

All standard aggregate functions **ignore NULLs** — except `COUNT(*)`, which counts every row regardless of NULL values.

---

## 2. COUNT(*) vs COUNT(col)

This is one of the most common sources of confusion in SQL.

```sql
-- Setup: a students table where some rows have NULL phone
-- Assume 6 students total, 2 of them have NULL phone

SELECT
    COUNT(*)        AS total_rows,      -- 6
    COUNT(phone)    AS rows_with_phone, -- 4
    COUNT(DISTINCT phone) AS unique_phones -- 4 or fewer
FROM students;
```

**The rule:**
- `COUNT(*)` counts every row, including NULLs
- `COUNT(col)` counts only non-NULL values in that column
- `COUNT(DISTINCT col)` counts unique non-NULL values

If you want the number of students who have no phone:
```sql
SELECT COUNT(*) - COUNT(phone) AS students_without_phone FROM students;
-- Or more directly:
SELECT COUNT(*) FROM students WHERE phone IS NULL;
```

---

## 3. SUM, AVG, MIN, MAX

```sql
-- Summary statistics for student GPAs
SELECT
    COUNT(*)   AS total_students,
    SUM(gpa)   AS gpa_sum,
    AVG(gpa)   AS gpa_average,
    MIN(gpa)   AS lowest_gpa,
    MAX(gpa)   AS highest_gpa
FROM students;
```

All five aggregate functions are available on all three platforms with identical syntax.

**Important:** If the column contains NULLs, `SUM`, `AVG`, `MIN`, and `MAX` silently skip them. This can produce surprising results:

```sql
-- Suppose bonus column: 100, 200, NULL, 300
SELECT AVG(bonus) FROM employees;
-- Returns 200 (average of 100, 200, 300 — not 150 which would include NULL as 0)
```

If you want NULLs treated as zero:
```sql
SELECT AVG(COALESCE(bonus, 0)) FROM employees;
```

---

## 4. AVG and Integer Division

**SQL Server specific:** When both operands are integers, SQL Server performs integer division.

```sql
-- SQL Server: returns 3 (truncated), not 3.5
SELECT AVG(gpa_as_integer_col) FROM students;

-- Fix: cast to decimal first
SELECT AVG(CAST(gpa_as_integer_col AS DECIMAL(5,2))) FROM students;
```

MySQL and PostgreSQL return a decimal result for `AVG` even when the column is `INTEGER`. SQL Server truncates to integer — always cast.

---

## 5. GROUP BY

`GROUP BY` partitions the rows into groups and applies aggregate functions to each group separately.

```sql
-- How many students are in each department?
SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
ORDER BY student_count DESC;
```

The logical processing order now includes GROUP BY:

```
1. FROM
2. WHERE       -- filter individual rows BEFORE grouping
3. GROUP BY    -- partition into groups
4. HAVING      -- filter groups AFTER aggregating
5. SELECT      -- compute output columns
6. ORDER BY    -- sort
7. LIMIT/TOP   -- clip
```

**Rule:** Any column in `SELECT` that is NOT inside an aggregate function **must appear** in `GROUP BY`.

```sql
-- WRONG: last_name is not aggregated and not in GROUP BY
SELECT last_name, COUNT(*) FROM students GROUP BY department_id;

-- RIGHT:
SELECT department_id, COUNT(*) FROM students GROUP BY department_id;
```

---

## 6. GROUP BY Multiple Columns

```sql
-- Count students per department per enrollment year
SELECT
    department_id,
    YEAR(enrolled_at) AS enrollment_year,
    COUNT(*)          AS student_count
FROM   students
GROUP BY department_id, YEAR(enrolled_at)
ORDER BY department_id, enrollment_year;
```

The grouping is on the **combination** of all GROUP BY columns. Each unique combination forms one output row.

---

## 7. HAVING

`HAVING` filters groups after aggregation — it is `WHERE` for groups.

```sql
-- Only departments with more than 2 students
SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
HAVING COUNT(*) > 2
ORDER BY student_count DESC;
```

**WHERE vs HAVING — the critical distinction:**

| Clause | Filters | When | Can use aggregates? |
|--------|---------|------|---------------------|
| `WHERE` | Individual rows | Before GROUP BY | No |
| `HAVING` | Groups | After GROUP BY | Yes |

```sql
-- WHERE filters individual rows first, then HAVING filters groups
SELECT
    department_id,
    AVG(gpa) AS avg_gpa
FROM   students
WHERE  is_active = 1          -- filter: only active students
GROUP BY department_id
HAVING AVG(gpa) > 3.50        -- filter: only departments with high avg GPA
ORDER BY avg_gpa DESC;
```

---

## 8. COUNT(DISTINCT col)

```sql
-- How many unique buildings do our departments use?
SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;

-- How many distinct enrollment years are in the database?
SELECT COUNT(DISTINCT YEAR(enrolled_at)) AS distinct_years FROM students;
```

---

## 9. MIN and MAX on Non-Numeric Columns

`MIN` and `MAX` work on any sortable type — text, dates, numbers.

```sql
-- Earliest and latest enrollment dates
SELECT
    MIN(enrolled_at) AS first_enrollment,
    MAX(enrolled_at) AS most_recent_enrollment
FROM students;

-- Alphabetically first and last department name
SELECT
    MIN(department_name) AS first_alpha,
    MAX(department_name) AS last_alpha
FROM departments;
```

---

## 10. Combining Aggregates with Non-Grouped Columns

You can mix aggregate functions with GROUP BY columns in SELECT:

```sql
SELECT
    d.department_name,
    COUNT(s.student_id)  AS total_students,
    AVG(s.gpa)           AS avg_gpa,
    MIN(s.gpa)           AS min_gpa,
    MAX(s.gpa)           AS max_gpa
FROM   departments d
JOIN   students    s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_gpa DESC;
```

(The `JOIN` here is a preview — covered fully in Module 05.)

---

## 11. GROUP_CONCAT / STRING_AGG

Collects values from multiple rows into a single delimited string — useful for reporting.

```sql
-- MySQL
SELECT
    department_id,
    GROUP_CONCAT(last_name ORDER BY last_name SEPARATOR ', ') AS student_names
FROM   students
GROUP BY department_id;

-- PostgreSQL
SELECT
    department_id,
    STRING_AGG(last_name, ', ' ORDER BY last_name) AS student_names
FROM   students
GROUP BY department_id;

-- SQL Server
SELECT
    department_id,
    STRING_AGG(last_name, ', ') WITHIN GROUP (ORDER BY last_name) AS student_names
FROM   students
GROUP BY department_id;
```

---

## 12. ROLLUP — Subtotals (Intro)

`ROLLUP` adds subtotal and grand total rows automatically.

```sql
-- MySQL / SQL Server
SELECT
    department_id,
    YEAR(enrolled_at) AS yr,
    COUNT(*)          AS students
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP;

-- PostgreSQL
SELECT
    department_id,
    EXTRACT(YEAR FROM enrolled_at) AS yr,
    COUNT(*) AS students
FROM   students
GROUP BY ROLLUP(department_id, EXTRACT(YEAR FROM enrolled_at));
```

The ROLLUP output includes:
- One row per (department, year) combination
- One subtotal row per department (year = NULL)
- One grand total row (both = NULL)

---

## 13. Aggregate Functions and NULL — Summary

| Function | NULL treatment |
|----------|---------------|
| `COUNT(*)` | Counts every row (NULLs included) |
| `COUNT(col)` | Skips NULLs |
| `SUM(col)` | Skips NULLs |
| `AVG(col)` | Skips NULLs (denominator = non-NULL count) |
| `MIN(col)` | Skips NULLs |
| `MAX(col)` | Skips NULLs |

If a group has **only NULLs**, `SUM`/`AVG`/`MIN`/`MAX` return `NULL` for that group.

---

## 14. Common Mistakes

| Mistake | Explanation | Fix |
|---------|-------------|-----|
| Non-aggregate column not in GROUP BY | SQL doesn't know which row's value to show | Add to GROUP BY or wrap in an aggregate |
| `WHERE` with aggregate | WHERE runs before grouping — aggregates don't exist yet | Use `HAVING` instead |
| `COUNT(col)` expecting to include NULLs | `COUNT(col)` skips NULLs | Use `COUNT(*)` |
| SQL Server `AVG` on integers | Truncates to integer | `CAST` column to `DECIMAL` before `AVG` |
| Forgetting `ORDER BY` with `GROUP BY` | Group order is non-deterministic | Add `ORDER BY` explicitly |

---

## 15. Cross-Platform Quick Reference

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|---------------|-----------------|
| Aggregate string | `GROUP_CONCAT(col SEPARATOR ',')` | `STRING_AGG(col, ',')` | `STRING_AGG(col, ',') WITHIN GROUP (ORDER BY col)` |
| ROLLUP syntax | `GROUP BY … WITH ROLLUP` | `GROUP BY ROLLUP(…)` | `GROUP BY … WITH ROLLUP` |
| Year from date | `YEAR(col)` | `EXTRACT(YEAR FROM col)` | `YEAR(col)` or `DATEPART(year, col)` |
| AVG integer div | Returns decimal | Returns decimal | Truncates — cast needed |
| GROUPING() function | ✓ | ✓ | ✓ |
