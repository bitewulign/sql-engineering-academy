# Module 02 — Creating Tables and Inserting Data

**Tracks:** A (MySQL) · B (PostgreSQL) · C (SQL Server)  
**Prerequisite:** Module 01 — Database Foundations  
**Estimated time:** 4–6 hours per track

---

## Learning Objectives

By the end of this module you will be able to:

1. Create a database and select it for use
2. Choose appropriate data types for columns (integers, decimals, text, dates, booleans)
3. Write `CREATE TABLE` statements with constraints (`PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `DEFAULT`, `CHECK`)
4. Understand auto-incrementing primary keys on each platform (`AUTO_INCREMENT`, `SERIAL`, `IDENTITY`)
5. Insert single and multiple rows with `INSERT INTO`
6. Update existing rows with `UPDATE … SET … WHERE`
7. Delete rows with `DELETE FROM … WHERE` (and understand `TRUNCATE`)
8. Explain the difference between `DELETE` and `TRUNCATE`
9. Identify at least five data type differences between the three platforms

---

## Module Contents

```
modules/module-02/
├── README.md                        ← this file
├── lecture-notes.md                 ← full written lesson (shared concepts)
├── slides/
│   └── module-02-slides.md          ← Marp presentation
├── code/
│   ├── sql-server/
│   │   └── 02_create_insert.sql     ← Track C
│   ├── postgresql/
│   │   └── 02_create_insert.sql     ← Track B
│   └── mysql/
│       └── 02_create_insert.sql     ← Track A
├── labs/
│   └── lab-02-guided.md
├── exercises/
│   └── exercises-02.md
├── assessments/
│   └── quiz-02.md
├── solutions/
│   └── solutions-02.md
└── resources/
    └── references.md
```

---

## Key Concepts

| Concept | SQL Server | PostgreSQL | MySQL |
|---------|-----------|-----------|-------|
| Create database | `CREATE DATABASE` | `CREATE DATABASE` | `CREATE DATABASE` |
| Auto-increment PK | `INT IDENTITY(1,1)` | `SERIAL` or `GENERATED ALWAYS AS IDENTITY` | `INT AUTO_INCREMENT` |
| Variable-length text | `VARCHAR(n)` | `VARCHAR(n)` or `TEXT` | `VARCHAR(n)` |
| Unlimited text | `VARCHAR(MAX)` | `TEXT` | `TEXT` or `LONGTEXT` |
| Boolean | `BIT` (0/1) | `BOOLEAN` (true/false) | `TINYINT(1)` or `BOOLEAN` |
| Decimal money | `DECIMAL(10,2)` or `MONEY` | `NUMERIC(10,2)` | `DECIMAL(10,2)` |
| Current timestamp default | `GETDATE()` | `NOW()` or `CURRENT_TIMESTAMP` | `CURRENT_TIMESTAMP` |

---

## How to Use This Module

1. Read `lecture-notes.md`
2. Run the SQL code file for your track (or all three)
3. Complete `labs/lab-02-guided.md` — build a small student database
4. Work through `exercises/exercises-02.md`
5. Take `assessments/quiz-02.md` (pass = 11/15)
6. Check answers in `solutions/solutions-02.md`

---

## Module 03 Preview

Module 03 introduces `SELECT` with filtering and sorting:
- `WHERE` with comparison operators, `AND`, `OR`, `NOT`
- `ORDER BY` (single and multi-column)
- `BETWEEN`, `IN`, `LIKE`, `IS NULL`
- `DISTINCT`
- Aliasing columns and expressions
