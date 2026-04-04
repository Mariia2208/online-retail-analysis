-- ================================================================
-- 🛒 ONLINE RETAIL II — SQL ANALYSIS
-- Dataset: UCI Online Retail II (Kaggle)
-- Period: December 2009 — December 2011
-- Tool: PostgreSQL
-- ================================================================
-- 📖 STORY: A UK-based online gift retailer wants to understand
-- its business performance. Who are the best customers?
-- When does the business make the most money?
-- Are there patterns we can use to grow revenue?
-- This analysis answers these questions step by step.
-- ================================================================


-- ================================================================
-- 📂 CHAPTER 1: GETTING TO KNOW THE DATA
-- Before any analysis, I explored the dataset to understand
-- what we are working with — size, time period, and scope.
-- ================================================================

SELECT 
    MIN(invoicedate) AS first_transaction,
    MAX(invoicedate) AS last_transaction,
    COUNT(DISTINCT country) AS unique_countries,
    COUNT(DISTINCT customerid) AS unique_customers,
    COUNT(DISTINCT stockcode) AS unique_products,
    COUNT(DISTINCT invoiceno) AS total_invoices
FROM online_retail;

-- 📊 Results:
-- Period: 2009-12-01 → 2011-12-09
-- Countries: 43
-- Customers: 5,942
-- Products: 5,698
-- Invoices: 53,628


-- ================================================================
-- 🔍 CHAPTER 2: DATA QUALITY CHECK
-- Real data is never perfect. Before trusting any result,
-- I checked for three common data quality issues.
-- ================================================================

-- Issue 1: Missing customer identity
SELECT COUNT(*) AS null_customerid
FROM online_retail
WHERE customerid IS NULL;
-- Result: 243,007 rows — guest purchases with no customer identity

-- Issue 2: Returns and cancellations
SELECT COUNT(*) AS negative_quantity
FROM online_retail
WHERE quantity <= 0;
-- Result: 22,950 rows — product returns

-- Issue 3: Zero-price items
SELECT COUNT(*) AS zero_price
FROM online_retail
WHERE price <= 0;
-- Result: 6,220 rows — samples or damaged goods

-- 💡 Decision:
-- NULL CustomerIDs → exclude from customer analysis
-- (kept for revenue-only queries since sales still occurred)
-- Negative Quantity → exclude (returns are not sales)
-- Zero Price → exclude (no commercial value)


-- ================================================================
-- 🧹 CHAPTER 3: CLEANING THE DATA
-- I used a CTE to create a clean version of the dataset
-- without modifying the original table.
-- A new column 'revenue' was added since it didn't exist.
-- ================================================================

-- DEBUGGING NOTE:
-- Initial CTE returned only 3,457 rows — unexpectedly low.
-- I tested each WHERE condition separately to find the issue:
--   Step 1: customerid IS NOT NULL → 824,364 rows ✅
--   Step 2: + quantity > 0         → 805,620 rows ✅
--   Step 3: + price > 0            → 805,531 rows ✅
-- Root cause: conditions were inverted in the first attempt.
-- I filtered FOR bad data instead of AGAINST it.
-- Incremental testing quickly revealed the mistake.

-- ✅ FINAL CLEAN DATA CTE — used as base for all further analysis
WITH clean_data AS (
    SELECT *,
           quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
)
SELECT COUNT(*) FROM clean_data;
-- Clean dataset: 805,531 rows ready for analysis


-- ================================================================
-- 💰 CHAPTER 4: IS THE BUSINESS MAKING MONEY?
-- The first question any business asks.
-- I translated raw transactions into business metrics.
-- ================================================================

WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
)
SELECT
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_transaction_revenue,
    COUNT(DISTINCT invoiceno) AS total_transactions
FROM clean_data;

-- 📊 Results:
-- Total Revenue:        $17,743,429
-- Avg per Transaction:  $22
-- Total Transactions:   36,969
--
-- 💡 Insight: The business generated $17.7M over 2 years
-- with a consistent average transaction value of $22.
-- The volume of transactions confirms this is an active,
-- healthy business — not a struggling one.


-- ================================================================
-- 📅 CHAPTER 5: WHEN DOES THE BUSINESS PERFORM BEST?
-- I broke revenue down by year and month to find patterns.
-- This is where the story gets interesting.
-- ================================================================

-- Revenue by Year
WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
)
SELECT 
    EXTRACT(YEAR FROM invoicedate) AS year,
    ROUND(SUM(revenue)) AS total_revenue
FROM clean_data
GROUP BY year
ORDER BY year;

-- 💡 Insight: 2009 shows only $686,654 — not a weak year,
-- simply because the dataset starts December 1, 2009 (1 month only).
-- Fair comparison: 2010 ($8.7M) vs 2011 ($8.3M) — slight decline worth monitoring.

-- Revenue by Month — Seasonality
WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
)
SELECT 
    EXTRACT(MONTH FROM invoicedate) AS month,
    ROUND(SUM(revenue)) AS total_revenue
FROM clean_data
GROUP BY month
ORDER BY total_revenue DESC;

-- 💡 Insight: Top 3 months — November, October, December.
-- The pattern is clear: this business runs on holiday shopping.
-- • Black Friday / Cyber Monday drives November peak
-- • Christmas shopping fuels December
-- • October captures early gift buyers
-- Business implication: Q4 is not just busy — it defines the year.


-- ================================================================
-- 👥 CHAPTER 6: WHO ARE THE BEST CUSTOMERS?
-- Not all customers are equal. I identified top performers
-- and tested a hypothesis about why they rank so high.
-- ================================================================

-- Top 10 Customers by Revenue
WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
)
SELECT 
    customerid,
    SUM(revenue) AS total_revenue
FROM clean_data
GROUP BY customerid
ORDER BY total_revenue DESC
LIMIT 10;

-- 💡 Insight: Top customer (18102) generated $608,821 — 3.4% of
-- total company revenue alone. The gap between #1 and #3 is massive.
-- This pattern suggests wholesale/B2B buyers, not regular consumers.
-- Note: customerid stored as float (18102.0) — original dataset issue,
-- does not affect analysis results.

-- HYPOTHESIS TESTING: Why is customer 18102 #1?
-- My hypothesis: active since day 1 means more time to accumulate revenue.
WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
)
SELECT 
    MIN(invoicedate) AS first_purchase,
    MAX(invoicedate) AS last_purchase,
    COUNT(invoiceno) AS total_transactions,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM clean_data
WHERE customerid = '18102.0';

-- 📊 Results:
-- First purchase: 2009-12-01 ✅ active from dataset start
-- Last purchase:  2011-12-09 ✅ active until dataset end
-- Transactions: 1,058 — avg 44 per month
-- Revenue: $608,821
--
-- 💡 Conclusion: High revenue comes from BOTH long tenure AND
-- high purchase frequency. 44 transactions/month confirms
-- this is a wholesale buyer, not a regular retail customer.


-- ================================================================
-- 🏆 CHAPTER 7: RANKING CUSTOMERS WITH WINDOW FUNCTIONS
-- Instead of just sorting, I used RANK() to assign each customer
-- a position — making it easy to filter by tier in future queries.
-- ================================================================

-- Customer Ranking — RANK() Window Function
WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
),
rank_customers AS (
    SELECT 
        customerid,
        SUM(revenue) AS total_revenue,
        RANK() OVER (ORDER BY SUM(revenue) DESC) AS rank
    FROM clean_data
    GROUP BY customerid
)
SELECT rank, customerid, total_revenue
FROM rank_customers
WHERE rank <= 10;

-- Note: I used two chained CTEs here.
-- CTE 1 (clean_data): filters and prepares raw data
-- CTE 2 (rank_customers): assigns rank to every customer
-- Final SELECT filters to top 10 using WHERE rank <= 10
--
-- This is more powerful than LIMIT 10:
-- LIMIT just cuts the list — RANK handles ties correctly
-- and allows flexible threshold changes (top 20, top 50, etc.)


-- ================================================================
-- 📈 CHAPTER 8: IS REVENUE GROWING MONTH OVER MONTH?
-- I used LAG() to compare each month with the previous one —
-- revealing the true growth story behind the numbers.
-- ================================================================

WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
),
monthly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM invoicedate) AS year,
        EXTRACT(MONTH FROM invoicedate) AS month,
        SUM(revenue) AS total_revenue
    FROM clean_data
    GROUP BY year, month
)
SELECT 
    year,
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
    total_revenue - LAG(total_revenue) OVER (ORDER BY year, month) AS revenue_change
FROM monthly_revenue;

-- 💡 Insight 1 — Seasonality confirmed:
-- Sep → Oct → Nov shows consistent growth every single year.
-- Peak: November 2010 ($1,172,336) — almost certainly Black Friday driven.
-- Sharp decline follows every December and January.
--
-- 💡 Insight 2 — The business is predictable:
-- The same cycle repeats year over year — positive in Q4, negative in Q1.
-- Predictability is a strength: the business can plan inventory,
-- staffing, and budgets with confidence around this pattern.


-- ================================================================
-- 🎯 CHAPTER 9: SEGMENTING CUSTOMERS BY VALUE
-- Using CASE WHEN to classify every customer into a business tier.
-- This turns raw revenue numbers into an actionable strategy.
-- ================================================================

WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
),
customers AS (
    SELECT 
        customerid,
        SUM(revenue) AS total_revenue,
        CASE 
            WHEN SUM(revenue) > 10000 THEN 'VIP'
            WHEN SUM(revenue) BETWEEN 1000 AND 10000 THEN 'Regular'
            ELSE 'Occasional'
        END AS customer_segment
    FROM clean_data
    GROUP BY customerid
)
SELECT 
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM customers
GROUP BY customer_segment
ORDER BY percentage DESC;

-- 📊 Results:
-- 🟢 Occasional (<$1K):    3,131 customers = 53%
-- 🟡 Regular ($1K-$10K):  2,480 customers = 42%
-- 🔴 VIP (>$10K):           267 customers =  5%
--
-- 💡 Insight: Only 5% are VIP — yet this small group almost certainly
-- drives the majority of revenue (classic 80/20 rule).
-- 53% occasional buyers have low switching cost and high churn risk.
--
-- Business recommendations by segment:
-- VIP       → personal account managers + exclusive early access
-- Regular   → loyalty program: "spend $X more to reach VIP status"
-- Occasional → re-engagement emails + first-purchase discount incentives


-- ================================================================
-- 📊 CHAPTER 10: WHICH MONTHS BEAT THE AVERAGE?
-- Using a subquery to benchmark each month against overall average.
-- This separates truly strong months from average performance.
-- ================================================================

WITH clean_data AS (
    SELECT *, quantity * price AS revenue
    FROM online_retail
    WHERE customerid IS NOT NULL
    AND quantity > 0
    AND price > 0
),
monthly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM invoicedate) AS year,
        EXTRACT(MONTH FROM invoicedate) AS month,
        SUM(revenue) AS total_revenue
    FROM clean_data
    GROUP BY year, month
)
SELECT year, month, total_revenue
FROM monthly_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM monthly_revenue
)
ORDER BY total_revenue DESC;

-- 📊 Result: Only 7 out of 25 months performed above average.
-- All 7 fall in Sep(9), Oct(10), Nov(11), Dec(12).
--
-- 💡 Insight: The business is heavily Q4-dependent.
-- Peak months generate 2x the average monthly revenue.
-- Without strong Q4 performance, annual targets would be missed.
--
-- Business implication: Q4 is not just the best season —
-- it is the season that makes or breaks the year.
-- Any supply chain issues or marketing failures in Sep-Nov
-- would have a disproportionate impact on annual results.


-- ================================================================
-- 🏁 SUMMARY OF KEY FINDINGS
-- ================================================================
--
-- 1. BUSINESS HEALTH:    $17.7M revenue | 36,969 transactions | $22 avg
-- 2. YEARLY TREND:       2010 ($8.7M) slightly outperformed 2011 ($8.3M)
-- 3. SEASONALITY:        Q4 (Oct-Nov-Dec) dominates — Black Friday effect
-- 4. TOP CUSTOMER:       #18102 generated $608K — wholesale B2B buyer
-- 5. CUSTOMER SEGMENTS:  5% VIP | 42% Regular | 53% Occasional
-- 6. ABOVE AVERAGE:      Only 7/25 months beat average — all in Q4
--
-- ================================================================
-- SQL techniques demonstrated:
-- ✅ CTEs (Common Table Expressions) — chained and reusable
-- ✅ Window Function: RANK() — customer ranking with ties support
-- ✅ Window Function: LAG() — month-over-month comparison
-- ✅ Complex CASE WHEN — customer segmentation by value tier
-- ✅ Subquery — dynamic benchmarking against average
-- ✅ Debugging — incremental condition testing
-- ✅ Hypothesis testing — data-driven assumption validation
-- ================================================================
