# Module 07 — Window Functions

**Track:** Core SQL (all platforms)  
**Prerequisites:** Module 04 (Aggregates), Module 05 (Joins), Module 06 (Subqueries)  
**Estimated study time:** 5–6 hours

---

## Learning Objectives

By the end of this module you will be able to:

- Explain what a window function is and how it differs from GROUP BY aggregation
- Use `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()` for ranking rows
- Apply `PARTITION BY` to restart ranking or aggregation per group
- Use `LAG()` and `LEAD()` to access previous and next row values
- Use `FIRST_VALUE()` and `LAST_VALUE()` to access boundary rows in a window
- Write running totals and moving averages with aggregate window functions
- Control the window frame with `ROWS BETWEEN` and `RANGE BETWEEN`
- Choose the correct ranking function for a given business question

---

## Files in This Module

| File | Description |
|------|-------------|
| `README.md` | This file |
| `lecture-notes.md` | Concept explanations with annotated SQL |
| `code/mysql/07_window.sql` | MySQL 8.0 runnable examples |
| `code/postgresql/07_window.sql` | PostgreSQL 16 runnable examples |
| `code/sql-server/07_window.sql` | SQL Server 2022 runnable examples |
| `exercises/exercises-07.md` | Practice problems (beginner → challenge) |
| `assessments/quiz-07.md` | 15-question multiple-choice quiz |
| `solutions/solutions-07.md` | Full exercise solutions with explanations |
| `labs/lab-07-guided.md` | Step-by-step guided lab (all 3 platforms) |
| `resources/references.md` | Official docs, books, quick-reference tables |
| `slides/module-07-slides.md` | Marp presentation slides |

---

## Key Concepts

### Window Function Syntax

```sql
function_name(arg) OVER (
    [PARTITION BY col1, col2]
    [ORDER BY col3 [ASC|DESC]]
    [frame_clause]
)
```

### Ranking Functions

| Function | Ties | Gaps | Example output for ranks 1,1,3 |
|----------|------|------|-------------------------------|
| `ROW_NUMBER()` | Arbitrary order | — | 1, 2, 3 |
| `RANK()` | Same rank | Yes | 1, 1, 3 |
| `DENSE_RANK()` | Same rank | No | 1, 1, 2 |

### Value Functions

| Function | Returns |
|----------|---------|
| `LAG(col, n, default)` | Value from n rows before current |
| `LEAD(col, n, default)` | Value from n rows after current |
| `FIRST_VALUE(col)` | Value from the first row in the window frame |
| `LAST_VALUE(col)` | Value from the last row in the window frame |
| `NTH_VALUE(col, n)` | Value from the nth row in the window frame |

### Aggregate Window Functions

Any aggregate function (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`) can be used as a window function by adding `OVER (…)`.

---

## Platform Notes

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| ROW_NUMBER / RANK / DENSE_RANK | ✅ | ✅ | ✅ |
| LAG / LEAD | ✅ | ✅ | ✅ |
| FIRST_VALUE / LAST_VALUE | ✅ | ✅ | ✅ |
| NTH_VALUE | ✅ | ✅ | ✅ 2022+ |
| NTILE | ✅ | ✅ | ✅ |
| ROWS BETWEEN | ✅ | ✅ | ✅ |
| RANGE BETWEEN | ✅ (limited) | ✅ | ✅ |
| Named window (WINDOW clause) | ✅ | ✅ | ❌ |
| IGNORE NULLS in LAG/LEAD | ❌ | ❌ | ✅ 2022+ |
| PERCENT_RANK / CUME_DIST | ✅ | ✅ | ✅ |

---

## Module 08 Preview

**Data Modification** — INSERT, UPDATE, DELETE, MERGE (UPSERT), transactions (BEGIN/COMMIT/ROLLBACK), and isolation levels.
