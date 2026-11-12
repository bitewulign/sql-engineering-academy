# Module 02 Quiz
## Creating Tables and Inserting Data

**Instructions:** Choose the best answer for each question.  
No time limit for self-study. 60 minutes for formal assessment.  
Passing: 11/15 correct (73%).

---

**Question 1**

Which statement correctly creates an auto-incrementing primary key in MySQL?

A) `student_id INT IDENTITY(1,1) NOT NULL`  
B) `student_id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (student_id)`  
C) `student_id SERIAL PRIMARY KEY`  
D) `student_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`

---

**Question 2**

You are storing price values such as `19.99` and `1250.00`. Which data type is most appropriate?

A) `FLOAT`  
B) `DOUBLE`  
C) `DECIMAL(10,2)`  
D) `INT`

---

**Question 3**

What is the result of running `UPDATE employees SET salary = 100000;` with no `WHERE` clause?

A) An error — SQL requires a WHERE clause on UPDATE  
B) Only the first row is updated  
C) Every row in `employees` has its salary set to 100000  
D) The statement has no effect

---

**Question 4**

In PostgreSQL, which clause returns the auto-generated ID immediately after an INSERT without requiring a second query?

A) `OUTPUT INSERTED.id`  
B) `SELECT LAST_INSERT_ID()`  
C) `RETURNING id`  
D) `SELECT SCOPE_IDENTITY()`

---

**Question 5**

Which of the following is a key difference between `DELETE FROM students` and `TRUNCATE TABLE students`?

A) DELETE removes the table structure; TRUNCATE only removes data  
B) TRUNCATE is row-by-row logged and fires triggers; DELETE is not  
C) DELETE can target specific rows; TRUNCATE always removes all rows  
D) TRUNCATE requires a WHERE clause; DELETE does not

---

**Question 6**

You want to store short variable-length text (up to 50 characters) that may include Chinese characters in SQL Server. Which data type should you use?

A) `VARCHAR(50)`  
B) `NVARCHAR(50)`  
C) `CHAR(50)`  
D) `TEXT`

---

**Question 7**

What does `IDENTITY(100, 5)` mean on a SQL Server column?

A) The column starts at 5 and increments by 100  
B) The column starts at 100 and increments by 5  
C) The column allows values between 100 and 5  
D) It is an error — IDENTITY only accepts one argument

---

**Question 8**

Which of the following correctly enforces that every row in `products` has a `price` greater than zero?

A) `CONSTRAINT chk_price NOT NULL (price > 0)`  
B) `CONSTRAINT chk_price CHECK (price > 0)`  
C) `CONSTRAINT chk_price PRIMARY KEY (price)`  
D) `CONSTRAINT chk_price DEFAULT (price > 0)`

---

**Question 9**

Why does MySQL require `ENGINE=InnoDB` for foreign key constraints to be enforced?

A) `InnoDB` is the only engine that supports any data types  
B) `InnoDB` supports transactions and row-level locking; `MyISAM` (the older default) does not enforce foreign keys  
C) Foreign keys only work with Unicode character sets, which InnoDB enables  
D) The `ENGINE` keyword is not required — foreign keys work on all engines

---

**Question 10**

You insert a row into `students` and then call `SCOPE_IDENTITY()` in SQL Server. What does it return?

A) The total number of rows in `students`  
B) The highest `student_id` currently in the table  
C) The identity value generated for the last INSERT in the current scope  
D) The seed value of the IDENTITY property

---

**Question 11**

In MySQL, what character set should you specify to ensure full Unicode support (including emoji)?

A) `utf8`  
B) `utf8mb4`  
C) `latin1`  
D) `unicode`

---

**Question 12**

A `professors` table has a foreign key `department_id` referencing `departments`. The foreign key is defined with `ON DELETE CASCADE`. What happens when you delete a department?

A) The DELETE is blocked until all professors in that department are manually deleted  
B) All professors in that department are automatically deleted along with the department  
C) The professors remain, but their `department_id` becomes NULL  
D) An error is raised regardless of the CASCADE setting

---

**Question 13**

Which SQL statement would you use to add a `phone` column (VARCHAR 20, nullable) to an existing `students` table?

A) `INSERT INTO students (phone) VALUES (VARCHAR(20));`  
B) `ALTER TABLE students ADD phone VARCHAR(20);`  
C) `UPDATE students SET phone = VARCHAR(20);`  
D) `CREATE COLUMN phone VARCHAR(20) IN students;`

---

**Question 14**

You want a `created_at` column to automatically store the current timestamp when a row is inserted, and never change after that. Which approach works across all three platforms?

A) `created_at TIMESTAMP AUTO_UPDATE`  
B) `created_at DATETIME DEFAULT NOW() ON UPDATE NOW()`  
C) `created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP` and never include it in UPDATE statements  
D) `created_at TIMESTAMP IDENTITY`

---

**Question 15**

What is the correct order to drop these three tables to avoid a foreign key violation error?

Tables: `students`, `courses`, `enrollments`  
(`enrollments` has FKs referencing both `students` and `courses`)

A) students → courses → enrollments  
B) courses → students → enrollments  
C) enrollments → students → courses  
D) The order does not matter when using DROP TABLE

---

## Answer Key

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | B | MySQL uses `AUTO_INCREMENT`; `IDENTITY` is SQL Server; `SERIAL` and `GENERATED` are PostgreSQL |
| 2 | C | `DECIMAL(10,2)` stores exact decimal values — required for money; FLOAT is approximate |
| 3 | C | UPDATE without WHERE modifies every row — always include WHERE |
| 4 | C | PostgreSQL's `RETURNING` returns inserted row values atomically; the others are SQL Server and MySQL equivalents |
| 5 | C | DELETE can be selective (WHERE); TRUNCATE removes all rows and cannot be targeted |
| 6 | B | `NVARCHAR` stores Unicode; `VARCHAR` in SQL Server is ASCII/Latin-1 only |
| 7 | B | IDENTITY(seed, increment): starts at 100, next values are 105, 110, 115... |
| 8 | B | `CHECK` constraint enforces a logical condition |
| 9 | B | MyISAM parses but ignores FK constraints; InnoDB enforces them |
| 10 | C | `SCOPE_IDENTITY()` returns the identity from the last INSERT in the current scope |
| 11 | B | `utf8mb4` is true UTF-8; MySQL's `utf8` is capped at 3 bytes and cannot store emoji |
| 12 | B | `ON DELETE CASCADE` automatically deletes child rows when the parent is deleted |
| 13 | B | `ALTER TABLE ... ADD column_name type` adds a column to an existing table |
| 14 | C | Specifying the default and not updating it is the cross-platform approach |
| 15 | C | Drop children (enrollments) before parents (students, courses) to respect FK constraints |

---

## Score Interpretation

| Score | Interpretation |
|-------|---------------|
| 15/15 | Excellent — ready for Module 03 |
| 13–14 | Good — review the questions you missed |
| 11–12 | Passing — re-read relevant lecture-notes sections |
| Below 11 | Re-study Module 02 before proceeding |
