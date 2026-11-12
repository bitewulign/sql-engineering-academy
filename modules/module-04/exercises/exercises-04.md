# Module 04 — Exercises
## Aggregating Data: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

Work through these exercises using your track's SQL file as a reference.  
Attempt each exercise before checking `solutions/solutions-04.md`.

---

## Beginner Exercises (1–10)

**Exercise 1 — COUNT all rows**  
Count the total number of students in the `students` table.

---

**Exercise 2 — COUNT with NULL awareness**  
In a single query, return:
- The total number of rows in `students`
- The number of rows where `phone` is not NULL
- The number of rows where `phone` IS NULL

---

**Exercise 3 — SUM and AVG**  
Return the sum of all department budgets and the average department budget.  
Round the average to 2 decimal places.

---

**Exercise 4 — MIN and MAX**  
Return the earliest and most recent enrollment dates from the `students` table.

---

**Exercise 5 — Aggregate with WHERE**  
Return the average GPA of active students only (`is_active = 1` or `TRUE`).

---

**Exercise 6 — GROUP BY single column**  
Count the number of students in each department.  
Sort by student count descending.

---

**Exercise 7 — GROUP BY with multiple aggregates**  
For each department, return:
- Number of students
- Average GPA (rounded to 2 decimal places)
- Minimum GPA
- Maximum GPA

---

**Exercise 8 — HAVING**  
List only the departments that have more than 1 student, along with their student count.

---

**Exercise 9 — WHERE + GROUP BY + HAVING**  
For active students only, find departments where the average GPA is greater than 3.00.  
Return department_id and average GPA, sorted by average GPA descending.

---

**Exercise 10 — COUNT(DISTINCT)**  
How many unique buildings are used by departments in the `departments` table?

---

## Intermediate Exercises (11–15)

**Exercise 11 — Conditional COUNT with CASE**  
In a single query against `students`, return:
- Total students
- Active students (is_active = 1)
- Inactive students (is_active = 0)

Hint: `SUM(CASE WHEN condition THEN 1 ELSE 0 END)` counts matching rows.

---

**Exercise 12 — GROUP BY multiple columns**  
Group students by `department_id` and `is_active`.  
For each combination, return the count of students and average GPA.

---

**Exercise 13 — MIN and MAX on text**  
Return the alphabetically first and last department names.

---

**Exercise 14 — AVG with COALESCE**  
Suppose some students have a NULL `gpa`. Write two versions of an average query:
1. The default AVG (NULLs ignored)
2. An AVG where NULLs are treated as 0.00

Which result is higher? Why?

---

**Exercise 15 — Aggregate string (platform-specific)**  
For each department, return a comma-separated list of student last names (alphabetically sorted).  

- MySQL: use `GROUP_CONCAT`  
- PostgreSQL: use `STRING_AGG`  
- SQL Server: use `STRING_AGG … WITHIN GROUP`

---

## Advanced Challenges (16–18)

**Challenge 16 — Isolate NULL effect on AVG**  
Insert a student with no GPA (`NULL`). Then:
1. Count total rows and rows with non-NULL GPA
2. Compare `AVG(gpa)` with `AVG(COALESCE(gpa, 0.00))`
3. Delete the test student

Explain in a comment why the two averages differ.

---

**Challenge 17 — ROLLUP subtotals**  
Write a query that shows student counts by `department_id` and enrollment year, plus:
- A subtotal row for each department (all years combined)
- A grand total row (all departments, all years)

Use `WITH ROLLUP` (MySQL/SQL Server) or `ROLLUP()` (PostgreSQL).

---

**Challenge 18 — Cross-platform HAVING with multiple conditions**  
Find departments where:
- There is at least 1 active student
- The maximum GPA among active students is above 3.70

Return department_id, active student count, and max active GPA.  
Write the query for all three platforms.

---

## Interview Practice Questions

1. What is the difference between `COUNT(*)` and `COUNT(col)`?
2. If `AVG(col)` skips NULLs, what does that mean for departments that have only NULL values in that column?
3. Can you use an aggregate function in a `WHERE` clause? Why or why not?
4. What is the difference between `WHERE` and `HAVING`?
5. In what order does the database evaluate `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `SELECT`, `ORDER BY`?
6. What does `ROLLUP` add to a `GROUP BY` query?
7. In SQL Server, what happens when you run `SELECT AVG(integer_col)` and the column type is `INT`?
8. What does `GROUPING()` return and when is it useful?

---

## Submission Checklist

- [ ] Exercises 1–10 completed and results noted
- [ ] Exercises 11–15 completed
- [ ] Challenges 16–18 attempted
- [ ] SQL files run without errors on your track's platform
- [ ] Quiz 04 taken (minimum passing score: 11/15)
