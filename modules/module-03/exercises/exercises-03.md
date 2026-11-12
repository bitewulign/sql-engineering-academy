# Module 03 — Exercises
## Querying Data: SELECT, WHERE, ORDER BY

Complete on your chosen track. Use the `university` database populated in Module 02.

---

## Beginner Exercises (1–10)

**Exercise 1 — Retrieve all columns**  
Write a query that retrieves every column from the `departments` table, ordered alphabetically by `department_name`.

---

**Exercise 2 — Retrieve specific columns**  
Write a query that returns only `first_name`, `last_name`, and `email` from the `students` table, ordered by `last_name`.

---

**Exercise 3 — Column alias**  
Retrieve `first_name`, `last_name`, and `gpa` from `students`. Give `gpa` the alias `grade_point_average`. Order by `grade_point_average` descending.

---

**Exercise 4 — Filter with WHERE**  
Retrieve all students whose GPA is greater than 3.70. Return `first_name`, `last_name`, and `gpa`.

---

**Exercise 5 — AND condition**  
Retrieve active students (`is_active = 1` or `TRUE`) with a GPA of 3.60 or higher. Return `first_name`, `last_name`, `gpa`.

---

**Exercise 6 — Filter by date**  
Retrieve all students who enrolled on or after January 1, 2024. Return `first_name`, `enrolled_at`.

---

**Exercise 7 — IS NULL**  
Find all students who do not have a phone number on record. Return `first_name`, `last_name`, `phone`.

---

**Exercise 8 — LIKE**  
Find all students whose last name starts with the letter 'S'. Return `first_name`, `last_name`.

---

**Exercise 9 — BETWEEN**  
Find all departments with a budget between 300,000 and 600,000 (inclusive). Return `department_name`, `budget`, ordered by `budget` descending.

---

**Exercise 10 — IN**  
Retrieve departments located in either 'Tech Hall' or 'Science Wing'. Return `department_name`, `building`, `budget`.

---

## Intermediate Exercises (11–15)

**Exercise 11 — OR with parentheses**  
Write a query that retrieves students who either:
- Have a GPA above 3.80, **OR**
- Enrolled before January 1, 2024 AND have a GPA above 3.60

Return `first_name`, `last_name`, `gpa`, `enrolled_at`. Explain in a comment why parentheses matter here.

---

**Exercise 12 — CASE WHEN**  
Add an `academic_standing` column to your student query using a CASE expression:
- 3.70+ → 'Distinction'
- 3.00–3.69 → 'Merit'
- 2.00–2.99 → 'Pass'
- Below 2.00 → 'At Risk'

Return all students ordered by GPA descending.

---

**Exercise 13 — LIMIT / TOP**  
Write three queries:
1. The top 3 students by GPA
2. Students ranked 4th through 6th by GPA
3. The department with the smallest budget

Use the platform-appropriate limiting syntax.

---

**Exercise 14 — DISTINCT**  
Write queries to answer:
1. What unique buildings exist in the `departments` table?
2. How many unique buildings are there? (Use `COUNT(DISTINCT ...)`)
3. What distinct `is_active` values exist in the `students` table?

---

**Exercise 15 — Computed column**  
Write a query that returns `department_name`, `budget`, and a third column `budget_after_10pct_increase` calculated as `budget * 1.10`. Order by `budget_after_10pct_increase` descending.

---

## Advanced Challenges (16–18)

**Challenge 16 — NULL trap**  
Consider this query:
```sql
SELECT * FROM students WHERE phone NOT IN (NULL, '416-555-0101');
```
What do you expect it to return? Run it and record the actual result. Explain the behavior in a comment, referencing three-valued logic. Write an alternative query that correctly returns all students whose phone is not `'416-555-0101'` (including those with NULL phones).

---

**Challenge 17 — CASE in ORDER BY**  
Write a query that lists students with their academic standing, but sorts them by standing category first (Distinction → Merit → Pass → At Risk), then by GPA descending within each category. Do not use a subquery. *(Hint: use CASE in ORDER BY.)*

---

**Challenge 18 — Cross-platform pagination**  
Write queries to return "page 2" of students (rows 4–6) ordered by `enrolled_at` descending, using:
- MySQL/PostgreSQL: `LIMIT … OFFSET`
- SQL Server: `OFFSET … FETCH NEXT`
- SQL Server: `TOP` (how would you get rows 4–6 using only TOP? Is it possible cleanly?)

---

## Interview Questions

1. What is the difference between `WHERE column = NULL` and `WHERE column IS NULL`?
2. What does `DISTINCT` do, and when should you be careful with it?
3. What is the difference between `LIKE 'S%'` and `LIKE '%S%'`?
4. Why should you always use `ORDER BY` with `LIMIT` / `TOP`?
5. What does `BETWEEN 10 AND 20` include at the boundaries?
6. What is the logical processing order of a SELECT statement?
7. Can you use a column alias defined in SELECT inside a WHERE clause?
8. What is `ILIKE` and which platform supports it?
9. What is the SQL Server equivalent of PostgreSQL's `ILIKE`?
10. How do you handle NULLs when sorting in PostgreSQL?

---

## Submission Checklist

- [ ] All queries run without errors
- [ ] Every query includes a comment explaining what it returns
- [ ] The NULL trap in Challenge 16 is explained in writing
- [ ] Platform-specific syntax differences are noted where applicable
- [ ] All SQL files begin with the standard academy header

**When complete: take Quiz 03 (`assessments/quiz-03.md`)**
