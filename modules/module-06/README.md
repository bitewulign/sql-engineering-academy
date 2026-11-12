# Module 06 — Subqueries

**Track:** Core SQL (all platforms)  
**Prerequisites:** Module 03 (WHERE / filtering), Module 04 (Aggregates), Module 05 (Joins)  
**Estimated study time:** 4–5 hours

---

## Learning Objectives

By the end of this module you will be able to:

- Write scalar subqueries in SELECT, WHERE, and HAVING
- Use `IN`, `NOT IN`, `EXISTS`, and `NOT EXISTS` with subqueries
- Understand when `NOT IN` can silently return 0 rows (NULL trap)
- Write correlated subqueries that reference the outer query row by row
- Build derived tables in the FROM clause
- Write Common Table Expressions (CTEs) with `WITH`
- Choose between a subquery and a JOIN for a given problem

---

## Files in This Module

| File | Description |
|------|-------------|
| `README.md` | This file |
| `lecture-notes.md` | Concept explanations with annotated SQL |
| `code/mysql/06_subqueries.sql` | MySQL 8.0 runnable examples |
| `code/postgresql/06_subqueries.sql` | PostgreSQL 16 runnable examples |
| `code/sql-server/06_subqueries.sql` | SQL Server 2022 runnable examples |
| `exercises/exercises-06.md` | Practice problems (beginner → challenge) |
| `assessments/quiz-06.md` | 15-question multiple-choice quiz |
| `solutions/solutions-06.md` | Full exercise solutions with explanations |
| `labs/lab-06-guided.md` | Step-by-step guided lab (all 3 platforms) |
| `resources/references.md` | Official docs, books, quick-reference tables |
| `slides/module-06-slides.md` | Marp presentation slides |

---

## Key Concepts

### Subquery Types

| Type | Location | Returns | Example use |
|------|----------|---------|-------------|
| Scalar | SELECT, WHERE, HAVING | One value | `WHERE salary > (SELECT AVG(salary)…)` |
| Row | WHERE | One row | `WHERE (dept, role) = (SELECT …)` |
| Table (derived) | FROM | Table | `FROM (SELECT …) AS alias` |
| Correlated | WHERE / HAVING | Varies | References outer query column |

### Subquery Keywords

| Keyword | Use | NULL-safe? |
|---------|-----|-----------|
| `IN (subquery)` | True if value is in result set | ⚠️ NOT IN + NULL = 0 rows |
| `NOT IN (subquery)` | True if value is not in result set | ⚠️ Dangerous with NULLs |
| `EXISTS (subquery)` | True if subquery returns any row | ✅ NULL-safe |
| `NOT EXISTS (subquery)` | True if subquery returns no rows | ✅ NULL-safe |
| `ANY / SOME` | True if any comparison satisfies | Rarely used |
| `ALL` | True if all comparisons satisfy | Rarely used |

### CTEs

```sql
WITH cte_name AS (
    SELECT …
)
SELECT … FROM cte_name;
```

Supported in MySQL 8.0+, PostgreSQL, and SQL Server. Improves readability; can be referenced multiple times. Recursive CTEs (not in this module) handle trees and hierarchies.

---

## Platform Notes

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| Scalar subquery | ✅ | ✅ | ✅ |
| IN / NOT IN | ✅ | ✅ | ✅ |
| EXISTS / NOT EXISTS | ✅ | ✅ | ✅ |
| Derived table (must alias) | ✅ required | ✅ required | ✅ required |
| CTE (WITH) | ✅ 8.0+ | ✅ | ✅ |
| Correlated subquery | ✅ | ✅ | ✅ |
| Lateral join | ✅ 8.0+ | ✅ | ✅ (CROSS APPLY) |

---

## Module 07 Preview

**Window Functions** — ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, running totals with SUM OVER, PARTITION BY.
