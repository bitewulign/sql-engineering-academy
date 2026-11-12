# Module 07 — Solutions
## Window Functions

> **Security note:** This file is for instructor use. Do not expose to learners before they attempt the exercises.

---

## Beginner Solutions

### Exercise 01 — School-wide ROW_NUMBER by GPA

```sql
-- MySQL 8.0 / PostgreSQL 16 / SQL Server 2022
SELECT
    first_name,
    last_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS school_rank
FROM   students
ORDER BY school_rank;
```

**Notes:** `ROW_NUMBER()` assigns a unique integer even when two students share the same GPA. The order of tied rows is non-deterministic unless a tiebreaker column is added.

---

### Exercise 02 — RANK by GPA per department

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

**Notes:** `RANK()` assigns the same rank to tied GPAs and skips the next rank. Two students tied at rank 2 produce no rank 3.

---

### Exercise 03 — Department average with window function

```sql
-- MySQL 8.0 / SQL Server 2022
SELECT
    first_name,
    department_id,
    gpa,
    ROUND(AVG(gpa) OVER (PARTITION BY department_id), 2) AS dept_avg_gpa
FROM   students
ORDER BY department_id, gpa DESC;

-- PostgreSQL 16
SELECT
    first_name,
    department_id,
    gpa,
    ROUND(AVG(gpa) OVER (PARTITION BY department_id)::NUMERIC, 2) AS dept_avg_gpa
FROM   students
ORDER BY department_id, gpa DESC;
```

---

### Exercise 04 — Department max GPA and gap

```sql
-- MySQL 8.0 / SQL Server 2022
SELECT
    first_name,
    department_id,
    gpa,
    MAX(gpa) OVER (PARTITION BY department_id) AS dept_max_gpa,
    ROUND(MAX(gpa) OVER (PARTITION BY department_id) - gpa, 2) AS gpa_gap
FROM   students
ORDER BY department_id, gpa DESC;
```

**Notes:** `gpa_gap = 0` for the top student in each department.

---

### Exercise 05 — Running count by enrollment date

```sql
SELECT
    first_name,
    enrolled_at,
    COUNT(*) OVER (ORDER BY enrolled_at) AS running_count
FROM   students
ORDER BY enrolled_at;
```

**Notes:** Default frame (`RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`) is correct here — it counts all students enrolled on or before the current date, including ties.

---

### Exercise 06 — LAG to previous enrolled student

```sql
SELECT
    first_name,
    enrolled_at,
    gpa,
    LAG(gpa) OVER (ORDER BY enrolled_at) AS prev_gpa
FROM   students
ORDER BY enrolled_at;
```

**Notes:** The first row returns `NULL` because there is no previous row. No default argument is provided since NULL is acceptable.

---

### Exercise 07 — NTILE quartiles

```sql
SELECT
    first_name,
    gpa,
    NTILE(4) OVER (ORDER BY gpa DESC) AS quartile
FROM   students
ORDER BY quartile, gpa DESC;
```

**Notes:** Quartile 1 = top 25% by GPA. Rows are distributed as evenly as possible; if the row count is not divisible by 4, earlier buckets receive the extra row(s).

---

### Exercise 08 — FIRST_VALUE per department

```sql
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
```

---

### Exercise 09 — All three ranking functions side by side

```sql
SELECT
    first_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa DESC) AS row_num,
    RANK()       OVER (ORDER BY gpa DESC) AS rnk,
    DENSE_RANK() OVER (ORDER BY gpa DESC) AS d_rnk
FROM   students
ORDER BY gpa DESC;
```

---

### Exercise 10 — Running GPA sum

```sql
SELECT
    first_name,
    enrolled_at,
    gpa,
    SUM(gpa) OVER (ORDER BY enrolled_at) AS running_gpa_sum
FROM   students
ORDER BY enrolled_at;
```

---

## Intermediate Solutions

### Exercise 11 — Top 2 students per department

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

**Notes:** `ROW_NUMBER()` (not `RANK()`) is used here so that exactly 2 rows per department are returned even when there are ties. If you need all tied students at position 2, use `RANK()` or `DENSE_RANK()` instead.

---

### Exercise 12 — 3-row moving average

```sql
-- MySQL 8.0 / SQL Server 2022
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

-- PostgreSQL 16
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
```

**Notes:** `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` = exactly 3 rows (not `3 PRECEDING`). For the first two rows, the average is computed over the available rows only.

---

### Exercise 13 — PERCENT_RANK and CUME_DIST

```sql
-- MySQL 8.0 / SQL Server 2022
SELECT
    first_name,
    gpa,
    ROUND(PERCENT_RANK() OVER (ORDER BY gpa), 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY gpa), 4) AS cume_dist
FROM   students
ORDER BY gpa;

-- PostgreSQL 16
SELECT
    first_name,
    gpa,
    ROUND(PERCENT_RANK() OVER (ORDER BY gpa)::NUMERIC, 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY gpa)::NUMERIC, 4) AS cume_dist
FROM   students
ORDER BY gpa;
```

**Notes:** The lowest-GPA student gets `pct_rank = 0.0`; the highest gets `pct_rank = 1.0`. `CUME_DIST` is always > 0.

---

### Exercise 14 — 2nd and 3rd place per department

```sql
WITH dept_ranked AS (
    SELECT
        first_name,
        department_id,
        gpa,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY gpa DESC
        ) AS dept_rank
    FROM students
)
SELECT first_name, department_id, gpa, dept_rank
FROM   dept_ranked
WHERE  dept_rank IN (2, 3)
ORDER BY department_id, dept_rank;
```

**Notes:** `DENSE_RANK()` ensures consistent tier numbering without gaps. Using `RANK()` would produce the same rank values, but if two students tie at rank 2, there would be no rank 3.

---

### Exercise 15 — Department min and max GPA

```sql
SELECT
    first_name,
    department_id,
    gpa,
    MIN(gpa) OVER (PARTITION BY department_id) AS dept_min_gpa,
    MAX(gpa) OVER (PARTITION BY department_id) AS dept_max_gpa
FROM   students
ORDER BY department_id, gpa DESC;
```

---

## Challenge Solutions

### Exercise 16 — GPA change from previous enrollment

```sql
-- MySQL 8.0 / SQL Server 2022
SELECT
    first_name,
    enrolled_at,
    gpa,
    LAG(gpa, 1, 0.0) OVER (ORDER BY enrolled_at) AS prev_gpa,
    ROUND(gpa - LAG(gpa, 1, gpa) OVER (ORDER BY enrolled_at), 2) AS gpa_change
FROM   students
ORDER BY enrolled_at;
```

**Notes:**
- `LAG(gpa, 1, 0.0)` returns `0.0` for the first row (no previous), so `prev_gpa` shows `0.0` there.
- `LAG(gpa, 1, gpa)` defaults to the current GPA when there is no previous row, making `gpa_change = 0` for the first row.

---

### Exercise 17 — Students above their department average

```sql
-- MySQL 8.0 / SQL Server 2022
WITH student_vs_avg AS (
    SELECT
        first_name,
        department_id,
        gpa,
        ROUND(AVG(gpa) OVER (PARTITION BY department_id), 2) AS dept_avg
    FROM students
)
SELECT
    first_name,
    department_id,
    gpa,
    dept_avg,
    ROUND(gpa - dept_avg, 2) AS above_by
FROM   student_vs_avg
WHERE  gpa > dept_avg
ORDER BY department_id, above_by DESC;

-- PostgreSQL 16 (::NUMERIC cast in CTE)
WITH student_vs_avg AS (
    SELECT
        first_name,
        department_id,
        gpa,
        ROUND(AVG(gpa) OVER (PARTITION BY department_id)::NUMERIC, 2) AS dept_avg
    FROM students
)
SELECT
    first_name,
    department_id,
    gpa,
    dept_avg,
    ROUND((gpa - dept_avg)::NUMERIC, 2) AS above_by
FROM   student_vs_avg
WHERE  gpa > dept_avg
ORDER BY department_id, above_by DESC;
```

**Key insight:** The window function runs in the CTE's SELECT phase; the outer WHERE can then filter on the computed `dept_avg` column. This avoids both a correlated subquery and a GROUP BY.

---

### Exercise 18 — Department summary (top/bottom student + spread)

```sql
-- MySQL 8.0 / SQL Server 2022
WITH dept_window AS (
    SELECT
        s.student_id,
        d.department_name,
        s.gpa,
        FIRST_VALUE(s.first_name) OVER (
            PARTITION BY s.department_id
            ORDER BY s.gpa DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS top_student,
        LAST_VALUE(s.first_name) OVER (
            PARTITION BY s.department_id
            ORDER BY s.gpa DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS bottom_student,
        MAX(s.gpa) OVER (PARTITION BY s.department_id) AS dept_max,
        MIN(s.gpa) OVER (PARTITION BY s.department_id) AS dept_min
    FROM   students s
    JOIN   departments d ON d.department_id = s.department_id
)
SELECT DISTINCT
    department_name,
    top_student,
    bottom_student,
    ROUND(dept_max - dept_min, 2) AS gpa_spread
FROM   dept_window
ORDER BY department_name;
```

**Notes:**
- `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` is **required** for `LAST_VALUE` to see all rows in the partition, not just up to the current row.
- `SELECT DISTINCT` collapses the per-student rows into one per department.
- Alternatively, the outer SELECT could `GROUP BY department_name` with `MAX(top_student)`, `MAX(bottom_student)`.

---

## Interview Answer Guide

### IQ-01 — RANK vs DENSE_RANK

Both assign the same rank to tied rows. The difference: `RANK()` skips subsequent ranks after a tie (1, 2, 2, **4**); `DENSE_RANK()` does not (1, 2, 2, **3**).

**Choose RANK** when gaps are meaningful — e.g., competition results where "there is no bronze because two athletes tied for silver."

**Choose DENSE_RANK** when you need consecutive tier numbers — e.g., assigning customers to pricing tiers, or top-N filtering where you want `WHERE d_rnk <= 3` to include all students in the 3rd tier regardless of ties.

---

### IQ-02 — PARTITION BY vs GROUP BY

`PARTITION BY` divides rows into independent groups for the window function to operate on, **without collapsing rows**. Each student row is still present; the window function resets per partition.

`GROUP BY` **collapses** rows — you lose access to individual student data. The output has one row per group, not one row per original row.

Rule of thumb: "GROUP BY reduces; window functions annotate."

---

### IQ-03 — Filtering window function results

Window functions execute during the SELECT phase of SQL logical processing, **after** FROM, JOIN, WHERE, GROUP BY, and HAVING. Because WHERE runs before SELECT, it cannot see window function results.

**Workaround:** Wrap in a CTE or subquery:

```sql
WITH ranked AS (
    SELECT first_name, gpa,
           RANK() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rnk
    FROM students
)
SELECT first_name, gpa FROM ranked WHERE rnk = 1;
```

---

### IQ-04 — ROWS BETWEEN and ROWS vs RANGE

`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` means: include every row from the start of the partition up to and including the current physical row.

**ROWS** counts physical rows — if 5 rows precede the current row, exactly 5 are included regardless of whether any share the same ORDER BY value. Precise.

**RANGE** counts rows with the same ORDER BY value as the current row — if 3 rows have the same date as the current row, all 3 are included together. Can include more rows than expected with ties.

---

### IQ-05 — The LAST_VALUE bug

Default frame with `ORDER BY`: `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`.

For `LAST_VALUE`, "the last row in the frame" = the current row. So `LAST_VALUE` always returns the current row's value — it never shows the last row of the partition.

**Fix:** Always specify the full partition frame explicitly:

```sql
LAST_VALUE(first_name) OVER (
    PARTITION BY department_id
    ORDER BY gpa DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
```

---

### IQ-06 — Top N per group

**Window function approach (recommended):**

```sql
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC) AS rn
    FROM students
)
SELECT * FROM ranked WHERE rn <= 3;
```

**Alternative — correlated subquery (older style):**

```sql
SELECT * FROM students s
WHERE (
    SELECT COUNT(*) FROM students s2
    WHERE s2.department_id = s.department_id AND s2.gpa > s.gpa
) < 3;
```

Window functions are cleaner, more readable, and usually better optimized on modern engines. The correlated subquery handles ties naturally (all tied students pass); `ROW_NUMBER()` imposes an arbitrary tiebreaker — use `RANK()` or `DENSE_RANK()` to include all tied students.

---

### IQ-07 — LAG default argument

`LAG(col, 1, 0)` returns `0` for the first row because there is no row before it. Without the default argument, it would return `NULL`. The third argument provides a fallback value that replaces `NULL` at partition boundaries.

---

### IQ-08 — Ranking comparison for [90, 85, 85, 80]

| Row | GPA | ROW_NUMBER | RANK | DENSE_RANK |
|-----|-----|------------|------|------------|
| 1 | 90 | 1 | 1 | 1 |
| 2 | 85 | 2 | 2 | 2 |
| 3 | 85 | 3 | 2 | 2 |
| 4 | 80 | 4 | 4 | 3 |

- `ROW_NUMBER`: always unique; row 2 and row 3 get different numbers
- `RANK`: ties share rank 2; rank 3 is skipped (gap)
- `DENSE_RANK`: ties share rank 2; rank 3 follows with no gap
