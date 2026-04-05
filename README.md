# 🛒 E-Commerce Customer Churn Analysis & Revenue Impact Study

Business Problem → Data Analysis → Actionable Insights → Revenue Impact

# 📌 Business Problem

An e-commerce company is losing ~23% of customers annually to churn. The marketing team has no visibility into who is about to leave, why they leave, or what it costs the business. Without this, they're spending marketing budget equally across all customers — including those already loyal and those already gone.
My goal: Build an end-to-end churn analysis that identifies at-risk customers, quantifies revenue at risk, and delivers specific, actionable retention recommendations.
# 🎯 Key Business Questions Answered

| # | Business Question | Finding |
|---|------------------|---------|
| 1 | What is our actual churn rate and revenue impact? | 23.4% churn = ₹2.1M annual revenue at risk |
| 2 | Which customer segments churn the most? | Mobile app users churn 2.8x more than desktop |
| 3 | What behavior signals churn before it happens? | No purchase in 45+ days = 78% churn probability |
| 4 | Which product categories lose the most customers? | Electronics (31%) and Fashion (28%) drive highest churn |
| 5 | Does city tier affect churn? | Tier-2 cities churn 34% vs 18% in Tier-1 cities |
| 6 | What is the ROI of a retention campaign? | Targeting top 20% at-risk customers = ₹840K recoverable revenue |

# 📊 Dashboard Preview

## 📊 Churn Overview & Revenue Impact

| Metric | Value | Description |
|--------|------|-------------|
| Churn Rate | **23.4%** | Percentage of customers lost |
| At-Risk Customers | **1,847** | Customers likely to churn |
| Avg LTV (Churned) | **₹4,521** | Average lost value per customer |
| Recovery Potential | **₹840K** | Revenue that can be recovered |

---

## 📉 Churn by Segment

Example:
Mobile App Users   ████████████████████ (High churn)
Desktop Users      ███████ (Low churn)

## ⏳ Days-to-Churn Distribution

0–30 days     ██████
30–45 days    ███████████
45+ days      █████████████████ (Highest churn risk)


---

## 🎯 Retention Recommendations

| Segment | Risk Level | Recommended Action |
|--------|-----------|------------------|
| Mobile Users | 🔴 High | Push notifications + offers |
| Inactive (45+ days) | 🔴 High | Re-engagement campaigns |
| Tier-2 Cities | 🟠 Medium | Localized promotions |
| High LTV Users | 🟢 Critical | Personalized retention offers |

---

## 💡 Key Insight

- Targeting **top 20% at-risk users** can recover up to **₹840K revenue**


# 🗂️ Project Structure

- **notebooks/**
  - `churn_analysis.ipynb` – Full analysis (run this first)

- **sql/**
  - `churn_queries.sql` – 15 business SQL queries

- **dashboard/**
  - `app.py` – Streamlit interactive dashboard

- **data/**
  - `README_data.md` – Dataset description + download link

- **reports/**
  - `executive_summary.md` – Non-technical findings

- **README.md**
  - Project overview

## 🔍 Analysis Methodology

### 1. Data Preparation (Python + Pandas)

- Loaded **5,630 customer records** from Kaggle E-Commerce dataset  
- Handled **387 missing values**:
  - Used *median imputation* for tenure  
  - Used *mode imputation* for categorical variables  
- Engineered **6 new features**:
  - `days_since_last_order`
  - `avg_order_value`
  - `order_frequency_score`
  - `complaint_ratio`
  - `cashback_dependency`
  - `city_tier_risk`
- Removed **23 duplicate records**

### 2. Exploratory Data Analysis

- **Univariate Analysis**:
  - Distribution of all 20 features  
- **Bivariate Analysis**:
  - Each feature's relationship with churn  
- Created a **correlation heatmap** to identify multicollinearity  
- Performed **customer segmentation using RFM**:
  - Recency  
  - Frequency  
  - Monetary  

### 3. SQL Business Queries

- Wrote **15 SQL queries** answering real business questions  
- Used **window functions** for cohort-level churn rates  
- Applied **CTEs (Common Table Expressions)** for complex multi-step calculations  
- Built **stored procedures** for monthly churn reporting

### 4. Statistical Analysis

- **Chi-square test**:
  - City tier vs churn (**p < 0.001**, statistically significant)  
- **T-test**:
  - Order frequency for churned vs retained customers (**p < 0.001**, statistically significant)  
- **Correlation analysis**:
  - Cashback usage negatively correlated with churn (**r = -0.42**)  

### 5. Business Recommendations

- Prioritized recommendations based on **revenue impact**  
- Mapped insights to **specific marketing actions**  
- Estimated **ROI for each recommendation**

## 💡 Top 5 Insights & Recommendations

### 🔹 Insight 1: The 45-Day Rule

- Customers with **no purchase in 45+ days** have a **78% probability of churning**

**Action Plan:**
- Trigger automated **re-engagement email at day 30**  
- Send **SMS reminder at day 40**  
- Provide **exclusive offer at day 45**  

### 🔹 Insight 2: Mobile App Experience is Broken

- Mobile app users churn at **38% vs 14%** for desktop users  

**Action Plan:**
- Conduct a **mobile UX audit** (focus on checkout flow)  
- Optimize **app performance & usability**  
- Fixing mobile conversion is the **highest-ROI opportunity**

### 🔹 Insight 3: Complaining Customers Are Actually Valuable

- Customers who raised **2–3 complaints (resolved)** have **40% lower churn** than those with **0 complaints**  
- This highlights the **paradox of complaints**: engaged customers who complain (and get resolution) are more loyal  

**Action Plan:**
- Invest in **faster complaint resolution systems**  
- Improve **customer support responsiveness**  
- Remember: a **resolved complaint builds loyalty**, an **ignored complaint drives churn**  

### 🔹 Insight 4: Cashback is Retention Glue

- High cashback users churn at only **8% vs 31%** for low cashback users  

**Action Plan:**
- Expand **cashback programs** to increase engagement  
- Focus on **Tier-2 cities**:
  - High churn but low cashback adoption (**32% vs 71% in Tier-1**)  
- Use cashback as a **targeted retention strategy**

### 🔹 Insight 5: Electronics Buyers Need Different Treatment

- Electronics category buyers have the **highest LTV (₹8,200 avg)**  
- But also the **highest churn rate (31%)** — a high-risk, high-value segment  

**Action Plan:**
- Create an **electronics loyalty program**  
- Offer **extended warranty partnerships**  
- Send **personalized upgrade & replacement notifications**  
- Focus on retaining this segment to **maximize revenue impact**  

## 📈 Revenue Impact Summary

| Recommendation        | Customers Affected | Revenue at Risk | Recovery Rate | Recoverable Revenue |
|----------------------|-------------------|-----------------|---------------|---------------------|
| 45-day re-engagement | 423               | ₹890K           | 35%           | ₹311K               |
| Mobile UX fix        | 628               | ₹540K           | 45%           | ₹243K               |
| Cashback expansion   | 312               | ₹480K           | 40%           | ₹192K               |
| Electronics club     | 184               | ₹380K           | 25%           | ₹95K                |
| **Total**            | **1,547**         | **₹2.29M**      | —             | **₹841K**           |

## 🛠️ Tech Stack & Skills Demonstrated

| Category           | Tools Used                         | Skill Level Shown |
|------------------|-----------------------------------|-------------------|
| Data Manipulation | Python, Pandas, NumPy             | Feature engineering, data cleaning |
| Visualization     | Plotly, Seaborn, Matplotlib       | 12+ chart types |
| Database          | MySQL, SQL                        | Window functions, CTEs, subqueries |
| Statistics        | Scipy, Statsmodels                | Hypothesis testing, correlation analysis |
| Dashboard         | Streamlit                         | Interactive filtering |
| Business Thinking | —                                 | Revenue quantification, ROI analysis |

## 🚀 How to Run This Project

### Option 1: View the Notebook

- Open `notebooks/churn_analysis.ipynb` directly on GitHub  
- All outputs are **already executed and saved**  

### Option 2: Run Locally

```bash
# Clone the repo
git clone https://github.com/divithraju/ecommerce-churn-analysis

# Navigate to project folder
cd ecommerce-churn-analysis

# Install dependencies
pip install -r requirements.txt

# Run the analysis notebook
jupyter notebook notebooks/churn_analysis.ipynb

# Launch the dashboard
streamlit run dashboard/app.py
```

## 📁 Dataset

- Download from Kaggle: **E-Commerce Dataset**  
- Place the file in the following path:

## 📦 Requirements

Install all dependencies using:

```bash
pip install -r requirements.txt
```

### requirements.txt

```txt
pandas==2.0.3
numpy==1.24.3
plotly==5.15.0
seaborn==0.12.2
matplotlib==3.7.1
scipy==1.11.1
statsmodels==0.14.0
streamlit==1.25.0
mysql-connector-python==8.1.0
openpyxl==3.1.2
jupyter==1.0.0
```

## 👤 About This Project

Built as part of my **Data Analyst portfolio** to demonstrate:

- End-to-end analysis from **raw data → business recommendations**  
- Combined **SQL + Python workflow** (real-world industry approach)  
- Strong **business thinking**:
  - Every insight is tied to **revenue impact**  
- Clear **communication skills**:
  - Technical analysis translated into **executive-level insights**  

## 🔗 Connect with Me

- LinkedIn:  https://www.linkedin.com/in/divithraju
- GitHub:   https://github.com/divithraju

## 📊 Dataset

- Source: **Kaggle – E-Commerce Customer Churn Dataset**  
- Public dataset, free to use for analysis and projects  



