# Module 05 — Guided Lab
## Joining Tables: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF JOIN

**Prerequisites:** Module 05 lecture notes read; `05_joins.sql` executed on your platform.  
**Estimated time:** 60–90 minutes  
**Platforms:** MySQL 8.0 (Part A) · PostgreSQL 16 (Part B) · SQL Server 2022 (Part C)

---

## Learning Objectives

By the end of this lab you will be able to:
- Write INNER, LEFT, RIGHT, FULL OUTER, CROSS, and SELF JOINs
- Correctly place filters in ON vs WHERE with LEFT JOIN
- Use COUNT(col) instead of COUNT(*) for zero-safe counts
- Simulate FULL OUTER JOIN in MySQL
- Chain three and four tables in a single query

---

## Part A — MySQL 8.0

### Step A1 — INNER JOIN warm-up

Connect to your MySQL instance and select the `university` database.

```sql
USE university;

SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
INNER JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name;
```

**Expected:** Only students who have a matching department_id appear. Students with `department_id = NULL` are excluded.

**Question:** How many rows does this return? How does that compare to the total student count?

---

### Step A2 — LEFT JOIN and the NULL rows

```sql
-- All students, including those without a department
SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
ORDER BY s.last_name;
```

**Observation:** Students without a department show `NULL` in the `department_name` column.

Now replace `d.department_name` with `COALESCE(d.department_name, 'Unassigned')`. Re-run. The NULLs should read as `'Unassigned'`.

---

### Step A3 — Anti-join pattern

```sql
-- Students with NO department
SELECT s.first_name, s.last_name, s.email
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.department_id IS NULL;
```

**What is happening:** After the LEFT JOIN, any student without a department produces a row where all `d.*` columns are NULL. The WHERE clause isolates those NULL rows.

**Try it:** Remove the WHERE clause. Count how many rows come back. Add it back. How many rows remain?

---

### Step A4 — Department student counts (zero-safe)

```sql
-- Count students per department — include departments with zero students
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;
```

**Compare:** Change `COUNT(s.student_id)` to `COUNT(*)`. Re-run.

What is the count for a zero-student department?
- `COUNT(s.student_id)` → **0** (NULL is skipped)
- `COUNT(*)` → **1** (the NULL row is counted)

Always use `COUNT(right_table.pk)` when counting through a LEFT JOIN.

---

### Step A5 — Filter in WHERE vs ON

**Version A — filter in WHERE (removes unmatched left rows):**
```sql
SELECT s.first_name, d.department_name, d.building
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.building = 'Tech Hall';
```

**Version B — filter in ON (preserves unmatched left rows):**
```sql
SELECT s.first_name, d.department_name, d.building
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
  AND  d.building = 'Tech Hall';
```

Run both. Count the rows. Version A returns fewer rows — it excludes students not in Tech Hall (or with no department). Version B returns all students; non-Tech-Hall students have NULL for department columns.

**Rule:** If you need "all left rows, only some right rows matched", put the filter in ON.

---

### Step A6 — HAVING with joins

```sql
-- Departments with more than 2 students
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.student_id) > 2
ORDER BY student_count DESC;
```

**Experiment:** Change the threshold to 0. What happens? Change to 10. What happens?

---

### Step A7 — Three-table JOIN

```sql
SELECT
    s.first_name,
    s.last_name,
    c.course_name,
    e.grade
FROM   students    s
JOIN   enrollments e ON e.student_id = s.student_id
JOIN   courses     c ON c.course_id  = e.course_id
ORDER BY s.last_name, c.course_name;
```

**Question:** A student enrolled in 3 courses will appear how many times in this result?

---

### Step A8 — FULL OUTER JOIN simulation (MySQL)

MySQL does not support FULL OUTER JOIN. Use this pattern:

```sql
-- Step 1: All students with their department (or NULL if no dept)
SELECT s.first_name, s.last_name, d.department_name
FROM   students s
LEFT JOIN departments d ON s.department_id = d.department_id

UNION

-- Step 2: All departments with no matching students
SELECT s.first_name, s.last_name, d.department_name
FROM   students s
RIGHT JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL;
```

**Explain to yourself:** Why is UNION used instead of UNION ALL? (Answer: UNION deduplicates — matched rows would appear in both queries as UNION ALL, so UNION removes those duplicates from the second half. Because the second SELECT already filters to `s.student_id IS NULL`, there are no actual duplicates — but UNION is safer style.)

---

## Part B — PostgreSQL 16

### Step B1 — INNER JOIN and COUNT

```bash
psql -U postgres -d university
```

```sql
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   students s
INNER JOIN departments d ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;
```

---

### Step B2 — LEFT JOIN with ROUND (PostgreSQL cast)

```sql
SELECT
    d.department_name,
    COUNT(s.student_id)                AS students,
    ROUND(AVG(s.gpa)::NUMERIC, 2)      AS avg_gpa
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_gpa DESC NULLS LAST;
```

**PostgreSQL note:** `ROUND()` requires a `NUMERIC` argument when used with `AVG()`. The `::NUMERIC` cast converts the float result of `AVG()` before rounding.

**NULLS LAST:** PostgreSQL sorts NULLs before non-NULLs by default in DESC ordering. `NULLS LAST` pushes empty departments to the bottom.

---

### Step B3 — WHERE + GROUP BY + HAVING

```sql
SELECT
    d.department_name,
    COUNT(s.student_id) AS active_count
FROM   departments d
LEFT JOIN students s
  ON   s.department_id = d.department_id
  AND  s.is_active = TRUE         -- filter in ON preserves all departments
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.student_id) > 0   -- only departments with active students
ORDER BY active_count DESC;
```

---

### Step B4 — Native FULL OUTER JOIN

```sql
SELECT
    s.first_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL OR d.department_id IS NULL
ORDER BY s.first_name NULLS LAST, d.department_name NULLS LAST;
```

**Comparison:** Run the same query without the WHERE clause. You will see all matched rows plus the unmatched rows on both sides.

---

### Step B5 — Self join

```sql
SELECT
    e.first_name  AS employee,
    COALESCE(m.first_name, '(no manager)') AS manager
FROM   employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY m.first_name NULLS LAST, e.first_name;
```

**Trace the join:** Amara has `manager_id = NULL`. The LEFT JOIN finds no match for NULL. The COALESCE substitutes `'(no manager)'`.

---

## Part C — SQL Server 2022

### Step C1 — Basic aggregates with JOIN

```sql
USE university;
GO

SELECT
    d.department_name,
    COUNT(s.student_id)  AS students,
    ROUND(AVG(s.gpa), 2) AS avg_gpa,
    MAX(s.gpa)           AS max_gpa
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY students DESC;
GO
```

---

### Step C2 — ISNULL and COALESCE in joins

```sql
-- Compare ISNULL and COALESCE in a self join
SELECT
    e.first_name                               AS employee,
    ISNULL(m.first_name, N'(no manager)')      AS mgr_isnull,
    COALESCE(m.first_name, N'(no manager)')    AS mgr_coalesce
FROM   dbo.employees e
LEFT JOIN dbo.employees m ON e.manager_id = m.employee_id
ORDER BY m.first_name, e.first_name;
GO
```

Both produce the same output for a single NULL substitution. COALESCE accepts multiple fallback values; ISNULL accepts one.

---

### Step C3 — Four-table JOIN

```sql
SELECT
    s.first_name + N' ' + s.last_name AS student_name,
    d.department_name,
    c.course_name,
    e.grade
FROM   students    s
JOIN   departments d ON s.department_id = d.department_id
JOIN   enrollments e ON e.student_id    = s.student_id
JOIN   courses     c ON c.course_id     = e.course_id
ORDER BY s.last_name, c.course_name;
GO
```

---

### Step C4 — Native FULL OUTER JOIN

```sql
SELECT
    s.first_name    AS student_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d ON s.department_id = d.department_id
ORDER BY s.first_name, d.department_name;
GO

-- Unmatched rows only
SELECT
    s.first_name    AS student_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL OR d.department_id IS NULL;
GO
```

---

### Step C5 — ON vs WHERE with LEFT JOIN (SQL Server)

```sql
-- Version A: WHERE reduces to INNER JOIN behavior
SELECT s.first_name, d.department_name
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.building = N'Tech Hall';
GO

-- Version B: ON preserves all students
SELECT s.first_name, d.department_name
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
  AND  d.building = N'Tech Hall';
GO
```

---

## Lab Summary

| Concept | Key takeaway |
|---------|-------------|
| INNER JOIN | Only matched rows; unassigned students excluded |
| LEFT JOIN | All left rows; NULLs for unmatched right rows |
| Anti-join | LEFT JOIN … WHERE right.pk IS NULL |
| Zero-safe count | COUNT(right_table.pk) not COUNT(*) |
| ON vs WHERE filter | ON: controls match; WHERE: filters result |
| FULL OUTER JOIN | MySQL: LEFT UNION RIGHT; PostgreSQL/SQL Server: native |
| Self join | Two aliases on same table; LEFT JOIN for NULL manager |
| Three-table join | Chain JOIN clauses; row count multiplied by enrollments |

---

## Check Your Understanding

Before moving to Module 06, confirm you can answer these without looking:

1. What does `WHERE d.department_id IS NULL` do after a LEFT JOIN?
2. Why does `COUNT(*)` give wrong counts for empty departments?
3. What is the MySQL equivalent of FULL OUTER JOIN?
4. When should a filter go in ON vs WHERE for a LEFT JOIN?
5. Why does a self join require two aliases?
