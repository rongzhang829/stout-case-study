-- 04_dashboard_data.sql
-- Combine all 10 metrics into one summary table (one row per year)
-- for export to Tableau. 2015 comparative metrics are NULL (N/A: no prior year).

DROP TABLE IF EXISTS dashboard_metrics;

CREATE TABLE dashboard_metrics AS
WITH totals AS (            -- Q1, Q7: revenue and customers per year
    SELECT year,
           SUM(net_revenue) AS revenue,
           COUNT(*)         AS customers
    FROM orders_clean
    GROUP BY year
),
existing AS (               -- Q5, Q6: customers present in both years
    SELECT cur.year,
           SUM(cur.net_revenue)  AS rev_current,
           SUM(prev.net_revenue) AS rev_prior,
           COUNT(*)              AS customers
    FROM orders_clean cur
    JOIN orders_clean prev
      ON  prev.customer_email = cur.customer_email
      AND prev.year = cur.year - 1
    GROUP BY cur.year
),
new_cust AS (               -- Q2, Q9: in this year, not in last year
    SELECT cur.year,
           SUM(cur.net_revenue) AS revenue,
           COUNT(*)             AS customers
    FROM orders_clean cur
    LEFT JOIN orders_clean prev
      ON  prev.customer_email = cur.customer_email
      AND prev.year = cur.year - 1
    WHERE prev.customer_email IS NULL
      AND cur.year > 2015
    GROUP BY cur.year
),
lost_cust AS (              -- Q4, Q10: in last year, not in this year
    SELECT prev.year + 1          AS year,
           SUM(prev.net_revenue)  AS revenue,
           COUNT(*)               AS customers
    FROM orders_clean prev
    LEFT JOIN orders_clean cur
      ON  cur.customer_email = prev.customer_email
      AND cur.year = prev.year + 1
    WHERE cur.customer_email IS NULL
      AND prev.year < 2017
    GROUP BY prev.year
)
SELECT t.year,
       ROUND(t.revenue, 2)                    AS total_revenue,                      -- Q1
       ROUND(n.revenue, 2)                    AS new_customer_revenue,               -- Q2
       ROUND(e.rev_current - e.rev_prior, 2)  AS existing_customer_growth,           -- Q3
       ROUND(l.revenue, 2)                    AS revenue_lost_from_attrition,        -- Q4
       ROUND(e.rev_current, 2)                AS existing_customer_revenue_current,  -- Q5
       ROUND(e.rev_prior, 2)                  AS existing_customer_revenue_prior,    -- Q6
       t.customers                            AS total_customers_current,            -- Q7
       p.customers                            AS total_customers_prior,              -- Q8
       n.customers                            AS new_customers,                      -- Q9
       l.customers                            AS lost_customers,                     -- Q10
       e.customers                            AS existing_customers,                 -- extra
       ROUND(t.revenue - p.revenue, 2)        AS revenue_change                      -- extra
FROM totals t
LEFT JOIN totals    p ON p.year = t.year - 1
LEFT JOIN existing  e ON e.year = t.year
LEFT JOIN new_cust  n ON n.year = t.year
LEFT JOIN lost_cust l ON l.year = t.year
ORDER BY t.year;

-- Check the result: should be 3 rows (2015, 2016, 2017)
SELECT * FROM dashboard_metrics;
