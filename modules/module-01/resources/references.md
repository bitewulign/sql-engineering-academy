# Module 01 — Further Reading and Resources
## Database Foundations and Introduction to SQL

---

## Essential Reading

### The Relational Model

**E.F. Codd — "A Relational Model of Data for Large Shared Data Banks" (1970)**  
The original paper. Dense, but reading the introduction and Section 1 gives you the vocabulary every database concept descends from.  
https://dl.acm.org/doi/10.1145/362384.362685

**C.J. Date — *An Introduction to Database Systems* (8th ed.)**  
Still the most rigorous textbook treatment of relational theory. Chapter 1–3 for foundations.

**Joe Celko — *SQL for Smarties: Advanced SQL Programming***  
Focus on Chapters 1–3 (NULLs, three-valued logic, set theory in SQL). Celko is strict about ANSI SQL and reveals how much vendor-specific SQL diverges.

---

## SQL Standard Reference

**ISO/IEC 9075 SQL Standard (official)**  
The authoritative standard. Access through your institution's library — not freely available, but Parts 1 and 2 are what most developers ever need.

**Use the ANSI SQL Wikipedia article as a quick feature map:**  
https://en.wikipedia.org/wiki/SQL — especially the "Interoperability and standardization" section.

---

## Platform Documentation

### SQL Server
- Getting Started: https://learn.microsoft.com/en-us/sql/sql-server/
- T-SQL Reference: https://learn.microsoft.com/en-us/sql/t-sql/language-reference
- NULL handling in T-SQL: https://learn.microsoft.com/en-us/sql/t-sql/language-elements/null-and-unknown-transact-sql
- INFORMATION_SCHEMA Views: https://learn.microsoft.com/en-us/sql/relational-databases/system-information-schema-views/

### PostgreSQL
- PostgreSQL 16 Documentation: https://www.postgresql.org/docs/16/
- SQL Syntax chapter: https://www.postgresql.org/docs/16/sql-syntax.html
- Data Types: https://www.postgresql.org/docs/16/datatype.html
- Functions and Operators: https://www.postgresql.org/docs/16/functions.html

### MySQL
- MySQL 8.0 Reference Manual: https://dev.mysql.com/doc/refman/8.0/en/
- Getting Started: https://dev.mysql.com/doc/refman/8.0/en/getting-started.html
- NULL handling: https://dev.mysql.com/doc/refman/8.0/en/working-with-null.html
- Character sets and collations: https://dev.mysql.com/doc/refman/8.0/en/charset.html

---

## Interactive Practice

**SQLZoo** — https://sqlzoo.net/  
Hands-on exercises in a browser. The first few sections cover exactly what Module 01 introduced. Supports MySQL, SQL Server, Oracle, and PostgreSQL dialects.

**Mode SQL Tutorial** — https://mode.com/sql-tutorial/  
Good for beginners. Practice queries run against real PostgreSQL.

**DB Fiddle** — https://www.db-fiddle.com/  
Online sandbox where you can test SQL against MySQL, PostgreSQL, or SQLite without installing anything. Useful for quick experiments and sharing queries.

**SQL Bolt** — https://sqlbolt.com/  
Structured, progressive exercises. Good for building muscle memory on SELECT syntax.

---

## Concepts to Deepen

### NULL and Three-Valued Logic
- Fabian Pascal, "What First Normal Form Really Means": explains why NULL is philosophically controversial
- Celko's SQL for Smarties, Chapter 5 (NULL handling) — the most practical treatment

### Docker for Databases
- Docker Compose documentation: https://docs.docker.com/compose/
- Official SQL Server Docker images: https://hub.docker.com/_/microsoft-mssql-server
- Official PostgreSQL Docker image: https://hub.docker.com/_/postgres
- Official MySQL Docker image: https://hub.docker.com/_/mysql

### INFORMATION_SCHEMA
- ISO standard for INFORMATION_SCHEMA: https://www.contrib.andrew.cmu.edu/~shadow/sql/sql1992.txt (search for "INFORMATION_SCHEMA")
- Cross-platform catalog query guide: https://docs.microsoft.com/en-us/sql/relational-databases/system-information-schema-views/

---

## Videos

**CMU 15-445 Database Systems (Andy Pavlo)** — https://15445.cs.cmu.edu/  
Free university-level database course. Lectures 1–3 cover relational model and SQL foundations. High quality, freely available on YouTube.

**PostgreSQL Tutorial YouTube Series** — search "PostgreSQL tutorial beginners" for several well-regarded series.

---

## Tools Reference

| Tool | Purpose | URL |
|------|---------|-----|
| SSMS (SQL Server Mgmt Studio) | SQL Server GUI | https://aka.ms/ssmsfullsetup |
| Azure Data Studio | Cross-platform SQL editor | https://aka.ms/azuredatastudio |
| pgAdmin 4 | PostgreSQL GUI | https://www.pgadmin.org/download/ |
| DBeaver | Universal DB GUI (all three) | https://dbeaver.io/download/ |
| MySQL Workbench | MySQL GUI | https://dev.mysql.com/downloads/workbench/ |
| DB Fiddle | Browser SQL sandbox | https://www.db-fiddle.com/ |

---

## Module 01 Key Terms (Quick Reference)

| Term | Definition |
|------|-----------|
| RDBMS | Relational Database Management System — stores data in related tables |
| SQL | Structured Query Language — ANSI/ISO standard for relational databases |
| T-SQL | Transact-SQL — Microsoft SQL Server's extension of SQL |
| PL/pgSQL | PostgreSQL's procedural extension of SQL |
| NULL | Absence of a value; not zero, not empty string |
| Three-valued logic | TRUE / FALSE / UNKNOWN — SQL's logic system (UNKNOWN from NULL) |
| Primary key | Column(s) uniquely identifying each row; cannot be NULL |
| Foreign key | Column(s) referencing the primary key of another table |
| DDL | Data Definition Language — CREATE, ALTER, DROP |
| DML | Data Manipulation Language — INSERT, UPDATE, DELETE |
| DQL | Data Query Language — SELECT |
| DCL | Data Control Language — GRANT, REVOKE |
| COALESCE | Returns first non-NULL value from a list |
| INFORMATION_SCHEMA | Standard cross-platform catalog views |

---

## Next Module Preview

**Module 02** diverges by track:
- **Track A (MySQL):** Creating your first database — CREATE TABLE, data types, INSERT, UPDATE, DELETE
- **Track B (PostgreSQL):** Creating your first database — PostgreSQL types, sequences, RETURNING
- **Track C (SQL Server):** Creating your first database — T-SQL types, IDENTITY, OUTPUT clause

All tracks reconverge at **Module CX-01** (Cross-Platform Comparison: Data Types) around week 4.
