# Module 10 — Quiz
## Subqueries & CTEs

**15 questions · Pass mark: 11/15**

---

**Q1.** A scalar subquery is placed in the SELECT list. It returns no rows for a particular outer row. What value does the outer query receive for that column?

- A) An error is raised
- B) 0
- C) NULL
- D) An empty string

**Answer: C**
*A scalar subquery that returns zero rows produces NULL — not an error. Only returning more than one row causes an error.*

---

**Q2.** Which of the following statements about correlated subqueries is TRUE?

- A) The inner query executes once for the entire outer query
- B) The inner query references at least one column from the outer query
- C) The inner query cannot reference aggregate functions
- D) Correlated subqueries always outperform equivalent JOINs

**Answer: B**
*A correlated subquery references a column from the outer query in its WHERE clause, causing it to run once per outer row.*

---

**Q3.** You run this query and get zero rows, even though you know some students have no matching rows in `expelled`:

```sql
SELECT * FROM students
WHERE student_id NOT IN (SELECT student_id FROM expelled);
```

What is the most likely cause?

- A) The `NOT IN` operator is not supported by this database
- B) The `expelled.student_id` column contains at least one NULL value
- C) The `students` table is empty
- D) `NOT IN` with a subquery always returns zero rows

**Answer: B**
*When the subquery returns any NULL, `NOT IN` evaluates to UNKNOWN for every outer row, so no rows satisfy the predicate. Use `NOT EXISTS` instead.*

---

**Q4.** Which SQL keyword makes a subquery in the FROM clause valid?

- A) Every derived table must have a column alias
- B) Every derived table must have a table alias
- C) The derived table must be wrapped in `()` only if it uses GROUP BY
- D) The derived table must be named with AS only in MySQL

**Answer: B**
*All databases require a table alias on a derived table (subquery) in the FROM clause. Without it, the query is a syntax error.*

---

**Q5.** What does `EXISTS (SELECT 1 FROM …)` return when the subquery produces at least one row?

- A) The number 1
- B) The first matching row
- C) TRUE
- D) A result set of 1 row

**Answer: C**
*`EXISTS` returns a boolean TRUE or FALSE. It stops scanning as soon as the first row is found, regardless of what the SELECT list contains.*

---

**Q6.** You want to write a CTE that is referenced twice in the final SELECT statement. Which syntax is correct?

- A) Write two separate WITH clauses, one for each reference
- B) Write one WITH clause, define the CTE once, and reference it by name twice in the SELECT
- C) Assign the CTE to a variable before using it
- D) CTEs cannot be referenced more than once

**Answer: B**
*A CTE is defined once in a single WITH block and can be referenced by its name as many times as needed within the same statement.*

---

**Q7.** MySQL 8.0 and PostgreSQL 16 require `WITH RECURSIVE` for recursive CTEs. What keyword does SQL Server 2022 use?

- A) `WITH RECURSIVE`
- B) `WITH LOOP`
- C) `WITH` (no RECURSIVE keyword — recursion is auto-detected)
- D) `RECURSIVE WITH`

**Answer: C**
*SQL Server does not support the `RECURSIVE` keyword. Using `WITH RECURSIVE` in SQL Server causes a syntax error.*

---

**Q8.** In a recursive CTE, what is the purpose of the anchor member?

- A) It guards against infinite recursion by setting a depth limit
- B) It is the base case that initializes the result set without recursion
- C) It is the step that references the CTE itself
- D) It filters the final output to remove duplicates

**Answer: B**
*The anchor member defines the starting rows (base case). The recursive member then references those rows and builds on them, joining the CTE to itself.*

---

**Q9.** A recursive CTE has no depth guard. The data contains a cycle (employee A reports to B, B reports to A). What happens?

- A) The database detects the cycle and stops automatically
- B) The CTE returns only the cyclic rows
- C) The recursion runs until the database's maximum recursion depth is reached, then raises an error
- D) The CTE silently returns zero rows

**Answer: C**
*Without a depth guard, the recursion hits the platform's maximum (100 by default in SQL Server; controlled by `cte_max_recursion_depth` in MySQL) and raises an error.*

---

**Q10.** Which of the following is a valid use of a CTE to filter window function results?

- A) `WHERE ROW_NUMBER() OVER (…) = 1` in the main SELECT
- B) Wrap the window function query in a CTE, then filter with `WHERE rn = 1` in the outer SELECT
- C) Use `HAVING ROW_NUMBER() OVER (…) = 1`
- D) Window functions do not need filtering

**Answer: B**
*Window functions cannot appear in WHERE or HAVING. The standard pattern is to wrap the window query in a CTE (or subquery), then filter in the outer query.*

---

**Q11.** How many CTEs can you define in a single `WITH` block?

- A) One only
- B) Two maximum
- C) As many as needed; separate them with commas
- D) As many as needed; each uses its own `WITH` keyword

**Answer: C**
*A single WITH block can contain any number of CTEs, each separated by a comma. Later CTEs can reference CTEs defined earlier in the same block.*

---

**Q12.** What is the difference between `UNION` and `UNION ALL` in a recursive CTE's recursive member?

- A) `UNION ALL` is required by standard SQL; `UNION` is not allowed in CTEs
- B) `UNION` removes duplicates at every recursion step, which can terminate otherwise-infinite loops; `UNION ALL` keeps all rows and is usually required for correct hierarchy traversal
- C) `UNION ALL` runs faster only on PostgreSQL; SQL Server requires `UNION`
- D) They are identical inside a WITH block

**Answer: B**
*`UNION ALL` preserves all rows, which is usually necessary for hierarchical data. `UNION` deduplicates at each step, can suppress valid paths, and is slower. Most recursive CTEs use `UNION ALL`.*

---

**Q13.** You have an index on `(department_id, gpa, last_name)`. Which query will NOT be able to use this index efficiently?

- A) `WHERE department_id = 2 AND gpa > 3.5`
- B) `WHERE department_id = 2`
- C) `WHERE gpa > 3.5`
- D) `WHERE department_id = 2 AND gpa > 3.5 AND last_name = 'Chen'`

**Answer: C**
*The leftmost prefix rule requires the query to include the leading column(s). A filter only on `gpa` skips `department_id`, so the index cannot be used for a range scan.*

---

**Q14.** In SQL Server 2022, what is the purpose of `OPTION (MAXRECURSION 50)` at the end of a recursive CTE query?

- A) Limits the number of rows returned to 50
- B) Sets the maximum number of recursive iterations to 50 for that query
- C) Sets the depth counter column to increment by 50
- D) Causes the query to automatically add a depth = 50 WHERE clause

**Answer: B**
*`OPTION (MAXRECURSION n)` is a query hint specific to SQL Server that overrides the default maximum recursion depth (100) for that individual query.*

---

**Q15.** A derived table (subquery in FROM) and a CTE both produce the same result. What is one practical advantage of using a CTE over an inline derived table?

- A) CTEs always execute faster than derived tables
- B) CTEs are materialized by default in all databases
- C) A CTE can be referenced multiple times in the same query without repeating the subquery logic
- D) CTEs bypass query planner optimization

**Answer: C**
*The key advantage of a CTE over a derived table is reusability — define the query once and reference it by name as many times as needed in the same statement. This is impossible with an inline derived table.*
