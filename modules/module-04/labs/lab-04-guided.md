# Module 04 — Guided Lab
## Aggregating Data: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

**Estimated time:** 75 minutes  
**Difficulty:** Beginner–Intermediate  
**Prerequisite:** Module 03 lab completed; university database populated

---

## Lab Overview

In this lab you will use aggregate functions to answer real analytical questions about the university dataset. You will work through COUNT/SUM/AVG/MIN/MAX, GROUP BY, HAVING, conditional aggregation, and string aggregation.

Work through **your track's part** (A, B, or C). Advanced learners: attempt all three to compare platform-specific syntax.

---

## Prerequisites Checklist

- [ ] `docker-compose ps` shows all containers healthy
- [ ] `university` database populated with students, departments, enrollments
- [ ] At least 4 students across at least 2 departments

---

## Part A — MySQL 8.0

### Connection
```bash
docker exec -it sql-academy-mysql80 mysql -u root -pAcademy2024! -h 127.0.0.1
```
Then: `USE university;`

---

### Step A-1: Warm-up — basic counts

```sql
-- How many rows in each table?
SELECT COUNT(*) AS total_students FROM students;
SELECT COUNT(*) AS total_departments FROM departments;
SELECT COUNT(*) AS total_enrollments FROM enrollments;
```

---

### Step A-2: Demonstrate COUNT(*) vs COUNT(col)

```sql
-- Insert a student without a phone number
INSERT INTO students (first_name, last_name, email, enrolled_at)
VALUES ('Test', 'NoPhone', 'test.nophone2@example.com', '2024-09-01');

-- Compare
SELECT
    COUNT(*)        AS all_rows,
    COUNT(phone)    AS with_phone,
    COUNT(*) - COUNT(phone) AS without_phone
FROM students;

-- Clean up
DELETE FROM students WHERE email = 'test.nophone2@example.com';
```

**Record:** How many students had NULL phone in your dataset?

---

### Step A-3: Summary statistics on GPA and budget

```sql
-- GPA statistics
SELECT
    COUNT(*)           AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa,
    MIN(gpa)           AS min_gpa,
    MAX(gpa)           AS max_gpa,
    SUM(gpa)           AS gpa_sum
FROM students;

-- Budget statistics
SELECT
    COUNT(*)           AS departments,
    SUM(budget)        AS total_budget,
    ROUND(AVG(budget), 0) AS avg_budget,
    MIN(budget)        AS smallest_budget,
    MAX(budget)        AS largest_budget
FROM departments;
```

---

### Step A-4: GROUP BY — students per department

```sql
SELECT
    department_id,
    COUNT(*)           AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM   students
GROUP BY department_id
ORDER BY students DESC;
```

**Question:** Which department has the most students? The highest average GPA?

---

### Step A-5: WHERE before GROUP BY

```sql
-- Active students per department
SELECT
    department_id,
    COUNT(*) AS active_count
FROM   students
WHERE  is_active = 1
GROUP BY department_id
ORDER BY active_count DESC;
```

**Experiment:** Remove the WHERE clause and add `is_active` to SELECT. How does the output change?

---

### Step A-6: HAVING — filter groups

```sql
-- Departments with more than 1 student
SELECT
    department_id,
    COUNT(*) AS student_count
FROM   students
GROUP BY department_id
HAVING COUNT(*) > 1;

-- Departments where avg GPA is above 3.00 (active students only)
SELECT
    department_id,
    COUNT(*)           AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM   students
WHERE  is_active = 1
GROUP BY department_id
HAVING AVG(gpa) > 3.00
ORDER BY avg_gpa DESC;
```

---

### Step A-7: Conditional aggregation

```sql
-- Active and inactive counts in one query
SELECT
    department_id,
    COUNT(*)                                            AS total,
    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END)     AS active,
    SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END)     AS inactive
FROM   students
GROUP BY department_id
ORDER BY department_id;
```

---

### Step A-8: GROUP_CONCAT

```sql
SELECT
    department_id,
    COUNT(*) AS students,
    GROUP_CONCAT(last_name ORDER BY last_name SEPARATOR ', ') AS last_names
FROM   students
GROUP BY department_id
ORDER BY department_id;
```

---

### Part A Deliverables

Create `exercises/lab-04-results-mysql.md` and record:
1. Row counts from Step A-1
2. NULL phone count from Step A-2
3. GPA and budget statistics from Step A-3
4. Which department has the highest average GPA (Step A-4)
5. The GROUP_CONCAT output for each department (Step A-8)

---

## Part B — PostgreSQL 16

### Connection
```bash
docker exec -it sql-academy-postgres16 psql -U postgres -h 127.0.0.1 -d university
```

---

### Step B-1: Basic counts and statistics

```sql
SELECT COUNT(*) AS total_students FROM students;

SELECT
    COUNT(*)                     AS students,
    ROUND(AVG(gpa)::NUMERIC, 2)  AS avg_gpa,
    MIN(gpa)                     AS min_gpa,
    MAX(gpa)                     AS max_gpa
FROM students;
```

---

### Step B-2: GROUP BY with ROUND

PostgreSQL's `ROUND` requires the input to be `NUMERIC`, not `FLOAT`.  
When a column is `DECIMAL` or `NUMERIC`, `AVG` returns `NUMERIC` automatically.  
If GPA is stored as `FLOAT`, cast first:

```sql
SELECT
    department_id,
    COUNT(*)                     AS students,
    ROUND(AVG(gpa)::NUMERIC, 2)  AS avg_gpa
FROM   students
GROUP BY department_id
ORDER BY avg_gpa DESC;
```

---

### Step B-3: WHERE + GROUP BY + HAVING

```sql
SELECT
    department_id,
    COUNT(*)                    AS students,
    ROUND(AVG(gpa)::NUMERIC, 2) AS avg_gpa
FROM   students
WHERE  is_active = TRUE
GROUP BY department_id
HAVING COUNT(*) > 0
   AND AVG(gpa) > 3.00
ORDER BY avg_gpa DESC;
```

---

### Step B-4: STRING_AGG

```sql
SELECT
    department_id,
    COUNT(*) AS students,
    STRING_AGG(last_name, ', ' ORDER BY last_name) AS last_names
FROM   students
GROUP BY department_id
ORDER BY department_id;
```

**Compare to MySQL's `GROUP_CONCAT`:** PostgreSQL puts the ORDER BY inside `STRING_AGG`. MySQL puts it after the column name, before SEPARATOR.

---

### Step B-5: ROLLUP

```sql
-- Student count by department and enrollment year with subtotals
SELECT
    department_id,
    EXTRACT(YEAR FROM enrolled_at) AS yr,
    COUNT(*)                       AS students
FROM   students
GROUP BY ROLLUP(department_id, EXTRACT(YEAR FROM enrolled_at))
ORDER BY department_id NULLS LAST, yr NULLS LAST;
```

**Observe:** Which rows have NULL in `department_id` or `yr`? Those are the ROLLUP summary rows.

---

### Part B Deliverables

Create `exercises/lab-04-results-postgresql.md` and record:
1. Row counts and GPA statistics from Step B-1
2. Department averages from Step B-2
3. The ROLLUP output — identify the subtotal and grand total rows (Step B-5)

---

## Part C — SQL Server 2022

### Connection

**SSMS / Azure Data Studio:** `localhost,1433`, user `SA`, password `Academy2024!`

---

### Step C-1: Basic aggregates

```sql
USE university;
GO

SELECT COUNT(*) AS total_students FROM students;

SELECT
    COUNT(*)        AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa,
    MIN(gpa)        AS min_gpa,
    MAX(gpa)        AS max_gpa
FROM students;
GO
```

---

### Step C-2: Integer division trap

```sql
-- Demonstrate the truncation issue with an INT column
-- GPA is DECIMAL so it's safe here, but try this:
DECLARE @t TABLE (val INT);
INSERT INTO @t VALUES (1), (2), (3), (4);

SELECT
    AVG(val)                       AS avg_integer_truncated,
    AVG(CAST(val AS DECIMAL(5,2))) AS avg_decimal_correct
FROM @t;
-- Returns 2 and 2.50 respectively
GO
```

**Record:** What is the difference? Why does SQL Server truncate the integer result?

---

### Step C-3: GROUP BY, HAVING

```sql
SELECT
    department_id,
    COUNT(*)           AS students,
    ROUND(AVG(gpa), 2) AS avg_gpa
FROM   students
WHERE  is_active = 1
GROUP BY department_id
HAVING AVG(gpa) > 3.00
ORDER BY avg_gpa DESC;
GO
```

---

### Step C-4: STRING_AGG WITHIN GROUP

```sql
SELECT
    department_id,
    COUNT(*) AS students,
    STRING_AGG(last_name, N', ') WITHIN GROUP (ORDER BY last_name) AS last_names
FROM   students
GROUP BY department_id
ORDER BY department_id;
GO
```

**Note the SQL Server syntax difference:** The `ORDER BY` goes inside `WITHIN GROUP (...)`, not inside the `STRING_AGG` function parentheses.

---

### Step C-5: ROLLUP with GROUPING()

```sql
SELECT
    CASE WHEN GROUPING(department_id)     = 1 THEN N'ALL DEPTS'
         ELSE CAST(department_id AS NVARCHAR(10)) END AS dept,
    CASE WHEN GROUPING(YEAR(enrolled_at)) = 1 THEN N'ALL YEARS'
         ELSE CAST(YEAR(enrolled_at) AS NVARCHAR(4)) END AS yr,
    COUNT(*) AS students
FROM   students
GROUP BY department_id, YEAR(enrolled_at) WITH ROLLUP;
GO
```

---

### Part C Deliverables

Create `exercises/lab-04-results-sqlserver.md` and record:
1. The integer division trap result from Step C-2
2. The active-students-per-dept HAVING result from Step C-3
3. The STRING_AGG output from Step C-4
4. The ROLLUP with GROUPING() output from Step C-5

---

## Lab Submission

Create your results files inside `exercises/`:
- `exercises/lab-04-results-mysql.md`
- `exercises/lab-04-results-postgresql.md`
- `exercises/lab-04-results-sqlserver.md`

**When complete:** Take Quiz 04 (`assessments/quiz-04.md`)
