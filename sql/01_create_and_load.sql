-- ============================================================
-- RavenStack SaaS analytics  |  01 - schema + load
-- Activation -> churn project
--
-- HOW TO RUN:
--   1. Put this file in the same folder as the 5 CSVs.
--   2. From that folder, connect with psql:  psql -d your_db_name
--   3. Run:  \i 01_create_and_load.sql
--   (\copy reads files relative to the folder psql was launched from,
--    so launching psql from the CSV folder means no full paths needed.)
-- ============================================================

-- Re-runnable: drop children before parents (FK order)
DROP TABLE IF EXISTS feature_usage;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS churn_events;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS accounts;

-- ---------- accounts : one row per customer (the hub) ----------
CREATE TABLE accounts (
    account_id       TEXT PRIMARY KEY,
    account_name     TEXT,
    industry         TEXT,
    country          TEXT,
    signup_date      DATE,
    referral_source  TEXT,
    plan_tier        TEXT,
    seats            INTEGER,
    is_trial         BOOLEAN,
    churn_flag       BOOLEAN     -- our prediction label: did they ultimately leave
);

-- ---------- subscriptions : lifecycle, ~10 rows per account ----------
CREATE TABLE subscriptions (
    subscription_id    TEXT PRIMARY KEY,
    account_id         TEXT REFERENCES accounts(account_id),
    start_date         DATE,
    end_date           DATE,        -- NULL = still open / active
    plan_tier          TEXT,
    seats              INTEGER,
    mrr_amount         INTEGER,     -- 0 for trial rows
    arr_amount         INTEGER,
    is_trial           BOOLEAN,
    upgrade_flag       BOOLEAN,
    downgrade_flag     BOOLEAN,
    churn_flag         BOOLEAN,
    billing_frequency  TEXT,
    auto_renew_flag    BOOLEAN
);

-- ---------- feature_usage : daily product logs (our behavior signal) ----------
-- NOTE: links to subscription_id, NOT account_id. Join via subscriptions.
CREATE TABLE feature_usage (
    usage_id             TEXT PRIMARY KEY,
    subscription_id      TEXT REFERENCES subscriptions(subscription_id),
    usage_date           DATE,
    feature_name         TEXT,
    usage_count          INTEGER,
    usage_duration_secs  INTEGER,
    error_count          INTEGER,
    is_beta_feature      BOOLEAN
);

-- ---------- churn_events : reasons, timing, reactivations ----------
CREATE TABLE churn_events (
    churn_event_id            TEXT PRIMARY KEY,
    account_id                TEXT REFERENCES accounts(account_id),
    churn_date                DATE,
    reason_code               TEXT,
    refund_amount_usd         NUMERIC(10,2),
    preceding_upgrade_flag    BOOLEAN,
    preceding_downgrade_flag  BOOLEAN,
    is_reactivation           BOOLEAN,
    feedback_text             TEXT          -- NULL when no feedback given
);

-- ---------- support_tickets : support activity + CSAT (bonus driver) ----------
CREATE TABLE support_tickets (
    ticket_id                    TEXT PRIMARY KEY,
    account_id                   TEXT REFERENCES accounts(account_id),
    submitted_at                 TIMESTAMP,
    closed_at                    TIMESTAMP,
    resolution_time_hours        NUMERIC,
    priority                     TEXT,
    first_response_time_minutes  INTEGER,
    satisfaction_score           NUMERIC(3,1),  -- 3.0-5.0, ~59% NULL
    escalation_flag              BOOLEAN
);

-- ============================================================
-- LOAD  (parents first so foreign keys resolve)
-- ============================================================
\copy accounts        FROM 'ravenstack_accounts.csv'        WITH (FORMAT csv, HEADER true)
\copy subscriptions   FROM 'ravenstack_subscriptions.csv'   WITH (FORMAT csv, HEADER true)
\copy feature_usage   FROM 'ravenstack_feature_usage.csv'   WITH (FORMAT csv, HEADER true)
\copy churn_events    FROM 'ravenstack_churn_events.csv'    WITH (FORMAT csv, HEADER true)
\copy support_tickets FROM 'ravenstack_support_tickets.csv' WITH (FORMAT csv, HEADER true)

-- ============================================================
-- SANITY CHECKS  (expected: 500 / 5000 / 25000 / 600 / 2000)
-- ============================================================
SELECT 'accounts'        AS table_name, COUNT(*) FROM accounts
UNION ALL SELECT 'subscriptions',   COUNT(*) FROM subscriptions
UNION ALL SELECT 'feature_usage',   COUNT(*) FROM feature_usage
UNION ALL SELECT 'churn_events',    COUNT(*) FROM churn_events
UNION ALL SELECT 'support_tickets', COUNT(*) FROM support_tickets;
