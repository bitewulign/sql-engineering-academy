# Module 10 — Exercises
## Subqueries & CTEs

**Database:** `university`  
**Tables:** students, departments, courses, enrollments, faculty, faculty_courses

---

## Beginner Exercises (1–10)

**Exercise 1**  
Write a query that returns all students whose GPA is above the school-wide average. Display `first_name`, `last_name`, and `gpa`. Order by `gpa` descending.

---

**Exercise 2**  
Write a scalar subquery in the SELECT list to add a column `school_avg` to every student row. Also add a column `diff` showing how far above or below the average each student is. Round both to 2 decimal places.

---

**Exercise 3**  
Using a subquery in the HAVING clause, find all departments whose average GPA is above the school-wide average. Return `department_id` and `dept_avg`, ordered by `dept_avg` descending.

---

**Exercise 4**  
Write a table subquery (derived table) in the FROM clause to find each student's GPA relative to their department average. Return `first_name`, `last_name`, `gpa`, and `dept_avg`. Filter to only show students who are above their department average.

---

**Exercise 5**  
Write a correlated subquery that returns, for each student, their `first_name`, `last_name`, `gpa`, and their own department's average GPA as `dept_avg`. (Do not use a JOIN — use a correlated subquery in the SELECT list.)

---

**Exercise 6**  
Using `EXISTS`, find all students who have at least one enrollment. Return `student_id`, `first_name`, and `last_name`.

---

**Exercise 7**  
Using `NOT EXISTS`, find all students who have NO enrollments. Return `student_id`, `first_name`, and `last_name`.

---

**Exercise 8**  
Using `IN` with a subquery, find the names of all courses that have at least one enrollment. Return `course_name` and `credits`, ordered by `course_name`.

---

**Exercise 9**  
Write a simple CTE named `dept_summary` that computes `department_id`, `avg_gpa` (rounded to 2 decimal places), and `student_count` for each department. Then use it to return all departments with more than 2 students, joined to `departments` for the name.

---

**Exercise 10**  
Write a CTE that finds the student with the highest GPA in each department (use ROW_NUMBER). Return `department_name`, `first_name`, `last_name`, and `gpa`.

---

## Intermediate Exercises (11–15)

**Exercise 11**  
Write a stacked CTE with two CTEs:
1. `dept_stats` — per-department: `department_id`, `student_count`, `avg_gpa`
2. `dept_ranked` — adds a `gpa_rank` column using `RANK() OVER (ORDER BY avg_gpa DESC)`

Final SELECT: return `department_name`, `avg_gpa`, `student_count`, and `gpa_rank`, ordered by rank.

---

**Exercise 12**  
Using a CTE, find the top 3 students per department by GPA (use ROW_NUMBER with PARTITION BY). Return `department_name`, `first_name`, `last_name`, `gpa`, and `dept_rank`. Order by department name, then rank.

---

**Exercise 13**  
Write an enrollment report using two stacked CTEs:
1. `dept_total` — total students per department
2. `dept_enrolled` — count of students who have at least one enrollment per department

Final SELECT: return `department_name`, `total_students`, `enrolled_students`, and `enrollment_pct` (rounded to 1 decimal). Use LEFT JOIN to include departments with zero enrollments.

---

**Exercise 14**  
Write a query using `NOT EXISTS` to find courses that have NO enrollments. Return `course_id`, `course_name`, and `credits`.

---

**Exercise 15**  
Using `NOT EXISTS` (the NULL-safe approach), find students who are NOT enrolled in course_id 1.  
Then write the same query using `NOT IN`.  
Explain in a comment why `NOT IN` can silently return 0 rows.

---

## Challenge Exercises (16–18)

**Exercise 16 — Recursive CTE: Organization Hierarchy**

Create the following `org_demo` table and data, then answer the two questions below using recursive CTEs.

```sql
-- Create the table
CREATE TABLE org_demo (
    id         INT NOT NULL,       -- MySQL: AUTO_INCREMENT; PG: SERIAL; SS: IDENTITY(1,1)
    name       VARCHAR(100) NOT NULL,
    title      VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    PRIMARY KEY (id)
);

-- Insert data (adjust syntax for your platform)
INSERT INTO org_demo (id, name, title, manager_id) VALUES
    (1, 'Raj Patel',     'CEO',              NULL),
    (2, 'Sofia Chen',    'CTO',              1),
    (3, 'Omar Farouq',   'CFO',              1),
    (4, 'Amara Diallo',  'VP Engineering',   2),
    (5, 'Carlos Rivera', 'VP Infrastructure',2),
    (6, 'Priya Sharma',  'Lead Engineer',    4),
    (7, 'Yuki Tanaka',   'Engineer',         6),
    (8, 'Lena Müller',   'FP&A Manager',     3),
    (9, 'Ibrahim Hassan','Controller',       3);
```

**Part A:** Write a recursive CTE that traverses the full hierarchy, outputting each person's name, title, depth (CEO = 0), and their reporting path as a string (e.g., `Raj Patel → Sofia Chen → Amara Diallo`).

**Part B:** Write a recursive CTE that finds all direct and indirect reports of **Sofia Chen (id = 2)**.

Include a depth guard to prevent infinite recursion. For SQL Server, use `OPTION (MAXRECURSION 50)`.

---

**Exercise 17 — Relational Division with NOT EXISTS**

Using `NOT EXISTS` (double negation), write a query that finds all students who are enrolled in **every** course that exists in the `courses` table.

A student qualifies if there is no course for which they have no enrollment.

Hint:
```
WHERE NOT EXISTS (
    SELECT course_id FROM courses c
    WHERE NOT EXISTS (
        SELECT 1 FROM enrollments e WHERE e.student_id = s.student_id AND e.course_id = c.course_id
    )
)
```

---

**Exercise 18 — Multi-Step CTE Analytics Pipeline**

Build a 4-step CTE pipeline:

1. `student_stats` — per student: `student_id`, `first_name`, `last_name`, `department_id`, `gpa`, `enrollment_count` (number of courses enrolled in)
2. `dept_summary` — per department: `department_id`, `avg_gpa`, `avg_enrollments`, `student_count`
3. `dept_ranked` — adds `gpa_rank` and `enroll_rank` using RANK() window functions
4. `dept_labeled` — joins to `departments` for the name

Final SELECT: return all columns from `dept_labeled`, ordered by `gpa_rank`.

---

## Inquiry Questions (IQ 1–8)

**IQ 1**  
What is the difference between a correlated subquery and a non-correlated subquery? How many times does each execute?

**IQ 2**  
Why does `NOT IN` return zero rows when the subquery contains a NULL value? Give an example using three-valued logic (TRUE / FALSE / UNKNOWN).

**IQ 3**  
Can a scalar subquery return zero rows? What value does the outer query receive in that case?

**IQ 4**  
What is the difference between a CTE and a temporary table? When would you prefer one over the other?

**IQ 5**  
MySQL and PostgreSQL require `WITH RECURSIVE`. SQL Server uses just `WITH`. What is the practical implication of using `WITH RECURSIVE` syntax in a SQL Server script?

**IQ 6**  
In a recursive CTE, what is the purpose of `UNION ALL`? What would happen if you used `UNION` instead?

**IQ 7**  
What does the leftmost-prefix rule mean for composite indexes? Give an example index and show which WHERE clauses can and cannot use it.

**IQ 8**  
Give two real-world scenarios where a recursive CTE is the most natural tool to use. Explain why a non-recursive approach would be more complex.
