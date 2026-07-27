# Task 3: SQL for Data Analysis — Ecommerce Analytics

A complete, GitHub-ready SQL project built around a realistic **Ecommerce database**, demonstrating the full spectrum of SQL skills used in real-world data analysis: schema design, data modeling, joins, subqueries, window functions, CTEs, views, and query optimization — all executed and verified on **MySQL 8.0**.

---

## 1. Project Overview

This project simulates the backend database of an online retail store ("ecommerce_analytics") and answers realistic business questions that a Data Analyst / BI team would be asked to solve — top customers, best-selling products, monthly revenue trends, customer lifetime value, and more.

The database was built from scratch, populated with **38 customers, 61 products, 130 orders, 336 order line items and 125 payments**, and every single query in this repository has been executed end-to-end against a live MySQL 8.0 instance to confirm it runs without errors and returns correct results.

## 2. Objective

- Design a normalized, relational Ecommerce schema with proper keys and constraints.
- Populate it with realistic, internally-consistent sample data.
- Write production-quality SQL covering every major concept tested in SQL interviews and real analyst workflows (joins, subqueries, window functions, CTEs, views, indexing).
- Answer 15 practical business questions that mirror real stakeholder requests.
- Document everything so the project can be run, reviewed, and submitted with zero extra setup.

## 3. Database Schema

**Database name:** `ecommerce_analytics`

| Table | Purpose | Key Columns |
|---|---|---|
| `categories` | Product category lookup | `category_id` (PK) |
| `products` | Product catalog | `product_id` (PK), `category_id` (FK → categories) |
| `customers` | Customer master data | `customer_id` (PK) |
| `orders` | Order header | `order_id` (PK), `customer_id` (FK → customers) |
| `order_items` | Order line items (bridge table) | `order_item_id` (PK), `order_id` (FK → orders), `product_id` (FK → products) |
| `payments` | One payment per order (optional table) | `payment_id` (PK), `order_id` (FK, UNIQUE → orders) |

**Relationships**
- `categories (1) —— (N) products`
- `customers (1) —— (N) orders`
- `orders (1) —— (N) order_items`
- `products (1) —— (N) order_items`
- `orders (1) —— (1) payments`

See **`schema.png`** for the full Entity Relationship Diagram.

`order_items.total_price` is a **generated column** (`quantity * unit_price`), which mirrors how many real OLTP systems denormalize line totals for reporting speed while keeping the source values intact.

### Data volume
| Table | Row count |
|---|---|
| categories | 8 |
| customers | 38 (3 intentionally have zero orders) |
| products | 61 (2 intentionally never ordered) |
| orders | 130 |
| order_items | 336 |
| payments | 125 |

## 4. Tools Used

- **MySQL 8.0** (Community Server) — database engine
- **MySQL Workbench** — recommended GUI client for running scripts & taking screenshots
- **Graphviz** — used to generate the ER diagram (`schema.png`)
- Plain SQL only — no ORMs, no external frameworks

## 5. SQL Concepts Covered

| Category | Concepts |
|---|---|
| Core querying | `SELECT`, `WHERE`, `ORDER BY`, `DISTINCT`, `LIMIT` |
| Aggregation | `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` |
| Joins | `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, multi-table joins |
| Subqueries | Scalar subqueries, correlated subqueries, `EXISTS` / `NOT EXISTS` |
| Set operators | `IN`, `NOT IN`, `ANY`, `ALL`, `UNION`, `UNION ALL` |
| Conditional logic | `CASE WHEN ... THEN ... ELSE ... END` |
| Date & string functions | `DATEDIFF`, `DATE_FORMAT`, `YEAR`, `MONTHNAME`, `CONCAT`, `UPPER`, `LOWER`, `SUBSTRING`, `LOCATE`, `LENGTH` |
| Window functions | `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, running totals with `SUM() OVER()` |
| CTEs | Single and chained `WITH` clauses |
| Views | `CREATE OR REPLACE VIEW` |
| Optimization | `CREATE INDEX`, `EXPLAIN` |

## 6. How to Run

### Prerequisites
- MySQL 8.0+ installed locally, or MySQL Workbench connected to a MySQL 8.0 server.

### Steps
1. Clone this repository.
2. Open **MySQL Workbench** and connect to your local MySQL server.
3. Open `ecommerce_database.sql` and execute the entire script (⚡ Execute / `Ctrl+Shift+Enter`).
   This will:
   - Drop and recreate the `ecommerce_analytics` database
   - Create all 6 tables with primary keys, foreign keys and constraints
   - Create supporting indexes
   - Load all sample data (customers, products, orders, order items, payments)
4. Open `analysis_queries.sql` and run it (in full, or section by section using the numbered comment headers).
   This will:
   - Run every concept-demonstration query (Sections 1–8)
   - Answer all 15 business questions (Section 9)
   - Create the 3 views: `CustomerSales`, `ProductPerformance`, `MonthlyRevenue` (Section 10)
   - Show `EXPLAIN` output proving the indexes are used (Section 11)

Alternatively, from a terminal:
```bash
mysql -u root -p < ecommerce_database.sql
mysql -u root -p ecommerce_analytics < analysis_queries.sql
```

## 7. Sample Outputs

Full result sets for every business question are saved as `.txt` files inside **`output_samples/`**, captured directly from a live run against MySQL 8.0. A few highlights:

**Top 5 Customers by Revenue**

| customer_name | total_revenue |
|---|---|
| Kiara Desai | 280,204.42 |
| Diya Malhotra | 266,359.78 |
| Dhruv Mishra | 263,535.73 |
| Sara Prasad | 236,517.52 |
| Arjun Reddy | 235,077.82 |

**Revenue by Category**

| category_name | category_revenue |
|---|---|
| Electronics | 2,262,874.71 |
| Home & Kitchen | 532,211.26 |
| Fashion | 194,246.09 |
| Sports | 90,826.49 |

**Average Order Value:** ₹25,519.20

**Products Never Ordered:** `Premium Espresso Machine`, `Studio Monitor Speakers`

**Customers Without Orders:** Nikhil Das, Priya Nambiar, Farhan Ali

See `output_samples/` for the complete set (monthly sales report, best-sellers, lowest-sellers, customer lifetime value, repeat customers, view outputs, etc.).

## 8. Interview Questions — Answered

**Q1. Difference between `WHERE` and `HAVING`?**
`WHERE` filters individual rows *before* any grouping or aggregation happens — it cannot reference an aggregate function like `SUM()` or `COUNT()`. `HAVING` filters *groups* — it runs after `GROUP BY` has produced aggregated rows, so it can filter on aggregate results (e.g. `HAVING SUM(total_price) > 100000`). A simple rule of thumb: `WHERE` acts on raw table rows, `HAVING` acts on the summarized/grouped output.

**Q2. Types of JOINs?**
- `INNER JOIN` — returns only rows that have a match in both tables.
- `LEFT JOIN` (LEFT OUTER JOIN) — returns all rows from the left table, plus matching rows from the right table (`NULL` where there's no match).
- `RIGHT JOIN` (RIGHT OUTER JOIN) — mirror of LEFT JOIN; returns all rows from the right table. MySQL 8.0 supports this natively.
- `FULL OUTER JOIN` — not natively supported in MySQL; emulated with `LEFT JOIN UNION RIGHT JOIN`.
- `CROSS JOIN` — Cartesian product of both tables (every row combined with every row).
- `SELF JOIN` — a table joined to itself, useful for hierarchical/comparative data.

**Q3. What are Subqueries?**
A subquery is a query nested inside another query, used wherever a single value, a list of values, or a derived table is needed. A **scalar subquery** returns a single value (e.g. `WHERE price > (SELECT AVG(price) FROM products)`). A **correlated subquery** references a column from the outer query, so it re-executes once per outer row (e.g. computing each customer's own total spend). Subqueries can appear in `SELECT`, `WHERE`, `FROM` (as a derived table), or `HAVING`.

**Q4. How to calculate Average Revenue Per User (ARPU)?**
ARPU = Total Revenue ÷ Number of Active Users (customers), typically over a defined time period (e.g. monthly ARPU). In this schema:
```sql
SELECT SUM(oi.total_price) / COUNT(DISTINCT o.customer_id) AS arpu
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled';
```
For a per-month ARPU, add `GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')`. It's important to decide whether the denominator should be *all registered customers* or only *customers active in that period* — the two give very different numbers and should be labelled clearly in any report.

**Q5. What is a View?**
A view is a stored, named `SELECT` statement that behaves like a virtual table — it has no data of its own and is recomputed from the underlying tables every time it's queried. Views are used to: simplify repeated complex joins, present a restricted/curated set of columns to certain users (security), and give business users a stable, friendly name (`CustomerSales`) to query instead of writing raw JOINs each time.

**Q6. How to optimize SQL queries?**
- Add indexes on columns used in `JOIN` conditions, `WHERE` filters, and `ORDER BY` clauses (see Section 11 of `analysis_queries.sql`).
- Avoid `SELECT *` — only fetch the columns you actually need.
- Use `EXPLAIN` to check whether the optimizer is doing a full table scan vs. an index seek.
- Filter as early as possible (push `WHERE` conditions before joins where logically valid).
- Avoid functions on indexed columns in `WHERE` clauses (e.g. `WHERE YEAR(order_date) = 2024` prevents index use; prefer `WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'`).
- Use `LIMIT` when only a subset of rows is needed.
- For very large aggregations, consider covering indexes or pre-aggregated summary tables.

**Q7. How to handle NULL values?**
- Use `IS NULL` / `IS NOT NULL` for comparisons — never `= NULL`, which always evaluates to unknown.
- Use `COALESCE(column, default_value)` to substitute a default when a value is `NULL` (used throughout this project, e.g. `COALESCE(SUM(oi.total_price),0)` so customers with zero orders show `0` instead of `NULL`).
- Use `NULLIF(a, b)` to convert a specific value into `NULL` (useful to avoid divide-by-zero, e.g. `NULLIF(total_orders,0)`).
- Remember aggregate functions (`SUM`, `AVG`, `COUNT(column)`) automatically ignore `NULL` values, while `COUNT(*)` counts all rows regardless.
- Decide deliberately whether `NULL` should mean "zero/none" (usually needs `COALESCE`) or "genuinely unknown" (should stay `NULL` and be flagged, not defaulted).

## 9. Learning Outcomes

Through this project, the following practical skills were reinforced:
- Designing a normalized relational schema with correct primary/foreign key constraints.
- Writing joins that correctly answer "who/what is missing" questions (`LEFT JOIN ... IS NULL`, `NOT EXISTS`).
- Using window functions to solve ranking and running-total problems without complex self-joins.
- Structuring multi-step analysis cleanly with CTEs instead of deeply nested subqueries.
- Building views to make recurring business questions reusable and BI-tool friendly.
- Reasoning about index selection and validating it with `EXPLAIN`.
- Translating vague stakeholder asks ("who are our best customers?") into precise, correct SQL.

## 10. Suggested Screenshots for Submission

Capture these in MySQL Workbench and place them in `screenshots/`:
1. `01_database_creation.png` — Result of running `ecommerce_database.sql` (Output/Action log showing success, no errors).
2. `02_schema_tables.png` — Left-hand Schemas panel expanded showing all 6 tables under `ecommerce_analytics`.
3. `03_row_counts.png` — Output of the sanity-check `SELECT COUNT(*)` queries (Section D of `ecommerce_database.sql`).
4. `04_top10_customers.png` — Result grid of the "Top 10 Customers by Revenue" query.
5. `05_monthly_sales_report.png` — Result grid of the Monthly Sales Report query.
6. `06_window_functions.png` — Result grid of the `RANK()` / `DENSE_RANK()` query.
7. `07_cte_clv.png` — Result grid of the Customer Lifetime Value CTE query.
8. `08_views_list.png` — Schemas panel → Views, showing `CustomerSales`, `ProductPerformance`, `MonthlyRevenue`.
9. `09_explain_index.png` — Output of an `EXPLAIN` statement showing the index being used (`key` column populated, not `NULL`).
10. `10_er_diagram.png` — The `schema.png` ER diagram itself (or a screenshot of Workbench's own reverse-engineered EER diagram, if generated).

## 11. Project Structure

```
Task3_SQL_Data_Analysis/
│
├── ecommerce_database.sql      # Database + table creation, constraints, indexes, and all sample data
├── analysis_queries.sql        # Full analysis query suite (concepts + business questions + views)
├── README.md                   # This file
├── schema.png                  # Entity Relationship Diagram
├── screenshots/                # Place your MySQL Workbench screenshots here for submission
└── output_samples/              # Captured .txt outputs of key queries, for quick review without re-running SQL
```

---

**Author:** Data Analyst / SQL Developer — Task 3 Internship Submission
**Database engine:** MySQL 8.0.46
