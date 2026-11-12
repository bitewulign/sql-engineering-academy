# Module 04 — Aggregating Data
## COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

**Track:** A (MySQL 8.0) · B (PostgreSQL 16) · C (SQL Server 2022)  
**Level:** Beginner–Intermediate  
**Estimated time:** 4–5 hours

---

## Learning Objectives

By the end of this module you will be able to:

1. Use aggregate functions — `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` — to summarize data
2. Understand how NULLs are treated by aggregate functions
3. Group rows with `GROUP BY` and compute per-group summaries
4. Filter groups with `HAVING`
5. Distinguish between `WHERE` (filters rows before grouping) and `HAVING` (filters after)
6. Write multi-column `GROUP BY` queries
7. Use `COUNT(DISTINCT col)` to count unique values
8. Use `ROLLUP` for subtotals (intro)

---

## Module Contents

```
module-04/
├── README.md                   ← this file
├── lecture-notes.md            ← full narrative with code examples
├── code/
│   ├── mysql/04_aggregate.sql
│   ├── postgresql/04_aggregate.sql
│   └── sql-server/04_aggregate.sql
├── exercises/exercises-04.md
├── assessments/quiz-04.md
├── solutions/solutions-04.md
├── labs/lab-04-guided.md
├── resources/references.md
└── slides/module-04-slides.md
```

---

## Key Concepts

| Concept | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| Count all rows | `COUNT(*)` | `COUNT(*)` | `COUNT(*)` |
| Count non-NULL | `COUNT(col)` | `COUNT(col)` | `COUNT(col)` |
| Count distinct | `COUNT(DISTINCT col)` | `COUNT(DISTINCT col)` | `COUNT(DISTINCT col)` |
| Average | `AVG(col)` | `AVG(col)` | `AVG(col)` |
| Sum | `SUM(col)` | `SUM(col)` | `SUM(col)` |
| Subtotals | `GROUP BY … WITH ROLLUP` | `GROUP BY … ROLLUP(…)` | `GROUP BY … WITH ROLLUP` |
| Integer division in AVG | Decimal result | Decimal result | Integer (cast needed) |
| Group separator | — | `STRING_AGG(col, ',')` | `STRING_AGG(col, ',')` |
| Group concat | `GROUP_CONCAT(col)` | `STRING_AGG(col, ',')` | `STRING_AGG(col, ',')` |

---

## How to Use This Module

1. Read `lecture-notes.md` from top to bottom
2. Run each SQL file against your local Docker containers
3. Work through `exercises/exercises-04.md` without looking at solutions
4. Run `labs/lab-04-guided.md` to cement skills hands-on
5. Take `assessments/quiz-04.md` (pass mark: 11/15)
6. Check your work in `solutions/solutions-04.md`
7. Review `resources/references.md` for deeper reading

---

## Module 05 Preview

**Module 05 — Joining Tables:** `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`, `CROSS JOIN`, multi-table joins, join conditions.
