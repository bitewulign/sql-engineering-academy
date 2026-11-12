# Module 09 — Quiz
## Schema Design & DDL

**Instructions:** Choose the single best answer. Pass mark: 11 / 15.

---

**Q1.** A table is in 1NF. Which additional requirement must be met for it to be in 2NF?

A) No transitive dependencies  
B) Every non-key column must depend on the entire primary key, not just part of it  
C) The table must have a single-column primary key  
D) No column may contain NULL values  

---

**Q2.** Which data type should you use to store a monetary value like `$9999.99` with no rounding errors?

A) `FLOAT`  
B) `DOUBLE`  
C) `DECIMAL(6, 2)`  
D) `INT`  

---

**Q3.** What automatically happens when you define a `PRIMARY KEY` on a column?

A) The column allows NULL values  
B) A unique index is created on that column  
C) A FOREIGN KEY is created pointing to the same column  
D) The column is set to AUTO_INCREMENT  

---

**Q4.** In MySQL, you try to delete a row from `departments` that is referenced by a row in `students` with `ON DELETE RESTRICT`. What happens?

A) The delete succeeds and the student's `department_id` is set to NULL  
B) The delete succeeds and the student row is also deleted  
C) The delete fails with a foreign key constraint error  
D) The delete succeeds silently  

---

**Q5.** Which SQL correctly adds a column `phone VARCHAR(20)` to an existing `students` table in MySQL?

A) `UPDATE students ADD COLUMN phone VARCHAR(20);`  
B) `ALTER TABLE students ADD COLUMN phone VARCHAR(20);`  
C) `MODIFY TABLE students ADD phone VARCHAR(20);`  
D) `CREATE COLUMN phone VARCHAR(20) ON students;`  

---

**Q6.** You have a composite index on `(department_id, gpa)`. Which query **cannot** use this index?

A) `WHERE department_id = 1`  
B) `WHERE department_id = 1 AND gpa > 3.5`  
C) `WHERE gpa > 3.5`  
D) `ORDER BY department_id, gpa`  

---

**Q7.** What is a **covering index**?

A) An index that spans all tables in the database  
B) An index whose key columns plus included columns satisfy all columns needed by a query, avoiding a table lookup  
C) An index automatically created by the database on all columns  
D) An index that covers NULL values  

---

**Q8.** In PostgreSQL, `SERIAL` is shorthand for which underlying construct?

A) `INT NOT NULL PRIMARY KEY`  
B) `INT DEFAULT nextval('<table>_<col>_seq')`  
C) `INT GENERATED ALWAYS AS IDENTITY`  
D) `BIGINT AUTO_INCREMENT`  

---

**Q9.** What does `ON DELETE CASCADE` mean on a FOREIGN KEY?

A) Deleting the child row automatically deletes the parent row  
B) Deleting the parent row automatically deletes all matching child rows  
C) Deleting either row prevents the other from being deleted  
D) Deleting the parent row sets the child FK column to NULL  

---

**Q10.** In SQL Server, which function should you use to get the most recently inserted identity value in the **current scope**?

A) `@@IDENTITY`  
B) `LAST_INSERT_ID()`  
C) `SCOPE_IDENTITY()`  
D) `IDENT_CURRENT()`  

---

**Q11.** Which of the following is a 3NF violation?

A) A table with a composite PK  
B) A non-key column that depends on another non-key column  
C) A table with no UNIQUE constraint  
D) A column that allows NULL  

---

**Q12.** In SQL Server, when must you use `NVARCHAR` instead of `VARCHAR`?

A) When the column will store more than 255 characters  
B) When the column needs to store Unicode characters (non-ASCII, e.g., Arabic, Chinese, emoji)  
C) When the column is used as a PRIMARY KEY  
D) When the column is indexed  

---

**Q13.** What is a **partial index** (called a **filtered index** in SQL Server)?

A) An index that covers only the first N characters of a column  
B) An index built on a subset of rows matching a WHERE condition  
C) An index on a subset of columns in the table  
D) An index with lower precision for float columns  

---

**Q14.** A table has `gpa DECIMAL(3, 2) CHECK (gpa BETWEEN 0.00 AND 4.00)`. What happens if you try to insert `gpa = 4.50`?

A) The row is inserted with `gpa` truncated to 4.00  
B) The insert is rejected by the CHECK constraint  
C) The insert succeeds but a warning is logged  
D) The database rounds 4.50 to 4.00 automatically  

---

**Q15.** Which unique feature does PostgreSQL have that MySQL and SQL Server do not, regarding DDL?

A) PostgreSQL can create indexes on expressions  
B) PostgreSQL supports partial indexes  
C) PostgreSQL DDL statements are fully transactional and can be rolled back  
D) PostgreSQL supports generated columns  

---

## Answer Key (Instructor Use Only)

| Q | Answer | Topic |
|---|--------|-------|
| 1 | B | 2NF — no partial dependencies |
| 2 | C | DECIMAL for money |
| 3 | B | PK creates unique index |
| 4 | C | ON DELETE RESTRICT |
| 5 | B | ALTER TABLE ADD COLUMN |
| 6 | C | Leftmost prefix rule |
| 7 | B | Covering index definition |
| 8 | B | SERIAL = DEFAULT nextval() |
| 9 | B | ON DELETE CASCADE |
| 10 | C | SCOPE_IDENTITY() |
| 11 | B | 3NF — transitive dependency |
| 12 | B | NVARCHAR for Unicode |
| 13 | B | Partial / filtered index |
| 14 | B | CHECK constraint rejects |
| 15 | C | PostgreSQL transactional DDL |

Pass = 11 / 15
