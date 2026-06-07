-- ============================================================
-- RavenStack  |  02 - churn rate by acquisition channel
-- Question: which referral sources bring customers who STAY?
-- ============================================================

-- Q1: how many customers came from each channel?
SELECT referral_source,
       COUNT(*) AS customers
FROM accounts
GROUP BY referral_source
ORDER BY customers DESC;

-- Q2: churn rate per channel (the headline)
--   CASE WHEN ... 1 ELSE 0  -> 1 for churned customers, 0 otherwise
--   SUM(...)                -> counts the churned customers in each group
--   100.0 (with the dot)    -> forces decimal division, not integer division
SELECT
    referral_source,
    COUNT(*)                                    AS customers,
    SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) AS churned,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS churn_rate_pct
FROM accounts
GROUP BY referral_source
ORDER BY churn_rate_pct DESC;

-- Result (RavenStack):
--   partner 14.6%  | organic 17.5%  | ads 23.5%  | other 24.3%  | event 30.2%
--   -> partner & organic retain best; event churns at ~2x partner.
