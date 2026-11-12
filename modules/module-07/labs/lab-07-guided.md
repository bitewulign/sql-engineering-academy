# Module 07 — Guided Lab
## Window Functions

**Estimated time:** 90–120 minutes  
**Platforms covered:** Part A — MySQL 8.0 · Part B — PostgreSQL 16 · Part C — SQL Server 2022

---

## Prerequisites

- `university` database populated with synthetic student, department, enrollment, and course data
- Completed Module 07 lecture-notes.md and MySQL code examples

---

## Part A — MySQL 8.0

Connect to your MySQL instance and select the database:

```sql
USE university;
```

---

### A-01: ROW_NUMBER — Unique sequential ranks

Assign a school-wide rank to each student ordered by GPA descending. Observe that no two students share the same number, even if their GPAs are identical.

```sql
SELECT
    first_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS school_rank
FROM   students
ORDER BY school_rank;
```

**Question:** If two students both have GPA 3.85, what ranks do they receive? How does this differ from RANK()?

---

### A-02: RANK vs DENSE_RANK — Spot the difference

Run all three ranking functions side by side:

```sql
SELECT
    first_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS rn,
    RANK()       OVER (ORDER BY gpa DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS d_rnk
FROM   students
ORDER BY gpa DESC;
```

**Task:** Find a GPA value that appears more than once. Record what each function returns for those tied rows. Note the gap in RANK() that DENSE_RANK() avoids.

---

### A-03: PARTITION BY — Per-department ranking

Apply `PARTITION BY` to restart ranking within each department:

```sql
SELECT
    first_name,
    department_id,
    gpa,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS dept_rank
FROM   students
ORDER BY department_id, dept_rank;
```

**Question:** Can two students in different departments both have `dept_rank = 1`? Why?

---

### A-04: Top N per group

Extract the top 2 students per department by GPA:

```sql
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
```

**Task:** Change `ROW_NUMBER()` to `RANK()`. What happens if three students in one department have the same GPA? How many rows does the department return?

---

### A-05: LAG and LEAD — Accessing adjacent rows

Compare each student's GPA to the student enrolled immediately before them:

```sql
SELECT
    first_name,
    enrolled_at,
    gpa,
    LAG(gpa, 1, 0.0) OVER (ORDER BY enrolled_at) AS prev_gpa,
    ROUND(gpa - LAG(gpa, 1, gpa) OVER (ORDER BY enrolled_at), 2) AS gpa_change
FROM   students
ORDER BY enrolled_at;
```

**Question:** What value does `LAG` return for the very first row? What would happen if you omitted the third argument (`0.0`)?

---

### A-06: LAST_VALUE bug — Demonstrate and fix

**Step 1 — Broken query (default frame):**

```sql
-- This looks correct but produces wrong results for LAST_VALUE
SELECT
    first_name,
    department_id,
    gpa,
    LAST_VALUE(first_name) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS should_be_lowest_gpa_student
FROM   students
ORDER BY department_id, gpa DESC;
```

Observe: every row shows itself as `should_be_lowest_gpa_student`. This is the LAST_VALUE bug.

**Step 2 — Fixed query (explicit frame):**

```sql
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
```

Observe: now all rows in a department show the same `lowest_gpa_student` — the student with the lowest GPA in that department.

**Explain in your own words:** Why does the default frame cause this bug?

---

### A-07: Aggregate window function — Running total

Compute a running GPA sum and running average as students enrolled over time:

```sql
SELECT
    first_name,
    enrolled_at,
    gpa,
    SUM(gpa) OVER (ORDER BY enrolled_at)                 AS running_sum,
    ROUND(AVG(gpa) OVER (ORDER BY enrolled_at), 2)        AS running_avg
FROM   students
ORDER BY enrolled_at;
```

**Task:** Remove `ORDER BY enrolled_at` from the OVER clause. Observe what happens to `running_sum`. Explain the difference.

---

### A-08: Moving average with explicit frame

Compute a 3-row moving average of GPA by enrollment date:

```sql
SELECT
    first_name,
    enrolled_at,
    gpa,
    ROUND(AVG(gpa) OVER (
        ORDER BY enrolled_at
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3
FROM   students
ORDER BY enrolled_at;
```

**Question:** For the second row, the moving average is computed over how many rows? For the third row? For the tenth row?

---

### A-09: Named WINDOW clause — MySQL 8.0

Rewrite the three-function ranking query using a named window to avoid repetition:

```sql
SELECT
    first_name,
    department_id,
    gpa,
    ROW_NUMBER() OVER w AS rn,
    RANK()       OVER w AS rnk,
    DENSE_RANK() OVER w AS d_rnk
FROM   students
WINDOW w AS (PARTITION BY department_id ORDER BY gpa DESC)
ORDER BY department_id, gpa DESC;
```

**Task:** Compare this output to A-02. Confirm the results are identical.

---

## Part B — PostgreSQL 16

Connect to your PostgreSQL instance:

```sql
\c university
```

---

### B-01: ROUND with NUMERIC cast — PostgreSQL requirement

PostgreSQL's `ROUND(float, n)` requires a `NUMERIC` input. Run both and observe:

```sql
-- This may raise: function round(double precision, integer) does not exist
SELECT
    first_name,
    department_id,
    AVG(gpa) OVER (PARTITION BY department_id) AS dept_avg_broken
FROM students;

-- Fixed: cast to NUMERIC
SELECT
    first_name,
    department_id,
    ROUND(AVG(gpa) OVER (PARTITION BY department_id)::NUMERIC, 2) AS dept_avg
FROM students
ORDER BY department_id, gpa DESC;
```

**Note:** MySQL and SQL Server apply ROUND to float without issue. PostgreSQL enforces strict type matching.

---

### B-02: PERCENT_RANK and CUME_DIST

```sql
SELECT
    first_name,
    gpa,
    ROUND(PERCENT_RANK() OVER (ORDER BY gpa)::NUMERIC, 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY gpa)::NUMERIC, 4) AS cume_dist
FROM   students
ORDER BY gpa;
```

**Question:** What value does `PERCENT_RANK()` return for the student with the lowest GPA? The highest? Why?

---

### B-03: Named WINDOW clause — PostgreSQL

```sql
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
```

---

### B-04: NULLS LAST in ORDER BY

When ordering by a nullable column, PostgreSQL defaults `NULLS LAST` for ascending, `NULLS FIRST` for descending. Test explicitly:

```sql
-- Students with NULL gpa appear last (ascending)
SELECT first_name, gpa
FROM   students
ORDER BY gpa ASC NULLS LAST;

-- Students with NULL gpa appear last (descending) — explicit override needed
SELECT first_name, gpa
FROM   students
ORDER BY gpa DESC NULLS LAST;
```

**Task:** Modify the department ranking from B-03 to place NULL GPAs last within each department partition.

---

### B-05: Filtering window results with a CTE

Find only students ranked 1st in their department by GPA:

```sql
WITH dept_ranked AS (
    SELECT
        first_name,
        department_id,
        gpa,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY gpa DESC
        ) AS dept_rank
    FROM students
)
SELECT first_name, department_id, gpa
FROM   dept_ranked
WHERE  dept_rank = 1
ORDER BY department_id;
```

**Confirm:** Try placing `WHERE dept_rank = 1` directly in the main SELECT (without the CTE). Observe the error message. Explain why this fails.

---

## Part C — SQL Server 2022

Connect to your SQL Server instance:

```sql
USE university;
GO
```

---

### C-01: No named WINDOW clause — Repeat OVER

SQL Server does not support the `WINDOW` clause. Each function must repeat its OVER specification:

```sql
-- SQL Server: repeat the OVER clause
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
```

**Note:** This is functionally identical to MySQL/PostgreSQL; only the syntax differs.

---

### C-02: AVG with FLOAT cast — SQL Server precision

SQL Server's `AVG` on integer columns truncates. When `gpa` is stored as `DECIMAL(3,2)`, truncation does not occur, but demonstrate the FLOAT cast pattern for safety:

```sql
SELECT
    first_name,
    department_id,
    gpa,
    ROUND(AVG(CAST(gpa AS FLOAT)) OVER (PARTITION BY department_id), 2) AS dept_avg
FROM   students
ORDER BY department_id, gpa DESC;
GO
```

---

### C-03: IGNORE NULLS — SQL Server 2022+

SQL Server 2022 adds `IGNORE NULLS` to `LAG` and `LEAD`, skipping NULL values when searching:

```sql
-- Without IGNORE NULLS: returns NULL if the adjacent row's value is NULL
SELECT
    first_name,
    department_id,
    gpa,
    LAG(gpa) OVER (
        PARTITION BY department_id ORDER BY gpa DESC
    ) AS prev_gpa_with_nulls,
    LAG(gpa) IGNORE NULLS OVER (
        PARTITION BY department_id ORDER BY gpa DESC
    ) AS prev_non_null_gpa
FROM   students
ORDER BY department_id, gpa DESC;
GO
```

**Note:** `IGNORE NULLS` is not available in MySQL 8.0 or PostgreSQL 16.

---

### C-04: NTH_VALUE — SQL Server 2022+

SQL Server 2022 fully supports `NTH_VALUE`. Retrieve the 2nd-highest GPA student name per department:

```sql
SELECT
    first_name,
    department_id,
    gpa,
    NTH_VALUE(first_name, 2) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_highest
FROM   students
ORDER BY department_id, gpa DESC;
GO
```

**Task:** What value appears in `second_highest` for a department with only one student?

---

### C-05: LAST_VALUE fix — SQL Server

Demonstrate and fix the LAST_VALUE bug in SQL Server:

```sql
-- Broken: default frame (RANGE UNBOUNDED PRECEDING AND CURRENT ROW)
SELECT
    first_name,
    department_id,
    gpa,
    LAST_VALUE(first_name) OVER (
        PARTITION BY department_id ORDER BY gpa DESC
    ) AS buggy_result
FROM   students
ORDER BY department_id, gpa DESC;
GO

-- Fixed: explicit full-partition frame
SELECT
    first_name,
    department_id,
    gpa,
    LAST_VALUE(first_name) OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS correct_result
FROM   students
ORDER BY department_id, gpa DESC;
GO
```

---

## Lab Wrap-Up

After completing all parts:

1. List the **three ranking functions** and when you would use each.
2. Write the SQL to find students ranked **exactly 2nd** in their department by GPA, keeping ties.
3. What one change to any LAST_VALUE query prevents the most common LAST_VALUE bug?
4. Which platform does **not** support the named `WINDOW` clause?
5. When is the third argument to `LAG(col, n, default)` necessary?
