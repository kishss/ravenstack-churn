# RavenStack — Predicting SaaS Churn from Early Activation Behavior

**Which actions a customer takes in their first weeks predict whether they stay or churn — and what onboarding should do about it.**

A self-directed data analysis project on a simulated B2B SaaS business, built to practice the full workflow: SQL data modeling in PostgreSQL, analysis and modeling in Python, and an interactive dashboard.

---

## The question

In SaaS, keeping a customer is far cheaper than winning a new one, so retention is existential. This project asks one business question:

> Which behaviors during a customer's first weeks predict whether they ultimately churn — and what should the company change about onboarding as a result?

The goal isn't just to *predict* churn, but to find the **"aha moment"** — an early-behavior threshold the business can act on — and quantify the payoff of moving more customers past it.

## The data

RavenStack is a fictional AI-powered collaboration platform — a simulated SaaS business spanning five related CSV files (~500 accounts):

| File | Grain | Role |
|------|-------|------|
| `accounts` | one row per customer | metadata + the churn label |
| `subscriptions` | one row per subscription change | signup clock, plan, MRR (the bridge to usage) |
| `feature_usage` | daily product logs | the early-behavior signal |
| `churn_events` | one row per churn event | churn reason, date, reactivations |
| `support_tickets` | one row per ticket | support experience (a secondary churn driver) |

The raw data is **not** stored in this repo. Download it separately and place the CSVs in a local `data/` folder (which is gitignored).

> **Dataset source:** _paste the Kaggle dataset URL you downloaded from here._

### Key data decisions
- **Churn label:** `accounts.churn_flag` (the customer-level "did they ultimately leave" signal). `churn_events` is used for the *reason* and *timing* only — the two sources deliberately disagree, and reconciling them is documented in the analysis.
- **Join path:** `feature_usage` has no `account_id`; it joins to a customer via `subscriptions` (`feature_usage -> subscriptions -> accounts`).
- **Subscription grain:** each account has ~10 subscription rows (a change history), so MRR is taken from the latest row, never summed across rows.
- **Activation window:** early behavior is measured relative to `accounts.signup_date`.

## Approach

| Stage | Tool | Output |
|-------|------|--------|
| Load & explore | SQL (PostgreSQL) | 5 tables loaded, EDA queries |
| Build the analytical base table | SQL | `account_features` — one row per account, early-behavior columns + churn label |
| Compare & test | Python (pandas, scipy) | churned vs retained, significance tests |
| Find the threshold & model | Python (scikit-learn) | activation threshold + interpretable churn model |
| Visualize | Python / Streamlit | interactive dashboard |
| Quantify impact | — | estimated retention lift from improving activation |

## Tech stack

PostgreSQL · Python (pandas, scikit-learn, matplotlib/seaborn) · Streamlit · Git / GitHub

## Project structure

```
ravenstack-churn/
├── README.md
├── .gitignore
├── sql/
│   └── 01_create_and_load.sql      # schema + load
├── analysis/                        # Python notebooks / scripts
├── dashboard/                       # Streamlit app
└── data/                            # raw CSVs (gitignored — download separately)
```

## How to run

*(Fleshed out as the project develops.)*

1. Download the dataset and put the CSVs in `data/`.
2. Create a PostgreSQL database, then from the `data/` folder run the load script:
   `psql -d your_db -f ../sql/01_create_and_load.sql`
3. *Analysis and dashboard steps — coming soon.*

## Findings

*Coming soon — the headline insight, key chart, and recommended action will live here.*

## Progress

- [x] Define the business question
- [x] Explore the data and lock key modeling decisions
- [x] Load the data into PostgreSQL
- [ ] Build the `account_features` table
- [ ] Churn EDA (rate, segments, cohorts)
- [ ] Compare churned vs retained + significance tests
- [ ] Find the activation threshold
- [ ] Build the churn model
- [ ] Streamlit dashboard
- [ ] Write up findings + quantify impact
