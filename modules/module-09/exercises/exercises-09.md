# Module 09 — Exercises
## Schema Design & DDL

---

## Setup

Create a fresh schema called `university_design` (or use a new schema prefix) for all exercises so they don't conflict with the main `university` database. All exercises use synthetic data only.

> **Safety rule:** Always run `DROP TABLE IF EXISTS` before `CREATE TABLE` in exercises so re-runs are idempotent.

---

## Beginner Exercises

### Exercise 01
Create a table called `buildings` with the following columns:

| Column | Type | Constraints |
|--------|------|-------------|
| building_id | INT, auto-increment | PRIMARY KEY |
| building_name | VARCHAR(100) | NOT NULL, UNIQUE |
| floors | TINYINT | NOT NULL, DEFAULT 1 |
| opened_year | SMALLINT | |

---

### Exercise 02
Create a `faculty` table:

| Column | Type | Constraints |
|--------|------|-------------|
| faculty_id | INT, auto-increment | PRIMARY KEY |
| first_name | VARCHAR(100) | NOT NULL |
| last_name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(200) | NOT NULL, UNIQUE |
| hire_date | DATE | NOT NULL, DEFAULT today |
| is_tenured | BOOLEAN/BIT | NOT NULL, DEFAULT FALSE/0 |

---

### Exercise 03
Create a `research_groups` table with:
- `group_id` (auto-increment PK)
- `group_name` (VARCHAR 150, NOT NULL, UNIQUE)
- `faculty_lead_id` (INT, FK referencing `faculty.faculty_id`, ON DELETE SET NULL)
- `founded_date` (DATE)

---

### Exercise 04
Add a `CHECK` constraint to the `faculty` table that ensures `hire_date` is on or after `'1970-01-01'`.

---

### Exercise 05
Add an index to the `faculty` table on `last_name` to speed up name searches.

---

### Exercise 06
Write a query against `information_schema.columns` to list all columns in the `faculty` table including their data type and whether they allow NULL.

---

### Exercise 07
Add a `department_id` column (INT, NOT NULL) to the `faculty` table using `ALTER TABLE`. Then add a FOREIGN KEY referencing `departments(department_id)` with `ON DELETE RESTRICT`.

---

### Exercise 08
Rename the `is_tenured` column in `faculty` to `has_tenure`.

> Write the platform-specific syntax for all three: MySQL, PostgreSQL, and SQL Server.

---

### Exercise 09
Drop the `founded_date` column from the `research_groups` table.

---

### Exercise 10
Write a `DROP TABLE IF EXISTS` statement that safely drops `research_groups` and `faculty` in the correct order (child before parent).

---

## Intermediate Exercises

### Exercise 11 — Normalize a flawed table
The following table is not in 3NF. Identify the problem and write the corrected schema:

```
course_registrations(
    registration_id,
    student_id,
    student_name,     -- transitive dependency
    course_id,
    course_name,      -- transitive dependency
    course_credits,   -- transitive dependency
    registration_date
)
```

Write the normalized `CREATE TABLE` statements.

---

### Exercise 12 — Composite unique constraint
Create a `teaching_assignments` table where each faculty member can be assigned to each course at most once per semester:

| Column | Type |
|--------|------|
| assignment_id | INT auto-increment PK |
| faculty_id | INT FK → faculty |
| course_id | INT FK → courses |
| semester | VARCHAR(20) NOT NULL |
| classroom | VARCHAR(50) |

Add a UNIQUE constraint on `(faculty_id, course_id, semester)`.

---

### Exercise 13 — Covering index
You frequently run this query:
```sql
SELECT first_name, last_name, email
FROM   faculty
WHERE  department_id = ?
ORDER BY last_name;
```

Write a covering index that makes this query a pure index scan (no table lookup). Explain the column order you chose.

---

### Exercise 14 — Partial / filtered index
You query inactive faculty members once a week for a report:
```sql
SELECT * FROM faculty WHERE is_tenured = FALSE AND hire_date < '2015-01-01';
```

Write a partial (PostgreSQL) or filtered (SQL Server) index to speed this up. Explain when a partial index is preferable to a full index.

---

### Exercise 15 — ALTER TABLE: change data type
The `floors` column in `buildings` currently holds `TINYINT`. Business requirements change and a building can now have up to 500 floors. Write the `ALTER TABLE` statement to widen the column to `SMALLINT` for each platform.

---

## Challenge Exercises

### Exercise 16 — Design a schema from scratch
Design the schema for a **Library Management System** with the following business rules:
- A library has many **books**
- Each book has one or more **authors**
- A book can have multiple **copies** (physical items on shelves)
- A **member** can **borrow** a copy; each borrow has a due date and optional return date
- A member can be fined for a late return; fines belong to borrows

Write `CREATE TABLE` statements for all tables with appropriate:
- Primary keys (auto-increment)
- Foreign keys (with appropriate ON DELETE actions)
- NOT NULL, UNIQUE, CHECK, and DEFAULT constraints
- An index on each FK column

---

### Exercise 17 — Identify normalization violations
Examine this table structure and list every normalization violation (1NF, 2NF, 3NF):

```
student_courses(
    student_id    INT,
    course_id     INT,
    student_name  VARCHAR,
    student_email VARCHAR,
    dept_id       INT,
    dept_name     VARCHAR,
    course_name   VARCHAR,
    credits       INT,
    grade         DECIMAL,
    grade_letter  CHAR(1),    -- computed from grade
    professor_id  INT,
    professor_name VARCHAR
)
```

Then write the fully normalized schema (3NF).

---

### Exercise 18 — Platform comparison
Write the equivalent `CREATE TABLE` statement for the following table in all three platforms:

```
employees(
    employee_id   -- auto-increment integer PK
    full_name     -- Unicode variable text, NOT NULL
    email         -- ASCII variable text, NOT NULL, UNIQUE
    salary        -- exact decimal 10,2; NOT NULL; must be > 0
    hire_date     -- date only; NOT NULL; DEFAULT today
    is_active     -- boolean; NOT NULL; DEFAULT true
    department_id -- FK → departments; ON DELETE SET NULL
)
```

Highlight every platform-specific difference in your answer.

---

## Interview Questions

### IQ-01
What is the difference between 2NF and 3NF? Give a concrete example of a 3NF violation.

---

### IQ-02
When should you use `DECIMAL(p,s)` instead of `FLOAT`?

---

### IQ-03
What does a FOREIGN KEY with `ON DELETE CASCADE` do? Name a real-world scenario where this is appropriate and one where it is dangerous.

---

### IQ-04
Explain the leftmost prefix rule for composite indexes. If you have an index on `(department_id, gpa, last_name)`, which of the following queries can use it?
- `WHERE department_id = 1`
- `WHERE gpa > 3.5`
- `WHERE department_id = 1 AND gpa > 3.5`
- `WHERE last_name = 'Fischer'`

---

### IQ-05
What is the difference between a clustered and a non-clustered index (SQL Server terminology)? Does PostgreSQL have clustered indexes?

---

### IQ-06
What is a covering index? Why does it speed up queries?

---

### IQ-07
In SQL Server, what is the difference between `VARCHAR` and `NVARCHAR`? When must you use `NVARCHAR`?

---

### IQ-08
Why is PostgreSQL DDL transactional but MySQL's is not? What practical advantage does this give PostgreSQL administrators?
