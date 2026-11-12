# Module 09 — References
## Schema Design & DDL

---

## Official Documentation

| Platform | Topic | URL |
|----------|-------|-----|
| MySQL 8.0 | CREATE TABLE | https://dev.mysql.com/doc/refman/8.0/en/create-table.html |
| MySQL 8.0 | ALTER TABLE | https://dev.mysql.com/doc/refman/8.0/en/alter-table.html |
| MySQL 8.0 | CREATE INDEX | https://dev.mysql.com/doc/refman/8.0/en/create-index.html |
| MySQL 8.0 | Data types | https://dev.mysql.com/doc/refman/8.0/en/data-types.html |
| MySQL 8.0 | CHECK constraint | https://dev.mysql.com/doc/refman/8.0/en/create-table-check-constraints.html |
| PostgreSQL 16 | CREATE TABLE | https://www.postgresql.org/docs/16/sql-createtable.html |
| PostgreSQL 16 | ALTER TABLE | https://www.postgresql.org/docs/16/sql-altertable.html |
| PostgreSQL 16 | CREATE INDEX | https://www.postgresql.org/docs/16/sql-createindex.html |
| PostgreSQL 16 | Data types | https://www.postgresql.org/docs/16/datatype.html |
| PostgreSQL 16 | Partial indexes | https://www.postgresql.org/docs/16/indexes-partial.html |
| SQL Server 2022 | CREATE TABLE | https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql |
| SQL Server 2022 | ALTER TABLE | https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-table-transact-sql |
| SQL Server 2022 | CREATE INDEX | https://learn.microsoft.com/en-us/sql/t-sql/statements/create-index-transact-sql |
| SQL Server 2022 | Data types | https://learn.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql |
| SQL Server 2022 | Filtered indexes | https://learn.microsoft.com/en-us/sql/relational-databases/indexes/create-filtered-indexes |

---

## Auto-Increment / Identity Column Reference

| Feature | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|---------|-----------|--------------|----------------|
| Keyword | `AUTO_INCREMENT` | `SERIAL` or `GENERATED ALWAYS AS IDENTITY` | `IDENTITY(seed, increment)` |
| Get last inserted ID | `LAST_INSERT_ID()` | `RETURNING id` | `SCOPE_IDENTITY()` |
| Session-wide last ID | `LAST_INSERT_ID()` | `currval('seq')` | `@@IDENTITY` (avoid — trigger-unsafe) |
| Reset sequence | `ALTER TABLE t AUTO_INCREMENT = 1` | `setval('t_id_seq', 1, FALSE)` | `DBCC CHECKIDENT ('t', RESEED, 0)` |

---

## Data Type Quick Reference

| Category | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|----------|-----------|--------------|----------------|
| Small integer | `TINYINT` (1B) | `SMALLINT` | `TINYINT` (0–255) |
| Standard integer | `INT` (4B) | `INTEGER` / `INT4` | `INT` (4B) |
| Large integer | `BIGINT` (8B) | `BIGINT` / `INT8` | `BIGINT` (8B) |
| Exact decimal | `DECIMAL(p,s)` | `NUMERIC(p,s)` | `DECIMAL(p,s)` |
| Boolean | `TINYINT(1)` | `BOOLEAN` | `BIT` |
| Variable ASCII text | `VARCHAR(n)` | `VARCHAR(n)` | `VARCHAR(n)` |
| Variable Unicode text | `VARCHAR(n)` (utf8mb4) | `VARCHAR(n)` (always Unicode) | `NVARCHAR(n)` |
| Timestamp with TZ | `TIMESTAMP` (auto UTC) | `TIMESTAMPTZ` | `DATETIMEOFFSET` |
| Timestamp without TZ | `DATETIME` | `TIMESTAMP` | `DATETIME2` |
| JSON | `JSON` | `JSONB` (indexed) | `NVARCHAR(MAX)` + `ISJSON()` |
| Auto-increment int | `INT AUTO_INCREMENT` | `SERIAL` | `INT IDENTITY(1,1)` |

---

## Normalization Summary

| Form | Requires | Removes |
|------|----------|---------|
| 1NF | Atomic values + unique rows | Repeating groups, multi-valued cells |
| 2NF | 1NF + no partial dependencies | Non-key columns that depend on part of composite PK |
| 3NF | 2NF + no transitive dependencies | Non-key columns that depend on another non-key column |
| BCNF | 3NF + every determinant is a candidate key | Anomalies that 3NF allows in special cases |

---

## Constraint Quick Reference

| Constraint | Syntax (MySQL/PG) | Auto-creates index? |
|-----------|------------------|-------------------|
| PRIMARY KEY | `PRIMARY KEY (col)` | Yes (clustered in SQL Server) |
| UNIQUE | `UNIQUE (col)` or `ADD CONSTRAINT name UNIQUE (col)` | Yes |
| FOREIGN KEY | `FOREIGN KEY (col) REFERENCES t(col)` | No (add manually in MySQL) |
| CHECK | `CHECK (expr)` | No |
| NOT NULL | `col TYPE NOT NULL` | No |
| DEFAULT | `col TYPE DEFAULT value` | No |

---

## Index Types by Platform

| Type | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|------|-----------|--------------|----------------|
| Default B-Tree | `CREATE INDEX` | `CREATE INDEX` | `CREATE NONCLUSTERED INDEX` |
| Unique | `CREATE UNIQUE INDEX` | `CREATE UNIQUE INDEX` | `CREATE UNIQUE NONCLUSTERED INDEX` |
| Composite | `idx (a, b, c)` | `idx (a, b, c)` | `idx (a, b, c)` |
| Covering | Add all cols to key | `INCLUDE (col1, col2)` | `INCLUDE (col1, col2)` |
| Partial / filtered | Not supported natively | `WHERE condition` | `WHERE condition` |
| Descending | `col DESC` in key | `col DESC` in key | `col DESC` in key |

---

## ALTER TABLE Cheat Sheet

| Operation | MySQL 8.0 | PostgreSQL 16 | SQL Server 2022 |
|-----------|-----------|--------------|----------------|
| Add column | `ADD COLUMN col TYPE` | `ADD COLUMN col TYPE` | `ADD col TYPE` |
| Drop column | `DROP COLUMN col` | `DROP COLUMN col` | `DROP COLUMN col` |
| Rename column | `RENAME COLUMN old TO new` | `RENAME COLUMN old TO new` | `EXEC sp_rename 't.old', 'new', 'COLUMN'` |
| Change type | `MODIFY COLUMN col NEWTYPE` | `ALTER COLUMN col TYPE NEWTYPE` | `ALTER COLUMN col NEWTYPE` |
| Add constraint | `ADD CONSTRAINT name …` | `ADD CONSTRAINT name …` | `ADD CONSTRAINT name …` |
| Drop constraint | `DROP CONSTRAINT name` | `DROP CONSTRAINT name` | `DROP CONSTRAINT name` |
| Drop UNIQUE | `DROP INDEX name` | `DROP CONSTRAINT name` | `DROP CONSTRAINT name` |
| Drop CHECK | `DROP CHECK name` | `DROP CONSTRAINT name` | `DROP CONSTRAINT name` |

---

## Safe DROP Order

Always drop **child** tables before **parent** tables:

```sql
-- Given: students → departments, enrollments → students, enrollments → courses
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS departments;
```

Or drop the FOREIGN KEY constraint first:
```sql
ALTER TABLE students DROP FOREIGN KEY fk_std_dept;  -- MySQL
ALTER TABLE students DROP CONSTRAINT fk_std_dept;   -- PG / SQL Server
-- Now you can drop in any order
```

---

## Recommended Reading

- *Database Design for Mere Mortals* (Michael Hernandez) — normalization chapters
- *SQL Antipatterns* (Bill Karwin) — Chapter 1: Jaywalking (1NF violations)
- PostgreSQL Documentation — Chapter 5: Data Definition: https://www.postgresql.org/docs/16/ddl.html
- MySQL Documentation — Section 11: Data Types: https://dev.mysql.com/doc/refman/8.0/en/data-types.html
- Use The Index, Luke (Markus Winand) — free index guide: https://use-the-index-luke.com
