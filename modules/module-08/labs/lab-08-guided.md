# Module 08 — Guided Lab
## Data Modification

**Estimated time:** 90–120 minutes  
**Platforms covered:** Part A — MySQL 8.0 · Part B — PostgreSQL 16 · Part C — SQL Server 2022

---

## Prerequisites

- `university` database populated with synthetic data
- `students_staging` table created (see Section 3 of each platform's SQL file)
- `course_stats` table created (see Section 14 / UPSERT section)

---

## Part A — MySQL 8.0

```sql
USE university;
```

---

### A-01: INSERT safety check

Before inserting, check whether a student named **Lena Fischer** already exists:

```sql
SELECT * FROM students WHERE first_name = 'Lena' AND last_name = 'Fischer';
```

If 0 rows returned, proceed with the insert:

```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Lena', 'Fischer', 3.72, 2, CURDATE(), 1);

SELECT * FROM students WHERE first_name = 'Lena';
```

**Question:** What auto-generated value did `student_id` receive? How would you retrieve it without a second SELECT?

---

### A-02: Multi-row INSERT

Insert three students in a single statement. Count rows before and after:

```sql
SELECT COUNT(*) AS before_count FROM students;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES
    ('Omar',  'Hassan',    3.65, 1, '2024-09-01', 1),
    ('Mia',   'Johansson', 3.88, 3, '2023-01-15', 1),
    ('Raj',   'Patel',     3.50, 2, '2024-01-15', 1);

SELECT COUNT(*) AS after_count FROM students;
```

---

### A-03: INSERT … SELECT

Populate staging from the main table:

```sql
-- Clear staging first
TRUNCATE TABLE students_staging;

INSERT INTO students_staging (student_id, first_name, last_name, gpa)
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  gpa >= 3.80;

SELECT * FROM students_staging ORDER BY gpa DESC;
```

**Task:** How many rows were copied? Run `SELECT COUNT(*) FROM students WHERE gpa >= 3.80;` and compare.

---

### A-04: SELECT-before-UPDATE discipline

Before updating Lena Fischer's GPA, always SELECT first:

```sql
-- Step 1: What will change?
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  first_name = 'Lena' AND last_name = 'Fischer';

-- Step 2: Apply the update
UPDATE students
SET    gpa = 3.85
WHERE  first_name = 'Lena' AND last_name = 'Fischer';

-- Step 3: Verify
SELECT student_id, first_name, gpa FROM students WHERE first_name = 'Lena';
```

**Question:** Why is using `WHERE student_id = <id>` safer than `WHERE first_name = 'Lena' AND last_name = 'Fischer'` in production?

---

### A-05: UPDATE with expression (capped at 4.00)

Raise all CS department GPAs by 0.10, but cap at 4.00:

```sql
-- Step 1: Who will be affected and what will they become?
SELECT student_id, first_name, gpa,
       LEAST(gpa + 0.10, 4.00) AS new_gpa
FROM   students
WHERE  department_id = 1;

-- Step 2: Apply
UPDATE students
SET    gpa = LEAST(gpa + 0.10, 4.00)
WHERE  department_id = 1;

-- Step 3: Verify
SELECT first_name, gpa FROM students WHERE department_id = 1;
```

---

### A-06: Multi-table UPDATE with JOIN

Update all Mathematics department students using a join to the departments table:

```sql
UPDATE students s
JOIN   departments d ON d.department_id = s.department_id
SET    s.gpa = LEAST(s.gpa + 0.05, 4.00)
WHERE  d.department_name = 'Mathematics';
```

**Task:** Rewrite this UPDATE to use a subquery instead of a JOIN:

```sql
UPDATE students
SET    gpa = LEAST(gpa + 0.05, 4.00)
WHERE  department_id = (
    SELECT department_id FROM departments WHERE department_name = 'Mathematics'
);
```

Compare both versions. Which do you find more readable?

---

### A-07: SELECT-before-DELETE discipline

```sql
-- Step 1: What will be deleted?
SELECT student_id, first_name, last_name
FROM   students
WHERE  first_name = 'Omar' AND last_name = 'Hassan';

-- Step 2: Delete
DELETE FROM students
WHERE  first_name = 'Omar' AND last_name = 'Hassan';

-- Step 3: Confirm
SELECT * FROM students WHERE first_name = 'Omar';  -- expect 0 rows
```

---

### A-08: UPSERT — ON DUPLICATE KEY UPDATE

```sql
-- First run: should INSERT (course 201 does not exist yet)
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (201, 1, NOW())
ON DUPLICATE KEY UPDATE
    enrollment_count = enrollment_count + 1,
    last_updated     = NOW();

SELECT * FROM course_stats WHERE course_id = 201;

-- Second run: should UPDATE (course 201 now exists)
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (201, 1, NOW())
ON DUPLICATE KEY UPDATE
    enrollment_count = enrollment_count + 1,
    last_updated     = NOW();

SELECT * FROM course_stats WHERE course_id = 201;  -- enrollment_count = 2
```

**Question:** What constraint must exist on `course_id` for `ON DUPLICATE KEY UPDATE` to trigger?

---

### A-09: Transaction — COMMIT and ROLLBACK

**Scenario:** Enroll a student and increment a counter atomically.

```sql
-- Part 1: Commit path
START TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('TxnTest', 'A', 3.00, 1, NOW(), 1);

UPDATE course_stats SET enrollment_count = enrollment_count + 1 WHERE course_id = 201;

COMMIT;

SELECT * FROM students WHERE first_name = 'TxnTest';        -- should exist
SELECT enrollment_count FROM course_stats WHERE course_id = 201;

-- Part 2: Rollback path
START TRANSACTION;

DELETE FROM students WHERE first_name = 'TxnTest';
UPDATE course_stats SET enrollment_count = enrollment_count - 1 WHERE course_id = 201;

ROLLBACK;

SELECT * FROM students WHERE first_name = 'TxnTest';        -- should still exist
SELECT enrollment_count FROM course_stats WHERE course_id = 201;  -- unchanged
```

---

### A-10: SAVEPOINT

```sql
START TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('SP', 'Demo', 3.60, 2, NOW(), 1);

SAVEPOINT before_mistake;

-- Accidental mass update
UPDATE students SET gpa = 0.00 WHERE department_id = 2;

-- Undo the mass update, keep the INSERT
ROLLBACK TO SAVEPOINT before_mistake;

COMMIT;

-- Verify: SP Demo exists; dept 2 students have their real GPAs
SELECT first_name, gpa FROM students WHERE department_id = 2;
```

---

## Part B — PostgreSQL 16

```sql
\c university
```

---

### B-01: INSERT … RETURNING

```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Lena', 'Fischer', 3.72, 2, CURRENT_DATE, TRUE)
RETURNING student_id, first_name, gpa;
```

The `RETURNING` clause shows the auto-generated `student_id` immediately — no second query needed.

**Task:** Rewrite to also RETURN the `enrolled_at` column.

---

### B-02: ON CONFLICT DO UPDATE (UPSERT)

```sql
-- First insert
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (201, 1, NOW())
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = course_stats.enrollment_count + 1,
        last_updated     = NOW();

-- Second insert (update path)
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (201, 1, NOW())
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = course_stats.enrollment_count + 1,
        last_updated     = NOW();

SELECT * FROM course_stats WHERE course_id = 201;
```

**Task:** Change the second statement to use `EXCLUDED` to reference the attempted row:

```sql
SET enrollment_count = EXCLUDED.enrollment_count + course_stats.enrollment_count
```

What is the difference in behavior?

---

### B-03: ON CONFLICT DO NOTHING

```sql
-- Try to insert an existing course_id — should silently do nothing
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (201, 999, NOW())
ON CONFLICT (course_id) DO NOTHING;

SELECT enrollment_count FROM course_stats WHERE course_id = 201;
-- enrollment_count unchanged — the 999 was ignored
```

---

### B-04: UPDATE … RETURNING

```sql
UPDATE students
SET    gpa = LEAST(gpa + 0.05, 4.00)
WHERE  department_id = 1
RETURNING student_id, first_name, gpa AS new_gpa;
```

**Task:** Extend the RETURNING clause to also show the old GPA.  
Hint: PostgreSQL does not have DELETED/INSERTED like SQL Server. Store old values in a CTE:

```sql
WITH old_values AS (
    SELECT student_id, gpa AS old_gpa FROM students WHERE department_id = 1
),
updated AS (
    UPDATE students
    SET    gpa = LEAST(gpa + 0.05, 4.00)
    WHERE  department_id = 1
    RETURNING student_id, gpa AS new_gpa
)
SELECT u.student_id, o.old_gpa, u.new_gpa
FROM   updated u
JOIN   old_values o ON o.student_id = u.student_id;
```

---

### B-05: DELETE … RETURNING

```sql
DELETE FROM students_staging
WHERE gpa < 3.80
RETURNING student_id, first_name, gpa;
```

The result shows exactly which rows were removed and what their values were.

---

## Part C — SQL Server 2022

```sql
USE university;
GO
```

---

### C-01: INSERT … OUTPUT

```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
OUTPUT INSERTED.student_id, INSERTED.first_name, INSERTED.gpa
VALUES (N'Lena', N'Fischer', 3.72, 2, GETDATE(), 1);
```

OUTPUT INSERTED returns the row as it was written (after any defaults are applied).

---

### C-02: UPDATE … OUTPUT (old and new values)

```sql
UPDATE students
SET    gpa = LEAST(gpa + 0.10, 4.00)  -- SQL Server doesn't have LEAST — use CASE
-- actually:
-- SET gpa = CASE WHEN gpa + 0.10 > 4.00 THEN 4.00 ELSE gpa + 0.10 END
OUTPUT DELETED.gpa AS old_gpa, INSERTED.gpa AS new_gpa, INSERTED.first_name
WHERE  department_id = 1;
```

```sql
-- Correct version
UPDATE students
SET    gpa = CASE WHEN gpa + 0.10 > 4.00 THEN 4.00 ELSE gpa + 0.10 END
OUTPUT DELETED.gpa AS old_gpa, INSERTED.gpa AS new_gpa, INSERTED.first_name
WHERE  department_id = 1;
```

---

### C-03: MERGE — full UPSERT

```sql
MERGE INTO course_stats AS target
USING (VALUES (201, 1)) AS source(course_id, increment)
    ON target.course_id = source.course_id
WHEN MATCHED THEN
    UPDATE SET
        enrollment_count = target.enrollment_count + source.increment,
        last_updated     = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (course_id, enrollment_count, last_updated)
    VALUES (source.course_id, source.increment, GETDATE())
OUTPUT $action AS merge_action, INSERTED.course_id, INSERTED.enrollment_count;
GO
```

Run once (INSERT path), then run again (UPDATE path). Observe `$action` changes from `INSERT` to `UPDATE`.

---

### C-04: Transaction with SAVE TRANSACTION

```sql
BEGIN TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES (N'SP', N'Demo', 3.60, 2, GETDATE(), 1);

SAVE TRANSACTION before_mistake;

UPDATE students SET gpa = 0.00 WHERE department_id = 2;

ROLLBACK TRANSACTION before_mistake;

COMMIT TRANSACTION;

SELECT first_name, gpa FROM students WHERE department_id = 2;
GO
```

---

### C-05: Isolation level — observe dirty reads

**Setup:** Open two SQL Server query windows.

**Window 1:**
```sql
BEGIN TRANSACTION;
UPDATE students SET gpa = 0.00 WHERE student_id = 1;
-- Do NOT commit yet
```

**Window 2:**
```sql
-- READ COMMITTED (default) — will NOT see Window 1's change
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT gpa FROM students WHERE student_id = 1;  -- sees original value

-- READ UNCOMMITTED — WILL see Window 1's uncommitted change
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT gpa FROM students WHERE student_id = 1;  -- sees 0.00 (dirty read)
```

**Window 1:**
```sql
ROLLBACK TRANSACTION;  -- Window 2's dirty read was data that never committed
```

---

## Lab Wrap-Up

After completing all parts:

1. What is the safest way to handle an UPDATE that affects a large table in production?
2. Write the UPSERT syntax for your preferred platform from memory.
3. What does `ROLLBACK TO SAVEPOINT` do — and what does it NOT undo?
4. Name the two platforms that support a `RETURNING`-style clause for INSERT/UPDATE/DELETE.
5. At which isolation level does a dirty read become possible?
