# Getting Started

You can be running SQL queries within 10 minutes using Docker. This guide walks you from zero to your first query on all three database systems.

---

## Option 1: Docker (Recommended)

Docker runs all three databases in isolated containers — no system-level installation, no version conflicts, easy reset.

### Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Mac, Windows, Linux)
- 8 GB RAM minimum (16 GB recommended — SQL Server alone requests 2 GB)
- 10 GB free disk space
- Git

### Step 1: Clone the repository

```bash
git clone https://github.com/your-org/sql-engineering-academy.git
cd sql-engineering-academy
```

### Step 2: Create your environment file

```bash
cp .env.example .env
```

Open `.env` in any text editor and set strong passwords. Example:

```
MSSQL_SA_PASSWORD=YourStrong@Password123
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres_pass_456
MYSQL_ROOT_PASSWORD=mysql_root_789
MYSQL_USER=academy
MYSQL_PASSWORD=academy_pass_321
PGADMIN_DEFAULT_EMAIL=admin@sqlacademy.local
PGADMIN_DEFAULT_PASSWORD=pgadmin_pass_654
```

> **Security:** Never commit `.env` to git. It is listed in `.gitignore`. Keep your passwords only on your own machine.

### Step 3: Start the environment

```bash
docker-compose up -d
```

The first run downloads images (~3 GB). Subsequent starts take under 30 seconds.

### Step 4: Verify everything is running

```bash
docker-compose ps
```

All six services should show `healthy` or `running`:

| Service | Port | Purpose |
|---------|------|---------|
| sqlserver2022 | 1433 | SQL Server 2022 Developer Edition |
| postgres16 | 5432 | PostgreSQL 16 |
| mysql80 | 3306 | MySQL 8.0 |
| pgadmin | 5050 | PostgreSQL web GUI |
| adminer | 8080 | Multi-database web GUI |
| jupyter | 8888 | Python + SQL notebooks |

### Step 5: Connect a client

**Browser-based (no install):**
- pgAdmin: http://localhost:5050 (email and password from `.env`)
- Adminer: http://localhost:8080

**Desktop clients:**

| Platform | Recommended client | Server | Port | User |
|----------|--------------------|--------|------|------|
| SQL Server | SSMS or Azure Data Studio | localhost | 1433 | SA |
| PostgreSQL | pgAdmin or DBeaver | localhost | 5432 | postgres |
| MySQL | MySQL Workbench or DBeaver | 127.0.0.1 | 3306 | root |

### Step 6: Run your first query

Open Module 01 and run:
```bash
# SQL Server
modules/module-01/code/sql-server/01_first_queries.sql

# PostgreSQL
modules/module-01/code/postgresql/01_first_queries.sql

# MySQL
modules/module-01/code/mysql/01_first_queries.sql
```

---

## Option 2: Native Installation

Prefer not to use Docker? See [docs/installation.md](installation.md) for native install instructions for all three platforms on Windows, macOS, and Linux.

---

## Stopping and Resetting

**Stop the environment (preserves data):**
```bash
docker-compose down
```

**Full reset — deletes all data and starts fresh:**
```bash
docker-compose down -v
docker-compose up -d
```

---

## Choosing Your Track

| Track | Platform | Best for |
|-------|----------|---------|
| A | MySQL 8.0 | Web development, open source, LAMP stack |
| B | PostgreSQL 16 | Advanced SQL, analytics, open source enterprise |
| C | SQL Server 2022 | Microsoft ecosystem, enterprise, Windows environments |

**Not sure?** Start with Track A (MySQL) — it has the gentlest learning curve and the largest online community for beginners. All tracks teach the same SQL fundamentals; they diverge only on platform-specific syntax.

You can run multiple tracks simultaneously — all three databases are running in your Docker environment.

---

## Next Steps

1. Read [docs/learning-roadmap.md](learning-roadmap.md) — understand the full curriculum structure
2. Open `modules/module-01/README.md` — your first module
3. Work through the guided lab: `modules/module-01/labs/lab-01-guided.md`

**You are ready to start.**
