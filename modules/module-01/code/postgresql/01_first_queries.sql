-- ============================================================
-- SQL Engineering Academy
-- Engine:  PostgreSQL 16
-- Module:  01 — Database Foundations
-- File:    01_first_queries.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Run this file in pgAdmin 4 or psql.
-- Connect to: localhost:5432  User: postgres
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: Verify your PostgreSQL installation
-- ────────────────────────────────────────────────────────────

-- 1.1  PostgreSQL version
SELECT version() AS postgresql_version;

-- 1.2  Current database
SELECT current_database() AS current_db;

-- 1.3  Current user
SELECT current_user     AS current_user_name;
SELECT session_user     AS session_user_name;

-- 1.4  Current date and time
SELECT NOW()                 AS now_with_timezone;     -- timestamptz
SELECT CURRENT_TIMESTAMP     AS current_timestamp;     -- same as NOW()
SELECT LOCALTIMESTAMP        AS local_timestamp;       -- without timezone

-- 1.5  Current date only
SELECT CURRENT_DATE          AS today;

-- 1.6  Current time only
SELECT CURRENT_TIME          AS current_time_now;


-- ────────────────────────────────────────────────────────────
-- SECTION 2: Literals and expressions
-- ────────────────────────────────────────────────────────────

-- 2.1  String literal (single quotes in PostgreSQL)
SELECT 'Hello, PostgreSQL!' AS greeting;

-- 2.2  Integer and decimal literals
SELECT 42                   AS integer_literal;
SELECT 3.14159              AS decimal_literal;
SELECT 1.0 / 3.0            AS division_result;    -- 0.33333...

-- 2.3  Arithmetic
SELECT 100 + 25             AS addition;
SELECT 100 - 25             AS subtraction;
SELECT 10  * 7              AS multiplication;
SELECT 100 / 4              AS integer_division;   -- 25
SELECT 100 / 4.0            AS decimal_division;   -- 25.0
SELECT 17  % 5              AS modulo;             -- 2

-- 2.4  Power operator (PostgreSQL-specific: ^)
SELECT 2 ^ 10               AS two_to_the_tenth;   -- 1024

-- 2.5  Tip calculator
SELECT
    48.50                        AS meal_price,
    48.50 * 0.15                 AS tip_15_percent,
    48.50 * 1.15                 AS total_with_tip,
    ROUND((48.50 * 0.15)::NUMERIC, 2) AS tip_rounded;


-- ────────────────────────────────────────────────────────────
-- SECTION 3: String concatenation (PostgreSQL style)
-- ────────────────────────────────────────────────────────────

-- 3.1  Using || (double pipe) — standard SQL
SELECT 'Hello' || ', ' || 'PostgreSQL!'   AS concat_pipe;

-- 3.2  Using CONCAT() — handles NULLs gracefully
SELECT CONCAT('Hello', ', ', 'PostgreSQL!') AS concat_function;

-- 3.3  NULL behavior in concatenation
SELECT 'Hello' || NULL              AS pipe_with_null;     -- NULL
SELECT CONCAT('Hello', NULL, '!')   AS concat_with_null;   -- Hello!

-- 3.4  String length
SELECT LENGTH('PostgreSQL')         AS char_length;        -- 10
SELECT OCTET_LENGTH('Hello')        AS byte_length;        -- 5


-- ────────────────────────────────────────────────────────────
-- SECTION 4: NULL behavior
-- ────────────────────────────────────────────────────────────

-- 4.1  NULL arithmetic — any operation on NULL returns NULL
SELECT NULL + 5           AS null_plus_5;       -- NULL
SELECT NULL * 100         AS null_times_100;    -- NULL
SELECT 'x' || NULL        AS string_pipe_null;  -- NULL

-- 4.2  NULL comparison — always NULL
SELECT NULL = NULL          AS null_eq_null;         -- NULL (not true!)
SELECT NULL IS NULL         AS null_is_null;          -- TRUE
SELECT NULL IS DISTINCT FROM NULL  AS distinct_null;  -- FALSE

-- 4.3  IS DISTINCT FROM (PostgreSQL-specific)
-- Unlike =, IS DISTINCT FROM treats NULL as a known value
SELECT NULL IS NOT DISTINCT FROM NULL  AS not_distinct; -- TRUE

-- 4.4  COALESCE() — ANSI standard; returns first non-NULL
SELECT COALESCE(NULL, NULL, 'third', 'fourth') AS first_non_null; -- 'third'

-- 4.5  NULLIF() — returns NULL if two values are equal
SELECT NULLIF(10, 10)   AS equal_returns_null;    -- NULL
SELECT NULLIF(10, 20)   AS not_equal_returns_first; -- 10


-- ────────────────────────────────────────────────────────────
-- SECTION 5: Useful system catalogs
-- ────────────────────────────────────────────────────────────

-- 5.1  List all databases
SELECT datname     AS database_name,
       pg_size_pretty(pg_database_size(datname)) AS size
FROM   pg_database
ORDER BY datname;

-- 5.2  List tables in current database
SELECT table_schema,
       table_name,
       table_type
FROM   information_schema.tables
WHERE  table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;

-- 5.3  List all schemas
SELECT schema_name
FROM   information_schema.schemata
ORDER BY schema_name;

-- 5.4  PostgreSQL version number
SHOW server_version;


-- ────────────────────────────────────────────────────────────
-- SECTION 6: Date and time arithmetic
-- ────────────────────────────────────────────────────────────

-- 6.1  Days between two dates
SELECT CURRENT_DATE - '2000-01-01'::DATE  AS days_since_y2k;

-- 6.2  Add intervals (PostgreSQL INTERVAL type)
SELECT CURRENT_DATE + INTERVAL '30 days'   AS thirty_days_from_now;
SELECT CURRENT_DATE + INTERVAL '6 months'  AS six_months_from_now;
SELECT CURRENT_DATE + INTERVAL '1 year'    AS one_year_from_now;

-- 6.3  age() — human-readable interval between two timestamps
SELECT age(NOW(), '2000-01-01'::TIMESTAMP) AS age_since_y2k;

-- 6.4  Extract date parts
SELECT
    EXTRACT(YEAR  FROM NOW())   AS current_year,
    EXTRACT(MONTH FROM NOW())   AS current_month,
    EXTRACT(DAY   FROM NOW())   AS current_day,
    TO_CHAR(NOW(), 'Day')       AS day_of_week;

-- 6.5  date_trunc — truncate to precision
SELECT date_trunc('month', NOW())  AS start_of_month;
SELECT date_trunc('year',  NOW())  AS start_of_year;


-- ────────────────────────────────────────────────────────────
-- SECTION 7: LIMIT and OFFSET (PostgreSQL pagination)
-- Note: SQL Server uses TOP / OFFSET-FETCH, MySQL uses LIMIT
-- ────────────────────────────────────────────────────────────

-- Generate a quick series to demonstrate
CREATE TEMP TABLE numbers AS
SELECT generate_series(1, 10) AS n;

-- Return first 5 rows
SELECT n FROM numbers ORDER BY n LIMIT 5;

-- Page 2: skip 5, return next 5
SELECT n FROM numbers ORDER BY n LIMIT 5 OFFSET 5;

DROP TABLE numbers;


-- ────────────────────────────────────────────────────────────
-- SECTION 8: Type casting
-- ────────────────────────────────────────────────────────────

-- 8.1  ANSI CAST (works on all three platforms)
SELECT CAST('3.14' AS NUMERIC)   AS cast_to_numeric;
SELECT CAST(42 AS TEXT)          AS cast_to_text;
SELECT CAST('2026-01-01' AS DATE) AS cast_to_date;

-- 8.2  PostgreSQL :: shorthand (PostgreSQL only)
SELECT '3.14'::NUMERIC           AS coloncolon_numeric;
SELECT 42::TEXT                  AS coloncolon_text;
SELECT '2026-01-01'::DATE        AS coloncolon_date;


-- ============================================================
-- END OF MODULE 01 — POSTGRESQL
-- Compare with: modules/module-01/code/sql-server/01_first_queries.sql
--               modules/module-01/code/mysql/01_first_queries.sql
-- ============================================================
