# Module 10 — References
## Subqueries & CTEs

---

## Official Documentation

| Platform | Topic | URL |
|----------|-------|-----|
| MySQL 8.0 | Subquery syntax | https://dev.mysql.com/doc/refman/8.0/en/subqueries.html |
| MySQL 8.0 | EXISTS and NOT EXISTS | https://dev.mysql.com/doc/refman/8.0/en/exists-and-not-exists-subqueries.html |
| MySQL 8.0 | WITH (CTE) | https://dev.mysql.com/doc/refman/8.0/en/with.html |
| MySQL 8.0 | Recursive CTEs | https://dev.mysql.com/doc/refman/8.0/en/with.html#common-table-expressions-recursive |
| PostgreSQL 16 | Subquery expressions | https://www.postgresql.org/docs/16/functions-subquery.html |
| PostgreSQL 16 | WITH queries (CTE) | https://www.postgresql.org/docs/16/queries-with.html |
| PostgreSQL 16 | LATERAL | https://www.postgresql.org/docs/16/queries-table-expressions.html#QUERIES-LATERAL |
| SQL Server 2022 | Subquery fundamentals | https://learn.microsoft.com/en-us/sql/relational-databases/performance/subqueries |
| SQL Server 2022 | WITH (CTE) | https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql |
| SQL Server 2022 | Recursive CTE | https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql#guidelines-for-defining-and-using-recursive-common-table-expressions |
| SQL Server 2022 | MAXRECURSION hint | https://learn.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-query |

---

## Subquery Types Quick Reference

| Type | Returns | Location | Correlated? |
|------|---------|----------|------------|
| Scalar | 1 row × 1 col | SELECT, WHERE, HAVING, ORDER BY | Optional |
| Row | 1 row × N cols | WHERE with row constructor | Optional |
| Table (derived) | N rows × M cols | FROM clause | No |
| EXISTS | TRUE / FALSE | WHERE | Yes (usually) |
| IN / NOT IN | Set membership | WHERE | Optional |
| Correlated | Depends on outer row | WHERE, SELECT, HAVING | Yes |

---

## EXISTS vs IN vs NOT EXISTS — Decision Table

| Situation | Use |
|-----------|-----|
| Check if any matching row exists | `EXISTS` |
| Filter by a small fixed set of values | `IN ('a', 'b', 'c')` |
| Filter by results of another query (positive) | `IN (subquery)` or `EXISTS` |
| Check if NO matching row exists | `NOT EXISTS` ✅ |
| Check if value not in a set | `NOT IN ('a', 'b')` (OK if no NULLs) |
| Check if value not in subquery results | **`NOT EXISTS`** (NOT IN is unsafe) |

---

## NOT IN NULL Trap — Three-Valued Logic

```sql
-- Scenario: enrollment.student_id happens to have one NULL row
SELECT * FROM students
WHERE student_id NOT IN (SELECT student_id FROM enrollments);
-- If enrollments has even one NULL student_id → returns 0 rows!

-- Why:
-- student_id NOT IN (1, 2, NULL)
-- = student_id <> 1 AND student_id <> 2 AND student_id <> NULL
-- = TRUE       AND TRUE             AND UNKNOWN
-- = UNKNOWN → WHERE only passes TRUE → no rows pass

-- Safe version:
WHERE NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id)
```

---

## CTE Syntax by Platform

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| CTE keyword | `WITH` | `WITH` | `WITH` |
| Recursive keyword | `WITH RECURSIVE` | `WITH RECURSIVE` | `WITH` (no RECURSIVE) |
| CTE in DML | Supported | Supported | Supported |
| Writeable CTE | No (read-only in DML target) | Yes (`WITH … DELETE/UPDATE`) | Yes (CTE as UPDATE target) |
| Materialization hint | None | `MATERIALIZED` / `NOT MATERIALIZED` | None (planner decides) |

---

## Recursive CTE Structure

```sql
-- MySQL / PostgreSQL
WITH RECURSIVE cte_name AS (
    -- Anchor member (non-recursive base case)
    SELECT … WHERE anchor_condition

    UNION ALL

    -- Recursive member (references cte_name)
    SELECT … FROM source JOIN cte_name ON …
    WHERE depth_guard_condition
)
SELECT * FROM cte_name;

-- SQL Server (identical, no RECURSIVE keyword)
WITH cte_name AS (
    SELECT … WHERE anchor_condition
    UNION ALL
    SELECT … FROM source JOIN cte_name ON …
)
SELECT * FROM cte_name
OPTION (MAXRECURSION 100);
```

---

## Recursion Depth Controls

| Platform | Default Limit | How to Change |
|----------|--------------|---------------|
| MySQL 8.0 | 1000 | `SET SESSION cte_max_recursion_depth = N;` |
| PostgreSQL 16 | None built-in | Use depth counter (`WHERE depth < N`) |
| SQL Server 2022 | 100 | `OPTION (MAXRECURSION N)` per query; 0 = unlimited |

Always add an explicit depth counter as a secondary guard regardless of platform.

---

## CTE vs Subquery vs JOIN — When to Use

| Use case | Recommended approach |
|----------|---------------------|
| Filter by aggregate | Subquery or CTE |
| Membership test (positive) | IN or EXISTS |
| Membership test (negative, NULL-safe) | NOT EXISTS |
| Complex multi-step logic | CTE (readable, debuggable) |
| Same result set needed twice | CTE (define once) |
| Filter window function result | CTE wrapping window query |
| Hierarchical / tree data | Recursive CTE |
| Simple lookup on large table | JOIN (planner optimizes) |
| Correlated lookup on large table | Rewrite as JOIN or window function |

---

## Top N per Group — Canonical Pattern

```sql
-- Works on all three platforms
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY group_col ORDER BY sort_col DESC) AS rn
    FROM   source_table
)
SELECT * FROM ranked WHERE rn <= N;
```

---

## Relational Division (All-or-Nothing Membership)

"Find rows from A that are related to every row in B":

```sql
SELECT a.*
FROM   A a
WHERE  NOT EXISTS (
    SELECT b_key FROM B
    WHERE  NOT EXISTS (
        SELECT 1 FROM AB
        WHERE  AB.a_key = a.a_key AND AB.b_key = B.b_key
    )
);
```

Translation: "A rows for which there is no B row they are not related to."

---

## Platform-Specific Extensions

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| LATERAL | Not supported (use correlated subquery) | `CROSS JOIN LATERAL` / `JOIN LATERAL` | `CROSS APPLY` / `OUTER APPLY` |
| CTE in DML | Subquery only | Full writeable CTE | CTE as DML source |
| Array in recursion | Not supported | `ARRAY[id] || child_id` for cycle detection | Not supported (use string path) |
| Date series | Recursive CTE or calendar table | `generate_series(start, end, interval)` | Recursive CTE or `sys.all_objects` trick |

---

## Recommended Reading

- *Learning SQL* (Alan Beaulieu) — Chapters 9 (Subqueries) and 11 (Conditional Logic)
- Use The Index, Luke — Subquery optimization: https://use-the-index-luke.com
- PostgreSQL Documentation — Queries: WITH: https://www.postgresql.org/docs/16/queries-with.html
- SQL Server Documentation — Recursive CTEs: https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql
- *SQL Antipatterns* (Bill Karwin) — Chapter 18: Spaghetti Query (overloaded single query)
