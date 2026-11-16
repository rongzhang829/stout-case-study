-- 05_reconciliation.sql
-- Check that the 10 metrics are internally consistent.
-- Both differences should be 0 for every year after 2015.

SELECT cur.year,
       -- Check 1: Revenue change = New revenue + Existing growth - Attrition
       ROUND(cur.total_revenue - prev.total_revenue, 2)               AS revenue_change,
       ROUND(cur.new_customer_revenue
             + cur.existing_customer_growth
             - cur.revenue_lost_from_attrition, 2)                     AS revenue_bridge,
       ROUND((cur.total_revenue - prev.total_revenue)
             - (cur.new_customer_revenue
                + cur.existing_customer_growth
                - cur.revenue_lost_from_attrition), 2)                 AS revenue_difference,

       -- Check 2: Customers this year = Customers last year - Lost + New
       cur.total_customers_current                                     AS customers_actual,
       cur.total_customers_prior - cur.lost_customers + cur.new_customers AS customers_bridge,
       cur.total_customers_current
         - (cur.total_customers_prior - cur.lost_customers + cur.new_customers) AS customer_difference
FROM dashboard_metrics cur
JOIN dashboard_metrics prev
  ON prev.year = cur.year - 1
ORDER BY cur.year;
