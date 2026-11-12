# Glossary

Key terms used throughout SQL Engineering Academy, defined in plain language.

---

## A

**Aggregate function**  
A function that takes a set of rows and returns a single value. Examples: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`.

**ANSI SQL**  
The version of SQL standardized by the American National Standards Institute (and ISO). SQL Server, PostgreSQL, and MySQL all implement ANSI SQL with their own extensions.

**AUTO_INCREMENT** (MySQL)  
A column property that automatically assigns the next integer value when a row is inserted. The PostgreSQL equivalent is `SERIAL` or a sequence; in SQL Server it is `IDENTITY`.

---

## C

**Cardinality**  
The number of distinct values in a column. High cardinality = many unique values (e.g., email addresses). Low cardinality = few unique values (e.g., a status column with three possible values). Affects index performance.

**Catalog**  
The metadata database that stores information about tables, columns, indexes, and users. Accessible via `INFORMATION_SCHEMA` (all three platforms) or platform-specific system views (`sys.*` on SQL Server, `pg_catalog` on PostgreSQL).

**Collation**  
The rules for comparing and sorting text: case sensitivity, accent sensitivity, and locale. `ci` = case-insensitive; `cs` = case-sensitive.

**Column**  
A single attribute in a table (also called a field or attribute). All values in a column share the same data type.

**Constraint**  
A rule enforced by the database on table data. Types: `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, `CHECK`.

**CTE (Common Table Expression)**  
A named, temporary result set defined with `WITH` and used within a single query. Makes complex queries more readable and can be recursive.

```sql
WITH dept_counts AS (
    SELECT department_id, COUNT(*) AS headcount
    FROM employees
    GROUP BY department_id
)
SELECT * FROM dept_counts WHERE headcount > 5;
```

---

## D

**Data type**  
The kind of value a column can hold: integer, decimal, text, date, boolean, etc. Each platform has its own type names and ranges.

**DCL (Data Control Language)**  
SQL commands for managing permissions: `GRANT`, `REVOKE`.

**DDL (Data Definition Language)**  
SQL commands for defining and modifying database structure: `CREATE`, `ALTER`, `DROP`, `TRUNCATE`.

**DML (Data Manipulation Language)**  
SQL commands for modifying data: `INSERT`, `UPDATE`, `DELETE`, `MERGE`.

**DQL (Data Query Language)**  
SQL commands for querying data: `SELECT`.

---

## E

**Entity**  
A real-world object or concept represented as a table (e.g., Customer, Product, Order).

**ER Diagram (Entity-Relationship Diagram)**  
A visual representation of database tables and their relationships.

---

## F

**Foreign key**  
A column (or set of columns) in one table that references the primary key of another table, enforcing referential integrity.

**Full outer join**  
Returns all rows from both tables, with NULL where there is no match on either side.

---

## G

**GROUP BY**  
A clause that collapses rows with the same value in specified columns into a single row for use with aggregate functions.

---

## H

**HAVING**  
A clause that filters the result of a `GROUP BY` after aggregation (like WHERE, but for groups).

---

## I

**Index**  
A data structure that speeds up queries at the cost of additional storage and slower writes. A table scan reads every row; an index allows targeted row lookup.

**Inner join**  
Returns only rows that have matching values in both tables.

**INFORMATION_SCHEMA**  
A set of read-only views defined by the ANSI SQL standard that expose metadata about tables, columns, and other database objects. Available on all three platforms.

---

## J

**Join**  
An operation that combines rows from two or more tables based on a related column.

---

## L

**Left join (LEFT OUTER JOIN)**  
Returns all rows from the left table, plus matching rows from the right table. Right-side columns are NULL when there is no match.

---

## N

**Normalization**  
The process of organizing tables to reduce data redundancy and improve integrity. First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF) are the most common targets.

**NULL**  
The absence of a known value. NULL is not zero, not an empty string, and not false. Any comparison with NULL returns NULL (UNKNOWN) — use `IS NULL` to test for it.

---

## P

**PL/pgSQL**  
PostgreSQL's procedural extension of SQL, used to write stored procedures, functions, and triggers with control flow (IF, LOOP, EXCEPTION).

**Primary key**  
A column or set of columns that uniquely identifies each row in a table. Must be unique and NOT NULL.

**Predicate**  
A condition that evaluates to TRUE, FALSE, or UNKNOWN. The `WHERE` clause is a predicate.

---

## Q

**Query**  
A SQL statement that retrieves data from a database. The word is often used loosely to mean any SQL statement.

---

## R

**RDBMS (Relational Database Management System)**  
A database management system that organizes data into tables with relationships between them. SQL Server, PostgreSQL, and MySQL are all RDBMSs.

**Referential integrity**  
The guarantee that a foreign key always points to an existing primary key value (or is NULL). Enforced by the database engine.

**Relation**  
The formal term (from set theory) for what SQL calls a table: a set of tuples (rows) sharing the same attributes (columns).

**Row**  
A single record in a table (also called a tuple in relational theory).

---

## S

**Schema**  
1. A logical namespace that groups database objects (tables, views, functions). In PostgreSQL and SQL Server, `public` and `dbo` are the defaults. 2. The structure of a database — its tables, columns, data types, and constraints.

**SELECT**  
The SQL command for querying data. The most used SQL command.

**Stored procedure**  
A named, pre-compiled set of SQL statements stored in the database and callable by name. T-SQL `EXEC`, PL/pgSQL `CALL`, MySQL `CALL`.

**Subquery**  
A query nested inside another query. Can appear in `SELECT`, `FROM`, or `WHERE`.

---

## T

**T-SQL (Transact-SQL)**  
Microsoft SQL Server's extension of SQL, adding procedural programming constructs, error handling (`TRY/CATCH`), and proprietary functions like `GETDATE()`, `@@ROWCOUNT`, and `ISNULL()`.

**Transaction**  
A sequence of SQL statements treated as a single unit of work. Either all statements succeed (`COMMIT`) or all are rolled back (`ROLLBACK`). Governed by ACID properties.

**Trigger**  
A stored procedure that fires automatically in response to a data event (`INSERT`, `UPDATE`, `DELETE`) on a table.

**Tuple**  
The formal relational term for a row.

---

## U

**UNIQUE constraint**  
Ensures all values in a column (or combination of columns) are distinct. Unlike a primary key, a UNIQUE column can contain NULL (behavior varies by platform).

---

## V

**View**  
A named, stored `SELECT` query. Behaves like a virtual table. Does not store data itself (unless it is a materialized view).

---

## W

**Window function**  
A function that performs a calculation across a set of rows related to the current row, without collapsing the result into a single row. Examples: `ROW_NUMBER()`, `RANK()`, `LAG()`, `LEAD()`, `SUM() OVER(...)`.

---

## Cross-Platform Quick Reference

| Concept | SQL Server | PostgreSQL | MySQL |
|---------|-----------|-----------|-------|
| Auto-increment | `IDENTITY(1,1)` | `SERIAL` or `GENERATED` | `AUTO_INCREMENT` |
| String concat | `+` or `CONCAT()` | `\|\|` or `CONCAT()` | `CONCAT()` |
| Current datetime | `GETDATE()` | `NOW()` | `NOW()` |
| Limit rows | `TOP N` | `LIMIT N` | `LIMIT N` |
| NULL-safe equals | — | `IS NOT DISTINCT FROM` | `<=>` |
| Conditional | `IIF()` or `CASE` | `CASE` | `IF()` or `CASE` |
| Procedural language | T-SQL | PL/pgSQL | MySQL SP |
