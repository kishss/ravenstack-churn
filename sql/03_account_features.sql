-- ============================================================
-- RavenStack  |  03 - account_features table
-- One row per account with first-30-day engagement + churn label
--
-- Anchor: each account's first actual usage date (not signup_date,
-- because signup timestamps are noisy in this dataset).
-- INTERVAL '30 days' captures the first month of real product activity.
-- ============================================================

DROP TABLE IF EXISTS account_features;

CREATE TABLE account_features AS

-- CTE 1: find the earliest usage date per account (our "day zero")
WITH first_use AS (
    SELECT s.account_id,
           MIN(f.usage_date) AS first_use_date
    FROM feature_usage f
    JOIN subscriptions s ON s.subscription_id = f.subscription_id
    GROUP BY s.account_id
),

-- CTE 2: sum up what each account did in their first 30 days of activity
month1 AS (
    SELECT
        s.account_id,
        COUNT(*)                        AS usage_events,
        COUNT(DISTINCT f.usage_date)    AS active_days,
        COUNT(DISTINCT f.feature_name)  AS distinct_features,
        SUM(f.usage_count)              AS total_actions,
        SUM(f.error_count)              AS total_errors
    FROM feature_usage f
    JOIN subscriptions s ON s.subscription_id = f.subscription_id
    JOIN first_use fu    ON fu.account_id = s.account_id
    WHERE f.usage_date BETWEEN fu.first_use_date
                           AND fu.first_use_date + INTERVAL '30 days'
    GROUP BY s.account_id
)

-- Final: one row per account with context + engagement + churn label
SELECT
    a.account_id,
    a.referral_source,
    a.plan_tier,
    a.industry,
    a.seats,
    a.churn_flag,
    -- engagement features (0 for accounts with no usage)
    COALESCE(m.usage_events,      0) AS usage_events,
    COALESCE(m.active_days,       0) AS active_days,
    COALESCE(m.distinct_features, 0) AS distinct_features,
    COALESCE(m.total_actions,     0) AS total_actions,
    COALESCE(m.total_errors,      0) AS total_errors
FROM accounts a
LEFT JOIN month1 m ON m.account_id = a.account_id;

-- Sanity check: should be 500 rows
SELECT COUNT(*) AS total_accounts FROM account_features;

-- Quick look at the channel story
SELECT
    referral_source,
    COUNT(*)                                    AS customers,
    SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) AS churned,
    ROUND(100.0 * SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_pct,
    ROUND(AVG(usage_events), 1)                 AS avg_usage_events,
    ROUND(AVG(distinct_features), 1)            AS avg_features_used
FROM account_features
GROUP BY referral_source
ORDER BY churn_pct;
