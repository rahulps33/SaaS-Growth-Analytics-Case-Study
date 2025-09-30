# SaaS Growth Analytics - Case Study

## 📌 Overview  
This project simulates a real-world **SaaS analytics case study** focusing on user activity, customer acquisition, and session clustering.  
The goal is to **transform raw event logs into actionable business insights** and design a **Growth Department Dashboard** for decision-makers.  

---
## 🎯 Objectives &  Highlights 
- Explored ~56k raw web-event logs with SQL
- Engineered a **10-minute session-clustering rule** (Group user activity logs into meaningful sessions) and validated it statistically.
- Performed **exploratory data analysis (EDA)** to understand user behavior, company distribution, and role-based usage. 
- Designed KPIs for **acquisition, retention, churn, and unit economics** 
- Built a **B2B & B2C dashboard mockup** for Growth Department decision-making

---
## 🏗️ Dataset:
Synthetic SaaS dataset modeled on real-world event logs, user-company relationships, and user roles.

- `requests_log` → Fact table (all user activity events).
- `user_roles` → Dimension table (roles assigned to users).
- `user_company` → Dimension table (company association, fleet size).
  
### 🏗️ Data Model & Schema  
The dataset is modeled using a **star schema** with `requests_log` as the fact table and supporting dimensions.  

```text
┌─────────────────┐ 1:M ┌─────────────────┐
│ user_roles       │     │ requests_log    │
│ user_id (PK)     │◄────┤ mapped_user_id │
│ roles (JSON)     │     │ timestamp       │
└─────────────────┘     │ context_*       │
                        └─────────────────┘
         ▲ 1:M
         │
┌─────────────────┐
│ user_company     │
│ user_id (PK)     │
│ company_id       │
│ fleet_size       │
└─────────────────┘
```

---

> **Tech stack:** SQL (BigQuery) · Plotly · Python · Canva/Figma (static BI mock-up) · GitHub (Documentation)


## 📌 Key Learnings
- Designed a complete analytics workflow: raw logs → session clustering → KPIs → dashboard.
- Gained hands-on with SaaS growth metrics: CAC, LTV, MRR, NPS
- Demonstrated ability to bridge technical SQL analysis with business insights.

## 🚀 How to Use
- Clone the repo
- Open SQL queries in BigQuery (or any warehouse with similar syntax)
- VIew the detailed case study report in /docs/pdf/
- View the static dashboard mockup in /dashboard/

  ---
---
