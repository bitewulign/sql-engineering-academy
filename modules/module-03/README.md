# Module 03 — Querying Data
## SELECT, WHERE, ORDER BY, LIMIT / TOP / FETCH

**Track:** Shared (A · MySQL 8.0, B · PostgreSQL 16, C · SQL Server 2022)  
**Level:** Beginner  
**Estimated time:** 3–4 hours  
**Prerequisites:** Module 02 completed; university database with tables and data

---

## Learning Objectives

By the end of this module you will be able to:

1. Write `SELECT` statements to retrieve specific columns
2. Filter rows with `WHERE` using comparison and logical operators
3. Use `BETWEEN`, `IN`, `LIKE`, `IS NULL` / `IS NOT NULL` for specialized filtering
4. Sort result sets with `ORDER BY` (ASC / DESC, multi-column)
5. Limit result sets using the platform-appropriate syntax
6. Explain how `NULL` behaves in `WHERE` predicates (three-valued logic)
7. Use column aliases to improve output readability
8. Apply basic string pattern matching with `LIKE` and wildcard characters

---

## Module Contents

```
module-03/
├── README.md                        ← this file
├── lecture-notes.md                 ← comprehensive notes (all platforms)
├── code/
│   ├── mysql/
│   │   └── 03_select.sql
│   ├── postgresql/
│   │   └── 03_select.sql
│   └── sql-server/
│       └── 03_select.sql
├── labs/
│   └── lab-03-guided.md
├── exercises/
│   └── exercises-03.md
├── assessments/
│   └── quiz-03.md
├── solutions/
│   └── solutions-03.md
├── resources/
│   └── references.md
└── slides/
    └── module-03-slides.md
```

---

## Key Concepts

| Concept | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Retrieve all columns | `SELECT *` | `SELECT *` | `SELECT *` |
| Retrieve top N rows | `LIMIT n` | `LIMIT n` | `TOP n` |
| Standard pagination | `LIMIT n OFFSET m` | `LIMIT n OFFSET m` | `FETCH NEXT n ROWS ONLY` |
| Case-insensitive LIKE | default | `ILIKE` | default |
| NULL check | `IS NULL` | `IS NULL` | `IS NULL` |
| Conditional expression | `CASE WHEN` | `CASE WHEN` | `CASE WHEN` |
| Column alias | `AS alias` | `AS alias` | `AS alias` |

---

## How to Use This Module

1. Read `lecture-notes.md` from top to bottom
2. Run `code/<your-platform>/03_select.sql` section by section — predict the output before running
3. Complete `labs/lab-03-guided.md` with your track's database
4. Attempt all exercises in `exercises/exercises-03.md`
5. Take `assessments/quiz-03.md` (pass mark: 11/15)

---

## Module 04 Preview

**Module 04 — Aggregating Data:** `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING` — summarizing large datasets.
