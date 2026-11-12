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
# Module 09
## Schema Design & DDL

**Normalization · CREATE TABLE · Constraints · Indexes · ALTER TABLE**

MySQL 8.0 · PostgreSQL 16 · SQL Server 2022

---

<!-- Slide 02: DDL vs DML -->
## DDL vs DML

| Category | Statements | Changes |
|----------|-----------|---------|
| **DDL** (Data Definition) | CREATE, ALTER, DROP, TRUNCATE | Table structure |
| **DML** (Data Manipulation) | INSERT, UPDATE, DELETE, MERGE | Row data |
| **TCL** (Transaction Control) | BEGIN, COMMIT, ROLLBACK | Transaction scope |

> DDL defines the **shape** of the data. DML fills the **content**.  
> A good schema makes DML safer, faster, and simpler.

---

<!-- Slide 03: Why Schema Design Matters -->
## Why Schema Design Matters

A poorly designed schema causes:
- Redundant data → UPDATE anomalies (update one place, forget another)
- No constraints → bad data lands silently
- No indexes → slow queries that no tuning can fix
- Wrong types → rounding errors, silent truncation

A well-designed schema:
- Enforces business rules at the **database level**
- Makes queries obvious and joins natural
- Scales to millions of rows without rewrites

> <span class="warn">Fixing a schema after data is in production is 10× harder than designing it correctly up front.</span>

---

<!-- Slide 04: Normalization — 1NF -->
## Normalization: 1NF

**Rule:** Every cell holds one atomic value. No repeating groups.

**Violation:**
```
students(student_id, name, courses)
1, 'Amara', 'Math, Physics, CS'   ← multi-valued cell
```

**Fix:** Create a separate `enrollments` table

```sql
CREATE TABLE enrollments (
    student_id INT NOT NULL,
    course_id  INT NOT NULL,
    PRIMARY KEY (student_id, course_id)
);
```

> 1NF is the foundation. Without it, SQL cannot filter, join, or aggregate correctly.

---

<!-- Slide 05: Normalization — 2NF and 3NF -->
## Normalization: 2NF and 3NF

**2NF:** No partial dependency on a composite PK

```
order_detail(order_id, product_id, product_name, quantity)
-- product_name depends only on product_id, not the full (order_id, product_id) PK
```
Fix: move `product_name` to `products(product_id PK, product_name)`

---

**3NF:** No transitive dependency (non-key → non-key)

```
students(student_id, dept_id, dept_name)
-- dept_name depends on dept_id, not student_id
```
Fix: move `dept_name` to `departments(dept_id PK, dept_name)`

> Our `university` database is already 3NF. Now you know **why**.

---

<!-- Slide 06: Data Types -->
## Data Types — Key Choices

| Need | MySQL | PostgreSQL | SQL Server |
|------|-------|-----------|------------|
| Auto-int PK | `INT AUTO_INCREMENT` | `SERIAL` | `INT IDENTITY(1,1)` |
| Exact decimal | `DECIMAL(p,s)` | `NUMERIC(p,s)` | `DECIMAL(p,s)` |
| Boolean | `TINYINT(1)` | `BOOLEAN` | `BIT` |
| Unicode text | `VARCHAR(n)` utf8mb4 | `VARCHAR(n)` | **`NVARCHAR(n)`** |
| Timestamp+TZ | `TIMESTAMP` | `TIMESTAMPTZ` | `DATETIMEOFFSET` |
| JSON | `JSON` | `JSONB` | `NVARCHAR(MAX)` |

<span class="warn">Never use FLOAT for money.</span> `0.1 + 0.2` ≠ `0.3` in floating-point. Use `DECIMAL(p,s)`.

---

<!-- Slide 07: CREATE TABLE -->
## CREATE TABLE

```sql
-- MySQL 8.0
CREATE TABLE students (
    student_id    INT           NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(100)  NOT NULL,
    email         VARCHAR(200)  NOT NULL,
    gpa           DECIMAL(3,2)  NOT NULL DEFAULT 0.00,
    department_id INT           NOT NULL,
    PRIMARY KEY (student_id),
    UNIQUE KEY uq_email (email),
    CONSTRAINT chk_gpa CHECK (gpa BETWEEN 0.00 AND 4.00)
);
```

**Key ingredients every CREATE TABLE needs:**
- Auto-increment PK
- NOT NULL on required columns
- UNIQUE on natural keys (email)
- CHECK on constrained values (GPA range)

---

<!-- Slide 08: PRIMARY KEY -->
## PRIMARY KEY

```sql
-- Single-column PK
PRIMARY KEY (student_id)

-- Composite PK (enrollments)
PRIMARY KEY (student_id, course_id)
```

**Rules:**
- Implicitly NOT NULL
- Automatically creates a unique index
- One per table only
- Use `IDENTITY(1,1)` / `SERIAL` / `AUTO_INCREMENT` for surrogate keys

> Prefer **surrogate keys** (auto-increment integer) for most tables. Use natural composite PKs for pure join tables (enrollments, roles).

---

<!-- Slide 09: FOREIGN KEY -->
## FOREIGN KEY

```sql
CONSTRAINT fk_std_dept
    FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
```

**Referential actions:**

| Action | On parent DELETE |
|--------|-----------------|
| `RESTRICT` / `NO ACTION` | Block — parent cannot be deleted if children exist |
| `CASCADE` | Delete all matching children automatically |
| `SET NULL` | Set child FK column to NULL |
| `SET DEFAULT` | Set child FK column to its default |

> <span class="warn">Use CASCADE only when children have no meaning without the parent (order items → orders).</span>

---

<!-- Slide 10: UNIQUE, NOT NULL, CHECK, DEFAULT -->
## Constraints: UNIQUE · NOT NULL · CHECK · DEFAULT

```sql
-- UNIQUE: no two rows can share this value
email VARCHAR(200) NOT NULL UNIQUE

-- Composite UNIQUE
CONSTRAINT uq_faculty_course UNIQUE (faculty_id, course_id, semester)

-- CHECK: reject rows that fail the condition
CONSTRAINT chk_gpa CHECK (gpa BETWEEN 0.00 AND 4.00)

-- DEFAULT: value used when INSERT doesn't specify the column
enrolled_at DATE NOT NULL DEFAULT CURRENT_DATE  -- PostgreSQL
enrolled_at DATE NOT NULL DEFAULT (CURDATE())   -- MySQL 8.0
```

> CHECK constraints are your last line of defense in the database.  
> They fire even if the application forgets to validate.

---

<!-- Slide 11: Indexes — Why They Exist -->
## Indexes — Why They Exist

**Without an index:** full table scan — the database reads every row.

**With a B-Tree index:** the database navigates a sorted tree directly to the rows.

```sql
-- 10,000-row table, no index on email
SELECT * FROM students WHERE email = 'priya@example.com';
-- Reads all 10,000 rows

-- After: CREATE INDEX idx_email ON students(email)
-- Reads ~log2(10000) ≈ 14 comparisons
```

**Cost:**
- Faster SELECT
- Slower INSERT / UPDATE / DELETE (index must be maintained)
- Storage overhead

> Index every column you filter, join, or sort on — but not more.

---

<!-- Slide 12: Index Types -->
## Index Types

| Type | Purpose |
|------|---------|
| **B-Tree** (default) | Equality, range, ORDER BY, JOIN |
| **Composite** | Filter on multiple columns together |
| **Covering** | Satisfy all needed columns without touching the table |
| **Partial / Filtered** | Index only a qualifying subset of rows |
| **Unique index** | Enforce uniqueness (created by UNIQUE constraint) |

```sql
-- Composite (leftmost prefix rule applies)
CREATE INDEX idx_dept_gpa ON students(department_id, gpa DESC);

-- Covering (PostgreSQL / SQL Server)
CREATE INDEX idx_cov ON students(department_id) INCLUDE (first_name, email);

-- Partial (PostgreSQL) / Filtered (SQL Server)
CREATE INDEX idx_active ON students(department_id) WHERE is_active = TRUE;
```

---

<!-- Slide 13: Leftmost Prefix Rule -->
## Composite Indexes — Leftmost Prefix Rule

Index on `(department_id, gpa, last_name)`:

| Query | Uses index? |
|-------|-------------|
| `WHERE department_id = 1` | ✅ Yes |
| `WHERE department_id = 1 AND gpa > 3.5` | ✅ Yes |
| `WHERE department_id = 1 AND gpa > 3.5 AND last_name = 'F'` | ✅ Yes |
| `WHERE gpa > 3.5` | ❌ No — skips leading column |
| `WHERE last_name = 'Fischer'` | ❌ No — skips both leading columns |

> Design composite indexes **leading with equality filters**, then range filters.

---

<!-- Slide 14: ALTER TABLE -->
## ALTER TABLE

```sql
-- Add column
ALTER TABLE faculty ADD COLUMN phone VARCHAR(20);         -- MySQL/PG
ALTER TABLE faculty ADD              phone NVARCHAR(20);  -- SQL Server

-- Rename column
ALTER TABLE faculty RENAME COLUMN phone TO contact_phone; -- MySQL 8.0 / PG
EXEC sp_rename 'faculty.phone', 'contact_phone', 'COLUMN'; -- SQL Server

-- Change type
ALTER TABLE faculty MODIFY COLUMN gpa DECIMAL(4,2);       -- MySQL
ALTER TABLE faculty ALTER  COLUMN gpa TYPE NUMERIC(4,2);  -- PostgreSQL
ALTER TABLE faculty ALTER  COLUMN gpa DECIMAL(4,2);       -- SQL Server

-- Add constraint
ALTER TABLE faculty ADD CONSTRAINT chk_gpa CHECK (gpa BETWEEN 0 AND 4);

-- Drop column
ALTER TABLE faculty DROP COLUMN phone;
```

---

<!-- Slide 15: DROP TABLE — Safe Patterns -->
## DROP TABLE — Safe Patterns

```sql
-- MySQL / PostgreSQL: IF EXISTS prevents error if table doesn't exist
DROP TABLE IF EXISTS students_staging;

-- Drop in FK-safe order: children before parents
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS departments;

-- SQL Server
IF OBJECT_ID('dbo.enrollments', 'U') IS NOT NULL DROP TABLE dbo.enrollments;
IF OBJECT_ID('dbo.students',    'U') IS NOT NULL DROP TABLE dbo.students;
```

> <span class="warn">DROP TABLE is irreversible. It removes the table structure AND all its data.</span>  
> Always verify the table name before dropping in production.

---

<!-- Slide 16: Auto-Increment by Platform -->
## Auto-Increment / Identity

```sql
-- MySQL 8.0
CREATE TABLE t (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY);
SELECT LAST_INSERT_ID();      -- get generated id

-- PostgreSQL 16
CREATE TABLE t (id SERIAL PRIMARY KEY);
-- or modern:
CREATE TABLE t (id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY);
INSERT INTO t (name) VALUES ('x') RETURNING id;   -- inline

-- SQL Server 2022
CREATE TABLE t (id INT IDENTITY(1,1) NOT NULL PRIMARY KEY);
SELECT SCOPE_IDENTITY();      -- current scope (always use this)
-- NOT @@IDENTITY — that is session-wide, unsafe with triggers
```

---

<!-- Slide 17: PostgreSQL — Transactional DDL -->
## PostgreSQL: DDL Is Transactional

```sql
BEGIN;

CREATE TABLE rollback_test (id SERIAL PRIMARY KEY, val TEXT);
INSERT INTO rollback_test (val) VALUES ('test');

SELECT * FROM rollback_test;  -- sees 1 row mid-transaction

ROLLBACK;  -- the table itself is rolled back

SELECT to_regclass('public.rollback_test');  -- NULL — table is gone
```

**MySQL and SQL Server:** DDL auto-commits — `CREATE TABLE` cannot be rolled back.

**PostgreSQL advantage:** a failed schema migration script can be rolled back atomically, leaving the database clean.

---

<!-- Slide 18: VARCHAR vs NVARCHAR (SQL Server) -->
## SQL Server: VARCHAR vs NVARCHAR

| Type | Encoding | Bytes/char | Use for |
|------|----------|-----------|---------|
| `VARCHAR(n)` | ASCII/ANSI | 1 | Emails, ISO codes, internal keys |
| `NVARCHAR(n)` | UTF-16 | 2 | Names, addresses, any user text |

```sql
-- Correct: N prefix for NVARCHAR literals
INSERT INTO students (first_name) VALUES (N'Amara');   -- ✅
INSERT INTO students (first_name) VALUES ('Amara');    -- ✅ ASCII

-- Dangerous: Amharic or Arabic name without N prefix
INSERT INTO students (first_name) VALUES ('ሴ');        -- ❌ corrupted
INSERT INTO students (first_name) VALUES (N'ሴ');       -- ✅ stored correctly
```

> <span class="warn">Always use NVARCHAR for user-generated text in SQL Server. Always prefix Unicode literals with N.</span>

---

<!-- Slide 19: Common DDL Mistakes -->
## Common DDL Mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| `FLOAT` for money | Rounding errors | `DECIMAL(p,s)` |
| No index on FK columns | Slow JOIN, slow DELETE | Add index on every FK |
| Over-indexing | Slow INSERT/UPDATE | Index only queried columns |
| `VARCHAR(255)` everywhere | Misleads documentation | Size to business data |
| SQL Server `VARCHAR` for names | Corrupts non-ASCII | `NVARCHAR` |
| DROP TABLE wrong order | FK violation error | Drop children first |
| CHECK ignored (MySQL < 8.0.16) | Bad data enters | Upgrade or enforce in app |

---

<!-- Slide 20: Key Takeaways & Module 10 Preview -->
## Key Takeaways

**Normalization:** 1NF → atomic values · 2NF → no partial deps · 3NF → no transitive deps

**Types:** `DECIMAL` for money · `NVARCHAR` in SQL Server for user text · `SERIAL`/`IDENTITY`/`AUTO_INCREMENT` for PKs

**Constraints:** CHECK catches bad data before it lands — use them

**Indexes:** B-Tree for most queries · composite respects leftmost prefix · covering avoids table lookup · partial/filtered for subsets

**ALTER TABLE:** column rename differs by platform — `sp_rename` on SQL Server

**DROP TABLE:** children before parents · `IF EXISTS` prevents errors

---

## Module 10 Preview

### Subqueries & CTEs

- **Scalar subqueries** — return one value
- **Correlated subqueries** — reference the outer query
- **EXISTS / NOT EXISTS** — NULL-safe membership test
- **WITH clause (CTE)** — name and reuse a query result
- **Recursive CTEs** — hierarchical data, organizational trees
- **Subquery vs JOIN** — when each performs better

> CTEs are the tool that transforms complex multi-step logic into readable, maintainable SQL.
