# Module 03 — Guided Lab
## Querying Data: SELECT, WHERE, ORDER BY

**Estimated time:** 75 minutes  
**Difficulty:** Beginner  
**Prerequisite:** Module 02 lab completed; university database populated with students, departments, and enrollments

---

## Lab Overview

In this lab you will write progressively more complex queries against the `university` database. You will practice filtering, sorting, pagination, NULL handling, and the CASE expression — all core SELECT skills used every day in real database work.

Work through **your track's part** (A, B, or C). Advanced learners: attempt all three to compare platform-specific syntax.

---

## Prerequisites Checklist

- [ ] `docker-compose ps` shows all containers healthy
- [ ] `university` database exists and contains the Module 02 data
- [ ] At least 4 students and 4 departments are present (run Module 02 code if needed)
- [ ] `lecture-notes.md` open for reference

---

## Part A — MySQL 8.0

### Connection
```bash
docker exec -it sql-academy-mysql80 mysql -u root -pAcademy2024! -h 127.0.0.1
```
Then: `USE university;`

---

### Step A-1: Warm-up queries

Run each query and note how many rows are returned.

```sql
-- How many students are there?
SELECT COUNT(*) AS total_students FROM students;

-- How many departments?
SELECT COUNT(*) AS total_departments FROM departments;

-- How many enrollments?
SELECT COUNT(*) AS total_enrollments FROM enrollments;
```

Record the counts in your results file.

---

### Step A-2: SELECT specific columns with alias

```sql
SELECT
    student_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    gpa AS grade_point_average
FROM   students
ORDER BY last_name ASC;
```

**Question:** What is the alias for `gpa` in the output? Can you use that alias in the WHERE clause? Try it and record what happens.

```sql
-- Try using the alias in WHERE
SELECT first_name, gpa AS grade FROM students WHERE grade > 3.5;
```

---

### Step A-3: WHERE with comparison operators

```sql
-- Students with GPA above 3.70
SELECT first_name, last_name, gpa
FROM   students
WHERE  gpa > 3.70
ORDER BY gpa DESC;

-- Active students only
SELECT first_name, last_name, is_active
FROM   students
WHERE  is_active = 1;

-- Students enrolled in 2024
SELECT first_name, enrolled_at
FROM   students
WHERE  enrolled_at >= '2024-01-01'
  AND  enrolled_at <  '2025-01-01'
ORDER BY enrolled_at;
```

---

### Step A-4: BETWEEN, IN, LIKE

```sql
-- GPA in the 3.50–3.80 range
SELECT first_name, gpa FROM students WHERE gpa BETWEEN 3.50 AND 3.80;

-- Specific departments
SELECT department_name, budget
FROM   departments
WHERE  department_name IN ('Computer Science', 'Physics');

-- Last names containing 'a' (case-insensitive in MySQL)
SELECT first_name, last_name FROM students WHERE last_name LIKE '%a%';

-- Email pattern
SELECT first_name, email FROM students WHERE email LIKE '%@example.com';
```

---

### Step A-5: NULL handling

```sql
-- Insert a student without a phone
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Test', 'NoPhone', 'test.nophone@example.com', '2024-09-01');

-- Students with no phone
SELECT first_name, last_name, phone FROM students WHERE phone IS NULL;

-- Students with a phone
SELECT first_name, last_name, phone FROM students WHERE phone IS NOT NULL;

-- COALESCE to display a default
SELECT
    first_name,
    COALESCE(phone, 'Not provided') AS phone_display
FROM students;

-- Clean up
DELETE FROM students WHERE email = 'test.nophone@example.com';
```

**Record:** How many students had NULL phone numbers?

---

### Step A-6: ORDER BY and LIMIT

```sql
-- Top 3 students by GPA
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3;

-- Departments sorted by budget, lowest first
SELECT department_name, budget
FROM   departments
ORDER BY budget ASC;

-- Students ordered by enrollment date, newest first; second page (rows 4-6)
SELECT first_name, enrolled_at
FROM   students
ORDER BY enrolled_at DESC
LIMIT 3 OFFSET 3;
```

---

### Step A-7: CASE WHEN

```sql
SELECT
    first_name,
    last_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.00 THEN 'Merit'
        WHEN gpa >= 2.00 THEN 'Pass'
        ELSE 'At Risk'
    END AS academic_standing
FROM   students
ORDER BY gpa DESC;
```

**Experiment:** Change the threshold for 'Distinction' to 3.90 and re-run. What changes?

---

### Step A-8: Putting it together

Write a query (without looking at solutions) that returns:
- Full name as a single column
- GPA
- Academic standing (Distinction / Merit / Pass)
- Only active students
- Only those with GPA ≥ 3.00
- Sorted by GPA descending
- Maximum 5 rows

```sql
-- Your query here
```

---

### Part A Deliverables

Create `exercises/lab-03-results-mysql.md` and record:
1. Row counts from Step A-1
2. Result of trying to use an alias in WHERE (Step A-2)
3. How many students had NULL phone numbers (Step A-5)
4. Your own CASE + filter query from Step A-8

---

## Part B — PostgreSQL 16

### Connection
```bash
docker exec -it sql-academy-postgres16 psql -U postgres -h 127.0.0.1 -d university
```

---

### Step B-1: Warm-up

```sql
SELECT COUNT(*) AS total_students FROM students;
SELECT COUNT(*) AS total_departments FROM departments;
SELECT COUNT(*) AS total_enrollments FROM enrollments;
```

---

### Step B-2: PostgreSQL string concatenation

```sql
-- || operator
SELECT
    student_id,
    first_name || ' ' || last_name AS full_name,
    email,
    gpa AS grade_point_average
FROM   students
ORDER BY last_name;

-- Compare: what happens with NULL in ||?
SELECT 'Hello' || NULL AS concat_result;  -- returns NULL

-- CONCAT() is NULL-safe:
SELECT CONCAT('Hello', NULL, ' World') AS concat_result;  -- returns 'Hello World'
```

**Question:** Which concatenation method should you use in production queries involving nullable columns?

---

### Step B-3: ILIKE (case-insensitive LIKE)

```sql
-- Case-sensitive LIKE
SELECT first_name, last_name FROM students WHERE last_name LIKE 's%';  -- 0 rows if names start with capital S

-- Case-insensitive ILIKE
SELECT first_name, last_name FROM students WHERE last_name ILIKE 's%';  -- matches Sharma, etc.

-- Pattern: contains 'a' anywhere (case-insensitive)
SELECT first_name, last_name FROM students WHERE last_name ILIKE '%a%';
```

---

### Step B-4: NULL and IS NOT DISTINCT FROM

```sql
-- Insert a student without a phone
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Test', 'NoPhone', 'test.nophone@example.com', '2024-09-01');

-- IS NULL
SELECT first_name, phone FROM students WHERE phone IS NULL;

-- PostgreSQL's NULL-safe equality
SELECT 1 WHERE NULL IS NOT DISTINCT FROM NULL;  -- returns 1 (TRUE)
SELECT 1 WHERE NULL = NULL;                      -- returns nothing (UNKNOWN)

-- COALESCE
SELECT
    first_name,
    COALESCE(phone, 'Not provided') AS phone_display
FROM students;

-- Clean up
DELETE FROM students WHERE email = 'test.nophone@example.com';
```

---

### Step B-5: NULLS FIRST / NULLS LAST

```sql
-- Insert a student with NULL phone to have test data
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Null', 'Phone', 'null.phone@example.com', '2024-09-01');

-- Default sort (NULLs last in DESC)
SELECT first_name, phone FROM students ORDER BY phone DESC;

-- Explicit control
SELECT first_name, phone FROM students ORDER BY phone ASC  NULLS LAST;
SELECT first_name, phone FROM students ORDER BY phone DESC NULLS FIRST;

DELETE FROM students WHERE email = 'null.phone@example.com';
```

---

### Step B-6: OFFSET … FETCH (ANSI pagination)

```sql
-- Top 3 by GPA
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3;

-- Rows 4–6 using LIMIT/OFFSET
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
LIMIT 3 OFFSET 3;

-- Same using ANSI FETCH syntax (PostgreSQL 16 supports this)
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
OFFSET 3 ROWS
FETCH NEXT 3 ROWS ONLY;
```

**Question:** Which syntax is more readable for pagination?

---

### Step B-7: CASE in ORDER BY

```sql
SELECT
    first_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN 'Distinction'
        WHEN gpa >= 3.00 THEN 'Merit'
        ELSE 'Pass'
    END AS standing
FROM   students
ORDER BY
    CASE
        WHEN gpa >= 3.70 THEN 1
        WHEN gpa >= 3.00 THEN 2
        ELSE 3
    END, gpa DESC;
```

---

### Part B Deliverables

Create `exercises/lab-03-results-postgresql.md` and record:
1. Row counts from Step B-1
2. The difference between `||` and `CONCAT()` with NULL (Step B-2)
3. ILIKE vs LIKE behavior (Step B-3)
4. NULL sort behavior with and without NULLS LAST (Step B-5)

---

## Part C — SQL Server 2022

### Connection

**SSMS / Azure Data Studio:** `localhost,1433`, user `SA`, password `Academy2024!`

---

### Step C-1: Warm-up

```sql
USE university;
GO

SELECT COUNT(*) AS total_students FROM students;
SELECT COUNT(*) AS total_departments FROM departments;
SELECT COUNT(*) AS total_enrollments FROM enrollments;
GO
```

---

### Step C-2: String concatenation and NULL

```sql
-- + operator
SELECT first_name + N' ' + last_name AS full_name FROM students;

-- What happens with NULL?
SELECT N'Hello' + NULL + N' World' AS result;  -- NULL

-- CONCAT is NULL-safe
SELECT CONCAT(N'Hello', NULL, N' World') AS result;  -- 'Hello World'

-- IIF (SQL Server shorthand for two-branch CASE)
SELECT
    first_name,
    IIF(is_active = 1, N'Active', N'Inactive') AS status
FROM students;
GO
```

---

### Step C-3: TOP and OFFSET…FETCH

```sql
-- TOP 3
SELECT TOP 3 first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC;

-- TOP WITH TIES
SELECT TOP 3 WITH TIES first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC;

-- Rows 4-6 using OFFSET…FETCH
SELECT first_name, last_name, gpa
FROM   students
ORDER BY gpa DESC
OFFSET 3 ROWS
FETCH NEXT 3 ROWS ONLY;
GO
```

---

### Step C-4: NULL handling

```sql
-- Insert a student without phone
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES (N'Test', N'NoPhone', N'test.nophone@example.com', '2024-09-01');

-- IS NULL
SELECT first_name, phone FROM students WHERE phone IS NULL;

-- COALESCE vs ISNULL
SELECT
    first_name,
    COALESCE(phone, N'Not provided') AS coalesce_result,
    ISNULL(phone, N'Not provided')   AS isnull_result
FROM students;
-- Both return the same here — difference is: COALESCE accepts more than 2 args

-- NULLIF
SELECT
    department_name,
    NULLIF(building, N'Tech Hall') AS building_if_not_tech
FROM departments;

DELETE FROM students WHERE email = N'test.nophone@example.com';
GO
```

---

### Step C-5: NULL sort workaround

```sql
-- SQL Server has no NULLS LAST — use CASE trick
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES (N'Null', N'Phone', N'null.phone@example.com', '2024-09-01');

-- NULLs sort first by default in ASC
SELECT first_name, phone FROM students ORDER BY phone ASC;

-- Push NULLs to the end
SELECT first_name, phone
FROM   students
ORDER BY
    CASE WHEN phone IS NULL THEN 1 ELSE 0 END,
    phone ASC;

DELETE FROM students WHERE email = N'null.phone@example.com';
GO
```

---

### Step C-6: CASE and IIF

```sql
SELECT
    first_name,
    gpa,
    CASE
        WHEN gpa >= 3.70 THEN N'Distinction'
        WHEN gpa >= 3.00 THEN N'Merit'
        WHEN gpa >= 2.00 THEN N'Pass'
        ELSE N'At Risk'
    END AS academic_standing
FROM   students
ORDER BY gpa DESC;
GO
```

---

### Part C Deliverables

Create `exercises/lab-03-results-sqlserver.md` and record:
1. Row counts from Step C-1
2. The NULL behavior of `+` vs `CONCAT()` (Step C-2)
3. The difference between `TOP 3` and `TOP 3 WITH TIES` if any ties exist (Step C-3)
4. The CASE-based ORDER BY trick for pushing NULLs last (Step C-5)

---

## Lab Submission

Create your results files inside `exercises/`:
- `exercises/lab-03-results-mysql.md`
- `exercises/lab-03-results-postgresql.md`
- `exercises/lab-03-results-sqlserver.md`

**When complete:** Take Quiz 03 (`assessments/quiz-03.md`)
