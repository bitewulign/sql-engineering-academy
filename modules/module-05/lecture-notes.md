# Module 05 — Lecture Notes
## Joining Tables: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF JOIN

---

## 1. Why Joins Exist

Relational databases store related data in separate tables to avoid duplication. A `students` table holds student data; a `departments` table holds department data. The `department_id` foreign key in `students` links the two.

A **join** combines columns from two or more tables into a single result set based on a related column.

```
students                    departments
-----------                 ---------------
student_id  department_id   department_id  department_name
1           10       ──────► 10             Computer Science
2           20       ──────► 20             Physics
3           10              
```

Without joins, you would need two separate queries and manual matching in application code — slow, error-prone, and not what SQL was designed for.

---

## 2. JOIN Syntax

The standard SQL join syntax uses `JOIN … ON`:

```sql
SELECT s.first_name, s.last_name, d.department_name
FROM   students   s          -- left table, alias s
JOIN   departments d          -- right table, alias d
  ON   s.department_id = d.department_id;
```

Key parts:
- `JOIN` (default = INNER JOIN)
- `ON` condition — the column(s) that link the two tables
- Table aliases (`s`, `d`) shorten column references

You can also use `USING(col)` when both tables have the same column name:

```sql
SELECT s.first_name, d.department_name
FROM   students s
JOIN   departments d USING (department_id);
```

---

## 3. INNER JOIN

Returns only rows where the ON condition matches in **both** tables. Rows with no match on either side are excluded.

```sql
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    d.department_name
FROM   students   s
INNER JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY s.last_name;
```

If a student has `department_id = NULL` or a value that doesn't exist in `departments`, that student is **not returned**. If a department has no students, it is **not returned** either.

`JOIN` without a type keyword is an `INNER JOIN` — they are identical.

---

## 4. LEFT JOIN (LEFT OUTER JOIN)

Returns **all rows from the left table**, plus matching rows from the right table. Where there is no match in the right table, the right-side columns are `NULL`.

```sql
-- All students, even those not assigned to a department
SELECT
    s.first_name,
    s.last_name,
    d.department_name        -- NULL if student has no department
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY d.department_name NULLS LAST, s.last_name;
```

**Use case:** Find all students who do NOT have a department assignment:

```sql
SELECT s.first_name, s.last_name
FROM   students   s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
WHERE  d.department_id IS NULL;   -- right-side NULL = no match
```

This "anti-join" pattern is a very common technique.

---

## 5. RIGHT JOIN (RIGHT OUTER JOIN)

Returns **all rows from the right table**, plus matching rows from the left. Left-side columns are `NULL` where there is no match.

```sql
-- All departments, even those with no enrolled students
SELECT
    d.department_name,
    s.first_name,
    s.last_name             -- NULL if no students in that dept
FROM   students   s
RIGHT JOIN departments d
  ON   s.department_id = d.department_id
ORDER BY d.department_name, s.last_name;
```

**Practical note:** `RIGHT JOIN` can always be rewritten as a `LEFT JOIN` by swapping the table order. Most developers prefer `LEFT JOIN` for readability and avoid `RIGHT JOIN` entirely.

Equivalent rewrite:
```sql
-- Identical result, more readable
SELECT d.department_name, s.first_name, s.last_name
FROM   departments d
LEFT JOIN students s
  ON   s.department_id = d.department_id
ORDER BY d.department_name, s.last_name;
```

---

## 6. FULL OUTER JOIN

Returns **all rows from both tables**. Where there is no match, `NULL` fills the missing side.

```sql
-- PostgreSQL / SQL Server
SELECT
    s.first_name,
    d.department_name
FROM   students   s
FULL OUTER JOIN departments d
  ON   s.department_id = d.department_id;
```

**Result includes:**
- Students with a matching department ✓
- Students with no department (d.* = NULL) ✓
- Departments with no students (s.* = NULL) ✓

**MySQL does not support FULL OUTER JOIN.** Simulate it:

```sql
-- MySQL: LEFT JOIN UNION RIGHT JOIN
SELECT s.first_name, d.department_name
FROM   students s
LEFT  JOIN departments d ON s.department_id = d.department_id
UNION
SELECT s.first_name, d.department_name
FROM   students s
RIGHT JOIN departments d ON s.department_id = d.department_id
WHERE  s.student_id IS NULL;
```

---

## 7. CROSS JOIN (Cartesian Product)

Returns every combination of rows from both tables. If `students` has 6 rows and `departments` has 4 rows, `CROSS JOIN` returns 24 rows.

```sql
SELECT s.first_name, d.department_name
FROM   students   s
CROSS JOIN departments d;
```

**When is CROSS JOIN useful?**
- Generating all possible combinations (schedules, test matrices)
- Pairing every row with a list of values

**Accidental Cartesian product** — the most common join mistake:

```sql
-- WRONG: forgot the ON clause — this is an implicit CROSS JOIN
SELECT s.first_name, d.department_name
FROM   students s, departments d;

-- Or forgot WHERE:
SELECT * FROM students, departments WHERE 1=1;
```

Always use explicit `JOIN … ON` syntax to avoid this.

---

## 8. SELF JOIN

A table joined to itself. Requires two aliases to distinguish the two "copies."

**Use case:** An `employees` table with a `manager_id` FK pointing to another row in the same table.

```sql
-- employees(employee_id, first_name, manager_id)
SELECT
    e.first_name  AS employee,
    m.first_name  AS manager
FROM   employees e
LEFT JOIN employees m
  ON   e.manager_id = m.employee_id
ORDER BY m.first_name, e.first_name;
```

LEFT JOIN is used so employees with no manager (the CEO) are still returned.

---

## 9. Multi-Table Joins (Three or More Tables)

Chain joins sequentially. Each `JOIN … ON` adds another table to the result.

```sql
-- students → enrollments → courses
SELECT
    s.first_name,
    s.last_name,
    c.course_name,
    e.grade
FROM   students   s
JOIN   enrollments e ON e.student_id  = s.student_id
JOIN   courses     c ON c.course_id   = e.course_id
ORDER BY s.last_name, c.course_name;
```

**Tips for multi-table joins:**
1. Use consistent short aliases (s, e, c, d…)
2. Always qualify column names with the table alias
3. Add `WHERE` / `HAVING` after all joins are defined
4. Add joins one at a time and test before adding the next

---

## 10. JOIN + WHERE vs JOIN ON

You can filter using either `WHERE` or by adding conditions to `ON`.

```sql
-- These are equivalent for INNER JOIN:
-- Option A: filter in WHERE
SELECT s.first_name, d.department_name
FROM   students s
JOIN   departments d ON s.department_id = d.department_id
WHERE  d.building = 'Tech Hall';

-- Option B: add condition to ON
SELECT s.first_name, d.department_name
FROM   students s
JOIN   departments d
  ON   s.department_id = d.department_id
  AND  d.building = 'Tech Hall';
```

**For INNER JOIN:** both produce the same result.

**For LEFT JOIN:** they differ. Adding the filter to `ON` preserves unmatched left rows; adding it to `WHERE` eliminates them (turns it back into an INNER JOIN effectively):

```sql
-- LEFT JOIN with WHERE filter: students without matching dept are EXCLUDED
-- (WHERE filters after the join, so NULL right rows fail the condition)
SELECT s.first_name, d.department_name
FROM   students s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE  d.building = 'Tech Hall';  -- eliminates rows where d.* IS NULL

-- LEFT JOIN with ON filter: students without a Tech Hall dept KEPT (NULL dept)
SELECT s.first_name, d.department_name
FROM   students s
LEFT JOIN departments d
  ON   s.department_id = d.department_id
  AND  d.building = 'Tech Hall';
```

---

## 11. JOIN + GROUP BY

Joining before aggregating is a common and powerful pattern:

```sql
-- How many students per department name?
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY student_count DESC;
```

Using `LEFT JOIN` here ensures departments with zero students appear in the output with `COUNT = 0`. With `INNER JOIN`, zero-student departments would be excluded.

**Note:** Use `COUNT(s.student_id)` rather than `COUNT(*)` when the left-joined table may have NULL rows — `COUNT(col)` skips NULLs, giving the correct zero count for empty departments.

---

## 12. Cross-Platform Notes

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|---------------|-----------------|
| INNER JOIN | ✓ | ✓ | ✓ |
| LEFT JOIN | ✓ | ✓ | ✓ |
| RIGHT JOIN | ✓ | ✓ | ✓ |
| FULL OUTER JOIN | ❌ (simulate) | ✓ | ✓ |
| CROSS JOIN | ✓ | ✓ | ✓ |
| SELF JOIN | ✓ | ✓ | ✓ |
| `USING(col)` | ✓ | ✓ | ✓ |
| NULL sort in LEFT JOIN | Manual CASE | `NULLS LAST` | Manual CASE |
| Old comma join syntax | Avoid | Avoid | Avoid |

---

## 13. Common Mistakes

| Mistake | Explanation | Fix |
|---------|-------------|-----|
| Missing ON clause | Produces Cartesian product | Always write `JOIN … ON` |
| `COUNT(*)` with LEFT JOIN | Counts NULL rows as 1 | Use `COUNT(s.col)` on the nullable side |
| Filtering in WHERE after LEFT JOIN | Eliminates unmatched rows, turning it into INNER JOIN | Move filter to ON clause |
| Joining on wrong columns | Mismatched FK/PK gives wrong or huge result | Verify FK/PK relationship first |
| Not aliasing tables | Ambiguous column names | Always use short aliases |
| FULL OUTER JOIN in MySQL | MySQL doesn't support it | Use LEFT + RIGHT UNION |
