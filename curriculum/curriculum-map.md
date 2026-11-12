# SQL Engineering Academy — Curriculum Map

Three parallel tracks + cross-platform comparison + Python integration.
Each module number maps to a folder: `modules/module-NN/`

---

## Track A: MySQL Engineering

| Module | Title | Key Topics | Est. Hours |
|--------|-------|-----------|------------|
| M01 | Database Foundations | RDBMS concepts, installation, first queries | 4 |
| M02 | MySQL Architecture | Storage engines, InnoDB, data directories | 3 |
| M03 | SQL Fundamentals | SELECT, WHERE, ORDER BY, DISTINCT, LIMIT | 6 |
| M04 | Data Types and Constraints | Numeric, string, date/time, NULL, PRIMARY/FOREIGN KEY | 5 |
| M05 | Aggregations and Grouping | COUNT, SUM, AVG, GROUP BY, HAVING | 5 |
| M06 | Joins and Subqueries | INNER, LEFT, RIGHT, FULL, CROSS, correlated subqueries | 8 |
| M07 | CTEs and Window Functions | WITH, recursive CTEs, ROW_NUMBER, RANK, LAG/LEAD | 8 |
| M08 | Views and Indexes | CREATE VIEW, B-tree, full-text, EXPLAIN | 6 |
| M09 | Stored Procedures and Functions | CREATE PROCEDURE, CREATE FUNCTION, parameters | 8 |
| M10 | Triggers and Events | BEFORE/AFTER triggers, MySQL Event Scheduler | 5 |
| M11 | Transactions and Locking | ACID, COMMIT, ROLLBACK, SAVEPOINT, isolation levels | 6 |
| M12 | Query Optimization | EXPLAIN, EXPLAIN ANALYZE, indexes, SARGability | 8 |
| M13 | Security and Permissions | Users, roles, GRANT, REVOKE, authentication | 5 |
| M14 | Backup and Recovery | mysqldump, mysqlpump, point-in-time recovery | 5 |
| M15 | Replication and HA | Binary log replication, GTID, Group Replication | 6 |
| M16 | Performance Monitoring | performance_schema, sys schema, slow query log | 5 |
| M17 | MySQL with Python | mysql-connector-python, SQLAlchemy, pandas | 6 |

**Track A total: ~104 hours**

---

## Track B: PostgreSQL Engineering

| Module | Title | Key Topics | Est. Hours |
|--------|-------|-----------|------------|
| M01 | Database Foundations | RDBMS concepts, installation, first queries | 4 |
| M18 | PostgreSQL Architecture | Process model, WAL, MVCC, shared_buffers | 4 |
| M19 | Advanced Data Types | Arrays, JSONB, hstore, composite, range, UUID | 6 |
| M20 | Advanced SQL Queries | LATERAL joins, FILTER, DISTINCT ON, RETURNING | 6 |
| M21 | CTEs and Recursive Queries | WITH RECURSIVE, hierarchical data | 6 |
| M22 | Window Functions | Full window function set, frames | 6 |
| M23 | JSON and JSONB | JSON operators, GIN indexes, jsonb_agg | 6 |
| M24 | Views and Materialized Views | CREATE VIEW, REFRESH MATERIALIZED VIEW | 5 |
| M25 | PL/pgSQL | DO blocks, functions, procedures, control flow | 10 |
| M26 | Triggers | Trigger functions, BEFORE/AFTER/INSTEAD OF | 5 |
| M27 | Transactions and MVCC | Isolation, pg_locks, deadlocks, MVCC internals | 7 |
| M28 | Indexing Strategies | B-tree, Hash, GIN, GiST, BRIN, partial, expression | 8 |
| M29 | EXPLAIN and Query Optimization | EXPLAIN ANALYZE, pg_stat_statements, planner config | 8 |
| M30 | VACUUM and Autovacuum | Table bloat, autovacuum tuning, ANALYZE | 4 |
| M31 | Roles and Security | pg_hba.conf, row-level security, encryption | 5 |
| M32 | Backup and Recovery | pg_dump, pg_basebackup, WAL archiving, PITR | 6 |
| M33 | Replication | Streaming replication, logical replication, Patroni | 6 |
| M34 | PostgreSQL with Python | psycopg2, SQLAlchemy, asyncpg, pandas | 6 |

**Track B total: ~118 hours**

---

## Track C: SQL Server / T-SQL

| Module | Title | Key Topics | Est. Hours |
|--------|-------|-----------|------------|
| M01 | Database Foundations | RDBMS concepts, installation, first queries | 4 |
| M35 | SQL Server Architecture | Database Engine, TempDB, buffer pool, .mdf/.ldf | 4 |
| M36 | T-SQL Fundamentals | Batches, GO, variables, PRINT, data types | 5 |
| M37 | Advanced SELECT | TOP, OFFSET/FETCH, PIVOT, UNPIVOT, APPLY | 6 |
| M38 | CTEs and Recursive Queries | WITH, recursive, hierarchical queries | 6 |
| M39 | Window Functions | ROW_NUMBER, RANK, LAG/LEAD, ROWS/RANGE frames | 6 |
| M40 | Temporary Tables and Variables | #temp, ##global, @table, table-valued parameters | 5 |
| M41 | Views | CREATE VIEW, indexed views, schema binding | 4 |
| M42 | Stored Procedures | CREATE PROCEDURE, parameters, OUTPUT, sp_executesql | 8 |
| M43 | User-Defined Functions | Scalar, inline TVF, multi-statement TVF | 6 |
| M44 | Triggers | DML triggers, DDL triggers, INSTEAD OF | 5 |
| M45 | Dynamic SQL | EXEC(), sp_executesql, SQL injection prevention | 5 |
| M46 | Transactions and Error Handling | TRY/CATCH, THROW, XACT_ABORT, isolation levels | 6 |
| M47 | Indexing and Execution Plans | Clustered, nonclustered, columnstore, filtered | 8 |
| M48 | Query Optimization | Query Store, Extended Events, DMVs, statistics | 8 |
| M49 | Security | Logins, users, roles, permissions, TDE, Always Encrypted | 6 |
| M50 | Backup and Recovery | Full, differential, log backups; restore scenarios | 6 |
| M51 | High Availability | Always On AG, Failover Cluster, log shipping | 6 |
| M52 | SQL Server Agent and Automation | Jobs, schedules, alerts, notifications | 4 |
| M53 | SQL Server with Python | pyodbc, SQLAlchemy, pandas, OPENROWSET | 6 |

**Track C total: ~124 hours**

---

## Cross-Platform Comparison (all 3 engines)

| Module | Title |
|--------|-------|
| CX-01 | SELECT syntax differences and pagination |
| CX-02 | Auto-increment IDs: IDENTITY vs SERIAL vs AUTO_INCREMENT |
| CX-03 | String functions comparison |
| CX-04 | Date/time functions comparison |
| CX-05 | UPSERT: MERGE vs ON CONFLICT vs ON DUPLICATE KEY |
| CX-06 | JSON handling: JSON vs JSONB vs JSON |
| CX-07 | Stored procedure comparison: T-SQL vs PL/pgSQL vs Stored Programs |
| CX-08 | Error handling comparison |
| CX-09 | Temporary tables comparison |
| CX-10 | Transaction isolation comparison |
| CX-11 | Indexing strategy comparison |
| CX-12 | Replication and HA comparison |

---

## Portfolio Projects

| Project | Tracks | Primary Skills |
|---------|--------|---------------|
| Retail Sales Database | All 3 | Schema, analytics, indexes |
| Banking Database | All 3 | Transactions, constraints |
| Healthcare Database | All 3 | ER modeling, synthetic data |
| E-commerce Analytics | All 3 | Window functions, cohorts |
| HR and Workforce Analytics | All 3 | Procedures, payroll, reporting |
| Data Engineering Pipeline | All 3 + Python | ETL, validation, automation |

---

## Assessment Framework

| Type | Frequency | Format |
|------|-----------|--------|
| Module quiz | Each module | 10–15 multiple choice |
| Practical coding assessment | Each module | 3–5 SQL challenges |
| Weekly review | Weekly | Cumulative problems |
| Monthly examination | Monthly | Mixed format, 90 min |
| Project submission | Each project | Build + document + present |
| Capstone | End of program | Full enterprise project |
