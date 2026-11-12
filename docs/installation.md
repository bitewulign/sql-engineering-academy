# Installation Guide

Complete setup for all three database systems. Choose Option A (Docker) for the fastest, cleanest setup.

---

## Option A: Docker (Recommended)

### Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| RAM | 8 GB | 16 GB |
| Disk | 20 GB | 40 GB |
| Docker Desktop | 4.x+ | Latest |
| OS | Windows 10/11, macOS 12+, Ubuntu 20.04+ | — |

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/sql-engineering-academy.git
cd sql-engineering-academy

# 2. Create your environment file
cp .env.example .env

# 3. Edit .env — set strong passwords for all three systems
# Windows: notepad .env
# macOS/Linux: nano .env or code .env

# 4. Start all services
docker-compose up -d

# 5. Verify (all should show "healthy" after ~30 seconds)
docker-compose ps

# 6. View logs if any container fails
docker-compose logs sqlserver
docker-compose logs postgres
docker-compose logs mysql
```

### Connecting after startup

| Service | URL / Host | Port | User |
|---------|-----------|------|------|
| SQL Server | localhost | 1433 | SA |
| PostgreSQL | localhost | 5432 | (POSTGRES_USER from .env) |
| MySQL | localhost | 3306 | root |
| pgAdmin | http://localhost:5050 | 5050 | (PGADMIN_EMAIL from .env) |
| Adminer | http://localhost:8080 | 8080 | — |
| Jupyter | http://localhost:8888 | 8888 | token in logs |

---

## Option B: Native Installation

### Microsoft SQL Server 2022

**Windows / Linux only** (not natively available on macOS — use Docker)

1. Download **Developer Edition** (free, full features):  
   https://www.microsoft.com/en-us/sql-server/sql-server-downloads

2. Run the installer → choose **Developer** edition → **Basic** installation type

3. After install, download and install **SSMS**:  
   https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms

4. Connect in SSMS:
   - Server: `localhost` or `.\SQLEXPRESS`
   - Authentication: Windows Authentication (or SQL Server with SA)

**Verify:**
```sql
SELECT @@VERSION;
SELECT GETDATE();
```

---

### PostgreSQL 16

**All platforms**

1. Download installer:  
   https://www.postgresql.org/download/

2. Run installer. When prompted:
   - Set a password for the `postgres` superuser
   - Leave port as 5432
   - Check **pgAdmin 4** in components

3. After install, pgAdmin opens in your browser. Connect to localhost:5432.

4. Or use `psql` from terminal:
```bash
psql -U postgres -h localhost
```

**Verify:**
```sql
SELECT version();
SELECT NOW();
```

---

### MySQL 8.0

**All platforms**

1. Download MySQL Community Server:  
   https://dev.mysql.com/downloads/mysql/

2. During setup:
   - Choose **Developer Default** (includes Workbench)
   - Set root password
   - Configure MySQL as a Windows service (Windows) or follow macOS/Linux instructions

3. Open MySQL Workbench → New Connection → localhost:3306 → user: root

**Verify:**
```sql
SELECT VERSION();
SELECT NOW();
```

---

## Client Tools

| Tool | Download | Best for |
|------|----------|---------|
| SSMS 20 | https://learn.microsoft.com/en-us/sql/ssms | SQL Server (Windows) |
| Azure Data Studio | https://azure.microsoft.com/products/data-studio | SQL Server, PostgreSQL |
| pgAdmin 4 | https://www.pgadmin.org/download/ | PostgreSQL |
| MySQL Workbench | https://dev.mysql.com/downloads/workbench/ | MySQL |
| DBeaver | https://dbeaver.io/download/ | All three in one |
| VS Code + SQLTools | Marketplace | All three in VS Code |

---

## Loading Sample Databases

### AdventureWorks (SQL Server)

```sql
-- Download from Microsoft:
-- https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure
-- Restore the .bak file in SSMS:
-- File > Restore Database > Device > browse to .bak
```

### Pagila (PostgreSQL)

```bash
# Download and load Pagila (PostgreSQL port of Sakila)
curl -O https://raw.githubusercontent.com/devrimgunduz/pagila/master/pagila-schema.sql
curl -O https://raw.githubusercontent.com/devrimgunduz/pagila/master/pagila-data.sql
psql -U postgres -c "CREATE DATABASE pagila;"
psql -U postgres -d pagila -f pagila-schema.sql
psql -U postgres -d pagila -f pagila-data.sql
```

### Sakila (MySQL)

```bash
# Download from MySQL:
# https://dev.mysql.com/doc/index-other.html → Example Databases
mysql -u root -p < sakila-schema.sql
mysql -u root -p < sakila-data.sql
```

---

## Resetting Your Environment

```bash
# Stop and remove containers AND volumes (deletes all data)
docker-compose down -v

# Restart fresh
docker-compose up -d
```

Or reset one database only:
```bash
docker-compose stop mysql
docker-compose rm -f mysql
docker volume rm sql-engineering-academy_mysql_data
docker-compose up -d mysql
```
