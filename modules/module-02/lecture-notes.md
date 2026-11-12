# Module 02 — Lecture Notes
## Creating Tables and Inserting Data

---

## 1. Creating a Database

Before creating tables you need a database to hold them. The syntax is similar on all three platforms, but the subsequent step of "switching to" that database differs.

### SQL Server
```sql
CREATE DATABASE academy;
GO
USE academy;
GO
```
`GO` is a batch separator in T-SQL — it tells SSMS/sqlcmd to send statements in the buffer to the server. It is not SQL; it is a client tool directive.

### PostgreSQL
```sql
CREATE DATABASE academy;
-- Then connect to it:
-- psql: \c academy
-- pgAdmin: select the database in the object tree
```
PostgreSQL has no `USE` statement. You switch databases by opening a new connection to that database.

### MySQL
```sql
CREATE DATABASE academy CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE academy;
```
Always specify `utf8mb4` in MySQL for full Unicode support (including emoji and supplementary characters). The older `utf8` in MySQL is not actual UTF-8 — it only supports 3-byte characters.

---

## 2. Data Types

Choosing the right data type is a design decision: it enforces business rules, affects storage, and determines what operations are valid.

### Integer types

| Type | SQL Server | PostgreSQL | MySQL | Range |
|------|-----------|-----------|-------|-------|
| Small integer | `SMALLINT` | `SMALLINT` | `SMALLINT` | −32,768 to 32,767 |
| Standard integer | `INT` | `INTEGER` | `INT` | −2.1B to 2.1B |
| Large integer | `BIGINT` | `BIGINT` | `BIGINT` | −9.2×10¹⁸ to 9.2×10¹⁸ |
| Tiny (0–255) | `TINYINT` | — | `TINYINT` | 0 to 255 |

**Recommendation:** Use `INT` for most IDs. Use `BIGINT` when you expect more than 2 billion rows. `TINYINT` is useful for small lookup code columns.

### Decimal / money types

| Need | Recommended type | Notes |
|------|-----------------|-------|
| Currency, exact math | `DECIMAL(p,s)` or `NUMERIC(p,s)` | p = total digits, s = decimal places |
| Scientific calculations | `FLOAT` or `REAL` | Approximate — never use for money |
| SQL Server money shortcut | `MONEY` | 4 decimal places, proprietary |

For money: **always use `DECIMAL(10,2)`** (or higher precision if needed). Never use `FLOAT` for financial amounts — floating-point arithmetic introduces rounding errors.

### Text types

| Need | SQL Server | PostgreSQL | MySQL |
|------|-----------|-----------|-------|
| Short strings, fixed max | `CHAR(n)` | `CHAR(n)` | `CHAR(n)` |
| Variable strings, known max | `VARCHAR(n)` | `VARCHAR(n)` | `VARCHAR(n)` |
| Large text, no length limit | `VARCHAR(MAX)` | `TEXT` | `TEXT` / `MEDIUMTEXT` / `LONGTEXT` |
| Unicode (SQL Server) | `NVARCHAR(n)` | VARCHAR is always Unicode | VARCHAR is Unicode with utf8mb4 |

**SQL Server note:** Use `NVARCHAR` instead of `VARCHAR` if the column will store non-Latin characters (Chinese, Arabic, emoji, etc.). PostgreSQL and MySQL (with utf8mb4) store all text as Unicode natively.

### Date and time types

| Type | SQL Server | PostgreSQL | MySQL |
|------|-----------|-----------|-------|
| Date only | `DATE` | `DATE` | `DATE` |
| Time only | `TIME` | `TIME` | `TIME` |
| Date + time | `DATETIME2` (preferred) or `DATETIME` | `TIMESTAMP` | `DATETIME` |
| Date + time + timezone | `DATETIMEOFFSET` | `TIMESTAMPTZ` | — (store timezone separately) |

**SQL Server:** Prefer `DATETIME2` over the older `DATETIME` — it has higher precision and a wider range.

### Boolean

| Platform | Type | True value | False value |
|----------|------|-----------|------------|
| SQL Server | `BIT` | `1` | `0` |
| PostgreSQL | `BOOLEAN` | `TRUE` or `'t'` | `FALSE` or `'f'` |
| MySQL | `BOOLEAN` (alias for `TINYINT(1)`) | `1` | `0` |

---

## 3. CREATE TABLE

The fundamental syntax:

```sql
CREATE TABLE table_name (
    column_name  data_type  [constraints],
    column_name  data_type  [constraints],
    ...
    [table_constraints]
);
```

### A complete example (all three platforms — shared syntax)

```sql
CREATE TABLE students (
    student_id   INT           NOT NULL,
    first_name   VARCHAR(50)   NOT NULL,
    last_name    VARCHAR(50)   NOT NULL,
    email        VARCHAR(100)  NOT NULL,
    gpa          DECIMAL(3,2),
    enrolled_at  DATE          NOT NULL,
    is_active    BIT,                     -- SQL Server; use BOOLEAN on PG/MySQL
    CONSTRAINT pk_students PRIMARY KEY (student_id),
    CONSTRAINT uq_students_email UNIQUE (email)
);
```

Naming constraints explicitly (`pk_students`, `uq_students_email`) is best practice — it makes error messages readable and allows precise `ALTER TABLE` operations later.

---

## 4. Auto-incrementing Primary Keys

The most important platform divergence in this module.

### MySQL — AUTO_INCREMENT

```sql
CREATE TABLE students (
    student_id  INT           NOT NULL AUTO_INCREMENT,
    first_name  VARCHAR(50)   NOT NULL,
    -- ...
    PRIMARY KEY (student_id)
);
```

The column must be a key (usually the primary key). MySQL assigns the next integer automatically on INSERT.

```sql
-- Check the next value
SHOW TABLE STATUS LIKE 'students';
-- or
SELECT AUTO_INCREMENT FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'students';
```

### PostgreSQL — SERIAL (classic) or GENERATED (modern)

**Classic (PostgreSQL < 10 style, still widely used):**
```sql
CREATE TABLE students (
    student_id  SERIAL        PRIMARY KEY,  -- shorthand for INT + sequence
    first_name  VARCHAR(50)   NOT NULL
);
```
`SERIAL` creates an integer column and an associated sequence object automatically.

**Modern (SQL standard, PostgreSQL 10+):**
```sql
CREATE TABLE students (
    student_id  INT           GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name  VARCHAR(50)   NOT NULL
);
```
`GENERATED ALWAYS AS IDENTITY` conforms to the SQL standard and is preferred in new code.

### SQL Server — IDENTITY

```sql
CREATE TABLE students (
    student_id  INT           IDENTITY(1,1) NOT NULL,
    first_name  VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_students PRIMARY KEY (student_id)
);
```
`IDENTITY(seed, increment)` — seed is the first value, increment is the step. `IDENTITY(1,1)` is the most common.

To see the last inserted identity value:
```sql
SELECT SCOPE_IDENTITY() AS last_id;      -- recommended
SELECT @@IDENTITY AS last_id;            -- also works, but scope-unaware
```

---

## 5. Constraints

Constraints enforce rules at the database level — they cannot be bypassed by application bugs.

| Constraint | Purpose | Example |
|-----------|---------|---------|
| `PRIMARY KEY` | Unique + NOT NULL; one per table | `student_id INT PRIMARY KEY` |
| `NOT NULL` | Column must have a value | `first_name VARCHAR(50) NOT NULL` |
| `UNIQUE` | All values in column must be distinct | `UNIQUE (email)` |
| `DEFAULT` | Value to use when none is supplied | `DEFAULT CURRENT_TIMESTAMP` |
| `CHECK` | Arbitrary condition that every row must satisfy | `CHECK (gpa BETWEEN 0.0 AND 4.0)` |
| `FOREIGN KEY` | References PK of another table | `REFERENCES instructors(id)` |

### CHECK constraint examples

```sql
-- SQL Server / PostgreSQL
CHECK (gpa BETWEEN 0.00 AND 4.00)
CHECK (email LIKE '%@%.%')
CHECK (quantity > 0)

-- MySQL (MySQL 8.0.16+ enforces CHECK; earlier versions parse but ignore it)
CHECK (gpa >= 0.00 AND gpa <= 4.00)
```

---

## 6. INSERT INTO

### Single row

```sql
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES ('Amara', 'Osei', 'amara.osei@email.com', 3.80, '2024-09-01');
```

Always name your columns explicitly. Positional inserts (`INSERT INTO t VALUES (...)`) break silently when columns are added or reordered.

### Multiple rows (one statement)

```sql
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES
    ('Priya',  'Sharma',  'priya.sharma@email.com',  3.50, '2024-09-01'),
    ('Carlos', 'Mendez',  'carlos.mendez@email.com', 3.90, '2024-01-15'),
    ('Sofia',  'Eriksson','sofia.eriksson@email.com', 3.70, '2023-09-01');
```

Multi-row INSERT is supported on all three platforms. It is significantly faster than single-row inserts in a loop.

### Retrieving the new ID after INSERT

```sql
-- SQL Server
INSERT INTO students (...) VALUES (...);
SELECT SCOPE_IDENTITY() AS new_id;

-- PostgreSQL (use RETURNING — cleaner and atomic)
INSERT INTO students (...) VALUES (...) RETURNING student_id;

-- MySQL
INSERT INTO students (...) VALUES (...);
SELECT LAST_INSERT_ID() AS new_id;
```

PostgreSQL's `RETURNING` clause is especially useful — it returns column values from the inserted row in a single atomic operation, without a second query.

---

## 7. UPDATE

```sql
UPDATE students
SET    gpa = 3.95,
       email = 'amara.updated@email.com'
WHERE  student_id = 1;
```

**Always include a `WHERE` clause.** An `UPDATE` without `WHERE` modifies every row in the table.

### Safe update pattern — verify first

```sql
-- Step 1: SELECT to see what you're about to change
SELECT student_id, gpa FROM students WHERE last_name = 'Osei';

-- Step 2: Run the UPDATE
UPDATE students SET gpa = 3.95 WHERE last_name = 'Osei';

-- Step 3: Verify
SELECT student_id, gpa FROM students WHERE last_name = 'Osei';
```

---

## 8. DELETE vs. TRUNCATE

### DELETE

```sql
-- Delete specific rows
DELETE FROM students WHERE student_id = 5;

-- Delete all rows (preserves table structure)
DELETE FROM students;
```

`DELETE` is logged row-by-row. It fires triggers. It can be rolled back inside a transaction. It respects foreign key constraints.

### TRUNCATE

```sql
TRUNCATE TABLE students;
```

`TRUNCATE` removes all rows instantly. It is minimally logged (much faster for large tables). It does **not** fire row-level triggers. On most platforms it resets auto-increment counters. It cannot be used when foreign keys reference the table (without disabling them first).

| Feature | DELETE | TRUNCATE |
|---------|--------|---------|
| Removes rows | Yes (selective or all) | All rows only |
| Logged per row | Yes | Minimally |
| Fires triggers | Yes | No (platform-dependent) |
| Resets identity/auto_increment | No | Yes (most platforms) |
| Can be rolled back | Yes | Platform-dependent |
| Respects foreign keys | Yes | Must disable FKs first |
| Speed on large tables | Slow | Fast |

---

## 9. ALTER TABLE

Modify an existing table structure:

```sql
-- Add a column
ALTER TABLE students ADD phone VARCHAR(20);

-- Drop a column (SQL Server and MySQL)
ALTER TABLE students DROP COLUMN phone;

-- Drop a column (PostgreSQL)
ALTER TABLE students DROP COLUMN phone;

-- Rename a column (SQL Server 2022+)
ALTER TABLE students RENAME COLUMN old_name TO new_name;

-- Rename a column (PostgreSQL)
ALTER TABLE students RENAME COLUMN old_name TO new_name;

-- Rename a column (MySQL)
ALTER TABLE students RENAME COLUMN old_name TO new_name;
-- or older syntax:
ALTER TABLE students CHANGE old_name new_name VARCHAR(50) NOT NULL;
```

---

## 10. DROP TABLE

```sql
-- Drop a single table
DROP TABLE students;

-- Drop only if it exists (avoid error if already gone)
DROP TABLE IF EXISTS students;   -- all three platforms

-- SQL Server classic pattern (before SQL Server 2016)
IF OBJECT_ID('students', 'U') IS NOT NULL DROP TABLE students;
```

---

## 11. Common Mistakes

1. **INSERT without naming columns** — if you add a column later, the query breaks
2. **UPDATE without WHERE** — updates every row
3. **DELETE without WHERE** — deletes every row
4. **Using `utf8` instead of `utf8mb4` in MySQL** — `utf8` in MySQL is not full UTF-8; it cannot store emoji or characters above U+FFFF
5. **Using `FLOAT` for monetary values** — floating-point imprecision causes wrong rounding; use `DECIMAL(10,2)`
6. **Forgetting NOT NULL on required columns** — allows NULL to be inserted silently
7. **SQL Server: forgetting `GO` between `CREATE DATABASE` and `USE`** — without `GO`, the batch hasn't been sent yet

---

## Key Vocabulary

| Term | Definition |
|------|-----------|
| DDL | Data Definition Language — `CREATE`, `ALTER`, `DROP` |
| DML | Data Manipulation Language — `INSERT`, `UPDATE`, `DELETE` |
| Constraint | A rule the database enforces on column values |
| AUTO_INCREMENT | MySQL property that automatically assigns the next integer |
| SERIAL | PostgreSQL shorthand for integer + auto-increment sequence |
| IDENTITY | SQL Server property for auto-incrementing integers |
| TRUNCATE | Removes all rows from a table with minimal logging |
| RETURNING | PostgreSQL clause that returns column values from INSERT/UPDATE/DELETE |
| SCOPE_IDENTITY() | SQL Server function returning the last identity value in the current scope |
| utf8mb4 | MySQL's true UTF-8 encoding (supports all Unicode characters) |
