# Module 08 — Lecture Notes
## Data Modification

---

## 1. DML Overview

SQL statements that change data are called **DML — Data Manipulation Language**:

| Statement | Purpose |
|-----------|---------|
| `INSERT` | Add new rows |
| `UPDATE` | Modify existing rows |
| `DELETE` | Remove rows |
| `MERGE` | Insert + Update + Delete in one statement (UPSERT) |

These differ from **DDL** (CREATE, ALTER, DROP) which changes structure, not data. DML changes can be wrapped in transactions and rolled back; some DDL (TRUNCATE, DROP) cannot.

---

## 2. INSERT — Adding Rows

### Single-row INSERT

```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Amara', 'Diallo', 3.90, 1, '2024-09-01', 1);
```

The column list and VALUES list must match in count and data type. The column list can be omitted if VALUES supplies every column in table-definition order — but explicit column lists are safer and self-documenting.

### Multi-row INSERT

```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES
    ('Priya',   'Sharma',   3.85, 2, '2024-09-01', 1),
    ('Carlos',  'Reyes',    3.70, 1, '2024-09-01', 1),
    ('Sofia',   'Chen',     3.95, 3, '2023-09-01', 1);
```

Multi-row INSERT is significantly faster than separate single-row statements because it reduces round-trips and can be batched by the engine.

### INSERT … SELECT

Populate a table from the result of a query:

```sql
-- Archive inactive students
INSERT INTO students_archive (student_id, first_name, last_name, gpa, archived_at)
SELECT student_id, first_name, last_name, gpa, NOW()
FROM   students
WHERE  is_active = 0;
```

The SELECT can include JOINs, WHERE, GROUP BY — anything a normal SELECT supports. No VALUES keyword is used. Column counts and types must match.

---

## 3. UPDATE — Modifying Rows

### Basic UPDATE

```sql
UPDATE students
SET    gpa = 3.95
WHERE  student_id = 7;
```

**Always include a WHERE clause** unless you intentionally want to update every row. Without WHERE, every row is updated.

### UPDATE multiple columns

```sql
UPDATE students
SET    gpa         = 3.80,
       is_active   = 1,
       enrolled_at = '2024-01-15'
WHERE  student_id = 12;
```

### UPDATE with expression

```sql
-- Apply a uniform GPA bump to one department
UPDATE students
SET    gpa = gpa + 0.05
WHERE  department_id = 2 AND gpa <= 3.95;
```

### UPDATE with subquery

```sql
-- Set each student's GPA to their department average (illustrative)
UPDATE students s
SET    s.gpa = (
    SELECT ROUND(AVG(s2.gpa), 2)
    FROM   students s2
    WHERE  s2.department_id = s.department_id
);
```

### UPDATE with JOIN (MySQL syntax)

```sql
-- MySQL: multi-table UPDATE using JOIN
UPDATE students s
JOIN   departments d ON d.department_id = s.department_id
SET    s.gpa = s.gpa + 0.10
WHERE  d.department_name = 'Computer Science';
```

### UPDATE with JOIN (SQL Server / PostgreSQL)

```sql
-- SQL Server: UPDATE … FROM
UPDATE s
SET    s.gpa = s.gpa + 0.10
FROM   students s
JOIN   departments d ON d.department_id = s.department_id
WHERE  d.department_name = 'Computer Science';

-- PostgreSQL: UPDATE … FROM
UPDATE students s
SET    gpa = s.gpa + 0.10
FROM   departments d
WHERE  d.department_id = s.department_id
  AND  d.department_name = 'Computer Science';
```

---

## 4. The SELECT-Before-UPDATE Rule

Before running any UPDATE, run the equivalent SELECT first to verify which rows will be affected:

```sql
-- Step 1: What will change?
SELECT student_id, first_name, gpa
FROM   students
WHERE  department_id = 2 AND gpa <= 3.95;

-- Step 2: Apply (after confirming Step 1 looks correct)
UPDATE students
SET    gpa = gpa + 0.05
WHERE  department_id = 2 AND gpa <= 3.95;
```

This discipline prevents accidental mass-updates that are expensive or impossible to undo outside a transaction.

---

## 5. DELETE — Removing Rows

### Basic DELETE

```sql
DELETE FROM students
WHERE student_id = 7;
```

Same rule as UPDATE: **always include WHERE** unless you want to delete all rows.

### DELETE with subquery

```sql
-- Delete students who have never enrolled
DELETE FROM students
WHERE student_id NOT IN (
    SELECT DISTINCT student_id FROM enrollments
);
```

### DELETE with JOIN (MySQL)

```sql
-- MySQL: multi-table delete
DELETE s
FROM   students s
JOIN   departments d ON d.department_id = s.department_id
WHERE  d.department_name = 'Defunct Department';
```

### DELETE with EXISTS (portable)

```sql
-- Delete enrollments for a specific course (all platforms)
DELETE FROM enrollments
WHERE EXISTS (
    SELECT 1 FROM courses c
    WHERE  c.course_id = enrollments.course_id
      AND  c.credits = 0
);
```

---

## 6. TRUNCATE — Remove All Rows Fast

```sql
TRUNCATE TABLE students_staging;
```

`TRUNCATE` removes all rows without scanning them individually. It is much faster than `DELETE FROM table` for large tables.

**Differences from DELETE:**

| Dimension | DELETE | TRUNCATE |
|-----------|--------|----------|
| WHERE clause | Yes | No |
| Row-level logging | Yes | No (page deallocation) |
| Triggers | Fire | Do not fire (most platforms) |
| Auto-increment reset | No | Yes (MySQL); depends on platform |
| Rollback | Always | In a transaction (PostgreSQL); not always (MySQL, SQL Server) |
| Foreign keys | Respects them | Blocked if referenced rows exist |

---

## 7. UPSERT — INSERT or UPDATE on Conflict

An **UPSERT** inserts a row if it does not exist, or updates it if it does. Each platform has a different syntax.

### MySQL — ON DUPLICATE KEY UPDATE

```sql
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 1, NOW())
ON DUPLICATE KEY UPDATE
    enrollment_count = enrollment_count + 1,
    last_updated     = NOW();
```

Triggers when any UNIQUE or PRIMARY KEY constraint would be violated.

### PostgreSQL — ON CONFLICT DO UPDATE

```sql
INSERT INTO course_stats (course_id, enrollment_count, last_updated)
VALUES (101, 1, NOW())
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = course_stats.enrollment_count + 1,
        last_updated     = NOW();
```

`ON CONFLICT (col)` names the specific constraint column. `EXCLUDED` refers to the row that was attempted:

```sql
ON CONFLICT (course_id) DO UPDATE
    SET enrollment_count = EXCLUDED.enrollment_count + course_stats.enrollment_count;
```

### SQL Server — MERGE

```sql
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

MERGE can also include `WHEN NOT MATCHED BY SOURCE THEN DELETE` to remove rows from the target that have no match in the source.

---

## 8. Transactions

A **transaction** is a unit of work that is either committed entirely or rolled back entirely — the ACID atomicity guarantee.

```sql
-- MySQL / PostgreSQL
BEGIN;

UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 500 WHERE account_id = 2;

COMMIT;   -- both changes become permanent
```

If anything goes wrong between BEGIN and COMMIT:

```sql
BEGIN;

UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
-- Error happens here — account 2 doesn't exist

ROLLBACK;  -- account 1's deduction is also reversed
```

### SQL Server syntax

```sql
BEGIN TRANSACTION;

UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 500 WHERE account_id = 2;

COMMIT TRANSACTION;
-- or
ROLLBACK TRANSACTION;
```

### SAVEPOINT — partial rollback

```sql
BEGIN;

INSERT INTO students (...) VALUES (...);
SAVEPOINT after_insert;

UPDATE students SET gpa = 4.00 WHERE student_id = 999;  -- mistake

ROLLBACK TO SAVEPOINT after_insert;  -- undo only the bad UPDATE

COMMIT;  -- keep the INSERT
```

SAVEPOINTs are supported by MySQL and PostgreSQL. SQL Server uses `SAVE TRANSACTION name`.

---

## 9. ACID Properties

| Property | Meaning |
|----------|---------|
| **Atomicity** | All statements in the transaction succeed or all are rolled back |
| **Consistency** | The database moves from one valid state to another |
| **Isolation** | Concurrent transactions cannot see each other's uncommitted changes (level-dependent) |
| **Durability** | Committed changes survive crashes |

---

## 10. Isolation Levels

Isolation levels control what a transaction can see from other concurrent transactions.

### Phenomena that isolation levels prevent:

| Phenomenon | Description |
|-----------|-------------|
| **Dirty read** | Reading uncommitted data from another transaction |
| **Non-repeatable read** | The same row returns different values when read twice in a transaction |
| **Phantom read** | A range query returns different rows when repeated (another transaction inserted/deleted) |

### Standard levels:

| Level | Dirty Read | Non-Repeatable | Phantom |
|-------|-----------|----------------|---------|
| READ UNCOMMITTED | Possible | Possible | Possible |
| READ COMMITTED | ✅ Protected | Possible | Possible |
| REPEATABLE READ | ✅ | ✅ | Possible |
| SERIALIZABLE | ✅ | ✅ | ✅ |

### Platform defaults:

| Platform | Default Level |
|----------|--------------|
| MySQL 8.0 | REPEATABLE READ |
| PostgreSQL 16 | READ COMMITTED |
| SQL Server 2022 | READ COMMITTED |

### Setting isolation level:

```sql
-- MySQL
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- PostgreSQL
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SQL Server
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

---

## 11. Autocommit

By default, most platforms run in **autocommit mode** — every DML statement is immediately committed as its own transaction. To use explicit transactions you must either:
- Wrap statements in `BEGIN … COMMIT`, or
- Disable autocommit (`SET autocommit = 0` in MySQL)

PostgreSQL disables autocommit when you open a transaction block with `BEGIN`.

---

## 12. Returning Modified Rows

### PostgreSQL — RETURNING clause

```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
VALUES ('Yuki', 'Tanaka', 3.88, 2, NOW(), TRUE)
RETURNING student_id, first_name;

-- Also works with UPDATE and DELETE
UPDATE students SET gpa = 3.95 WHERE student_id = 5
RETURNING student_id, first_name, gpa;
```

### SQL Server — OUTPUT clause

```sql
INSERT INTO students (first_name, last_name, gpa, department_id, enrolled_at, is_active)
OUTPUT INSERTED.student_id, INSERTED.first_name
VALUES (N'Yuki', N'Tanaka', 3.88, 2, GETDATE(), 1);

-- With UPDATE
UPDATE students
SET    gpa = 3.95
OUTPUT DELETED.gpa AS old_gpa, INSERTED.gpa AS new_gpa, INSERTED.first_name
WHERE  student_id = 5;
```

MySQL does not have a direct equivalent; use `LAST_INSERT_ID()` for the last auto-increment value.

---

## 13. Common DML Mistakes

| Mistake | Consequence | Prevention |
|---------|-------------|-----------|
| UPDATE without WHERE | Updates every row | Test with SELECT first |
| DELETE without WHERE | Deletes every row | Test with SELECT first; use TRUNCATE deliberately |
| NOT IN with NULL in subquery | Deletes / updates 0 rows | Use NOT EXISTS |
| Forgetting COMMIT | Changes invisible to others | Always pair BEGIN with COMMIT or ROLLBACK |
| TRUNCATE thinking it's rollback-safe | Cannot undo (some platforms) | Use DELETE in a transaction if rollback needed |
| ON DUPLICATE KEY UPDATE changing PK | Error | Never update the primary key column |

---

## 14. Summary

| Statement | Affects | WHERE | Rollback |
|-----------|---------|-------|----------|
| INSERT | New rows | N/A | Yes (in transaction) |
| UPDATE | Existing rows | Recommended | Yes |
| DELETE | Existing rows | Recommended | Yes |
| TRUNCATE | All rows | No | Platform-dependent |
| MERGE | Insert + Update + Delete | Via ON clause | Yes |
