# Module 05 — References & Further Reading
## Joining Tables: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF JOIN

---

## Official Documentation

### MySQL 8.0
- [JOIN Syntax](https://dev.mysql.com/doc/refman/8.0/en/join.html)
- [UNION Syntax](https://dev.mysql.com/doc/refman/8.0/en/union.html) — required for FULL OUTER JOIN simulation
- [Optimizing Joins](https://dev.mysql.com/doc/refman/8.0/en/nested-loop-joins.html)

### PostgreSQL 16
- [SELECT — FROM clause](https://www.postgresql.org/docs/16/sql-select.html#SQL-FROM)
- [Table Expressions](https://www.postgresql.org/docs/16/queries-table-expressions.html)
- [NULLS FIRST / NULLS LAST](https://www.postgresql.org/docs/16/queries-order.html)

### SQL Server 2022
- [FROM — JOIN (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql)
- [FULL OUTER JOIN](https://learn.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql#full-outer-join)
- [ISNULL (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/functions/isnull-transact-sql)

---

## SQL Standard Reference

### ISO/IEC 9075 — Relevant Sections
- **§7.7** — Joined table (all join types defined)
- **§7.9** — Group by and having (GROUP BY with joins)
- Cross join, natural join, and named column joins are also specified in §7.7

---

## Join Type Quick Reference

| Join type | Returns | MySQL | PostgreSQL | SQL Server |
|-----------|---------|-------|-----------|-----------|
| INNER JOIN | Matched rows only | Yes | Yes | Yes |
| LEFT JOIN | All left rows + matched right | Yes | Yes | Yes |
| RIGHT JOIN | All right rows + matched left | Yes | Yes | Yes |
| FULL OUTER JOIN | All rows from both sides | No (simulate) | Yes | Yes |
| CROSS JOIN | Every combination | Yes | Yes | Yes |
| SELF JOIN | Rows related within one table | Yes (as LEFT JOIN) | Yes (as LEFT JOIN) | Yes (as LEFT JOIN) |

---

## FULL OUTER JOIN MySQL Simulation

MySQL does not support FULL OUTER JOIN natively. The standard simulation:

```sql
SELECT l.col, r.col
FROM   left_table  l
LEFT  JOIN right_table r ON l.id = r.id

UNION

SELECT l.col, r.col
FROM   left_table  l
RIGHT JOIN right_table r ON l.id = r.id
WHERE  l.id IS NULL;
```

**Why UNION, not UNION ALL?**
- The first SELECT returns all matched rows + unmatched left rows.
- The second SELECT with `WHERE l.id IS NULL` returns only unmatched right rows.
- Because the second SELECT's rows don't appear in the first, there are no actual duplicates — UNION is safe and idiomatic.

---

## ON vs WHERE Filter Placement

| Filter location | Effect | Use case |
|----------------|--------|---------|
| `ON a.id = b.id AND b.col = 'X'` | Controls which right rows can match; left rows with no match still appear | "All students, with their department only if it is in Tech Hall" |
| `WHERE b.col = 'X'` | Filters the result after the join; NULL right rows are excluded | "Only rows where the department is in Tech Hall" |

**Rule of thumb:** If moving a filter from WHERE to ON changes your row count, the filter placement is semantically important.

---

## COUNT(*) vs COUNT(col) with LEFT JOIN

```sql
-- departments d LEFT JOIN students s
-- A department with 0 students produces one row with s.student_id = NULL

COUNT(*)             -- counts the NULL row → returns 1 (wrong)
COUNT(s.student_id)  -- skips NULL → returns 0 (correct)
```

Always reference the right-side table's primary key inside COUNT() when counting through a LEFT JOIN.

---

## Self Join Pattern

```sql
-- Prerequisite: a table with a self-referencing foreign key
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name  VARCHAR(60),
    manager_id  INT NULL REFERENCES employees(employee_id)
);

-- Self join to show employee–manager pairs
SELECT
    e.first_name  AS employee,
    COALESCE(m.first_name, '(none)') AS manager
FROM   employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

**Two aliases are essential:** `e` = "this row as an employee"; `m` = "this row as a manager".

---

## NULLS FIRST / NULLS LAST (PostgreSQL)

PostgreSQL sorts NULLs before non-NULLs by default when ordering DESC. Use explicit modifiers to control placement:

```sql
ORDER BY avg_gpa DESC NULLS LAST;   -- NULLs at bottom
ORDER BY avg_gpa ASC  NULLS FIRST;  -- NULLs at top (default for ASC)
```

MySQL and SQL Server do not support NULLS FIRST/LAST syntax — NULLs sort lowest (first in ASC, last in DESC).

---

## Anti-join Pattern

Find rows in the left table with no match in the right table:

```sql
-- Pattern
FROM   left_table  l
LEFT JOIN right_table r ON l.id = r.fk_id
WHERE  r.id IS NULL

-- Example: departments with no students
FROM   departments d
LEFT JOIN students s ON s.department_id = d.department_id
WHERE  s.student_id IS NULL
```

Alternative using NOT EXISTS (often equivalent, can be faster on large tables):

```sql
FROM   departments d
WHERE  NOT EXISTS (
    SELECT 1 FROM students s WHERE s.department_id = d.department_id
)
```

---

## Recommended Books

- **Learning SQL** — Alan Beaulieu (O'Reilly) — Chapters 5–7: Querying Multiple Tables
- **SQL in 10 Minutes, Sams Teach Yourself** — Ben Forta — Lessons 12–16
- **SQL Performance Explained** — Markus Winand — Chapter 2: The Index (join performance fundamentals)
- **T-SQL Fundamentals** — Itzik Ben-Gan (Microsoft Press) — Chapter 3: Joins

---

## Glossary

| Term | Definition |
|------|-----------|
| Join | Combine rows from two tables based on a related column |
| ON clause | Specifies the join condition; can also include additional filters |
| WHERE clause | Filters the result set after all joins are evaluated |
| Cartesian product | Every row from one table paired with every row from another |
| Anti-join | Returns rows from the left table with no matching rows in the right |
| Self join | A table joined to itself; requires two aliases |
| NULL propagation | Most operations on NULL produce NULL |
| COALESCE | Returns the first non-NULL value from its argument list |
| ISNULL | SQL Server function; returns replacement if the first argument is NULL |
| IFNULL | MySQL function; equivalent to ISNULL |
| NVL | Oracle function; equivalent to ISNULL (not covered in this module) |
| USING | Alternative join syntax when both tables share the same column name |
| Table alias | A short name for a table within a query (`students s`, `departments d`) |

---

## Module Connections

| Module | Topic | Connection to Module 05 |
|--------|-------|------------------------|
| Module 03 | Filtering with WHERE | WHERE still applies after joins; ON vs WHERE distinction builds on this |
| Module 04 | Aggregate functions | COUNT(col) NULL behavior directly impacts LEFT JOIN counts |
| Module 06 | Subqueries | EXISTS / NOT EXISTS as an alternative to anti-join; correlated subqueries reference outer joins |
| Module 07 | Window functions | ROW_NUMBER() / RANK() over joined result sets |
