# Customer Revenue Analysis, 2015–2017
**Stout — Data Analyst, Transformative Change Case Study**
Author: Rong Zhang

**Tableau dashboard:** https://public.tableau.com/app/profile/rong.zhang6629/viz/StoutCaseStudyCustomerRevenueAnalysis/CustomerRevenueDashboard

---

## Overview
The dataset contains three years (2015–2017) of customer orders with four columns: `index`, `customer_email` (hashed customer ID), `net_revenue`, and `year`. This project calculates 10 customer and revenue metrics for each year, validates them, and presents the results and insights in a Tableau dashboard.

**Tools:** SQLite (DB Browser for SQLite) for all calculations, Tableau Public for visualization.

## Approach
1. **Define the metrics** and state assumptions before writing code.
2. **Profile the data:** structure, data types and grain (one row per customer per year).
3. **Check data quality:** nulls, value range, duplicates, and the formatting of the join key (`customer_email`).
4. **Calculate the metrics** by splitting each pair of consecutive years into three customer groups: **new**, **existing (retained)** and **lost**.
5. **Validate** the results with two reconciliation checks, then visualize the findings.

## Data Quality Finding
About **39% of rows (270,214)** had leading or trailing whitespace in `customer_email`. Because email is the key used to match customers across years, the same customer could appear as two different customers, for example `" abc@gmail.com"` in 2016 and `"abc@gmail.com"` in 2017. That would misclassify one returning customer as both **lost** and **new**.

All emails were trimmed into a cleaned table (`orders_clean`). The raw table was left untouched for auditability.

| 2017 | Raw emails | Trimmed emails |
|---|---|---|
| Existing customers | 20,959 | **76,538** |
| New customers | 229,028 | **173,449** |
| Lost customers | 183,687 | **128,108** |

Other checks passed: no nulls, revenue between $1 and $250 (no zero or negative values), and no duplicate customer-year rows.

## Metric Definitions
For year Y:

| # | Metric | Definition |
|---|---|---|
| 1 | Total Revenue | Sum of revenue in Y |
| 2 | New Customer Revenue | Y revenue from customers not present in Y-1 |
| 3 | Existing Customer Growth | #5 − #6 |
| 4 | Revenue Lost from Attrition | Y-1 revenue of customers present in Y-1 but not in Y |
| 5 | Existing Customer Revenue, Current Year | Y revenue of customers present in both Y and Y-1 |
| 6 | Existing Customer Revenue, Prior Year | Y-1 revenue of those same customers |
| 7 | Total Customers, Current Year | Distinct customers in Y |
| 8 | Total Customers, Prior Year | Distinct customers in Y-1 |
| 9 | New Customers | Customers in Y but not in Y-1 |
| 10 | Lost Customers | Customers in Y-1 but not in Y |

**Assumptions**
- "New" is judged against the immediately prior year only, as the case specifies.
- 2015 is the baseline year. Metrics that need a prior year are shown as N/A, not 0.

## Results

| # | Metric | 2015 | 2016 | 2017 |
|---|---|---|---|---|
| 1 | Total Revenue | $29,036,749.19 | $25,730,943.59 | $31,417,495.03 |
| 2 | New Customer Revenue | N/A | $17,206,366.90 | $21,769,213.01 |
| 3 | Existing Customer Growth | N/A | $39,043.65 | $63,857.06 |
| 4 | Revenue Lost from Attrition | N/A | $20,551,216.15 | $16,146,518.63 |
| 5 | Existing Customer Revenue, Current Year | N/A | $8,524,576.69 | $9,648,282.02 |
| 6 | Existing Customer Revenue, Prior Year | N/A | $8,485,533.04 | $9,584,424.96 |
| 7 | Total Customers, Current Year | 231,294 | 204,646 | 249,987 |
| 8 | Total Customers, Prior Year | N/A | 231,294 | 204,646 |
| 9 | New Customers | N/A | 136,891 | 173,449 |
| 10 | Lost Customers | N/A | 163,539 | 128,108 |

## Validation
Two identities must hold for every year after 2015 (`sql/05_reconciliation.sql`):

- **Revenue Change = New Customer Revenue + Existing Customer Growth − Revenue Lost from Attrition**
- **Current Year Customers = Prior Year Customers − Lost Customers + New Customers**

| Year | Revenue change | New + Growth − Attrition | Difference | Customers | Prior − Lost + New | Difference |
|---|---|---|---|---|---|---|
| 2016 | −$3,305,805.60 | −$3,305,805.60 | **0** | 204,646 | 204,646 | **0** |
| 2017 | $5,686,551.44 | $5,686,551.44 | **0** | 249,987 | 249,987 | **0** |

Both checks tie out exactly, so the ten metrics are internally consistent.

## Key Insights

| Derived metric | 2016 | 2017 |
|---|---|---|
| Revenue YoY | −11.4% | +22.1% |
| Retention rate (existing ÷ prior-year customers) | 29.3% | 37.4% |
| Churn rate (lost ÷ prior-year customers) | 70.7% | 62.6% |
| Existing customer spend growth (#3 ÷ #6) | +0.46% | +0.67% |
| Revenue per customer | $125.73 | $125.68 |

1. **Churn is very high.** 63–71% of customers do not return the following year.
2. **Revenue depends on acquisition outpacing churn.** In 2016, 163,539 customers were lost and only 136,891 were gained, so revenue fell 11.4%. In 2017, 173,449 were gained and 128,108 lost, so revenue rose 22.1%.
3. **Existing customers' spending is essentially flat** (+0.5–0.7%), so revenue growth is not coming from retained customers spending more.
4. **2017 improved on both fronts:** retention rose from 29.3% to 37.4%, and new customers grew 27%.
5. **Revenue per customer is about $125 in every group and year**, so customer count drives revenue. The even spread of values between $1 and $250 also suggests the data is synthetic.

**Recommendation:** Focus on retention. With roughly two-thirds of customers churning each year, even a small improvement compounds, because every retained customer is revenue that does not need to be re-acquired.

## Dashboard
The Tableau dashboard has four views. A year filter controls the first two; the trend views show all years.
1. **Key Metrics:** all 10 metrics for the selected year, labeled Q1–Q10
2. **What Drove Revenue Change:** new customer revenue, existing customer growth and attrition for the selected year
3. **Customer Movement:** new vs. retained vs. lost customers, 2016–2017
4. **Revenue & Retention Rate Trend:** total revenue 2015–2017 with retention rate

Only the aggregated summary table (`data/dashboard_metrics.csv`, 3 rows) was published to Tableau Public. No customer-level data was published.

## Repository Structure
```
sql/
  01_data_quality_checks.sql   profiling and data quality checks on the raw table
  02_clean_data.sql            trims emails into orders_clean (raw table untouched)
  03_metrics_queries.sql       the 10 metric queries, one per metric
  04_dashboard_data.sql        combines all metrics into one table for Tableau
  05_reconciliation.sql        validation checks (both should return 0)
data/
  dashboard_metrics.csv        summary table used by the Tableau dashboard
```

## How to Reproduce
1. Import `casestudy.csv` into SQLite as a table named `customer_orders`. Do not trim fields on import.
2. Run the SQL files in order: `01` → `02` → `03` → `04` → `05`.
3. Export `dashboard_metrics` to CSV and connect it in Tableau.
