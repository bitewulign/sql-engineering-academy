---
marp: true
theme: default
paginate: true
header: "SQL Engineering Academy · Module 01"
footer: "Database Foundations · © SQL Engineering Academy"
style: |
  section {
    font-family: 'Segoe UI', system-ui, sans-serif;
    font-size: 28px;
  }
  h1 { color: #1a56db; }
  h2 { color: #1e429f; border-bottom: 2px solid #1a56db; padding-bottom: 4px; }
  code { background: #f3f4f6; border-radius: 4px; padding: 2px 6px; }
  pre  { background: #1e293b; color: #e2e8f0; padding: 16px; border-radius: 8px; }
  table { border-collapse: collapse; width: 100%; }
  th   { background: #1a56db; color: white; padding: 8px; }
  td   { border: 1px solid #d1d5db; padding: 8px; }
  .highlight { background: #fef3c7; border-left: 4px solid #f59e0b; padding: 8px 12px; }
---

# Module 01
## Database Foundations

### From Data to Relational Databases

**SQL Engineering Academy**
_All three platforms: SQL Server · PostgreSQL · MySQL_

---

## What You Will Learn

By the end of this module you will be able to:

- Explain what a database is and why we use one
- Describe the relational model and where it comes from
- Identify the four categories of SQL commands
- Write your first queries on all three database systems
- Explain what NULL is and why `NULL = NULL` is **not** TRUE

---

## Data vs. Information

**Data** = raw, unprocessed facts

> `48392, Smith, 2024-03-15, 134.75`

**Information** = data given context and meaning

> Customer #48392 (Smith) placed an order on March 15, 2024 totaling $134.75

A **database** stores data in a structured way so it can be turned into information reliably and repeatedly.

---

## Why Not Just Use a Spreadsheet?

| Need | Spreadsheet | Database |
|------|------------|---------|
| Millions of rows | Slow or impossible | Handles easily |
| Multiple users at once | Conflict risk | Built-in concurrency |
| Enforce data rules | Manual, fragile | Constraints |
| Complex joins across topics | Manual VLOOKUP | Natural |
| Audit trail | None | Transaction log |

A database is not a smarter spreadsheet — it is a different tool.

---

## The Relational Model

**Edgar F. Codd, 1970 — IBM Research**

> *"A Relational Model of Data for Large Shared Data Banks"*

Based on two branches of mathematics:

- **Set theory** — tables are sets; operations on sets (union, intersection, difference) map to SQL clauses
- **Predicate logic** — a WHERE clause is a predicate; rows satisfying it are included

This mathematical foundation is why SQL is *declarative*: you say **what** you want, not **how** to find it.

---

## Anatomy of a Table

```
┌─────────────────────────────────────────────────┐
│  students                    ← TABLE (relation) │
├────────────┬──────────────┬───────────┬─────────┤
│ student_id │ first_name   │ last_name │ gpa     │
│  (column)  │  (column)    │ (column)  │(column) │
├────────────┼──────────────┼───────────┼─────────┤
│    1001    │ Amara        │ Osei      │  3.8    │  ← row
│    1002    │ Priya        │ Sharma    │  3.5    │  ← row
│    1003    │ Carlos       │ Mendez    │  3.9    │  ← row
└────────────┴──────────────┴───────────┴─────────┘
         ↑
  primary key: unique, never NULL
```

Every row is uniquely identified by its **primary key**.

---

## Keys: The Backbone of Relationships

**Primary Key**
- Uniquely identifies each row
- Cannot be NULL
- One per table

**Foreign Key**
- References the primary key of another table
- Enforces *referential integrity* — no orphan rows

```sql
-- You cannot insert a course for instructor_id = 999
-- if that instructor does not exist in the instructors table
```

---

## The Three Platforms

| Feature | SQL Server | PostgreSQL | MySQL |
|---------|-----------|-----------|-------|
| Created by | Microsoft | UC Berkeley | MySQL AB |
| Year | 1989 | 1996 | 1995 |
| Language | T-SQL | PL/pgSQL | MySQL SP |
| License | Commercial | Open source | Open source |
| Best known for | Enterprise Windows | Advanced SQL | Web apps |

All three use **ANSI/ISO SQL** as a base.
Vendor extensions add power — and incompatibility.

---

## Four Categories of SQL

| Category | Full Name | Commands |
|----------|-----------|---------|
| **DDL** | Data Definition Language | CREATE, ALTER, DROP |
| **DML** | Data Manipulation Language | INSERT, UPDATE, DELETE |
| **DQL** | Data Query Language | SELECT |
| **DCL** | Data Control Language | GRANT, REVOKE |

> Every SQL statement you write falls into one of these four buckets.

---

## Your First Query

The most fundamental SQL statement:

```sql
SELECT column1, column2
FROM   table_name
WHERE  condition;
```

- `SELECT` — which columns to return
- `FROM` — which table to read
- `WHERE` — which rows to include (optional)

---

## Checking the Version

Three different functions — same purpose:

```sql
-- SQL Server
SELECT @@VERSION;

-- PostgreSQL
SELECT version();

-- MySQL
SELECT VERSION();
```

> **Pattern:** SQL Server uses `@@global_variable`; PostgreSQL and MySQL use functions. These small syntax differences are everywhere.

---

## Current Date and Time

```sql
-- SQL Server
SELECT GETDATE() AS now,
       CAST(GETDATE() AS DATE) AS today;

-- PostgreSQL
SELECT NOW() AS now,
       CURRENT_DATE AS today;

-- MySQL
SELECT NOW() AS now,
       CURDATE() AS today;
```

Same concept, different function names across all three platforms.

---

## NULL: The Absent Value

`NULL` means **unknown** or **missing** — not zero, not empty string.

<div class="highlight">

**The golden rule:**  
`NULL = NULL` → **NULL** (not TRUE)  
`NULL IS NULL` → **TRUE**

</div>

You cannot test for NULL with `=`. You **must** use `IS NULL`.

```sql
-- WRONG — returns 0 rows even if nulls exist:
SELECT * FROM employees WHERE manager_id = NULL;

-- CORRECT:
SELECT * FROM employees WHERE manager_id IS NULL;
```

---

## Three-Valued Logic

SQL has three truth values:

| Value | Meaning |
|-------|---------|
| `TRUE` | Definitely true |
| `FALSE` | Definitely false |
| `UNKNOWN` | NULL is involved — cannot determine |

A `WHERE` clause only passes rows through when the condition is `TRUE`. Neither `FALSE` nor `UNKNOWN` passes.

> This is why `WHERE col != NULL` also returns nothing — it's UNKNOWN, not TRUE.

---

## COALESCE: The NULL Escape Hatch

`COALESCE()` returns the **first non-NULL** value:

```sql
SELECT COALESCE(NULL, NULL, 'third', 'fourth');
-- Result: 'third'
```

Use it to substitute a default for NULL:

```sql
SELECT
    employee_name,
    COALESCE(bonus, 0) AS bonus_or_zero
FROM employees;
```

---

## String Concatenation: Three Ways

```sql
-- SQL Server: use + (NULL + anything = NULL)
SELECT 'Hello' + ', ' + 'World!';

-- PostgreSQL: use || (NULL || anything = NULL)
SELECT 'Hello' || ', ' || 'World!';

-- MySQL: use CONCAT() (NULL makes the whole result NULL!)
SELECT CONCAT('Hello', ', ', 'World!');

-- All three: CONCAT() — but NULL behavior differs!
-- PostgreSQL/SQL Server: CONCAT ignores NULL
-- MySQL: CONCAT returns NULL if any argument is NULL
```

---

## Paginating Results

Returning a "page" of results:

```sql
-- SQL Server (ANSI — works on all three modern systems)
SELECT * FROM products
ORDER BY product_id
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;

-- SQL Server also: TOP (not in PG or MySQL)
SELECT TOP 10 * FROM products;

-- PostgreSQL and MySQL: LIMIT / OFFSET
SELECT * FROM products
ORDER BY product_id
LIMIT 10 OFFSET 20;
```

> Always pair pagination with `ORDER BY` — without it, the "page" returned is undefined.

---

## System Catalogs

Every platform ships with a metadata database:

```sql
-- ANSI standard — works on all three:
SELECT table_name
FROM   information_schema.tables
WHERE  table_type = 'BASE TABLE'
ORDER BY table_name;

-- SQL Server native:
SELECT name FROM sys.databases;

-- PostgreSQL native:
SELECT datname FROM pg_database;

-- MySQL native:
SHOW DATABASES;
SHOW TABLES;
```

---

## Platform Comparison: Quick Reference

| Feature | SQL Server | PostgreSQL | MySQL |
|---------|-----------|-----------|-------|
| `NULL = NULL` result | NULL | NULL | NULL |
| `NULL <=> NULL` | — | — | 1 (TRUE) |
| `CONCAT(x, NULL)` | x | x | NULL |
| Integer division `1/2` | 0 | 0 | 0 |
| NULL-safe equals | — | `IS NOT DISTINCT FROM` | `<=>` |
| Pagination | `TOP` / `OFFSET-FETCH` | `LIMIT/OFFSET` | `LIMIT/OFFSET` |

---

## Common Mistakes to Avoid

1. **Testing for NULL with `=`**  
   Use `IS NULL` / `IS NOT NULL`

2. **Forgetting ORDER BY with LIMIT/TOP**  
   Without it, results are non-deterministic

3. **Assuming integer division gives decimals**  
   `1 / 2 = 0` on all three — use `1.0 / 2`

4. **Using `||` for string concat in MySQL**  
   In MySQL `||` means logical OR — use `CONCAT()`

5. **Assuming `CONCAT()` behavior is identical**  
   It is not — MySQL returns NULL when any arg is NULL

---

## Module 01 Summary

You now understand:

✓ Why relational databases exist and what problem they solve  
✓ The relational model: tables, rows, columns, keys  
✓ How SQL Server, PostgreSQL, and MySQL relate to each other  
✓ The four categories of SQL commands (DDL / DML / DQL / DCL)  
✓ NULL as unknown — and how to test for it correctly  
✓ Your first queries across all three platforms  
✓ Key syntax differences between the three systems  

---

## What Is Coming Next

**Module 02** — Creating Tables and Inserting Data

- `CREATE TABLE` with appropriate data types
- `INSERT INTO` values
- Platform-specific data types (VARCHAR vs TEXT, INT vs SERIAL, etc.)
- `UPDATE` and `DELETE`
- The importance of transactions

Track A (MySQL) · Track B (PostgreSQL) · Track C (SQL Server)

---

## Before You Move On

Complete in order:

1. `code/` — Run all three SQL files (SQL Server, PostgreSQL, MySQL)
2. `labs/lab-01-guided.md` — Connect and run queries on all three systems
3. `exercises/exercises-01.md` — 18 exercises (beginners → challenges)
4. `assessments/quiz-01.md` — 15 questions, pass = 11/15
5. Check your answers: `solutions/solutions-01.md`

**Module 02 is waiting.**

---

# Questions?

**Resources for this module:**
- Lecture notes: `modules/module-01/lecture-notes.md`
- Code examples: `modules/module-01/code/`
- Further reading: `modules/module-01/resources/references.md`

**Community:**
- GitHub Discussions: raise questions, share insights
- Issues: report errors or suggest improvements

_SQL Engineering Academy_
