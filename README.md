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




Through this project, the following practical skills were reinforced:
- Designing a normalized relational schema with correct primary/foreign key constraints.
- Writing joins that correctly answer "who/what is missing" questions (`LEFT JOIN ... IS NULL`, `NOT EXISTS`).
- Using window functions to solve ranking and running-total problems without complex self-joins.
- Structuring multi-step analysis cleanly with CTEs instead of deeply nested subqueries.
- Building views to make recurring business questions reusable and BI-tool friendly.
- Reasoning about index selection and validating it with `EXPLAIN`.
- Translating vague stakeholder asks ("who are our best customers?") into precise, correct SQL.

## 8. Suggested Screenshots for Submission

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

## 9. Project Structure

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

**Author:** Aiman zuha — Task 3 Internship Submission
**Database engine:** MySQL 8.0.46
