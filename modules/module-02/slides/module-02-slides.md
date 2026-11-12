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
    --color-text: #e8eaf0;
    --color-muted: #8892a4;
    --color-code-bg: #21253a;
  }
  section {
    background: var(--color-bg);
    color: var(--color-text);
    font-family: 'Segoe UI', system-ui, sans-serif;
    font-size: 22px;
    padding: 40px 50px;
  }
  h1 {
    color: var(--color-accent);
    font-size: 2em;
    margin-bottom: 0.3em;
  }
  h2 {
    color: var(--color-accent2);
    font-size: 1.3em;
    border-bottom: 1px solid #2e3250;
    padding-bottom: 6px;
    margin-bottom: 0.6em;
  }
  h3 { color: #b0b8d0; font-size: 1.05em; }
  code {
    background: var(--color-code-bg);
    color: var(--color-accent2);
    border-radius: 4px;
    padding: 1px 5px;
  }
  pre {
    background: var(--color-code-bg);
    border-left: 3px solid var(--color-accent);
    border-radius: 6px;
    padding: 14px 18px;
    font-size: 0.78em;
  }
  pre code { background: transparent; padding: 0; }
  table {
    font-size: 0.82em;
    border-collapse: collapse;
    width: 100%;
  }
  th {
    background: var(--color-surface);
    color: var(--color-accent);
    padding: 7px 10px;
    text-align: left;
  }
  td { padding: 6px 10px; border-bottom: 1px solid #2e3250; }
  tr:last-child td { border-bottom: none; }
  .accent { color: var(--color-accent); font-weight: bold; }
  .green  { color: var(--color-accent2); font-weight: bold; }
  .warn   { color: var(--color-warn); font-weight: bold; }
  .muted  { color: var(--color-muted); }
  footer {
    font-size: 0.65em;
    color: var(--color-muted);
  }
---

<!-- _paginate: false -->

# Module 02
## Creating Tables and Inserting Data

**SQL Engineering Academy**
Track A · MySQL 8.0 | Track B · PostgreSQL 16 | Track C · SQL Server 2022

---

## Agenda

1. The two categories of SQL you'll use today
2. CREATE DATABASE — platform differences
3. Data types and when to use each
4. CREATE TABLE — constraints and naming
5. Auto-incrementing primary keys — three ways
6. INSERT INTO — single-row and multi-row
7. Getting back the new ID
8. UPDATE and DELETE — safely
9. TRUNCATE vs DELETE
10. ALTER TABLE
11. Common mistakes to avoid

---

## DDL vs DML

```
SQL commands
├── DDL — Data Definition Language  (define the structure)
│   └── CREATE  ALTER  DROP  TRUNCATE
│
└── DML — Data Manipulation Language  (move the data)
    └── INSERT  UPDATE  DELETE  SELECT
```

This module covers DDL and the write-side of DML.

**Rule of thumb:**
- DDL changes the *shape* of the database
- DML changes the *contents* of the database

---

## CREATE DATABASE

Three platforms, three syntaxes:

```sql
-- MySQL: specify encoding from day one
CREATE DATABASE university
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE university;
```

```sql
-- PostgreSQL: encoding chosen at cluster level
CREATE DATABASE university;
-- Then: \c university  (psql)
```

```sql
-- SQL Server: GO separates batches
CREATE DATABASE university;
GO
USE university;
GO
```

---

## Integer Types — At a Glance

| Type | MySQL | PostgreSQL | SQL Server | Range |
|------|-------|------------|------------|-------|
| Tiny | `TINYINT` | — | `TINYINT` | 0–255 |
| Small | `SMALLINT` | `SMALLINT` | `SMALLINT` | ±32 K |
| Standard | `INT` | `INT` | `INT` | ±2.1 B |
| Big | `BIGINT` | `BIGINT` | `BIGINT` | ±9.2 × 10¹⁸ |

**Use `INT` for most IDs. Use `BIGINT` when you might exceed 2 billion rows.**

PostgreSQL also has `SERIAL` / `BIGSERIAL` shorthand types.

---

## DECIMAL vs FLOAT — Use the Right One

<div class="warn">Never store money as FLOAT.</div>

```sql
-- Floating-point arithmetic is approximate:
SELECT 0.1 + 0.2;
-- Returns: 0.30000000000000004  ← not 0.30
```

```sql
-- DECIMAL is exact:
SELECT CAST(0.1 AS DECIMAL(10,2)) + CAST(0.2 AS DECIMAL(10,2));
-- Returns: 0.30  ✓
```

**Pattern:**
- `DECIMAL(10,2)` — currency (8 digits before, 2 after the decimal point)
- `DECIMAL(3,2)` — GPA, rate out of 4.00
- `FLOAT` — scientific measurements where approximation is acceptable

---

## Text Types — Platform Differences

| Need | MySQL | PostgreSQL | SQL Server |
|------|-------|------------|------------|
| Short variable text | `VARCHAR(n)` | `VARCHAR(n)` or `TEXT` | `NVARCHAR(n)` |
| Unlimited text | `TEXT` | `TEXT` | `NVARCHAR(MAX)` |
| Fixed-length | `CHAR(n)` | `CHAR(n)` | `NCHAR(n)` |

**Critical distinctions:**

- **MySQL `utf8`** is capped at 3 bytes — emoji are excluded. Use `utf8mb4`.
- **SQL Server `VARCHAR`** stores Latin-1 only. Use `NVARCHAR` for any real-world text.
- **PostgreSQL `TEXT`** has no length limit and the same performance as `VARCHAR(n)`.

---

## Boolean and Date Types

| Concept | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Boolean | `BOOLEAN` (alias TINYINT(1)) | `BOOLEAN` (native) | `BIT` (0/1) |
| Date only | `DATE` | `DATE` | `DATE` |
| Date + time | `DATETIME` | `TIMESTAMP` | `DATETIME2` |
| With timezone | (manual) | `TIMESTAMPTZ` ← use this | `DATETIMEOFFSET` |

**Use `TIMESTAMPTZ` in PostgreSQL** — it stores UTC internally and converts to local time on read.  
**Use `DATETIME2` in SQL Server** — higher precision than the older `DATETIME`.

---

## CREATE TABLE — Anatomy

```sql
CREATE TABLE students (
    -- column   data_type        constraint
    student_id  INT              NOT NULL IDENTITY(1,1),
    first_name  NVARCHAR(50)     NOT NULL,
    email       NVARCHAR(100)    NOT NULL,
    gpa         DECIMAL(3,2)     NULL,

    -- named table-level constraints
    CONSTRAINT pk_students       PRIMARY KEY (student_id),
    CONSTRAINT uq_students_email UNIQUE (email),
    CONSTRAINT chk_students_gpa  CHECK (gpa BETWEEN 0.00 AND 4.00)
);
```

**Always name your constraints.**  
`pk_`, `uq_`, `chk_`, `fk_`, `df_` prefixes make error messages readable.

---

## Auto-Incrementing Primary Keys — Three Ways

```sql
-- MySQL
student_id  INT  NOT NULL AUTO_INCREMENT,
CONSTRAINT pk_students PRIMARY KEY (student_id)
```

```sql
-- PostgreSQL (preferred — SQL standard)
student_id  INT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY
-- or classic shorthand:
student_id  SERIAL PRIMARY KEY
```

```sql
-- SQL Server
student_id  INT  NOT NULL IDENTITY(1,1),
CONSTRAINT pk_students PRIMARY KEY (student_id)
```

`IDENTITY(seed, increment)` — `IDENTITY(1,1)` starts at 1, increments by 1.  
`IDENTITY(100,5)` starts at 100 and goes 100 → 105 → 110 …

---

## INSERT — Single and Multi-Row

```sql
-- Single row
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Amara', 'Osei', 'amara.osei@example.com', '2024-09-01');

-- Multi-row (one statement — preferred for bulk loads)
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES
    ('Priya',  'Sharma',  'priya.sharma@example.com',  '2024-09-01'),
    ('Carlos', 'Mendez',  'carlos.mendez@example.com', '2024-01-15'),
    ('Sofia',  'Eriksson','sofia.eriksson@example.com','2023-09-01');
```

Multi-row inserts are **significantly faster** than individual inserts in a loop — the database processes one statement instead of many.

---

## Getting Back the New ID — Platform Comparison

| Platform | Mechanism | Atomic? |
|----------|-----------|---------|
| PostgreSQL | `RETURNING id` | ✓ Yes |
| SQL Server | `OUTPUT INSERTED.id` | ✓ Yes |
| MySQL | `SELECT LAST_INSERT_ID()` | Requires 2nd statement |

```sql
-- PostgreSQL
INSERT INTO departments (department_name) VALUES ('Physics')
RETURNING department_id;

-- SQL Server
INSERT INTO departments (department_name)
OUTPUT INSERTED.department_id VALUES (N'Physics');

-- MySQL
INSERT INTO departments (department_name) VALUES ('Physics');
SELECT LAST_INSERT_ID() AS new_id;
```

---

## PostgreSQL RETURNING — A Superpower

`RETURNING` works on `INSERT`, `UPDATE`, and `DELETE`:

```sql
-- See old and new values in a single UPDATE
UPDATE students
SET    gpa = 3.95
WHERE  student_id = 1
RETURNING student_id, first_name, gpa;   -- shows the new gpa

-- Confirm what was deleted
DELETE FROM students
WHERE  email = 'test@example.com'
RETURNING student_id, first_name, last_name;
```

**Why it matters:** No gap between the write and the read. Eliminates race conditions in concurrent applications.

---

## SQL Server OUTPUT — INSERTED and DELETED

```sql
-- On UPDATE: DELETED = before-image, INSERTED = after-image
UPDATE students
SET    gpa = 3.95
OUTPUT DELETED.gpa AS old_gpa,
       INSERTED.gpa AS new_gpa,
       INSERTED.first_name
WHERE  student_id = 1;

-- On DELETE: use DELETED pseudo-table
DELETE FROM students
OUTPUT DELETED.student_id, DELETED.email
WHERE  is_active = 0;
```

**Key fact:** `INSERTED` and `DELETED` are virtual tables, not real columns.  
They exist only inside `OUTPUT`, `AFTER` triggers, and `INSTEAD OF` triggers.

---

## UPDATE Safely

```sql
-- ALWAYS filter with WHERE
-- Step 1: SELECT first to confirm target rows
SELECT department_id, department_name, budget
FROM   departments
WHERE  department_name = 'Computer Science';

-- Step 2: Update only after confirming
UPDATE departments
SET    budget = budget * 1.10
WHERE  department_name = 'Computer Science';

-- Step 3: Verify
SELECT department_name, budget FROM departments;
```

<div class="warn">UPDATE without WHERE modifies EVERY row in the table.</div>  
<div class="warn">There is no undo. Use transactions (covered in a later module).</div>

---

## DELETE vs TRUNCATE

| Feature | DELETE | TRUNCATE |
|---------|--------|----------|
| Removes specific rows | ✓ WITH WHERE | ✗ All rows only |
| Transaction log | Row-by-row | Minimal (page deallocations) |
| Fires triggers | ✓ Yes | ✗ No (usually) |
| Resets identity counter | ✗ No | ✓ Yes (MySQL, SQL Server) |
| PostgreSQL reset | ✗ No | With RESTART IDENTITY |
| Can be rolled back | ✓ Yes | ✓ Yes (in a transaction) |

**Use DELETE** when you need a WHERE clause or trigger behavior.  
**Use TRUNCATE** when clearing a whole table fast.

---

## ALTER TABLE — Adding and Modifying Columns

```sql
-- Add a column
ALTER TABLE students ADD COLUMN bio TEXT;             -- MySQL / PostgreSQL
ALTER TABLE students ADD bio NVARCHAR(MAX);           -- SQL Server

-- Change column type
ALTER TABLE students ALTER COLUMN phone TYPE VARCHAR(30);  -- PostgreSQL
ALTER TABLE students ALTER COLUMN phone NVARCHAR(30);      -- SQL Server
-- MySQL:
ALTER TABLE students MODIFY COLUMN phone VARCHAR(30);

-- Rename a column
ALTER TABLE students RENAME COLUMN bio TO notes;      -- PostgreSQL / MySQL 8.0.4+
EXEC sp_rename 'students.bio', 'notes', 'COLUMN';    -- SQL Server

-- Drop a column
ALTER TABLE students DROP COLUMN notes;               -- MySQL / PostgreSQL
-- SQL Server: must drop default constraint first, then:
ALTER TABLE students DROP COLUMN notes;
```

---

## Common Mistakes — Module 02

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| `FLOAT` for money | Rounding errors accumulate | Use `DECIMAL(10,2)` |
| MySQL `utf8` instead of `utf8mb4` | Emoji crash with "incorrect string" | `CHARACTER SET utf8mb4` |
| SQL Server `VARCHAR` for text | Non-ASCII silently corrupted | Use `NVARCHAR`; prefix with `N''` |
| Unnamed constraints | Cryptic FK error messages | Always use `CONSTRAINT pk_... UNIQUE...` |
| Missing `ENGINE=InnoDB` in MySQL | FKs parsed but not enforced | Add `ENGINE=InnoDB` to every table |
| `@@IDENTITY` instead of `SCOPE_IDENTITY()` | Wrong ID when triggers exist | Use `SCOPE_IDENTITY()` |
| UPDATE / DELETE without WHERE | Every row modified / deleted | Always SELECT first |
| DROP TABLE — parent before child | FK violation error | Drop child tables first |

---

## DROP TABLE Order Matters

```
departments  (parent)
    └── professors  (child — has FK to departments)
            └── course_assignments  (grandchild)
```

```sql
-- WRONG — parent first → FK error
DROP TABLE departments;
DROP TABLE professors;

-- CORRECT — children first
DROP TABLE course_assignments;
DROP TABLE professors;
DROP TABLE departments;
```

```sql
-- PostgreSQL / MySQL shortcut
DROP TABLE IF EXISTS course_assignments, professors, departments;

-- SQL Server pattern
IF OBJECT_ID('course_assignments', 'U') IS NOT NULL DROP TABLE course_assignments;
IF OBJECT_ID('professors',         'U') IS NOT NULL DROP TABLE professors;
IF OBJECT_ID('departments',        'U') IS NOT NULL DROP TABLE departments;
```

---

## Platform Summary — Module 02

| Concept | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Database creation | `CREATE DATABASE … utf8mb4` | `CREATE DATABASE` | `CREATE DATABASE; GO` |
| Auto-increment | `AUTO_INCREMENT` | `GENERATED ALWAYS AS IDENTITY` | `IDENTITY(1,1)` |
| Last ID | `LAST_INSERT_ID()` | `RETURNING` / `currval()` | `SCOPE_IDENTITY()` |
| Return on INSERT | — | `RETURNING` | `OUTPUT INSERTED.*` |
| Unicode text | `VARCHAR utf8mb4` | `VARCHAR` / `TEXT` | `NVARCHAR` + `N''` |
| Timestamp | `TIMESTAMP` | `TIMESTAMPTZ` | `DATETIME2` |
| Require InnoDB | `ENGINE=InnoDB` | n/a | n/a |

---

## Module 02 — Summary

You can now:

✓ Create databases with platform-appropriate character settings  
✓ Define tables with correct data types (DECIMAL not FLOAT for money)  
✓ Understand the three auto-increment mechanisms  
✓ Insert single and multi-row data  
✓ Retrieve the new ID immediately (RETURNING / OUTPUT / LAST_INSERT_ID)  
✓ Write safe UPDATE and DELETE with WHERE clauses  
✓ Understand TRUNCATE vs DELETE trade-offs  
✓ Modify existing tables with ALTER TABLE  

---

## Next: Module 03 — Querying Data

**SELECT, WHERE, ORDER BY, LIMIT / TOP / FETCH**

You will learn to:
- Filter rows with WHERE and comparison operators
- Sort results with ORDER BY
- Limit result sets (LIMIT vs TOP vs FETCH NEXT)
- Combine conditions with AND, OR, NOT
- Handle NULL in WHERE clauses (IS NULL, IS NOT NULL)
- Use BETWEEN, IN, LIKE for range and pattern matching

**Before then:** Complete the Module 02 lab and quiz.

---

<!-- _paginate: false -->

## Knowledge Check

Before the next module, make sure you can answer:

1. Why is `DECIMAL` required for monetary values?
2. What does `IDENTITY(50, 10)` mean in SQL Server?
3. What is the PostgreSQL advantage of `RETURNING` over `SELECT LAST_INSERT_ID()`?
4. Why does dropping a parent table before its child table fail?
5. What is the difference between `SCOPE_IDENTITY()` and `@@IDENTITY`?
6. What happens to auto-increment counters after DELETE vs TRUNCATE?

*Answers in `assessments/quiz-02.md`*
