import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
from sqlalchemy import create_engine

# Connect to database
engine = create_engine('postgresql://postgres:6890@localhost:5432/ravenstackk')

# Page title
st.title('RavenStack — Churn by Acquisition Channel')
st.write('Which channels bring customers who stay, and which bring customers who churn?')

# Pull data
query = """
SELECT
    referral_source,
    COUNT(*) AS customers,
    SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) AS churned,
    ROUND(100.0 * SUM(CASE WHEN churn_flag THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_rate_pct
FROM accounts
GROUP BY referral_source
ORDER BY churn_rate_pct
"""
df = pd.read_sql(query, engine)

# Chart
colors = ['#2ecc71' if x < 20 else '#e74c3c' if x > 25 else '#f39c12'
          for x in df['churn_rate_pct']]

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.bar(df['referral_source'], df['churn_rate_pct'], color=colors)

for bar, val in zip(bars, df['churn_rate_pct']):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
            f'{val}%', ha='center', fontweight='bold')

ax.set_title('Churn Rate by Acquisition Channel', fontsize=14, fontweight='bold')
ax.set_xlabel('Acquisition Channel')
ax.set_ylabel('Churn Rate (%)')
ax.set_ylim(0, 35)
plt.tight_layout()
st.pyplot(fig)

# Key finding
st.subheader('Key Finding')
st.write('Partner-referred customers churn at 14.6% — less than half the rate of event-sourced customers at 30.2%.')

# Raw data table
st.subheader('Data')
st.dataframe(df)
