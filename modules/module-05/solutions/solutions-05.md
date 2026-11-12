# Module 05 — Solutions
## Joining Tables: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF JOIN

Attempt every exercise before reading these solutions.

---

## Beginner Solutions (1–10)

### Exercise 1 — INNER JOIN two tables

```sql
-- MySQL / PostgreSQL / SQL Server
SELECT
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
INNER JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name;
```

---

### Exercise 2 — INNER JOIN with ORDER BY

```sql
-- MySQL
SELECT
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    d.department_name
FROM   students   s
INNER JOIN departments d ON s.department_id = d.department_id
ORDER BY d.department_name, s.last_name;

-- PostgreSQL (same CONCAT syntax works; || also works)
SELECT
    s.first_name || ' ' || s.last_name AS full_name,
    d.department_name
FROM   students   s
INNER JOIN departments d ON s.department_id = d.department_id
ORDER BY d.department_name, s.last_name;

-- SQL Server
SELECT
    s.first_name + N' ' + s.last_name AS full_name,
    d.department_name
FROM   students   s
INNER JOIN departments d ON s.department_id = d.department_id
ORDER BY d.department_name, s.last_name;
```

---

### Exercise 3 — LEFT JOIN — all students with COALESCE

```sql
SELECT
    s.first_name,
    s.last_name,
    COALESCE(d.department_name, 'Unassigned') AS department
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
ORDER BY s.last_name;
```

---

### Exercise 4 — Anti-join — students without a department

```sql
SELECT
    s.first_name,
    s.last_name,
    s.email
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.department_id IS NULL;
```

**Explanation:** After the LEFT JOIN, rows with no matching department have `d.department_id = NULL`. The WHERE clause isolates exactly those rows.

---

### Exercise 5 — Departments with zero students

```sql
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;
```

**Key:** `COUNT(s.student_id)` skips NULLs → returns 0 for empty departments. `COUNT(*)` would return 1 (wrong).

---

### Exercise 6 — RIGHT JOIN equivalent

```sql
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   students   s
RIGHT JOIN departments d ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;
```

**Note:** The results are identical to Exercise 5. RIGHT JOIN swaps which side is preserved; since departments is now on the right, all departments appear even with no students.

---

### Exercise 7 — INNER JOIN + WHERE filter

```sql
SELECT
    s.first_name,
    s.last_name,
    s.gpa,
    d.department_name
FROM   students   s
INNER JOIN departments d ON s.department_id = d.department_id
WHERE  d.department_name = 'Computer Science'
  AND  s.gpa > 3.50
ORDER BY s.gpa DESC;
```

---

### Exercise 8 — INNER JOIN + COUNT per department

```sql
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   students   s
INNER JOIN departments d ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.student_id) >= 1
ORDER BY student_count DESC;
```

**Note:** Because INNER JOIN already excludes departments with no students, the HAVING clause is redundant here. It becomes meaningful when switching to LEFT JOIN.

---

### Exercise 9 — Three-table JOIN

```sql
SELECT
    s.first_name,
    s.last_name,
    c.course_name
FROM   students    s
JOIN   enrollments e ON e.student_id = s.student_id
JOIN   courses     c ON c.course_id  = e.course_id
ORDER BY s.last_name, c.course_name;
```

---

### Exercise 10 — CROSS JOIN

```sql
-- MySQL / PostgreSQL / SQL Server
SELECT
    s.first_name,
    d.department_name
FROM   students   s
CROSS JOIN departments d
ORDER BY s.last_name, d.department_name;

-- Count rows
SELECT
    (SELECT COUNT(*) FROM students)    AS student_count,
    (SELECT COUNT(*) FROM departments) AS dept_count,
    (SELECT COUNT(*) FROM students)
      * (SELECT COUNT(*) FROM departments) AS cross_join_rows;
```

**Formula:** rows = (rows in left table) × (rows in right table). Every combination is produced — no join condition.

---

## Intermediate Solutions (11–15)

### Exercise 11 — Active student count per department (zero-safe)

```sql
-- Filter is_active in the ON clause, not WHERE
SELECT
    d.department_name,
    COUNT(s.student_id) AS active_students
FROM   departments d
LEFT JOIN students s
  ON   s.department_id = d.department_id
  AND  s.is_active = 1               -- ON clause: preserves all departments
GROUP BY d.department_id, d.department_name
ORDER BY active_students DESC;
```

**Why not WHERE?** A `WHERE s.is_active = 1` filter would eliminate rows where `s.student_id IS NULL` (the zero-student departments), collapsing them from the result.

---

### Exercise 12 — Four-table JOIN

```sql
SELECT
    s.first_name,
    s.last_name,
    d.department_name,
    c.course_name
FROM   students    s
JOIN   departments d ON s.department_id = d.department_id
JOIN   enrollments e ON e.student_id    = s.student_id
JOIN   courses     c ON c.course_id     = e.course_id
ORDER BY s.last_name, c.course_name;
```

---

### Exercise 13 — FULL OUTER JOIN

**PostgreSQL / SQL Server:**
```sql
-- All rows, then filter to unmatched only
SELECT
    s.first_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL OR d.department_id IS NULL;
```

**MySQL simulation:**
```sql
-- LEFT JOIN catches unmatched students
-- RIGHT JOIN WHERE catches unmatched departments
SELECT s.first_name, d.department_name
FROM   students s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.department_id IS NULL

UNION

SELECT s.first_name, d.department_name
FROM   students s
RIGHT JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL;
```

**UNION vs UNION ALL:** UNION removes duplicates. In the simulation, the two halves are complementary (one captures NULLs on the right, the other on the left), so there are no actual duplicates — but UNION is safer style.

---

### Exercise 14 — SELF JOIN

```sql
-- MySQL / PostgreSQL
SELECT
    e.first_name  AS employee,
    COALESCE(m.first_name, '(no manager)') AS manager
FROM   employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY m.first_name, e.first_name;

-- SQL Server (ISNULL instead of COALESCE)
SELECT
    e.first_name  AS employee,
    ISNULL(m.first_name, N'(no manager)') AS manager
FROM   dbo.employees e
LEFT JOIN dbo.employees m ON e.manager_id = m.employee_id
ORDER BY m.first_name, e.first_name;
```

**Two aliases are required:** `e` and `m` refer to the same physical table but represent different logical roles (employee vs manager). Without aliases the query is ambiguous.

---

### Exercise 15 — Department statistics

```sql
-- MySQL
SELECT
    d.department_name,
    COUNT(s.student_id)      AS total_students,
    ROUND(AVG(s.gpa), 2)     AS avg_gpa,
    MAX(s.gpa)               AS max_gpa
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_gpa DESC;

-- PostgreSQL (NULLS LAST for NULL avg_gpa at bottom)
SELECT
    d.department_name,
    COUNT(s.student_id)                AS total_students,
    ROUND(AVG(s.gpa)::NUMERIC, 2)      AS avg_gpa,
    MAX(s.gpa)                         AS max_gpa
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_gpa DESC NULLS LAST;

-- SQL Server
SELECT
    d.department_name,
    COUNT(s.student_id)      AS total_students,
    ROUND(AVG(s.gpa), 2)     AS avg_gpa,
    MAX(s.gpa)               AS max_gpa
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_gpa DESC;
```

**Note:** AVG() on a column with all NULLs (empty department) returns NULL — not 0. This is correct SQL behavior.

---

## Challenge Solutions (16–18)

### Challenge 16 — ON vs WHERE with LEFT JOIN

```sql
-- Version A: Filter in WHERE — eliminates unmatched left rows
SELECT
    s.first_name,
    d.department_name,
    d.building
FROM   students   s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.building = 'Tech Hall';
-- Result: only students in Tech Hall departments
-- Students with no department (or departments in other buildings) are EXCLUDED

-- Version B: Filter in ON — unmatched left rows preserved
SELECT
    s.first_name,
    d.department_name,
    d.building
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
  AND  d.building = 'Tech Hall';
-- Result: ALL students appear
-- For students in non-Tech-Hall departments: department_name = NULL, building = NULL
-- For students in Tech Hall departments: department info shown
```

**Row count comparison:**
- Version A: equals the INNER JOIN count (only matched + filtered rows)
- Version B: equals the total student count (all students, some with NULL dept info)

**Rule:** A filter on the right-side table belongs in ON when you want to control *which* right rows match, while still preserving all left rows. It belongs in WHERE only when you want to filter the final result (which removes unmatched left rows).

---

### Challenge 17 — Finding gaps with anti-join

```sql
-- Part 1: Departments with no students
SELECT
    d.department_name,
    d.building
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
WHERE  s.student_id IS NULL
ORDER BY d.department_name;

-- Part 2: Students enrolled in no courses
SELECT
    s.first_name,
    s.last_name,
    s.email
FROM   students    s
LEFT JOIN enrollments e ON e.student_id = s.student_id
WHERE  e.enrollment_id IS NULL
ORDER BY s.last_name;
```

**Anti-join pattern:** LEFT JOIN followed by WHERE right_table.pk IS NULL. This isolates rows from the left table that have no corresponding rows in the right table — the "gap" between the two sets.

---

### Challenge 18 — Cross-platform FULL OUTER JOIN (unmatched rows only)

**PostgreSQL:**
```sql
SELECT
    s.first_name    AS student_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL OR d.department_id IS NULL
ORDER BY s.first_name NULLS LAST, d.department_name NULLS LAST;
```

**SQL Server:**
```sql
SELECT
    s.first_name    AS student_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL OR d.department_id IS NULL
ORDER BY s.first_name, d.department_name;
```

**MySQL (simulation):**
```sql
-- Unmatched students (no department)
SELECT s.first_name AS student_name, NULL AS department_name
FROM   students s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.department_id IS NULL

UNION

-- Unmatched departments (no students)
SELECT NULL AS student_name, d.department_name
FROM   students s
RIGHT JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL
ORDER BY student_name, department_name;
```

**Explanation:** The MySQL simulation works because:
1. First branch: LEFT JOIN isolates students with no department match.
2. Second branch: RIGHT JOIN WHERE isolates departments with no student match.
3. UNION deduplicates (safe here since the two sets are disjoint).

---

## Interview Question Answers

**1. INNER JOIN vs LEFT JOIN?**  
INNER JOIN returns only rows where a match exists on both sides. LEFT JOIN returns all rows from the left table; unmatched right rows produce NULLs.

**2. What is a Cartesian product?**  
A Cartesian product pairs every row from the left table with every row from the right table. A CROSS JOIN produces it explicitly. It can happen accidentally when a JOIN condition is missing or incorrect.

**3. FULL OUTER JOIN in MySQL?**  
MySQL does not support FULL OUTER JOIN natively. Simulate it with: `LEFT JOIN UNION RIGHT JOIN WHERE right.pk IS NULL`. The UNION removes duplicate matched rows.

**4. ON vs WHERE with LEFT JOIN?**  
A filter in ON controls which right rows can match while keeping all left rows. A filter in WHERE runs after the join and eliminates rows — including unmatched left rows whose right columns are NULL. The result with WHERE on a right-side column is equivalent to an INNER JOIN.

**5. COUNT(col) vs COUNT(*) with LEFT JOIN?**  
For a department with no students (all right-side columns NULL):  
- `COUNT(s.student_id)` → 0 (skips NULLs)  
- `COUNT(*)` → 1 (counts the NULL row)  
Use `COUNT(col)` when counting related rows through a LEFT JOIN.

**6. What is a self join?**  
A table joined to itself using two aliases. Common use case: employee–manager hierarchy where both employee and manager are rows in the same `employees` table.

**7. How to join three tables?**  
Chain two JOIN clauses:
```sql
FROM   a
JOIN   b ON b.a_id = a.id
JOIN   c ON c.b_id = b.id
```
Each JOIN adds one more table. Order typically follows the foreign key chain.

**8. When to use CROSS JOIN?**  
When you need every combination of two sets — for example: generating a schedule matrix (all employees × all shifts), creating test data with all possible pairings, or computing permutations. In production, CROSS JOIN is rare because result sets grow as M × N.
