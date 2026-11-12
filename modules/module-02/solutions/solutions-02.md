# Module 02 — Exercise Solutions
## Creating Tables and Inserting Data

> Try each exercise yourself before reading the solution.

---

## Exercise 1 — Create a database

**MySQL:**
```sql
CREATE DATABASE IF NOT EXISTS university
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE university;
```

**PostgreSQL:**
```sql
CREATE DATABASE university;
-- Then: \c university  (psql) or reconnect in pgAdmin
```

**SQL Server:**
```sql
CREATE DATABASE university;
GO
USE university;
GO
```

---

## Exercise 2 — Create departments table

**All platforms (adjust auto-increment syntax per platform):**

**MySQL:**
```sql
CREATE TABLE departments (
    department_id   INT              NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100)     NOT NULL,
    building        VARCHAR(50),
    budget          DECIMAL(12,2),
    CONSTRAINT pk_departments PRIMARY KEY (department_id)
) ENGINE=InnoDB CHARACTER SET utf8mb4;
```

**PostgreSQL:**
```sql
CREATE TABLE departments (
    department_id   INT              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(100)     NOT NULL,
    building        VARCHAR(50),
    budget          NUMERIC(12,2)
);
```

**SQL Server:**
```sql
CREATE TABLE departments (
    department_id   INT              NOT NULL IDENTITY(1,1),
    department_name NVARCHAR(100)    NOT NULL,
    building        NVARCHAR(50)     NULL,
    budget          DECIMAL(12,2)    NULL,
    CONSTRAINT pk_departments PRIMARY KEY (department_id)
);
```

---

## Exercise 3 — Insert departments

**MySQL / PostgreSQL (ANSI syntax):**
```sql
INSERT INTO departments (department_name, building, budget)
VALUES
    ('Computer Science',    'Tech Hall',      500000.00),
    ('Mathematics',         'Science Wing',   320000.00),
    ('Physics',             'Science Wing',   410000.00),
    ('English Literature',  'Arts Building',  180000.00),
    ('Data Engineering',    'Tech Hall',      650000.00);
```

**SQL Server (N prefix for Unicode):**
```sql
INSERT INTO departments (department_name, building, budget)
VALUES
    (N'Computer Science',    N'Tech Hall',     500000.00),
    (N'Mathematics',         N'Science Wing',  320000.00),
    (N'Physics',             N'Science Wing',  410000.00),
    (N'English Literature',  N'Arts Building', 180000.00),
    (N'Data Engineering',    N'Tech Hall',     650000.00);
```

---

## Exercise 4 — Verify inserts

```sql
SELECT * FROM departments ORDER BY department_name;
```

Expected: 5 rows, alphabetically ordered.

---

## Exercise 5 — professors table

**MySQL:**
```sql
CREATE TABLE professors (
    professor_id   INT            NOT NULL AUTO_INCREMENT,
    first_name     VARCHAR(50)    NOT NULL,
    last_name      VARCHAR(50)    NOT NULL,
    email          VARCHAR(100)   NOT NULL,
    department_id  INT            NOT NULL,
    salary         DECIMAL(10,2),
    hire_date      DATE           NOT NULL,
    CONSTRAINT pk_professors         PRIMARY KEY (professor_id),
    CONSTRAINT uq_professors_email   UNIQUE (email),
    CONSTRAINT fk_prof_department    FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB CHARACTER SET utf8mb4;
```

**PostgreSQL:**
```sql
CREATE TABLE professors (
    professor_id   INT            GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name     VARCHAR(50)    NOT NULL,
    last_name      VARCHAR(50)    NOT NULL,
    email          VARCHAR(100)   NOT NULL,
    department_id  INT            NOT NULL,
    salary         NUMERIC(10,2),
    hire_date      DATE           NOT NULL,
    CONSTRAINT uq_professors_email  UNIQUE (email),
    CONSTRAINT fk_prof_department   FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
);
```

**SQL Server:**
```sql
CREATE TABLE professors (
    professor_id   INT              NOT NULL IDENTITY(1,1),
    first_name     NVARCHAR(50)     NOT NULL,
    last_name      NVARCHAR(50)     NOT NULL,
    email          NVARCHAR(100)    NOT NULL,
    department_id  INT              NOT NULL,
    salary         DECIMAL(10,2)    NULL,
    hire_date      DATE             NOT NULL,
    CONSTRAINT pk_professors         PRIMARY KEY (professor_id),
    CONSTRAINT uq_professors_email   UNIQUE (email),
    CONSTRAINT fk_prof_department    FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
);
```

---

## Exercise 6 — Insert professors

```sql
-- Assuming department_id 1 = Computer Science, 3 = Physics, 4 = English
INSERT INTO professors (first_name, last_name, email, department_id, salary, hire_date)
VALUES
    ('Leila',   'Nkosi',    'leila.nkosi@university.edu',    1, 95000.00, '2018-08-15'),
    ('Marcus',  'Pereira',  'marcus.pereira@university.edu', 3, 88000.00, '2020-01-10'),
    ('Fatima',  'Yilmaz',   'fatima.yilmaz@university.edu',  4, 72000.00, '2015-09-01');
```

---

## Exercise 7 — Increase budget by 10%

```sql
UPDATE departments
SET    budget = budget * 1.10
WHERE  department_name = 'Computer Science';
```

New value: 500000.00 × 1.10 = 550000.00

---

## Exercise 8 — Set building for NULL rows

```sql
UPDATE departments
SET    building = 'Annex'
WHERE  building IS NULL;
```

---

## Exercise 9 — Delete a professor

```sql
-- Step 1: find the professor_id
SELECT professor_id, first_name, last_name
FROM   professors
WHERE  department_id = (
    SELECT department_id FROM departments WHERE department_name = 'English Literature'
);

-- Step 2: delete by ID (use the actual ID returned above)
DELETE FROM professors WHERE professor_id = 3;
```

---

## Exercise 10 — CHECK constraint for salary

```sql
-- MySQL / PostgreSQL
ALTER TABLE professors
ADD CONSTRAINT chk_salary CHECK (salary > 0);

-- SQL Server
ALTER TABLE professors
ADD CONSTRAINT chk_salary CHECK (salary > 0);
```

**Test with invalid value:**
```sql
INSERT INTO professors (first_name, last_name, email, department_id, salary, hire_date)
VALUES ('Bad', 'Salary', 'bad.salary@test.com', 1, -100, CURRENT_DATE);
```

Expected: error citing `chk_salary` constraint violation.

---

## Exercise 11 — DEFAULT values

```sql
-- MySQL
ALTER TABLE professors ADD COLUMN is_tenured BOOLEAN NOT NULL DEFAULT FALSE;

-- PostgreSQL
ALTER TABLE professors ADD COLUMN is_tenured BOOLEAN NOT NULL DEFAULT FALSE;

-- SQL Server
ALTER TABLE professors ADD is_tenured BIT NOT NULL DEFAULT 0;
```

**Test default applied:**
```sql
INSERT INTO professors (first_name, last_name, email, department_id, hire_date)
VALUES ('Default', 'Test', 'default.test@university.edu', 1, CURRENT_DATE);

SELECT professor_id, first_name, is_tenured FROM professors WHERE last_name = 'Test';
-- is_tenured should be FALSE / 0
```

---

## Exercise 12 — AUTO_INCREMENT / IDENTITY behavior

```sql
-- Insert and note the ID
INSERT INTO departments (department_name) VALUES ('Temporary Dept');
SELECT LAST_INSERT_ID();   -- MySQL (or SCOPE_IDENTITY() / currval(...))

-- Delete it
DELETE FROM departments WHERE department_name = 'Temporary Dept';

-- Insert another
INSERT INTO departments (department_name) VALUES ('Another Dept');
SELECT LAST_INSERT_ID();
```

**Expected behavior:** The new ID does **not** reuse the deleted ID. Auto-increment counters never go back. The gap remains.

**TRUNCATE behavior:**
```sql
TRUNCATE TABLE demo;      -- (use a demo table)
-- MySQL and SQL Server: counter resets to 1
-- PostgreSQL: use TRUNCATE TABLE demo RESTART IDENTITY; to reset
```

---

## Exercise 13 — INSERT … SELECT

```sql
CREATE TABLE high_budget_departments (
    department_name VARCHAR(100),
    building        VARCHAR(50),
    budget          DECIMAL(12,2)
);

INSERT INTO high_budget_departments (department_name, building, budget)
SELECT department_name, building, budget
FROM   departments
WHERE  budget > 400000;

SELECT * FROM high_budget_departments;
-- Expected: Computer Science (550000), Physics (410000), Data Engineering (650000)
```

---

## Exercise 14 — Capture new ID without a second query

**PostgreSQL:**
```sql
INSERT INTO departments (department_name, building)
VALUES ('Neuroscience', 'Medical Center')
RETURNING department_id;
```

**SQL Server:**
```sql
INSERT INTO departments (department_name, building)
OUTPUT INSERTED.department_id
VALUES (N'Neuroscience', N'Medical Center');
```

**MySQL:**
```sql
INSERT INTO departments (department_name, building)
VALUES ('Neuroscience', 'Medical Center');
SELECT LAST_INSERT_ID() AS new_id;
```

---

## Exercise 15 — Add and test founded_year

```sql
-- Add column
ALTER TABLE departments ADD COLUMN founded_year INT;   -- MySQL/PostgreSQL
-- SQL Server: ALTER TABLE departments ADD founded_year INT;

-- Update with plausible years
UPDATE departments SET founded_year = 1965 WHERE department_name = 'Computer Science';
UPDATE departments SET founded_year = 1890 WHERE department_name = 'Mathematics';
UPDATE departments SET founded_year = 1912 WHERE department_name = 'Physics';
UPDATE departments SET founded_year = 1875 WHERE department_name = 'English Literature';
UPDATE departments SET founded_year = 2015 WHERE department_name = 'Data Engineering';

-- Add CHECK constraint
ALTER TABLE departments
ADD CONSTRAINT chk_founded_year CHECK (founded_year > 1800);

-- Test with invalid year
INSERT INTO departments (department_name, founded_year)
VALUES ('Ancient History', 1700);
-- Expected: CHECK constraint violation error
```

---

## Challenge 16 — Referential integrity errors

**Non-existent parent:**
```sql
INSERT INTO professors (first_name, last_name, email, department_id, hire_date)
VALUES ('Ghost', 'Prof', 'ghost@test.com', 999, CURRENT_DATE);
```

Expected error (MySQL): `Cannot add or update a child row: a foreign key constraint fails`  
Expected error (PostgreSQL): `insert or update on table "professors" violates foreign key constraint`  
Expected error (SQL Server): `The INSERT statement conflicted with the FOREIGN KEY constraint`

**Delete parent with children:**
```sql
DELETE FROM departments WHERE department_name = 'Computer Science';
```
Expected: error (RESTRICT / NO ACTION) or cascade (CASCADE). Which one you get depends on what you specified in the FK definition.

---

## Challenge 17 — UPSERT

**MySQL:**
```sql
INSERT INTO departments (department_name, building, budget)
VALUES ('Computer Science', 'Tech Hall', 550000.00)
ON DUPLICATE KEY UPDATE
    building = VALUES(building),
    budget   = VALUES(budget);

INSERT INTO departments (department_name, building, budget)
VALUES ('Biology', 'Life Sciences', 300000.00)
ON DUPLICATE KEY UPDATE
    building = VALUES(building),
    budget   = VALUES(budget);
```
*(Requires a UNIQUE constraint on `department_name`)*

**PostgreSQL:**
```sql
INSERT INTO departments (department_name, building, budget)
VALUES ('Computer Science', 'Tech Hall', 550000.00)
ON CONFLICT (department_name) DO UPDATE
    SET building = EXCLUDED.building,
        budget   = EXCLUDED.budget;
```

**SQL Server:**
```sql
MERGE departments AS target
USING (VALUES (N'Computer Science', N'Tech Hall', 550000.00)) AS source (department_name, building, budget)
ON target.department_name = source.department_name
WHEN MATCHED    THEN UPDATE SET building = source.building, budget = source.budget
WHEN NOT MATCHED THEN INSERT (department_name, building, budget)
                      VALUES (source.department_name, source.building, source.budget);
```

---

## Challenge 18 — Audit columns

**MySQL:**
```sql
ALTER TABLE professors
ADD COLUMN created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                       ON UPDATE CURRENT_TIMESTAMP;
```

**PostgreSQL — trigger required:**
```sql
-- Add columns
ALTER TABLE professors
ADD COLUMN created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
ADD COLUMN updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Create trigger function
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger
CREATE TRIGGER trg_professors_updated_at
BEFORE UPDATE ON professors
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

**SQL Server — trigger required:**
```sql
ALTER TABLE professors
ADD created_at  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at  DATETIME2 NOT NULL DEFAULT SYSDATETIME();

CREATE TRIGGER trg_professors_updated_at
ON professors
AFTER UPDATE AS
BEGIN
    UPDATE professors
    SET    updated_at = SYSDATETIME()
    WHERE  professor_id IN (SELECT professor_id FROM INSERTED);
END;
```

**Key insight:** MySQL has built-in `ON UPDATE` for timestamps. PostgreSQL and SQL Server require a trigger to auto-update a timestamp column on UPDATE — a common pattern worth knowing.
