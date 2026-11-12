# Module 08 — Exercises
## Data Modification

---

## Setup

All exercises use the `university` database. Tables used:
- `students` (student_id PK, first_name, last_name, gpa, department_id, enrolled_at, is_active)
- `departments` (department_id PK, department_name)
- `enrollments` (enrollment_id PK, student_id FK, course_id FK, grade, enrolled_on)
- `courses` (course_id PK, course_name, credits, department_id FK)
- `students_staging` (student_id, first_name, last_name, gpa, copied_at) — staging table

> **Safety rule:** Before every UPDATE or DELETE, write and run the matching SELECT first.

---

## Beginner Exercises

### Exercise 01
Insert a new student named **Lena Fischer** with GPA **3.72**, department_id **2**, enrolled today, and is_active = 1 (or TRUE in PostgreSQL).

---

### Exercise 02
Insert the following three students in a single INSERT statement:

| first_name | last_name | gpa | department_id | enrolled_at |
|-----------|---------|-----|--------------|-------------|
| Omar | Hassan | 3.65 | 1 | 2024-09-01 |
| Mia | Johansson | 3.88 | 3 | 2023-01-15 |
| Raj | Patel | 3.50 | 2 | 2024-01-15 |

---

### Exercise 03
Copy all students with GPA >= 3.75 into `students_staging` using INSERT … SELECT.

---

### Exercise 04
Update Lena Fischer's GPA to **3.85**.  
Write the SELECT statement first, then the UPDATE.

---

### Exercise 05
Set `is_active = 0` (or FALSE) for all students who enrolled before January 1, 2023.

---

### Exercise 06
Delete the student named **Omar Hassan** from the students table.  
Write the SELECT statement first to confirm exactly which row will be deleted.

---

### Exercise 07
Delete all rows from `students_staging`.  
Use TRUNCATE (not DELETE).

---

### Exercise 08
Increase every student's GPA by **0.03**, but do not let any GPA exceed **4.00**.

---

### Exercise 09
Write an INSERT into `students_staging` that selects only students from department_id = 1 who are is_active = 1.

---

### Exercise 10
Show all students before and after the following operation: set `is_active = 1` for every student whose GPA is above the school-wide average GPA.

---

## Intermediate Exercises

### Exercise 11
Write a joined UPDATE that sets `gpa = LEAST(gpa + 0.10, 4.00)` for all students in the **'Computer Science'** department. Use the `departments` table in the join.

---

### Exercise 12
Delete all enrollments where the enrolled student no longer exists in the `students` table (use NOT EXISTS).

---

### Exercise 13 — UPSERT
A course-enrollment counter table `course_stats (course_id PK, enrollment_count, last_updated)` needs to be updated when a new enrollment is recorded.

Write a single statement that:
- Inserts a new row if `course_id` does not exist
- Increments `enrollment_count` by 1 if it does

Write the appropriate syntax for your platform.

---

### Exercise 14
Wrap the following two operations in a transaction:
1. Insert a new student: **Test Txn**, GPA 3.00, department_id 1, enrolled today
2. Increment `course_stats.enrollment_count` for course_id = 101 by 1

Commit the transaction. Verify both changes are visible.

---

### Exercise 15
Repeat Exercise 14 but ROLLBACK after the second UPDATE. Verify neither change persisted.

---

## Challenge Exercises

### Exercise 16
Write a **SAVEPOINT** transaction that:
1. Inserts a new student: **SP Test**, GPA 3.50, department_id 2
2. Sets a SAVEPOINT
3. Updates all department 2 students' GPA to 0.00 (simulated mistake)
4. Rolls back to the SAVEPOINT
5. Commits

Verify the final state: SP Test exists with GPA 3.50; other dept 2 students are unchanged.

---

### Exercise 17
Write a DELETE … (with subquery or join) that removes all students from the `students` table who have **zero enrollments** in the `enrollments` table.

**Hint:** Use NOT EXISTS or NOT IN (with IS NOT NULL guard).

---

### Exercise 18
(SQL Server) Write a MERGE statement that synchronizes `course_stats` from a source values list:

```
(101, 10), (102, 5), (103, 8)
```

- If course_id already exists in `course_stats`: update `enrollment_count` to the source value
- If not: insert the row

Include an OUTPUT clause showing whether each row was inserted or updated (`$action`).

---

## Interview Questions

### IQ-01
What is the risk of running `UPDATE students SET gpa = 3.80;` without a WHERE clause?

---

### IQ-02
Explain the difference between DELETE and TRUNCATE. When would you choose each?

---

### IQ-03
What does `ON CONFLICT DO NOTHING` do in PostgreSQL? How does it differ from `ON CONFLICT DO UPDATE`?

---

### IQ-04
Explain what ACID stands for. Why does it matter for a bank transfer?

---

### IQ-05
What is the difference between READ COMMITTED and REPEATABLE READ isolation levels? Give a real-world scenario where the distinction matters.

---

### IQ-06
What is a dirty read? Which isolation level prevents it?

---

### IQ-07
In PostgreSQL, what does the `RETURNING` clause do? Name one practical use case.

---

### IQ-08
In SQL Server's MERGE, what does `$action` in an OUTPUT clause tell you?
