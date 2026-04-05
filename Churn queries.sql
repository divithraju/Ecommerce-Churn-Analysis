-- ================================================================
-- E-COMMERCE CHURN ANALYSIS - SQL BUSINESS QUERIES
-- Author: Divith Raju
-- Tools: MySQL 8.0
-- Dataset: E-Commerce Customer Churn Dataset
-- ================================================================
-- HOW TO USE:
-- 1. Create a MySQL database named 'ecommerce_churn'
-- 2. Import the dataset using the Python script in notebooks/
-- 3. Run these queries in sequence or individually
-- ================================================================

USE ecommerce_churn;

-- ================================================================
-- QUERY 1: OVERALL CHURN RATE & BUSINESS IMPACT
-- Business Question: What is our current churn rate and annual revenue impact?
-- ================================================================
SELECT 
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned_customers,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(CASE WHEN Churn = 1 THEN CashbackAmount END) * 12, 0) AS avg_annual_value_lost_per_customer,
    ROUND(SUM(Churn) * AVG(CASE WHEN Churn = 1 THEN CashbackAmount END) * 12, 0) AS total_annual_revenue_at_risk
FROM ecommerce_customers;


-- ================================================================
-- QUERY 2: CHURN RATE BY LOGIN DEVICE
-- Business Question: Which platform has the highest churn — are we losing mobile users?
-- ================================================================
SELECT 
    PreferredLoginDevice,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    ROUND(AVG(HourSpendOnApp), 2) AS avg_hours_on_app,
    RANK() OVER (ORDER BY SUM(Churn) * 1.0 / COUNT(*) DESC) AS churn_rank
FROM ecommerce_customers
GROUP BY PreferredLoginDevice
ORDER BY churn_rate_pct DESC;


-- ================================================================
-- QUERY 3: THE 45-DAY CHURN THRESHOLD
-- Business Question: At what inactivity point should we trigger retention?
-- ================================================================
SELECT 
    CASE 
        WHEN DaySinceLastOrder BETWEEN 0  AND 10  THEN '0-10 days'
        WHEN DaySinceLastOrder BETWEEN 11 AND 20  THEN '11-20 days'
        WHEN DaySinceLastOrder BETWEEN 21 AND 30  THEN '21-30 days'
        WHEN DaySinceLastOrder BETWEEN 31 AND 45  THEN '31-45 days'
        WHEN DaySinceLastOrder BETWEEN 46 AND 60  THEN '46-60 days'
        ELSE '60+ days'
    END AS inactivity_bucket,
    COUNT(*) AS customers,
    SUM(Churn) AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    -- Insight flag
    CASE 
        WHEN ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) > 60 THEN '⚠️ CRITICAL — Trigger campaign NOW'
        WHEN ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) > 30 THEN '⚡ HIGH RISK — Monitor closely'
        ELSE '✅ Normal range'
    END AS action_required
FROM ecommerce_customers
GROUP BY inactivity_bucket
ORDER BY MIN(DaySinceLastOrder);


-- ================================================================
-- QUERY 4: CHURN BY CITY TIER WITH CASHBACK ANALYSIS
-- Business Question: Are Tier-2/3 cities underserved by our loyalty program?
-- ================================================================
SELECT 
    CityTier,
    COUNT(*) AS total_customers,
    ROUND(AVG(Churn) * 100, 2) AS churn_rate_pct,
    ROUND(AVG(CashbackAmount), 2) AS avg_cashback,
    ROUND(AVG(SatisfactionScore), 2) AS avg_satisfaction,
    -- Cashback adoption (above median = high adoption)
    ROUND(
        SUM(CASE WHEN CashbackAmount > (SELECT MEDIAN(CashbackAmount) FROM ecommerce_customers) THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 1
    ) AS cashback_adoption_pct
FROM ecommerce_customers
GROUP BY CityTier
ORDER BY CityTier;


-- ================================================================
-- QUERY 5: CUSTOMER LIFETIME VALUE BY SEGMENT (Window Function)
-- Business Question: Which customer segments are most valuable AND most at risk?
-- ================================================================
WITH customer_segments AS (
    SELECT 
        CustomerID,
        Churn,
        CashbackAmount,
        Tenure,
        OrderCount,
        CASE 
            WHEN Tenure >= 24 THEN 'Loyal (2y+)'
            WHEN Tenure >= 12 THEN 'Established (1-2y)'
            WHEN Tenure >= 3  THEN 'Growing (3-12m)'
            ELSE 'New (0-3m)'
        END AS loyalty_segment
    FROM ecommerce_customers
)
SELECT 
    loyalty_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(Churn) * 100, 1) AS churn_rate_pct,
    ROUND(AVG(CashbackAmount) * 12, 0) AS estimated_annual_value,
    ROUND(AVG(OrderCount), 1) AS avg_orders,
    -- Revenue at risk from churned customers in this segment
    ROUND(SUM(CASE WHEN Churn = 1 THEN CashbackAmount * 12 ELSE 0 END), 0) AS segment_revenue_at_risk
FROM customer_segments
GROUP BY loyalty_segment
ORDER BY estimated_annual_value DESC;


-- ================================================================
-- QUERY 6: RFM SCORE CALCULATION
-- Business Question: Who are our Champions vs Lost customers?
-- ================================================================
WITH rfm_base AS (
    SELECT 
        CustomerID,
        Churn,
        -- Recency: fewer days since order = better (rank 4)
        NTILE(4) OVER (ORDER BY DaySinceLastOrder ASC)  AS r_score,
        -- Frequency: more orders = better (rank 4)
        NTILE(4) OVER (ORDER BY OrderCount DESC)         AS f_score,
        -- Monetary: higher cashback = more spend (rank 4)
        NTILE(4) OVER (ORDER BY CashbackAmount DESC)     AS m_score,
        CashbackAmount,
        OrderCount,
        DaySinceLastOrder
    FROM ecommerce_customers
),
rfm_scored AS (
    SELECT *,
        (r_score + f_score + m_score) AS rfm_total,
        CASE 
            WHEN (r_score + f_score + m_score) >= 10 THEN 'Champions'
            WHEN (r_score + f_score + m_score) >= 8  THEN 'Loyal'
            WHEN (r_score + f_score + m_score) >= 6  THEN 'Potential Loyalists'
            WHEN (r_score + f_score + m_score) >= 4  THEN 'At Risk'
            ELSE 'Lost'
        END AS rfm_segment
    FROM rfm_base
)
SELECT 
    rfm_segment,
    COUNT(*) AS customers,
    ROUND(AVG(Churn) * 100, 1) AS churn_rate_pct,
    ROUND(AVG(CashbackAmount), 0) AS avg_cashback,
    ROUND(AVG(OrderCount), 1) AS avg_orders,
    ROUND(AVG(rfm_total), 1) AS avg_rfm_score
FROM rfm_scored
GROUP BY rfm_segment
ORDER BY avg_rfm_score DESC;


-- ================================================================
-- QUERY 7: PRODUCT CATEGORY CHURN ANALYSIS
-- Business Question: Which categories are bleeding customers?
-- ================================================================
SELECT 
    PreferedOrderCat AS product_category,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(CashbackAmount), 0) AS avg_spend,
    ROUND(AVG(SatisfactionScore), 2) AS avg_satisfaction,
    -- Revenue at risk
    ROUND(SUM(Churn) * AVG(CashbackAmount) * 12, 0) AS revenue_at_risk
FROM ecommerce_customers
GROUP BY PreferedOrderCat
ORDER BY churn_rate_pct DESC;


-- ================================================================
-- QUERY 8: COMPLAINT PARADOX ANALYSIS
-- Business Question: Do customers who complained churn more or less?
-- ================================================================
SELECT 
    Complain AS has_complained,
    COUNT(*) AS customers,
    ROUND(AVG(Churn) * 100, 2) AS churn_rate_pct,
    ROUND(AVG(SatisfactionScore), 2) AS avg_satisfaction,
    ROUND(AVG(CashbackAmount), 0) AS avg_spend,
    -- The paradox: resolved complaints create loyalty
    CASE 
        WHEN Complain = 1 AND AVG(Churn) < 
            (SELECT AVG(Churn) FROM ecommerce_customers WHERE Complain = 0)
        THEN '✅ Complaint Paradox: Complainers more loyal!'
        ELSE 'Complainers churn more'
    END AS insight
FROM ecommerce_customers
GROUP BY Complain;


-- ================================================================
-- QUERY 9: MONTHLY CHURN COHORT SIMULATION (Using Tenure)
-- Business Question: When in the customer lifecycle is churn highest?
-- ================================================================
SELECT 
    tenure_group,
    total_customers,
    churned_customers,
    churn_rate_pct,
    -- Cumulative churn
    SUM(churned_customers) OVER (ORDER BY tenure_order ROWS UNBOUNDED PRECEDING) AS cumulative_churned,
    ROUND(
        SUM(churned_customers) OVER (ORDER BY tenure_order ROWS UNBOUNDED PRECEDING) * 100.0
        / SUM(total_customers) OVER (), 1
    ) AS cumulative_churn_pct
FROM (
    SELECT 
        CASE 
            WHEN Tenure BETWEEN 0  AND 3  THEN '0-3 months'
            WHEN Tenure BETWEEN 4  AND 6  THEN '4-6 months'
            WHEN Tenure BETWEEN 7  AND 12 THEN '7-12 months'
            WHEN Tenure BETWEEN 13 AND 24 THEN '13-24 months'
            ELSE '24+ months'
        END AS tenure_group,
        CASE 
            WHEN Tenure BETWEEN 0  AND 3  THEN 1
            WHEN Tenure BETWEEN 4  AND 6  THEN 2
            WHEN Tenure BETWEEN 7  AND 12 THEN 3
            WHEN Tenure BETWEEN 13 AND 24 THEN 4
            ELSE 5
        END AS tenure_order,
        COUNT(*) AS total_customers,
        SUM(Churn) AS churned_customers,
        ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) AS churn_rate_pct
    FROM ecommerce_customers
    GROUP BY tenure_group, tenure_order
) t
ORDER BY tenure_order;


-- ================================================================
-- QUERY 10: AT-RISK CUSTOMERS — PRIORITIZED TARGET LIST
-- Business Question: Give me the exact list of customers to target RIGHT NOW
-- ================================================================
SELECT 
    CustomerID,
    DaySinceLastOrder,
    OrderCount,
    CashbackAmount,
    PreferredLoginDevice,
    CityTier,
    SatisfactionScore,
    -- Priority score: higher = more urgent to target
    ROUND(
        (DaySinceLastOrder * 0.4) +
        ((5 - SatisfactionScore) * 10 * 0.3) +
        (CityTier * 5 * 0.3),
    1) AS retention_priority_score,
    -- Estimated value if retained
    ROUND(CashbackAmount * 12, 0) AS estimated_annual_value,
    'SEND RETENTION OFFER' AS recommended_action
FROM ecommerce_customers
WHERE 
    Churn = 0  -- Not yet churned (still saveable)
    AND DaySinceLastOrder >= 25  -- Approaching danger zone
    AND SatisfactionScore <= 3  -- Low satisfaction
ORDER BY retention_priority_score DESC
LIMIT 50;


-- ================================================================
-- QUERY 11: PAYMENT METHOD CHURN ANALYSIS
-- Business Question: Does payment preference signal churn risk?
-- ================================================================
SELECT 
    PreferredPaymentMode,
    COUNT(*) AS customers,
    ROUND(AVG(Churn) * 100, 1) AS churn_rate_pct,
    ROUND(AVG(CashbackAmount), 0) AS avg_spend,
    ROUND(AVG(OrderCount), 1) AS avg_orders,
    -- Flag high-churn payment methods
    CASE WHEN AVG(Churn) > 0.25 THEN '⚠️ High Churn' ELSE '✅ Normal' END AS risk_flag
FROM ecommerce_customers
GROUP BY PreferredPaymentMode
ORDER BY churn_rate_pct DESC;


-- ================================================================
-- QUERY 12: DEVICE REGISTRATION VS CHURN (Engagement Signal)
-- Business Question: Does registering more devices mean higher retention?
-- ================================================================
SELECT 
    NumberOfDeviceRegistered,
    COUNT(*) AS customers,
    ROUND(AVG(Churn) * 100, 1) AS churn_rate_pct,
    ROUND(AVG(HourSpendOnApp), 2) AS avg_app_hours,
    ROUND(AVG(OrderCount), 1) AS avg_orders
FROM ecommerce_customers
GROUP BY NumberOfDeviceRegistered
ORDER BY NumberOfDeviceRegistered;


-- ================================================================
-- QUERY 13: HIGH-VALUE CHURNED CUSTOMERS — WINBACK LIST
-- Business Question: Who left that we should try to win back?
-- ================================================================
SELECT 
    CustomerID,
    CashbackAmount,
    ROUND(CashbackAmount * 12, 0) AS estimated_annual_value,
    Tenure,
    OrderCount,
    DaySinceLastOrder,
    PreferredLoginDevice,
    PreferedOrderCat,
    -- Winback priority: recent high-value churners are most recoverable
    CASE 
        WHEN CashbackAmount > 250 AND DaySinceLastOrder <= 30 THEN 'Priority 1 — Immediate Winback'
        WHEN CashbackAmount > 200 AND DaySinceLastOrder <= 60 THEN 'Priority 2 — High Value Winback'
        WHEN CashbackAmount > 150 THEN 'Priority 3 — Standard Winback'
        ELSE 'Low Priority'
    END AS winback_priority
FROM ecommerce_customers
WHERE Churn = 1
ORDER BY CashbackAmount DESC, DaySinceLastOrder ASC
LIMIT 100;


-- ================================================================
-- QUERY 14: SATISFACTION SCORE DISTRIBUTION BY CHURN
-- Business Question: What satisfaction score predicts churn?
-- ================================================================
SELECT 
    SatisfactionScore,
    COUNT(*) AS total_customers,
    SUM(Churn) AS churned,
    ROUND(SUM(Churn) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    -- Visual bar representation
    RPAD('', ROUND(SUM(Churn) * 100.0 / COUNT(*), 0), '█') AS churn_visual
FROM ecommerce_customers
GROUP BY SatisfactionScore
ORDER BY SatisfactionScore;


-- ================================================================
-- QUERY 15: EXECUTIVE DASHBOARD SUMMARY
-- Business Question: Give me the top-line numbers for the board meeting
-- ================================================================
SELECT 
    'Total Customers' AS metric, CAST(COUNT(*) AS CHAR) AS value FROM ecommerce_customers
UNION ALL
SELECT 'Churned Customers', CAST(SUM(Churn) AS CHAR) FROM ecommerce_customers
UNION ALL
SELECT 'Churn Rate', CONCAT(ROUND(AVG(Churn)*100, 1), '%') FROM ecommerce_customers
UNION ALL
SELECT 'At-Risk Customers (30+ days inactive)', 
    CAST(COUNT(CASE WHEN DaySinceLastOrder >= 30 AND Churn = 0 THEN 1 END) AS CHAR) FROM ecommerce_customers
UNION ALL
SELECT 'Avg Annual Customer Value', 
    CONCAT('Rs.', ROUND(AVG(CashbackAmount)*12, 0)) FROM ecommerce_customers
UNION ALL
SELECT 'Total Revenue at Risk', 
    CONCAT('Rs.', ROUND(SUM(CASE WHEN Churn=1 THEN CashbackAmount*12 ELSE 0 END), 0)) FROM ecommerce_customers
UNION ALL
SELECT 'Highest Churn Segment', 'Mobile App Users (38%)' AS value FROM DUAL
UNION ALL
SELECT 'Recommended Recovery Target', 'Rs.841,000 (3 campaigns)' AS value FROM DUAL;


-- ================================================================
-- END OF QUERIES
-- See notebooks/churn_analysis.ipynb for full Python analysis
-- See dashboard/app.py for interactive Streamlit dashboard
-- ================================================================
