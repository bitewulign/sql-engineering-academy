# Module 04 — Exercise Solutions
## Aggregating Data: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

> Try each exercise yourself before reading the solution.

---

## Exercise 1 — COUNT all rows

```sql
SELECT COUNT(*) AS total_students FROM students;
```

---

## Exercise 2 — COUNT with NULL awareness

```sql
SELECT
    COUNT(*)        AS total_rows,
    COUNT(phone)    AS rows_with_phone,
    COUNT(*) - COUNT(phone) AS rows_without_phone
FROM students;
```

`COUNT(phone)` skips rows where `phone IS NULL`. Subtracting from `COUNT(*)` gives the NULL count.

---

## Exercise 3 — SUM and AVG

```sql
-- MySQL / SQL Server
SELECT
    SUM(budget)         AS total_budget,
    ROUND(AVG(budget), 2) AS avg_budget
FROM departments;

-- PostgreSQL
SELECT
    SUM(budget)                        AS total_budget,
    ROUND(AVG(budget)::NUMERIC, 2)     AS avg_budget
FROM departments;
```

---

## Exercise 4 — MIN and MAX

```sql
SELECT
    MIN(enrolled_at) AS first_enrollment,
    MAX(enrolled_at) AS most_recent_enrollment
FROM students;
```

---

## Exercise 5 — Aggregate with WHERE

```sql
-- MySQL / SQL Server
SELECT AVG(gpa) AS avg_active_gpa
FROM   students
WHERE  is_active = 1;

-- PostgreSQL
SELECT AVG(gpa) AS avg_active_gpa
FROM   students
WHERE  is_active = TRUE;
```

---

## Exercise 6 — GROUP BY single column

```sql
SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
ORDER BY student_count DESC;
```

---

## Exercise 7 — GROUP BY with multiple aggregates

```sql
-- MySQL / SQL Server
SELECT
    department_id,
    COUNT(*)              AS students,
    ROUND(AVG(gpa), 2)    AS avg_gpa,
    MIN(gpa)              AS min_gpa,
    MAX(gpa)              AS max_gpa
FROM   students
GROUP BY department_id;

-- PostgreSQL (cast needed for ROUND)
SELECT
    department_id,
    COUNT(*)                     AS students,
    ROUND(AVG(gpa)::NUMERIC, 2)  AS avg_gpa,
    MIN(gpa)                     AS min_gpa,
    MAX(gpa)                     AS max_gpa
FROM   students
GROUP BY department_id;
```

---

## Exercise 8 — HAVING

```sql
SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
HAVING COUNT(*) > 1
ORDER BY student_count DESC;
```

---

## Exercise 9 — WHERE + GROUP BY + HAVING

```sql
-- MySQL / SQL Server
SELECT
    department_id,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM   students
WHERE  is_active = 1
GROUP BY department_id
HAVING AVG(gpa) > 3.00
ORDER BY avg_gpa DESC;

-- PostgreSQL
SELECT
    department_id,
    ROUND(AVG(gpa)::NUMERIC, 2) AS avg_gpa
FROM   students
WHERE  is_active = TRUE
GROUP BY department_id
HAVING AVG(gpa) > 3.00
ORDER BY avg_gpa DESC;
```

**Key point:** `WHERE is_active = 1` filters individual rows before grouping. `HAVING AVG(gpa) > 3.00` filters groups after aggregation. You cannot swap them.

---

## Exercise 10 — COUNT(DISTINCT)

```sql
SELECT COUNT(DISTINCT building) AS unique_buildings FROM departments;
```

---

## Exercise 11 — Conditional COUNT with CASE

```sql
SELECT
    COUNT(*)                                            AS total_students,
    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END)     AS active_students,
    SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END)     AS inactive_students
FROM students;
```

The CASE inside SUM returns 1 for matching rows and 0 for non-matching, so SUM counts the matches. This is a standard pattern for conditional aggregation.

---

## Exercise 12 — GROUP BY multiple columns

```sql
SELECT
    department_id,
    is_active,
    COUNT(*)           AS student_count,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM   students
GROUP BY department_id, is_active
ORDER BY department_id, is_active;
```

---

## Exercise 13 — MIN and MAX on text

```sql
SELECT
    MIN(department_name) AS first_alpha,
    MAX(department_name) AS last_alpha
FROM departments;
```

`MIN` and `MAX` on text use the column's collation to determine alphabetical order.

---

## Exercise 14 — AVG with COALESCE

```sql
-- Insert a student with NULL GPA
-- MySQL / PostgreSQL
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Test', 'NullGPA', 'test.nullgpa@example.com', CURRENT_DATE);

-- SQL Server
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES (N'Test', N'NullGPA', N'test.nullgpa@example.com', CAST(GETDATE() AS DATE));

-- Compare averages
-- MySQL / SQL Server
SELECT
    AVG(gpa)                     AS avg_ignoring_null,
    AVG(COALESCE(gpa, 0.00))     AS avg_treating_null_as_zero
FROM students;

-- PostgreSQL
SELECT
    AVG(gpa)                                    AS avg_ignoring_null,
    AVG(COALESCE(gpa, 0.00))                    AS avg_treating_null_as_zero
FROM students;

-- Clean up
DELETE FROM students WHERE email = 'test.nullgpa@example.com';  -- MySQL / PostgreSQL
DELETE FROM students WHERE email = N'test.nullgpa@example.com'; -- SQL Server
```

**Why they differ:** `AVG(gpa)` divides by the count of non-NULL values. `AVG(COALESCE(gpa, 0.00))` divides by the total row count (NULL becomes 0, so it is included in both numerator and denominator). The null-as-zero version will always be lower or equal.

---

## Exercise 15 — Aggregate string

```sql
-- MySQL
SELECT
    department_id,
    GROUP_CONCAT(last_name ORDER BY last_name SEPARATOR ', ') AS names
FROM   students
GROUP BY department_id;

-- PostgreSQL
SELECT
    department_id,
    STRING_AGG(last_name, ', ' ORDER BY last_name) AS names
FROM   students
GROUP BY department_id;

-- SQL Server
SELECT
    department_id,
    STRING_AGG(last_name, N', ') WITHIN GROUP (ORDER BY last_name) AS names
FROM   students
GROUP BY department_id;
```

---

## Challenge 16 — Isolate NULL effect on AVG

```sql
-- Step 1: insert test student with NULL gpa
-- MySQL / PostgreSQL
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Null', 'GPATest', 'null.gpa@example.com', CURRENT_DATE);

-- SQL Server
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES (N'Null', N'GPATest', N'null.gpa@example.com', CAST(GETDATE() AS DATE));

-- Step 2: compare counts and averages
SELECT
    COUNT(*)                        AS total_rows,
    COUNT(gpa)                      AS rows_with_gpa,
    AVG(gpa)                        AS avg_null_ignored,
    AVG(COALESCE(gpa, 0.00))        AS avg_null_as_zero
FROM students;

-- Step 3: clean up
DELETE FROM students WHERE email = 'null.gpa@example.com';        -- MySQL / PostgreSQL
DELETE FROM students WHERE email = N'null.gpa@example.com';        -- SQL Server
```

**Explanation:** The database counted `total_rows` as one more than `rows_with_gpa`. `AVG(gpa)` ignored the NULL row entirely (denominator = rows with GPA). `AVG(COALESCE(gpa, 0.00))` included it as 0 (denominator = all rows), pulling the average down.

---

## Challenge 17 — ROLLUP subtotals

```sql
-- MySQL / SQL Server
SELECT
    CASE WHEN GROUPING(department_id)      = 1 THEN 'ALL DEPTS'
         ELSE CAST(department_id AS CHAR) END AS dept,
    CASE WHEN GROUPING(YEAR(enrolled_at))  = 1 THEN 'ALL YEARS'
         ELSE CAST(YEAR(enrolled_at) AS CHAR) END AS yr,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP;

-- PostgreSQL
SELECT
    CASE WHEN GROUPING(department_id) = 1 THEN 'ALL DEPTS'
         ELSE department_id::TEXT END AS dept,
    CASE WHEN GROUPING(EXTRACT(YEAR FROM enrolled_at)) = 1 THEN 'ALL YEARS'
         ELSE EXTRACT(YEAR FROM enrolled_at)::TEXT END AS yr,
    COUNT(*) AS student_count
FROM   students
GROUP BY ROLLUP(department_id, EXTRACT(YEAR FROM enrolled_at));
```

The `GROUPING()` function returns 1 for NULL values that were added by ROLLUP (not "real" NULLs from data). Without it, you can't tell whether a NULL in `department_id` is a real NULL or a ROLLUP subtotal marker.

---

## Challenge 18 — Cross-platform HAVING with multiple conditions

```sql
-- MySQL
SELECT
    department_id,
    COUNT(*)   AS active_students,
    MAX(gpa)   AS max_active_gpa
FROM   students
WHERE  is_active = 1
GROUP BY department_id
HAVING COUNT(*) >= 1
   AND MAX(gpa) > 3.70
ORDER BY max_active_gpa DESC;

-- PostgreSQL
SELECT
    department_id,
    COUNT(*)                     AS active_students,
    MAX(gpa)                     AS max_active_gpa
FROM   students
WHERE  is_active = TRUE
GROUP BY department_id
HAVING COUNT(*) >= 1
   AND MAX(gpa) > 3.70
ORDER BY max_active_gpa DESC;

-- SQL Server
SELECT
    department_id,
    COUNT(*)   AS active_students,
    MAX(gpa)   AS max_active_gpa
FROM   students
WHERE  is_active = 1
GROUP BY department_id
HAVING COUNT(*) >= 1
   AND MAX(gpa) > 3.70
ORDER BY max_active_gpa DESC;
```

**Pattern:** `WHERE` filters the rows to only active students before grouping. `HAVING` then filters the resulting groups to only those where count ≥ 1 AND max GPA > 3.70. Both aggregate conditions must be in HAVING, not WHERE.

---

## Interview Question Answers

1. `COUNT(*)` counts every row including NULLs. `COUNT(col)` counts only rows where `col` is not NULL.
2. If all values are NULL, `AVG(col)` returns NULL. There are no non-NULL values to average over.
3. No. Aggregate functions are computed after WHERE runs. Using an aggregate in WHERE raises an error. Use HAVING instead.
4. `WHERE` filters individual rows before grouping. `HAVING` filters groups after aggregation and can use aggregate functions.
5. `FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT/TOP`
6. ROLLUP adds extra rows representing subtotals (one per grouping level) and a grand total. The collapsed dimensions are represented as NULL.
7. SQL Server performs integer division when the column type is `INT`: `AVG(1,2,3,4)` returns 2, not 2.5. Fix by casting: `AVG(CAST(col AS DECIMAL(10,2)))`.
8. `GROUPING(col)` returns 1 when the NULL in that column was introduced by ROLLUP (not a real data NULL), and 0 otherwise. It is used to label ROLLUP summary rows.
