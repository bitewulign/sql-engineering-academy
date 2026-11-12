# Module 08 — References
## Data Modification

---

## Official Documentation

| Platform | Topic | URL |
|----------|-------|-----|
| MySQL 8.0 | INSERT | https://dev.mysql.com/doc/refman/8.0/en/insert.html |
| MySQL 8.0 | UPDATE | https://dev.mysql.com/doc/refman/8.0/en/update.html |
| MySQL 8.0 | DELETE | https://dev.mysql.com/doc/refman/8.0/en/delete.html |
| MySQL 8.0 | INSERT … ON DUPLICATE KEY UPDATE | https://dev.mysql.com/doc/refman/8.0/en/insert-on-duplicate.html |
| MySQL 8.0 | TRUNCATE | https://dev.mysql.com/doc/refman/8.0/en/truncate-table.html |
| MySQL 8.0 | Transactions | https://dev.mysql.com/doc/refman/8.0/en/commit.html |
| PostgreSQL 16 | INSERT | https://www.postgresql.org/docs/16/sql-insert.html |
| PostgreSQL 16 | UPDATE | https://www.postgresql.org/docs/16/sql-update.html |
| PostgreSQL 16 | DELETE | https://www.postgresql.org/docs/16/sql-delete.html |
| PostgreSQL 16 | Transactions | https://www.postgresql.org/docs/16/tutorial-transactions.html |
| PostgreSQL 16 | Isolation levels | https://www.postgresql.org/docs/16/transaction-iso.html |
| SQL Server 2022 | INSERT | https://learn.microsoft.com/en-us/sql/t-sql/statements/insert-transact-sql |
| SQL Server 2022 | UPDATE | https://learn.microsoft.com/en-us/sql/t-sql/queries/update-transact-sql |
| SQL Server 2022 | DELETE | https://learn.microsoft.com/en-us/sql/t-sql/statements/delete-transact-sql |
| SQL Server 2022 | MERGE | https://learn.microsoft.com/en-us/sql/t-sql/statements/merge-transact-sql |
| SQL Server 2022 | Isolation levels | https://learn.microsoft.com/en-us/sql/t-sql/statements/set-transaction-isolation-level-transact-sql |

---

## DELETE vs TRUNCATE Quick Reference

| Dimension | DELETE | TRUNCATE |
|-----------|--------|----------|
| WHERE clause | Yes | No |
| Row-by-row logging | Yes | No (page deallocation) |
| Triggers | Fire | Do not fire |
| AUTO_INCREMENT reset | No | Yes (MySQL) |
| Rollback inside transaction | Always | MySQL: no; PostgreSQL: yes; SQL Server: yes (if explicit txn) |
| Foreign key check | Yes | Yes — blocked if FK references exist |
| Speed on large tables | Slower | Much faster |

---

## UPSERT Syntax by Platform

### MySQL 8.0
```sql
INSERT INTO t (pk_col, val_col)
VALUES (1, 'x')
ON DUPLICATE KEY UPDATE val_col = VALUES(val_col);
-- Modern alternative (avoid deprecated VALUES() function):
ON DUPLICATE KEY UPDATE val_col = 'x';
```

### PostgreSQL 16
```sql
INSERT INTO t (pk_col, val_col)
VALUES (1, 'x')
ON CONFLICT (pk_col) DO UPDATE
    SET val_col = EXCLUDED.val_col;

-- Do nothing on conflict:
ON CONFLICT (pk_col) DO NOTHING;
```

### SQL Server 2022
```sql
MERGE INTO target AS t
USING source AS s ON t.pk_col = s.pk_col
WHEN MATCHED THEN UPDATE SET t.val_col = s.val_col
WHEN NOT MATCHED THEN INSERT (pk_col, val_col) VALUES (s.pk_col, s.val_col);
```

---

## UPDATE … FROM / JOIN Syntax

| Platform | Syntax |
|----------|--------|
| MySQL 8.0 | `UPDATE t1 JOIN t2 ON … SET t1.col = … WHERE …` |
| PostgreSQL 16 | `UPDATE t1 SET col = … FROM t2 WHERE t1.id = t2.id AND …` |
| SQL Server 2022 | `UPDATE t1 SET col = … FROM t1 JOIN t2 ON … WHERE …` |

---

## RETURNING / OUTPUT by Platform

| Platform | INSERT | UPDATE | DELETE |
|----------|--------|--------|--------|
| MySQL 8.0 | `LAST_INSERT_ID()` for auto-increment only | ❌ | ❌ |
| PostgreSQL 16 | `RETURNING col, …` | `RETURNING col, …` | `RETURNING col, …` |
| SQL Server 2022 | `OUTPUT INSERTED.col, …` | `OUTPUT DELETED.col, INSERTED.col` | `OUTPUT DELETED.col, …` |

---

## Isolation Levels Reference

| Level | Dirty Read | Non-Repeatable | Phantom | Use When |
|-------|-----------|----------------|---------|----------|
| READ UNCOMMITTED | Possible | Possible | Possible | Approximate counts on reporting DB only |
| READ COMMITTED | Protected | Possible | Possible | Most OLTP workloads (PG/SQL Server default) |
| REPEATABLE READ | Protected | Protected | Possible | Reports that must be internally consistent (MySQL default) |
| SERIALIZABLE | Protected | Protected | Protected | Financial transactions; strict consistency required |

### Setting isolation level

```sql
-- MySQL
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- PostgreSQL (per transaction)
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
COMMIT;

-- SQL Server (per session)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

---

## Transaction Control Reference

| Statement | MySQL | PostgreSQL | SQL Server |
|-----------|-------|-----------|------------|
| Start transaction | `START TRANSACTION` or `BEGIN` | `BEGIN` | `BEGIN TRANSACTION` |
| Commit | `COMMIT` | `COMMIT` | `COMMIT TRANSACTION` |
| Rollback | `ROLLBACK` | `ROLLBACK` | `ROLLBACK TRANSACTION` |
| Set savepoint | `SAVEPOINT name` | `SAVEPOINT name` | `SAVE TRANSACTION name` |
| Rollback to savepoint | `ROLLBACK TO SAVEPOINT name` | `ROLLBACK TO SAVEPOINT name` | `ROLLBACK TRANSACTION name` |
| Release savepoint | `RELEASE SAVEPOINT name` | `RELEASE SAVEPOINT name` | N/A |

---

## Common DML Mistakes and Fixes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| UPDATE / DELETE without WHERE | Updates or deletes all rows | Always SELECT-before-DML |
| NOT IN with NULL in subquery | 0 rows matched | Use NOT EXISTS |
| Multi-row INSERT with mismatched column count | Error | Recount columns vs VALUES |
| INSERT without column list | Type mismatch if schema changes | Always list columns explicitly |
| TRUNCATE when rollback needed | May not roll back | Use DELETE inside a transaction |
| Forgetting COMMIT | Changes invisible to other sessions | Always pair BEGIN with COMMIT/ROLLBACK |
| SQL Server MERGE without semicolon before MERGE | Syntax error | Add `;` before MERGE (if previous statement lacks one) |

---

## Recommended Reading

- *Learning SQL* (Alan Beaulieu) — Chapters 9–10: Subqueries and Joins in DML
- *SQL Antipatterns* (Bill Karwin) — Chapter 24: Magic Beans (safe INSERT practices)
- PostgreSQL Documentation — Chapter 6: Data Manipulation: https://www.postgresql.org/docs/16/dml.html
- MySQL Documentation — Section 15.7: InnoDB Locking and Transaction Model: https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-model.html
