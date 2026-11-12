# Module 03 — References and Further Reading
## Querying Data: SELECT, WHERE, ORDER BY

---

## Official Documentation

### MySQL 8.0

| Topic | URL |
|-------|-----|
| SELECT syntax | https://dev.mysql.com/doc/refman/8.0/en/select.html |
| WHERE clause | https://dev.mysql.com/doc/refman/8.0/en/where-optimization.html |
| LIKE patterns | https://dev.mysql.com/doc/refman/8.0/en/pattern-matching.html |
| Comparison functions | https://dev.mysql.com/doc/refman/8.0/en/comparison-operators.html |
| COALESCE / IFNULL | https://dev.mysql.com/doc/refman/8.0/en/control-flow-functions.html |
| NULL handling | https://dev.mysql.com/doc/refman/8.0/en/working-with-null.html |
| ORDER BY | https://dev.mysql.com/doc/refman/8.0/en/order-by-optimization.html |
| LIMIT and OFFSET | https://dev.mysql.com/doc/refman/8.0/en/limit-optimization.html |

### PostgreSQL 16

| Topic | URL |
|-------|-----|
| SELECT | https://www.postgresql.org/docs/16/sql-select.html |
| Pattern matching (LIKE/ILIKE) | https://www.postgresql.org/docs/16/functions-matching.html |
| NULL comparisons | https://www.postgresql.org/docs/16/functions-comparison.html |
| COALESCE / NULLIF | https://www.postgresql.org/docs/16/functions-conditional.html |
| ORDER BY / NULLS FIRST | https://www.postgresql.org/docs/16/queries-order.html |
| LIMIT / OFFSET | https://www.postgresql.org/docs/16/queries-limit.html |

### SQL Server 2022 (T-SQL)

| Topic | URL |
|-------|-----|
| SELECT | https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql |
| WHERE | https://learn.microsoft.com/en-us/sql/t-sql/queries/where-transact-sql |
| TOP | https://learn.microsoft.com/en-us/sql/t-sql/queries/top-transact-sql |
| OFFSET FETCH | https://learn.microsoft.com/en-us/sql/t-sql/queries/select-order-by-clause-transact-sql |
| LIKE | https://learn.microsoft.com/en-us/sql/t-sql/language-elements/like-transact-sql |
| COALESCE / ISNULL | https://learn.microsoft.com/en-us/sql/t-sql/language-elements/coalesce-transact-sql |
| IIF | https://learn.microsoft.com/en-us/sql/t-sql/functions/logical-functions-iif-transact-sql |
| NULL and UNKNOWN | https://learn.microsoft.com/en-us/sql/t-sql/language-elements/null-and-unknown-transact-sql |

---

## Books

| Title | Author | Relevance |
|-------|--------|-----------|
| *Learning SQL* (3rd ed.) | Alan Beaulieu | Chapters 3–4: Querying — the classic introduction to SELECT |
| *SQL Performance Explained* | Markus Winand | Chapter 1: Why are queries slow? — explains how WHERE filtering affects index usage |
| *The Art of SQL* | Stéphane Faroult | Chapter 3: Filtering data — expert advice on writing correct, fast WHERE clauses |
| *Joe Celko's SQL for Smarties* | Joe Celko | Chapters on NULLs and three-valued logic — definitive reference |

---

## Key Concept: Three-Valued Logic

SQL uses three truth values: TRUE, FALSE, and UNKNOWN. UNKNOWN arises when any operand is NULL.

| Expression | Result |
|-----------|--------|
| `NULL = 1` | UNKNOWN |
| `NULL <> 1` | UNKNOWN |
| `NULL > 1` | UNKNOWN |
| `NULL IS NULL` | TRUE |
| `NULL IS NOT NULL` | FALSE |
| `TRUE AND UNKNOWN` | UNKNOWN |
| `FALSE AND UNKNOWN` | FALSE |
| `TRUE OR UNKNOWN` | TRUE |
| `FALSE OR UNKNOWN` | UNKNOWN |

A `WHERE` clause only passes rows where the predicate evaluates to **TRUE**. UNKNOWN rows are excluded — the same as FALSE rows.

---

## Practice Resources

| Platform | URL | Notes |
|----------|-----|-------|
| SQLBolt | https://sqlbolt.com | Lessons 1–10: SELECT fundamentals — interactive |
| SQL Zoo | https://sqlzoo.net | Tutorials 0–3 cover basic SELECT, WHERE, aggregate |
| DB Fiddle | https://www.db-fiddle.com | Write and test queries online |
| Mode SQL Tutorial | https://mode.com/sql-tutorial | Practical SQL — module on SELECT |
| W3Schools SQL | https://www.w3schools.com/sql | Quick syntax reference |

---

## Module 03 Key Terms Quick Reference

| Term | Definition | Platform |
|------|------------|---------|
| SELECT | Retrieves rows from a table | All |
| WHERE | Filter rows; only TRUE predicates pass | All |
| ORDER BY | Sort result set; without it, order is undefined | All |
| ASC | Ascending sort order (default) | All |
| DESC | Descending sort order | All |
| LIMIT n | Return first n rows | MySQL, PostgreSQL |
| TOP n | Return first n rows | SQL Server |
| OFFSET m ROWS FETCH NEXT n | ANSI pagination | PostgreSQL, SQL Server |
| DISTINCT | Remove duplicate rows | All |
| LIKE | Pattern match with % (any chars) and _ (one char) | All |
| ILIKE | Case-insensitive LIKE | PostgreSQL only |
| IS NULL | Test for absent value | All |
| IS NOT NULL | Test for present value | All |
| BETWEEN a AND b | a <= x <= b (inclusive both ends) | All |
| IN (list) | Match any value in list | All |
| NOT IN | Exclude values in list (careful with NULLs!) | All |
| COALESCE | Return first non-NULL value | All (ANSI) |
| ISNULL | 2-arg NULL replacement | SQL Server |
| IFNULL | 2-arg NULL replacement | MySQL |
| NULLIF | Return NULL if two values are equal | All (ANSI) |
| CASE WHEN | Conditional expression | All |
| IIF | 2-branch CASE shorthand | SQL Server |
| Three-valued logic | TRUE / FALSE / UNKNOWN — how NULLs behave in predicates | All |
| Alias | Alternative column name in SELECT output | All |
| NULLS FIRST / NULLS LAST | Control NULL position in ORDER BY | PostgreSQL |
