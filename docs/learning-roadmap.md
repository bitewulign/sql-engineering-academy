# Learning Roadmap

SQL Engineering Academy takes you from zero SQL knowledge to production-ready database skills across three platforms. This document maps the full journey.

---

## Curriculum Structure

The curriculum has four components that run in parallel:

| Component | Description |
|-----------|-------------|
| **Track modules** | Platform-specific deep dives (MySQL, PostgreSQL, SQL Server) |
| **Cross-platform modules** | Side-by-side comparisons of the same concept on all three systems |
| **Portfolio projects** | End-to-end database design and implementation projects |
| **Python integration** | Connecting Python to all three databases |

---

## The Twelve Levels

| Level | Focus | Modules |
|-------|-------|---------|
| 1 | Foundations | Module 01 (shared) |
| 2 | Table design & DML | Modules 02–03 (track-specific) |
| 3 | Filtering & sorting | Modules 04–05 |
| 4 | Aggregation & grouping | Modules 06–07 |
| 5 | Joins | Modules 08–10 |
| 6 | Subqueries & CTEs | Modules 11–13 |
| 7 | Views & indexes | Modules 14–15 |
| 8 | Stored procedures & functions | Modules 16–18 |
| 9 | Triggers & transactions | Modules 19–21 |
| 10 | Performance tuning | Modules 22–24 |
| 11 | Advanced analytics | Modules 25–27 |
| 12 | Expert projects | Portfolio Projects 1–6 |

---

## Recommended Schedule

**Time commitment:** 2 hours/day, 6 days/week  
**Total duration:** 6–12 months depending on experience

### Phase 1 — Foundations (Weeks 1–4)
Module 01 is shared across all tracks. Complete it on all three platforms before diverging.

- Week 1: Module 01 — Database Foundations (this module)
- Week 2: Module 02 — Creating Tables and Inserting Data
- Week 3: Module 03 — Querying Data (SELECT, WHERE, ORDER BY)
- Week 4: Cross-platform comparison + first mini-project

**Milestone:** Build a 3-table student database from scratch on all three systems.

### Phase 2 — Core SQL (Weeks 5–12)
- Weeks 5–6: Aggregation (COUNT, SUM, AVG, GROUP BY, HAVING)
- Weeks 7–9: Joins (INNER, LEFT, RIGHT, FULL, CROSS, self-join)
- Weeks 10–11: Subqueries and CTEs
- Week 12: Views, indexes, and query optimization basics

**Milestone:** Complete Portfolio Project 1 (Retail Sales Database).

### Phase 3 — Intermediate SQL (Weeks 13–20)
- Stored procedures and functions (platform-specific procedural SQL)
- Triggers and events
- Transactions and concurrency
- Window functions (ROW_NUMBER, RANK, LAG, LEAD, running totals)

**Milestone:** Complete Portfolio Project 2 (Banking System).

### Phase 4 — Advanced SQL (Weeks 21–32)
- Query execution plans and performance tuning
- Partitioning and archiving
- Full-text search
- JSON support (all three platforms)
- Advanced analytics and reporting queries

**Milestone:** Complete Portfolio Projects 3–6.

### Phase 5 — Python Integration (Weeks 25–32, parallel)
- psycopg2, mysql-connector-python, pyodbc
- SQLAlchemy ORM
- pandas + SQL
- Building a data pipeline

---

## Track Divergence Points

| Module | Track A (MySQL) | Track B (PostgreSQL) | Track C (SQL Server) |
|--------|----------------|---------------------|---------------------|
| 02 | AUTO_INCREMENT, utf8mb4 | SERIAL/BIGSERIAL, sequences | IDENTITY, computed columns |
| 08 | MySQL JOIN syntax | PostgreSQL LATERAL joins | SQL Server APPLY |
| 16 | MySQL stored procedures | PL/pgSQL functions | T-SQL stored procedures |
| 22 | EXPLAIN, slow query log | EXPLAIN ANALYZE, pg_stat | Execution plans, DMVs |

---

## Cross-Platform Comparison Modules (CX)

These modules run simultaneously across all three platforms — same concept, three implementations:

| Module | Topic |
|--------|-------|
| CX-01 | Data types |
| CX-02 | String functions |
| CX-03 | Date and time functions |
| CX-04 | NULL handling |
| CX-05 | Aggregation |
| CX-06 | Window functions |
| CX-07 | JSON support |
| CX-08 | Stored procedures |
| CX-09 | Error handling |
| CX-10 | Transactions and isolation levels |
| CX-11 | Indexing strategies |
| CX-12 | Full-text search |

---

## Portfolio Projects

| # | Project | Skills |
|---|---------|--------|
| 1 | Retail Sales Database | Schema design, DML, basic queries |
| 2 | Banking System | Transactions, constraints, stored procedures |
| 3 | Healthcare Records | Complex joins, security, audit trails |
| 4 | E-commerce Analytics | Window functions, reporting queries |
| 5 | HR Analytics | Advanced aggregation, Python integration |
| 6 | Data Engineering Pipeline | ETL, performance tuning, all three platforms |

---

## Tracking Your Progress

Use `progress-tracking/learner-progress.yml` to track your module completions, quiz scores, and project milestones. Update it after completing each module assessment.

---

## Prerequisite Checklist

Before starting Module 01, confirm:
- [ ] Docker Desktop installed and running
- [ ] Repository cloned
- [ ] `.env` file configured
- [ ] `docker-compose up -d` ran successfully
- [ ] All three databases show `healthy` in `docker-compose ps`
- [ ] At least one client tool installed (SSMS, pgAdmin, MySQL Workbench, or DBeaver)

**You are ready. Open `modules/module-01/README.md`.**
