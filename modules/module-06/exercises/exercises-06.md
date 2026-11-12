# Module 06 — Exercises
## Subqueries

Attempt every exercise before checking `solutions/solutions-06.md`.

---

## Beginner Exercises (1–10)

**Exercise 1 — Scalar subquery in WHERE**  
Return all students whose GPA is above the school-wide average GPA.  
Include: first name, last name, GPA.

---

**Exercise 2 — Scalar subquery in SELECT**  
Return each student's first name, GPA, and the school average GPA (as a computed column).  
Round the average to 2 decimal places.

---

**Exercise 3 — IN with subquery**  
Return the first and last name of all students who are enrolled in at least one course.  
Use an `IN` subquery (not a JOIN).

---

**Exercise 4 — NOT IN with subquery**  
Return all students who are NOT enrolled in any course.  
Use a `NOT IN` subquery.  
⚠️ Hint: ensure the subquery has no NULLs in `student_id`.

---

**Exercise 5 — EXISTS**  
Rewrite Exercise 3 using `EXISTS` instead of `IN`.  
Both queries should return the same students.

---

**Exercise 6 — NOT EXISTS**  
Rewrite Exercise 4 using `NOT EXISTS`.  
Both queries should return the same students.

---

**Exercise 7 — Scalar subquery with MAX**  
Return the student(s) who have the highest GPA in the school.  
Use a scalar subquery.

---

**Exercise 8 — Scalar subquery with department filter**  
Return all students whose GPA is higher than the average GPA of the Computer Science department.  
Use a scalar subquery with a WHERE condition in the inner query.

---

**Exercise 9 — Derived table**  
Write a derived table (subquery in FROM) that computes the average GPA per department.  
Then select only the departments whose average GPA is above 3.50.  
Include: department name, average GPA.

---

**Exercise 10 — CTE (Basic)**  
Rewrite Exercise 9 as a CTE using `WITH`.  
The result should be identical.

---

## Intermediate Exercises (11–15)

**Exercise 11 — Correlated subquery**  
For each student, return their first name, last name, GPA, and the number of courses they are enrolled in.  
Use a correlated subquery in the SELECT list for the course count.

---

**Exercise 12 — Correlated subquery with comparison**  
Return students who are enrolled in more courses than the average number of courses per student.  
Use a correlated or scalar subquery.

---

**Exercise 13 — Subquery in HAVING**  
Return departments whose total number of students is greater than the average number of students per department across the whole school.  
Use a subquery inside HAVING.

---

**Exercise 14 — Multi-step CTE**  
Using two CTEs:
1. CTE 1: Compute the number of active students per department.
2. CTE 2: Compute the average number of active students across departments.
3. Main query: Return departments with more active students than the average.

---

**Exercise 15 — NOT IN vs NOT EXISTS (NULL comparison)**  
The `employees` table has a `manager_id` column containing NULLs (Amara is the CEO with no manager).

Write two queries:
- **Query A:** List employees who are not anyone's manager using `NOT IN`.
- **Query B:** Same result using `NOT EXISTS`.

Run both and compare row counts. Explain in a comment why they may differ.

---

## Advanced Challenges (16–18)

**Challenge 16 — Top student per department**  
Return the student with the highest GPA in each department.  
If there is a tie for highest GPA, return all tied students.  
Use a correlated subquery (not window functions).

---

**Challenge 17 — Departments above school average (three approaches)**  
Write the same query three ways and confirm they produce identical results:
- Version A: Derived table in FROM
- Version B: CTE with WITH
- Version C: Scalar subquery in HAVING

The query: return departments whose average student GPA is above the school-wide average.

---

**Challenge 18 — Chained CTEs**  
Using three CTEs:
1. `enrolled_students`: students who have at least one enrollment
2. `dept_enrolled_count`: number of enrolled students per department
3. `dept_with_rate`: join to departments to get department name and enrollment rate (enrolled ÷ total students as a percentage)

Return: department name, enrolled count, total students, enrollment rate rounded to 1 decimal place.  
Sort by enrollment rate descending.

---

## Interview Practice Questions

1. What is a scalar subquery? Where can it appear in a SQL statement?
2. What happens when a scalar subquery returns more than one row?
3. What is the NULL trap with `NOT IN`? How do you avoid it?
4. What is the difference between `IN` and `EXISTS`?
5. When is a correlated subquery said to be correlated?
6. What is a derived table? What requirement does it have that a CTE does not?
7. What is a CTE? How does it differ from a derived table?
8. When would you choose a CTE over a derived table?

---

## Submission Checklist

- [ ] Exercises 1–10 completed
- [ ] Exercises 11–15 completed
- [ ] Challenges 16–18 attempted
- [ ] SQL files run without errors on at least one platform
- [ ] Quiz 06 taken (minimum passing score: 11/15)
