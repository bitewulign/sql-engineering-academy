-- ============================================================
-- SQL Engineering Academy
-- Engine:  MySQL 8.0
-- Module:  01 — Database Foundations
-- File:    01_first_queries.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Run this file in MySQL Workbench or mysql CLI.
-- Connect to: localhost:3306  User: root
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: Verify your MySQL installation
-- ────────────────────────────────────────────────────────────

-- 1.1  MySQL version
SELECT VERSION()           AS mysql_version;

-- 1.2  Current database
SELECT DATABASE()          AS current_database;

-- 1.3  Current user
SELECT USER()              AS current_user_name;
SELECT CURRENT_USER()      AS current_user_full;    -- includes host

-- 1.4  Current date and time
SELECT NOW()               AS now_datetime;
SELECT CURRENT_TIMESTAMP   AS current_ts;
SELECT SYSDATE()           AS sysdate_result;        -- evaluated at runtime

-- 1.5  Current date only
SELECT CURDATE()           AS today;
SELECT CURRENT_DATE        AS today_alt;

-- 1.6  Current time only
SELECT CURTIME()           AS current_time_now;
SELECT CURRENT_TIME        AS current_time_alt;


-- ────────────────────────────────────────────────────────────
-- SECTION 2: Literals and expressions
-- ────────────────────────────────────────────────────────────

-- 2.1  String literal (single or double quotes in MySQL)
SELECT 'Hello, MySQL!'     AS greeting_single;
SELECT "Hello, MySQL!"     AS greeting_double;    -- MySQL allows this; avoid in production

-- 2.2  Integer and decimal literals
SELECT 42                  AS integer_literal;
SELECT 3.14159             AS decimal_literal;
SELECT 1.0 / 3.0           AS division_result;   -- 0.3333

-- 2.3  Arithmetic
SELECT 100 + 25            AS addition;
SELECT 100 - 25            AS subtraction;
SELECT 10  * 7             AS multiplication;
SELECT 100 / 4             AS division;           -- 25.0000 (MySQL returns decimal)
SELECT 100 DIV 4           AS integer_division;   -- 25
SELECT 17  MOD 5           AS modulo_word;        -- 2
SELECT 17  % 5             AS modulo_symbol;      -- 2

-- 2.4  Tip calculator
SELECT
    48.50                           AS meal_price,
    48.50 * 0.15                    AS tip_15_percent,
    48.50 * 1.15                    AS total_with_tip,
    ROUND(48.50 * 0.15, 2)          AS tip_rounded;


-- ────────────────────────────────────────────────────────────
-- SECTION 3: String concatenation (MySQL style)
-- ────────────────────────────────────────────────────────────

-- 3.1  CONCAT() — MySQL's standard way
SELECT CONCAT('Hello', ', ', 'MySQL!')          AS concat_function;

-- 3.2  CONCAT_WS() — concatenate with separator
SELECT CONCAT_WS(', ', 'Toronto', 'Ontario', 'Canada') AS with_separator;

-- 3.3  NULL behavior
-- CONCAT with NULL returns NULL in MySQL (unlike PostgreSQL's CONCAT)
SELECT CONCAT('Hello', NULL, '!')               AS concat_with_null;  -- NULL in MySQL 8!

-- 3.4  || operator (requires sql_mode PIPES_AS_CONCAT)
-- By default || is a logical OR in MySQL — do not use for strings
-- Use CONCAT() instead to be safe across platforms.

-- 3.5  String length
SELECT LENGTH('MySQL')           AS byte_length;    -- 5
SELECT CHAR_LENGTH('MySQL')      AS char_length;    -- 5 (use this for multibyte-safe)


-- ────────────────────────────────────────────────────────────
-- SECTION 4: NULL behavior
-- ────────────────────────────────────────────────────────────

-- 4.1  NULL arithmetic
SELECT NULL + 5             AS null_plus_5;         -- NULL
SELECT NULL * 100           AS null_times_100;      -- NULL

-- 4.2  NULL comparison
SELECT NULL = NULL           AS null_eq_null;        -- NULL (not 1/true!)
SELECT NULL IS NULL          AS null_is_null;        -- 1 (TRUE)
SELECT NULL IS NOT NULL      AS null_is_not_null;    -- 0 (FALSE)

-- 4.3  NULL-safe equals operator (MySQL-specific: <=>)
SELECT NULL <=> NULL         AS null_safe_equal;     -- 1 (TRUE)
SELECT NULL <=> 1            AS null_safe_not_equal; -- 0 (FALSE)
SELECT 1    <=> 1            AS regular_equal;       -- 1 (TRUE)

-- 4.4  IFNULL() — MySQL equivalent of ISNULL() / COALESCE(x, y)
SELECT IFNULL(NULL, 'default')   AS ifnull_result;    -- 'default'
SELECT IFNULL('value', 'default') AS ifnull_result2;  -- 'value'

-- 4.5  COALESCE() — ANSI standard; returns first non-NULL
SELECT COALESCE(NULL, NULL, 'third')  AS first_non_null; -- 'third'

-- 4.6  NULLIF() — returns NULL if equal, otherwise first value
SELECT NULLIF(10, 10)         AS equal_returns_null;    -- NULL
SELECT NULLIF(10, 20)         AS not_equal_returns_10;  -- 10

-- 4.7  IF() — MySQL conditional (not ANSI; use CASE for portability)
SELECT IF(1 = 1, 'yes', 'no')  AS if_function;         -- 'yes'


-- ────────────────────────────────────────────────────────────
-- SECTION 5: Useful MySQL system tables and variables
-- ────────────────────────────────────────────────────────────

-- 5.1  List all databases
SHOW DATABASES;

-- 5.2  List tables in current database
SHOW TABLES;

-- 5.3  Standard ANSI way (works on all three platforms)
SELECT table_schema, table_name, table_type
FROM   information_schema.tables
WHERE  table_schema = DATABASE()
ORDER BY table_name;

-- 5.4  MySQL global variables
SHOW VARIABLES LIKE 'version%';
SHOW VARIABLES LIKE 'character_set_server';
SHOW VARIABLES LIKE 'max_connections';


-- ────────────────────────────────────────────────────────────
-- SECTION 6: Date and time arithmetic
-- ────────────────────────────────────────────────────────────

-- 6.1  Days between two dates
SELECT DATEDIFF(CURDATE(), '2000-01-01') AS days_since_y2k;

-- 6.2  DATE_ADD() / DATE_SUB()
SELECT DATE_ADD(CURDATE(), INTERVAL 30 DAY)    AS thirty_days_from_now;
SELECT DATE_ADD(CURDATE(), INTERVAL 6 MONTH)   AS six_months_from_now;
SELECT DATE_ADD(CURDATE(), INTERVAL 1 YEAR)    AS one_year_from_now;
SELECT DATE_SUB(CURDATE(), INTERVAL 7 DAY)     AS seven_days_ago;

-- 6.3  TIMESTAMPDIFF — difference in a specific unit
SELECT TIMESTAMPDIFF(YEAR, '1990-05-15', CURDATE())  AS age_in_years;
SELECT TIMESTAMPDIFF(MONTH, '2020-01-01', CURDATE()) AS months_elapsed;

-- 6.4  Extract date parts
SELECT
    YEAR(NOW())     AS current_year,
    MONTH(NOW())    AS current_month,
    DAY(NOW())      AS current_day,
    DAYNAME(NOW())  AS day_of_week,
    WEEKDAY(NOW())  AS weekday_num;    -- 0=Monday, 6=Sunday

-- 6.5  Format dates
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d')          AS iso_date;
SELECT DATE_FORMAT(NOW(), '%W, %M %d, %Y')     AS long_date;


-- ────────────────────────────────────────────────────────────
-- SECTION 7: LIMIT — restrict rows (MySQL pagination)
-- Note: SQL Server uses TOP / OFFSET-FETCH, PostgreSQL uses LIMIT
-- ────────────────────────────────────────────────────────────

-- Create a temporary demo table
CREATE TEMPORARY TABLE numbers (n INT);

INSERT INTO numbers VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

-- Return first 5 rows
SELECT n FROM numbers ORDER BY n LIMIT 5;

-- Page 2: skip 5, return next 5
SELECT n FROM numbers ORDER BY n LIMIT 5 OFFSET 5;

-- MySQL shorthand: LIMIT offset, count
SELECT n FROM numbers ORDER BY n LIMIT 5, 5;   -- same as LIMIT 5 OFFSET 5

DROP TEMPORARY TABLE numbers;


-- ────────────────────────────────────────────────────────────
-- SECTION 8: Type casting
-- ────────────────────────────────────────────────────────────

-- 8.1  ANSI CAST — works on all three platforms
SELECT CAST('3.14' AS DECIMAL(10,2)) AS cast_to_decimal;
SELECT CAST(42 AS CHAR)              AS cast_to_char;
SELECT CAST('2026-01-01' AS DATE)    AS cast_to_date;

-- 8.2  CONVERT() — MySQL version (different from SQL Server's CONVERT)
SELECT CONVERT('3.14', DECIMAL(10,2))  AS convert_decimal;
SELECT CONVERT(42,     CHAR)           AS convert_char;


-- ────────────────────────────────────────────────────────────
-- SECTION 9: Character set and collation
-- (Important for string comparisons and sorting in MySQL)
-- ────────────────────────────────────────────────────────────

-- Check default character set
SELECT @@character_set_server AS server_charset;

-- utf8mb4 is correct for full Unicode (including emoji); utf8 in MySQL is NOT full Unicode
-- Always use utf8mb4 in production MySQL databases.

SHOW CHARSET LIKE 'utf8%';
SHOW COLLATION LIKE 'utf8mb4%';


-- ============================================================
-- END OF MODULE 01 — MYSQL
-- KEY DIFFERENCES SUMMARY (Module 01):
--
-- Feature         SQL Server          PostgreSQL          MySQL
-- -----------------------------------------------------------------
-- Version         @@VERSION           version()           VERSION()
-- Current time    GETDATE()           NOW()               NOW()
-- Current date    CAST(.. AS DATE)    CURRENT_DATE        CURDATE()
-- Concat          + or CONCAT()       || or CONCAT()      CONCAT()
-- Top N rows      SELECT TOP N        LIMIT N             LIMIT N
-- NULL-safe eq    (not built-in)      IS NOT DISTINCT FROM  <=>
-- Integer div     100 / 4 = 25        100 / 4 = 25        100 DIV 4 = 25
-- ============================================================
