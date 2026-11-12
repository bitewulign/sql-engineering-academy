# Module 05 — Exercises
## Joining Tables: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF JOIN

Attempt every exercise before checking `solutions/solutions-05.md`.

---

## Beginner Exercises (1–10)

**Exercise 1 — INNER JOIN two tables**  
Write a query that returns each student's first name, last name, and their department name.  
Only include students who are assigned to a department.

---

**Exercise 2 — INNER JOIN with ORDER BY**  
Return student full name (concatenated as one column) and department name.  
Sort alphabetically by department name, then by student last name within each department.

---

**Exercise 3 — LEFT JOIN — all students**  
Return all students and their department name.  
Students not assigned to any department should show `'Unassigned'` instead of NULL.

---

**Exercise 4 — Anti-join — students without a department**  
Using a LEFT JOIN, find all students who are NOT assigned to any department.  
Return their first name, last name, and email.

---

**Exercise 5 — LEFT JOIN — departments with zero students**  
Return all departments, including those with no enrolled students.  
Include a column showing the student count for each department.

---

**Exercise 6 — RIGHT JOIN**  
Write the same query as Exercise 5 using a RIGHT JOIN (swap the table order).  
Confirm the results are identical.

---

**Exercise 7 — INNER JOIN + WHERE**  
Return students who are enrolled in the Computer Science department and have a GPA above 3.50.  
Include: first name, last name, GPA, department name.

---

**Exercise 8 — INNER JOIN + COUNT (GROUP BY)**  
For each department, return the department name and number of students enrolled.  
Only include departments that have at least 1 student.  
Sort by student count descending.

---

**Exercise 9 — Three-table JOIN**  
Return each student's first name, last name, and the names of all courses they are enrolled in.  
(Tables: `students` → `enrollments` → `courses`)

---

**Exercise 10 — CROSS JOIN**  
Write a CROSS JOIN between `students` and `departments`.  
How many rows does it produce? (State the formula: rows = X × Y.)

---

## Intermediate Exercises (11–15)

**Exercise 11 — LEFT JOIN + GROUP BY (zero counts)**  
Return every department name and the number of **active** students in each.  
Departments with no active students should show 0, not be excluded.

Hint: filter `is_active = 1` in the ON clause, not in WHERE.

---

**Exercise 12 — Four-table JOIN**  
Return each student's full name, their department name, and the courses they are enrolled in.  
(Tables: `students`, `departments`, `enrollments`, `courses`)

---

**Exercise 13 — FULL OUTER JOIN (PostgreSQL / SQL Server)**  
Write a FULL OUTER JOIN between `students` and `departments`.  
Then add a WHERE clause to find only the rows where either side has no match (unmatched students OR unmatched departments).

For MySQL: simulate with LEFT JOIN UNION RIGHT JOIN.

---

**Exercise 14 — SELF JOIN**  
Using the `employees` table (created in the SQL code file), write a self join that lists each employee's name and their manager's name.  
Employees with no manager should still appear, with `'(no manager)'` shown.

---

**Exercise 15 — JOIN + aggregate**  
For each department, return:
- Department name
- Total students
- Average GPA (rounded to 2 decimal places)
- Maximum GPA

Include departments with no students (avg GPA = NULL is fine).  
Sort by average GPA descending.

---

## Advanced Challenges (16–18)

**Challenge 16 — ON vs WHERE with LEFT JOIN**  
Create two versions of the following query and compare the row counts:

**Version A:** LEFT JOIN students to departments, then `WHERE d.building = 'Tech Hall'`  
**Version B:** LEFT JOIN students to departments with `AND d.building = 'Tech Hall'` in the ON clause

Explain in a comment why the row counts differ.

---

**Challenge 17 — Finding gaps with anti-join**  
Write a query that returns all departments that have **no** students enrolled.  
Return department name and building.

Then write a second version: students who are enrolled in **no** courses.

---

**Challenge 18 — Cross-platform FULL OUTER JOIN**  
Write the same FULL OUTER JOIN query for all three platforms:
- PostgreSQL and SQL Server: use `FULL OUTER JOIN`
- MySQL: simulate with `LEFT JOIN UNION RIGHT JOIN`

The query should return: student first name (or NULL), department name (or NULL),  
for all unmatched rows only (no matched rows in the output).

---

## Interview Practice Questions

1. What is the difference between INNER JOIN and LEFT JOIN?
2. What is a Cartesian product? How does it happen accidentally?
3. Can you use FULL OUTER JOIN in MySQL? If not, how do you simulate it?
4. What is the difference between putting a filter in the ON clause vs the WHERE clause for a LEFT JOIN?
5. What does `COUNT(s.student_id)` return for a department with no students (after a LEFT JOIN)? What would `COUNT(*)` return?
6. What is a self join? Give an example use case.
7. How do you join three tables? Describe the syntax.
8. When would you use a CROSS JOIN?

---

## Submission Checklist

- [ ] Exercises 1–10 completed
- [ ] Exercises 11–15 completed
- [ ] Challenges 16–18 attempted
- [ ] SQL files run without errors
- [ ] Quiz 05 taken (minimum passing score: 11/15)
