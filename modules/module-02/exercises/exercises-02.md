# Module 02 — Exercises
## Creating Tables and Inserting Data

Complete all exercises on your chosen track platform. Advanced challenges should be attempted on all three if time allows.

---

## Beginner Exercises (1–10)

**Exercise 1 — Create a database**  
Create a database named `university`. On MySQL, specify `utf8mb4` as the character set. Switch to that database.

---

**Exercise 2 — Create a simple table**  
Inside `university`, create a table called `departments` with:
- `department_id` — integer, primary key, auto-increment
- `department_name` — variable-length string up to 100 characters, NOT NULL
- `building` — variable-length string up to 50 characters (nullable)
- `budget` — exact decimal, 12 digits total, 2 decimal places (nullable)

---

**Exercise 3 — Insert rows**  
Insert five departments:

| department_name | building | budget |
|----------------|---------|--------|
| Computer Science | Tech Hall | 500000.00 |
| Mathematics | Science Wing | 320000.00 |
| Physics | Science Wing | 410000.00 |
| English Literature | Arts Building | 180000.00 |
| Data Engineering | Tech Hall | 650000.00 |

Write a single multi-row `INSERT` statement.

---

**Exercise 4 — Verify inserts**  
Write a `SELECT *` to retrieve all rows from `departments`, ordered by `department_name`.

---

**Exercise 5 — Create a table with foreign key**  
Create a `professors` table:
- `professor_id` — integer, PK, auto-increment
- `first_name` — VARCHAR(50), NOT NULL
- `last_name` — VARCHAR(50), NOT NULL
- `email` — VARCHAR(100), NOT NULL, UNIQUE
- `department_id` — integer, NOT NULL, foreign key referencing `departments(department_id)`
- `salary` — DECIMAL(10,2), nullable
- `hire_date` — DATE, NOT NULL

---

**Exercise 6 — Insert professors**  
Insert three professors. Choose departments that exist in Exercise 3.  
*(Use synthetic names — do not use real people's names or emails.)*

---

**Exercise 7 — Update**  
Increase the budget of the Computer Science department by 10%.  
Write the query without hard-coding the new amount — calculate it from the existing value.

---

**Exercise 8 — Conditional update**  
Write an `UPDATE` that sets `building` to `'Annex'` for all departments whose current `building` is NULL.

---

**Exercise 9 — Delete**  
Delete the professor you inserted in Exercise 6 who belongs to the English Literature department.  
Before deleting, write a `SELECT` to find their `professor_id`. Then delete by ID.

---

**Exercise 10 — CHECK constraint**  
Add a `CHECK` constraint to the `professors` table that ensures `salary`, when not NULL, is greater than 0.  
Test it by trying to insert a professor with `salary = -100`. What happens?

---

## Intermediate Exercises (11–15)

**Exercise 11 — DEFAULT values**  
Add a column `is_tenured` to `professors` with a default of `FALSE` (or `0` on SQL Server).  
Verify the default is applied by inserting a new professor without specifying `is_tenured`.

---

**Exercise 12 — AUTO_INCREMENT / IDENTITY behavior**  
Insert a row, delete it, then insert another row.  
What is the new row's auto-generated ID? Does it reuse the deleted ID?  
Answer for your platform. Then check: does `TRUNCATE` reset the counter? Test it.

---

**Exercise 13 — INSERT … SELECT**  
Create a table `high_budget_departments` with the same columns as `departments` (minus the PK constraint).  
Populate it in one statement using `INSERT INTO … SELECT` from `departments` where `budget > 400000`.

---

**Exercise 14 — RETURNING / OUTPUT / LAST_INSERT_ID**  
Insert a new department and capture the auto-generated ID in a single operation (no second SELECT):
- PostgreSQL: use `RETURNING`
- SQL Server: use `OUTPUT INSERTED.department_id`
- MySQL: `INSERT` then `SELECT LAST_INSERT_ID()`

---

**Exercise 15 — ALTER TABLE**  
Add a `founded_year` column (integer, nullable) to `departments`.  
Update all five departments with realistic founding years.  
Then add a `CHECK` constraint ensuring `founded_year > 1800`.  
Try inserting a department with `founded_year = 1700`. What happens?

---

## Advanced Challenges (16–18)

**Challenge 16 — Referential integrity test**  
Attempt to:
1. Insert a professor with a `department_id` that does not exist in `departments`
2. Delete a department that has professors assigned to it

What error messages do you get on each platform? Write down the exact error text. What does each error reveal about how the database enforces referential integrity?

---

**Challenge 17 — UPSERT (INSERT or UPDATE)**  
Research and implement an "upsert" — insert a row if it doesn't exist, or update it if it does — for the `departments` table, keyed on `department_name`:

- MySQL: `INSERT ... ON DUPLICATE KEY UPDATE`
- PostgreSQL: `INSERT ... ON CONFLICT DO UPDATE`
- SQL Server: `MERGE` statement

Test it by trying to insert 'Computer Science' (already exists) and 'Biology' (new).

---

**Challenge 18 — Audit column pattern**  
Modify the `professors` table to add:
- `created_at` — timestamp defaulting to the current time, never updated
- `updated_at` — timestamp that automatically reflects the last modification time

On MySQL: use `ON UPDATE CURRENT_TIMESTAMP`.  
On PostgreSQL: explain why a trigger would be needed (PostgreSQL has no `ON UPDATE`).  
On SQL Server: explain the same.

---

## Interview Questions

1. What is the difference between `DELETE` and `TRUNCATE`?
2. What does `IDENTITY(1,1)` mean in SQL Server?
3. Why should you use `DECIMAL` instead of `FLOAT` for monetary values?
4. What is `SCOPE_IDENTITY()` and why is it preferred over `@@IDENTITY`?
5. What is PostgreSQL's `RETURNING` clause and what problem does it solve?
6. Why does MySQL require `ENGINE=InnoDB` for foreign keys to work?
7. What does `utf8mb4` mean and why is it important in MySQL?
8. What happens if you try to insert a row that violates a `CHECK` constraint?
9. What is the difference between a column-level and a table-level constraint?
10. When you drop and recreate a table, do you need to recreate its constraints separately?

---

## Submission Checklist

- [ ] Database created and selected
- [ ] All tables created with correct data types and constraints
- [ ] Synthetic data only — no real personal information
- [ ] Every SQL file has the standard header comment
- [ ] `UPDATE` and `DELETE` statements include `WHERE` clauses
- [ ] All queries tested and producing expected output
- [ ] Files committed to your repository

**When complete: take Quiz 02 (`assessments/quiz-02.md`)**
