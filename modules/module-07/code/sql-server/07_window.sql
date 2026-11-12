-- =============================================================
-- SQL Engineering Academy
-- Engine  : SQL Server 2022
-- Module  : 07 — Window Functions
-- File    : 07_window.sql
-- Author  : SQL Engineering Academy
-- =============================================================

USE university;
GO

-- ----------------------------------------------------------------
-- SECTION 1: ROW_NUMBER()
-- ----------------------------------------------------------------

-- School-wide row number ordered by GPA descending
SELECT
    first_name,
    last_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS row_num
FROM   students
ORDER BY row_num;
GO

-- Row number within each department
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
GO

-- ----------------------------------------------------------------
-- SECTION 2: RANK() and DENSE_RANK()
-- ----------------------------------------------------------------

-- School-wide ranking — observe gap vs no-gap behavior
SELECT
    first_name,
    gpa,
    RANK()       OVER (ORDER BY gpa DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS d_rnk
FROM   students
ORDER BY gpa DESC;
GO

-- Per-department ranking
SELECT
    first_name,
    department_id,
    gpa,
    RANK()       OVER (PARTITION BY department_id ORDER BY gpa DESC) AS dept_rank,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS dept_dense_rank
FROM   students
ORDER BY department_id, dept_rank;
GO

-- ----------------------------------------------------------------
-- SECTION 3: ROW_NUMBER vs RANK vs DENSE_RANK comparison
-- ----------------------------------------------------------------

SELECT
    first_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS row_num,
    RANK()       OVER (ORDER BY gpa DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS d_rnk
FROM   students
ORDER BY gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 4: Top N per group using ROW_NUMBER in a CTE
-- ----------------------------------------------------------------

-- Top 2 students per department by GPA
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
GO

-- ----------------------------------------------------------------
-- SECTION 5: LAG() and LEAD()
-- ----------------------------------------------------------------

-- Compare each student's GPA to the student enrolled just before them
SELECT
    first_name,
    enrolled_at,
    gpa,
    LAG(gpa, 1, 0.0)  OVER (ORDER BY enrolled_at) AS prev_gpa,
    LEAD(gpa, 1, NULL) OVER (ORDER BY enrolled_at) AS next_gpa,
    gpa - LAG(gpa, 1, gpa) OVER (ORDER BY enrolled_at) AS gpa_delta
FROM   students
ORDER BY enrolled_at;
GO

-- LAG within department: compare to previous peer in same dept
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
GO

-- SQL Server 2022: IGNORE NULLS option
-- Skips NULL values when looking for previous/next value
SELECT
    first_name,
    department_id,
    gpa,
    LAG(gpa) IGNORE NULLS OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS prev_non_null_gpa
FROM   students
ORDER BY department_id, gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 6: FIRST_VALUE() and LAST_VALUE()
-- ----------------------------------------------------------------

-- Highest GPA student per department
SELECT
    first_name,
    department_id,
    gpa,
    FIRST_VALUE(first_name) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS top_student_in_dept
FROM   students
ORDER BY department_id, gpa DESC;
GO

-- LAST_VALUE with explicit frame (required for correct behavior)
SELECT
    first_name,
    department_id,
    gpa,
    LAST_VALUE(first_name) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_gpa_student
FROM   students
ORDER BY department_id, gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 7: Aggregate window functions
-- ----------------------------------------------------------------

-- Running count of enrolled students (by enrollment date)
SELECT
    first_name,
    enrolled_at,
    COUNT(*) OVER (ORDER BY enrolled_at) AS running_student_count
FROM   students
ORDER BY enrolled_at;
GO

-- Running GPA sum and running average
SELECT
    first_name,
    enrolled_at,
    gpa,
    SUM(gpa) OVER (ORDER BY enrolled_at)                   AS running_sum,
    ROUND(AVG(CAST(gpa AS FLOAT)) OVER (ORDER BY enrolled_at), 2) AS running_avg
FROM   students
ORDER BY enrolled_at;
GO

-- Each student vs their department average
-- SQL Server: AVG on DECIMAL columns is safe; FLOAT cast ensures precision
SELECT
    first_name,
    department_id,
    gpa,
    ROUND(AVG(CAST(gpa AS FLOAT)) OVER (PARTITION BY department_id), 2) AS dept_avg,
    ROUND(gpa - AVG(CAST(gpa AS FLOAT)) OVER (PARTITION BY department_id), 2) AS diff_from_avg
FROM   students
ORDER BY department_id, gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 8: Window frame — ROWS BETWEEN
-- ----------------------------------------------------------------

-- 3-row moving average (current + 2 preceding)
SELECT
    first_name,
    enrolled_at,
    gpa,
    ROUND(AVG(CAST(gpa AS FLOAT)) OVER (
        ORDER BY enrolled_at
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3
FROM   students
ORDER BY enrolled_at;
GO

-- Full partition sum on every row (not a running sum)
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
GO

-- ----------------------------------------------------------------
-- SECTION 9: NTILE()
-- ----------------------------------------------------------------

-- Divide students into 4 GPA quartiles
SELECT
    first_name,
    gpa,
    NTILE(4) OVER (ORDER BY gpa DESC) AS quartile
FROM   students
ORDER BY quartile, gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 10: PERCENT_RANK() and CUME_DIST()
-- ----------------------------------------------------------------

SELECT
    first_name,
    gpa,
    ROUND(PERCENT_RANK() OVER (ORDER BY gpa), 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY gpa), 4) AS cume_dist
FROM   students
ORDER BY gpa;
GO

-- ----------------------------------------------------------------
-- SECTION 11: Named window — SQL Server does NOT support WINDOW clause
-- Repeat OVER clause instead
-- ----------------------------------------------------------------

-- SQL Server: each window function must repeat its OVER specification
SELECT
    first_name,
    department_id,
    gpa,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rn,
    RANK()       OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rnk,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS d_rnk
FROM   students
ORDER BY department_id, gpa DESC;
GO

-- ----------------------------------------------------------------
-- SECTION 12: NTH_VALUE() — SQL Server 2022+
-- ----------------------------------------------------------------

-- Get the 2nd highest GPA student name per department
SELECT
    first_name,
    department_id,
    gpa,
    NTH_VALUE(first_name, 2) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_top_student
FROM   students
ORDER BY department_id, gpa DESC;
GO
