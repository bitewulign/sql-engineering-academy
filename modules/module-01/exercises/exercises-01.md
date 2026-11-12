# Module 01 — Exercises
## Database Foundations and Introduction to SQL

Complete all exercises in **all three systems** unless otherwise noted.  
Write your answers as SQL files and commit them to your repository.

---

## Beginner Exercises (Exercises 1–10)

**Exercise 1 — Version check**  
Write a single query that returns the version of the database system you are using.  
Run it on SQL Server, PostgreSQL, and MySQL. Record the version of each.

---

**Exercise 2 — Current date and time**  
Write a query that returns three columns:
- `current_date_only` — today's date, without the time
- `current_time_only` — the current time, without the date
- `current_full_timestamp` — the full datetime with both date and time

Write a separate version for each of the three database systems.

---

**Exercise 3 — String output**  
Write a SELECT that returns exactly this output (as a single value):

```
SQL is the language of data.
```

---

**Exercise 4 — Arithmetic**  
Write a single SELECT query that calculates and labels all of the following in one result set:
- 7 multiplied by 8
- 500 divided by 4
- The remainder when 47 is divided by 5
- 12.5 multiplied by 3.14159, rounded to 2 decimal places

---

**Exercise 5 — Tip calculator**  
A restaurant bill is $134.75. Write a query that returns:
- The original bill amount
- An 18% tip amount (rounded to 2 decimal places)
- A 20% tip amount (rounded to 2 decimal places)
- The total with an 18% tip
- The total with a 20% tip

---

**Exercise 6 — String concatenation**  
Write a query that constructs a full name from parts. The result should be:

```
Last name: Smith, First name: Jane
```

Write it using the concatenation method native to each platform:
- SQL Server: use `+`
- PostgreSQL: use `||`
- MySQL: use `CONCAT()`

Then write a version using `CONCAT()` that works on all three.

---

**Exercise 7 — NULL behavior**  
Predict the result of each of the following expressions **without running them first**. Write down your prediction, then run them and compare.

a) `SELECT NULL + 10;`  
b) `SELECT NULL = NULL;`  
c) `SELECT NULL IS NULL;`  
d) `SELECT COALESCE(NULL, NULL, 42);`  
e) `SELECT CONCAT('Hello', NULL, '!');` *(check if behavior differs between MySQL and PostgreSQL)*

---

**Exercise 8 — Coalesce practice**  
Write a query that returns the first non-NULL value from this sequence:
- `NULL`, `NULL`, `'Toronto'`, `'Canada'`

Then write a query using NULLIF that returns NULL when the input is 0, and the input itself otherwise. Test it with the values 0 and 25.

---

**Exercise 9 — Days elapsed**  
Write a query that calculates the number of days between January 1, 1970 (the Unix epoch) and today.

Write it once for each database system using that system's native date arithmetic.

---

**Exercise 10 — System catalog query**  
Using the `INFORMATION_SCHEMA.TABLES` view (available on all three systems), write a query that returns the names of all tables in your sample database, sorted alphabetically.

If you have not yet installed a sample database, use:
- SQL Server: the `master` system database
- PostgreSQL: `pg_catalog`
- MySQL: `information_schema`

---

## Intermediate Exercises (Exercises 11–15)

**Exercise 11 — Pagination**  
Create a temporary table containing the integers 1 through 20.  
Write three queries:
- Page 1: rows 1–5
- Page 2: rows 6–10
- Page 3: rows 11–15

Write each using the pagination method for that system (TOP/OFFSET-FETCH for SQL Server, LIMIT/OFFSET for PostgreSQL and MySQL).

---

**Exercise 12 — Type casting**  
Write a query that:
1. Converts the string `'3.14159'` to a numeric value
2. Converts the integer `2026` to a character string
3. Converts the string `'2026-11-11'` to a date value

Use `CAST()` (ANSI standard) for all three. Then note which system(s) also support the `::` shorthand.

---

**Exercise 13 — Date components**  
Write a single SELECT that returns the following for today's date:
- Year as a number
- Month as a number (1–12)
- Day as a number (1–31)
- Name of the day of the week (e.g., Wednesday)
- Number of the day of the week (using whatever convention the platform uses)

---

**Exercise 14 — Future dates**  
Write a query that returns:
- Today's date
- 90 days from today
- 6 months from today
- The first day of the current month
- The last day of the current month

---

**Exercise 15 — Cross-platform comparison**  
Fill in this comparison table by running the queries and observing the results:

| Test | SQL Server result | PostgreSQL result | MySQL result |
|------|------------------|------------------|-------------|
| `SELECT 1 / 2` | ? | ? | ? |
| `SELECT 1.0 / 2` | ? | ? | ? |
| `SELECT 'A' = 'a'` | ? | ? | ? |
| `SELECT NULL + 0` | ? | ? | ? |
| `SELECT CONCAT('x', NULL)` | ? | ? | ? |

Write down your observations. Which results surprised you?

---

## Advanced Challenges (Challenges 16–18)

**Challenge 16 — The NULL experiment**  
Run the following query on all three systems and explain **why** each result is what it is:

```sql
SELECT
    1 = 1          AS one_eq_one,
    1 = 2          AS one_eq_two,
    NULL = 1       AS null_eq_one,
    NULL = NULL    AS null_eq_null,
    NULL != NULL   AS null_neq_null,
    NULL IS NULL   AS null_is_null,
    NOT (NULL = 1) AS not_null_eq_one;
```

Write a paragraph explaining the three-valued logic (TRUE, FALSE, UNKNOWN) of SQL.

---

**Challenge 17 — 1,000-row series**  
Using only a SELECT statement (no INSERT, no loop, no programming):
- SQL Server: generate integers 1 through 1,000
- PostgreSQL: generate integers 1 through 1,000
- MySQL: generate integers 1 through 1,000

Hint: each platform has a different way to generate sequences from pure SQL.  
*(SQL Server: recursive CTE or sys.objects cross join; PostgreSQL: generate_series(); MySQL: recursive CTE in 8.0)*

---

**Challenge 18 — System introspection**  
Write queries against the system catalogs to answer:
1. How many total tables exist in the sample database?
2. What is the name of the table with the most columns?
3. How many tables have the word "order" in their name (case-insensitive)?

Write versions for all three systems.

---

## Interview Questions (for self-assessment)

After completing the exercises, answer these without looking at your notes:

1. What is the difference between a DBMS and an RDBMS?
2. What does NULL mean? Is `NULL = NULL` true?
3. What are the four categories of SQL commands?
4. What is the difference between `SELECT TOP 10` and `SELECT ... LIMIT 10`?
5. Why should you always specify an `ORDER BY` clause when using `TOP` or `LIMIT`?
6. What is T-SQL? What is PL/pgSQL? How do they relate to SQL?
7. Name three syntactic differences between SQL Server, PostgreSQL, and MySQL.
8. What is a primary key? What two rules must it follow?
9. What is a foreign key? What problem does it prevent?
10. What is `@@VERSION` in SQL Server, and what are the equivalent commands in PostgreSQL and MySQL?

---

## Submission Checklist

- [ ] All 10 beginner exercises completed and tested
- [ ] All 5 intermediate exercises completed and tested
- [ ] At least 1 advanced challenge completed
- [ ] Every SQL file has a header comment identifying the engine and version
- [ ] Queries tested on all three systems
- [ ] Files committed to your GitHub repository

**When you have checked all boxes: proceed to the Module 01 Quiz.**
