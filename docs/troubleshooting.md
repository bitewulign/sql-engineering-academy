# Troubleshooting

Common problems and their solutions. If your issue is not here, open a GitHub Discussion.

---

## Docker Issues

### Containers not starting

**Symptom:** `docker-compose up -d` exits with errors, or containers show `Exit 1`

**Check 1 — Docker is running:**
```bash
docker info
```
If this fails, start Docker Desktop and wait for it to fully initialize.

**Check 2 — Ports in use:**
```bash
# macOS / Linux
lsof -i :1433
lsof -i :5432
lsof -i :3306

# Windows
netstat -ano | findstr :1433
netstat -ano | findstr :5432
netstat -ano | findstr :3306
```
If another process is using those ports, either stop it or change the host-side port mapping in `docker-compose.yml`.

**Check 3 — `.env` file exists:**
```bash
ls -la .env
```
If missing: `cp .env.example .env` and fill in passwords.

---

### SQL Server container unhealthy or not starting

**Symptom:** `sqlserver2022` shows `unhealthy` or `starting` indefinitely

**Cause 1 — Insufficient memory.** SQL Server requires at least 2 GB RAM.
```bash
docker stats sqlserver2022
```
If memory is capped, increase Docker Desktop's memory allocation:  
Docker Desktop → Settings → Resources → Memory → 4 GB minimum

**Cause 2 — Apple Silicon (M1/M2/M3 Mac).**  
The `docker-compose.yml` includes `platform: linux/amd64` for the SQL Server service. If you removed this, add it back:
```yaml
sqlserver:
  platform: linux/amd64
  image: mcr.microsoft.com/mssql/server:2022-latest
```

**Cause 3 — Password too weak.** SQL Server requires a password with uppercase, lowercase, digit, and symbol.
```
MSSQL_SA_PASSWORD=YourStrong@Password123
```

---

### MySQL "Access denied" on first connect

**Cause:** MySQL caches the password used when the volume was first created. If you change the password in `.env` after the volume exists, MySQL won't use the new one.

**Fix:** Destroy the MySQL volume and recreate:
```bash
docker-compose down
docker volume rm sql-engineering-academy_mysql_data
docker-compose up -d
```

> **Warning:** This deletes all data in MySQL. Run it only on a fresh setup.

---

### Cannot connect to PostgreSQL from pgAdmin

1. Open http://localhost:5050
2. Add Server → Connection tab:
   - **Host:** `postgres` (the Docker service name, not `localhost`)
   - **Port:** `5432`
   - **Username:** value of `POSTGRES_USER` from `.env`
   - **Password:** value of `POSTGRES_PASSWORD`

The host must be `postgres` (the Docker network hostname), not `localhost`.

---

## SQL Client Issues

### SSMS: "A network-related error occurred"

- Server name: `localhost,1433` (comma, not colon)
- Authentication: SQL Server Authentication (not Windows)
- Login: `SA`
- Trust server certificate: check this box (required for self-signed certs)

---

### MySQL Workbench: "Authentication plugin 'caching_sha2_password' cannot be loaded"

This happens with MySQL 8+ when connecting with an older client.

**Fix in docker-compose.yml** (already included):
```yaml
command: --default-authentication-plugin=mysql_native_password
```
If you removed this line, add it back and restart: `docker-compose down && docker-compose up -d`

---

### psql: "FATAL: password authentication failed"

Confirm your password matches `POSTGRES_PASSWORD` in `.env`:
```bash
docker exec -it postgres16 psql -U postgres -c "SELECT 1;"
```
If this works inside Docker but fails from your host, check the port mapping and firewall.

---

## SQL Execution Issues

### "Invalid object name 'sys.databases'" in PostgreSQL

`sys.databases` is SQL Server-specific. In PostgreSQL use:
```sql
SELECT datname FROM pg_database;
```

### "LIMIT is not a recognized option" in SQL Server

`LIMIT` is MySQL/PostgreSQL syntax. In SQL Server use:
```sql
SELECT TOP 10 * FROM table_name;
-- or
SELECT * FROM table_name ORDER BY id OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;
```

### "GETDATE() is not a recognized function" in PostgreSQL

`GETDATE()` is SQL Server-specific. In PostgreSQL use `NOW()` or `CURRENT_TIMESTAMP`.

---

## Resetting the Environment

**Soft reset — stop and restart (preserves all data):**
```bash
docker-compose down
docker-compose up -d
```

**Hard reset — delete all data and start fresh:**
```bash
docker-compose down -v
docker-compose up -d
```

**Nuclear option — remove everything including images:**
```bash
docker-compose down -v --rmi all
docker-compose up -d
```

---

## Getting More Help

1. Check [GitHub Issues](../../issues) — your problem may already be solved
2. Open a [GitHub Discussion](../../discussions) — describe your OS, Docker version, and the exact error message
3. Include the output of `docker-compose ps` and `docker-compose logs <service-name>` in your report
