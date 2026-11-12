# Module 01 Quiz
## Database Foundations and Introduction to SQL

**Instructions:** Choose the best answer for each question.  
No time limit for self-study. 60 minutes for formal assessment.  
Passing: 11/15 correct (73%).

---

**Question 1**

Which statement best describes the relationship between SQL, T-SQL, and PL/pgSQL?

A) They are three completely different languages that solve different problems  
B) T-SQL and PL/pgSQL are vendor-specific extensions of the SQL standard  
C) PL/pgSQL is a subset of T-SQL  
D) SQL is a subset of T-SQL  

---

**Question 2**

What does NULL represent in SQL?

A) Zero  
B) An empty string  
C) The absence of any value, or an unknown value  
D) False  

---

**Question 3**

What is the result of the expression `NULL = NULL` in SQL?

A) TRUE  
B) FALSE  
C) NULL  
D) An error  

---

**Question 4**

A table's primary key must satisfy which two rules? (Select the best answer)

A) It must be numeric; it must be less than 1,000,000  
B) It must be unique for each row; it cannot be NULL  
C) It must be an auto-incrementing integer; it must be less than the foreign key  
D) It must be the first column in the table; it must be a single column  

---

**Question 5**

Which SQL command category does `CREATE TABLE` belong to?

A) DQL — Data Query Language  
B) DML — Data Manipulation Language  
C) DDL — Data Definition Language  
D) DCL — Data Control Language  

---

**Question 6**

You want to return the first 10 rows of a query result in SQL Server. Which syntax is correct?

A) `SELECT LIMIT 10 * FROM employees;`  
B) `SELECT * FROM employees LIMIT 10;`  
C) `SELECT TOP 10 * FROM employees ORDER BY employee_id;`  
D) `SELECT * FROM employees FETCH FIRST 10;`  

---

**Question 7**

A `students` table has 500 rows. How many rows does this query return?

```sql
SELECT * FROM students WHERE student_id = NULL;
```

A) 500  
B) 0  
C) An error  
D) 1  

---

**Question 8**

What is the result of `COALESCE(NULL, NULL, 'third', 'fourth')`?

A) NULL  
B) 'third'  
C) 'fourth'  
D) 'thirdFourth'  

---

**Question 9**

In PostgreSQL, which operator is used for string concatenation?

A) `+`  
B) `&`  
C) `||`  
D) `CONCAT` only — there is no operator  

---

**Question 10**

Which statement about MySQL's `<=>` operator is correct?

A) It is a comparison that returns NULL when either operand is NULL  
B) It is a NULL-safe equals operator — `NULL <=> NULL` returns TRUE  
C) It is used to test whether a value is greater than or equal to NULL  
D) It is an alias for `IS DISTINCT FROM`  

---

**Question 11**

Which of the following correctly retrieves all rows from `employees` where the `manager_id` column has no value?

A) `SELECT * FROM employees WHERE manager_id = NULL;`  
B) `SELECT * FROM employees WHERE manager_id IS NULL;`  
C) `SELECT * FROM employees WHERE manager_id = 'NULL';`  
D) `SELECT * FROM employees WHERE manager_id <> NULL;`  

---

**Question 12**

Edgar F. Codd's relational model, published in 1970, was based on which mathematical foundations?

A) Graph theory and linear algebra  
B) Set theory and predicate logic  
C) Boolean algebra and decision trees  
D) Object-oriented programming and type theory  

---

**Question 13**

What is the main difference between MySQL's `CONCAT()` function and PostgreSQL's `CONCAT()` function when one argument is NULL?

A) Both return NULL  
B) MySQL returns NULL; PostgreSQL silently skips the NULL and concatenates the rest  
C) PostgreSQL returns NULL; MySQL silently skips the NULL  
D) Both throw a runtime error  

---

**Question 14**

Which of the following is the ANSI SQL standard way to paginate results (supported by all three systems in modern versions)?

A) `SELECT TOP 5 ... SKIP 10`  
B) `SELECT ... LIMIT 5 OFFSET 10`  
C) `SELECT ... OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY`  
D) `SELECT ... ROWNUM BETWEEN 10 AND 15`  

---

**Question 15**

A `courses` table has a foreign key `instructor_id` that references `instructors.instructor_id`. Which action would the database **reject** due to referential integrity?

A) Inserting a new course with an `instructor_id` that exists in `instructors`  
B) Inserting a new course with an `instructor_id` that does not exist in `instructors`  
C) Inserting a new course with `instructor_id` set to NULL (assuming the column allows NULL)  
D) Updating an instructor's name without changing the `instructor_id`  

---

## Answer Key

*(For self-check — instructors: see `solutions/solutions-01.md`)*

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | B | T-SQL and PL/pgSQL are vendor extensions of the ISO/ANSI SQL standard |
| 2 | C | NULL = unknown or missing; not zero, not empty string |
| 3 | C | Any comparison involving NULL returns NULL (unknown), not TRUE or FALSE |
| 4 | B | PK must be unique per row and cannot be NULL — the two fundamental rules |
| 5 | C | CREATE belongs to DDL — it defines/changes database structure |
| 6 | C | T-SQL uses SELECT TOP N ... (requires ORDER BY for deterministic results) |
| 7 | B | The WHERE condition evaluates to NULL (unknown), which is not TRUE — returns 0 rows |
| 8 | B | COALESCE returns the first non-NULL value: 'third' |
| 9 | C | PostgreSQL uses || for string concatenation (also supports CONCAT()) |
| 10 | B | <=> is MySQL's NULL-safe equality — NULL <=> NULL returns 1 (TRUE) |
| 11 | B | IS NULL is the only correct way to test for NULL |
| 12 | B | Codd based the relational model on set theory and first-order predicate logic |
| 13 | B | MySQL's CONCAT returns NULL if any arg is NULL; PostgreSQL's CONCAT treats NULL as '' |
| 14 | C | OFFSET/FETCH is the ANSI SQL 2008 standard, supported by all three modern systems |
| 15 | B | A foreign key constraint prevents inserting a child row referencing a non-existent parent |

---

## Score Interpretation

| Score | Interpretation |
|-------|---------------|
| 15/15 | Excellent — ready for Module 02 |
| 13–14 | Good — review the questions you missed |
| 11–12 | Passing — re-read the relevant lecture-notes sections |
| Below 11 | Re-study Module 01 before proceeding |
