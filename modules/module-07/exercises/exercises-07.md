# Module 07 — Exercises
## Window Functions

---

## Setup

All exercises use the `university` database with these tables:
- `students` (student_id, first_name, last_name, gpa, department_id, enrolled_at, is_active)
- `departments` (department_id, department_name)
- `enrollments` (enrollment_id, student_id, course_id, grade, enrolled_on)
- `courses` (course_id, course_name, credits, department_id)

---

## Beginner Exercises

### Exercise 01
Assign a school-wide rank to each student ordered by GPA descending. Include `first_name`, `last_name`, `gpa`, and a column named `school_rank`.

**Hint:** Use `ROW_NUMBER()`.

---

### Exercise 02
Rank students within each department by GPA (highest first). Include `first_name`, `department_id`, `gpa`, and `dept_rank`. Use `RANK()` so tied GPAs receive the same rank.

---

### Exercise 03
Show each student's GPA alongside their department's average GPA. Include `first_name`, `department_id`, `gpa`, and `dept_avg_gpa` (rounded to 2 decimal places). Do **not** use GROUP BY.

---

### Exercise 04
For each student, show how their GPA compares to the highest GPA in their department. Include `first_name`, `department_id`, `gpa`, `dept_max_gpa`, and `gpa_gap` (the difference).

---

### Exercise 05
Add a `running_count` column that shows how many students have enrolled on or before each student's `enrolled_at` date. Order results by `enrolled_at`.

---

### Exercise 06
Show each student's GPA and the GPA of the student enrolled immediately before them (`prev_gpa`). If there is no previous student, show `NULL`. Order by `enrolled_at`.

---

### Exercise 07
Divide all students into 4 quartiles based on GPA (highest GPA = quartile 1). Include `first_name`, `gpa`, and `quartile`.

---

### Exercise 08
For each department, show the name of the student with the highest GPA using `FIRST_VALUE`. Include every student row: `first_name`, `department_id`, `gpa`, `top_student`.

---

### Exercise 09
Show all three ranking functions — `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()` — for a school-wide GPA ranking (descending). Include `first_name`, `gpa`, and all three rank columns side by side.

---

### Exercise 10
Compute a running sum of GPA values ordered by `enrolled_at`. Include `first_name`, `enrolled_at`, `gpa`, and `running_gpa_sum`.

---

## Intermediate Exercises

### Exercise 11
Find the **top 2 students per department** by GPA. Return only those rows, with columns `first_name`, `department_id`, and `gpa`.

**Hint:** Use a CTE with `ROW_NUMBER()`, then filter `WHERE rn <= 2`.

---

### Exercise 12
For each student, compute the **3-row moving average** GPA based on `enrolled_at` order (current row plus the 2 rows immediately before it). Include `first_name`, `enrolled_at`, `gpa`, and `moving_avg_3` (rounded to 2 decimal places).

---

### Exercise 13
Compute both `PERCENT_RANK()` and `CUME_DIST()` for students ordered by GPA ascending. Include `first_name`, `gpa`, `pct_rank` (4 decimal places), and `cume_dist` (4 decimal places).

---

### Exercise 14
Use `DENSE_RANK()` to find students who are ranked **2nd or 3rd** in their department by GPA. Return `first_name`, `department_id`, `gpa`, and `dept_rank`.

**Hint:** Wrap in a CTE and filter WHERE dense_rank IN (2, 3).

---

### Exercise 15
For each student, show the department's **minimum and maximum GPA** in the same row using aggregate window functions. Include `first_name`, `department_id`, `gpa`, `dept_min_gpa`, and `dept_max_gpa`.

---

## Challenge Exercises

### Exercise 16
Write a query that shows each student's GPA, the GPA of the student enrolled **one before** them, and the **GPA change** (`gpa - prev_gpa`). Where there is no previous student, show `0` as the previous GPA and `0` as the change. Order by `enrolled_at`.

Expected columns: `first_name`, `enrolled_at`, `gpa`, `prev_gpa`, `gpa_change`.

---

### Exercise 17
Identify every student whose GPA is **above their department average**. For each such student, show `first_name`, `department_id`, `gpa`, `dept_avg`, and `above_by` (rounded to 2 decimal places).

Do not use a subquery. Use only window functions and a CTE for filtering.

---

### Exercise 18
For each department, show:
- The department name
- The student with the **highest** GPA (`top_student`)
- The student with the **lowest** GPA (`bottom_student`)
- The department GPA **spread** (max GPA minus min GPA, rounded to 2 decimal places)

Each department should appear as **one row**.

**Hint:** Aggregate window functions inside a CTE, then collapse with GROUP BY or use MAX/MIN in the outer query.

---

## Interview Questions

### IQ-01
What is the difference between `RANK()` and `DENSE_RANK()`? When would you choose one over the other?

---

### IQ-02
Explain what `PARTITION BY` does in a window function. How does it differ from `GROUP BY`?

---

### IQ-03
Why can you not filter on a window function in a `WHERE` clause? How do you work around this?

---

### IQ-04
What does `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` mean? What is the difference between `ROWS` and `RANGE`?

---

### IQ-05
What is the LAST_VALUE bug that many SQL developers encounter, and how do you fix it?

---

### IQ-06
How would you write a "top N per group" query using window functions? What alternative approaches exist?

---

### IQ-07
What does `LAG(col, 1, 0)` return for the very first row in its partition? Why?

---

### IQ-08
Compare `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()` for the input values: `[90, 85, 85, 80]`. What does each function produce?
