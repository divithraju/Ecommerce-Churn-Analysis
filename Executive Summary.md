# 📊 Executive Summary: E-Commerce Churn Analysis

### 👤 Prepared by: Divith Raju | Data Analyst

---

## 🚨 The Problem

Our e-commerce platform is losing **23.4% of customers every year**.  
That means roughly **1 in 4 customers** does not return within 12 months.  

Based on average customer spending, this represents an estimated  
💰 **₹21 lakh in annual revenue loss**.

The business currently has **no early warning system** — we only know a customer churned *after* they stop buying.  

👉 This analysis changes that.

---

## 📈 What the Data Tells Us

After analyzing **5,630 customer records** across 20 variables, five clear patterns emerged:

---

### 🔹 Finding 1: The 45-Day Clock

- Customers inactive for **45+ days** → **78% churn probability**  
- At **day 30**, churn probability is still **below 50%**  

**💡 Business Impact:**
- Trigger re-engagement campaigns at **day 30**
- 15-day intervention window exists

---

### 🔹 Finding 2: We Are Losing Mobile Customers

- Mobile churn: **38%**  
- Desktop churn: **14%**  

📉 Nearly **3x higher churn on mobile**

**💡 Business Impact:**
- Likely **UX friction (checkout/payment issues)**
- Every 1% improvement ≈ **₹50K+ revenue recovery**
- Mobile UX audit = **highest priority**

---

### 🔹 Finding 3: Tier-2 Cities Are Underserved

- Tier-2 churn: **34%**  
- Tier-1 churn: **18%**  
- Cashback usage:
  - Tier-2: **32%**
  - Tier-1: **71%**

**💡 Business Impact:**
- Problem = **low cashback adoption**, not product
- Increase awareness → reduce churn significantly

---

### 🔹 Finding 4: Cashback is Our Best Retention Tool

- High cashback users churn: **8%**  
- Low cashback users churn: **31%**  

📊 **4x difference — strongest retention lever**

**💡 Business Impact:**
- Expand cashback adoption
- Target underserved segments

---

### 🔹 Finding 5: Complaints Are an Opportunity

- Customers with **resolved complaints** → **40% lower churn**  
- Complaint resolution builds **trust & loyalty**

**💡 Business Impact:**
- Treat support as a **retention strategy**
- Invest in **faster resolution systems**

---

## 🎯 Recommended Actions (Ranked by Revenue Impact)

| Action | Revenue Recovery | Timeline | Effort |
|--------|-----------------|----------|--------|
| 30-day re-engagement (Email/SMS) | ₹3,11,000 | 1 week | Low |
| Mobile UX audit & fix | ₹2,43,000 | 1–3 months | High |
| Cashback campaign (Tier-2) | ₹1,92,000 | 1 month | Medium |
| Electronics loyalty program | ₹95,000 | 2 months | Medium |

### 💰 Total Estimated Recovery: **₹8,41,000 annually**

---

## 📊 How to Use the Dashboard

The interactive dashboard helps you:

- Filter by **city tier, device type, and tenure**  
- Identify **at-risk customers** for targeted outreach  
- Track churn trends **before vs after interventions**  

---

## 📂 Additional Resources

- 📓 Full analysis: `notebooks/churn_analysis.ipynb`  
- 🗄️ SQL queries: `sql/churn_queries.sql`  

---
