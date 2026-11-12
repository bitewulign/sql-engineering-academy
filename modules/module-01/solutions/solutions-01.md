# Module 01 — Exercise Solutions
## Database Foundations and Introduction to SQL

> **Self-check only.** Try each exercise yourself first. Resist the urge to read solutions before making a genuine attempt — that is where most of the learning happens.

---

## Exercise 1 — Version check

**SQL Server:**
```sql
SELECT @@VERSION AS sql_server_version;
```

**PostgreSQL:**
```sql
SELECT version() AS postgresql_version;
```

**MySQL:**
```sql
SELECT VERSION() AS mysql_version;
```

---

## Exercise 2 — Current date and time

**SQL Server:**
```sql
SELECT
    CAST(GETDATE() AS DATE)        AS current_date_only,
    CAST(GETDATE() AS TIME)        AS current_time_only,
    GETDATE()                      AS current_full_timestamp;
```

**PostgreSQL:**
```sql
SELECT
    CURRENT_DATE                   AS current_date_only,
    CURRENT_TIME                   AS current_time_only,
    NOW()                          AS current_full_timestamp;
```

**MySQL:**
```sql
SELECT
    CURDATE()                      AS current_date_only,
    CURTIME()                      AS current_time_only,
    NOW()                          AS current_full_timestamp;
```

---

## Exercise 3 — String output

All three systems:
```sql
SELECT 'SQL is the language of data.' AS message;
```

---

## Exercise 4 — Arithmetic

All three systems (ANSI-compatible):
```sql
SELECT
    7  * 8                         AS seven_times_eight,
    500 / 4                        AS five_hundred_div_four,
    47 % 5                         AS remainder_47_div_5,
    ROUND(12.5 * 3.14159, 2)       AS product_rounded;
```

> **Note (SQL Server):** Use `ROUND(CAST(12.5 * 3.14159 AS DECIMAL(10,4)), 2)` for guaranteed decimal precision.

Expected output:

| seven_times_eight | five_hundred_div_four | remainder_47_div_5 | product_rounded |
|---|---|---|---|
| 56 | 125 | 2 | 39.27 |

---

## Exercise 5 — Tip calculator

All three systems:
```sql
SELECT
    134.75                              AS original_bill,
    ROUND(134.75 * 0.18, 2)            AS tip_18_percent,
    ROUND(134.75 * 0.20, 2)            AS tip_20_percent,
    ROUND(134.75 * 1.18, 2)            AS total_with_18_tip,
    ROUND(134.75 * 1.20, 2)            AS total_with_20_tip;
```

Expected output:

| original_bill | tip_18_percent | tip_20_percent | total_with_18_tip | total_with_20_tip |
|---|---|---|---|---|
| 134.75 | 24.26 | 26.95 | 159.01 | 161.70 |

---

## Exercise 6 — String concatenation

**SQL Server (using `+`):**
```sql
SELECT 'Last name: ' + 'Smith' + ', First name: ' + 'Jane' AS full_label;
```

**PostgreSQL (using `||`):**
```sql
SELECT 'Last name: ' || 'Smith' || ', First name: ' || 'Jane' AS full_label;
```

**MySQL (using `CONCAT()`):**
```sql
SELECT CONCAT('Last name: ', 'Smith', ', First name: ', 'Jane') AS full_label;
```

**All three (ANSI `CONCAT()`):**
```sql
SELECT CONCAT('Last name: ', 'Smith', ', First name: ', 'Jane') AS full_label;
```

> **Key difference:** `CONCAT()` on SQL Server and PostgreSQL treats NULL as empty string in this context; MySQL's `CONCAT()` returns NULL if any argument is NULL. Use `CONCAT_WS()` or `COALESCE()` for safer handling.

---

## Exercise 7 — NULL behavior

Predictions and actual results:

| Expression | Predicted | Actual | Explanation |
|---|---|---|---|
| `NULL + 10` | NULL | NULL | Any arithmetic on NULL returns NULL |
| `NULL = NULL` | NULL | NULL | Comparison with NULL returns NULL (not TRUE!) |
| `NULL IS NULL` | TRUE | TRUE (1) | IS NULL is the correct test |
| `COALESCE(NULL, NULL, 42)` | 42 | 42 | COALESCE returns first non-NULL |
| `CONCAT('Hello', NULL, '!')` | varies | MySQL: NULL; PostgreSQL: 'Hello!' | Key platform difference |

---

## Exercise 8 — COALESCE practice

**First non-NULL from sequence:**
```sql
SELECT COALESCE(NULL, NULL, 'Toronto', 'Canada') AS first_non_null;
-- Result: 'Toronto'
```

**NULLIF returning NULL when input is 0:**
```sql
SELECT NULLIF(0, 0)  AS when_zero;    -- NULL
SELECT NULLIF(25, 0) AS when_nonzero; -- 25
```

---

## Exercise 9 — Days elapsed

**SQL Server:**
```sql
SELECT DATEDIFF(DAY, '1970-01-01', GETDATE()) AS days_since_epoch;
```

**PostgreSQL:**
```sql
SELECT CURRENT_DATE - '1970-01-01'::DATE AS days_since_epoch;
```

**MySQL:**
```sql
SELECT DATEDIFF(CURDATE(), '1970-01-01') AS days_since_epoch;
```

> As of late 2026, all three return approximately 20,800–20,900 days.

---

## Exercise 10 — System catalog query

**SQL Server:**
```sql
SELECT TABLE_NAME
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_CATALOG = DB_NAME()
  AND  TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

**PostgreSQL:**
```sql
SELECT table_name
FROM   information_schema.tables
WHERE  table_schema NOT IN ('pg_catalog', 'information_schema')
  AND  table_type = 'BASE TABLE'
ORDER BY table_name;
```

**MySQL:**
```sql
SELECT TABLE_NAME
FROM   information_schema.TABLES
WHERE  TABLE_SCHEMA = DATABASE()
  AND  TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

---

## Exercise 11 — Pagination

**SQL Server:**
```sql
-- Setup
SELECT TOP 20 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
INTO   #numbers
FROM   sys.objects;

-- Page 1 (rows 1–5)
SELECT n FROM #numbers ORDER BY n OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- Page 2 (rows 6–10)
SELECT n FROM #numbers ORDER BY n OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;

-- Page 3 (rows 11–15)
SELECT n FROM #numbers ORDER BY n OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY;

DROP TABLE #numbers;
```

**PostgreSQL:**
```sql
CREATE TEMP TABLE numbers AS
SELECT generate_series(1, 20) AS n;

SELECT n FROM numbers ORDER BY n LIMIT 5 OFFSET 0;   -- Page 1
SELECT n FROM numbers ORDER BY n LIMIT 5 OFFSET 5;   -- Page 2
SELECT n FROM numbers ORDER BY n LIMIT 5 OFFSET 10;  -- Page 3

DROP TABLE numbers;
```

**MySQL:**
```sql
CREATE TEMPORARY TABLE numbers (n INT);
INSERT INTO numbers VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
                            (11),(12),(13),(14),(15),(16),(17),(18),(19),(20);

SELECT n FROM numbers ORDER BY n LIMIT 5 OFFSET 0;   -- Page 1
SELECT n FROM numbers ORDER BY n LIMIT 5 OFFSET 5;   -- Page 2
SELECT n FROM numbers ORDER BY n LIMIT 5 OFFSET 10;  -- Page 3

DROP TEMPORARY TABLE numbers;
```

---

## Exercise 12 — Type casting

**All three (ANSI CAST):**
```sql
SELECT
    CAST('3.14159' AS DECIMAL(10,5)) AS string_to_numeric,
    CAST(2026      AS CHAR(4))       AS int_to_string,
    CAST('2026-11-11' AS DATE)       AS string_to_date;
```

> **PostgreSQL shorthand (`::`):**
> ```sql
> SELECT '3.14159'::NUMERIC, 2026::TEXT, '2026-11-11'::DATE;
> ```
> The `::` operator is PostgreSQL-specific. SQL Server and MySQL do not support it.

---

## Exercise 13 — Date components

**SQL Server:**
```sql
SELECT
    YEAR(GETDATE())                    AS current_year,
    MONTH(GETDATE())                   AS current_month,
    DAY(GETDATE())                     AS current_day,
    DATENAME(WEEKDAY, GETDATE())       AS day_name,
    DATEPART(WEEKDAY, GETDATE())       AS day_number;  -- 1=Sunday, 7=Saturday
```

**PostgreSQL:**
```sql
SELECT
    EXTRACT(YEAR  FROM NOW())::INT     AS current_year,
    EXTRACT(MONTH FROM NOW())::INT     AS current_month,
    EXTRACT(DAY   FROM NOW())::INT     AS current_day,
    TO_CHAR(NOW(), 'Day')              AS day_name,
    EXTRACT(DOW   FROM NOW())::INT     AS day_number;  -- 0=Sunday, 6=Saturday
```

**MySQL:**
```sql
SELECT
    YEAR(NOW())                        AS current_year,
    MONTH(NOW())                       AS current_month,
    DAY(NOW())                         AS current_day,
    DAYNAME(NOW())                     AS day_name,
    DAYOFWEEK(NOW())                   AS day_number;  -- 1=Sunday, 7=Saturday
```

---

## Exercise 14 — Future dates

**SQL Server:**
```sql
SELECT
    CAST(GETDATE() AS DATE)                              AS today,
    DATEADD(DAY,   90, CAST(GETDATE() AS DATE))         AS ninety_days_out,
    DATEADD(MONTH,  6, CAST(GETDATE() AS DATE))         AS six_months_out,
    DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) AS first_of_month,
    EOMONTH(GETDATE())                                   AS last_of_month;
```

**PostgreSQL:**
```sql
SELECT
    CURRENT_DATE                                         AS today,
    CURRENT_DATE + INTERVAL '90 days'                   AS ninety_days_out,
    CURRENT_DATE + INTERVAL '6 months'                  AS six_months_out,
    date_trunc('month', CURRENT_DATE)::DATE             AS first_of_month,
    (date_trunc('month', CURRENT_DATE)
     + INTERVAL '1 month' - INTERVAL '1 day')::DATE    AS last_of_month;
```

**MySQL:**
```sql
SELECT
    CURDATE()                                            AS today,
    DATE_ADD(CURDATE(), INTERVAL 90 DAY)                AS ninety_days_out,
    DATE_ADD(CURDATE(), INTERVAL 6 MONTH)               AS six_months_out,
    DATE_FORMAT(CURDATE(), '%Y-%m-01')                  AS first_of_month,
    LAST_DAY(CURDATE())                                 AS last_of_month;
```

---

## Exercise 15 — Cross-platform comparison

| Test | SQL Server | PostgreSQL | MySQL |
|------|-----------|-----------|-------|
| `SELECT 1 / 2` | 0 (integer division) | 0 (integer division) | 0 (integer division) |
| `SELECT 1.0 / 2` | 0.500000 | 0.5000000000000000 | 0.5000 |
| `SELECT 'A' = 'a'` | 1 (TRUE — case-insensitive default) | NULL/error — use `='a'` | 1 (TRUE — ci_default) |
| `SELECT NULL + 0` | NULL | NULL | NULL |
| `SELECT CONCAT('x', NULL)` | 'x' (NULL treated as '') | 'x' (NULL treated as '') | NULL |

> **Key takeaway:** Integer division truncates to 0 on all three systems. Always use `1.0 / 2` or cast when you want decimal output. `CONCAT(x, NULL)` behavior is a critical difference: MySQL returns NULL while both SQL Server and PostgreSQL return the non-NULL value(s).

---

## Challenge 16 — The NULL experiment

```sql
SELECT
    1 = 1          AS one_eq_one,       -- TRUE  (1)
    1 = 2          AS one_eq_two,       -- FALSE (0)
    NULL = 1       AS null_eq_one,      -- NULL
    NULL = NULL    AS null_eq_null,     -- NULL  ← NOT TRUE!
    NULL != NULL   AS null_neq_null,    -- NULL
    NULL IS NULL   AS null_is_null,     -- TRUE  (1)
    NOT (NULL = 1) AS not_null_eq_one;  -- NULL  ← NOT TRUE!
```

**Three-valued logic explanation:**

SQL uses three truth values: TRUE, FALSE, and UNKNOWN (which NULL represents in a boolean context). Any comparison involving NULL produces UNKNOWN. UNKNOWN behaves like this in boolean operations:
- `NOT UNKNOWN` → UNKNOWN
- `TRUE AND UNKNOWN` → UNKNOWN
- `FALSE AND UNKNOWN` → FALSE
- `TRUE OR UNKNOWN` → TRUE
- `FALSE OR UNKNOWN` → UNKNOWN

This is why `WHERE col = NULL` never returns rows — the condition evaluates to UNKNOWN, and rows are only included when the WHERE clause is TRUE. Always use `IS NULL` or `IS NOT NULL` to test for the absence of a value.

---

## Challenge 17 — 1,000-row series

**SQL Server (recursive CTE):**
```sql
WITH numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 1000
)
SELECT n FROM numbers
OPTION (MAXRECURSION 1000);
```

**PostgreSQL (generate_series):**
```sql
SELECT generate_series(1, 1000) AS n;
```

**MySQL (recursive CTE — requires MySQL 8.0+):**
```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 1000
)
SELECT n FROM numbers;
```

---

## Challenge 18 — System introspection

**How many total tables?**

```sql
-- SQL Server
SELECT COUNT(*) AS table_count
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = DB_NAME();

-- PostgreSQL
SELECT COUNT(*) AS table_count
FROM   information_schema.tables
WHERE  table_type = 'BASE TABLE'
  AND  table_schema NOT IN ('pg_catalog', 'information_schema');

-- MySQL
SELECT COUNT(*) AS table_count
FROM   information_schema.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = DATABASE();
```

**Table with the most columns:**

```sql
-- SQL Server
SELECT TOP 1 TABLE_NAME, COUNT(*) AS column_count
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_CATALOG = DB_NAME()
GROUP BY TABLE_NAME
ORDER BY column_count DESC;

-- PostgreSQL
SELECT table_name, COUNT(*) AS column_count
FROM   information_schema.columns
WHERE  table_schema NOT IN ('pg_catalog', 'information_schema')
GROUP BY table_name
ORDER BY column_count DESC
LIMIT 1;

-- MySQL
SELECT TABLE_NAME, COUNT(*) AS column_count
FROM   information_schema.COLUMNS
WHERE  TABLE_SCHEMA = DATABASE()
GROUP BY TABLE_NAME
ORDER BY column_count DESC
LIMIT 1;
```

**Tables with "order" in the name:**

```sql
-- SQL Server
SELECT COUNT(*) AS order_table_count
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE'
  AND  LOWER(TABLE_NAME) LIKE '%order%';

-- PostgreSQL
SELECT COUNT(*) AS order_table_count
FROM   information_schema.tables
WHERE  table_type = 'BASE TABLE'
  AND  table_name ILIKE '%order%';

-- MySQL
SELECT COUNT(*) AS order_table_count
FROM   information_schema.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE'
  AND  LOWER(TABLE_NAME) LIKE '%order%';
```

---

## Module 01 Complete

You have worked through every exercise in Database Foundations. When you have verified your solutions here, take the **Module 01 Quiz** (`assessments/quiz-01.md`) to confirm you are ready for Module 02.
