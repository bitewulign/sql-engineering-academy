# Module 01 — Guided Lab
## First Steps: Connecting and Running Your First Queries

**Time:** 60–90 minutes  
**Goal:** Successfully connect to all three database systems, run your first queries, and observe platform differences.

---

## Lab Setup

Confirm Docker is running:
```bash
docker-compose ps
```
All three containers (sqlserver2022, postgres16, mysql80) should show `healthy`.

---

## Part 1: SQL Server (25 minutes)

### Step 1: Connect

Option A — SSMS:
1. Open SQL Server Management Studio
2. Server name: `localhost,1433`
3. Authentication: SQL Server Authentication
4. Login: `SA`
5. Password: (from your .env file)
6. Click Connect

Option B — Azure Data Studio:
1. New Connection → SQL Server
2. Server: `localhost,1433` | User: `SA`

Option C — Docker exec (no GUI needed):
```bash
docker exec -it sqlserver2022 /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U SA -P "YourStrong@Password123" -C
```

---

### Step 2: Run your first queries

Copy and run each query. Observe the output.

```sql
-- What version are we running?
SELECT @@VERSION;

-- What is the current date and time?
SELECT GETDATE() AS right_now;

-- Simple arithmetic
SELECT 2 + 2 AS two_plus_two;

-- Your name as a string (replace with your actual name)
SELECT 'Your Name' AS my_name;

-- NULL behavior
SELECT NULL + 100 AS null_plus_100;
SELECT NULL IS NULL AS null_is_null_check;
```

**Record:** What version of SQL Server are you running? ___________

---

### Step 3: Explore system catalogs

```sql
-- List all databases on this server
SELECT name, database_id, create_date
FROM sys.databases
ORDER BY name;

-- How many system tables are there?
SELECT COUNT(*) AS system_table_count
FROM sys.tables;
```

---

## Part 2: PostgreSQL (25 minutes)

### Step 1: Connect

Option A — pgAdmin:
1. Open browser → http://localhost:5050
2. Login with PGADMIN_EMAIL and PGADMIN_PASSWORD from .env
3. Add Server → Host: `postgres` | Port: 5432 | User: `postgres` | Password: from .env

Option B — psql:
```bash
docker exec -it postgres16 psql -U postgres
```

---

### Step 2: Run your first queries

```sql
-- What version are we running?
SELECT version();

-- What is the current date and time?
SELECT NOW() AS right_now;
SELECT CURRENT_DATE AS today;

-- Simple arithmetic
SELECT 2 + 2 AS two_plus_two;

-- PostgreSQL-specific: generate a series
SELECT generate_series(1, 5) AS n;

-- NULL behavior in PostgreSQL
SELECT NULL + 100  AS null_plus_100;
SELECT NULL || 'x' AS null_concat;       -- NULL
SELECT CONCAT(NULL, 'x') AS coalesce_concat; -- 'x' (PostgreSQL CONCAT skips NULLs)
```

**Record:** What version of PostgreSQL are you running? ___________

**Note the difference:** PostgreSQL's `CONCAT()` treats NULL as empty string. MySQL's `CONCAT()` returns NULL if any argument is NULL.

---

### Step 3: Explore system catalogs

```sql
-- List all databases
SELECT datname, pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
ORDER BY datname;

-- List tables in the current database
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
```

---

## Part 3: MySQL (20 minutes)

### Step 1: Connect

Option A — MySQL Workbench:
1. New Connection → Hostname: `127.0.0.1` | Port: 3306
2. Username: `root` | Password: from .env
3. Test Connection → OK

Option B — mysql CLI:
```bash
docker exec -it mysql80 mysql -u root -pYourMySQLRoot123
```

---

### Step 2: Run your first queries

```sql
-- What version are we running?
SELECT VERSION();

-- What is the current date and time?
SELECT NOW() AS right_now;
SELECT CURDATE() AS today;

-- Simple arithmetic
SELECT 2 + 2 AS two_plus_two;
SELECT 100 DIV 3 AS integer_division;   -- 33

-- NULL behavior in MySQL
SELECT NULL + 100         AS null_plus_100;    -- NULL
SELECT CONCAT('a', NULL)  AS concat_with_null; -- NULL (different from PostgreSQL!)
SELECT IFNULL(NULL, 'default') AS use_default; -- 'default'
```

**Record:** What version of MySQL are you running? ___________

**Note the difference:** MySQL `CONCAT()` returns NULL if any argument is NULL — different from PostgreSQL.

---

### Step 3: Explore system databases

```sql
-- List all databases
SHOW DATABASES;

-- Use ANSI method (works on all three systems)
SELECT schema_name AS database_name
FROM information_schema.schemata
ORDER BY schema_name;
```

---

## Part 4: Side-by-side comparison (10 minutes)

Fill in this table based on what you observed:

| Query | SQL Server | PostgreSQL | MySQL |
|-------|-----------|-----------|-------|
| Version function | `@@VERSION` | `version()` | `VERSION()` |
| Current datetime | `GETDATE()` | `NOW()` | `NOW()` |
| Current date only | `CAST(GETDATE() AS DATE)` | `CURRENT_DATE` | `CURDATE()` |
| List databases | `sys.databases` | `pg_database` | `SHOW DATABASES` |
| `CONCAT('a', NULL)` result | | | |
| `1 / 2` result | | | |
| `1.0 / 2` result | | | |

---

## Lab Deliverable

Create a file: `modules/module-01/exercises/lab-01-results.md`

Write:
1. The version number of each system you connected to
2. The completed comparison table above
3. One thing that surprised you about the differences

Commit it to your repository.

---

## Lab Complete ✓

You have:
- Connected to all three database systems
- Run your first SQL queries on each
- Observed how NULL behaves differently in CONCAT across PostgreSQL and MySQL
- Queried system catalogs on all three platforms

**Next: Complete the independent exercises in `exercises/exercises-01.md`**
