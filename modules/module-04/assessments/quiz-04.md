# Module 04 Quiz
## Aggregating Data: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

**Instructions:** Choose the best answer for each question.  
No time limit for self-study. 60 minutes for formal assessment.  
Passing: 11/15 correct (73%).

---

**Question 1**

A table has 10 rows. 3 of them have a NULL value in the `phone` column. What does `COUNT(phone)` return?

A) 10  
B) 7  
C) 3  
D) 0

---

**Question 2**

What does `COUNT(*)` count?

A) Only rows where all columns are non-NULL  
B) Only the rows matched by the most recent WHERE clause  
C) Every row in the group, including those with NULLs  
D) The number of distinct values in the first column

---

**Question 3**

Which clause filters groups *after* aggregation?

A) `WHERE`  
B) `GROUP BY`  
C) `HAVING`  
D) `ORDER BY`

---

**Question 4**

A column named `bonus` contains values: 100, 200, NULL, 300. What does `AVG(bonus)` return?

A) 150 (sum 600 ÷ 4)  
B) 200 (sum 600 ÷ 3)  
C) NULL (because one value is NULL)  
D) 0 (NULL treated as zero)

---

**Question 5**

Which query is INVALID?

A) `SELECT department_id, COUNT(*) FROM students GROUP BY department_id;`  
B) `SELECT department_id, AVG(gpa) FROM students GROUP BY department_id HAVING AVG(gpa) > 3.5;`  
C) `SELECT department_id, AVG(gpa) FROM students WHERE AVG(gpa) > 3.5 GROUP BY department_id;`  
D) `SELECT department_id, MAX(gpa) FROM students GROUP BY department_id;`

---

**Question 6**

What is the logical processing order of this query?

```sql
SELECT department_id, AVG(gpa) AS avg_gpa
FROM   students
WHERE  is_active = 1
GROUP BY department_id
HAVING AVG(gpa) > 3.0
ORDER BY avg_gpa DESC;
```

A) SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY  
B) FROM → GROUP BY → WHERE → HAVING → SELECT → ORDER BY  
C) FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY  
D) FROM → WHERE → SELECT → GROUP BY → HAVING → ORDER BY

---

**Question 7**

In SQL Server, what does `SELECT AVG(score) FROM results` return when `score` is an `INT` column with values 1, 2, 3, 4?

A) 2.5  
B) 2  
C) NULL  
D) 10

---

**Question 8**

You have a `students` table with 5 rows, all with NULL in the `gpa` column. What does `AVG(gpa)` return?

A) 0  
B) NULL  
C) An error  
D) The count of rows (5)

---

**Question 9**

Which of the following correctly counts only active students per department?

A) `SELECT department_id, COUNT(*) FROM students HAVING is_active = 1 GROUP BY department_id;`  
B) `SELECT department_id, COUNT(*) FROM students WHERE is_active = 1 GROUP BY department_id;`  
C) `SELECT department_id, COUNT(*) FROM students GROUP BY department_id HAVING is_active = 1;`  
D) `SELECT department_id, COUNT(is_active) FROM students GROUP BY department_id;`

---

**Question 10**

What does `ROLLUP` add to a `GROUP BY` query?

A) It removes duplicates from the result  
B) It adds subtotal and grand total rows using NULLs to represent aggregated dimensions  
C) It sorts the result by the first GROUP BY column  
D) It is an alias for `DISTINCT`

---

**Question 11**

Which of the following returns the number of distinct values in the `building` column?

A) `SELECT DISTINCT COUNT(building) FROM departments;`  
B) `SELECT COUNT(DISTINCT building) FROM departments;`  
C) `SELECT COUNT(*) FROM departments GROUP BY building;`  
D) `SELECT COUNT(building) FROM departments WHERE building IS NOT NULL;`

---

**Question 12**

You run:
```sql
SELECT department_id, last_name, COUNT(*)
FROM   students
GROUP BY department_id;
```
What happens?

A) It runs fine; `last_name` defaults to the first value in the group  
B) It returns one row per department with an arbitrary `last_name`  
C) Most databases return an error because `last_name` is not in GROUP BY or an aggregate  
D) It returns a row for every student, with COUNT(*) = 1 for each

---

**Question 13**

What does `SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END)` compute?

A) The sum of all `is_active` values  
B) The count of rows where `is_active = 1`  
C) The count of rows where `is_active = 0`  
D) The average of is_active values

---

**Question 14**

Which syntax collects values into a comma-separated string in PostgreSQL?

A) `GROUP_CONCAT(col SEPARATOR ',')`  
B) `STRING_AGG(col, ',') WITHIN GROUP (ORDER BY col)`  
C) `STRING_AGG(col, ',' ORDER BY col)`  
D) `LISTAGG(col, ',')`

---

**Question 15**

A query uses `GROUP BY department_id HAVING COUNT(*) > 2`. What does it return?

A) All rows from departments with more than 2 students  
B) One summary row per department that has more than 2 students  
C) Departments where at least 2 columns are non-NULL  
D) The first 2 rows of each department group

---

## Answer Key

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | B | COUNT(col) skips NULLs. 10 rows − 3 NULLs = 7 |
| 2 | C | COUNT(*) counts every row regardless of NULLs |
| 3 | C | HAVING filters groups after aggregation; WHERE filters rows before |
| 4 | B | AVG ignores NULLs: (100+200+300)/3 = 200 |
| 5 | C | Aggregate functions cannot be used in WHERE — use HAVING |
| 6 | C | FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY |
| 7 | B | SQL Server integer AVG truncates: (1+2+3+4)/4 = 10/4 = 2 |
| 8 | B | When all values are NULL, AVG returns NULL (no non-NULL values to average) |
| 9 | B | WHERE filters rows before grouping — correct place for row-level conditions |
| 10 | B | ROLLUP adds NULL-marked subtotal/grand total rows |
| 11 | B | COUNT(DISTINCT col) is the correct syntax |
| 12 | C | Standard SQL requires non-aggregate SELECT columns to appear in GROUP BY |
| 13 | B | CASE returns 1 for active rows, 0 otherwise; SUM adds them up = active count |
| 14 | C | PostgreSQL STRING_AGG takes the ORDER BY inside the function arguments |
| 15 | B | HAVING produces one aggregated row per passing group |

---

## Score Interpretation

| Score | Interpretation |
|-------|---------------|
| 15/15 | Excellent — ready for Module 05 (Joining Tables) |
| 13–14 | Good — review the questions you missed |
| 11–12 | Passing — re-read relevant sections in lecture-notes.md |
| Below 11 | Re-study Module 04 before proceeding |
