# Module 02 — Guided Lab
## Creating Tables and Inserting Data

**Estimated time:** 90 minutes  
**Difficulty:** Beginner  
**Prerequisite:** Module 01 lab completed; Docker containers running

---

## Lab Overview

In this lab you will build a small university database from scratch. By the end you will have:

- Created a database on each of the three platforms
- Created three related tables with proper data types and constraints
- Inserted synthetic student and course data
- Run UPDATE and DELETE statements safely
- Explored platform-specific features (RETURNING, OUTPUT, LAST_INSERT_ID)

Work through **Part A, B, or C** for your chosen track. Advanced learners: attempt all three and compare the syntax.

---

## Prerequisites Checklist

Before starting, confirm:

- [ ] `docker-compose ps` shows all containers as "healthy" or "running"
- [ ] You can connect to your track's database (see `docs/getting-started.md`)
- [ ] Module 02 `lecture-notes.md` is open in another window for reference

---

## Part A — MySQL 8.0

### Connection

**Docker exec (command line):**
```bash
docker exec -it sql-academy-mysql80 \
  mysql -u root -pAcademy2024! -h 127.0.0.1
```

**MySQL Workbench:** hostname `127.0.0.1`, port `3306`, user `root`, password `Academy2024!`

---

### Step A-1: Create the university database

```sql
-- Create database with full Unicode support
CREATE DATABASE IF NOT EXISTS university
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Switch to it
USE university;

-- Confirm
SELECT DATABASE() AS current_database;
```

Expected output:
```
+------------------+
| current_database |
+------------------+
| university       |
+------------------+
```

---

### Step A-2: Create the departments table

```sql
CREATE TABLE departments (
    department_id   INT              NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100)     NOT NULL,
    building        VARCHAR(50),
    budget          DECIMAL(12,2),
    CONSTRAINT pk_departments         PRIMARY KEY (department_id),
    CONSTRAINT uq_departments_name    UNIQUE (department_name)
) ENGINE=InnoDB CHARACTER SET utf8mb4;
```

**Inspect the table:**
```sql
DESCRIBE departments;
```

**Question:** What is the Key column value for `department_id`? For `department_name`?

---

### Step A-3: Create the students and enrollments tables

```sql
CREATE TABLE students (
    student_id   INT             NOT NULL AUTO_INCREMENT,
    first_name   VARCHAR(50)     NOT NULL,
    last_name    VARCHAR(50)     NOT NULL,
    email        VARCHAR(100)    NOT NULL,
    gpa          DECIMAL(3,2),
    enrolled_at  DATE            NOT NULL,
    is_active    BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_students         PRIMARY KEY (student_id),
    CONSTRAINT uq_students_email   UNIQUE (email),
    CONSTRAINT chk_students_gpa    CHECK (gpa BETWEEN 0.00 AND 4.00)
) ENGINE=InnoDB CHARACTER SET utf8mb4;

CREATE TABLE enrollments (
    enrollment_id INT        NOT NULL AUTO_INCREMENT,
    student_id    INT        NOT NULL,
    department_id INT        NOT NULL,
    enrolled_on   DATE       NOT NULL,
    CONSTRAINT pk_enrollments        PRIMARY KEY (enrollment_id),
    CONSTRAINT uq_enrollment         UNIQUE (student_id, department_id),
    CONSTRAINT fk_enroll_student     FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_department  FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB CHARACTER SET utf8mb4;
```

---

### Step A-4: Insert data

```sql
-- Insert departments (multi-row)
INSERT INTO departments (department_name, building, budget)
VALUES
    ('Computer Science',    'Tech Hall',      500000.00),
    ('Mathematics',         'Science Wing',   320000.00),
    ('Physics',             'Science Wing',   410000.00),
    ('Data Engineering',    'Tech Hall',      650000.00);

-- Check auto-assigned IDs
SELECT LAST_INSERT_ID() AS last_dept_id;

-- Insert students
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES
    ('Amara',   'Osei',    'amara.osei@example.com',    3.80, '2024-09-01'),
    ('Priya',   'Sharma',  'priya.sharma@example.com',  3.50, '2024-09-01'),
    ('Carlos',  'Mendez',  'carlos.mendez@example.com', 3.90, '2024-01-15'),
    ('Sofia',   'Eriksson','sofia.eriksson@example.com',3.70, '2023-09-01');

-- Insert enrollments
INSERT INTO enrollments (student_id, department_id, enrolled_on)
VALUES
    (1, 1, '2024-09-05'),
    (2, 1, '2024-09-05'),
    (3, 2, '2024-01-20'),
    (4, 3, '2024-09-05');
```

---

### Step A-5: Verify and query

```sql
-- Count rows in each table
SELECT 'departments' AS tbl, COUNT(*) AS rows FROM departments
UNION ALL
SELECT 'students',          COUNT(*) FROM students
UNION ALL
SELECT 'enrollments',       COUNT(*) FROM enrollments;

-- View students with their department
SELECT
    s.first_name, s.last_name, d.department_name, e.enrolled_on
FROM   students s
JOIN   enrollments e ON s.student_id = e.student_id
JOIN   departments d ON e.department_id = d.department_id
ORDER  BY s.last_name;
```

---

### Step A-6: Safe UPDATE

```sql
-- Step 1: SELECT before you UPDATE
SELECT department_id, department_name, budget
FROM   departments
WHERE  department_name = 'Computer Science';

-- Step 2: Update only that row
UPDATE departments
SET    budget = budget * 1.10
WHERE  department_name = 'Computer Science';

-- Step 3: Confirm the change
SELECT department_name, budget FROM departments;
```

**Safety habit:** Always run a matching SELECT before UPDATE or DELETE to confirm the WHERE clause targets the right rows.

---

### Step A-7: Referential integrity test

```sql
-- Try to delete a department that has enrollments
DELETE FROM departments WHERE department_name = 'Computer Science';
```

**Expected:** Error. Record the exact error message in your lab results file.

```sql
-- Now try to insert an enrollment for a non-existent student
INSERT INTO enrollments (student_id, department_id, enrolled_on)
VALUES (9999, 1, '2024-09-05');
```

**Expected:** Foreign key constraint error.

---

### Step A-8: AUTO_INCREMENT behavior

```sql
-- Insert and immediately capture the ID
INSERT INTO departments (department_name, building)
VALUES ('Neuroscience', 'Medical Center');

SELECT LAST_INSERT_ID() AS new_id;

-- Delete it
DELETE FROM departments WHERE department_name = 'Neuroscience';

-- Insert another
INSERT INTO departments (department_name) VALUES ('Astronomy');
SELECT LAST_INSERT_ID() AS new_id;
```

**Question:** Did the second INSERT reuse the deleted ID?

---

### Part A Deliverables

Create a file `exercises/lab-02-results-mysql.md` and record:
1. The error message from the referential integrity test (Step A-7)
2. The two auto-generated IDs from Step A-8 — did they skip?
3. The output of `DESCRIBE departments`

---

## Part B — PostgreSQL 16

### Connection

**psql (command line):**
```bash
docker exec -it sql-academy-postgres16 \
  psql -U postgres -h 127.0.0.1
```

**pgAdmin 4:** browser → `http://localhost:5050` → server `postgres` (host must be `postgres`, not `localhost`)

---

### Step B-1: Create the university database

```sql
-- Run while connected to 'postgres' database
CREATE DATABASE university;
```

**psql:** `\c university`  
**pgAdmin:** right-click *university* → Query Tool

```sql
-- Confirm
SELECT current_database() AS connected_to;
```

---

### Step B-2: Create the departments table

```sql
CREATE TABLE departments (
    department_id   INT              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(100)     NOT NULL,
    building        VARCHAR(50),
    budget          NUMERIC(12,2),
    CONSTRAINT uq_departments_name UNIQUE (department_name)
);
```

**Inspect the table (psql):**
```sql
\d departments
```

**Using INFORMATION_SCHEMA (works in all tools):**
```sql
SELECT column_name, data_type, is_nullable, column_default
FROM   information_schema.columns
WHERE  table_name = 'departments'
ORDER  BY ordinal_position;
```

---

### Step B-3: Create the students and enrollments tables

```sql
CREATE TABLE students (
    student_id   INT             GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name   VARCHAR(50)     NOT NULL,
    last_name    VARCHAR(50)     NOT NULL,
    email        VARCHAR(100)    NOT NULL,
    gpa          NUMERIC(3,2),
    enrolled_at  DATE            NOT NULL,
    is_active    BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_students_email UNIQUE (email),
    CONSTRAINT chk_students_gpa  CHECK (gpa BETWEEN 0.00 AND 4.00)
);

CREATE TABLE enrollments (
    enrollment_id INT       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id    INT       NOT NULL,
    department_id INT       NOT NULL,
    enrolled_on   DATE      NOT NULL,
    CONSTRAINT uq_enrollment         UNIQUE (student_id, department_id),
    CONSTRAINT fk_enroll_student     FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_department  FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
```

---

### Step B-4: Insert data with RETURNING

```sql
-- Insert departments — RETURNING shows generated IDs immediately
INSERT INTO departments (department_name, building, budget)
VALUES
    ('Computer Science',  'Tech Hall',    500000.00),
    ('Mathematics',       'Science Wing', 320000.00),
    ('Physics',           'Science Wing', 410000.00),
    ('Data Engineering',  'Tech Hall',    650000.00)
RETURNING department_id, department_name;

-- Insert students
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES
    ('Amara',   'Osei',    'amara.osei@example.com',    3.80, '2024-09-01'),
    ('Priya',   'Sharma',  'priya.sharma@example.com',  3.50, '2024-09-01'),
    ('Carlos',  'Mendez',  'carlos.mendez@example.com', 3.90, '2024-01-15'),
    ('Sofia',   'Eriksson','sofia.eriksson@example.com',3.70, '2023-09-01')
RETURNING student_id, first_name, last_name;
```

**Note:** With `RETURNING`, PostgreSQL returns the auto-generated IDs in the same statement — no second `SELECT` needed. This is atomic: even in a multi-row insert you get every generated ID.

---

### Step B-5: RETURNING on UPDATE and DELETE

```sql
-- UPDATE with RETURNING shows the new value
UPDATE students
SET    gpa = 3.95
WHERE  student_id = 1
RETURNING student_id, first_name, gpa;

-- INSERT then DELETE, using RETURNING to log what was removed
INSERT INTO departments (department_name) VALUES ('Temporary')
RETURNING department_id;

-- Use the returned ID here (replace 5 with the actual returned value)
DELETE FROM departments
WHERE  department_name = 'Temporary'
RETURNING department_id, department_name;
```

**Question:** How is RETURNING different from running a SELECT after the statement?

---

### Step B-6: Sequence inspection

```sql
-- PostgreSQL sequences are first-class objects
SELECT sequencename, last_value, increment_by, min_value, max_value
FROM   pg_sequences
WHERE  schemaname = 'public';

-- What's the current value for the students sequence?
SELECT currval(pg_get_serial_sequence('students', 'student_id'));
```

---

### Step B-7: Referential integrity and TRUNCATE

```sql
-- Test FK violation (insert enrollment with non-existent student)
INSERT INTO enrollments (student_id, department_id, enrolled_on)
VALUES (9999, 1, '2024-09-05');
-- Record the error message

-- TRUNCATE with RESTART IDENTITY
CREATE TEMP TABLE demo (
    id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    val TEXT
);
INSERT INTO demo (val) VALUES ('a'), ('b'), ('c');
SELECT * FROM demo;                               -- ids 1, 2, 3

TRUNCATE TABLE demo RESTART IDENTITY;

INSERT INTO demo (val) VALUES ('x');
SELECT * FROM demo;                               -- id restarts at 1
DROP TABLE demo;
```

---

### Part B Deliverables

Create `exercises/lab-02-results-postgresql.md` and record:
1. The RETURNING output from the departments INSERT (Step B-4)
2. The error message from the FK violation test (Step B-7)
3. Answer: how is `RETURNING` different from a follow-up SELECT?
4. The sequence name shown in `pg_sequences` for the students table

---

## Part C — SQL Server 2022

### Connection

**SSMS / Azure Data Studio:**  
Server: `localhost,1433` (comma, not colon)  
Login: `SA`, Password: `Academy2024!`

**Docker exec:**
```bash
docker exec -it sql-academy-sqlserver2022 \
  /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U SA -P 'Academy2024!' -No
```

---

### Step C-1: Create the university database

```sql
CREATE DATABASE university;
GO

USE university;
GO

-- Confirm
SELECT DB_NAME() AS current_database;
GO
```

---

### Step C-2: Create the departments table

```sql
CREATE TABLE departments (
    department_id   INT              NOT NULL IDENTITY(1,1),
    department_name NVARCHAR(100)    NOT NULL,
    building        NVARCHAR(50)     NULL,
    budget          DECIMAL(12,2)    NULL,
    CONSTRAINT pk_departments         PRIMARY KEY (department_id),
    CONSTRAINT uq_departments_name    UNIQUE (department_name)
);
GO

-- Inspect
EXEC sp_help 'departments';
GO
```

**Observe:** The `IDENTITY` column shows "Yes" in the Is_Identity column in the sp_help output.

---

### Step C-3: Create students and enrollments

```sql
CREATE TABLE students (
    student_id   INT             NOT NULL IDENTITY(1,1),
    first_name   NVARCHAR(50)    NOT NULL,
    last_name    NVARCHAR(50)    NOT NULL,
    email        NVARCHAR(100)   NOT NULL,
    gpa          DECIMAL(3,2)    NULL,
    enrolled_at  DATE            NOT NULL,
    is_active    BIT             NOT NULL CONSTRAINT df_students_active  DEFAULT 1,
    created_at   DATETIME2       NOT NULL CONSTRAINT df_students_created DEFAULT SYSDATETIME(),
    CONSTRAINT pk_students        PRIMARY KEY (student_id),
    CONSTRAINT uq_students_email  UNIQUE (email),
    CONSTRAINT chk_students_gpa   CHECK (gpa BETWEEN 0.00 AND 4.00)
);
GO

CREATE TABLE enrollments (
    enrollment_id  INT    NOT NULL IDENTITY(1,1),
    student_id     INT    NOT NULL,
    department_id  INT    NOT NULL,
    enrolled_on    DATE   NOT NULL,
    CONSTRAINT pk_enrollments         PRIMARY KEY (enrollment_id),
    CONSTRAINT uq_enrollment          UNIQUE (student_id, department_id),
    CONSTRAINT fk_enroll_student      FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_department   FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO
```

---

### Step C-4: Insert with OUTPUT

```sql
-- INSERT with OUTPUT — SQL Server's equivalent of PostgreSQL RETURNING
INSERT INTO departments (department_name, building, budget)
OUTPUT INSERTED.department_id, INSERTED.department_name
VALUES
    (N'Computer Science',  N'Tech Hall',    500000.00),
    (N'Mathematics',       N'Science Wing', 320000.00),
    (N'Physics',           N'Science Wing', 410000.00),
    (N'Data Engineering',  N'Tech Hall',    650000.00);
GO

-- Single-row insert + SCOPE_IDENTITY()
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
VALUES (N'Amara', N'Osei', N'amara.osei@example.com', 3.80, '2024-09-01');

SELECT SCOPE_IDENTITY() AS new_student_id;
GO

-- Multi-row insert with OUTPUT
INSERT INTO students (first_name, last_name, email, gpa, enrolled_at)
OUTPUT INSERTED.student_id, INSERTED.first_name, INSERTED.last_name
VALUES
    (N'Priya',   N'Sharma',   N'priya.sharma@example.com',   3.50, '2024-09-01'),
    (N'Carlos',  N'Mendez',   N'carlos.mendez@example.com',  3.90, '2024-01-15'),
    (N'Sofia',   N'Eriksson', N'sofia.eriksson@example.com', 3.70, '2023-09-01');
GO
```

---

### Step C-5: OUTPUT on UPDATE and DELETE

```sql
-- UPDATE with OUTPUT showing old and new values
UPDATE students
SET    gpa = 3.95
OUTPUT DELETED.gpa AS old_gpa, INSERTED.gpa AS new_gpa,
       INSERTED.first_name
WHERE  student_id = 1;
GO

-- DELETE with OUTPUT logs what was removed
INSERT INTO departments (department_name) VALUES (N'Temporary');
GO

DELETE FROM departments
OUTPUT DELETED.department_id, DELETED.department_name
WHERE  department_name = N'Temporary';
GO
```

**Key distinction:** SQL Server calls them `INSERTED` and `DELETED` (pseudo-tables) even on UPDATE — the `DELETED` pseudo-table holds the before-image, `INSERTED` holds the after-image.

---

### Step C-6: SCOPE_IDENTITY vs @@IDENTITY

```sql
-- Why SCOPE_IDENTITY() is preferred
-- (Demonstrate conceptually — no trigger needed to understand the rule)

-- SCOPE_IDENTITY() — returns the last identity in the CURRENT scope (batch/procedure)
INSERT INTO departments (department_name) VALUES (N'Scope Test');
SELECT SCOPE_IDENTITY()  AS scope_identity_result;   -- reliable
SELECT @@IDENTITY        AS at_at_identity_result;    -- same here, but risky with triggers

-- @@IDENTITY could return the identity from a trigger that fires on another table
-- SCOPE_IDENTITY() stays scoped to your current INSERT
-- Always prefer SCOPE_IDENTITY()

DELETE FROM departments WHERE department_name = N'Scope Test';
GO
```

---

### Step C-7: Referential integrity and IDENTITY reset

```sql
-- FK violation test
INSERT INTO enrollments (student_id, department_id, enrolled_on)
VALUES (9999, 1, '2024-09-05');
-- Record the error message
GO

-- IDENTITY reset behavior with TRUNCATE
CREATE TABLE #demo (
    id   INT IDENTITY(1,1) PRIMARY KEY,
    val  VARCHAR(10)
);
INSERT INTO #demo VALUES ('a'), ('b'), ('c');
SELECT * FROM #demo;             -- ids 1, 2, 3

TRUNCATE TABLE #demo;            -- resets IDENTITY counter

INSERT INTO #demo VALUES ('x');
SELECT * FROM #demo;             -- id = 1 again

DROP TABLE #demo;
GO
```

---

### Part C Deliverables

Create `exercises/lab-02-results-sqlserver.md` and record:
1. The OUTPUT result from the departments INSERT (Step C-4)
2. The error message from the FK violation test (Step C-7)
3. Answer: in one sentence, what is the difference between `SCOPE_IDENTITY()` and `@@IDENTITY`?
4. After TRUNCATE, what ID did the next INSERT get? What would `DELETE + INSERT` have given?

---

## Part D — Cross-Platform Comparison (all tracks)

If you completed two or three parts, fill in this comparison table in your results file.

| Feature | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Database creation syntax | | | |
| Auto-increment keyword | `AUTO_INCREMENT` | | `IDENTITY(1,1)` |
| Inspect table structure | `DESCRIBE` | | `sp_help` |
| Get last inserted ID | `LAST_INSERT_ID()` | | `SCOPE_IDENTITY()` |
| Return data from INSERT | (two-step) | `RETURNING` | `OUTPUT INSERTED.*` |
| Return data from DELETE | (two-step) | `RETURNING` | `OUTPUT DELETED.*` |
| Reset sequence on TRUNCATE | automatic | `RESTART IDENTITY` | automatic |
| Unicode string literal prefix | none needed | none needed | `N'...'` |

---

## Lab Submission

Create your results files inside the `exercises/` directory:
- `exercises/lab-02-results-mysql.md`
- `exercises/lab-02-results-postgresql.md`
- `exercises/lab-02-results-sqlserver.md`

Each file should contain the deliverables listed in the relevant Part section above.

**When complete:** Take Quiz 02 (`assessments/quiz-02.md`)
