# Module 04 — References and Further Reading
## Aggregating Data: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

---

## Official Documentation

### MySQL 8.0

| Topic | URL |
|-------|-----|
| Aggregate functions | https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions.html |
| GROUP BY | https://dev.mysql.com/doc/refman/8.0/en/group-by-handling.html |
| GROUP BY with ROLLUP | https://dev.mysql.com/doc/refman/8.0/en/group-by-modifiers.html |
| GROUP_CONCAT | https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions.html#function_group-concat |
| HAVING clause | https://dev.mysql.com/doc/refman/8.0/en/select.html |

### PostgreSQL 16

| Topic | URL |
|-------|-----|
| Aggregate functions | https://www.postgresql.org/docs/16/functions-aggregate.html |
| GROUP BY | https://www.postgresql.org/docs/16/queries-table-expressions.html#QUERIES-GROUP |
| HAVING | https://www.postgresql.org/docs/16/queries-table-expressions.html#QUERIES-GROUP |
| GROUPING SETS / ROLLUP / CUBE | https://www.postgresql.org/docs/16/queries-table-expressions.html#QUERIES-GROUPING-SETS |
| STRING_AGG | https://www.postgresql.org/docs/16/functions-aggregate.html |

### SQL Server 2022 (T-SQL)

| Topic | URL |
|-------|-----|
| Aggregate functions | https://learn.microsoft.com/en-us/sql/t-sql/functions/aggregate-functions-transact-sql |
| GROUP BY | https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql |
| HAVING | https://learn.microsoft.com/en-us/sql/t-sql/queries/select-having-transact-sql |
| ROLLUP | https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql#group-by-rollup |
| STRING_AGG | https://learn.microsoft.com/en-us/sql/t-sql/functions/string-agg-transact-sql |
| GROUPING | https://learn.microsoft.com/en-us/sql/t-sql/functions/grouping-transact-sql |

---

## Books

| Title | Author | Relevance |
|-------|--------|-----------|
| *Learning SQL* (3rd ed.) | Alan Beaulieu | Chapter 8: Grouping and aggregates — the standard introduction |
| *SQL Performance Explained* | Markus Winand | Chapter 7: Partial results — covers efficient GROUP BY |
| *Joe Celko's SQL for Smarties* | Joe Celko | Chapters on aggregates and NULL — definitive reference |
| *T-SQL Fundamentals* (4th ed.) | Itzik Ben-Gan | Chapter 2: Single-table queries — GROUP BY and HAVING |

---

## Key Concept: NULL Treatment in Aggregate Functions

| Function | NULL rows | Example: values (1, 2, NULL) |
|----------|-----------|------------------------------|
| `COUNT(*)` | Counted | Returns 3 |
| `COUNT(col)` | Skipped | Returns 2 |
| `SUM(col)` | Skipped | Returns 3 |
| `AVG(col)` | Skipped | Returns 1.5 (3÷2, not 3÷3) |
| `MIN(col)` | Skipped | Returns 1 |
| `MAX(col)` | Skipped | Returns 2 |

If a group contains **only NULLs**, `SUM`/`AVG`/`MIN`/`MAX` return `NULL` for that group.

---

## Key Concept: WHERE vs HAVING

```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

| | WHERE | HAVING |
|-|-------|--------|
| When it runs | Before GROUP BY | After GROUP BY |
| What it filters | Individual rows | Groups (summaries) |
| Can use aggregates? | No | Yes |
| Typical use | Row-level conditions | Aggregate conditions |

---

## Key Concept: SQL Server Integer AVG

```sql
DECLARE @t TABLE (val INT);
INSERT INTO @t VALUES (1), (2), (3), (4);

SELECT AVG(val) AS truncated_result FROM @t;        -- Returns 2 (not 2.5)
SELECT AVG(CAST(val AS DECIMAL(5,2))) FROM @t;      -- Returns 2.50 (correct)
```

Rule: when the input to `AVG` in SQL Server is `INT`, `TINYINT`, `SMALLINT`, or `BIGINT`, the result is also integer (truncated). Cast to `DECIMAL` or `FLOAT` before averaging.

---

## Practice Resources

| Platform | URL | Notes |
|----------|-----|-------|
| SQLBolt | https://sqlbolt.com | Lessons 10–12: aggregate functions — interactive |
| SQL Zoo | https://sqlzoo.net | Tutorials: SUM and COUNT |
| Mode SQL Tutorial | https://mode.com/sql-tutorial | Advanced SQL: aggregates section |
| DB Fiddle | https://www.db-fiddle.com | Test GROUP BY / HAVING queries online |

---

## Module 04 Key Terms Quick Reference

| Term | Definition | Platform |
|------|------------|---------|
| `COUNT(*)` | Count every row including NULLs | All |
| `COUNT(col)` | Count non-NULL values in col | All |
| `COUNT(DISTINCT col)` | Count unique non-NULL values | All |
| `SUM(col)` | Sum of non-NULL values | All |
| `AVG(col)` | Average of non-NULL values | All |
| `MIN(col)` | Smallest non-NULL value | All |
| `MAX(col)` | Largest non-NULL value | All |
| `GROUP BY` | Partition rows into groups | All |
| `HAVING` | Filter groups after aggregation | All |
| `WHERE` | Filter rows before aggregation | All |
| `ROLLUP` | Add subtotal/grand total rows | All (different syntax) |
| `GROUPING(col)` | Returns 1 if NULL from ROLLUP | All |
| `GROUP_CONCAT` | Aggregate values into a string | MySQL |
| `STRING_AGG` | Aggregate values into a string | PostgreSQL, SQL Server |
| `WITHIN GROUP` | Order clause for STRING_AGG | SQL Server |
| Conditional aggregation | `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` pattern | All |
| Integer division | SQL Server AVG truncates when input is INT | SQL Server |
