# Module 03 Quiz
## Querying Data: SELECT, WHERE, ORDER BY

**Instructions:** Choose the best answer for each question.  
No time limit for self-study. 60 minutes for formal assessment.  
Passing: 11/15 correct (73%).

---

**Question 1**

Which clause determines which rows are returned from a table?

A) `SELECT`  
B) `FROM`  
C) `WHERE`  
D) `ORDER BY`

---

**Question 2**

What does `SELECT DISTINCT building FROM departments` return?

A) Every row in `departments` with the `building` column
B) One row per unique `building` value
C) The first `building` value alphabetically
D) An error — `DISTINCT` can only be used with `COUNT`

---

**Question 3**

Which query correctly finds students with no phone number on file?

A) `WHERE phone = NULL`  
B) `WHERE phone == NULL`  
C) `WHERE phone IS NULL`  
D) `WHERE ISNULL(phone)`

---

**Question 4**

A student table has 1,000 rows. This query runs: `SELECT * FROM students WHERE gpa > 4.00;`. How many rows are returned?

A) 1,000 — `WHERE` only filters for display, not for count  
B) It depends on the database implementation  
C) 0 — no GPA can exceed 4.00 if a CHECK constraint enforces it  
D) The query raises an error

---

**Question 5**

What does `BETWEEN 3.50 AND 3.80` include?

A) Values greater than 3.50 and less than 3.80 (exclusive on both ends)  
B) Values greater than 3.50 and less than or equal to 3.80  
C) Values greater than or equal to 3.50 and less than or equal to 3.80  
D) Values greater than or equal to 3.50 and less than 3.80

---

**Question 6**

In which platform is `LIKE` case-sensitive by default?

A) MySQL with `utf8mb4_unicode_ci` collation  
B) SQL Server with `SQL_Latin1_General_CP1_CI_AS` collation  
C) PostgreSQL  
D) All three are case-sensitive by default

---

**Question 7**

Which SQL Server clause is the equivalent of MySQL's `LIMIT 5`?

A) `FETCH FIRST 5 ROWS`  
B) `ROWNUM = 5`  
C) `TOP 5`  
D) `SELECT FIRST 5`

---

**Question 8**

You run: `SELECT * FROM students WHERE last_name NOT IN (SELECT last_name FROM alumni)`. The `alumni` table contains some NULL values in `last_name`. What happens?

A) NULLs in the subquery are ignored; the query works normally  
B) The query returns 0 rows because NULL causes all comparisons to be UNKNOWN  
C) SQL raises a syntax error  
D) The query runs but only matches non-NULL alumni last names

---

**Question 9**

Which of the following correctly returns students ranked 6th through 10th by GPA in PostgreSQL?

A) `SELECT … ORDER BY gpa DESC LIMIT 5 OFFSET 5`  
B) `SELECT … ORDER BY gpa DESC LIMIT 10 OFFSET 5`  
C) `SELECT TOP 5 … ORDER BY gpa DESC WHERE ROWNUM > 5`  
D) `SELECT … ORDER BY gpa DESC LIMIT 5 OFFSET 6`

---

**Question 10**

What is the logical processing order of this query?

```sql
SELECT first_name AS fn, gpa FROM students WHERE gpa > 3.0 ORDER BY fn;
```

A) SELECT → FROM → WHERE → ORDER BY  
B) FROM → WHERE → SELECT → ORDER BY  
C) FROM → SELECT → WHERE → ORDER BY  
D) WHERE → FROM → SELECT → ORDER BY

---

**Question 11**

Which expression evaluates to TRUE?

A) `NULL = NULL`  
B) `NULL <> NULL`  
C) `NULL IS NULL`  
D) `NOT NULL = NULL`

---

**Question 12**

You want to retrieve students whose last name contains the letter 'a' anywhere. Which LIKE pattern is correct?

A) `LIKE 'a'`  
B) `LIKE 'a%'`  
C) `LIKE '%a'`  
D) `LIKE '%a%'`

---

**Question 13**

Which statement about `ORDER BY` without `LIMIT` / `TOP` is true?

A) Results are always returned in insertion order  
B) Results are always returned in primary key order  
C) The order of results is not guaranteed  
D) Results are always returned in alphabetical order by the first column

---

**Question 14**

In SQL Server, what is the difference between using `+` and `CONCAT()` for string concatenation when one value is NULL?

A) Both return NULL when any value is NULL  
B) `+` returns NULL when any value is NULL; `CONCAT()` treats NULL as an empty string  
C) `CONCAT()` returns NULL when any value is NULL; `+` treats NULL as an empty string  
D) There is no difference between the two

---

**Question 15**

Which query returns the same result as: `WHERE department_name = 'CS' OR department_name = 'Math' OR department_name = 'Physics'`?

A) `WHERE department_name BETWEEN 'CS' AND 'Physics'`  
B) `WHERE department_name LIKE 'CS' AND 'Math' AND 'Physics'`  
C) `WHERE department_name IN ('CS', 'Math', 'Physics')`  
D) `WHERE department_name = ANY ('CS', 'Math', 'Physics')`

---

## Answer Key

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | C | WHERE filters rows; SELECT picks columns; ORDER BY sorts; FROM identifies the table |
| 2 | B | DISTINCT collapses duplicate values into one row per unique value |
| 3 | C | NULL comparisons must use IS NULL or IS NOT NULL — = NULL never matches |
| 4 | C | With a CHECK(gpa BETWEEN 0.00 AND 4.00) constraint, 0 rows can exceed 4.00 |
| 5 | C | BETWEEN is inclusive on both ends: col >= low AND col <= high |
| 6 | C | PostgreSQL LIKE is case-sensitive; use ILIKE for case-insensitive. MySQL and SQL Server default to case-insensitive |
| 7 | C | SQL Server uses TOP n; PostgreSQL and MySQL use LIMIT n |
| 8 | B | NOT IN with a NULL in the subquery causes every row's comparison to be UNKNOWN, returning 0 rows |
| 9 | A | OFFSET 5 skips 5 rows; LIMIT 5 returns the next 5 — giving rows 6–10 |
| 10 | B | Logical order: FROM → WHERE → SELECT → ORDER BY. That's why aliases work in ORDER BY but not WHERE |
| 11 | C | NULL IS NULL evaluates to TRUE; all comparisons with = or <> against NULL return UNKNOWN |
| 12 | D | %a% matches any string containing 'a'; %a matches ending with 'a'; a% matches starting with 'a' |
| 13 | C | Without ORDER BY, row order is non-deterministic — the engine chooses based on its access plan |
| 14 | B | NVARCHAR + NULL = NULL in SQL Server; CONCAT() converts NULL to '' so concatenation succeeds |
| 15 | C | IN (list) is equivalent to multiple = OR conditions and is more readable |

---

## Score Interpretation

| Score | Interpretation |
|-------|---------------|
| 15/15 | Excellent — ready for Module 04 |
| 13–14 | Good — review the questions you missed |
| 11–12 | Passing — re-read the relevant sections in lecture-notes.md |
| Below 11 | Re-study Module 03 before proceeding |
