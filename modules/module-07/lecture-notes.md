# Module 07 — Lecture Notes
## Window Functions

---

## 1. What Is a Window Function?

A **window function** computes a value for each row based on a set of related rows — called the **window** — without collapsing them into a single output row the way GROUP BY does.

```sql
-- GROUP BY: collapses rows, loses individual student data
SELECT department_id, AVG(gpa) FROM students GROUP BY department_id;
-- Returns: 1 row per department

-- Window function: keeps all rows, adds the average alongside each student
SELECT
    first_name,
    gpa,
    AVG(gpa) OVER (PARTITION BY department_id) AS dept_avg
FROM students;
-- Returns: 1 row per student + dept_avg column on every row
```

The fundamental difference: **GROUP BY reduces; window functions annotate**.

---

## 2. Window Function Syntax

```sql
function_name([arguments]) OVER (
    [PARTITION BY col1, col2, ...]   -- divide rows into groups
    [ORDER BY col3 [ASC|DESC], ...]  -- define row order within partition
    [frame_clause]                   -- define which rows are "in the window"
)
```

**PARTITION BY** — optional. Divides rows into independent partitions. The function resets for each partition. Without it, the entire result set is one partition.

**ORDER BY** — required for ranking and value functions; optional for aggregate window functions (but determines the running total direction).

**Frame clause** — optional. Specifies which rows relative to the current row are included. Defaults vary by function and platform (see Section 9).

---

## 3. ROW_NUMBER()

Assigns a **unique sequential integer** to each row within its partition, starting at 1. Ties receive different numbers (arbitrary tiebreaker).

```sql
SELECT
    first_name,
    department_id,
    gpa,
    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS row_num
FROM students;
```

Result: Within each department, the student with the highest GPA gets row_num = 1. If two students have equal GPA, one gets 1 and the other gets 2 (order of equals is not guaranteed unless a secondary ORDER BY column makes rows unique).

**Use cases:** Deduplication (keep only row_num = 1), pagination (WHERE row_num BETWEEN 11 AND 20), assigning unique IDs.

---

## 4. RANK()

Assigns the **same rank to tied rows**, then **skips** the next rank(s) equal to the number of tied rows.

```sql
SELECT
    first_name,
    gpa,
    RANK() OVER (ORDER BY gpa DESC) AS rnk
FROM students;
```

Example output:

| first_name | gpa | rnk |
|------------|-----|-----|
| Amara | 3.95 | 1 |
| Priya | 3.90 | 2 |
| Carlos | 3.90 | 2 |
| Sofia | 3.80 | 4 ← skipped 3 |

**Use cases:** Leaderboards, competition rankings where gaps are meaningful ("there is no 3rd place because two people tied for 2nd").

---

## 5. DENSE_RANK()

Assigns the **same rank to tied rows** but does **not skip** the next rank.

```sql
SELECT
    first_name,
    gpa,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS d_rnk
FROM students;
```

Example output:

| first_name | gpa | d_rnk |
|------------|-----|-------|
| Amara | 3.95 | 1 |
| Priya | 3.90 | 2 |
| Carlos | 3.90 | 2 |
| Sofia | 3.80 | 3 ← no gap |

**Use cases:** Percentile bands, tier groupings where consecutive numbers are needed.

---

## 6. ROW_NUMBER vs RANK vs DENSE_RANK

For input: GPA values 3.95, 3.90, 3.90, 3.80

| Function | Output |
|----------|--------|
| `ROW_NUMBER()` | 1, 2, 3, 4 |
| `RANK()` | 1, 2, 2, 4 |
| `DENSE_RANK()` | 1, 2, 2, 3 |

---

## 7. PARTITION BY — Resetting Per Group

`PARTITION BY` causes the function to restart independently for each group.

```sql
-- Rank students within their own department (not school-wide)
SELECT
    first_name,
    department_id,
    gpa,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS dept_rank
FROM students;
```

A student ranked 1st in CS and a student ranked 1st in Math can both have `dept_rank = 1` simultaneously. Without PARTITION BY, there would be only one rank-1 student school-wide.

---

## 8. LAG() and LEAD()

`LAG(col, n, default)` returns the value of `col` from **n rows before** the current row.  
`LEAD(col, n, default)` returns the value from **n rows after** the current row.

```sql
-- Month-over-month GPA comparison (simulated with enrollment dates)
SELECT
    first_name,
    enrolled_at,
    gpa,
    LAG(gpa, 1, 0)  OVER (PARTITION BY student_id ORDER BY enrolled_at) AS prev_gpa,
    LEAD(gpa, 1, 0) OVER (PARTITION BY student_id ORDER BY enrolled_at) AS next_gpa
FROM student_progress;

-- Practical example: compare each student to the student enrolled just before them
SELECT
    first_name,
    gpa,
    LAG(gpa) OVER (ORDER BY enrolled_at) AS prev_enrolled_gpa,
    gpa - LAG(gpa) OVER (ORDER BY enrolled_at) AS gpa_delta
FROM students
ORDER BY enrolled_at;
```

**Default argument:** When there is no previous/next row (at the boundary), `LAG`/`LEAD` return NULL by default. The optional third argument provides a substitute value instead of NULL.

---

## 9. FIRST_VALUE() and LAST_VALUE()

`FIRST_VALUE(col)` returns the value of `col` from the **first row** in the window frame.  
`LAST_VALUE(col)` returns the value from the **last row** in the window frame.

```sql
-- First and last enrolled student in each department
SELECT
    first_name,
    department_id,
    enrolled_at,
    FIRST_VALUE(first_name) OVER (
        PARTITION BY department_id
        ORDER BY enrolled_at
    ) AS first_enrolled,
    LAST_VALUE(first_name) OVER (
        PARTITION BY department_id
        ORDER BY enrolled_at
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_enrolled
FROM students;
```

**LAST_VALUE frame warning:** By default, the window frame for ORDER BY functions is `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. This means `LAST_VALUE` without an explicit frame sees only rows up to the current row — which always makes it equal to the current row's value. Always use `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` with `LAST_VALUE`.

---

## 10. Aggregate Window Functions

Any standard aggregate can become a window function by adding `OVER`:

```sql
-- Running total of students enrolled over time
SELECT
    first_name,
    enrolled_at,
    COUNT(*) OVER (ORDER BY enrolled_at) AS running_count,
    SUM(gpa)  OVER (ORDER BY enrolled_at) AS running_gpa_sum,
    AVG(gpa)  OVER (ORDER BY enrolled_at) AS running_avg_gpa
FROM students
ORDER BY enrolled_at;

-- Compare each student to their department's average (without GROUP BY)
SELECT
    first_name,
    gpa,
    ROUND(AVG(gpa) OVER (PARTITION BY department_id), 2) AS dept_avg,
    gpa - ROUND(AVG(gpa) OVER (PARTITION BY department_id), 2) AS above_avg
FROM students;
```

---

## 11. Window Frame Clauses

The **frame** defines which rows relative to the current row are included in the window.

```
ROWS  BETWEEN <start> AND <end>
RANGE BETWEEN <start> AND <end>
```

**Boundary keywords:**

| Keyword | Meaning |
|---------|---------|
| `UNBOUNDED PRECEDING` | All rows before the first row of the partition |
| `n PRECEDING` | n rows before the current row |
| `CURRENT ROW` | The current row only |
| `n FOLLOWING` | n rows after the current row |
| `UNBOUNDED FOLLOWING` | All rows through the last row of the partition |

**Default frame** (when ORDER BY is specified): `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`

```sql
-- 3-row moving average (current row + 2 preceding)
SELECT
    enrolled_at,
    gpa,
    ROUND(AVG(gpa) OVER (
        ORDER BY enrolled_at
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3
FROM students
ORDER BY enrolled_at;

-- Full partition sum on every row
SELECT
    department_id,
    gpa,
    SUM(gpa) OVER (
        PARTITION BY department_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_total_gpa
FROM students;
```

**ROWS vs RANGE:**
- `ROWS` counts physical rows — precise, recommended for most use cases.
- `RANGE` counts rows with the same ORDER BY value — can include more rows than expected when there are ties.

---

## 12. NTILE()

`NTILE(n)` divides rows in the partition into `n` roughly equal buckets and assigns each row its bucket number.

```sql
-- Divide students into 4 GPA quartiles (school-wide)
SELECT
    first_name,
    gpa,
    NTILE(4) OVER (ORDER BY gpa DESC) AS quartile
FROM students;
```

Quartile 1 = top 25% by GPA; quartile 4 = bottom 25%.

---

## 13. PERCENT_RANK() and CUME_DIST()

`PERCENT_RANK()` = (rank - 1) / (total rows - 1). Range: 0.0 to 1.0.  
`CUME_DIST()` = (number of rows with value ≤ current) / (total rows). Range: 0 to 1.

```sql
SELECT
    first_name,
    gpa,
    ROUND(PERCENT_RANK() OVER (ORDER BY gpa), 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY gpa), 4) AS cume_dist
FROM students
ORDER BY gpa;
```

---

## 14. Named Windows (WINDOW clause — MySQL and PostgreSQL)

When the same window specification is repeated, name it once:

```sql
-- MySQL / PostgreSQL only (SQL Server does not support WINDOW clause)
SELECT
    first_name,
    gpa,
    ROW_NUMBER()  OVER w AS rn,
    RANK()        OVER w AS rnk,
    DENSE_RANK()  OVER w AS d_rnk
FROM students
WINDOW w AS (PARTITION BY department_id ORDER BY gpa DESC);
```

SQL Server requires repeating the OVER clause.

---

## 15. Window Functions vs GROUP BY — Summary

| Dimension | GROUP BY | Window function |
|-----------|----------|----------------|
| Output rows | One per group | Same as input |
| Access to individual rows | No | Yes |
| Can combine with GROUP BY | N/A | Yes (window runs after GROUP BY) |
| Requires OVER clause | No | Yes |
| Filter aggregated result | HAVING | Subquery / CTE wrapping window |

**Filtering window function results:** You cannot use a window function in a WHERE or HAVING clause directly (they execute in the SELECT phase). Wrap in a subquery or CTE:

```sql
-- Get only the top-ranked student per department
WITH ranked AS (
    SELECT
        first_name, department_id, gpa,
        RANK() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rnk
    FROM students
)
SELECT first_name, department_id, gpa
FROM   ranked
WHERE  rnk = 1;
```
