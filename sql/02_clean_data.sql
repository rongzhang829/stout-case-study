-- 02_clean_data.sql
-- Trim leading/trailing spaces from emails into a new table.
-- The raw table (customer_orders) stays untouched for auditability.
DROP TABLE IF EXISTS orders_clean;

CREATE TABLE orders_clean AS
SELECT TRIM(customer_email) AS customer_email, net_revenue, year
FROM customer_orders;

-- Index to speed up the year-over-year self-joins
CREATE INDEX IF NOT EXISTS idx_clean ON orders_clean(customer_email, year);

-- Verify: should return 0
SELECT COUNT(*) AS rows_with_spaces
FROM orders_clean
WHERE customer_email <> TRIM(customer_email);
