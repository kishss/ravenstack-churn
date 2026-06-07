import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

st.title('RavenStack — Churn by Acquisition Channel')
st.write('Which channels bring customers who stay, and which bring customers who churn?')

# Analysis results from PostgreSQL
data = {
    'referral_source': ['partner', 'organic', 'ads', 'other', 'event'],
    'customers': [89, 114, 98, 103, 96],
    'churned': [13, 20, 23, 25, 29],
    'churn_rate_pct': [14.6, 17.5, 23.5, 24.3, 30.2]
}
df = pd.DataFrame(data)
selected = st.multiselect(
    'Select channels to compare:',
    options=df['referral_source'].tolist(),
    default=df['referral_source'].tolist()
)

df = df[df['referral_source'].isin(selected)]
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

st.subheader('Key Finding')
st.write('Partner-referred customers churn at 14.6% — less than half the rate of event-sourced customers at 30.2%.')

st.subheader('Data')
st.dataframe(df)
