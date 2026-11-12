# Module 09 — Guided Lab
## Schema Design & DDL

**Estimated time:** 90–120 minutes  
**Platforms covered:** Part A — MySQL 8.0 · Part B — PostgreSQL 16 · Part C — SQL Server 2022

---

## Prerequisites

- `university` database exists with `departments` table populated
- You have CREATE/DROP privileges in the database

---

## Part A — MySQL 8.0

```sql
USE university;
```

---

### A-01: Review the existing schema

Before creating new objects, understand what already exists:

```sql
SHOW TABLES;
SHOW CREATE TABLE departments\G
DESCRIBE students;
```

**Questions:**
- What data type is `department_id` in `departments`? What constraint enforces uniqueness on `department_name`?
- Does `students` have a named FOREIGN KEY constraint? What is the `ON DELETE` action?

---

### A-02: CREATE TABLE with AUTO_INCREMENT

```sql
DROP TABLE IF EXISTS lab_faculty;

CREATE TABLE lab_faculty (
    faculty_id  INT             NOT NULL AUTO_INCREMENT,
    first_name  VARCHAR(100)    NOT NULL,
    last_name   VARCHAR(100)    NOT NULL,
    email       VARCHAR(200)    NOT NULL,
    department_id INT           NOT NULL,
    hire_date   DATE            NOT NULL DEFAULT (CURDATE()),
    is_tenured  TINYINT(1)      NOT NULL DEFAULT 0,
    PRIMARY KEY (faculty_id),
    UNIQUE KEY uq_lab_faculty_email (email),
    CONSTRAINT chk_lab_hire_date CHECK (hire_date >= '1950-01-01'),
    CONSTRAINT fk_lab_faculty_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

SHOW CREATE TABLE lab_faculty\G
```

**Task:** Insert a faculty member named **Priya Sharma** in department_id 1, hired today, not yet tenured.

```sql
INSERT INTO lab_faculty (first_name, last_name, email, department_id)
VALUES ('Priya', 'Sharma', 'priya@example.com', 1);

SELECT LAST_INSERT_ID() AS new_faculty_id;
SELECT * FROM lab_faculty;
```

---

### A-03: Composite PK and FK

```sql
DROP TABLE IF EXISTS lab_course_faculty;

CREATE TABLE lab_course_faculty (
    faculty_id INT NOT NULL,
    course_id  INT NOT NULL,
    semester   VARCHAR(20) NOT NULL,
    PRIMARY KEY (faculty_id, course_id, semester),
    CONSTRAINT fk_lcf_faculty FOREIGN KEY (faculty_id)
        REFERENCES lab_faculty(faculty_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_lcf_course  FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE RESTRICT
);
```

**Question:** What happens to `lab_course_faculty` rows when the linked `lab_faculty` row is deleted? Why?

---

### A-04: Indexes

```sql
-- Index on FK (MySQL does not auto-index FK columns)
CREATE INDEX idx_lab_faculty_dept ON lab_faculty(department_id);

-- Composite index for the common search pattern
-- WHERE department_id = ? ORDER BY last_name
CREATE INDEX idx_lab_faculty_dept_name
    ON lab_faculty(department_id, last_name);

-- Check all indexes
SHOW INDEX FROM lab_faculty;
```

**Task:** Which index will MySQL use for `SELECT * FROM lab_faculty WHERE department_id = 1 ORDER BY last_name`? Run `EXPLAIN SELECT …` to verify.

```sql
EXPLAIN SELECT * FROM lab_faculty WHERE department_id = 1 ORDER BY last_name;
```

---

### A-05: ALTER TABLE

```sql
-- Add a column
ALTER TABLE lab_faculty ADD COLUMN office_room VARCHAR(20) AFTER email;

-- Set a default
ALTER TABLE lab_faculty MODIFY COLUMN office_room VARCHAR(20) DEFAULT 'TBA';

-- Rename it
ALTER TABLE lab_faculty RENAME COLUMN office_room TO office;

-- Add a constraint
ALTER TABLE lab_faculty ADD CONSTRAINT uq_lab_first_last UNIQUE (first_name, last_name);

-- Drop the constraint
ALTER TABLE lab_faculty DROP INDEX uq_lab_first_last;

DESCRIBE lab_faculty;
```

---

### A-06: Generated column

```sql
DROP TABLE IF EXISTS lab_products;

CREATE TABLE lab_products (
    product_id    INT              NOT NULL AUTO_INCREMENT,
    unit_price    DECIMAL(10, 2)   NOT NULL,
    tax_rate      DECIMAL(5, 4)    NOT NULL DEFAULT 0.13,
    price_with_tax DECIMAL(10, 2)  GENERATED ALWAYS AS
                  (ROUND(unit_price * (1 + tax_rate), 2)) STORED,
    PRIMARY KEY (product_id),
    CONSTRAINT chk_price CHECK (unit_price > 0)
);

INSERT INTO lab_products (unit_price, tax_rate) VALUES (49.99, 0.13), (100.00, 0.08);
SELECT * FROM lab_products;
```

**Question:** Try to UPDATE `price_with_tax` directly. What happens?

---

### A-07: Safe DROP order

```sql
-- Must drop child tables before parent
DROP TABLE IF EXISTS lab_course_faculty;
DROP TABLE IF EXISTS lab_products;
DROP TABLE IF EXISTS lab_faculty;
```

What would happen if you tried to DROP `lab_faculty` before `lab_course_faculty`?

---

## Part B — PostgreSQL 16

```sql
\c university
```

---

### B-01: CREATE TABLE with SERIAL and GENERATED IDENTITY

```sql
DROP TABLE IF EXISTS lab_faculty CASCADE;

-- SERIAL (legacy, widely used)
CREATE TABLE lab_faculty (
    faculty_id  SERIAL          PRIMARY KEY,
    first_name  VARCHAR(100)    NOT NULL,
    last_name   VARCHAR(100)    NOT NULL,
    email       VARCHAR(200)    NOT NULL UNIQUE,
    department_id INT           NOT NULL,
    hire_date   DATE            NOT NULL DEFAULT CURRENT_DATE,
    is_tenured  BOOLEAN         NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_hire_date CHECK (hire_date >= '1950-01-01'),
    CONSTRAINT fk_faculty_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO lab_faculty (first_name, last_name, email, department_id)
VALUES ('Priya', 'Sharma', 'priya@example.com', 1)
RETURNING faculty_id, first_name;
```

---

### B-02: Partial index

```sql
-- Index only un-tenured faculty for the HR eligibility report
CREATE INDEX idx_untenured_faculty
    ON lab_faculty(hire_date)
    WHERE is_tenured = FALSE;

EXPLAIN ANALYZE
SELECT * FROM lab_faculty WHERE is_tenured = FALSE AND hire_date < '2015-01-01';
-- Confirm: "Index Scan using idx_untenured_faculty"
```

---

### B-03: Covering index

```sql
-- Query: SELECT first_name, last_name, email FROM lab_faculty WHERE department_id = ?
CREATE INDEX idx_cov_faculty
    ON lab_faculty(department_id)
    INCLUDE (first_name, last_name, email);

EXPLAIN (ANALYZE, BUFFERS)
SELECT first_name, last_name, email
FROM   lab_faculty
WHERE  department_id = 1;
-- Should show "Index Only Scan" (no heap access)
```

---

### B-04: Transactional DDL — rollback a CREATE TABLE

```sql
BEGIN;

CREATE TABLE lab_txn_test (
    id   SERIAL  PRIMARY KEY,
    val  TEXT    NOT NULL
);

INSERT INTO lab_txn_test (val) VALUES ('row1'), ('row2');

-- Check what we have mid-transaction
SELECT * FROM lab_txn_test;

ROLLBACK;

-- Verify the table is gone
SELECT to_regclass('public.lab_txn_test');  -- returns NULL
```

**Key insight:** PostgreSQL rolled back the CREATE TABLE itself — the table no longer exists. This is impossible in MySQL.

---

### B-05: ALTER TABLE — change data type and add expression CHECK

```sql
-- Widen salary column (safe widening: NUMERIC(8,2) → NUMERIC(12,2))
ALTER TABLE lab_faculty
    ADD COLUMN salary NUMERIC(8, 2) DEFAULT 50000.00;

ALTER TABLE lab_faculty
    ALTER COLUMN salary TYPE NUMERIC(12, 2);

-- Add a check
ALTER TABLE lab_faculty
    ADD CONSTRAINT chk_salary CHECK (salary > 0);

-- Drop the check
ALTER TABLE lab_faculty
    DROP CONSTRAINT chk_salary;

-- Drop the column
ALTER TABLE lab_faculty
    DROP COLUMN salary;
```

---

## Part C — SQL Server 2022

```sql
USE university;
GO
```

---

### C-01: CREATE TABLE with IDENTITY and NVARCHAR

```sql
IF OBJECT_ID('dbo.lab_faculty', 'U') IS NOT NULL
    DROP TABLE dbo.lab_faculty;
GO

CREATE TABLE lab_faculty (
    faculty_id    INT             NOT NULL IDENTITY(1,1),
    first_name    NVARCHAR(100)   NOT NULL,
    last_name     NVARCHAR(100)   NOT NULL,
    email         VARCHAR(200)    NOT NULL,
    department_id INT             NOT NULL,
    hire_date     DATE            NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    is_tenured    BIT             NOT NULL DEFAULT 0,
    CONSTRAINT pk_lab_faculty       PRIMARY KEY (faculty_id),
    CONSTRAINT uq_lab_faculty_email UNIQUE (email),
    CONSTRAINT chk_lab_hire_date    CHECK (hire_date >= '1950-01-01'),
    CONSTRAINT fk_lab_faculty_dept  FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

INSERT INTO lab_faculty (first_name, last_name, email, department_id)
OUTPUT INSERTED.faculty_id, INSERTED.first_name
VALUES (N'Priya', N'Sharma', 'priya@example.com', 1);
GO
```

---

### C-02: SCOPE_IDENTITY() vs @@IDENTITY

```sql
INSERT INTO lab_faculty (first_name, last_name, email, department_id)
VALUES (N'Carlos', N'Rivera', 'carlos@example.com', 2);

SELECT
    SCOPE_IDENTITY() AS scope_identity,
    @@IDENTITY       AS at_identity;
-- Both return the same value here (no trigger)
-- Always use SCOPE_IDENTITY() in production code
GO
```

---

### C-03: Covered and filtered indexes

```sql
-- Covering index
CREATE NONCLUSTERED INDEX idx_cov_faculty
    ON lab_faculty(department_id, last_name)
    INCLUDE (first_name, email);
GO

-- Filtered index (SQL Server equivalent of partial)
CREATE NONCLUSTERED INDEX idx_untenured
    ON lab_faculty(hire_date)
    WHERE is_tenured = 0;
GO

-- View all indexes
SELECT
    i.name       AS index_name,
    i.type_desc,
    i.is_unique,
    i.filter_definition
FROM   sys.indexes i
WHERE  i.object_id = OBJECT_ID('lab_faculty')
  AND  i.name IS NOT NULL
ORDER BY i.name;
GO
```

---

### C-04: ALTER TABLE — rename column (sp_rename)

```sql
-- Add a column
ALTER TABLE lab_faculty ADD office_room NVARCHAR(20) NULL;
GO

-- Add default constraint
ALTER TABLE lab_faculty
    ADD CONSTRAINT df_office_room DEFAULT N'TBA' FOR office_room;
GO

-- Rename (sp_rename for columns)
EXEC sp_rename 'lab_faculty.office_room', 'office', 'COLUMN';
GO

-- Drop default constraint before dropping column
DECLARE @dfName NVARCHAR(200);
SELECT  @dfName = dc.name
FROM    sys.default_constraints dc
JOIN    sys.columns c
    ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
WHERE   dc.parent_object_id = OBJECT_ID('lab_faculty')
  AND   c.name = 'office';

IF @dfName IS NOT NULL
    EXEC ('ALTER TABLE lab_faculty DROP CONSTRAINT ' + @dfName);
GO

ALTER TABLE lab_faculty DROP COLUMN office;
GO
```

---

### C-05: Inspect constraints via system catalog

```sql
-- All constraints on lab_faculty
SELECT
    name             AS constraint_name,
    type_desc        AS constraint_type,
    definition       AS check_definition
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('lab_faculty')

UNION ALL

SELECT
    fk.name,
    'FOREIGN_KEY',
    OBJECT_NAME(fk.referenced_object_id)
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('lab_faculty');
GO
```

---

## Lab Wrap-Up

After completing all parts:

1. What is the MySQL equivalent of PostgreSQL's `SERIAL`?
2. Write the SQL to add a column `gpa_min DECIMAL(3,2) DEFAULT 0.00 CHECK (gpa_min BETWEEN 0 AND 4)` to `lab_faculty` on your preferred platform.
3. In which platform can you roll back a `CREATE TABLE` inside a transaction?
4. What is the difference between `SCOPE_IDENTITY()` and `@@IDENTITY` in SQL Server?
5. Write a covering index for the query: `SELECT email FROM lab_faculty WHERE department_id = ? AND is_tenured = 1`.
