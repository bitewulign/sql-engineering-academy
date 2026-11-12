-- =============================================================
-- SQL Engineering Academy
-- Engine  : PostgreSQL 16
-- Module  : 07 — Window Functions
-- File    : 07_window.sql
-- Author  : SQL Engineering Academy
-- =============================================================

\c university

-- ----------------------------------------------------------------
-- SECTION 1: ROW_NUMBER()
-- ----------------------------------------------------------------

SELECT
    first_name,
    last_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS row_num
FROM   students
ORDER BY row_num;

-- Per department
SELECT
    first_name,
    department_id,
    gpa,
    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS dept_row_num
FROM   students
ORDER BY department_id, dept_row_num;

-- ----------------------------------------------------------------
-- SECTION 2: RANK() and DENSE_RANK()
-- ----------------------------------------------------------------

SELECT
    first_name,
    gpa,
    RANK()       OVER (ORDER BY gpa DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS d_rnk
FROM   students
ORDER BY gpa DESC;

-- Per-department ranking
SELECT
    first_name,
    department_id,
    gpa,
    RANK()       OVER (PARTITION BY department_id ORDER BY gpa DESC) AS dept_rank,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS dept_dense_rank
FROM   students
ORDER BY department_id, dept_rank;

-- ----------------------------------------------------------------
-- SECTION 3: All three ranking functions side by side
-- ----------------------------------------------------------------

SELECT
    first_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS row_num,
    RANK()       OVER (ORDER BY gpa DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS d_rnk
FROM   students
ORDER BY gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 4: Top N per group via CTE
-- ----------------------------------------------------------------

WITH ranked_students AS (
    SELECT
        first_name,
        department_id,
        gpa,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY gpa DESC
        ) AS rn
    FROM students
)
SELECT first_name, department_id, gpa
FROM   ranked_students
WHERE  rn <= 2
ORDER BY department_id, gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 5: LAG() and LEAD()
-- ----------------------------------------------------------------

SELECT
    first_name,
    enrolled_at,
    gpa,
    LAG(gpa, 1, 0.0::NUMERIC)  OVER (ORDER BY enrolled_at) AS prev_gpa,
    LEAD(gpa, 1, NULL)          OVER (ORDER BY enrolled_at) AS next_gpa,
    gpa - LAG(gpa, 1, gpa)     OVER (ORDER BY enrolled_at) AS gpa_delta
FROM   students
ORDER BY enrolled_at;

-- Within partition: compare to previous peer in same department
SELECT
    first_name,
    department_id,
    gpa,
    LAG(gpa) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS prev_dept_gpa
FROM   students
ORDER BY department_id, gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 6: FIRST_VALUE() and LAST_VALUE()
-- ----------------------------------------------------------------

-- Top student name per department
SELECT
    first_name,
    department_id,
    gpa,
    FIRST_VALUE(first_name) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS top_student
FROM   students
ORDER BY department_id, gpa DESC;

-- LAST_VALUE with explicit full-partition frame
SELECT
    first_name,
    department_id,
    gpa,
    LAST_VALUE(first_name) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS bottom_student
FROM   students
ORDER BY department_id, gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 7: Aggregate window functions
-- ----------------------------------------------------------------

-- Running student count by enrollment date
SELECT
    first_name,
    enrolled_at,
    COUNT(*) OVER (ORDER BY enrolled_at) AS running_count
FROM   students
ORDER BY enrolled_at;

-- Running sum and average GPA
SELECT
    first_name,
    enrolled_at,
    gpa,
    SUM(gpa)                              OVER (ORDER BY enrolled_at) AS running_sum,
    ROUND(AVG(gpa)::NUMERIC OVER (ORDER BY enrolled_at), 2)           AS running_avg
FROM   students
ORDER BY enrolled_at;

-- PostgreSQL: OVER with aggregate requires CAST for ROUND
SELECT
    first_name,
    department_id,
    gpa,
    ROUND(AVG(gpa) OVER (PARTITION BY department_id)::NUMERIC, 2) AS dept_avg
FROM   students
ORDER BY department_id, gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 8: Window frames
-- ----------------------------------------------------------------

-- 3-row moving average
SELECT
    first_name,
    enrolled_at,
    gpa,
    ROUND(AVG(gpa) OVER (
        ORDER BY enrolled_at
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    )::NUMERIC, 2) AS moving_avg_3
FROM   students
ORDER BY enrolled_at;

-- Full partition frame (total, not running)
SELECT
    first_name,
    department_id,
    gpa,
    SUM(gpa) OVER (
        PARTITION BY department_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_total_gpa
FROM   students
ORDER BY department_id;

-- ----------------------------------------------------------------
-- SECTION 9: NTILE()
-- ----------------------------------------------------------------

SELECT
    first_name,
    gpa,
    NTILE(4) OVER (ORDER BY gpa DESC) AS quartile
FROM   students
ORDER BY quartile, gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 10: Named window (WINDOW clause — PostgreSQL)
-- ----------------------------------------------------------------

SELECT
    first_name,
    department_id,
    gpa,
    ROW_NUMBER()  OVER w AS rn,
    RANK()        OVER w AS rnk,
    DENSE_RANK()  OVER w AS d_rnk
FROM   students
WINDOW w AS (PARTITION BY department_id ORDER BY gpa DESC)
ORDER BY department_id, gpa DESC;

-- ----------------------------------------------------------------
-- SECTION 11: PERCENT_RANK() and CUME_DIST()
-- ----------------------------------------------------------------

SELECT
    first_name,
    gpa,
    ROUND(PERCENT_RANK() OVER (ORDER BY gpa)::NUMERIC, 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY gpa)::NUMERIC, 4) AS cume_dist
FROM   students
ORDER BY gpa;
