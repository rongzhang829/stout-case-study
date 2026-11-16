-- 01_data_quality_checks.sql
-- Profile the raw table (customer_orders) before any analysis.

-- Check 1: rows, distinct customers and revenue per year
-- Result: row_count = customers every year -> grain is one row per customer per year (no duplicates)
SELECT year,
       COUNT(*)                       AS row_count,
       COUNT(DISTINCT customer_email) AS customers,
       ROUND(SUM(net_revenue), 2)     AS revenue
FROM customer_orders
GROUP BY year
ORDER BY year;

-- Check 2: missing values in each column
-- Result: 0 / 0 / 0
SELECT SUM(customer_email IS NULL) AS null_emails,
       SUM(net_revenue IS NULL)    AS null_revenue,
       SUM(year IS NULL)           AS null_year
FROM customer_orders;

-- Check 3: revenue range
-- Result: min 1.00, max 250.00 -> no zero, negative or extreme values
SELECT MIN(net_revenue) AS min_rev,
       MAX(net_revenue) AS max_rev
FROM customer_orders;

-- Check 4: duplicate customer-year rows
-- Result: none
SELECT customer_email, year, COUNT(*) AS n
FROM customer_orders
GROUP BY customer_email, year
HAVING COUNT(*) > 1;

-- Check 5: join key formatting - emails with leading/trailing spaces
-- Result: 270,214 rows (~39%) -> must trim before matching customers across years
SELECT COUNT(*) AS rows_with_spaces
FROM customer_orders
WHERE customer_email <> TRIM(customer_email);
