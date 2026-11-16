-- 03_metrics_queries.sql
-- Stout Data Analyst Case Study: 10 metrics, one query each.
-- All queries use the cleaned table orders_clean (see 02_clean_data.sql).
-- Grain: one row per customer per year. Years: 2015-2017.

-- ============================================================
-- Q1: Total Revenue for each year
-- ============================================================
SELECT year, ROUND(SUM(net_revenue), 2) AS total_revenue
FROM orders_clean GROUP BY year ORDER BY year;

-- ============================================================
-- Q7: Total Customers, Current Year
-- ============================================================
SELECT year, COUNT(DISTINCT customer_email) AS total_customers_current
FROM orders_clean GROUP BY year ORDER BY year;

-- ============================================================
-- Q8: Total Customers, Prior Year
-- Shift each year forward by 1 so last year's count lines up with this year.
-- ============================================================
SELECT year + 1 AS year, COUNT(DISTINCT customer_email) AS total_customers_prior
FROM orders_clean
WHERE year < 2017
GROUP BY year ORDER BY year;

-- ============================================================
-- Q5: Existing Customer Revenue, Current Year
-- Existing = present in both this year and last year (INNER JOIN).
-- ============================================================
SELECT cur.year, ROUND(SUM(cur.net_revenue), 2) AS existing_customer_revenue_current
FROM orders_clean cur
JOIN orders_clean prev
  ON  prev.customer_email = cur.customer_email
  AND prev.year = cur.year - 1
GROUP BY cur.year ORDER BY cur.year;

-- ============================================================
-- Q6: Existing Customer Revenue, Prior Year
-- Same existing customers as Q5, but sum their PRIOR-year revenue.
-- ============================================================
SELECT cur.year, ROUND(SUM(prev.net_revenue), 2) AS existing_customer_revenue_prior
FROM orders_clean cur
JOIN orders_clean prev
  ON  prev.customer_email = cur.customer_email
  AND prev.year = cur.year - 1
GROUP BY cur.year ORDER BY cur.year;

-- ============================================================
-- Q3: Existing Customer Growth
-- = existing customers' current-year revenue (Q5) minus their prior-year revenue (Q6).
-- ============================================================
SELECT cur.year,
       ROUND(SUM(cur.net_revenue) - SUM(prev.net_revenue), 2) AS existing_customer_growth
FROM orders_clean cur
JOIN orders_clean prev
  ON  prev.customer_email = cur.customer_email
  AND prev.year = cur.year - 1
GROUP BY cur.year ORDER BY cur.year;

-- ============================================================
-- Q2: New Customer Revenue
-- New = present this year, NOT present last year (LEFT JOIN + IS NULL).
-- 2015 excluded: no prior year, so 'new' cannot be determined (N/A).
-- ============================================================
SELECT cur.year, ROUND(SUM(cur.net_revenue), 2) AS new_customer_revenue
FROM orders_clean cur
LEFT JOIN orders_clean prev
  ON  prev.customer_email = cur.customer_email
  AND prev.year = cur.year - 1
WHERE prev.customer_email IS NULL
  AND cur.year > 2015
GROUP BY cur.year ORDER BY cur.year;

-- ============================================================
-- Q9: New Customers
-- Same logic as Q2, but count customers instead of summing revenue.
-- ============================================================
SELECT cur.year, COUNT(*) AS new_customers
FROM orders_clean cur
LEFT JOIN orders_clean prev
  ON  prev.customer_email = cur.customer_email
  AND prev.year = cur.year - 1
WHERE prev.customer_email IS NULL
  AND cur.year > 2015
GROUP BY cur.year ORDER BY cur.year;

-- ============================================================
-- Q4: Revenue Lost from Attrition
-- Lost = present last year, NOT present this year.
-- Start from the PRIOR year and look up the next year, then sum PRIOR-year revenue.
-- Reported in the year the loss occurs (prev.year + 1). 2017 excluded: no 2018 data.
-- ============================================================
SELECT prev.year + 1 AS year, ROUND(SUM(prev.net_revenue), 2) AS revenue_lost_from_attrition
FROM orders_clean prev
LEFT JOIN orders_clean cur
  ON  cur.customer_email = prev.customer_email
  AND cur.year = prev.year + 1
WHERE cur.customer_email IS NULL
  AND prev.year < 2017
GROUP BY prev.year ORDER BY prev.year;

-- ============================================================
-- Q10: Lost Customers
-- Same logic as Q4, but count customers instead of summing revenue.
-- ============================================================
SELECT prev.year + 1 AS year, COUNT(*) AS lost_customers
FROM orders_clean prev
LEFT JOIN orders_clean cur
  ON  cur.customer_email = prev.customer_email
  AND cur.year = prev.year + 1
WHERE cur.customer_email IS NULL
  AND prev.year < 2017
GROUP BY prev.year ORDER BY prev.year;
