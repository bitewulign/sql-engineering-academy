# Module 01 — Lecture Notes
# Database Foundations and Introduction to SQL

---

## 1. Concept and Definition

### What is data?

**Data** is raw, unprocessed facts. Numbers, names, dates, measurements.

Examples:
- `42`, `"Toronto"`, `2026-11-11`, `99.99`

**Information** is data that has been given meaning through context.

- 42 → 42 students enrolled in the course
- "Toronto" → the city where the student lives
- 2026-11-11 → the date the student enrolled

A **database** is an organized, structured collection of related data stored and accessed electronically.

A **Database Management System (DBMS)** is the software that manages a database — it handles storing, retrieving, updating, and securing data, enforcing rules, managing concurrent users, and recovering from failures.

---

## 2. What is a Relational Database?

A **Relational Database Management System (RDBMS)** organizes data into **tables** — two-dimensional grids of rows and columns — and links those tables through shared values.

The relational model was invented by **Edgar F. Codd** at IBM in 1970. His paper "A Relational Model of Data for Large Shared Data Banks" established the mathematical foundation that all modern RDBMSs are built on. Codd based his model on **set theory** and **predicate logic**.

The key insight: data should be described by its logical meaning, not by how it is physically stored. You ask "give me all students in Engineering" — not "open file 3, seek to byte 4096, read 200 bytes."

---

## 3. The Core Concepts: Tables, Rows, Columns, Keys

### Table (Relation)

A table stores one type of entity — one kind of thing.

```
students
┌────────────────────────────────────────────┐
│ student_id │ first_name │ last_name │ gpa  │
├────────────────────────────────────────────┤
│ 1          │ Amara      │ Osei      │ 3.8  │
│ 2          │ Jordan     │ Kim       │ 3.5  │
│ 3          │ Fatima     │ Al-Rashid │ 3.9  │
└────────────────────────────────────────────┘
```

A table has:
- A **name** (students)
- A fixed set of **columns** (student_id, first_name, last_name, gpa)
- Zero or more **rows** of data

### Row (Record / Tuple)

One row = one instance of the entity.

`1 | Amara | Osei | 3.8` is one student.

### Column (Attribute / Field)

One column = one property of the entity.

`gpa` is one attribute. Every row has a value for every column (or NULL if unknown).

### Primary Key

A **primary key** uniquely identifies each row. No two rows can share a primary key value. A primary key can never be NULL.

`student_id` is the primary key of `students`. Even if two students happen to have the same name, their student_id values are different.

### Foreign Key

A **foreign key** in one table refers to the primary key of another table. It is how tables are linked.

```
enrollments
┌──────────────────────────────────────┐
│ enrollment_id │ student_id │ course_id│
├──────────────────────────────────────┤
│ 1             │ 1          │ 101      │
│ 2             │ 1          │ 102      │
│ 3             │ 2          │ 101      │
└──────────────────────────────────────┘
```

`student_id` in `enrollments` is a foreign key referencing `student_id` in `students`. You cannot enroll a student who does not exist.

---

## 4. DBMS vs RDBMS vs NoSQL

| Feature | DBMS (generic) | RDBMS | NoSQL |
|---------|----------------|-------|-------|
| Data model | Various | Tables (relations) | Documents, key-value, graph, column-family |
| Relationships | Optional | Required — enforced by keys | Usually not enforced |
| SQL | Not always | Yes | Usually not (some have SQL-like query languages) |
| ACID transactions | Not always | Yes | Partial (varies by system) |
| Schema | Varies | Strict, defined up front | Often flexible or schema-less |
| Best for | Various | Structured business data | Unstructured, high-volume, distributed systems |
| Examples | Early file systems | SQL Server, PostgreSQL, MySQL, Oracle | MongoDB, Cassandra, Redis, DynamoDB |

---

## 5. The Three Platforms You Will Master

### Microsoft SQL Server 2022

- First released: 1989 (joint project: Microsoft + Sybase + Ashton-Tate)
- Language extension: **T-SQL** (Transact-SQL)
- Primary environment: Windows, Azure (Linux supported since 2017)
- Major users: enterprises, financial institutions, healthcare, government
- Free edition: Developer Edition (full features, non-production use)
- Key tools: SQL Server Management Studio (SSMS), Azure Data Studio
- Identifier quoting: `[square brackets]`
- Get current date: `GETDATE()` or `SYSDATETIME()`
- Limit rows: `SELECT TOP 10 ...`
- Known for: deep Windows integration, SQL Server Agent, Always On AG, Query Store

### PostgreSQL 16

- Descended from POSTGRES at UC Berkeley (1986), open source since 1996
- Language extension: **PL/pgSQL** (Procedural Language/PostgreSQL Stored Procedures Language)
- Cross-platform: Linux, macOS, Windows, BSD
- Known for: standards compliance, extensibility (1,000+ extensions), advanced types (arrays, JSONB, geospatial via PostGIS), strong MVCC implementation
- Free: open source (PostgreSQL License — very permissive)
- Key tools: pgAdmin 4, psql, DBeaver
- Identifier quoting: `"double quotes"`
- Get current date: `NOW()` or `CURRENT_TIMESTAMP`
- Limit rows: `SELECT ... LIMIT 10`
- Known for: PostGIS, JSONB, table inheritance, partial indexes, GIN/GiST/BRIN indexes

### MySQL 8.0

- First released: 1995 by MySQL AB; acquired by Sun (2008), Oracle (2010)
- Language extension: **MySQL Stored Program language** (for procedures, functions, triggers)
- Cross-platform: Linux, Windows, macOS
- Dominant in: web applications (LAMP/LEMP stack), WordPress, many SaaS platforms
- MariaDB is a community fork of MySQL — largely compatible
- Free: MySQL Community Server (GPL)
- Key tools: MySQL Workbench, mysql CLI, DBeaver
- Identifier quoting: `` `backticks` ``
- Get current date: `NOW()` or `CURDATE()`
- Limit rows: `SELECT ... LIMIT 10`
- Known for: performance on read-heavy web workloads, Group Replication, InnoDB Cluster

---

## 6. SQL: History and Standard

**SQL** (Structured Query Language) was developed in the 1970s at IBM, originally called SEQUEL. It became:
- ANSI standard: 1986
- ISO standard: 1987
- Current standard: SQL:2023

Each database vendor implements the SQL standard plus their own proprietary extensions:

| Standard SQL | T-SQL addition | PL/pgSQL addition | MySQL addition |
|-------------|---------------|------------------|---------------|
| SELECT | TOP | LIMIT (not standard, but SQL 2008 added FETCH FIRST) | LIMIT |
| CASE WHEN | IIF(), CHOOSE() | — | IF() |
| CAST() | CONVERT() | — | — |
| Standard procedures | T-SQL blocks | PL/pgSQL blocks | MySQL stored programs |

**Rule of thumb for this curriculum:** We always show the ANSI standard form first, then the platform-specific implementation.

---

## 7. The Four SQL Command Categories

```
SQL
├── DQL  — Data Query Language      → SELECT
├── DML  — Data Manipulation Language → INSERT, UPDATE, DELETE, MERGE
├── DDL  — Data Definition Language  → CREATE, ALTER, DROP, TRUNCATE
└── DCL  — Data Control Language     → GRANT, REVOKE
```

(Some sources also list TCL — Transaction Control Language: COMMIT, ROLLBACK, SAVEPOINT — as a fifth category.)

This curriculum begins with DQL (SELECT) in modules 03–08, then DML in modules 05–06, DDL in module 04, and DCL in the security modules.

---

## 8. NULL: The Most Misunderstood Value in SQL

**NULL means unknown or missing.** It does not mean zero. It does not mean empty string. It means "we do not know the value."

```
NULL ≠ 0
NULL ≠ ""
NULL ≠ NULL
```

The last point surprises many beginners: `NULL = NULL` evaluates to `NULL` (unknown), not `TRUE`.

```sql
-- This returns nothing — the WHERE condition is UNKNOWN, not TRUE
SELECT * FROM students WHERE gpa = NULL;

-- Correct way to find NULL values:
SELECT * FROM students WHERE gpa IS NULL;

-- Correct way to find non-NULL values:
SELECT * FROM students WHERE gpa IS NOT NULL;
```

---

## 9. Your First SQL Queries

### The simplest SELECT

```sql
-- SQL Server
SELECT 'Hello, SQL Server!';
SELECT @@VERSION;
SELECT GETDATE() AS current_datetime;

-- PostgreSQL
SELECT 'Hello, PostgreSQL!';
SELECT version();
SELECT NOW() AS current_datetime;

-- MySQL
SELECT 'Hello, MySQL!';
SELECT VERSION();
SELECT NOW() AS current_datetime;
```

### A SELECT with arithmetic

```sql
-- Calculate a 15% tip on a $48.50 meal (same syntax on all three systems)
SELECT 48.50 AS meal_price,
       48.50 * 0.15 AS tip_amount,
       48.50 * 1.15 AS total_with_tip;
```

### A SELECT with string concatenation

```sql
-- SQL Server: use + for strings
SELECT 'First name: ' + 'Amara' AS full_label;

-- PostgreSQL: use || (double pipe)
SELECT 'First name: ' || 'Amara' AS full_label;

-- MySQL: use CONCAT()
SELECT CONCAT('First name: ', 'Amara') AS full_label;

-- All three support CONCAT():
SELECT CONCAT('First', ' ', 'Last') AS full_name;
```

---

## 10. Performance Considerations at This Stage

There are none yet — single-table queries on small datasets run in microseconds regardless of how they are written. Performance becomes important starting in Module 08 (indexes) and Module 12/29/47 (query optimization).

The one habit to build now: **always give your columns meaningful aliases** (`AS column_name`) so results are readable. Unnamed expressions appear as `(No column name)` in SQL Server and confusingly automatic names in PostgreSQL and MySQL.

---

## 11. Common Mistakes

1. **Using `= NULL` instead of `IS NULL`:** Comparison to NULL using `=` always returns NULL (unknown), never TRUE. Use `IS NULL` and `IS NOT NULL`.

2. **Assuming syntax is identical across platforms:** `SELECT TOP 5 ...` works in SQL Server but not in PostgreSQL or MySQL. `LIMIT 5` works in PostgreSQL and MySQL but not (before SQL Server 2012) in SQL Server. Always check the platform.

3. **Confusing the SQL standard with a vendor dialect:** When you read documentation, check whether it describes ANSI SQL or a specific product. T-SQL documentation from Microsoft does not apply to PostgreSQL.

4. **Case sensitivity confusion:** SQL keywords (`SELECT`, `FROM`, `WHERE`) are case-insensitive in all three systems. Table and column names are also case-insensitive in SQL Server (by default) and MySQL (on Windows), but case-sensitive in PostgreSQL and MySQL on Linux.

5. **Forgetting semicolons:** SQL statements end with `;`. SSMS is forgiving about this in many contexts. psql and mysql CLI require it. Build the habit now.

---

## 12. Key Vocabulary

| Term | Definition |
|------|-----------|
| Database | Organized collection of related data |
| DBMS | Software that manages a database |
| RDBMS | DBMS where data is organized into relational tables |
| Table | A named, two-dimensional structure of rows and columns |
| Row / Record / Tuple | One instance of an entity |
| Column / Attribute / Field | One property of an entity |
| Primary key | Column(s) that uniquely identify each row; cannot be NULL |
| Foreign key | Column(s) that reference the primary key of another table |
| NULL | Unknown or missing value; not equal to anything |
| SQL | Structured Query Language — the standard language for RDBMS |
| T-SQL | Microsoft's SQL Server extension of SQL |
| PL/pgSQL | PostgreSQL's procedural extension of SQL |
| DQL | Data Query Language — SELECT |
| DML | Data Manipulation Language — INSERT, UPDATE, DELETE |
| DDL | Data Definition Language — CREATE, ALTER, DROP |
| DCL | Data Control Language — GRANT, REVOKE |
| Schema | The structure of a database — tables, columns, data types, constraints |
| ANSI SQL | The international standard for SQL |
