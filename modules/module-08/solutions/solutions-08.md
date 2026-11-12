# Module 08 — Solutions
## Data Modification

> **Security note:** Instructor use only. Do not expose to learners before they attempt exercises.

---

## Beginner Solutions

### Exercise 01 — Insert a single student

```sql
-- MySQL 8.0 / SQL Server 2022
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Lena', 'Fischer', 3.72, 2, CURDATE(), 1);  -- MySQL uses CURDATE()
-- SQL Server: GETDATE()

-- PostgreSQL 16
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Lena', 'Fischer', 3.72, 2, CURRENT_DATE, TRUE);
```

---

### Exercise 02 — Multi-row INSERT

```sql
-- MySQL 8.0 / SQL Server 2022
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES
    ('Omar',  'Hassan',    3.65, 1, '2024-09-01', 1),
    ('Mia',   'Johansson', 3.88, 3, '2023-01-15', 1),
    ('Raj',   'Patel',     3.50, 2, '2024-01-15', 1);

-- PostgreSQL 16 (is_active is BOOLEAN)
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES
    ('Omar',  'Hassan',    3.65, 1, '2024-09-01', TRUE),
    ('Mia',   'Johansson', 3.88, 3, '2023-01-15', TRUE),
    ('Raj',   'Patel',     3.50, 2, '2024-01-15', TRUE);
```

---

### Exercise 03 — INSERT … SELECT into staging

```sql
INSERT INTO students_staging (student_id, first_name, last_name, gpa)
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  gpa >= 3.75;
```

---

### Exercise 04 — Update Lena Fischer's GPA

```sql
-- Step 1: verify
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  first_name = 'Lena' AND last_name = 'Fischer';

-- Step 2: update
UPDATE students
SET    gpa = 3.85
WHERE  first_name = 'Lena' AND last_name = 'Fischer';
```

**Note:** Using name in WHERE is reliable here because we just inserted this unique test row. In production, prefer `WHERE student_id = <id>` after looking up the ID.

---

### Exercise 05 — Deactivate early-enrolled students

```sql
-- Step 1: verify
SELECT student_id, first_name, enrolled_at, is_active
FROM   students
WHERE  enrolled_at < '2023-01-01';

-- Step 2: update
-- MySQL / SQL Server
UPDATE students
SET    is_active = 0
WHERE  enrolled_at < '2023-01-01';

-- PostgreSQL
UPDATE students
SET    is_active = FALSE
WHERE  enrolled_at < '2023-01-01';
```

---

### Exercise 06 — Delete Omar Hassan

```sql
-- Step 1: verify exactly one row
SELECT student_id, first_name, last_name
FROM   students
WHERE  first_name = 'Omar' AND last_name = 'Hassan';

-- Step 2: delete
DELETE FROM students
WHERE  first_name = 'Omar' AND last_name = 'Hassan';
```

---

### Exercise 07 — TRUNCATE staging

```sql
TRUNCATE TABLE students_staging;
```

**Key distinction:** TRUNCATE removes all rows instantly, resets MySQL's AUTO_INCREMENT, and cannot have a WHERE clause. Use DELETE if you need row-level control or rollback certainty.

---

### Exercise 08 — GPA bump capped at 4.00

```sql
-- MySQL 8.0
UPDATE students
SET    gpa = LEAST(gpa + 0.03, 4.00);

-- PostgreSQL 16
UPDATE students
SET    gpa = LEAST(gpa + 0.03, 4.00);

-- SQL Server 2022
UPDATE students
SET    gpa = CASE WHEN gpa + 0.03 > 4.00 THEN 4.00 ELSE gpa + 0.03 END;
```

---

### Exercise 09 — Staging from department 1 active students

```sql
INSERT INTO students_staging (student_id, first_name, last_name, gpa)
SELECT student_id, first_name, last_name, gpa
FROM   students
WHERE  department_id = 1
  AND  is_active = 1;  -- PostgreSQL: is_active = TRUE
```

---

### Exercise 10 — Set active for above-average GPA students

```sql
-- Step 1: see who will be updated
SELECT student_id, first_name, gpa
FROM   students
WHERE  gpa > (SELECT AVG(gpa) FROM students);

-- Step 2: update
UPDATE students
SET    is_active = 1
WHERE  gpa > (SELECT AVG(gpa) FROM students);
-- PostgreSQL: is_active = TRUE
```

---

## Intermediate Solutions

### Exercise 11 — Joined UPDATE for Computer Science

```sql
-- MySQL 8.0
UPDATE students s
JOIN   departments d ON d.department_id = s.department_id
SET    s.gpa = LEAST(s.gpa + 0.10, 4.00)
WHERE  d.department_name = 'Computer Science';

-- PostgreSQL 16
UPDATE students s
SET    gpa = LEAST(s.gpa + 0.10, 4.00)
FROM   departments d
WHERE  d.department_id = s.department_id
  AND  d.department_name = 'Computer Science';

-- SQL Server 2022
UPDATE s
SET    s.gpa = CASE WHEN s.gpa + 0.10 > 4.00 THEN 4.00 ELSE s.gpa + 0.10 END
FROM   students s
JOIN   departments d ON d.department_id = s.department_id
WHERE  d.department_name = N'Computer Science';
```

---

### Exercise 12 — Delete orphaned enrollments

```sql
DELETE FROM enrollments
WHERE NOT EXISTS (
    SELECT 1 FROM students s
    WHERE  s.student_id = enrollments.student_id
);
```

**Why NOT EXISTS rather than NOT IN?** If `students.student_id` ever contained a NULL (which it shouldn't as a PK, but defensively), NOT IN would return 0 rows — the NULL trap. NOT EXISTS is always safe.

---

### Exercise 13 — UPSERT course stats

```sql
-- MySQL 8.0
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 1, NOW())
ON DUPLICATE KEY UPDATE
    enrollment_count = enrollment_count + 1,
    last_updated     = NOW();

-- PostgreSQL 16
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 1, NOW())
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = course_stats.enrollment_count + 1,
        last_updated     = NOW();

-- SQL Server 2022
MERGE INTO course_stats AS target
USING (VALUES (101, 1)) AS source(course_id, increment)
    ON target.course_id = source.course_id
WHEN MATCHED THEN
    UPDATE SET
        enrollment_count = target.enrollment_count + source.increment,
        last_updated     = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (course_id, enrollment_count, last_updated)
    VALUES (source.course_id, source.increment, GETDATE());
```

---

### Exercise 14 — Transaction with COMMIT

```sql
-- MySQL / PostgreSQL
BEGIN;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Test', 'Txn', 3.00, 1, NOW(), 1);  -- PostgreSQL: TRUE

UPDATE course_stats
SET    enrollment_count = enrollment_count + 1
WHERE  course_id = 101;

COMMIT;

-- Verify
SELECT * FROM students WHERE first_name = 'Test';
SELECT enrollment_count FROM course_stats WHERE course_id = 101;

-- SQL Server
BEGIN TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES (N'Test', N'Txn', 3.00, 1, GETDATE(), 1);

UPDATE course_stats
SET    enrollment_count = enrollment_count + 1
WHERE  course_id = 101;

COMMIT TRANSACTION;
```

---

### Exercise 15 — Transaction with ROLLBACK

```sql
-- MySQL / PostgreSQL
BEGIN;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Test', 'Txn', 3.00, 1, NOW(), 1);

UPDATE course_stats
SET    enrollment_count = enrollment_count + 1
WHERE  course_id = 101;

ROLLBACK;

-- Neither change persists
SELECT * FROM students WHERE first_name = 'Test';    -- 0 rows
SELECT enrollment_count FROM course_stats WHERE course_id = 101;  -- unchanged
```

---

## Challenge Solutions

### Exercise 16 — SAVEPOINT transaction

```sql
-- MySQL / PostgreSQL
BEGIN;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('SP', 'Test', 3.50, 2, NOW(), 1);  -- PostgreSQL: TRUE

SAVEPOINT after_insert;

UPDATE students SET gpa = 0.00 WHERE department_id = 2;  -- simulated mistake

ROLLBACK TO SAVEPOINT after_insert;

COMMIT;

-- Expected result
SELECT first_name, gpa FROM students WHERE first_name = 'SP';
-- SP Test: gpa = 3.50

SELECT first_name, gpa FROM students WHERE department_id = 2 AND first_name != 'SP';
-- All other dept 2 students retain their original GPAs

-- SQL Server
BEGIN TRANSACTION;

INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES (N'SP', N'Test', 3.50, 2, GETDATE(), 1);

SAVE TRANSACTION after_insert;

UPDATE students SET gpa = 0.00 WHERE department_id = 2;

ROLLBACK TRANSACTION after_insert;

COMMIT TRANSACTION;
```

---

### Exercise 17 — Delete students with no enrollments

```sql
-- Using NOT EXISTS (recommended — NULL-safe)
DELETE FROM students
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e
    WHERE  e.student_id = students.student_id
);

-- Alternative using LEFT JOIN anti-join (MySQL friendly)
DELETE s
FROM   students s
LEFT   JOIN enrollments e ON e.student_id = s.student_id
WHERE  e.student_id IS NULL;
```

**Warning:** Always run the matching SELECT first:

```sql
SELECT s.student_id, s.first_name
FROM   students s
WHERE NOT EXISTS (
    SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id
);
```

---

### Exercise 18 — SQL Server MERGE with OUTPUT

```sql
MERGE INTO course_stats AS target
USING (
    VALUES (101, 10), (102, 5), (103, 8)
) AS source(course_id, new_count)
    ON target.course_id = source.course_id
WHEN MATCHED THEN
    UPDATE SET
        enrollment_count = source.new_count,
        last_updated     = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (course_id, enrollment_count, last_updated)
    VALUES (source.course_id, source.new_count, GETDATE())
OUTPUT
    $action            AS merge_action,
    INSERTED.course_id,
    DELETED.enrollment_count AS old_count,
    INSERTED.enrollment_count AS new_count;
```

Expected OUTPUT:
- course_id 101: `UPDATE` (existed) — old_count shows previous value, new_count = 10
- course_id 102: `INSERT` (new) — old_count = NULL, new_count = 5
- course_id 103: `INSERT` (new) — old_count = NULL, new_count = 8

---

## Interview Answer Guide

### IQ-01 — UPDATE without WHERE
Every row in the table is updated. Without a WHERE clause, the update applies to all rows. If the table has 10,000 students, all 10,000 GPAs change. Prevention: always write and run the equivalent SELECT first; wrap in a transaction so you can ROLLBACK if the result is unexpected.

### IQ-02 — DELETE vs TRUNCATE
DELETE removes rows one at a time (or in batches) with full logging, can be filtered with WHERE, fires triggers, and can always be rolled back inside a transaction. TRUNCATE removes all rows by deallocating pages (much faster), cannot be filtered, does not fire triggers, and may not be rollback-safe outside a transaction on some platforms (MySQL). Use DELETE when you need partial removal, trigger execution, or guaranteed rollback; use TRUNCATE when you want to empty a large table quickly and completely.

### IQ-03 — ON CONFLICT DO NOTHING vs DO UPDATE
`DO NOTHING` silently ignores the conflicting row — the existing row is unchanged, the INSERT is skipped, no error is raised. `DO UPDATE` applies the SET clause to the existing row. Use `DO NOTHING` when duplicate inserts should simply be discarded (idempotent insert). Use `DO UPDATE` when the existing row should be refreshed or incremented.

### IQ-04 — ACID and bank transfer
A bank transfer between two accounts needs:
- **Atomicity**: both debit and credit happen, or neither does (no partial transfer)
- **Consistency**: the total balance across both accounts stays the same after the transaction
- **Isolation**: another transaction reading the accounts mid-transfer doesn't see an intermediate state where money has left one account but not yet arrived in the other
- **Durability**: once committed, the transfer survives a power outage

### IQ-05 — READ COMMITTED vs REPEATABLE READ
In READ COMMITTED, if transaction A reads a row and then transaction B commits an update to that row, transaction A's second read of the same row sees the new value (non-repeatable read). In REPEATABLE READ, transaction A's second read is guaranteed to return the same value it saw the first time — B's committed update is invisible to A until A's transaction ends. This matters for a report that runs the same aggregate query twice within one transaction and must get consistent results.

### IQ-06 — Dirty read
A dirty read occurs when transaction A reads data written by transaction B before B commits. If B rolls back, A has read data that never officially existed. Only READ UNCOMMITTED allows dirty reads. READ COMMITTED and higher prevent them.

### IQ-07 — PostgreSQL RETURNING
RETURNING appends a result set to INSERT, UPDATE, or DELETE, returning the affected rows and any computed values. Practical use: immediately get the auto-generated primary key after INSERT without a separate SELECT; get old and new values side by side after UPDATE; confirm which rows were removed by DELETE.

### IQ-08 — SQL Server MERGE $action
`$action` in an OUTPUT clause returns a string: `'INSERT'`, `'UPDATE'`, or `'DELETE'` — indicating which MERGE branch processed each row. It lets you audit the full MERGE operation: how many rows were inserted vs updated vs deleted, all from a single statement.
