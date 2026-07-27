-- =====================================================================================
-- TASK 3: SQL FOR DATA ANALYSIS
-- File        : analysis_queries.sql
-- Purpose     : Full suite of data-analysis queries on top of ecommerce_analytics DB.
--               Demonstrates every core SQL concept + answers real business questions.
-- RDBMS       : MySQL 8.0
-- Pre-req     : Run ecommerce_database.sql first to create & populate the database.
-- How to run  : Open in MySQL Workbench, USE ecommerce_analytics; then run section
--               by section, or run the whole file at once.
-- =====================================================================================

USE ecommerce_analytics;


-- #####################################################################################
-- SECTION 1: BASIC SELECT / FILTERING / SORTING
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q1.1 | Purpose: List all customer names & cities
-- Concept: SELECT, basic column projection
-- Expected output: 38 rows (customer_id, first_name, last_name, city)
-- ---------------------------------------------------------------------------------
SELECT customer_id, first_name, last_name, city
FROM customers;

-- ---------------------------------------------------------------------------------
-- Q1.2 | Purpose: Find all customers located in Delhi
-- Concept: WHERE (equality filter)
-- Expected output: All customers whose city = 'Delhi'
-- ---------------------------------------------------------------------------------
SELECT customer_id, first_name, last_name, city, customer_segment
FROM customers
WHERE city = 'Delhi';

-- ---------------------------------------------------------------------------------
-- Q1.3 | Purpose: List all products priced between 1000 and 5000, most expensive first
-- Concept: WHERE (BETWEEN) + ORDER BY DESC
-- Expected output: Products sorted from highest to lowest price within the range
-- ---------------------------------------------------------------------------------
SELECT product_id, product_name, price
FROM products
WHERE price BETWEEN 1000 AND 5000
ORDER BY price DESC;

-- ---------------------------------------------------------------------------------
-- Q1.4 | Purpose: Find the distinct list of cities customers are shipping orders to
-- Concept: DISTINCT
-- Expected output: Unique list of shipping cities used across all orders
-- ---------------------------------------------------------------------------------
SELECT DISTINCT shipping_city
FROM orders
ORDER BY shipping_city;

-- ---------------------------------------------------------------------------------
-- Q1.5 | Purpose: Show the 10 most recently placed orders
-- Concept: ORDER BY + LIMIT
-- Expected output: 10 rows, most recent order_date first
-- ---------------------------------------------------------------------------------
SELECT order_id, customer_id, order_date, order_status
FROM orders
ORDER BY order_date DESC
LIMIT 10;


-- #####################################################################################
-- SECTION 2: AGGREGATE FUNCTIONS, GROUP BY & HAVING
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q2.1 | Purpose: Overall catalog statistics (count of products, average/min/max price)
-- Concept: Aggregate Functions - COUNT, AVG, MIN, MAX, SUM
-- Expected output: Single summary row
-- ---------------------------------------------------------------------------------
SELECT
    COUNT(*)          AS total_products,
    ROUND(AVG(price),2) AS avg_price,
    MIN(price)        AS cheapest_price,
    MAX(price)        AS costliest_price,
    SUM(stock_quantity) AS total_units_in_stock
FROM products;

-- ---------------------------------------------------------------------------------
-- Q2.2 | Purpose: Count of products per category
-- Concept: GROUP BY + COUNT + JOIN
-- Expected output: One row per category with product count
-- ---------------------------------------------------------------------------------
SELECT c.category_name, COUNT(p.product_id) AS product_count
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY product_count DESC;

-- ---------------------------------------------------------------------------------
-- Q2.3 | Purpose: Categories that generate more than ₹1,00,000 in total revenue
-- Concept: GROUP BY + HAVING (filter on aggregated result, unlike WHERE)
-- Expected output: Only high-revenue categories (> 100000)
-- ---------------------------------------------------------------------------------
SELECT cat.category_name,
       SUM(oi.total_price) AS category_revenue
FROM order_items oi
JOIN products p   ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY cat.category_name
HAVING SUM(oi.total_price) > 100000
ORDER BY category_revenue DESC;


-- #####################################################################################
-- SECTION 3: JOINS
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q3.1 | Purpose: List every order along with the customer who placed it
-- Concept: INNER JOIN (returns only matching rows on both sides)
-- Expected output: 130 rows - one per order, with customer name attached
-- ---------------------------------------------------------------------------------
SELECT o.order_id, o.order_date, o.order_status,
       c.first_name, c.last_name, c.city
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- ---------------------------------------------------------------------------------
-- Q3.2 | Purpose: List ALL customers and their orders, including customers with
--                 zero orders (to see who has never purchased anything)
-- Concept: LEFT JOIN (keeps every row from the left/customers table)
-- Expected output: 38+ rows; customers with no orders show NULL order columns
-- ---------------------------------------------------------------------------------
SELECT c.customer_id, c.first_name, c.last_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id;

-- ---------------------------------------------------------------------------------
-- Q3.3 | Purpose: List ALL products and any orders that included them, including
--                 products that were never ordered
-- Concept: RIGHT JOIN
-- Note: MySQL 8.0 DOES support RIGHT JOIN natively (unlike, say, some NoSQL engines).
--       A RIGHT JOIN products/order_items is written below; it is logically identical
--       to "SELECT ... FROM order_items RIGHT JOIN products" -- i.e. keep every row
--       from the right-hand table (products), and bring in matching order_items rows
--       or NULLs when there is no match.
-- Expected output: Every product appears at least once; unordered products show NULL
--                  order_item columns.
-- ---------------------------------------------------------------------------------
SELECT p.product_id, p.product_name, oi.order_id, oi.quantity
FROM order_items oi
RIGHT JOIN products p ON p.product_id = oi.product_id
ORDER BY p.product_id;

-- ---------------------------------------------------------------------------------
-- Q3.4 | Purpose: Full order detail report - customer, order, product & category
--                 in one row per line item
-- Concept: Multiple Table JOIN (4 tables joined together)
-- Expected output: 336 rows (one per order_item), fully denormalised report
-- ---------------------------------------------------------------------------------
SELECT
    o.order_id,
    c.first_name, c.last_name,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.total_price,
    o.order_date
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p    ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
ORDER BY o.order_id;


-- #####################################################################################
-- SECTION 4: SUBQUERIES, CORRELATED SUBQUERIES, EXISTS, IN, ANY/ALL
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q4.1 | Purpose: Find products priced above the overall average product price
-- Concept: Subquery in WHERE clause (non-correlated - inner query runs once)
-- Expected output: Products more expensive than the catalog average
-- ---------------------------------------------------------------------------------
SELECT product_id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- ---------------------------------------------------------------------------------
-- Q4.2 | Purpose: For every customer, show their own total spend next to the
--                 company-wide average customer spend
-- Concept: Correlated Subquery (inner query references the outer query's row)
-- Expected output: One row per customer with total_spend, re-evaluated per row
-- ---------------------------------------------------------------------------------
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    (SELECT COALESCE(SUM(oi.total_price),0)
       FROM orders o
       JOIN order_items oi ON oi.order_id = o.order_id
      WHERE o.customer_id = c.customer_id
        AND o.order_status <> 'Cancelled') AS total_spend
FROM customers c
ORDER BY total_spend DESC;

-- ---------------------------------------------------------------------------------
-- Q4.3 | Purpose: Products that have NEVER been ordered
-- Concept: Correlated Subquery + NOT EXISTS
-- Expected output: The 2 seeded "never ordered" products
-- ---------------------------------------------------------------------------------
SELECT p.product_id, p.product_name, p.price
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id
);

-- ---------------------------------------------------------------------------------
-- Q4.4 | Purpose: Customers who have placed at least one 'Delivered' order
-- Concept: EXISTS (correlated) - stops scanning as soon as one match is found
-- Expected output: Customers with >=1 delivered order
-- ---------------------------------------------------------------------------------
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.customer_id AND o.order_status = 'Delivered'
);

-- ---------------------------------------------------------------------------------
-- Q4.5 | Purpose: Customers who have NEVER placed an order
-- Concept: NOT IN combined with a subquery
-- Expected output: The 3 seeded customers without any orders
-- ---------------------------------------------------------------------------------
SELECT customer_id, first_name, last_name, city
FROM customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);

-- ---------------------------------------------------------------------------------
-- Q4.6 | Purpose: Orders placed from any of the top-3-by-population metro cities
-- Concept: IN
-- Expected output: Orders shipped to Delhi, Mumbai or Bengaluru
-- ---------------------------------------------------------------------------------
SELECT order_id, shipping_city, order_date, order_status
FROM orders
WHERE shipping_city IN ('Delhi','Mumbai','Bengaluru');

-- ---------------------------------------------------------------------------------
-- Q4.7 | Purpose: Products that cost more than ANY (i.e. at least one) product
--                 in the 'Beauty' category - a very low bar
-- Concept: ANY
-- Expected output: Most products qualify, since ANY only needs to beat one row
-- ---------------------------------------------------------------------------------
SELECT product_id, product_name, price
FROM products
WHERE price > ANY (SELECT price FROM products WHERE category_id = 6)
ORDER BY price DESC;

-- ---------------------------------------------------------------------------------
-- Q4.8 | Purpose: Products that cost more than ALL products in the 'Beauty' category
-- Concept: ALL (must beat every row returned by the subquery - a much higher bar)
-- Expected output: Only products priced above the single most expensive Beauty item
-- ---------------------------------------------------------------------------------
SELECT product_id, product_name, price
FROM products
WHERE price > ALL (SELECT price FROM products WHERE category_id = 6)
ORDER BY price DESC;


-- #####################################################################################
-- SECTION 5: UNION / UNION ALL
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q5.1 | Purpose: Single combined watch-list of "high value customers" (VIP segment)
--                 and "high value products" (price > 50000) for a marketing campaign
-- Concept: UNION (removes duplicate rows across the two result sets)
-- Expected output: Combined, de-duplicated list tagged by record_type
-- ---------------------------------------------------------------------------------
SELECT 'Customer' AS record_type, CONCAT(first_name,' ',last_name) AS name, customer_segment AS detail
FROM customers WHERE customer_segment = 'VIP'
UNION
SELECT 'Product' AS record_type, product_name AS name, CONCAT('Price: ',price) AS detail
FROM products WHERE price > 50000;

-- ---------------------------------------------------------------------------------
-- Q5.2 | Purpose: Full audit trail of order status changes worth reviewing -
--                 all 'Cancelled' orders AND all 'Returned' orders, keeping duplicates
-- Concept: UNION ALL (keeps every row, no de-duplication - faster than UNION)
-- Expected output: Cancelled orders followed by returned orders (row count = sum of both)
-- ---------------------------------------------------------------------------------
SELECT order_id, customer_id, order_date, 'Cancelled Order' AS reason
FROM orders WHERE order_status = 'Cancelled'
UNION ALL
SELECT order_id, customer_id, order_date, 'Returned Order' AS reason
FROM orders WHERE order_status = 'Returned';


-- #####################################################################################
-- SECTION 6: CASE STATEMENTS, DATE FUNCTIONS, STRING FUNCTIONS
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q6.1 | Purpose: Tag each product into a price band for merchandising
-- Concept: CASE WHEN ... THEN ... ELSE ... END
-- Expected output: Every product labelled Budget / Mid-range / Premium / Luxury
-- ---------------------------------------------------------------------------------
SELECT product_name, price,
    CASE
        WHEN price < 1000  THEN 'Budget'
        WHEN price < 5000  THEN 'Mid-range'
        WHEN price < 20000 THEN 'Premium'
        ELSE 'Luxury'
    END AS price_band
FROM products
ORDER BY price DESC;

-- ---------------------------------------------------------------------------------
-- Q6.2 | Purpose: Show order age in days and flag orders older than 180 days as
--                 'Archive Candidate'
-- Concept: Date Functions - DATEDIFF, CURDATE()
-- Expected output: Every order with a computed age_in_days + status flag
-- ---------------------------------------------------------------------------------
SELECT order_id, order_date,
       DATEDIFF(CURDATE(), order_date) AS age_in_days,
       CASE WHEN DATEDIFF(CURDATE(), order_date) > 180
            THEN 'Archive Candidate' ELSE 'Recent' END AS archive_flag
FROM orders
ORDER BY age_in_days DESC;

-- ---------------------------------------------------------------------------------
-- Q6.3 | Purpose: Extract year and month name from order_date for reporting
-- Concept: Date Functions - YEAR(), MONTHNAME(), DATE_FORMAT()
-- Expected output: order_id with order_year, order_month_name, formatted_date
-- ---------------------------------------------------------------------------------
SELECT order_id, order_date,
       YEAR(order_date)  AS order_year,
       MONTHNAME(order_date) AS order_month_name,
       DATE_FORMAT(order_date, '%d-%b-%Y') AS formatted_date
FROM orders
ORDER BY order_date
LIMIT 15;

-- ---------------------------------------------------------------------------------
-- Q6.4 | Purpose: Build a clean display label combining customer name + masked email
-- Concept: String Functions - CONCAT, UPPER, LOWER, LEFT, LENGTH, SUBSTRING
-- Expected output: Formatted display_name and partially masked email per customer
-- ---------------------------------------------------------------------------------
SELECT
    customer_id,
    CONCAT(UPPER(LEFT(first_name,1)), LOWER(SUBSTRING(first_name,2)), ' ',
           UPPER(UPPER(LEFT(last_name,1))), LOWER(SUBSTRING(last_name,2))) AS display_name,
    CONCAT(LEFT(email, 3), '****', SUBSTRING(email, LOCATE('@', email))) AS masked_email,
    LENGTH(email) AS email_length
FROM customers;


-- #####################################################################################
-- SECTION 7: WINDOW FUNCTIONS (ROW_NUMBER, RANK, DENSE_RANK)
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q7.1 | Purpose: Rank products by price WITHIN each category
-- Concept: Window Function - ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)
-- Expected output: Every product with a row number that restarts at 1 per category
-- ---------------------------------------------------------------------------------
SELECT
    cat.category_name,
    p.product_name,
    p.price,
    ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY p.price DESC) AS price_rank_in_category
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
ORDER BY cat.category_name, price_rank_in_category;

-- ---------------------------------------------------------------------------------
-- Q7.2 | Purpose: Rank customers by total revenue generated (ties share the same rank,
--                 and the next rank is skipped - standard competition ranking)
-- Concept: Window Function - RANK() OVER (ORDER BY ...)
-- Expected output: Customers ranked 1,2,2,4... when ties occur
-- ---------------------------------------------------------------------------------
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(oi.total_price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.total_price) DESC) AS revenue_rank
FROM customers c
JOIN orders o     ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name;

-- ---------------------------------------------------------------------------------
-- Q7.3 | Purpose: Dense-rank products by total quantity sold (no gaps in ranking,
--                 unlike RANK())
-- Concept: Window Function - DENSE_RANK()
-- Expected output: Best-selling products ranked 1,2,2,3... (no skipped numbers)
-- ---------------------------------------------------------------------------------
SELECT
    p.product_name,
    SUM(oi.quantity) AS total_qty_sold,
    DENSE_RANK() OVER (ORDER BY SUM(oi.quantity) DESC) AS qty_dense_rank
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY qty_dense_rank;

-- ---------------------------------------------------------------------------------
-- Q7.4 | Purpose: Running (cumulative) monthly revenue total across the year
-- Concept: Window Function - SUM() OVER (ORDER BY ... ROWS/RANGE) i.e. running total
-- Expected output: Monthly revenue alongside a growing cumulative_revenue column
-- ---------------------------------------------------------------------------------
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(oi.total_price) AS monthly_revenue,
    SUM(SUM(oi.total_price)) OVER (ORDER BY DATE_FORMAT(o.order_date, '%Y-%m')) AS cumulative_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY order_month
ORDER BY order_month;


-- #####################################################################################
-- SECTION 8: COMMON TABLE EXPRESSIONS (CTE)
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q8.1 | Purpose: Identify "Repeat Customers" - those with more than 1 order
-- Concept: CTE (WITH clause) - makes multi-step logic readable
-- Expected output: List of customers with order_count > 1
-- ---------------------------------------------------------------------------------
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name, coc.order_count
FROM customer_order_counts coc
JOIN customers c ON c.customer_id = coc.customer_id
WHERE coc.order_count > 1
ORDER BY coc.order_count DESC;

-- ---------------------------------------------------------------------------------
-- Q8.2 | Purpose: Multi-step CTE chain to find each category's revenue share (%)
--                 of total company revenue
-- Concept: Multiple chained CTEs
-- Expected output: category_name, category_revenue, revenue_percentage
-- ---------------------------------------------------------------------------------
WITH category_revenue AS (
    SELECT cat.category_name, SUM(oi.total_price) AS revenue
    FROM order_items oi
    JOIN products p    ON p.product_id = oi.product_id
    JOIN categories cat ON cat.category_id = p.category_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY cat.category_name
),
total_revenue AS (
    SELECT SUM(revenue) AS grand_total FROM category_revenue
)
SELECT cr.category_name,
       cr.revenue,
       ROUND(cr.revenue / tr.grand_total * 100, 2) AS revenue_percentage
FROM category_revenue cr
CROSS JOIN total_revenue tr
ORDER BY revenue_percentage DESC;

-- ---------------------------------------------------------------------------------
-- Q8.3 | Purpose: Customer Lifetime Value (CLV) - total historical revenue per
--                 customer combined with their order count and average order value
-- Concept: CTE + Aggregate functions + LEFT JOIN (keeps zero-order customers at 0)
-- Expected output: Every customer's lifetime value, ready for segmentation
-- ---------------------------------------------------------------------------------
WITH clv AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(oi.total_price),0) AS lifetime_value
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.order_status <> 'Cancelled'
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT customer_id, customer_name, total_orders, lifetime_value,
       ROUND(lifetime_value / NULLIF(total_orders,0), 2) AS avg_order_value
FROM clv
ORDER BY lifetime_value DESC;


-- #####################################################################################
-- SECTION 9: KEY BUSINESS QUESTIONS
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- Q9.1 | Purpose: TOP 10 CUSTOMERS BY REVENUE
-- Concept: JOIN + GROUP BY + ORDER BY + LIMIT
-- ---------------------------------------------------------------------------------
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       SUM(oi.total_price) AS total_revenue
FROM customers c
JOIN orders o     ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- ---------------------------------------------------------------------------------
-- Q9.2 | Purpose: MONTHLY SALES REPORT
-- Concept: Date functions + GROUP BY
-- ---------------------------------------------------------------------------------
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
       COUNT(DISTINCT o.order_id) AS num_orders,
       SUM(oi.total_price) AS total_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY sales_month
ORDER BY sales_month;

-- ---------------------------------------------------------------------------------
-- Q9.3 | Purpose: BEST-SELLING PRODUCTS (by quantity sold)
-- Concept: GROUP BY + SUM + ORDER BY + LIMIT
-- ---------------------------------------------------------------------------------
SELECT p.product_name, SUM(oi.quantity) AS total_units_sold,
       SUM(oi.total_price) AS total_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC
LIMIT 10;

-- ---------------------------------------------------------------------------------
-- Q9.4 | Purpose: PRODUCTS NEVER ORDERED  (same technique as Q4.3)
-- Concept: NOT EXISTS
-- ---------------------------------------------------------------------------------
SELECT p.product_id, p.product_name
FROM products p
WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id);

-- ---------------------------------------------------------------------------------
-- Q9.5 | Purpose: CUSTOMERS WITHOUT ORDERS  (same technique as Q4.5)
-- Concept: LEFT JOIN + IS NULL
-- ---------------------------------------------------------------------------------
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- ---------------------------------------------------------------------------------
-- Q9.6 | Purpose: REVENUE BY CATEGORY
-- Concept: Multi-table JOIN + GROUP BY
-- ---------------------------------------------------------------------------------
SELECT cat.category_name, SUM(oi.total_price) AS category_revenue
FROM order_items oi
JOIN products p    ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY cat.category_name
ORDER BY category_revenue DESC;

-- ---------------------------------------------------------------------------------
-- Q9.7 | Purpose: AVERAGE ORDER VALUE (AOV)
-- Concept: Aggregate over a per-order subquery
-- ---------------------------------------------------------------------------------
SELECT ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT o.order_id, SUM(oi.total_price) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY o.order_id
) AS per_order_totals;

-- ---------------------------------------------------------------------------------
-- Q9.8 | Purpose: HIGHEST REVENUE MONTH
-- Concept: GROUP BY + ORDER BY + LIMIT 1
-- ---------------------------------------------------------------------------------
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
       SUM(oi.total_price) AS total_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY sales_month
ORDER BY total_sales DESC
LIMIT 1;

-- ---------------------------------------------------------------------------------
-- Q9.9 | Purpose: DAILY SALES TREND (last 30 calendar days of order activity)
-- Concept: Date functions + GROUP BY
-- ---------------------------------------------------------------------------------
SELECT o.order_date, SUM(oi.total_price) AS daily_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY o.order_date
ORDER BY o.order_date DESC
LIMIT 30;

-- ---------------------------------------------------------------------------------
-- Q9.10 | Purpose: TOP CITIES BY SALES
-- Concept: JOIN + GROUP BY + ORDER BY
-- ---------------------------------------------------------------------------------
SELECT o.shipping_city, SUM(oi.total_price) AS city_revenue,
       COUNT(DISTINCT o.order_id) AS num_orders
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY o.shipping_city
ORDER BY city_revenue DESC
LIMIT 10;

-- ---------------------------------------------------------------------------------
-- Q9.11 | Purpose: MOST EXPENSIVE PRODUCTS
-- Concept: ORDER BY + LIMIT
-- ---------------------------------------------------------------------------------
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 10;

-- ---------------------------------------------------------------------------------
-- Q9.12 | Purpose: LOWEST SELLING PRODUCTS (that have at least 1 sale, sorted ascending)
-- Concept: JOIN + GROUP BY + ORDER BY ASC
-- ---------------------------------------------------------------------------------
SELECT p.product_name, SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_units_sold ASC
LIMIT 10;

-- ---------------------------------------------------------------------------------
-- Q9.13 | Purpose: CUSTOMER LIFETIME VALUE  (same as Q8.3 CTE)
-- Concept: CTE + LEFT JOIN
-- (see Q8.3 above for the full query & explanation)
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Q9.14 | Purpose: REPEAT CUSTOMERS (placed more than one order)
-- Concept: GROUP BY + HAVING
-- ---------------------------------------------------------------------------------
SELECT o.customer_id, COUNT(*) AS order_count
FROM orders o
WHERE o.order_status <> 'Cancelled'
GROUP BY o.customer_id
HAVING COUNT(*) > 1
ORDER BY order_count DESC;

-- ---------------------------------------------------------------------------------
-- Q9.15 | Purpose: REVENUE CONTRIBUTION % PER CUSTOMER (Pareto / 80-20 analysis)
-- Concept: Window Function (SUM OVER) used to compute % of grand total per row
-- ---------------------------------------------------------------------------------
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(oi.total_price) AS customer_revenue,
    ROUND(SUM(oi.total_price) * 100.0 / SUM(SUM(oi.total_price)) OVER (), 2) AS pct_of_total_revenue
FROM customers c
JOIN orders o     ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, customer_name
ORDER BY customer_revenue DESC;


-- #####################################################################################
-- SECTION 10: VIEWS
-- #####################################################################################

-- ---------------------------------------------------------------------------------
-- View: CustomerSales
-- Purpose: Reusable summary of every customer's order count & total spend, so
--          analysts / BI tools can query it directly without repeating the JOIN logic.
-- Concept: CREATE VIEW - a saved, named SELECT statement that behaves like a virtual
--          table. It does not store data itself; it re-runs the underlying query
--          every time it is selected from.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE VIEW CustomerSales AS
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.city,
    c.customer_segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.total_price),0) AS total_spend
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.order_status <> 'Cancelled'
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, customer_name, c.city, c.customer_segment;

-- Sample usage:
SELECT * FROM CustomerSales ORDER BY total_spend DESC LIMIT 10;

-- ---------------------------------------------------------------------------------
-- View: ProductPerformance
-- Purpose: Quick per-product scorecard - units sold, revenue, and rank within category.
-- Concept: CREATE VIEW combined with a Window Function inside the view definition.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ProductPerformance AS
SELECT
    p.product_id,
    p.product_name,
    cat.category_name,
    p.price,
    COALESCE(SUM(oi.quantity),0)     AS total_units_sold,
    COALESCE(SUM(oi.total_price),0)  AS total_revenue,
    RANK() OVER (PARTITION BY p.category_id ORDER BY COALESCE(SUM(oi.total_price),0) DESC) AS category_rank
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, cat.category_name, p.price, p.category_id;

-- Sample usage:
SELECT * FROM ProductPerformance ORDER BY total_revenue DESC LIMIT 10;

-- ---------------------------------------------------------------------------------
-- View: MonthlyRevenue
-- Purpose: Ready-made monthly revenue trend for dashboards.
-- Concept: CREATE VIEW wrapping a GROUP BY + date-formatting query.
-- ---------------------------------------------------------------------------------
CREATE OR REPLACE VIEW MonthlyRevenue AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS num_orders,
    SUM(oi.total_price) AS total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY sales_month;

-- Sample usage:
SELECT * FROM MonthlyRevenue ORDER BY sales_month;


-- #####################################################################################
-- SECTION 11: INDEXING FOR QUERY OPTIMIZATION
-- #####################################################################################
-- The following indexes were already created in ecommerce_database.sql. Rationale:
--
-- idx_orders_customer_id     -> speeds up JOIN orders<->customers and lookups like
--                                "all orders for customer X" (used constantly above).
-- idx_orders_order_date      -> speeds up date-range filters and monthly GROUP BY
--                                queries (Q9.2, Q9.8, Q9.9) by avoiding a full scan.
-- idx_orderitems_order_id    -> speeds up JOIN order_items<->orders, the single most
--                                frequent join in this whole script.
-- idx_orderitems_product_id  -> speeds up JOIN order_items<->products and product
--                                sales aggregation (best-sellers, never-ordered, etc.)
-- idx_products_category_id   -> speeds up JOIN products<->categories and category
--                                revenue rollups.
-- idx_customers_city         -> speeds up WHERE city = '...' filters and "top cities"
--                                grouping.
--
-- Without these indexes MySQL must perform a full table scan (O(n)) for every JOIN
-- condition or WHERE filter; with a B-Tree index on the join/filter column, MySQL can
-- use an index seek (O(log n)) instead, which is dramatically faster as tables grow
-- into the millions of rows (the difference becomes very visible with EXPLAIN below).

-- Example: verify an index is actually chosen by the optimizer.
EXPLAIN
SELECT * FROM orders WHERE customer_id = 5;

-- Example: verify the date index helps a monthly range query.
EXPLAIN
SELECT * FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Additional index recommendation: a covering index on order_items(product_id, order_id)
-- would let MySQL answer "best-selling products" purely from the index without ever
-- touching the base table (an "index-only scan"). Uncomment to create it:
-- CREATE INDEX idx_orderitems_covering ON order_items(product_id, order_id, quantity, unit_price);


-- #####################################################################################
-- END OF analysis_queries.sql
-- #####################################################################################
