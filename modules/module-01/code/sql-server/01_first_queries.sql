-- ============================================================
-- SQL Engineering Academy
-- Engine:  Microsoft SQL Server 2022
-- Module:  01 — Database Foundations
-- File:    01_first_queries.sql
-- Author:  SQL Engineering Academy
-- ============================================================
-- Run this file in SSMS or Azure Data Studio.
-- Connect to: localhost:1433  User: SA
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- SECTION 1: Verify your SQL Server installation
-- ────────────────────────────────────────────────────────────

-- 1.1  SQL Server version
SELECT @@VERSION AS sql_server_version;

-- 1.2  Current server name
SELECT @@SERVERNAME AS server_name;

-- 1.3  Current date and time (two ways)
SELECT GETDATE()       AS getdate_result;      -- datetime  (legacy)
SELECT SYSDATETIME()   AS sysdatetime_result;  -- datetime2 (higher precision)
SELECT GETUTCDATE()    AS utc_datetime;

-- 1.4  Current date only
SELECT CAST(GETDATE() AS DATE) AS today;

-- 1.5  Current time only
SELECT CAST(GETDATE() AS TIME) AS current_time_only;


-- ────────────────────────────────────────────────────────────
-- SECTION 2: Literals and expressions
-- ────────────────────────────────────────────────────────────

-- 2.1  String literal  (use single quotes in SQL Server)
SELECT 'Hello, SQL Server!' AS greeting;

-- 2.2  Integer and decimal literals
SELECT 42         AS integer_literal;
SELECT 3.14159    AS decimal_literal;
SELECT 1.0 / 3.0  AS division_result;        -- 0.333333...

-- 2.3  Arithmetic
SELECT 100 + 25   AS addition;
SELECT 100 - 25   AS subtraction;
SELECT 10  * 7    AS multiplication;
SELECT 100 / 4    AS integer_division;       -- 25  (integer ÷ integer)
SELECT 100 / 4.0  AS decimal_division;       -- 25.0
SELECT 17  % 5    AS modulo;                 -- 2

-- 2.4  Tip calculator
SELECT
    48.50                    AS meal_price,
    48.50 * 0.15             AS tip_15_percent,
    48.50 * 1.15             AS total_with_tip,
    ROUND(48.50 * 0.15, 2)   AS tip_rounded;


-- ────────────────────────────────────────────────────────────
-- SECTION 3: String concatenation (T-SQL style)
-- ────────────────────────────────────────────────────────────

-- 3.1  Using + operator
SELECT 'Hello' + ', ' + 'SQL Server!'  AS concat_plus;

-- 3.2  Using CONCAT() — preferred; handles NULLs gracefully
SELECT CONCAT('Hello', ', ', 'SQL Server!')  AS concat_function;

-- 3.3  NULL behavior in concatenation
SELECT 'Hello' + NULL                        AS plus_with_null;    -- NULL
SELECT CONCAT('Hello', NULL, '!')            AS concat_with_null;  -- Hello!

-- 3.4  String length
SELECT LEN('SQL Server')   AS string_length;   -- 10 (excludes trailing spaces)
SELECT DATALENGTH('Hello') AS byte_length;      -- 5


-- ────────────────────────────────────────────────────────────
-- SECTION 4: NULL behavior
-- ────────────────────────────────────────────────────────────

-- 4.1  NULL arithmetic — any operation on NULL returns NULL
SELECT NULL + 5       AS null_plus_5;       -- NULL
SELECT NULL * 100     AS null_times_100;    -- NULL
SELECT 'x' + NULL     AS string_plus_null;  -- NULL

-- 4.2  NULL comparison — always NULL (not TRUE or FALSE)
SELECT
    CASE WHEN NULL = NULL THEN 'Equal'
         ELSE 'Not equal or unknown'
    END AS null_eq_null;   -- 'Not equal or unknown'

-- 4.3  Correct NULL check: IS NULL / IS NOT NULL
SELECT
    CASE WHEN NULL IS NULL     THEN 'IS NULL works'     END AS check_null,
    CASE WHEN NULL IS NOT NULL THEN 'has a value'
                               ELSE 'is NULL'           END AS check_not_null;

-- 4.4  ISNULL() — replace NULL with a default value
SELECT ISNULL(NULL, 'unknown') AS isnull_result;      -- 'unknown'
SELECT ISNULL('existing', 'unknown') AS isnull_result2; -- 'existing'

-- 4.5  COALESCE() — returns first non-NULL value (ANSI standard)
SELECT COALESCE(NULL, NULL, 'third', 'fourth')  AS first_non_null;  -- 'third'


-- ────────────────────────────────────────────────────────────
-- SECTION 5: Useful system views
-- ────────────────────────────────────────────────────────────

-- 5.1  List all user databases
SELECT name, database_id, create_date
FROM   sys.databases
WHERE  database_id > 4         -- skip system databases
ORDER BY name;

-- 5.2  Current database
SELECT DB_NAME() AS current_database;

-- 5.3  Current login and user
SELECT SUSER_NAME()   AS login_name;
SELECT USER_NAME()    AS db_user_name;

-- 5.4  List tables in current database
SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;


-- ────────────────────────────────────────────────────────────
-- SECTION 6: Date arithmetic
-- ────────────────────────────────────────────────────────────

-- 6.1  Days between two dates
SELECT DATEDIFF(DAY, '2000-01-01', GETDATE()) AS days_since_y2k;

-- 6.2  Add an interval to a date
SELECT DATEADD(DAY,   30, GETDATE())  AS thirty_days_from_now;
SELECT DATEADD(MONTH,  6, GETDATE())  AS six_months_from_now;
SELECT DATEADD(YEAR,   1, GETDATE())  AS one_year_from_now;

-- 6.3  Extract date parts
SELECT
    YEAR(GETDATE())    AS current_year,
    MONTH(GETDATE())   AS current_month,
    DAY(GETDATE())     AS current_day,
    DATENAME(WEEKDAY, GETDATE()) AS day_of_week;


-- ────────────────────────────────────────────────────────────
-- SECTION 7: TOP — limit returned rows (T-SQL specific)
-- ────────────────────────────────────────────────────────────
-- Note: PostgreSQL and MySQL use LIMIT instead of TOP.

-- Return exactly 5 rows
-- (requires a table — create a quick temp table to demonstrate)

CREATE TABLE #numbers (n INT);

INSERT INTO #numbers VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

SELECT TOP 5 n FROM #numbers ORDER BY n;          -- 1 2 3 4 5
SELECT TOP 5 n FROM #numbers ORDER BY n DESC;     -- 10 9 8 7 6

-- TOP with percentage
SELECT TOP 30 PERCENT n FROM #numbers ORDER BY n; -- 1 2 3  (3 = 30% of 10)

DROP TABLE #numbers;


-- ────────────────────────────────────────────────────────────
-- SECTION 8: Pagination — OFFSET / FETCH NEXT (SQL Server 2012+)
-- (Equivalent to LIMIT/OFFSET in PostgreSQL and MySQL)
-- ────────────────────────────────────────────────────────────

CREATE TABLE #items (id INT, name VARCHAR(50));
INSERT INTO #items VALUES
  (1,'Alpha'),(2,'Bravo'),(3,'Charlie'),(4,'Delta'),
  (5,'Echo'),(6,'Foxtrot'),(7,'Golf'),(8,'Hotel');

-- Page 1: rows 1–3
SELECT id, name FROM #items
ORDER BY id
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

-- Page 2: rows 4–6
SELECT id, name FROM #items
ORDER BY id
OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;

DROP TABLE #items;


-- ============================================================
-- END OF MODULE 01 — SQL SERVER
-- Next: modules/module-01/code/postgresql/01_first_queries.sql
--       modules/module-01/code/mysql/01_first_queries.sql
-- ============================================================
