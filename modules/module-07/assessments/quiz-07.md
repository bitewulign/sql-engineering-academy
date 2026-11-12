# Module 07 — Quiz
## Window Functions

**Instructions:** Choose the single best answer for each question. Pass mark: 11 / 15.

---

**Q1.** What does `ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY gpa DESC)` return for two students in the same department with the same GPA?

A) Both receive the same number  
B) Both receive number 1  
C) They receive consecutive numbers (e.g., 1 and 2) in arbitrary order  
D) The query raises an error  

---

**Q2.** For input values `[3.90, 3.85, 3.85, 3.80]`, what does `RANK() OVER (ORDER BY gpa DESC)` produce?

A) 1, 2, 3, 4  
B) 1, 2, 2, 3  
C) 1, 2, 2, 4  
D) 1, 1, 1, 4  

---

**Q3.** For the same input, what does `DENSE_RANK() OVER (ORDER BY gpa DESC)` produce?

A) 1, 2, 2, 4  
B) 1, 2, 3, 4  
C) 1, 2, 2, 3  
D) 1, 1, 1, 2  

---

**Q4.** Why can a window function not appear directly in a `WHERE` clause?

A) Window functions only work with `HAVING`  
B) Window functions execute in the SELECT phase, after WHERE is evaluated  
C) Window functions return NULL in WHERE conditions  
D) It is a platform-specific restriction in MySQL only  

---

**Q5.** What is the correct way to find the top-ranked student per department using window functions?

A) `WHERE RANK() OVER (...) = 1`  
B) `HAVING RANK() OVER (...) = 1`  
C) Wrap the ranked query in a CTE or subquery, then filter `WHERE rnk = 1`  
D) Use a correlated subquery instead — window functions cannot do top-per-group  

---

**Q6.** The default window frame when `ORDER BY` is specified is:

A) `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`  
B) `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING`  
C) `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`  
D) `ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING`  

---

**Q7.** Which SQL correctly computes a 3-row moving average?

A) `AVG(gpa) OVER (ORDER BY enrolled_at ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)`  
B) `AVG(gpa) OVER (ORDER BY enrolled_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`  
C) `AVG(gpa) OVER (ORDER BY enrolled_at RANGE BETWEEN 3 PRECEDING AND CURRENT ROW)`  
D) `AVG(gpa) OVER (PARTITION BY 3 ORDER BY enrolled_at)`  

---

**Q8.** What is the LAST_VALUE bug?

A) LAST_VALUE always returns NULL  
B) LAST_VALUE returns the wrong value when ORDER BY is omitted  
C) Without an explicit full-partition frame, LAST_VALUE defaults to `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`, making it always equal to the current row  
D) LAST_VALUE is not supported in MySQL  

---

**Q9.** How do you fix the LAST_VALUE bug?

A) Use `FIRST_VALUE` with `ORDER BY DESC` instead  
B) Add `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` to the OVER clause  
C) Use a subquery and MAX() instead  
D) Add `NULLS LAST` to the ORDER BY  

---

**Q10.** `NTILE(4) OVER (ORDER BY gpa DESC)` assigns value `1` to which students?

A) The bottom 25% by GPA  
B) The top 25% by GPA  
C) Students at exactly the 25th percentile  
D) Students with GPA > 3.0  

---

**Q11.** Which platforms support the named `WINDOW` clause (`WINDOW w AS (…)`)?

A) All three: MySQL 8.0, PostgreSQL 16, SQL Server 2022  
B) MySQL 8.0 and PostgreSQL 16 only  
C) PostgreSQL 16 and SQL Server 2022 only  
D) SQL Server 2022 only  

---

**Q12.** What is the difference between `ROWS BETWEEN` and `RANGE BETWEEN` in a window frame?

A) `ROWS` includes tied values; `RANGE` counts physical rows  
B) `ROWS` counts physical rows precisely; `RANGE` groups rows with the same ORDER BY value  
C) They are identical — the terms are interchangeable  
D) `RANGE` is only available in PostgreSQL  

---

**Q13.** `LAG(gpa, 1, 0.0) OVER (ORDER BY enrolled_at)` — what value is returned for the very first row?

A) NULL  
B) The GPA of the second row  
C) 0.0 (the default argument)  
D) The GPA of the last row  

---

**Q14.** In PostgreSQL, `ROUND(AVG(gpa) OVER (PARTITION BY department_id), 2)` raises an error. What is the fix?

A) Use `TRUNC()` instead of `ROUND()`  
B) Cast to NUMERIC: `ROUND(AVG(gpa) OVER (PARTITION BY department_id)::NUMERIC, 2)`  
C) PostgreSQL does not support aggregate window functions  
D) Add `CAST(gpa AS FLOAT)` before AVG  

---

**Q15.** Which statement about `PERCENT_RANK()` is correct?

A) `PERCENT_RANK()` always returns a value between 0 and 100  
B) The first row (lowest rank) always gets `PERCENT_RANK() = 1.0`  
C) `PERCENT_RANK()` = (rank − 1) / (total rows − 1); the first row gets 0.0  
D) `PERCENT_RANK()` is equivalent to `CUME_DIST()`  

---

## Answer Key (Instructor Use Only)

| Q | Answer | Topic |
|---|--------|-------|
| 1 | C | ROW_NUMBER — ties |
| 2 | C | RANK — gaps |
| 3 | C | DENSE_RANK — no gaps |
| 4 | B | Window execution phase |
| 5 | C | Top-per-group pattern |
| 6 | C | Default frame |
| 7 | B | Moving average frame |
| 8 | C | LAST_VALUE bug |
| 9 | B | LAST_VALUE fix |
| 10 | B | NTILE — bucket 1 |
| 11 | B | Named WINDOW clause support |
| 12 | B | ROWS vs RANGE |
| 13 | C | LAG default argument |
| 14 | B | PostgreSQL ROUND cast |
| 15 | C | PERCENT_RANK formula |

Pass = 11 / 15
