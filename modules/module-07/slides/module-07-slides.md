---
marp: true
theme: default
paginate: true
style: |
  :root {
    --color-bg:      #0f1117;
    --color-surface: #1a1d2e;
    --color-accent:  #7c6af7;
    --color-accent2: #3ecf8e;
    --color-warn:    #e96f4a;
    --color-text:    #e2e8f0;
    --color-muted:   #94a3b8;
  }
  section {
    background: var(--color-bg);
    color: var(--color-text);
    font-family: 'Segoe UI', system-ui, sans-serif;
    padding: 48px 56px;
  }
  h1 { color: var(--color-accent); font-size: 2rem; margin-bottom: 0.4em; }
  h2 { color: var(--color-accent2); font-size: 1.5rem; }
  h3 { color: var(--color-accent); font-size: 1.1rem; }
  code, pre {
    background: var(--color-surface);
    color: var(--color-accent2);
    border-radius: 6px;
  }
  pre { padding: 1em; font-size: 0.82rem; }
  table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
  th { background: var(--color-surface); color: var(--color-accent); padding: 8px 12px; }
  td { padding: 7px 12px; border-bottom: 1px solid #2a2d3e; }
  .warn  { color: var(--color-warn); }
  .good  { color: var(--color-accent2); }
  .muted { color: var(--color-muted); font-size: 0.85rem; }
---

# Module 07
## Window Functions

ROW_NUMBER · RANK · DENSE_RANK · LAG · LEAD · Frames · Moving Averages

---

# GROUP BY vs Window Functions

```sql
-- GROUP BY: collapses rows, loses student details
SELECT department_id, AVG(gpa)
FROM   students
GROUP BY department_id;
-- → 1 row per department

-- Window function: keeps all rows, adds dept avg alongside each student
SELECT
    first_name,
    gpa,
    AVG(gpa) OVER (PARTITION BY department_id) AS dept_avg
FROM students;
-- → 1 row per student
```

**Rule: GROUP BY reduces. Window functions annotate.**

---

# Window Function Syntax

```sql
function_name([arguments]) OVER (
    [PARTITION BY col1, col2]   -- divide into groups
    [ORDER BY col3 DESC]         -- order within group
    [frame_clause]               -- which rows to include
)
```

| Clause | Purpose | Required? |
|--------|---------|-----------|
| PARTITION BY | Restart function per group | Optional |
| ORDER BY | Define row order in partition | Required for ranking/value |
| Frame | Sliding window boundary | Optional (has defaults) |

---

# ROW_NUMBER()

Assigns a **unique sequential integer** — no two rows share a number, even with equal values.

```sql
SELECT
    first_name,
    gpa,
    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY gpa DESC
    ) AS dept_row_num
FROM students;
```

| Use case | Reason |
|----------|--------|
| Deduplication | Keep only `row_num = 1` |
| Pagination | `WHERE row_num BETWEEN 11 AND 20` |
| Top N per group | `WHERE rn <= N` |

---

# RANK() and DENSE_RANK()

Both give the **same rank to tied rows**. The difference: gaps.

| Input GPAs | ROW_NUMBER | RANK | DENSE_RANK |
|------------|-----------|------|------------|
| 3.95 | 1 | 1 | 1 |
| 3.90 | 2 | 2 | 2 |
| 3.90 | 3 | 2 | 2 |
| 3.80 | 4 | 4 | 3 |

**RANK:** skips rank 3 (gap after 2 tied rows)  
**DENSE_RANK:** no gap — 3 follows immediately

---

# RANK vs DENSE_RANK — When to Choose

```sql
-- RANK: "there is no 3rd place"
RANK() OVER (ORDER BY gpa DESC)

-- DENSE_RANK: "2nd tier, 3rd tier..."
DENSE_RANK() OVER (ORDER BY gpa DESC)
```

| Choose | When |
|--------|------|
| `RANK()` | Competition ranking where gaps are meaningful |
| `DENSE_RANK()` | Tier-based grouping (percentile bands, pricing tiers) |
| `ROW_NUMBER()` | Need exactly N rows with no ties |

---

# PARTITION BY — Resetting Per Group

```sql
SELECT
    first_name,
    department_id,
    gpa,
    RANK() OVER (
        PARTITION BY department_id   -- reset rank per department
        ORDER BY gpa DESC
    ) AS dept_rank
FROM students;
```

A student ranked 1st in CS and a student ranked 1st in Math both get `dept_rank = 1`.

Without PARTITION BY: only one student school-wide gets rank 1.

---

# Top N per Group

The canonical window function pattern:

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
WHERE  rn <= 2;   -- top 2 per department
```

<span class="good">Can't use ROW_NUMBER in WHERE directly — must wrap in CTE or subquery first.</span>

---

# LAG() and LEAD()

Access values from **adjacent rows** in the window.

```sql
SELECT
    first_name,
    enrolled_at,
    gpa,
    LAG(gpa, 1, 0.0)  OVER (ORDER BY enrolled_at) AS prev_gpa,
    LEAD(gpa, 1, NULL) OVER (ORDER BY enrolled_at) AS next_gpa,
    gpa - LAG(gpa, 1, gpa) OVER (ORDER BY enrolled_at) AS gpa_change
FROM students
ORDER BY enrolled_at;
```

`LAG(col, n, default)` — n rows before; default = NULL if omitted  
`LEAD(col, n, default)` — n rows after; default = NULL if omitted

At partition boundary: returns default (or NULL if not specified).

---

# FIRST_VALUE() and LAST_VALUE()

```sql
SELECT
    first_name, department_id, gpa,
    FIRST_VALUE(first_name) OVER (
        PARTITION BY department_id ORDER BY gpa DESC
    ) AS top_student,
    LAST_VALUE(first_name) OVER (
        PARTITION BY department_id ORDER BY gpa DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING  -- critical
    ) AS bottom_student
FROM students;
```

<span class="warn">LAST_VALUE requires explicit frame — see next slide.</span>

---

# LAST_VALUE Bug — Critical Trap

**Default frame** when ORDER BY is present:
`RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`

For `LAST_VALUE`: "last row in frame" = **current row** → always returns current row's value.

```sql
-- BROKEN — returns current row's own name every time
LAST_VALUE(first_name) OVER (
    PARTITION BY department_id ORDER BY gpa DESC
)

-- FIXED — sees all rows in the partition
LAST_VALUE(first_name) OVER (
    PARTITION BY department_id ORDER BY gpa DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
```

---

# Aggregate Window Functions

Any aggregate + `OVER ()` = window version:

```sql
-- Running count and running average
SELECT
    first_name,
    enrolled_at,
    COUNT(*) OVER (ORDER BY enrolled_at) AS running_count,
    ROUND(AVG(gpa) OVER (ORDER BY enrolled_at), 2) AS running_avg
FROM students;

-- Compare each student to their department average
SELECT
    first_name, gpa,
    ROUND(AVG(gpa) OVER (PARTITION BY department_id), 2) AS dept_avg,
    ROUND(gpa - AVG(gpa) OVER (PARTITION BY department_id), 2) AS above_avg
FROM students;
```

---

# Window Frame Clauses

```
ROWS  BETWEEN <start> AND <end>
RANGE BETWEEN <start> AND <end>
```

| Keyword | Meaning |
|---------|---------|
| UNBOUNDED PRECEDING | First row of partition |
| n PRECEDING | n rows before current |
| CURRENT ROW | Current row |
| n FOLLOWING | n rows after current |
| UNBOUNDED FOLLOWING | Last row of partition |

**Default** (with ORDER BY): `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`

---

# Moving Average with ROWS BETWEEN

```sql
-- 3-row moving average: current + 2 preceding rows
SELECT
    first_name,
    enrolled_at,
    gpa,
    ROUND(AVG(gpa) OVER (
        ORDER BY enrolled_at
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3
FROM students;
```

For the first row: average of 1 row  
For the second row: average of 2 rows  
For all subsequent: average of 3 rows

**ROWS** = exact physical row count — precise, no ties issue.

---

# ROWS vs RANGE

| | ROWS | RANGE |
|-|------|-------|
| Counts | Physical rows | Rows with same ORDER BY value |
| Ties | Splits per row | Groups tied rows together |
| Precision | Exact | May include extra rows |
| Recommended for | Moving averages | Running totals with date ties |

```sql
-- ROWS: exactly 3 physical rows
AVG(gpa) OVER (ORDER BY enrolled_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)

-- RANGE: all rows with same enrolled_at as current row + preceding
AVG(gpa) OVER (ORDER BY enrolled_at RANGE BETWEEN 2 PRECEDING AND CURRENT ROW)
```

---

# NTILE()

Divides rows into N roughly equal buckets:

```sql
-- GPA quartiles (4 equal groups)
SELECT
    first_name,
    gpa,
    NTILE(4) OVER (ORDER BY gpa DESC) AS quartile
FROM students
ORDER BY quartile, gpa DESC;
```

Bucket 1 = top 25% by GPA  
Bucket 4 = bottom 25%

If rows don't divide evenly, earlier buckets receive the extra row.

---

# PERCENT_RANK() and CUME_DIST()

```sql
SELECT
    first_name,
    gpa,
    ROUND(PERCENT_RANK() OVER (ORDER BY gpa), 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY gpa), 4) AS cume_dist
FROM students;
```

`PERCENT_RANK` = (rank − 1) / (total rows − 1) → range [0, 1]  
`CUME_DIST` = rows with value ≤ current / total rows → range (0, 1]

First row `pct_rank = 0.0`; last row `pct_rank = 1.0`

---

# Named WINDOW Clause

Avoid repeating the same OVER specification:

```sql
-- MySQL 8.0 / PostgreSQL 16 only
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

<span class="warn">SQL Server 2022 does NOT support WINDOW clause — repeat OVER for each function.</span>

---

# Platform Summary

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| ROW_NUMBER / RANK / DENSE_RANK | ✅ | ✅ | ✅ |
| LAG / LEAD | ✅ | ✅ | ✅ |
| FIRST_VALUE / LAST_VALUE | ✅ | ✅ | ✅ |
| NTH_VALUE | ✅ | ✅ | ✅ 2022+ |
| NTILE / PERCENT_RANK / CUME_DIST | ✅ | ✅ | ✅ |
| Named WINDOW clause | ✅ | ✅ | ❌ |
| IGNORE NULLS (LAG/LEAD) | ❌ | ❌ | ✅ 2022+ |
| ROUND float input | ✅ | ❌ need ::NUMERIC | ✅ |

---

# Common Mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| `WHERE rank_col = 1` directly | Syntax/column error | Wrap in CTE or subquery |
| LAST_VALUE without explicit frame | Always equals current row | Add `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` |
| `ROWS BETWEEN 3 PRECEDING` for 3-row average | Gets 4 rows, not 3 | Use `2 PRECEDING` for 3-row window |
| PostgreSQL `ROUND(AVG(...), 2)` | Type error | Cast: `ROUND(AVG(...)::NUMERIC, 2)` |
| SQL Server `WINDOW w AS (...)` | Syntax error | Repeat OVER clause for each function |
| Filtering `WHERE rnk = 1` | Column not found | Wrap the ranked query in a CTE first |

---

# Module 07 — Key Takeaways

✅ **GROUP BY reduces; window functions annotate** (keep all rows)  
✅ **ROW_NUMBER** = always unique; **RANK** = gaps; **DENSE_RANK** = no gaps  
✅ **PARTITION BY** resets the function per group  
✅ **Top N per group** = CTE with `ROW_NUMBER()` + `WHERE rn <= N`  
✅ **LAST_VALUE** always needs explicit `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`  
✅ **Window functions in WHERE** = impossible; wrap in CTE  
✅ **Named WINDOW clause** = MySQL/PostgreSQL only; SQL Server repeats OVER  

---

# Module 08 Preview
## Data Modification

- `INSERT` — single row, multi-row, INSERT … SELECT
- `UPDATE` — single table, multi-table, with subquery
- `DELETE` and `TRUNCATE` — differences and risks
- `MERGE` / `UPSERT` — INSERT + UPDATE + DELETE in one statement
- Transactions — `BEGIN` / `COMMIT` / `ROLLBACK`
- Isolation levels — READ UNCOMMITTED through SERIALIZABLE

<span class="muted">Window functions (Module 07) underpin many real-world reporting queries — the data you'll modify in Module 08 feeds the aggregations and rankings you've mastered here.</span>
