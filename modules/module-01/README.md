# Module 01: Database Foundations and Introduction to SQL

**Tracks:** A (MySQL), B (PostgreSQL), C (SQL Server)  
**Estimated time:** 4 hours theory + 2 hours lab  
**Prerequisites:** None — this is the starting point  

---

## Learning Objectives

By the end of this module, you will be able to:

1. Explain what a database, DBMS, and RDBMS are in plain language
2. Describe the relational model and its core concepts
3. Distinguish between MySQL, PostgreSQL, and SQL Server
4. Connect to all three database systems from their client tools
5. Write and execute basic SELECT queries on all three systems
6. Explain what SQL, T-SQL, and PL/pgSQL are
7. Explain what NULL means in SQL
8. Identify the four categories of SQL commands (DQL, DML, DDL, DCL)

---

## Module Contents

```
module-01/
├── README.md                   ← this file
├── lecture-notes.md            ← full teaching notes
├── slides/
│   └── module-01-slides.md     ← Marp-compatible presentation
├── code/
│   ├── mysql/
│   │   └── 01_first_queries.sql
│   ├── postgresql/
│   │   └── 01_first_queries.sql
│   └── sql-server/
│       └── 01_first_queries.sql
├── labs/
│   └── lab-01-guided.md        ← step-by-step guided lab
├── exercises/
│   └── exercises-01.md         ← independent exercises
├── assessments/
│   └── quiz-01.md              ← 15-question module quiz
├── solutions/
│   └── solutions-01.md         ← exercise solutions (self-check)
└── resources/
    └── references.md           ← further reading
```

---

## Concepts Covered

| Concept | Covered |
|---------|---------|
| Data vs information | ✓ |
| Database and DBMS | ✓ |
| RDBMS and relational model | ✓ |
| Tables, rows, columns | ✓ |
| Primary key and foreign key | ✓ |
| NULL | ✓ |
| SQL history and standards | ✓ |
| DQL / DML / DDL / DCL | ✓ |
| SELECT syntax | ✓ |
| Platform differences | ✓ |

---

## How to Work Through This Module

1. Read `lecture-notes.md` from top to bottom
2. Run every code example in `code/` on your own system
3. Complete the guided lab: `labs/lab-01-guided.md`
4. Solve the independent exercises: `exercises/exercises-01.md`
5. Check your solutions: `solutions/solutions-01.md`
6. Take the quiz: `assessments/quiz-01.md`
7. Mark this module complete in your `progress-tracking/learner-progress.yml`

---

## Module 02 Preview

Module 02 diverges by track:
- **Track A (MySQL):** MySQL Architecture — InnoDB, storage engines, data files
- **Track B (PostgreSQL):** PostgreSQL Architecture — process model, WAL, MVCC
- **Track C (SQL Server):** SQL Server Architecture — TempDB, buffer pool, .mdf/.ldf
