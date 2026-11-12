# Module 06 Quiz
## Subqueries

**Instructions:** Choose the best answer for each question.  
No time limit for self-study. 60 minutes for formal assessment.  
Passing: 11/15 correct (73%).

---

**Question 1**

A scalar subquery must return:

A) One column, any number of rows  
B) Any number of columns, one row  
C) Exactly one column and one row  
D) A table with named columns

---

**Question 2**

You write:
```sql
SELECT first_name FROM students
WHERE gpa = (SELECT gpa FROM students WHERE department_id = 2);
```
Department 2 has 5 students with different GPAs. What happens?

A) Returns all 5 students  
B) Returns the student with the highest GPA in dept 2  
C) Runtime error — subquery returns more than one row  
D) Returns NULL for all rows

---

**Question 3**

Which of the following is the correct syntax for an `EXISTS` subquery?

A) `WHERE EXISTS student_id IN enrollments`  
B) `WHERE EXISTS (SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id)`  
C) `WHERE EXISTS = (SELECT COUNT(*) FROM enrollments)`  
D) `WHERE EXISTS student_id = (SELECT student_id FROM enrollments)`

---

**Question 4**

```sql
SELECT first_name FROM employees
WHERE employee_id NOT IN (SELECT manager_id FROM employees);
```
The `manager_id` column contains some NULL values. What does this query return?

A) All employees who are not managers  
B) All employees  
C) 0 rows  
D) An error

---

**Question 5**

Which of the following is a NULL-safe way to rewrite a `NOT IN` with a potentially-NULL subquery?

A) Replace `NOT IN` with `NOT LIKE`  
B) Add `WHERE manager_id IS NOT NULL` inside the subquery  
C) Use `<>` instead of `NOT IN`  
D) Use `IN` with a negative outer condition

---

**Question 6**

What does `EXISTS (subquery)` return when the subquery produces 0 rows?

A) NULL  
B) TRUE  
C) FALSE  
D) An error

---

**Question 7**

What makes a subquery "correlated"?

A) It references an aggregate function  
B) It is placed in the FROM clause  
C) It references a column from the outer query  
D) It is wrapped in a CTE

---

**Question 8**

Which SQL clause is a derived table allowed in?

A) WHERE  
B) FROM  
C) HAVING  
D) SELECT

---

**Question 9**

A derived table (subquery in FROM) requires:

A) A DISTINCT keyword  
B) A GROUP BY clause  
C) An alias  
D) A primary key column

---

**Question 10**

What is the keyword that introduces a CTE?

A) USING  
B) FROM  
C) WITH  
D) DEFINE

---

**Question 11**

Which MySQL version introduced support for CTEs?

A) 5.5  
B) 5.7  
C) 8.0  
D) 8.4

---

**Question 12**

You have two CTEs in the same query. The second CTE needs to reference the first. Which syntax is correct?

A) `WITH cte1 AS (…); WITH cte2 AS (… FROM cte1 …);`  
B) `WITH cte1 AS (…), cte2 AS (… FROM cte1 …) SELECT …`  
C) `WITH cte1 AS (…) WITH cte2 AS (… FROM cte1 …) SELECT …`  
D) Multiple CTEs are not allowed in one query

---

**Question 13**

A correlated subquery in the SELECT clause runs:

A) Once for the entire query  
B) Once per input table  
C) Once per output row  
D) Only when the WHERE clause is satisfied

---

**Question 14**

Which of the following best describes the performance difference between `IN` and `EXISTS` on modern databases?

A) EXISTS is always faster because it short-circuits  
B) IN is always faster because it materializes the result once  
C) The optimizer typically produces similar plans; profile on real data  
D) EXISTS cannot be used with large tables

---

**Question 15**

```sql
WITH active AS (
    SELECT student_id FROM students WHERE is_active = 1
)
SELECT COUNT(*) FROM active;
```
What does this query return?

A) Count of all students  
B) Count of inactive students  
C) Count of active students  
D) An error — CTE cannot be used with COUNT

---

## Answer Key

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | C | A scalar subquery must return exactly one column and one row |
| 2 | C | A scalar subquery returning multiple rows causes a runtime error |
| 3 | B | EXISTS requires a subquery in parentheses; the SELECT list inside is typically `1` |
| 4 | C | `NOT IN` with a NULL-containing list evaluates every comparison as UNKNOWN → 0 rows |
| 5 | B | Adding `WHERE manager_id IS NOT NULL` removes NULLs from the list, making NOT IN safe |
| 6 | C | EXISTS returns FALSE when the subquery returns 0 rows |
| 7 | C | A correlated subquery references a column from the outer query |
| 8 | B | A derived table (subquery used as a table) lives in the FROM clause |
| 9 | C | Every derived table must have an alias; the alias is mandatory on all three platforms |
| 10 | C | CTEs begin with the WITH keyword |
| 11 | C | CTEs were introduced in MySQL 8.0; not available in 5.x |
| 12 | B | Multiple CTEs use a single WITH followed by comma-separated definitions |
| 13 | C | A correlated subquery in SELECT runs once per output row |
| 14 | C | Modern optimizers (MySQL, PostgreSQL, SQL Server) rewrite IN as a semi-join and produce similar plans; the difference is data-dependent |
| 15 | C | The CTE filters to active students; COUNT(*) counts only those rows |

---

## Score Interpretation

| Score | Interpretation |
|-------|---------------|
| 15/15 | Excellent — ready for Module 07 (Window Functions) |
| 13–14 | Good — review the questions you missed |
| 11–12 | Passing — re-read the relevant sections in lecture-notes.md |
| Below 11 | Re-study Module 06 before proceeding |
