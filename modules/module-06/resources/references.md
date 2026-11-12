# Module 06 — References & Further Reading
## Subqueries

---

## Official Documentation

### MySQL 8.0
- [Subquery Syntax](https://dev.mysql.com/doc/refman/8.0/en/subqueries.html)
- [Subqueries with EXISTS](https://dev.mysql.com/doc/refman/8.0/en/exists-and-not-exists-subqueries.html)
- [CTEs (WITH)](https://dev.mysql.com/doc/refman/8.0/en/with.html) — MySQL 8.0 and later only

### PostgreSQL 16
- [Subquery Expressions](https://www.postgresql.org/docs/16/functions-subquery.html) — EXISTS, IN, NOT IN, ANY, ALL
- [WITH Queries (CTEs)](https://www.postgresql.org/docs/16/queries-with.html) — includes MATERIALIZED / NOT MATERIALIZED
- [FROM clause — Subqueries](https://www.postgresql.org/docs/16/queries-table-expressions.html#QUERIES-SUBQUERIES)

### SQL Server 2022
- [Subqueries (T-SQL)](https://learn.microsoft.com/en-us/sql/relational-databases/performance/subqueries)
- [WITH common_table_expression (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql)
- [EXISTS (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/exists-transact-sql)

---

## Subquery Type Quick Reference

| Type | Syntax location | Returns | Notes |
|------|----------------|---------|-------|
| Scalar | SELECT / WHERE / HAVING / ON | 1 row × 1 col | Error if > 1 row |
| Row | WHERE | 1 row, N cols | `WHERE (a, b) = (SELECT …)` |
| Table (derived) | FROM | Table | Must have alias |
| Column list | WHERE IN | 1 col, N rows | NULL trap with NOT IN |
| Correlated | WHERE / HAVING / SELECT | Varies | References outer column |
| CTE | WITH | Table | Reusable; defined once |

---

## NOT IN NULL Trap — Summary

```sql
-- UNSAFE: ANY NULL in the subquery → 0 rows
WHERE col NOT IN (SELECT nullable_col FROM t)

-- SAFE option 1: filter NULLs
WHERE col NOT IN (SELECT nullable_col FROM t WHERE nullable_col IS NOT NULL)

-- SAFE option 2: NOT EXISTS (preferred)
WHERE NOT EXISTS (SELECT 1 FROM t WHERE t.col = outer.col)
```

**Rule:** Always use `NOT EXISTS` instead of `NOT IN` when the subquery column can contain NULLs.

---

## EXISTS vs IN — Decision Guide

| Use case | Recommended |
|----------|-------------|
| Check if related rows exist | EXISTS |
| Anti-join (no related rows) | NOT EXISTS |
| Match a known fixed list of values | IN with literal list |
| Match a subquery result, NULLs possible in subquery | EXISTS |
| Need values from both tables | JOIN (not EXISTS/IN) |

---

## CTE vs Derived Table

| Feature | Derived table | CTE |
|---------|--------------|-----|
| Defined location | Inline in FROM | At top of statement with WITH |
| Can be referenced multiple times | No — must repeat | Yes |
| Readability for multi-step logic | Lower | Higher |
| Recursive support | No | Yes (RECURSIVE in PostgreSQL) |
| Performance | Typically equal | Typically equal (optimizer-dependent) |
| Alias required | Yes | No (name is the alias) |

---

## Correlated Subquery Pattern

```sql
-- Pattern: correlated scalar subquery in WHERE
SELECT …
FROM   outer_table o
WHERE  o.col op (
    SELECT aggregate(inner.col)
    FROM   inner_table inner
    WHERE  inner.fk = o.pk       -- ← correlation condition
);

-- Pattern: correlated EXISTS
SELECT …
FROM   outer_table o
WHERE  EXISTS (
    SELECT 1
    FROM   inner_table i
    WHERE  i.fk = o.pk           -- ← correlation condition
);
```

---

## Platform-Specific Notes

### MySQL 8.0
- CTEs available from 8.0 only. MySQL 5.x has no WITH support.
- Derived tables must use a unique alias per occurrence.
- Correlated subqueries are supported fully.

### PostgreSQL 16
- `AVG()` returns NUMERIC for INTEGER input, DOUBLE PRECISION for FLOAT input.
- `ROUND(val, n)` requires a NUMERIC argument — cast with `::NUMERIC` when input is FLOAT.
- CTE `MATERIALIZED` / `NOT MATERIALIZED` hints available from PostgreSQL 12.
- PostgreSQL inlines CTEs by default (since 12); use `MATERIALIZED` when caching is preferred.

### SQL Server 2022
- `AVG()` on INT columns performs integer division — truncates the result. Cast with `CAST(col AS FLOAT)` or `CAST(col AS DECIMAL(…))` before AVG.
- CTE names must be unique within the same WITH clause.
- Recursive CTEs require the `RECURSIVE` keyword in PostgreSQL but NOT in SQL Server; SQL Server detects recursion automatically.

---

## Recommended Books

- **Learning SQL** — Alan Beaulieu (O'Reilly) — Chapter 9: Subqueries
- **SQL in 10 Minutes** — Ben Forta — Lessons 11, 20
- **SQL Antipatterns** — Bill Karwin — Antipattern: Implicit Columns (related to scalar subquery misuse)
- **T-SQL Fundamentals** — Itzik Ben-Gan — Chapter 4: Subqueries
- **PostgreSQL: Up and Running** — Regina Obe & Leo Hsu — Chapter 7: Functions

---

## Glossary

| Term | Definition |
|------|-----------|
| Scalar subquery | A subquery that returns exactly one column and one row |
| Correlated subquery | A subquery that references a column from the outer query |
| Derived table | A subquery used as a table in the FROM clause; requires an alias |
| CTE | Common Table Expression; a named temporary result set defined with WITH |
| Semi-join | A join that returns rows from one table when a match exists in another (not rows from both tables) — implemented with EXISTS or IN |
| Anti-join | Returns rows from one table that have NO match in another — implemented with NOT EXISTS or LEFT JOIN … WHERE IS NULL |
| NOT IN NULL trap | When a subquery used with NOT IN contains NULL, every comparison is UNKNOWN and no rows pass |
| EXISTS | Returns TRUE if the subquery returns at least one row |
| Materialized CTE | A CTE whose result is computed once and cached, rather than inlined per reference |

---

## Module Connections

| Module | Topic | Connection to Module 06 |
|--------|-------|------------------------|
| Module 03 | WHERE / filtering | Subqueries extend WHERE with dynamic values |
| Module 04 | Aggregate functions | Scalar subqueries often use AVG, MAX, COUNT |
| Module 05 | Joins | EXISTS/NOT EXISTS = NULL-safe alternative to JOIN-based semi/anti-joins |
| Module 07 | Window functions | ROW_NUMBER() / RANK() replace correlated ranking subqueries with cleaner syntax |
