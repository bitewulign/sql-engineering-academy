# SQL Engineering Academy
## MySQL · PostgreSQL · Microsoft SQL Server (T-SQL)

A complete, professional, industry-oriented SQL Engineering Academy covering three major relational database management systems. This program takes learners from absolute beginner to advanced database engineering capability — covering SQL programming, database design, query optimization, database administration, and data engineering.

---

## Program Overview

| Attribute | Detail |
|-----------|--------|
| Platforms | MySQL 8.0, PostgreSQL 16, Microsoft SQL Server 2022 |
| Level | Beginner → Professional |
| Duration | 6–12 months (2 hrs/day, 6 days/week) |
| Format | Self-directed; structured modules with assessments |
| Career targets | SQL Developer, DBA, Data Engineer, Data Analyst, Database Architect |

---

## Intended Audience

- Beginners with no database experience
- Developers who know one platform and want to master the others
- Data scientists and analysts who want deep SQL expertise
- Aspiring data engineers
- Technical interview candidates

---

## Learning Outcomes

After completing this curriculum, learners will be able to:

1. Write complex SQL queries across MySQL, PostgreSQL, and SQL Server
2. Design normalized relational database schemas from business requirements
3. Build stored procedures, functions, triggers, and views in all three systems
4. Analyze and optimize query performance using execution plans and indexes
5. Administer databases: users, permissions, backup, replication, monitoring
6. Build data warehouses and analytical SQL pipelines
7. Integrate SQL databases with Python and data engineering workflows
8. Build a professional GitHub portfolio demonstrating cross-platform expertise

---

## Course Structure

```
Three Tracks (run in parallel or sequentially)
├── Track A: MySQL Engineering          (17 modules)
├── Track B: PostgreSQL Engineering     (18 modules)
└── Track C: SQL Server / T-SQL         (18 modules)

Plus:
├── Cross-Platform Comparison Section
├── Python + SQL Integration
└── Six Portfolio Projects
```

See [curriculum/curriculum-map.md](curriculum/curriculum-map.md) for the full module map.

---

## Technology Stack

| Tool | Purpose |
|------|---------|
| Docker Desktop | Isolated database environments |
| SQL Server Management Studio | SQL Server client |
| Azure Data Studio | Multi-platform SQL client |
| pgAdmin 4 | PostgreSQL client |
| MySQL Workbench | MySQL client |
| DBeaver (optional) | Universal SQL client |
| Python 3.11+ | Integration and automation |
| Jupyter Notebook | Interactive notebooks |
| Git + GitHub | Version control and portfolio |

---

## Quick Start

### 1. Prerequisites

- Git installed: https://git-scm.com
- Docker Desktop installed: https://www.docker.com/products/docker-desktop
- 8 GB RAM minimum (16 GB recommended to run all three DBs simultaneously)

### 2. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/sql-engineering-academy.git
cd sql-engineering-academy
```

### 3. Start all three database systems

```bash
cp .env.example .env
# Edit .env with your passwords
docker-compose up -d
```

Verify containers are running:
```bash
docker-compose ps
```

### 4. Load sample databases

```bash
# SQL Server: AdventureWorks
docker exec -i sqlserver2022 /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U SA -P "$MSSQL_SA_PASSWORD" \
  -i /scripts/setup/adventureworks-install.sql

# PostgreSQL: Pagila
docker exec -i postgres16 psql -U postgres \
  -f /scripts/setup/pagila-install.sql

# MySQL: Sakila
docker exec -i mysql80 mysql -u root -p"$MYSQL_ROOT_PASSWORD" \
  < scripts/setup/sakila-install.sql
```

### 5. Connect your SQL client

| System | Host | Port | Default User |
|--------|------|------|-------------|
| SQL Server | localhost | 1433 | SA |
| PostgreSQL | localhost | 5432 | postgres |
| MySQL | localhost | 3306 | root |

### 6. Take the diagnostic assessment

Before starting, complete [assessments/diagnostic/diagnostic-assessment.md](assessments/diagnostic/diagnostic-assessment.md) to identify your entry point.

### 7. Begin your first module

```
modules/module-01/README.md
```

---

## How to Execute SQL Exercises

Each module's `code/` folder contains three subfolders:

```
code/
├── mysql/        ← Run in MySQL Workbench or mysql CLI
├── postgresql/   ← Run in pgAdmin or psql
└── sql-server/   ← Run in SSMS or Azure Data Studio
```

Every `.sql` file begins with a comment identifying the engine and version:

```sql
-- Engine: MySQL 8.0
-- Module: 01 - Database Foundations
-- File: 01_first_queries.sql
```

---

## How to Submit Assignments

1. Fork this repository
2. Create a branch: `git checkout -b module-01-exercises`
3. Complete your SQL scripts in `modules/module-01/exercises/`
4. Commit and push your work
5. Open a Pull Request for peer review

---

## How to Track Progress

Update your personal progress file:

```
progress-tracking/learner-progress.yml
```

The dashboard at `progress-tracking/progress-dashboard/` provides a visual summary.

---

## Portfolio Projects

| Project | Skills Demonstrated |
|---------|-------------------|
| Retail Sales Database | Schema design, analytics queries, indexes |
| Banking Database | Transactions, constraints, integrity |
| Healthcare Database | ER modeling, complex joins, synthetic data |
| E-commerce Analytics | Cohort analysis, window functions, reporting |
| HR & Workforce Analytics | Aggregations, stored procedures, payroll |
| Data Engineering Pipeline | Python + SQL, ETL, data validation |

---

## Contribution Guidelines

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

MIT License — see [LICENSE](LICENSE).

---

*Built for self-directed professionals. Prioritizes technical accuracy, practical application, and measurable outcomes.*
# sql-engineering-academy
