# Module 10 — Subqueries & CTEs

## Learning Objectives

By the end of this module you will be able to:

1. Write scalar, row, and table subqueries in SELECT, FROM, WHERE, and HAVING clauses
2. Distinguish correlated from non-correlated subqueries and understand when each executes
3. Use `EXISTS` and `NOT EXISTS` for membership tests (and explain why they are safer than `IN` with NULLs)
4. Write Common Table Expressions (CTEs) with the `WITH` clause to name and reuse query results
5. Stack multiple CTEs in a single `WITH` block
6. Write recursive CTEs to traverse hierarchical data
7. Choose between a subquery, CTE, and JOIN based on readability and performance

---

## Subquery Types at a Glance

| Type | Returns | Typical Location |
|------|---------|-----------------|
| Scalar subquery | Exactly one value (1 row × 1 col) | SELECT list, WHERE, HAVING |
| Row subquery | One row, multiple columns | WHERE with row constructor |
| Table subquery | Multiple rows and columns | FROM clause (derived table) |
| Correlated subquery | Result depends on outer row | WHERE, HAVING, SELECT list |
| EXISTS subquery | TRUE or FALSE | WHERE EXISTS / NOT EXISTS |

---

## CTE vs Subquery vs JOIN

| Approach | Best when |
|----------|-----------|
| **Subquery (inline)** | Simple, one-off use; small result set |
| **CTE** | Logic is reused, multi-step, or deeply nested |
| **JOIN** | Performance-critical; planner optimizes joins better than correlated subqueries |
| **Recursive CTE** | Hierarchical data (org charts, category trees, paths) |

---

## Key Concepts

### Non-correlated subquery
Executes **once** for the entire outer query. The inner query has no reference to outer columns.

```sql
SELECT * FROM students
WHERE gpa > (SELECT AVG(gpa) FROM students);  -- inner runs once
```

### Correlated subquery
Executes **once per outer row**. References a column from the outer query.

```sql
SELECT s.first_name, s.gpa
FROM   students s
WHERE  s.gpa > (
    SELECT AVG(s2.gpa)
    FROM   students s2
    WHERE  s2.department_id = s.department_id  -- references outer s
);
```

### EXISTS vs IN

```sql
-- IN: fails silently when subquery returns any NULL
WHERE student_id NOT IN (SELECT student_id FROM expelled)
-- If expelled has even one NULL student_id → returns 0 rows!

-- NOT EXISTS: NULL-safe
WHERE NOT EXISTS (SELECT 1 FROM expelled e WHERE e.student_id = s.student_id)
```

---

## CTE Syntax

```sql
WITH cte_name AS (
    SELECT …
),
second_cte AS (
    SELECT … FROM cte_name  -- CTEs can reference prior CTEs
)
SELECT * FROM second_cte;
```

### Recursive CTE

```sql
WITH RECURSIVE org_tree AS (
    -- Anchor: top-level rows
    SELECT employee_id, name, manager_id, 0 AS depth
    FROM   employees WHERE manager_id IS NULL

    UNION ALL

    -- Recursive step: each employee under their manager
    SELECT e.employee_id, e.name, e.manager_id, t.depth + 1
    FROM   employees e
    JOIN   org_tree t ON t.employee_id = e.manager_id
)
SELECT * FROM org_tree ORDER BY depth, name;
```

**Platform note:** MySQL 8.0 and PostgreSQL use `WITH RECURSIVE`. SQL Server uses `WITH` (no RECURSIVE keyword) — recursion is detected automatically.

---

## Module Files

| File | Description |
|------|-------------|
| `lecture-notes.md` | Full conceptual coverage with annotated code |
| `code/mysql/10_subqueries.sql` | MySQL 8.0 subquery and CTE examples |
| `code/postgresql/10_subqueries.sql` | PostgreSQL 16 examples |
| `code/sql-server/10_subqueries.sql` | SQL Server 2022 examples |
| `exercises/exercises-10.md` | 10 beginner + 5 intermediate + 3 challenges + 8 IQs |
| `assessments/quiz-10.md` | 15-question multiple-choice quiz |
| `solutions/solutions-10.md` | Full solutions (instructor only) |
| `labs/lab-10-guided.md` | Guided lab — 3 platforms |
| `resources/references.md` | Quick-reference tables and official docs |
| `slides/module-10-slides.md` | 20 Marp slides |

---

## Prerequisites

- Module 03 (SELECT fundamentals — WHERE, aggregates)
- Module 05 (JOINs — understanding multi-table queries)
- Module 07 (Window functions — CTEs for filtering window results)

## Next Module

**Module 11 — Stored Procedures & Functions:** CREATE PROCEDURE, CREATE FUNCTION, parameters, flow control (IF/ELSE, CASE, LOOP), error handling.
