# Module 09 — Solutions
## Schema Design & DDL

> **Security note:** Instructor use only. Do not expose to learners before they attempt exercises.

---

## Beginner Solutions

### Exercise 01 — buildings table

```sql
-- MySQL 8.0
DROP TABLE IF EXISTS buildings;
CREATE TABLE buildings (
    building_id   INT          NOT NULL AUTO_INCREMENT,
    building_name VARCHAR(100) NOT NULL,
    floors        TINYINT      NOT NULL DEFAULT 1,
    opened_year   SMALLINT,
    PRIMARY KEY (building_id),
    UNIQUE KEY uq_building_name (building_name)
);

-- PostgreSQL 16
DROP TABLE IF EXISTS buildings CASCADE;
CREATE TABLE buildings (
    building_id   SERIAL         PRIMARY KEY,
    building_name VARCHAR(100)   NOT NULL UNIQUE,
    floors        SMALLINT       NOT NULL DEFAULT 1,
    opened_year   SMALLINT
);

-- SQL Server 2022
IF OBJECT_ID('dbo.buildings', 'U') IS NOT NULL DROP TABLE dbo.buildings;
CREATE TABLE buildings (
    building_id   INT            NOT NULL IDENTITY(1,1),
    building_name NVARCHAR(100)  NOT NULL,
    floors        TINYINT        NOT NULL DEFAULT 1,
    opened_year   SMALLINT,
    CONSTRAINT pk_buildings    PRIMARY KEY (building_id),
    CONSTRAINT uq_building_name UNIQUE (building_name)
);
```

---

### Exercise 02 — faculty table

```sql
-- MySQL 8.0
DROP TABLE IF EXISTS faculty;
CREATE TABLE faculty (
    faculty_id  INT          NOT NULL AUTO_INCREMENT,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(200) NOT NULL,
    hire_date   DATE         NOT NULL DEFAULT (CURDATE()),
    is_tenured  TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (faculty_id),
    UNIQUE KEY uq_faculty_email (email)
);

-- PostgreSQL 16
DROP TABLE IF EXISTS faculty CASCADE;
CREATE TABLE faculty (
    faculty_id  SERIAL        PRIMARY KEY,
    first_name  VARCHAR(100)  NOT NULL,
    last_name   VARCHAR(100)  NOT NULL,
    email       VARCHAR(200)  NOT NULL UNIQUE,
    hire_date   DATE          NOT NULL DEFAULT CURRENT_DATE,
    is_tenured  BOOLEAN       NOT NULL DEFAULT FALSE
);

-- SQL Server 2022
IF OBJECT_ID('dbo.faculty', 'U') IS NOT NULL DROP TABLE dbo.faculty;
CREATE TABLE faculty (
    faculty_id  INT           NOT NULL IDENTITY(1,1),
    first_name  NVARCHAR(100) NOT NULL,
    last_name   NVARCHAR(100) NOT NULL,
    email       VARCHAR(200)  NOT NULL,
    hire_date   DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    is_tenured  BIT           NOT NULL DEFAULT 0,
    CONSTRAINT pk_faculty       PRIMARY KEY (faculty_id),
    CONSTRAINT uq_faculty_email UNIQUE (email)
);
```

---

### Exercise 03 — research_groups table

```sql
-- MySQL 8.0
DROP TABLE IF EXISTS research_groups;
CREATE TABLE research_groups (
    group_id        INT          NOT NULL AUTO_INCREMENT,
    group_name      VARCHAR(150) NOT NULL,
    faculty_lead_id INT,
    founded_date    DATE,
    PRIMARY KEY (group_id),
    UNIQUE KEY uq_group_name (group_name),
    CONSTRAINT fk_rg_faculty FOREIGN KEY (faculty_lead_id)
        REFERENCES faculty(faculty_id)
        ON DELETE SET NULL
);

-- PostgreSQL 16
DROP TABLE IF EXISTS research_groups CASCADE;
CREATE TABLE research_groups (
    group_id        SERIAL        PRIMARY KEY,
    group_name      VARCHAR(150)  NOT NULL UNIQUE,
    faculty_lead_id INT,
    founded_date    DATE,
    CONSTRAINT fk_rg_faculty FOREIGN KEY (faculty_lead_id)
        REFERENCES faculty(faculty_id)
        ON DELETE SET NULL
);

-- SQL Server 2022
IF OBJECT_ID('dbo.research_groups', 'U') IS NOT NULL DROP TABLE dbo.research_groups;
CREATE TABLE research_groups (
    group_id        INT           NOT NULL IDENTITY(1,1),
    group_name      NVARCHAR(150) NOT NULL,
    faculty_lead_id INT,
    founded_date    DATE,
    CONSTRAINT pk_research_groups PRIMARY KEY (group_id),
    CONSTRAINT uq_group_name      UNIQUE (group_name),
    CONSTRAINT fk_rg_faculty      FOREIGN KEY (faculty_lead_id)
        REFERENCES faculty(faculty_id)
        ON DELETE SET NULL
);
```

---

### Exercise 04 — CHECK constraint on hire_date

```sql
-- MySQL 8.0
ALTER TABLE faculty
    ADD CONSTRAINT chk_hire_date CHECK (hire_date >= '1970-01-01');

-- PostgreSQL 16
ALTER TABLE faculty
    ADD CONSTRAINT chk_hire_date CHECK (hire_date >= '1970-01-01');

-- SQL Server 2022
ALTER TABLE faculty
    ADD CONSTRAINT chk_hire_date CHECK (hire_date >= '1970-01-01');
```

---

### Exercise 05 — Index on last_name

```sql
-- MySQL 8.0
CREATE INDEX idx_faculty_last_name ON faculty(last_name);

-- PostgreSQL 16
CREATE INDEX idx_faculty_last_name ON faculty(last_name);

-- SQL Server 2022
CREATE NONCLUSTERED INDEX idx_faculty_last_name ON faculty(last_name);
```

---

### Exercise 06 — information_schema query

```sql
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM   information_schema.columns
WHERE  table_name   = 'faculty'
  AND  table_schema = 'university'   -- MySQL/PG: schema name
  -- SQL Server: use 'dbo' in table_schema
ORDER BY ordinal_position;
```

---

### Exercise 07 — Add department_id FK

```sql
-- Step 1: Add the column
-- MySQL / PostgreSQL
ALTER TABLE faculty ADD COLUMN department_id INT NOT NULL;
-- SQL Server
ALTER TABLE faculty ADD department_id INT NOT NULL;

-- Step 2: Add FK constraint
-- MySQL 8.0
ALTER TABLE faculty
    ADD CONSTRAINT fk_faculty_dept FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
    ON DELETE RESTRICT;

-- PostgreSQL 16
ALTER TABLE faculty
    ADD CONSTRAINT fk_faculty_dept FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
    ON DELETE RESTRICT;

-- SQL Server 2022
ALTER TABLE faculty
    ADD CONSTRAINT fk_faculty_dept FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
    ON DELETE NO ACTION;
```

---

### Exercise 08 — Rename is_tenured to has_tenure

```sql
-- MySQL 8.0
ALTER TABLE faculty RENAME COLUMN is_tenured TO has_tenure;

-- PostgreSQL 16
ALTER TABLE faculty RENAME COLUMN is_tenured TO has_tenure;

-- SQL Server 2022
EXEC sp_rename 'faculty.is_tenured', 'has_tenure', 'COLUMN';
```

---

### Exercise 09 — Drop founded_date

```sql
-- MySQL / PostgreSQL
ALTER TABLE research_groups DROP COLUMN founded_date;

-- SQL Server: drop any default constraint first, then drop column
ALTER TABLE research_groups DROP COLUMN founded_date;
-- (If a DEFAULT constraint exists on founded_date, drop it first)
```

---

### Exercise 10 — DROP TABLE in correct order

```sql
-- MySQL / PostgreSQL
DROP TABLE IF EXISTS research_groups;  -- child (FK → faculty)
DROP TABLE IF EXISTS faculty;          -- parent

-- SQL Server
IF OBJECT_ID('dbo.research_groups', 'U') IS NOT NULL DROP TABLE dbo.research_groups;
IF OBJECT_ID('dbo.faculty',         'U') IS NOT NULL DROP TABLE dbo.faculty;
```

---

## Intermediate Solutions

### Exercise 11 — Normalize course_registrations

**Violations:**
- `student_name`, `student_email` → depend on `student_id` only (should be in `students`)
- `course_name`, `course_credits` → depend on `course_id` only (should be in `courses`)
- `professor_name` → depends on `professor_id` only (should be in `professors`)
- `grade_letter` → derived/computed from `grade` (should be a computed column or omitted)

**Normalized schema (3NF):**

```sql
CREATE TABLE students (
    student_id  INT          NOT NULL AUTO_INCREMENT,
    name        VARCHAR(200) NOT NULL,
    email       VARCHAR(200) NOT NULL UNIQUE,
    PRIMARY KEY (student_id)
);

CREATE TABLE professors (
    professor_id  INT          NOT NULL AUTO_INCREMENT,
    name          VARCHAR(200) NOT NULL,
    PRIMARY KEY (professor_id)
);

CREATE TABLE courses (
    course_id  INT          NOT NULL AUTO_INCREMENT,
    name       VARCHAR(200) NOT NULL,
    credits    TINYINT      NOT NULL,
    professor_id INT        NOT NULL,
    PRIMARY KEY (course_id),
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id)
);

CREATE TABLE course_registrations (
    registration_id   INT        NOT NULL AUTO_INCREMENT,
    student_id        INT        NOT NULL,
    course_id         INT        NOT NULL,
    registration_date DATE       NOT NULL,
    grade             DECIMAL(4,2),
    -- grade_letter is computed: do not store it
    PRIMARY KEY (registration_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id)  REFERENCES courses(course_id)
);
```

---

### Exercise 12 — teaching_assignments with composite unique

```sql
-- MySQL 8.0
CREATE TABLE teaching_assignments (
    assignment_id INT          NOT NULL AUTO_INCREMENT,
    faculty_id    INT          NOT NULL,
    course_id     INT          NOT NULL,
    semester      VARCHAR(20)  NOT NULL,
    classroom     VARCHAR(50),
    PRIMARY KEY (assignment_id),
    CONSTRAINT uq_faculty_course_semester UNIQUE (faculty_id, course_id, semester),
    CONSTRAINT fk_ta_faculty FOREIGN KEY (faculty_id)  REFERENCES faculty(faculty_id),
    CONSTRAINT fk_ta_course  FOREIGN KEY (course_id)   REFERENCES courses(course_id)
);
```

---

### Exercise 13 — Covering index

```sql
-- The query: SELECT first_name, last_name, email FROM faculty WHERE department_id = ? ORDER BY last_name

-- MySQL 8.0
CREATE INDEX idx_cov_faculty_dept
    ON faculty(department_id, last_name)
    -- include first_name, email not supported in MySQL covering syntax;
    -- but (department_id, last_name, first_name, email) as key columns works:
;
CREATE INDEX idx_cov_faculty_dept
    ON faculty(department_id, last_name, first_name, email);

-- PostgreSQL 16
CREATE INDEX idx_cov_faculty_dept
    ON faculty(department_id, last_name)
    INCLUDE (first_name, email);

-- SQL Server 2022
CREATE NONCLUSTERED INDEX idx_cov_faculty_dept
    ON faculty(department_id, last_name)
    INCLUDE (first_name, email);
```

**Column order reasoning:** `department_id` first because it is the equality filter; `last_name` second because it is the ORDER BY. The `INCLUDE` columns (PG/SS) are carried in the leaf node so the query never needs to touch the base table.

---

### Exercise 14 — Partial / filtered index

```sql
-- PostgreSQL 16
CREATE INDEX idx_inactive_old_faculty
    ON faculty(hire_date)
    WHERE is_tenured = FALSE;

-- SQL Server 2022
CREATE NONCLUSTERED INDEX idx_inactive_old_faculty
    ON faculty(hire_date)
    WHERE is_tenured = 0;
```

**When to prefer partial over full index:** When a small, frequently queried subset of rows has a different access pattern from the rest. Here, inactive un-tenured faculty are queried in a weekly report; the index is small and tightly focused, reducing storage and maintenance cost.

---

### Exercise 15 — Widen floors column

```sql
-- MySQL 8.0
ALTER TABLE buildings MODIFY COLUMN floors SMALLINT NOT NULL DEFAULT 1;

-- PostgreSQL 16
ALTER TABLE buildings ALTER COLUMN floors TYPE SMALLINT;

-- SQL Server 2022
ALTER TABLE buildings ALTER COLUMN floors SMALLINT NOT NULL;
-- Note: DEFAULT is a constraint in SQL Server — widening the column type does not affect the default.
```

---

## Challenge Solutions

### Exercise 16 — Library Management schema

```sql
-- MySQL 8.0 version

CREATE TABLE authors (
    author_id  INT          NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    PRIMARY KEY (author_id)
);

CREATE TABLE books (
    book_id     INT           NOT NULL AUTO_INCREMENT,
    title       VARCHAR(300)  NOT NULL,
    isbn        VARCHAR(20)   NOT NULL,
    published   DATE,
    PRIMARY KEY (book_id),
    UNIQUE KEY uq_isbn (isbn)
);

CREATE TABLE book_authors (
    book_id    INT NOT NULL,
    author_id  INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book   FOREIGN KEY (book_id)   REFERENCES books(book_id)   ON DELETE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE RESTRICT
);

CREATE TABLE copies (
    copy_id    INT          NOT NULL AUTO_INCREMENT,
    book_id    INT          NOT NULL,
    shelf_code VARCHAR(20)  NOT NULL,
    condition  VARCHAR(50)  DEFAULT 'Good',
    PRIMARY KEY (copy_id),
    CONSTRAINT fk_copy_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT
);
CREATE INDEX idx_copies_book ON copies(book_id);

CREATE TABLE members (
    member_id  INT          NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(200) NOT NULL,
    joined_on  DATE         NOT NULL DEFAULT (CURDATE()),
    PRIMARY KEY (member_id),
    UNIQUE KEY uq_member_email (email)
);

CREATE TABLE borrows (
    borrow_id   INT        NOT NULL AUTO_INCREMENT,
    copy_id     INT        NOT NULL,
    member_id   INT        NOT NULL,
    borrowed_on DATE       NOT NULL DEFAULT (CURDATE()),
    due_date    DATE       NOT NULL,
    returned_on DATE,
    PRIMARY KEY (borrow_id),
    CONSTRAINT fk_borrow_copy   FOREIGN KEY (copy_id)   REFERENCES copies(copy_id)   ON DELETE RESTRICT,
    CONSTRAINT fk_borrow_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    CONSTRAINT chk_due_date     CHECK (due_date > borrowed_on)
);
CREATE INDEX idx_borrows_copy   ON borrows(copy_id);
CREATE INDEX idx_borrows_member ON borrows(member_id);

CREATE TABLE fines (
    fine_id    INT           NOT NULL AUTO_INCREMENT,
    borrow_id  INT           NOT NULL,
    amount     DECIMAL(8,2)  NOT NULL,
    issued_on  DATE          NOT NULL DEFAULT (CURDATE()),
    paid_on    DATE,
    PRIMARY KEY (fine_id),
    CONSTRAINT fk_fine_borrow FOREIGN KEY (borrow_id) REFERENCES borrows(borrow_id) ON DELETE CASCADE,
    CONSTRAINT chk_fine_amount CHECK (amount > 0)
);
CREATE INDEX idx_fines_borrow ON fines(borrow_id);
```

---

### Exercise 17 — Normalization violations

**All violations in `student_courses`:**

| Column | Violation | Normal form |
|--------|-----------|-------------|
| `student_name`, `student_email` | Partial dependency on `student_id` alone (PK is composite `student_id, course_id`) | 2NF |
| `dept_id`, `dept_name` | Partial dependency on `student_id`; additionally `dept_name` transitively depends on `dept_id` | 2NF + 3NF |
| `course_name`, `credits` | Partial dependency on `course_id` alone | 2NF |
| `grade_letter` | Computed from `grade` — transitive dependency | 3NF |
| `professor_name` | Partial dependency on `professor_id` alone | 2NF |

**Normalized schema (3NF):**

```sql
CREATE TABLE departments   (dept_id INT PK, dept_name VARCHAR);
CREATE TABLE students      (student_id INT PK, student_name, student_email, dept_id FK);
CREATE TABLE professors    (professor_id INT PK, professor_name VARCHAR);
CREATE TABLE courses       (course_id INT PK, course_name, credits, professor_id FK);
CREATE TABLE student_courses (
    student_id INT, course_id INT,
    grade DECIMAL(4,2),
    -- grade_letter: compute in app or use a generated/computed column
    PRIMARY KEY (student_id, course_id),
    FK student_id → students, FK course_id → courses
);
```

---

### Exercise 18 — Platform comparison CREATE TABLE

```sql
-- MySQL 8.0
CREATE TABLE employees (
    employee_id   INT             NOT NULL AUTO_INCREMENT,
    full_name     VARCHAR(200)    NOT NULL,
    email         VARCHAR(200)    NOT NULL,
    salary        DECIMAL(10, 2)  NOT NULL,
    hire_date     DATE            NOT NULL DEFAULT (CURDATE()),
    is_active     TINYINT(1)      NOT NULL DEFAULT 1,
    department_id INT,
    PRIMARY KEY (employee_id),
    UNIQUE KEY uq_emp_email (email),
    CONSTRAINT chk_salary CHECK (salary > 0),
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE SET NULL
);

-- PostgreSQL 16
CREATE TABLE employees (
    employee_id   SERIAL          PRIMARY KEY,
    full_name     VARCHAR(200)    NOT NULL,
    email         VARCHAR(200)    NOT NULL UNIQUE,
    salary        NUMERIC(10, 2)  NOT NULL CHECK (salary > 0),
    hire_date     DATE            NOT NULL DEFAULT CURRENT_DATE,
    is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
    department_id INT,
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE SET NULL
);

-- SQL Server 2022
CREATE TABLE employees (
    employee_id   INT             NOT NULL IDENTITY(1,1),
    full_name     NVARCHAR(200)   NOT NULL,          -- NVARCHAR for Unicode names
    email         VARCHAR(200)    NOT NULL,           -- VARCHAR: email is ASCII-safe
    salary        DECIMAL(10, 2)  NOT NULL,
    hire_date     DATE            NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    is_active     BIT             NOT NULL DEFAULT 1, -- BIT, not BOOLEAN
    department_id INT,
    CONSTRAINT pk_employees   PRIMARY KEY (employee_id),
    CONSTRAINT uq_emp_email   UNIQUE      (email),
    CONSTRAINT chk_salary     CHECK       (salary > 0),
    CONSTRAINT fk_emp_dept    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE SET NULL
);
```

**Platform differences highlighted:**
1. Auto-increment: `AUTO_INCREMENT` / `SERIAL` / `IDENTITY(1,1)`
2. Unicode names: `VARCHAR(utf8mb4)` / `VARCHAR` (always Unicode) / `NVARCHAR`
3. Boolean: `TINYINT(1)` / `BOOLEAN` / `BIT`; literal: `1` / `TRUE` / `1`
4. Date default: `CURDATE()` / `CURRENT_DATE` / `CAST(GETDATE() AS DATE)`
5. Decimal type name: `DECIMAL` / `NUMERIC` / `DECIMAL`
6. Constraint syntax: MySQL inline or table-level; PG inline or named; SQL Server always named preferred

---

## Interview Answer Guide

### IQ-01 — 2NF vs 3NF
2NF removes **partial dependencies** — when a non-key column depends on only part of a composite PK. 3NF removes **transitive dependencies** — when a non-key column depends on another non-key column rather than the PK directly. Example of 3NF violation: `orders(order_id, customer_id, customer_city)` — `customer_city` depends on `customer_id`, not `order_id`.

### IQ-02 — DECIMAL vs FLOAT
FLOAT uses binary floating-point arithmetic. `0.1 + 0.2` in binary floating point is not exactly `0.3` — it's `0.30000000000000004`. For money, GPA, and any value where `0.1 + 0.2 = 0.3` must be exactly true, use `DECIMAL(p,s)` which stores digits in decimal and is exact within its precision.

### IQ-03 — ON DELETE CASCADE
`ON DELETE CASCADE` means: when the parent row is deleted, all matching child rows are automatically deleted. Appropriate: `order_items` when an `order` is deleted — the items have no meaning without the order. Dangerous: `students` ↔ `departments` — accidentally deleting a department would silently delete all students in it.

### IQ-04 — Leftmost prefix rule
Index on `(department_id, gpa, last_name)`:
- `WHERE department_id = 1` → **yes**, uses index
- `WHERE gpa > 3.5` → **no**, cannot use index (skips leading column)
- `WHERE department_id = 1 AND gpa > 3.5` → **yes**, uses index on both columns
- `WHERE last_name = 'Fischer'` → **no**, skips both leading columns

### IQ-05 — Clustered vs non-clustered (SQL Server)
A **clustered index** determines the physical order of rows on disk — there can be only one per table (SQL Server defaults to the PK). A **non-clustered index** is a separate B-Tree with pointers (row locators) back to the base table rows. PostgreSQL has no true clustered index in the SQL Server sense — `CLUSTER` physically reorders the heap once but it does not stay sorted; PostgreSQL's primary approach for clustering is table access patterns. BRIN and HASH indexes are alternatives in PostgreSQL.

### IQ-06 — Covering index
A covering index stores all columns needed to satisfy a query — both the WHERE/JOIN columns (key columns) and the SELECT columns (included columns). When a query is "covered," the database reads only the index pages and never touches the base table pages. This eliminates the "key lookup" or "RID lookup" operation and can be orders of magnitude faster on large tables.

### IQ-07 — VARCHAR vs NVARCHAR (SQL Server)
`VARCHAR` stores ASCII/ANSI text at 1 byte per character. `NVARCHAR` stores Unicode text at 2 bytes per character (UTF-16). Use `NVARCHAR` whenever the column might hold non-ASCII characters: names, addresses, free-text, anything user-generated from an international audience. Use `VARCHAR` for internal codes, emails (ASCII by convention), and ISO codes. String literals must be prefixed with `N` for NVARCHAR: `N'Amharic ሴ'` — without the N prefix, non-ASCII characters are silently corrupted.

### IQ-08 — PostgreSQL transactional DDL
PostgreSQL wraps DDL statements in its transaction manager the same way DML is. This means `CREATE TABLE`, `ALTER TABLE`, and `DROP TABLE` can all be rolled back if the transaction is rolled back. Practical advantages: a failed migration script can be rolled back atomically instead of leaving the schema in a half-changed state; schema migrations can be tested and rolled back in development without manual cleanup. MySQL auto-commits DDL immediately — a failed multi-step migration may leave partial changes that must be repaired manually.
