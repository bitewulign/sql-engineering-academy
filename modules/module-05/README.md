# Module 05 — Joining Tables
## INNER JOIN · LEFT JOIN · RIGHT JOIN · FULL OUTER JOIN · CROSS JOIN

**Track:** A (MySQL 8.0) · B (PostgreSQL 16) · C (SQL Server 2022)  
**Level:** Intermediate  
**Estimated time:** 5–6 hours

---

## Learning Objectives

By the end of this module you will be able to:

1. Explain what a join is and why it is needed
2. Write `INNER JOIN` to return only matched rows
3. Write `LEFT JOIN` and `RIGHT JOIN` to preserve unmatched rows from one side
4. Write `FULL OUTER JOIN` to preserve unmatched rows from both sides
5. Use `CROSS JOIN` deliberately and avoid accidental Cartesian products
6. Write `SELF JOIN` to relate rows within the same table
7. Chain multiple joins across three or more tables
8. Understand how join type interacts with `GROUP BY` and `WHERE`
9. Use table aliases to write readable multi-table queries

---

## Module Contents

```
module-05/
├── README.md
├── lecture-notes.md
├── code/
│   ├── mysql/05_joins.sql
│   ├── postgresql/05_joins.sql
│   └── sql-server/05_joins.sql
├── exercises/exercises-05.md
├── assessments/quiz-05.md
├── solutions/solutions-05.md
├── labs/lab-05-guided.md
├── resources/references.md
└── slides/module-05-slides.md
```

---

## Key Concepts

| Join Type | Returns |
|-----------|---------|
| `INNER JOIN` | Only rows that match in both tables |
| `LEFT JOIN` | All rows from left table; NULLs for right where no match |
| `RIGHT JOIN` | All rows from right table; NULLs for left where no match |
| `FULL OUTER JOIN` | All rows from both tables; NULLs where no match on either side |
| `CROSS JOIN` | Every combination of rows from both tables (Cartesian product) |
| `SELF JOIN` | A table joined to itself using aliases |

---

## Platform Notes

- `FULL OUTER JOIN` is supported on PostgreSQL and SQL Server; **MySQL does not support it natively** — it must be simulated with `LEFT JOIN UNION RIGHT JOIN`.
- All other join types (INNER, LEFT, RIGHT, CROSS, SELF) work identically across all three platforms.
- MySQL requires `USING(col)` or `ON t1.col = t2.col` syntax for explicit joins.

---

## Module 06 Preview

**Module 06 — Subqueries:** Scalar subqueries, correlated subqueries, `IN`/`EXISTS`/`NOT EXISTS`, subqueries in FROM (derived tables).
