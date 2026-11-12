---
marp: true
theme: default
paginate: true
style: |
  :root {
    --color-bg: #0f1117;
    --color-surface: #1a1d2e;
    --color-accent: #7c6af7;
    --color-accent2: #3ecf8e;
    --color-warn: #e96f4a;
    --color-text: #e2e8f0;
    --color-muted: #8892a4;
    --color-border: #2d3148;
  }
  section {
    background: var(--color-bg);
    color: var(--color-text);
    font-family: 'Inter', 'Segoe UI', sans-serif;
    padding: 48px 60px;
  }
  h1 { color: var(--color-accent); font-size: 2.0em; margin-bottom: 0.2em; }
  h2 { color: var(--color-accent2); font-size: 1.4em; border-bottom: 2px solid var(--color-border); padding-bottom: 0.3em; }
  h3 { color: var(--color-accent); font-size: 1.1em; }
  code { background: var(--color-surface); color: var(--color-accent2); padding: 2px 6px; border-radius: 4px; font-size: 0.88em; }
  pre { background: var(--color-surface); border-left: 4px solid var(--color-accent); padding: 20px; border-radius: 8px; overflow: auto; }
  pre code { background: transparent; padding: 0; font-size: 0.82em; color: #cdd6f4; }
  table { width: 100%; border-collapse: collapse; font-size: 0.85em; }
  th { background: var(--color-surface); color: var(--color-accent); padding: 10px 14px; text-align: left; }
  td { padding: 9px 14px; border-bottom: 1px solid var(--color-border); }
  tr:nth-child(even) td { background: rgba(255,255,255,0.03); }
  strong { color: var(--color-accent2); }
  em { color: var(--color-warn); }
  .warn { color: var(--color-warn); font-weight: bold; }
  .ok { color: var(--color-accent2); font-weight: bold; }
  ul { line-height: 1.8; }
  li { margin-bottom: 0.2em; }
---

<!-- Slide 01: Title -->
# Module 08
## Data Modification

**INSERT · UPDATE · DELETE · UPSERT · Transactions**

MySQL 8.0 · PostgreSQL 16 · SQL Server 2022

---

<!-- Slide 02: DML vs DDL -->
## DML vs DDL

| Category | Statements | Changes |
|----------|-----------|---------|
| **DML** (Data Manipulation) | INSERT, UPDATE, DELETE, MERGE | Rows in tables |
| **DDL** (Data Definition) | CREATE, ALTER, DROP, TRUNCATE | Table structure |
| **TCL** (Transaction Control) | BEGIN, COMMIT, ROLLBACK | Transaction scope |

> This module focuses on **DML** and **TCL** — the statements you run every day.

---

<!-- Slide 03: INSERT — Single Row -->
## INSERT — Single Row

```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Lena', 'Fischer', 3.72, 2, CURDATE(), 1);
```

**Rules:**
- Always list column names explicitly — schema changes break position-based inserts
- Column count must match VALUES count exactly
- Run a `SELECT` with the same `WHERE` before inserting in production

**Platform note:** `CURDATE()` → MySQL · `CURRENT_DATE` → PostgreSQL · `GETDATE()` → SQL Server

---

<!-- Slide 04: INSERT — Multi-Row and INSERT…SELECT -->
## INSERT — Multiple Rows & INSERT…SELECT

**Multi-row (all platforms):**
```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES
    ('Omar',  'Hassan',    3.65, 1, '2024-09-01', 1),
    ('Mia',   'Johansson', 3.88, 3, '2023-01-15', 1),
    ('Raj',   'Patel',     3.50, 2, '2024-01-15', 1);
```

**INSERT…SELECT (populate from another table):**
```sql
INSERT INTO students_staging (student_id, first_name, last_name, gpa)
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  gpa >= 3.80;
```

> INSERT…SELECT copies any result set — including aggregates, joins, and CTEs.

---

<!-- Slide 05: UPDATE Safety Rule -->
## UPDATE — The Safety Rule

<span class="warn">⚠️ Never write UPDATE or DELETE without first running the matching SELECT.</span>

```sql
-- Step 1: Who will be changed?
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  first_name = 'Lena' AND last_name = 'Fischer';

-- Step 2: Apply the change
UPDATE students
SET    gpa = 3.85
WHERE  first_name = 'Lena' AND last_name = 'Fischer';

-- Step 3: Verify
SELECT student_id, gpa FROM students WHERE first_name = 'Lena';
```

**In production:** always use `WHERE student_id = <id>`, not name-based conditions.

---

<!-- Slide 06: UPDATE with Expression -->
## UPDATE — Expressions & Capping

**Cap GPA at 4.00 when applying a bump:**

```sql
-- MySQL / PostgreSQL
UPDATE students
SET    gpa = LEAST(gpa + 0.10, 4.00)
WHERE  department_id = 1;

-- SQL Server (no LEAST function)
UPDATE students
SET    gpa = CASE WHEN gpa + 0.10 > 4.00 THEN 4.00 ELSE gpa + 0.10 END
WHERE  department_id = 1;
```

**UPDATE with JOIN:**

| Platform | Syntax |
|----------|--------|
| MySQL 8.0 | `UPDATE t1 JOIN t2 ON … SET t1.col = …` |
| PostgreSQL 16 | `UPDATE t1 SET … FROM t2 WHERE t1.id = t2.id` |
| SQL Server 2022 | `UPDATE t1 SET … FROM t1 JOIN t2 ON …` |

---

<!-- Slide 07: DELETE vs TRUNCATE -->
## DELETE vs TRUNCATE

| Feature | DELETE | TRUNCATE |
|---------|--------|----------|
| WHERE clause | ✓ Yes | ✗ No |
| Row-by-row logging | Yes (slower) | No — pages (faster) |
| Triggers fire | Yes | No |
| AUTO_INCREMENT reset | No | Yes (MySQL) |
| Rollback safe | Always | MySQL: no · PG/SS: yes |
| FK constraint check | Yes | Yes |

```sql
-- DELETE — targeted, logged, rollback-safe
DELETE FROM students WHERE first_name = 'Omar';

-- TRUNCATE — fast, unfiltered, resets AUTO_INCREMENT
TRUNCATE TABLE students_staging;
```

> <span class="warn">Use TRUNCATE only when you want ALL rows gone and don't need row-level recovery.</span>

---

<!-- Slide 08: UPSERT — MySQL -->
## UPSERT — MySQL 8.0

**Problem:** You want to insert a row, but update it if the key already exists.

```sql
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (201, 1, NOW())
ON DUPLICATE KEY UPDATE
    enrollment_count = enrollment_count + 1,
    last_updated     = NOW();
```

- Triggers when a **PRIMARY KEY** or **UNIQUE** constraint would be violated
- The `UPDATE` clause can reference current column values via `enrollment_count` directly
- `VALUES(col)` syntax deprecated in MySQL 8.0.19 — use the column name directly

> Run once → INSERT. Run again → UPDATE. Same statement, one round trip.

---

<!-- Slide 09: UPSERT — PostgreSQL -->
## UPSERT — PostgreSQL 16

```sql
-- Update on conflict
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (201, 1, NOW())
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = course_stats.enrollment_count + 1,
        last_updated     = NOW();
```

```sql
-- Silently ignore on conflict
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (201, 999, NOW())
ON CONFLICT (course_id) DO NOTHING;
```

**Key concept:** `EXCLUDED` refers to the row that was attempted:

```sql
SET enrollment_count = EXCLUDED.enrollment_count + course_stats.enrollment_count
```

---

<!-- Slide 10: UPSERT — SQL Server -->
## UPSERT — SQL Server 2022 (MERGE)

```sql
MERGE INTO course_stats AS target
USING (VALUES (201, 1)) AS source(course_id, increment)
    ON target.course_id = source.course_id
WHEN MATCHED THEN
    UPDATE SET
        enrollment_count = target.enrollment_count + source.increment,
        last_updated     = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (course_id, enrollment_count, last_updated)
    VALUES (source.course_id, source.increment, GETDATE())
OUTPUT $action AS merge_action, INSERTED.course_id, INSERTED.enrollment_count;
GO
```

> `$action` returns `'INSERT'` or `'UPDATE'` — invaluable for auditing batch MERGE operations.

---

<!-- Slide 11: RETURNING and OUTPUT -->
## Getting Data Back: RETURNING / OUTPUT

**PostgreSQL — RETURNING:**
```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Lena', 'Fischer', 3.72, 2, CURRENT_DATE, TRUE)
RETURNING student_id, first_name;   -- auto-generated PK, no second query needed

UPDATE students SET gpa = 3.90 WHERE department_id = 1
RETURNING student_id, gpa AS new_gpa;

DELETE FROM students_staging WHERE gpa < 3.80
RETURNING student_id, first_name;
```

**SQL Server — OUTPUT:**
```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
OUTPUT INSERTED.student_id, INSERTED.first_name
VALUES (N'Lena', N'Fischer', 3.72, 2, GETDATE(), 1);

UPDATE students SET gpa = 3.90 WHERE department_id = 1
OUTPUT DELETED.gpa AS old_gpa, INSERTED.gpa AS new_gpa;
```

---

<!-- Slide 12: Transactions — ACID -->
## Transactions & ACID

A **transaction** is a unit of work that is treated as a single operation.

| Property | Meaning | Example |
|----------|---------|---------|
| **Atomicity** | All or nothing | Bank transfer: debit + credit, or neither |
| **Consistency** | Valid state to valid state | Total balance unchanged after transfer |
| **Isolation** | Transactions don't see each other's in-flight work | No dirty reads |
| **Durability** | Committed data survives crashes | Write-ahead log ensures persistence |

> Without ACID, two concurrent bank transfers could both see the same balance and overdraw an account.

---

<!-- Slide 13: Transaction Control Syntax -->
## Transaction Control by Platform

| Statement | MySQL | PostgreSQL | SQL Server |
|-----------|-------|-----------|------------|
| Start | `START TRANSACTION` | `BEGIN` | `BEGIN TRANSACTION` |
| Commit | `COMMIT` | `COMMIT` | `COMMIT TRANSACTION` |
| Rollback | `ROLLBACK` | `ROLLBACK` | `ROLLBACK TRANSACTION` |
| Savepoint | `SAVEPOINT name` | `SAVEPOINT name` | `SAVE TRANSACTION name` |
| Rollback to SP | `ROLLBACK TO SAVEPOINT name` | `ROLLBACK TO SAVEPOINT name` | `ROLLBACK TRANSACTION name` |

```sql
START TRANSACTION;         -- MySQL
INSERT INTO students …;
UPDATE course_stats …;
COMMIT;                    -- both changes visible, durably written
```

---

<!-- Slide 14: SAVEPOINTs -->
## SAVEPOINTs — Partial Rollback

```sql
START TRANSACTION;

INSERT INTO students (…) VALUES ('SP', 'Demo', 3.60, 2, NOW(), 1);

SAVEPOINT before_mistake;

UPDATE students SET gpa = 0.00 WHERE department_id = 2;  -- mistake!

ROLLBACK TO SAVEPOINT before_mistake;  -- undo mistake, keep insert

COMMIT;
-- Result: SP Demo exists (3.60); other dept 2 students unchanged
```

**What ROLLBACK TO SAVEPOINT does:**
- Undoes all changes **after** the savepoint was set
- **Does NOT** commit — the transaction is still open
- Changes **before** the savepoint are kept, pending final COMMIT or ROLLBACK

---

<!-- Slide 15: Isolation Levels -->
## Isolation Levels

| Level | Dirty Read | Non-Repeatable | Phantom |
|-------|-----------|----------------|---------|
| READ UNCOMMITTED | Possible | Possible | Possible |
| **READ COMMITTED** | Protected | Possible | Possible |
| **REPEATABLE READ** | Protected | Protected | Possible |
| SERIALIZABLE | Protected | Protected | Protected |

**Platform defaults:**
- MySQL: `REPEATABLE READ`
- PostgreSQL: `READ COMMITTED`
- SQL Server: `READ COMMITTED`

> **Dirty read:** reading uncommitted data from another transaction that may roll back.

---

<!-- Slide 16: Isolation Level Demo -->
## Isolation Levels — Dirty Read Demo

**Window 1 (SQL Server):**
```sql
BEGIN TRANSACTION;
UPDATE students SET gpa = 0.00 WHERE student_id = 1;
-- Do NOT commit yet
```

**Window 2:**
```sql
-- READ COMMITTED (default) — does NOT see the uncommitted 0.00
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT gpa FROM students WHERE student_id = 1;  -- original value

-- READ UNCOMMITTED — SEES the uncommitted 0.00 (dirty read!)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT gpa FROM students WHERE student_id = 1;  -- 0.00
```

**Window 1:**
```sql
ROLLBACK;  -- The 0.00 never committed; Window 2 read phantom data
```

---

<!-- Slide 17: Autocommit -->
## Autocommit Mode

By default, most platforms run in **autocommit** mode:

> Every statement is implicitly wrapped in its own transaction and committed immediately.

```sql
-- Without a transaction block, this commits immediately:
UPDATE students SET gpa = 4.00 WHERE student_id = 1;
-- Cannot roll this back!

-- To allow rollback, wrap in explicit transaction:
BEGIN TRANSACTION;
UPDATE students SET gpa = 4.00 WHERE student_id = 1;
-- Check: was this right?
ROLLBACK;  -- or COMMIT if correct
```

<span class="warn">In autocommit mode, a missing WHERE clause on UPDATE/DELETE causes immediate, unrecoverable data loss.</span>

---

<!-- Slide 18: Common DML Mistakes -->
## Common DML Mistakes

| Mistake | Consequence | Prevention |
|---------|-------------|------------|
| UPDATE / DELETE without WHERE | All rows affected | SELECT-before-DML |
| NOT IN with NULL in subquery | 0 rows returned | Use NOT EXISTS |
| INSERT without column list | Breaks on schema change | Always list columns |
| Forgetting COMMIT | Changes invisible to others | Pair every BEGIN with COMMIT/ROLLBACK |
| TRUNCATE expecting rollback (MySQL) | Unrecoverable | Use DELETE in a transaction |
| SQL Server: missing `;` before MERGE | Syntax error | Add `;` on preceding statement |
| PostgreSQL UPDATE JOIN syntax | Syntax error | Use `UPDATE … FROM … WHERE` |

---

<!-- Slide 19: Key Takeaways -->
## Key Takeaways

**INSERT:**
- Always list column names · multi-row in one statement · INSERT…SELECT for bulk copy

**UPDATE / DELETE:**
- <span class="warn">SELECT-before-DML — every time, no exceptions</span>
- Use `student_id` in WHERE, not names

**UPSERT:**
- MySQL: `ON DUPLICATE KEY UPDATE` · PostgreSQL: `ON CONFLICT DO UPDATE` · SQL Server: `MERGE`
- PostgreSQL: `EXCLUDED` = the attempted row · SQL Server: `$action` in OUTPUT

**Transactions:**
- ACID guarantees correctness and durability
- SAVEPOINTs let you undo mistakes without losing the whole transaction
- Match your isolation level to your consistency requirement

---

<!-- Slide 20: Module 09 Preview -->
## Module 09 Preview

### Schema Design & DDL

What's next:

- **Normalization** — 1NF, 2NF, 3NF and why they matter
- **CREATE TABLE** — column types, constraints, defaults
- **PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK**
- **Indexes** — B-Tree, covering, composite, partial
- **ALTER TABLE** — adding columns, changing types, dropping constraints
- **Platform differences** — AUTO_INCREMENT vs SERIAL vs IDENTITY

> Good schema design prevents entire categories of DML bugs — the best UPDATE is the one you never need.
