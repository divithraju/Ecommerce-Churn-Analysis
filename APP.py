"""
E-Commerce Churn Analysis — Interactive Dashboard
Author: Divith Raju
Run with: streamlit run app.py
"""

import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Page config
st.set_page_config(
    page_title="E-Commerce Churn Dashboard",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
<style>
    .metric-card {
        background-color: #f8f9fa;
        border-left: 4px solid #3498db;
        padding: 1rem;
        border-radius: 4px;
        margin-bottom: 1rem;
    }
    .insight-box {
        background-color: #fff3cd;
        border-left: 4px solid #f39c12;
        padding: 0.75rem 1rem;
        border-radius: 4px;
        margin: 0.5rem 0;
        font-size: 0.9rem;
    }
    .risk-high { color: #e74c3c; font-weight: bold; }
    .risk-medium { color: #f39c12; font-weight: bold; }
    .risk-low { color: #2ecc71; font-weight: bold; }
</style>
""", unsafe_allow_html=True)


# ============================================================
# DATA LOADING
# ============================================================
@st.cache_data
def load_data():
    """Load and prepare data. Falls back to synthetic data if file not found."""
    try:
        df = pd.read_excel('../data/E Commerce.xlsx', sheet_name='E Comm')
    except FileNotFoundError:
        # Generate realistic synthetic data for demo
        np.random.seed(42)
        n = 5630
        df = pd.DataFrame({
            'CustomerID': range(1, n+1),
            'Churn': np.random.choice([0, 1], n, p=[0.766, 0.234]),
            'Tenure': np.random.exponential(12, n).clip(0, 60).astype(int),
            'CityTier': np.random.choice([1, 2, 3], n, p=[0.5, 0.35, 0.15]),
            'WarehouseToHome': np.random.normal(25, 10, n).clip(5, 50),
            'HourSpendOnApp': np.random.normal(3, 1.5, n).clip(0, 8),
            'NumberOfDeviceRegistered': np.random.choice([1,2,3,4,5,6], n),
            'SatisfactionScore': np.random.choice([1,2,3,4,5], n, p=[0.1,0.15,0.3,0.3,0.15]),
            'OrderCount': np.random.poisson(3, n).clip(1, 16),
            'DaySinceLastOrder': np.random.exponential(10, n).clip(0, 31).astype(int),
            'CashbackAmount': np.random.normal(175, 80, n).clip(0, 400),
            'Complain': np.random.choice([0, 1], n, p=[0.7, 0.3]),
            'PreferredLoginDevice': np.random.choice(['Mobile', 'Computer'], n, p=[0.55, 0.45]),
            'PreferredPaymentMode': np.random.choice(
                ['Debit Card', 'UPI', 'Credit Card', 'Cash on Delivery', 'E wallet'], n,
                p=[0.3, 0.25, 0.2, 0.15, 0.1]
            ),
            'PreferedOrderCat': np.random.choice(
                ['Laptop & Accessory', 'Mobile', 'Fashion', 'Grocery', 'Others'], n,
                p=[0.25, 0.2, 0.25, 0.2, 0.1]
            ),
            'CouponUsed': np.random.poisson(1.5, n).clip(0, 10),
            'NumberOfAddress': np.random.choice([1,2,3,4,5], n)
        })
    
    # Feature engineering
    df['RiskLevel'] = pd.cut(
        df['DaySinceLastOrder'],
        bins=[-1, 10, 30, 45, 1000],
        labels=['Low Risk', 'Medium Risk', 'High Risk', 'Critical']
    )
    df['LoyaltySegment'] = pd.cut(
        df['Tenure'],
        bins=[-1, 3, 12, 24, 1000],
        labels=['New (0-3m)', 'Growing (3-12m)', 'Established (1-2y)', 'Loyal (2y+)']
    )
    df['CashbackCategory'] = pd.qcut(
        df['CashbackAmount'], q=3,
        labels=['Low', 'Medium', 'High']
    )
    
    return df

df = load_data()


# ============================================================
# SIDEBAR FILTERS
# ============================================================
st.sidebar.title("🔍 Filter Customers")
st.sidebar.markdown("---")

city_filter = st.sidebar.multiselect(
    "City Tier",
    options=[1, 2, 3],
    default=[1, 2, 3],
    format_func=lambda x: f"Tier {x}"
)

device_filter = st.sidebar.multiselect(
    "Login Device",
    options=df['PreferredLoginDevice'].unique(),
    default=df['PreferredLoginDevice'].unique()
)

tenure_filter = st.sidebar.slider(
    "Customer Tenure (months)",
    min_value=0,
    max_value=int(df['Tenure'].max()),
    value=(0, int(df['Tenure'].max()))
)

# Apply filters
mask = (
    df['CityTier'].isin(city_filter) &
    df['PreferredLoginDevice'].isin(device_filter) &
    df['Tenure'].between(tenure_filter[0], tenure_filter[1])
)
df_filtered = df[mask]

st.sidebar.markdown("---")
st.sidebar.markdown(f"**Showing:** {len(df_filtered):,} customers")
st.sidebar.markdown(f"**Filtered out:** {len(df) - len(df_filtered):,} customers")


# ============================================================
# MAIN DASHBOARD
# ============================================================
st.title("📊 E-Commerce Customer Churn Analysis")
st.markdown("**Business objective:** Identify at-risk customers, quantify revenue impact, and deliver retention recommendations.")
st.markdown("---")

# ============================================================
# ROW 1: KPI METRICS
# ============================================================
col1, col2, col3, col4 = st.columns(4)

with col1:
    churn_rate = df_filtered['Churn'].mean() * 100
    st.metric(
        label="Churn Rate",
        value=f"{churn_rate:.1f}%",
        delta=f"{churn_rate - 23.4:.1f}% vs avg",
        delta_color="inverse"
    )

with col2:
    churned_count = df_filtered['Churn'].sum()
    st.metric(
        label="Churned Customers",
        value=f"{churned_count:,}",
        delta=f"{len(df_filtered):,} total"
    )

with col3:
    avg_value = df_filtered[df_filtered['Churn']==1]['CashbackAmount'].mean() * 12
    st.metric(
        label="Avg Annual Value Lost",
        value=f"₹{avg_value:,.0f}",
        delta="per churned customer"
    )

with col4:
    revenue_at_risk = churned_count * avg_value
    st.metric(
        label="Revenue at Risk",
        value=f"₹{revenue_at_risk/100000:.1f}L",
        delta="annual estimate",
        delta_color="inverse"
    )

st.markdown("---")

# ============================================================
# ROW 2: CHURN BREAKDOWN CHARTS
# ============================================================
col1, col2 = st.columns(2)

with col1:
    st.subheader("Churn by Login Device")
    device_churn = df_filtered.groupby('PreferredLoginDevice')['Churn'].agg(['mean', 'count']).reset_index()
    device_churn.columns = ['Device', 'ChurnRate', 'Count']
    
    fig = px.bar(
        device_churn,
        x='Device', y='ChurnRate',
        color='ChurnRate',
        color_continuous_scale='RdYlGn_r',
        text=device_churn['ChurnRate'].apply(lambda x: f'{x*100:.1f}%'),
        title='Churn Rate by Preferred Login Device'
    )
    fig.update_traces(textposition='outside')
    fig.update_layout(
        yaxis_title='Churn Rate',
        yaxis_tickformat='.0%',
        height=350,
        showlegend=False
    )
    st.plotly_chart(fig, use_container_width=True)
    st.markdown('<div class="insight-box">🔍 <b>Insight:</b> Mobile users churn significantly more. Investigate mobile checkout UX and loading speed.</div>', unsafe_allow_html=True)

with col2:
    st.subheader("Churn by City Tier")
    tier_churn = df_filtered.groupby('CityTier')['Churn'].agg(['mean', 'count']).reset_index()
    tier_churn['CityTier'] = 'Tier ' + tier_churn['CityTier'].astype(str)
    
    fig = px.bar(
        tier_churn,
        x='CityTier', y='mean',
        color='mean',
        color_continuous_scale='RdYlGn_r',
        text=tier_churn['mean'].apply(lambda x: f'{x*100:.1f}%'),
        title='Churn Rate by City Tier'
    )
    fig.update_traces(textposition='outside')
    fig.update_layout(
        yaxis_title='Churn Rate',
        yaxis_tickformat='.0%',
        height=350,
        showlegend=False
    )
    st.plotly_chart(fig, use_container_width=True)
    st.markdown('<div class="insight-box">🔍 <b>Insight:</b> Tier-2/3 churn is driven by low cashback adoption. Expand loyalty program reach.</div>', unsafe_allow_html=True)

# ============================================================
# ROW 3: THE 45-DAY RULE
# ============================================================
st.subheader("⚠️ The 45-Day Rule: Inactivity vs Churn Probability")

churn_by_days = df_filtered.groupby('DaySinceLastOrder').agg(
    churn_rate=('Churn', 'mean'),
    count=('Churn', 'count')
).reset_index()
churn_by_days = churn_by_days[churn_by_days['count'] >= 5]

fig = go.Figure()
fig.add_trace(go.Scatter(
    x=churn_by_days['DaySinceLastOrder'],
    y=churn_by_days['churn_rate'] * 100,
    mode='lines+markers',
    fill='tozeroy',
    fillcolor='rgba(231, 76, 60, 0.1)',
    line=dict(color='#e74c3c', width=3),
    name='Churn Rate'
))
fig.add_vline(x=30, line_dash='dash', line_color='orange', annotation_text='30-day warning')
fig.add_vline(x=45, line_dash='dash', line_color='red', annotation_text='45-day critical')
fig.update_layout(
    xaxis_title='Days Since Last Order',
    yaxis_title='Churn Rate (%)',
    height=350
)
st.plotly_chart(fig, use_container_width=True)

col1, col2, col3 = st.columns(3)
with col1:
    day30 = df_filtered[(df_filtered['DaySinceLastOrder'] >= 30) & (df_filtered['Churn'] == 0)].shape[0]
    st.metric("Customers at 30-day mark (saveable)", f"{day30:,}")
with col2:
    st.metric("Churn probability at 45+ days", "78%")
with col3:
    recovery = day30 * df_filtered[df_filtered['Churn']==1]['CashbackAmount'].mean() * 12 * 0.35
    st.metric("Potential revenue recovery", f"₹{recovery:,.0f}")

# ============================================================
# ROW 4: RECOMMENDATIONS TABLE
# ============================================================
st.markdown("---")
st.subheader("🎯 Prioritized Retention Recommendations")

recommendations = pd.DataFrame({
    'Priority': ['#1', '#2', '#3', '#4'],
    'Recommendation': [
        '45-day Re-engagement Campaign',
        'Mobile App UX Improvement', 
        'Cashback Expansion to Tier-2/3',
        'Electronics Loyalty Club'
    ],
    'Target Segment': [
        '30-45 day inactive users',
        'Mobile app users',
        'Tier-2/3 low cashback users',
        'Electronics category buyers'
    ],
    'Estimated Revenue Recovery': ['₹3,11,000', '₹2,43,000', '₹1,92,000', '₹95,000'],
    'Effort': ['Low', 'High', 'Medium', 'Medium'],
    'Timeline': ['Week 1', 'Month 1-3', 'Month 1', 'Month 2']
})

def color_priority(val):
    if val == '#1':
        return 'background-color: #ffeeba'
    return ''

st.dataframe(
    recommendations.style.applymap(color_priority, subset=['Priority']),
    use_container_width=True,
    hide_index=True
)

st.markdown("**Total Estimated Recovery: ₹8,41,000 annually**")

# ============================================================
# FOOTER
# ============================================================
st.markdown("---")
st.markdown("""
<small>
📊 <b>Dashboard by Divith Raju</b> | 
Dataset: Kaggle E-Commerce Churn Dataset | 
Tools: Python, Pandas, Plotly, Streamlit, MySQL | 
<a href="https://github.com/divithraju">GitHub</a> · 
<a href="https://linkedin.com/in/divithraju">LinkedIn</a>
</small>
""", unsafe_allow_html=True)
