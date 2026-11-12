# Module 05 Quiz
## Joining Tables: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF JOIN

**Instructions:** Choose the best answer for each question.  
No time limit for self-study. 60 minutes for formal assessment.  
Passing: 11/15 correct (73%).

---

**Question 1**

A `students` table has 6 rows. A `departments` table has 4 rows. 5 of the 6 students are linked to a department. How many rows does an `INNER JOIN` between the two tables return?

A) 24  
B) 10  
C) 5  
D) 6

---

**Question 2**

Which join type returns ALL rows from the left table, with NULLs for the right side when there is no match?

A) INNER JOIN  
B) CROSS JOIN  
C) RIGHT JOIN  
D) LEFT JOIN

---

**Question 3**

You run:
```sql
SELECT s.first_name, d.department_name
FROM students s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE d.department_id IS NULL;
```
What does this query return?

A) All students and their department names  
B) Students who have no department assignment  
C) Departments with no students  
D) Nothing — the WHERE clause contradicts the JOIN

---

**Question 4**

A `students` table has 8 rows. A `departments` table has 3 rows. How many rows does a CROSS JOIN produce?

A) 11  
B) 8  
C) 3  
D) 24

---

**Question 5**

Which of the following is NOT supported natively in MySQL 8.0?

A) LEFT JOIN  
B) FULL OUTER JOIN  
C) CROSS JOIN  
D) INNER JOIN

---

**Question 6**

You want to list all departments, even those with no students. Which join is correct?

A) `FROM students INNER JOIN departments ON …`  
B) `FROM students LEFT JOIN departments ON …`  
C) `FROM departments LEFT JOIN students ON …`  
D) `FROM departments INNER JOIN students ON …`

---

**Question 7**

After a LEFT JOIN between departments (left) and students (right), you run:
```sql
SELECT d.department_name, COUNT(*) AS n
FROM departments d
LEFT JOIN students s ON s.department_id = d.department_id
GROUP BY d.department_id, d.department_name;
```
A department has 0 students. What does `COUNT(*)` return for that department?

A) 0  
B) 1  
C) NULL  
D) An error

---

**Question 8**

For the same query as Question 7, what would `COUNT(s.student_id)` return for the zero-student department?

A) 0  
B) 1  
C) NULL  
D) An error

---

**Question 9**

What is a self join?

A) A join where both tables are identical copies loaded twice  
B) A join of a table to itself using two aliases  
C) A join that uses the same column on both sides  
D) A join with no ON condition

---

**Question 10**

Which query correctly simulates FULL OUTER JOIN in MySQL?

A) `SELECT … FROM a INNER JOIN b … UNION SELECT … FROM a OUTER JOIN b …`  
B) `SELECT … FROM a LEFT JOIN b … UNION SELECT … FROM a RIGHT JOIN b … WHERE a.id IS NULL`  
C) `SELECT … FROM a FULL JOIN b … ON …`  
D) `SELECT … FROM a LEFT JOIN b … UNION ALL SELECT … FROM a RIGHT JOIN b …`

---

**Question 11**

You write a LEFT JOIN and add a filter condition in the `WHERE` clause on the right-side table. What happens to unmatched left-side rows?

A) They are returned with NULLs on the right side  
B) They are excluded from the result  
C) They are returned with their left-side data duplicated  
D) The query raises an error

---

**Question 12**

Which syntax is equivalent to `JOIN` without a type keyword?

A) `LEFT JOIN`  
B) `OUTER JOIN`  
C) `INNER JOIN`  
D) `CROSS JOIN`

---

**Question 13**

You need to find pairs of students who share the same department. Which technique would you use?

A) CROSS JOIN  
B) Self join on the students table  
C) FULL OUTER JOIN  
D) LEFT JOIN with a subquery

---

**Question 14**

You have four tables: `students`, `departments`, `enrollments`, `courses`. To get student name, department name, and course name in one result set, how many joins do you need?

A) 1  
B) 2  
C) 3  
D) 4

---

**Question 15**

A LEFT JOIN between `departments` (left) and `students` (right) returns a row where `s.student_id` is NULL. What does this row represent?

A) A student who is not enrolled in any course  
B) A department that has no students  
C) A student whose department does not exist  
D) A broken foreign key constraint

---

## Answer Key

| Q | Answer | Explanation |
|---|--------|-------------|
| 1 | C | INNER JOIN returns only matched rows. 5 students have matching departments → 5 rows |
| 2 | D | LEFT JOIN preserves all left-table rows; NULLs for unmatched right rows |
| 3 | B | d.department_id IS NULL after LEFT JOIN means the right side had no match — the student has no department |
| 4 | D | CROSS JOIN = every combination: 8 × 3 = 24 |
| 5 | B | MySQL does not support FULL OUTER JOIN natively |
| 6 | C | To keep all departments: departments must be on the LEFT side of a LEFT JOIN |
| 7 | B | COUNT(*) counts the one row (which has NULLs on the student side) — returns 1, not 0 |
| 8 | A | COUNT(s.student_id) skips NULLs → returns 0 for zero-student departments |
| 9 | B | A self join uses two aliases for the same table to relate rows within it |
| 10 | B | Left + Right UNION (not UNION ALL) with WHERE on right side IS NULL avoids duplicates |
| 11 | B | WHERE on the right-side table after LEFT JOIN filters out NULL rows — effectively turning it into INNER JOIN |
| 12 | C | Plain `JOIN` is shorthand for `INNER JOIN` |
| 13 | B | Self join: `FROM students s1 JOIN students s2 ON s1.department_id = s2.department_id AND s1.student_id < s2.student_id` |
| 14 | C | students → departments (1), students → enrollments (2), enrollments → courses (3) |
| 15 | B | A NULL right-side row from a LEFT JOIN means the left table (department) had no matching rows in the right table (students) |

---

## Score Interpretation

| Score | Interpretation |
|-------|---------------|
| 15/15 | Excellent — ready for Module 06 (Subqueries) |
| 13–14 | Good — review the questions you missed |
| 11–12 | Passing — re-read the relevant sections in lecture-notes.md |
| Below 11 | Re-study Module 05 before proceeding |
