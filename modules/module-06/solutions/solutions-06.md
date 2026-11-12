# Module 06 — Solutions
## Subqueries

Attempt every exercise before reading these solutions.

---

## Beginner Solutions (1–10)

### Exercise 1 — Scalar subquery in WHERE

```sql
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students)
ORDER BY gpa DESC;
```

---

### Exercise 2 — Scalar subquery in SELECT

```sql
-- MySQL / SQL Server
SELECT
    first_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students), 2) AS school_avg
FROM   students
ORDER BY gpa DESC;

-- PostgreSQL (cast required for ROUND)
SELECT
    first_name,
    gpa,
    ROUND((SELECT AVG(gpa) FROM students)::NUMERIC, 2) AS school_avg
FROM   students
ORDER BY gpa DESC;
```

The scalar subquery `(SELECT AVG(gpa) FROM students)` runs once per output row (the optimizer typically hoists it and evaluates it once).

---

### Exercise 3 — IN with subquery

```sql
SELECT first_name, last_name
FROM   students
WHERE  student_id IN (
    SELECT DISTINCT student_id FROM enrollments
)
ORDER BY last_name;
```

`DISTINCT` is optional here (IN de-duplicates the list automatically), but it makes the intent clearer.

---

### Exercise 4 — NOT IN with subquery

```sql
SELECT first_name, last_name
FROM   students
WHERE  student_id NOT IN (
    SELECT student_id FROM enrollments WHERE student_id IS NOT NULL
)
ORDER BY last_name;
```

**Why the IS NOT NULL guard?** The `enrollments.student_id` column should never be NULL (it's a FK), but the guard is good defensive practice. If any value in the NOT IN list were NULL, the entire result would be empty.

---

### Exercise 5 — EXISTS

```sql
SELECT first_name, last_name
FROM   students s
WHERE  EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY s.last_name;
```

EXISTS is NULL-safe. The inner `SELECT 1` is conventional — the actual columns selected don't matter; only row existence is tested.

---

### Exercise 6 — NOT EXISTS

```sql
SELECT first_name, last_name
FROM   students s
WHERE  NOT EXISTS (
    SELECT 1
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
)
ORDER BY s.last_name;
```

NOT EXISTS is the preferred form for anti-joins. It is unaffected by NULLs in the subquery.

---

### Exercise 7 — Highest GPA

```sql
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa = (SELECT MAX(gpa) FROM students);
```

Using `MAX()` guarantees the scalar subquery returns exactly one row (even if the max GPA is shared by multiple students — the outer WHERE returns all of them).

---

### Exercise 8 — Above Computer Science department average

```sql
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > (
    SELECT AVG(s2.gpa)
    FROM   students    s2
    JOIN   departments d  ON d.department_id = s2.department_id
    WHERE  d.department_name = 'Computer Science'
)
ORDER BY gpa DESC;
```

The inner query computes the average GPA only for students in CS. The outer query returns every student above that average — including students in other departments.

---

### Exercise 9 — Derived table

```sql
-- MySQL / SQL Server
SELECT dept_stats.department_name, dept_stats.avg_gpa
FROM (
    SELECT
        d.department_name,
        ROUND(AVG(s.gpa), 2) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
) AS dept_stats
WHERE dept_stats.avg_gpa > 3.50
ORDER BY dept_stats.avg_gpa DESC;

-- PostgreSQL (NUMERIC cast)
SELECT dept_stats.department_name, dept_stats.avg_gpa
FROM (
    SELECT
        d.department_name,
        ROUND(AVG(s.gpa)::NUMERIC, 2) AS avg_gpa
    FROM   departments d
    JOIN   students    s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
) AS dept_stats
WHERE dept_stats.avg_gpa > 3.50
ORDER BY dept_stats.avg_gpa DESC;
```

The derived table `dept_stats` is an alias for the aggregated result. The outer WHERE can reference its columns by that alias.

---

### Exercise 10 — CTE

```sql
-- MySQL / SQL Server
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
WHERE  avg_gpa > 3.50
ORDER BY avg_gpa DESC;
```

Identical result to Exercise 9. CTEs often read more clearly because the named query block appears at the top before the main SELECT.

---

## Intermediate Solutions (11–15)

### Exercise 11 — Correlated subquery in SELECT

```sql
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    (SELECT COUNT(*)
     FROM   enrollments e
     WHERE  e.student_id = s.student_id) AS course_count
FROM   students s
ORDER BY course_count DESC;
```

The inner query uses `s.student_id` from the current outer row — that makes it correlated. It runs once per student.

---

### Exercise 12 — Above-average enrollment count

```sql
SELECT first_name, last_name
FROM   students s
WHERE (
    SELECT COUNT(*)
    FROM   enrollments e
    WHERE  e.student_id = s.student_id
) > (
    SELECT AVG(enroll_count)
    FROM (
        SELECT student_id, COUNT(*) AS enroll_count
        FROM   enrollments
        GROUP BY student_id
    ) AS counts
);
```

The left side of `>` is a correlated subquery (counts this student's enrollments). The right side is a scalar subquery that averages enrollment counts across all enrolled students.

---

### Exercise 13 — Subquery in HAVING

```sql
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.student_id) > (
    SELECT AVG(dept_count)
    FROM (
        SELECT COUNT(student_id) AS dept_count
        FROM   students
        GROUP BY department_id
    ) AS dept_sizes
)
ORDER BY student_count DESC;

-- SQL Server note: use CAST to avoid integer AVG truncation
-- AVG(CAST(dept_count AS FLOAT))
```

The innermost derived table produces one count per department. The middle AVG averages those counts. HAVING compares each department's current count against that average.

---

### Exercise 14 — Multi-step CTE

```sql
WITH
active_students AS (
    SELECT department_id
    FROM   students
    WHERE  is_active = 1          -- MySQL / SQL Server
    -- WHERE is_active = TRUE     -- PostgreSQL
),
active_per_dept AS (
    SELECT department_id, COUNT(*) AS active_count
    FROM   active_students
    GROUP BY department_id
),
avg_active AS (
    SELECT AVG(CAST(active_count AS FLOAT)) AS avg_count
    FROM   active_per_dept
)
SELECT
    d.department_name,
    COALESCE(a.active_count, 0) AS active_count
FROM   departments    d
LEFT JOIN active_per_dept a ON a.department_id = d.department_id
WHERE  COALESCE(a.active_count, 0) > (SELECT avg_count FROM avg_active)
ORDER BY active_count DESC;
```

Three CTEs: `active_students` filters; `active_per_dept` aggregates; `avg_active` computes the threshold. The main query filters and joins.

---

### Exercise 15 — NOT IN vs NOT EXISTS (NULL comparison)

```sql
-- Query A: NOT IN (UNSAFE — Amara has manager_id = NULL)
SELECT first_name
FROM   employees
WHERE  employee_id NOT IN (SELECT manager_id FROM employees);
-- Returns 0 rows because manager_id contains NULL (Amara's row)
-- NULL in the list → all comparisons → UNKNOWN → no row passes

-- Query B: NOT EXISTS (SAFE)
SELECT e.first_name
FROM   employees e
WHERE  NOT EXISTS (
    SELECT 1 FROM employees m WHERE m.manager_id = e.employee_id
);
-- Returns employees who have no row with manager_id = their employee_id
-- NULL rows in the inner table are simply never matched

-- Expected result of Query B:
-- Sofia, Yuki, Ibrahim (they are not anyone's manager)
-- Query A returns 0 rows; Query B returns the correct 3 rows
```

**Explanation:** `NOT IN` checks `employee_id <> NULL` for Amara's row in the list. `x <> NULL` = UNKNOWN. No row passes. `NOT EXISTS` does not compare against NULLs — it simply checks whether a matching row exists; NULL manager_id rows just don't match any `m.manager_id = e.employee_id` condition.

---

## Challenge Solutions (16–18)

### Challenge 16 — Top student per department

```sql
SELECT s.first_name, s.last_name, s.gpa, s.department_id
FROM   students s
WHERE  s.gpa = (
    SELECT MAX(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = s.department_id
)
ORDER BY s.department_id, s.gpa DESC;
```

The correlated subquery finds the MAX GPA for the current student's department. The outer WHERE returns all students who match that maximum — naturally handling ties.

---

### Challenge 17 — Three approaches to above-average departments

```sql
-- Version A: Derived table in FROM
SELECT dept_stats.department_name, dept_stats.avg_gpa
FROM (
    SELECT d.department_name, AVG(s.gpa) AS avg_gpa
    FROM   departments d JOIN students s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
) AS dept_stats
WHERE dept_stats.avg_gpa > (SELECT AVG(gpa) FROM students)
ORDER BY dept_stats.avg_gpa DESC;

-- Version B: CTE
WITH dept_stats AS (
    SELECT d.department_name, AVG(s.gpa) AS avg_gpa
    FROM   departments d JOIN students s ON s.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
)
SELECT department_name, avg_gpa
FROM   dept_stats
WHERE  avg_gpa > (SELECT AVG(gpa) FROM students)
ORDER BY avg_gpa DESC;

-- Version C: Scalar subquery in HAVING
SELECT d.department_name, AVG(s.gpa) AS avg_gpa
FROM   departments d
JOIN   students    s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING AVG(s.gpa) > (SELECT AVG(gpa) FROM students)
ORDER BY avg_gpa DESC;
```

All three produce the same result. Version C is the most concise. Version B reads most clearly for multi-step logic. Version A is useful when the derived table result is needed in a more complex outer query.

---

### Challenge 18 — Chained CTEs with enrollment rate

```sql
-- MySQL / SQL Server
WITH
enrolled_students AS (
    SELECT DISTINCT student_id
    FROM   enrollments
),
dept_enrolled_count AS (
    SELECT s.department_id, COUNT(DISTINCT e.student_id) AS enrolled_count
    FROM   students        s
    LEFT JOIN enrolled_students e ON e.student_id = s.student_id
    GROUP BY s.department_id
),
dept_total AS (
    SELECT department_id, COUNT(*) AS total_count
    FROM   students
    GROUP BY department_id
),
dept_with_rate AS (
    SELECT
        d.department_name,
        COALESCE(ec.enrolled_count, 0)  AS enrolled,
        dt.total_count                  AS total,
        ROUND(
            100.0 * COALESCE(ec.enrolled_count, 0) / dt.total_count,
            1
        ) AS enrollment_rate
    FROM   departments       d
    JOIN   dept_total        dt ON dt.department_id = d.department_id
    LEFT JOIN dept_enrolled_count ec ON ec.department_id = d.department_id
)
SELECT department_name, enrolled, total, enrollment_rate
FROM   dept_with_rate
ORDER BY enrollment_rate DESC;
```

**Chain logic:**
1. `enrolled_students` — unique student IDs with at least one enrollment
2. `dept_enrolled_count` — per-department count of enrolled students
3. `dept_total` — per-department total students
4. `dept_with_rate` — joins everything to compute the percentage

**Note:** `100.0 *` forces floating-point division; without it, integer ÷ integer truncates to 0 in some engines.

---

## Interview Answer Guide

**1. Scalar subquery?**  
Returns exactly one column and one row. Can appear in SELECT, WHERE, HAVING, and ON. Used for single-value comparisons: `WHERE salary > (SELECT AVG(salary) …)`.

**2. More than one row?**  
Runtime error: "Subquery returns more than 1 row" (MySQL). Use an aggregate function or LIMIT 1 to enforce one row.

**3. NOT IN NULL trap?**  
If the subquery result list contains any NULL, every `val NOT IN (…, NULL, …)` comparison evaluates to UNKNOWN. No row passes. Fix: add `WHERE col IS NOT NULL` inside the subquery, or use `NOT EXISTS`.

**4. IN vs EXISTS?**  
IN materializes the subquery result and checks membership. EXISTS checks only for the presence of at least one row (and can short-circuit). Both can be NULL-safe with care; NOT EXISTS is universally NULL-safe. The optimizer often produces equivalent plans.

**5. Correlated subquery?**  
When the inner query references a column from the outer query. It is re-evaluated for each outer row. Example: `WHERE salary > (SELECT AVG(salary) FROM emp e2 WHERE e2.dept_id = e1.dept_id)` — `e1.dept_id` is from the outer row.

**6. Derived table?**  
A subquery used as a table in the FROM clause. It must have an alias. It exists only for the duration of the query and cannot be referenced more than once without repeating it.

**7. CTE vs derived table?**  
Both are temporary result sets. CTE is named, defined once at the top with WITH, and can be referenced multiple times. Derived table is anonymous and must be re-written wherever it is needed.

**8. CTE over derived table?**  
Multi-step logic where intermediate results are reused; better readability; recursive CTEs for hierarchical data.
