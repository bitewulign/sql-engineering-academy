# Module 08 — Quiz
## Data Modification

**Instructions:** Choose the single best answer. Pass mark: 11 / 15.

---

**Q1.** Which statement best describes the risk of `UPDATE students SET gpa = 4.00;` without a WHERE clause?

A) Only the first row is updated  
B) The statement raises a syntax error  
C) Every row in the table is updated  
D) The update is blocked if any foreign key references exist  

---

**Q2.** What is the correct syntax to insert three rows in a single MySQL/PostgreSQL statement?

A) Three separate INSERT statements inside a transaction  
B) `INSERT INTO t (col) VALUES (1); INSERT INTO t (col) VALUES (2); INSERT INTO t (col) VALUES (3);`  
C) `INSERT INTO t (col) VALUES (1), (2), (3);`  
D) `INSERT INTO t (col) SELECT 1 UNION SELECT 2 UNION SELECT 3;`  

---

**Q3.** What does `INSERT INTO archive SELECT * FROM students WHERE is_active = 0;` do?

A) Creates a new table called archive  
B) Copies all inactive student rows into the archive table  
C) Moves rows from students to archive and deletes them from students  
D) Raises an error because INSERT and SELECT cannot be combined  

---

**Q4.** You run `DELETE FROM students;` without a WHERE clause. What happens?

A) Nothing — DELETE requires a WHERE clause  
B) The first row is deleted  
C) All rows are deleted but the table structure remains  
D) The table and all its rows are dropped  

---

**Q5.** Which of the following is a key difference between DELETE and TRUNCATE?

A) DELETE is faster than TRUNCATE for large tables  
B) TRUNCATE supports a WHERE clause; DELETE does not  
C) DELETE logs individual row deletions; TRUNCATE deallocates pages  
D) TRUNCATE fires row-level triggers; DELETE does not  

---

**Q6.** In MySQL, `INSERT INTO t VALUES (1) ON DUPLICATE KEY UPDATE count = count + 1;` — when does the UPDATE portion execute?

A) Always, on every INSERT  
B) Only when a PRIMARY KEY or UNIQUE constraint would be violated  
C) Only when the table is empty  
D) When the row already exists AND the new value is different  

---

**Q7.** In PostgreSQL, `ON CONFLICT (course_id) DO UPDATE SET … = EXCLUDED.enrollment_count` — what does `EXCLUDED` refer to?

A) The existing row in the target table  
B) The row that was attempted to be inserted (the conflicting row)  
C) Rows deleted by a previous DELETE statement  
D) NULL values excluded from the index  

---

**Q8.** What is a **dirty read**?

A) Reading a row that has been deleted  
B) Reading uncommitted data from another transaction that may be rolled back  
C) Reading a row modified by the current transaction  
D) Reading a NULL value from a nullable column  

---

**Q9.** Which isolation level prevents dirty reads but NOT non-repeatable reads?

A) READ UNCOMMITTED  
B) READ COMMITTED  
C) REPEATABLE READ  
D) SERIALIZABLE  

---

**Q10.** What is the default isolation level for MySQL 8.0?

A) READ UNCOMMITTED  
B) READ COMMITTED  
C) REPEATABLE READ  
D) SERIALIZABLE  

---

**Q11.** What does `ROLLBACK TO SAVEPOINT sp1;` do?

A) Ends the entire transaction and undoes all changes  
B) Commits all changes up to sp1 permanently  
C) Undoes changes made after sp1 was set, but keeps changes before it  
D) Deletes the savepoint and all subsequent data  

---

**Q12.** Which SQL Server clause shows which rows were inserted, updated, or deleted, and what values changed?

A) RETURNING  
B) OUTPUT  
C) WITH RESULTS  
D) PRINT  

---

**Q13.** In SQL Server MERGE, `WHEN NOT MATCHED BY SOURCE THEN DELETE` means:

A) Rows in the source that do not match the target are deleted from the source  
B) Rows in the target that have no matching row in the source are deleted from the target  
C) The MERGE statement fails when no row matches  
D) Unmatched source rows are ignored  

---

**Q14.** What is the ACID property that guarantees a committed transaction survives a system crash?

A) Atomicity  
B) Consistency  
C) Isolation  
D) Durability  

---

**Q15.** You need to update all students in the 'Physics' department using data from the `departments` table. Which syntax is correct for SQL Server?

A) `UPDATE students SET gpa = 4.00 JOIN departments ON …`  
B) `UPDATE s SET s.gpa = 4.00 FROM students s JOIN departments d ON … WHERE d.department_name = 'Physics'`  
C) `UPDATE students s, departments d SET s.gpa = 4.00 WHERE …`  
D) `UPDATE students SET gpa = 4.00 WHERE department_id IN (SELECT department_id FROM departments WHERE department_name = 'Physics')`  

---

## Answer Key (Instructor Use Only)

| Q | Answer | Topic |
|---|--------|-------|
| 1 | C | UPDATE without WHERE |
| 2 | C | Multi-row INSERT |
| 3 | B | INSERT … SELECT |
| 4 | C | DELETE without WHERE |
| 5 | C | DELETE vs TRUNCATE |
| 6 | B | ON DUPLICATE KEY trigger condition |
| 7 | B | EXCLUDED in PostgreSQL |
| 8 | B | Dirty read definition |
| 9 | B | READ COMMITTED |
| 10 | C | MySQL default isolation |
| 11 | C | ROLLBACK TO SAVEPOINT |
| 12 | B | SQL Server OUTPUT clause |
| 13 | B | MERGE NOT MATCHED BY SOURCE |
| 14 | D | Durability |
| 15 | B | SQL Server UPDATE … FROM JOIN |

> Note: Q15 option D (subquery with IN) is also functionally correct but option B (UPDATE … FROM) is the canonical SQL Server join-based syntax.

Pass = 11 / 15
