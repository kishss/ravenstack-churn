# RavenStack Churn Analysis

I built this project to answer a question that matters to any SaaS business: does it matter *where* your customers come from, or do they all behave the same once they sign up?

The short answer — it matters a lot.

---

**The question**

Which acquisition channels bring customers who stay, and which bring customers who churn? And what should that mean for how a SaaS company allocates its marketing budget?

**The dataset**

RavenStack is a fictional AI-powered collaboration platform — a simulated SaaS business with five related tables covering 500 accounts, their subscription history, daily feature usage, support tickets, and churn events. The data was downloaded from Kaggle and loaded into PostgreSQL for analysis.

The raw data files are not stored in this repo. Download them from the Kaggle dataset and place the CSVs in a local `data/` folder.

**What I found**

Partner-referred customers churn at 14.6%. Event-sourced customers churn at 30.2% — more than double the rate. Organic sits comfortably in the middle at 17.5%.

| Channel | Customers | Churn Rate |
|---------|-----------|------------|
| Partner | 89 | 14.6% |
| Organic | 114 | 17.5% |
| Ads | 98 | 23.5% |
| Other | 103 | 24.3% |
| Event | 96 | 30.2% |

A chi-square test returned a p-value of 0.079 — just above the conventional 0.05 threshold. The pattern is directionally meaningful, but with ~90–100 customers per channel the sample is small. A larger dataset would likely confirm statistical significance. I'd treat this as strong enough to investigate further, not strong enough to reallocate budgets on its own.

**What it means**

A customer who stays twice as long is worth twice as much, regardless of acquisition cost. If partner-referred customers genuinely retain better, the question isn't just "which channel is cheapest?" but "which channel produces the most lifetime value?" This analysis is the first step toward answering that.

The practical recommendation: run a deeper analysis once more data is available, and consider whether event-sourced customers need different onboarding — they may be signing up impulsively at conferences without a strong enough reason to stay.

**How it was built**

The data lives in PostgreSQL. SQL handles the joining, aggregating, and building of the analytical base table. Python (pandas, matplotlib, scipy) handles the visualisation and significance testing. The notebook walks through the full analysis from raw query to chart to test result.

To run it yourself — load the CSVs into PostgreSQL using `sql/01_create_tables.sql`, then run the queries in order, then open the notebook in `analysis/`.

**Stack:** PostgreSQL · Python · pandas · matplotlib · scipy · Jupyter · GitHub

**Status:** SQL analysis and Python visualisation complete. Streamlit dashboard in progress.
