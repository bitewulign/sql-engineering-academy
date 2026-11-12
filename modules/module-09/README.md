# Module 09 — Schema Design & DDL

## Learning Objectives

By the end of this module you will be able to:

1. Explain the purpose of normalization and apply 1NF, 2NF, and 3NF to a table design
2. Write `CREATE TABLE` statements with appropriate data types, constraints, and defaults
3. Define and enforce PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, and CHECK constraints
4. Create B-Tree, composite, partial, and covering indexes
5. Modify an existing table using `ALTER TABLE`
6. Drop tables and indexes safely
7. Understand platform differences in AUTO_INCREMENT, SERIAL, and IDENTITY columns

---

## Why Schema Design Matters

A well-designed schema:
- Eliminates redundant data storage (normalization)
- Enforces data integrity at the database level (constraints)
- Enables the query planner to find rows quickly (indexes)
- Makes DML safer — a CHECK constraint catches bad data before it lands

A poorly designed schema causes cascading problems: bad joins, UPDATE anomalies, phantom duplicates, and slow queries that no index can fix.

---

## Normalization Quick Reference

| Form | Rule | Violation Example | Fix |
|------|------|-------------------|-----|
| **1NF** | No repeating groups; each cell holds one atomic value | `phones = "555-1234, 555-5678"` | Separate `phones` table |
| **2NF** | 1NF + no partial dependency on composite PK | `order_detail(order_id, product_id, product_name)` — `product_name` depends only on `product_id` | Move `product_name` to `products` |
| **3NF** | 2NF + no transitive dependency | `students(student_id, dept_id, dept_name)` — `dept_name` depends on `dept_id`, not `student_id` | Move `dept_name` to `departments` |

---

## Data Types by Platform

| Category | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|----------|-----------|--------------|----------------|
| Integer (auto) | `INT AUTO_INCREMENT` | `SERIAL` or `INT GENERATED ALWAYS AS IDENTITY` | `INT IDENTITY(1,1)` |
| Variable text | `VARCHAR(n)` | `VARCHAR(n)` or `TEXT` | `VARCHAR(n)` or `NVARCHAR(n)` |
| Unicode text | `VARCHAR(n)` (utf8mb4) | `VARCHAR(n)` (always Unicode) | `NVARCHAR(n)` |
| Decimal | `DECIMAL(p,s)` | `NUMERIC(p,s)` | `DECIMAL(p,s)` |
| Boolean | `TINYINT(1)` | `BOOLEAN` | `BIT` |
| Date | `DATE` | `DATE` | `DATE` |
| Timestamp | `DATETIME` or `TIMESTAMP` | `TIMESTAMPTZ` | `DATETIME2` |
| JSON | `JSON` | `JSONB` | `NVARCHAR(MAX)` + `ISJSON()` |

---

## Constraints

| Constraint | Purpose |
|-----------|---------|
| `PRIMARY KEY` | Uniquely identifies each row; implies NOT NULL + UNIQUE index |
| `FOREIGN KEY` | Enforces referential integrity between tables |
| `UNIQUE` | Prevents duplicate values in one or more columns |
| `NOT NULL` | Rejects NULL inserts/updates |
| `CHECK` | Rejects rows that fail a boolean expression |
| `DEFAULT` | Supplies a value when none is provided |

---

## Indexes

| Type | Use Case |
|------|---------|
| B-Tree (default) | Equality, range, ORDER BY, JOIN |
| Composite | Queries filtering on multiple columns |
| Covering | Avoid table lookup — include all needed columns |
| Partial (PG/SS) | Index only a subset of rows (e.g., `WHERE is_active = TRUE`) |
| Unique index | Enforce uniqueness without a formal UNIQUE constraint |

> Every PRIMARY KEY and UNIQUE constraint automatically creates an index.

---

## Module Files

| File | Description |
|------|-------------|
| `lecture-notes.md` | Full conceptual coverage with annotated code |
| `code/mysql/09_ddl.sql` | MySQL 8.0 DDL examples |
| `code/postgresql/09_ddl.sql` | PostgreSQL 16 DDL examples |
| `code/sql-server/09_ddl.sql` | SQL Server 2022 DDL examples |
| `exercises/exercises-09.md` | 10 beginner + 5 intermediate + 3 challenges + 8 IQs |
| `assessments/quiz-09.md` | 15-question multiple-choice quiz |
| `solutions/solutions-09.md` | Full solutions (instructor only) |
| `labs/lab-09-guided.md` | Guided lab — 3 platforms |
| `resources/references.md` | Quick-reference tables and official docs |
| `slides/module-09-slides.md` | 20 Marp slides |

---

## Prerequisites

- Module 03 (SELECT fundamentals)
- Module 05 (JOINs — understanding FK relationships)
- Module 08 (DML — you will ALTER tables that contain data)

## Next Module

**Module 10 — Subqueries & CTEs:** correlated subqueries, scalar subqueries, EXISTS/NOT EXISTS, WITH clause, recursive CTEs.
