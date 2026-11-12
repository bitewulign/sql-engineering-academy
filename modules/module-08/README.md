# Module 08 — Data Modification

**Track:** Core SQL (all platforms)  
**Prerequisites:** Module 05 (Joins), Module 06 (Subqueries)  
**Estimated study time:** 5–6 hours

---

## Learning Objectives

By the end of this module you will be able to:

- Insert single and multiple rows using `INSERT INTO … VALUES`
- Populate a table from a query with `INSERT INTO … SELECT`
- Update rows with single-table and multi-table (joined) `UPDATE`
- Delete rows safely with `DELETE` and understand `TRUNCATE`
- Write an UPSERT — insert or update on conflict — using `MERGE` (SQL Server), `ON CONFLICT` (PostgreSQL), and `ON DUPLICATE KEY UPDATE` (MySQL)
- Wrap statements in a transaction (`BEGIN` / `COMMIT` / `ROLLBACK`)
- Explain the four standard isolation levels and choose the right one

---

## Files in This Module

| File | Description |
|------|-------------|
| `README.md` | This file |
| `lecture-notes.md` | Concept explanations with annotated SQL |
| `code/mysql/08_dml.sql` | MySQL 8.0 runnable examples |
| `code/postgresql/08_dml.sql` | PostgreSQL 16 runnable examples |
| `code/sql-server/08_dml.sql` | SQL Server 2022 runnable examples |
| `exercises/exercises-08.md` | Practice problems (beginner → challenge) |
| `assessments/quiz-08.md` | 15-question multiple-choice quiz |
| `solutions/solutions-08.md` | Full exercise solutions with explanations |
| `labs/lab-08-guided.md` | Step-by-step guided lab (all 3 platforms) |
| `resources/references.md` | Official docs, books, quick-reference tables |
| `slides/module-08-slides.md` | Marp presentation slides |

---

## Key Concepts

### DML vs DDL

| Category | Statements | Effect |
|----------|-----------|--------|
| DML (Data Manipulation Language) | INSERT, UPDATE, DELETE, MERGE | Change row data |
| DDL (Data Definition Language) | CREATE, ALTER, DROP, TRUNCATE | Change schema structure |

> Note: TRUNCATE is DDL on most platforms — it cannot be rolled back in some configurations.

### INSERT Variants

```sql
-- Single row
INSERT INTO students (first_name, last_name, gpa, department_id)
VALUES ('Amara', 'Diallo', 3.90, 1);

-- Multiple rows
INSERT INTO students (first_name, last_name, gpa, department_id)
VALUES ('Priya', 'Sharma', 3.85, 2),
       ('Carlos', 'Reyes', 3.70, 1);

-- From query
INSERT INTO students_archive
SELECT * FROM students WHERE is_active = 0;
```

### UPDATE Safety Rule

Always test with SELECT before UPDATE:

```sql
-- Step 1: verify what will be changed
SELECT * FROM students WHERE department_id = 3;

-- Step 2: apply the change
UPDATE students SET gpa = gpa + 0.05 WHERE department_id = 3;
```

### DELETE vs TRUNCATE

| | DELETE | TRUNCATE |
|-|--------|----------|
| Filters rows | Yes (WHERE clause) | No — removes all rows |
| Logged | Yes (row-by-row) | Minimal (page deallocation) |
| Triggers fire | Yes | No (most platforms) |
| Rollback | Yes | Platform-dependent |
| Resets AUTO_INCREMENT | No | Yes (MySQL) |

### UPSERT by Platform

| Platform | Syntax |
|----------|--------|
| MySQL 8.0 | `INSERT … ON DUPLICATE KEY UPDATE` |
| PostgreSQL 16 | `INSERT … ON CONFLICT (col) DO UPDATE SET` |
| SQL Server 2022 | `MERGE target USING source ON … WHEN MATCHED THEN UPDATE … WHEN NOT MATCHED THEN INSERT` |

### Transaction Control

```sql
BEGIN;           -- MySQL / PostgreSQL
-- or
BEGIN TRANSACTION;  -- SQL Server

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;          -- make permanent
-- or
ROLLBACK;        -- undo all changes since BEGIN
```

---

## Isolation Levels

| Level | Dirty Read | Non-Repeatable Read | Phantom Read |
|-------|-----------|-------------------|-------------|
| READ UNCOMMITTED | Possible | Possible | Possible |
| READ COMMITTED | Protected | Possible | Possible |
| REPEATABLE READ | Protected | Protected | Possible |
| SERIALIZABLE | Protected | Protected | Protected |

Default: MySQL = REPEATABLE READ · PostgreSQL = READ COMMITTED · SQL Server = READ COMMITTED

---

## Module 09 Preview

**Schema Design** — normalization (1NF, 2NF, 3NF), primary and foreign keys, indexes, constraints, and CREATE TABLE syntax.
