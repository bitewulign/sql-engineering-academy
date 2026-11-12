# Module 07 — References
## Window Functions

---

## Official Documentation

| Platform | Topic | URL |
|----------|-------|-----|
| MySQL 8.0 | Window function concepts | https://dev.mysql.com/doc/refman/8.0/en/window-functions.html |
| MySQL 8.0 | Window function descriptions | https://dev.mysql.com/doc/refman/8.0/en/window-function-descriptions.html |
| MySQL 8.0 | Window function frame specification | https://dev.mysql.com/doc/refman/8.0/en/window-functions-frames.html |
| PostgreSQL 16 | Window functions tutorial | https://www.postgresql.org/docs/16/tutorial-window.html |
| PostgreSQL 16 | Window function calls | https://www.postgresql.org/docs/16/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS |
| PostgreSQL 16 | Window function list | https://www.postgresql.org/docs/16/functions-window.html |
| SQL Server 2022 | OVER clause | https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql |
| SQL Server 2022 | Ranking functions | https://learn.microsoft.com/en-us/sql/t-sql/functions/ranking-functions-transact-sql |
| SQL Server 2022 | Analytic functions | https://learn.microsoft.com/en-us/sql/t-sql/functions/analytic-functions-transact-sql |

---

## Ranking Functions Quick Reference

| Function | Ties | Gaps after tie | Example for [1st, 2nd, 2nd, 3rd] |
|----------|------|----------------|----------------------------------|
| `ROW_NUMBER()` | Arbitrary order (unique) | — | 1, 2, 3, 4 |
| `RANK()` | Same rank | Yes | 1, 2, 2, 4 |
| `DENSE_RANK()` | Same rank | No | 1, 2, 2, 3 |

---

## Value Functions Quick Reference

| Function | Returns | Frame note |
|----------|---------|------------|
| `LAG(col, n, default)` | Value n rows before current | No frame clause |
| `LEAD(col, n, default)` | Value n rows after current | No frame clause |
| `FIRST_VALUE(col)` | First row in current frame | Default frame is usually correct |
| `LAST_VALUE(col)` | Last row in current frame | **Must** specify full frame |
| `NTH_VALUE(col, n)` | nth row in current frame | Full frame recommended |

---

## LAST_VALUE Fix — Always Use This Frame

```sql
LAST_VALUE(col) OVER (
    PARTITION BY ...
    ORDER BY ...
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING   -- required
)
```

**Why:** Default frame with `ORDER BY` = `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. For `LAST_VALUE`, "last row in frame" = current row. Without the explicit frame, `LAST_VALUE` always returns the current row's own value.

---

## Window Frame Clause Reference

```
ROWS  BETWEEN <start> AND <end>
RANGE BETWEEN <start> AND <end>
```

| Boundary Keyword | Meaning |
|-----------------|---------|
| `UNBOUNDED PRECEDING` | First row of the partition |
| `n PRECEDING` | n rows before current |
| `CURRENT ROW` | Current row only |
| `n FOLLOWING` | n rows after current |
| `UNBOUNDED FOLLOWING` | Last row of the partition |

**Default frame** (when ORDER BY present): `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`  
**Default frame** (no ORDER BY): `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`

---

## ROWS vs RANGE

| | ROWS | RANGE |
|-|------|-------|
| Counts | Physical rows | Rows with same ORDER BY value |
| Ties | Splits tied rows | Groups tied rows |
| Precision | Exact | May include more rows than expected |
| Use for | Moving averages, N-row windows | Running totals where ties must group |

**Recommendation:** Use `ROWS` for moving averages and sliding windows. `RANGE` is appropriate for running totals where rows with equal dates/values must all be counted together.

---

## Top N per Group — Canonical Pattern

```sql
WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY group_col
            ORDER BY sort_col DESC
        ) AS rn
    FROM source_table
)
SELECT *
FROM   ranked
WHERE  rn <= N;
```

**To include all tied students at position N:** Replace `ROW_NUMBER()` with `RANK()` or `DENSE_RANK()`.

---

## Filtering Window Function Results

Window functions execute in the SELECT phase — after WHERE and HAVING. You cannot reference a window function result in WHERE or HAVING directly.

```sql
-- WRONG: cannot reference rnk in WHERE
SELECT first_name, RANK() OVER (...) AS rnk
FROM   students
WHERE  rnk = 1;   -- error

-- CORRECT: wrap in a CTE or subquery
WITH ranked AS (
    SELECT first_name, RANK() OVER (...) AS rnk FROM students
)
SELECT first_name FROM ranked WHERE rnk = 1;
```

---

## Platform Feature Matrix

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| `ROW_NUMBER()` | ✅ | ✅ | ✅ |
| `RANK()` | ✅ | ✅ | ✅ |
| `DENSE_RANK()` | ✅ | ✅ | ✅ |
| `LAG()` / `LEAD()` | ✅ | ✅ | ✅ |
| `FIRST_VALUE()` / `LAST_VALUE()` | ✅ | ✅ | ✅ |
| `NTH_VALUE()` | ✅ | ✅ | ✅ 2022+ |
| `NTILE()` | ✅ | ✅ | ✅ |
| `PERCENT_RANK()` | ✅ | ✅ | ✅ |
| `CUME_DIST()` | ✅ | ✅ | ✅ |
| `ROWS BETWEEN` | ✅ | ✅ | ✅ |
| `RANGE BETWEEN` | ✅ (limited) | ✅ | ✅ |
| Named `WINDOW` clause | ✅ | ✅ | ❌ |
| `IGNORE NULLS` in LAG/LEAD | ❌ | ❌ | ✅ 2022+ |
| `ROUND` float input | ✅ | ❌ need `::NUMERIC` | ✅ |
| `AVG` INT truncation risk | No (DECIMAL gpa) | No | Yes if column is INT |

---

## Platform-Specific Notes

### MySQL 8.0
- Window functions require MySQL **8.0** (not available in 5.x)
- `WINDOW w AS (…)` named clause supported
- `ROUND(AVG(gpa), 2)` works directly on DECIMAL columns
- `RANGE` frame with non-numeric ORDER BY has limited support

### PostgreSQL 16
- `ROUND` requires `NUMERIC` input: `ROUND(value::NUMERIC, n)`
- `AVG` returns `DOUBLE PRECISION` for float inputs; cast before ROUND
- `WINDOW w AS (…)` named clause supported
- `NULLS FIRST` / `NULLS LAST` ORDER BY modifiers supported
- CTE `MATERIALIZED` hint (Module 06) works independently of window functions

### SQL Server 2022
- **No** `WINDOW` clause — repeat OVER clause for each function
- `AVG` on INT columns truncates: use `AVG(CAST(col AS FLOAT))`
- `IGNORE NULLS` in LAG/LEAD: SQL Server 2022+
- `NTH_VALUE`: SQL Server 2022+
- `GO` batch separators required between queries in scripts

---

## Recommended Reading

- *Learning SQL* (Alan Beaulieu) — Chapter 16: Analytic Functions
- *SQL Antipatterns* (Bill Karwin) — Chapter 5: EAV (uses window functions in alternatives)
- Use The Index, Luke: https://use-the-index-luke.com/sql/partial-results/window-functions
- PostgreSQL documentation: https://www.postgresql.org/docs/16/tutorial-window.html
