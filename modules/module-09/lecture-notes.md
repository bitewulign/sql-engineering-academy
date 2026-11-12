# Module 09 — Lecture Notes
## Schema Design & DDL

---

## 1. What Is DDL?

**DDL (Data Definition Language)** defines the structure that holds data, rather than the data itself.

| Statement | Action |
|-----------|--------|
| `CREATE TABLE` | Define a new table |
| `ALTER TABLE` | Add, modify, or drop columns and constraints |
| `DROP TABLE` | Remove a table and all its rows permanently |
| `CREATE INDEX` | Add an index to speed up queries |
| `DROP INDEX` | Remove an index |
| `TRUNCATE` | Often grouped here — removes all rows, resets structure |

DDL statements in most platforms **auto-commit**: they cannot be rolled back in MySQL or SQL Server outside certain conditions. PostgreSQL is the exception — DDL is fully transactional there.

---

## 2. Normalization

Normalization is the process of organizing table structure to eliminate redundancy and protect data integrity. Each normal form builds on the previous one.

### First Normal Form (1NF)

A table is in 1NF when:
- Every column holds **atomic** (indivisible) values
- No repeating groups or arrays in a single column
- Each row is uniquely identifiable (a PK exists)

**Violation:**
```
students(student_id, name, courses)
1, 'Amara', 'Math, Physics, CS'
```

**Fix:** Create a separate `enrollments` table linking `student_id` to `course_id`.

---

### Second Normal Form (2NF)

A table is in 2NF when:
- It is in 1NF
- Every non-key column depends on the **whole** primary key (no partial dependencies)

This only applies to tables with **composite primary keys**.

**Violation:**
```
order_detail(order_id, product_id, product_name, quantity)
-- product_name depends on product_id alone, not on (order_id, product_id)
```

**Fix:**
```
products(product_id PK, product_name)
order_detail(order_id, product_id, quantity)  -- composite PK
```

---

### Third Normal Form (3NF)

A table is in 3NF when:
- It is in 2NF
- No non-key column depends on another non-key column (no transitive dependencies)

**Violation:**
```
students(student_id, dept_id, dept_name, dept_building)
-- dept_name and dept_building depend on dept_id, not student_id
```

**Fix:**
```
departments(dept_id PK, dept_name, dept_building)
students(student_id PK, dept_id FK, gpa, …)
```

> The `university` database we have been using is already in 3NF. This section explains *why* it was designed that way.

---

## 3. Data Types

Choosing the right data type enforces a category of data integrity at the storage level.

### Integer types

```sql
-- MySQL 8.0
TINYINT    -- 1 byte,  -128 to 127
SMALLINT   -- 2 bytes, -32,768 to 32,767
INT        -- 4 bytes, -2.1B to 2.1B
BIGINT     -- 8 bytes, very large counts

-- PostgreSQL 16 equivalents
SMALLINT / INT2
INTEGER  / INT4
BIGINT   / INT8

-- SQL Server 2022 equivalents
TINYINT  (0–255 only, unsigned)
SMALLINT
INT
BIGINT
```

### Character types

```sql
-- Fixed length (pads with spaces)
CHAR(n)

-- Variable length (stores only used bytes)
VARCHAR(n)

-- SQL Server: prefix N for Unicode literals
NVARCHAR(n)   -- stores UTF-16, 2 bytes per char
-- Always use NVARCHAR for user-generated text in SQL Server
```

### Decimal / Numeric

```sql
DECIMAL(10, 2)   -- up to 10 digits total, 2 after decimal point
NUMERIC(10, 2)   -- equivalent to DECIMAL in all three platforms
-- Use for money, GPA, measurements that must be exact
-- Never use FLOAT/DOUBLE for money — floating-point rounding errors
```

### Date and time

```sql
-- MySQL 8.0
DATE          -- 'YYYY-MM-DD'
TIME          -- 'HH:MM:SS'
DATETIME      -- 'YYYY-MM-DD HH:MM:SS' (no time zone)
TIMESTAMP     -- auto-converts to UTC on storage

-- PostgreSQL 16
DATE
TIME
TIMESTAMP                 -- no time zone
TIMESTAMPTZ               -- with time zone (recommended)

-- SQL Server 2022
DATE
TIME
DATETIME2(7)              -- high precision, no time zone
DATETIMEOFFSET            -- with time zone
```

---

## 4. CREATE TABLE

```sql
-- MySQL 8.0
CREATE TABLE departments (
    department_id   INT             NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100)    NOT NULL,
    building        VARCHAR(50),
    budget          DECIMAL(12, 2)  DEFAULT 0.00,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (department_id),
    UNIQUE KEY uq_dept_name (department_name)
);

-- PostgreSQL 16
CREATE TABLE departments (
    department_id   SERIAL          PRIMARY KEY,
    department_name VARCHAR(100)    NOT NULL UNIQUE,
    building        VARCHAR(50),
    budget          NUMERIC(12, 2)  DEFAULT 0.00,
    created_at      TIMESTAMPTZ     DEFAULT NOW()
);

-- SQL Server 2022
CREATE TABLE departments (
    department_id   INT             NOT NULL IDENTITY(1,1),
    department_name NVARCHAR(100)   NOT NULL,
    building        NVARCHAR(50),
    budget          DECIMAL(12, 2)  DEFAULT 0.00,
    created_at      DATETIME2       DEFAULT GETDATE(),
    CONSTRAINT pk_departments PRIMARY KEY (department_id),
    CONSTRAINT uq_dept_name   UNIQUE      (department_name)
);
```

---

## 5. PRIMARY KEY

```sql
-- Single-column PK (all platforms)
CREATE TABLE students (
    student_id  INT  NOT NULL AUTO_INCREMENT,
    …
    PRIMARY KEY (student_id)
);

-- Composite PK (all platforms)
CREATE TABLE enrollments (
    student_id  INT  NOT NULL,
    course_id   INT  NOT NULL,
    grade       DECIMAL(4, 2),
    PRIMARY KEY (student_id, course_id)
);
```

**Rules:**
- A PK column is implicitly NOT NULL
- A PK automatically creates a unique clustered index (SQL Server) or unique index (MySQL/PG)
- A table can have only one PRIMARY KEY

---

## 6. FOREIGN KEY

```sql
-- MySQL 8.0 / PostgreSQL 16
CREATE TABLE students (
    student_id    INT          NOT NULL AUTO_INCREMENT,
    department_id INT          NOT NULL,
    …
    PRIMARY KEY (student_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- SQL Server 2022
CREATE TABLE students (
    student_id    INT  NOT NULL IDENTITY(1,1),
    department_id INT  NOT NULL,
    …
    CONSTRAINT pk_students   PRIMARY KEY (student_id),
    CONSTRAINT fk_students_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
```

### Referential actions

| Action | Meaning |
|--------|---------|
| `RESTRICT` / `NO ACTION` | Block the parent delete/update if children exist |
| `CASCADE` | Propagate delete/update to children |
| `SET NULL` | Set the FK column to NULL in children |
| `SET DEFAULT` | Set the FK column to its default value |

---

## 7. UNIQUE Constraint

```sql
-- Column-level
email VARCHAR(200) NOT NULL UNIQUE

-- Table-level (can span multiple columns)
CONSTRAINT uq_first_last UNIQUE (first_name, last_name)

-- Named constraint (preferred — easier to drop later)
-- MySQL 8.0
ALTER TABLE students ADD CONSTRAINT uq_email UNIQUE (email);

-- PostgreSQL 16
ALTER TABLE students ADD CONSTRAINT uq_email UNIQUE (email);

-- SQL Server 2022
ALTER TABLE students ADD CONSTRAINT uq_email UNIQUE (email);
```

A UNIQUE constraint automatically creates an index.

---

## 8. NOT NULL and DEFAULT

```sql
-- NOT NULL: reject any INSERT/UPDATE that would leave this column empty
first_name VARCHAR(100) NOT NULL

-- DEFAULT: use this value when none is provided
enrolled_at DATE        DEFAULT CURRENT_DATE   -- MySQL/PG
enrolled_at DATE        DEFAULT GETDATE()      -- SQL Server
is_active   TINYINT(1)  DEFAULT 1              -- MySQL
is_active   BOOLEAN     DEFAULT TRUE           -- PostgreSQL
is_active   BIT         DEFAULT 1              -- SQL Server

-- Combined
gpa         DECIMAL(3,2) NOT NULL DEFAULT 0.00
```

---

## 9. CHECK Constraint

```sql
-- MySQL 8.0 (enforced from MySQL 8.0.16+)
CREATE TABLE students (
    …
    gpa DECIMAL(3, 2) NOT NULL,
    CONSTRAINT chk_gpa CHECK (gpa BETWEEN 0.00 AND 4.00)
);

-- PostgreSQL 16
CREATE TABLE students (
    …
    gpa NUMERIC(3, 2) NOT NULL CHECK (gpa BETWEEN 0.00 AND 4.00),
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%')
);

-- SQL Server 2022
CREATE TABLE students (
    …
    gpa DECIMAL(3, 2) NOT NULL,
    CONSTRAINT chk_gpa CHECK (gpa BETWEEN 0.00 AND 4.00)
);
```

> CHECK constraints enforce business rules at the database level — no application code needed.

---

## 10. Indexes

### Why indexes exist

Without an index, every query scans every row (full table scan). An index is a sorted data structure (B-Tree by default) the query planner uses to jump directly to the right rows.

```sql
-- Full table scan (no index)
SELECT * FROM students WHERE email = 'priya@example.com';
-- scans all 10,000 rows

-- After adding an index on email
CREATE INDEX idx_students_email ON students(email);
-- planner uses the index: O(log n) lookup
```

### Creating indexes

```sql
-- MySQL 8.0
CREATE INDEX idx_students_dept  ON students(department_id);
CREATE UNIQUE INDEX uq_students_email ON students(email);

-- Composite index (column order matters!)
CREATE INDEX idx_students_dept_gpa ON students(department_id, gpa DESC);

-- PostgreSQL 16
CREATE INDEX idx_students_dept ON students(department_id);

-- Partial index (index only active students)
CREATE INDEX idx_active_students
    ON students(department_id)
    WHERE is_active = TRUE;

-- Covering index (include extra columns to avoid table lookup)
CREATE INDEX idx_cov_students
    ON students(department_id)
    INCLUDE (first_name, gpa);  -- available in PG 11+

-- SQL Server 2022
CREATE NONCLUSTERED INDEX idx_students_dept
    ON students(department_id)
    INCLUDE (first_name, gpa);  -- covering index

-- Filtered index (SQL Server equivalent of partial)
CREATE INDEX idx_active_students
    ON students(department_id)
    WHERE is_active = 1;
```

### Index column order rule

For a composite index `(a, b, c)`:
- Queries filtering on `a` → can use the index
- Queries filtering on `a, b` → can use the index
- Queries filtering on `b` alone → **cannot** use the index (leftmost prefix rule)

---

## 11. ALTER TABLE

```sql
-- Add a column
-- MySQL / PostgreSQL / SQL Server
ALTER TABLE students ADD COLUMN phone VARCHAR(20);         -- MySQL/PG
ALTER TABLE students ADD              phone NVARCHAR(20);  -- SQL Server

-- Add a constraint
ALTER TABLE students ADD CONSTRAINT chk_gpa CHECK (gpa BETWEEN 0.00 AND 4.00);

-- Drop a column
-- MySQL / PostgreSQL
ALTER TABLE students DROP COLUMN phone;
-- SQL Server
ALTER TABLE students DROP COLUMN phone;

-- Rename a column
-- MySQL 8.0
ALTER TABLE students RENAME COLUMN old_name TO new_name;
-- PostgreSQL 16
ALTER TABLE students RENAME COLUMN old_name TO new_name;
-- SQL Server 2022
EXEC sp_rename 'students.old_name', 'new_name', 'COLUMN';

-- Change data type
-- MySQL 8.0
ALTER TABLE students MODIFY COLUMN gpa DECIMAL(4, 2);
-- PostgreSQL 16
ALTER TABLE students ALTER COLUMN gpa TYPE NUMERIC(4, 2);
-- SQL Server 2022
ALTER TABLE students ALTER COLUMN gpa DECIMAL(4, 2);

-- Drop a named constraint
ALTER TABLE students DROP CONSTRAINT chk_gpa;             -- MySQL/PG/SS
-- MySQL also supports:
ALTER TABLE students DROP CHECK chk_gpa;
```

---

## 12. DROP TABLE

```sql
-- Drop a table (and all its rows and indexes)
DROP TABLE students;

-- Safe drop: only drop if the table exists
DROP TABLE IF EXISTS students_staging;           -- MySQL / PostgreSQL
IF OBJECT_ID('students_staging', 'U') IS NOT NULL
    DROP TABLE students_staging;                 -- SQL Server

-- Cannot drop a table that is referenced by a FK
-- Must drop or disable the FK first
ALTER TABLE enrollments DROP FOREIGN KEY fk_enroll_student;  -- MySQL
ALTER TABLE enrollments DROP CONSTRAINT fk_enroll_student;   -- PG/SS
```

---

## 13. Auto-Increment / Identity Columns

```sql
-- MySQL 8.0: AUTO_INCREMENT
CREATE TABLE t (id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id));
INSERT INTO t (name) VALUES ('row1');
SELECT LAST_INSERT_ID();  -- returns the generated id

-- PostgreSQL 16: SERIAL (legacy) or GENERATED ALWAYS AS IDENTITY (modern)
CREATE TABLE t (id SERIAL PRIMARY KEY, name TEXT);
-- SERIAL is shorthand for: id INT DEFAULT nextval('t_id_seq')

CREATE TABLE t (
    id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT
);
-- RETURNING to get the generated value:
INSERT INTO t (name) VALUES ('row1') RETURNING id;

-- SQL Server 2022: IDENTITY(seed, increment)
CREATE TABLE t (id INT IDENTITY(1,1) NOT NULL, name NVARCHAR(100));
INSERT INTO t (name) VALUES (N'row1');
SELECT SCOPE_IDENTITY();  -- returns the generated id in current scope
-- @@IDENTITY is session-wide; SCOPE_IDENTITY() is safer
```

---

## 14. Common DDL Mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Using FLOAT for money | Rounding errors (0.1 + 0.2 ≠ 0.3) | Use DECIMAL(p,s) |
| No index on FK columns | Slow JOIN and DELETE | Add index on every FK column |
| Over-indexing | Slower INSERT/UPDATE/DELETE | Index only queried columns |
| VARCHAR(255) everywhere | Misleads documentation | Size to actual business data |
| Dropping FK before parent table | Error if children exist | Drop children or FK first |
| SQL Server VARCHAR without N prefix | Mojibake on Unicode data | Always use NVARCHAR for user text |
| CHECK on MySQL < 8.0.16 | Silently ignored | Upgrade or enforce in app layer |
