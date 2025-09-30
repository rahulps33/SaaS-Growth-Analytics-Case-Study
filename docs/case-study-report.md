---
title: "SaaS Growth Analytics - Case Study Report"
author: Rahul
date: 2025-09-30
---
# SaaS Growth Analytics - Case Study Report

## Executive Summary
This comprehensive analysis of a SaaS Business Portal applies intelligent session clustering, statistical analysis, and KPI-driven dashboard design to SaaS event data, transforming raw logs into actionable insights that drive improvements in customer acquisition, retention, and business growth.

---

### Key Achievements
- **15,164 applications** identified from 56,297 raw requests (3.71:1 intelligent compression)
- **10-minute clustering rule** statistically validated through gap distribution analysis
- **54.9% application efficiency** proving multi-request session capture
- **Strategic market insights** across user roles and company segments
- **Production-ready SQL architecture** with optimized performance
- Designed **KPIs** for acquisition, retention, churn, and unit economics
- Built a B2B & B2C **dashboard mockup** for Growth Department decision-making

---

## Table of Contents
1. [PART 1: Data ANALYSIS & SESSION CLUSTERING](#part-1-data-analysis--session-clustering)
  - [Business Problem & Context](#business-problem--context)
  - [Data Architecture & Schema](#data-architecture--schema)
  - [Technical Implementation - Core Clustering Algorithm](#technical-implementation---core-clustering-algorithm)
  - [Statistical Analysis & Validation](#statistical-analysis--validation)
  - [Time Gap Distribution Analysis](#time-gap-distribution-analysis)
  - [Core Results & Business Insights](#core-results--business-insights)
  - [Temporal Patterns & Operational Insights](#temporal-patterns--operational-insights)
  - [Alternative Clustering Rules Analysis](#alternative-clustering-rules-analysis)
  - [Critical Assumptions Analysis](#critical-assumptions-analysis)
  - [Key Business Metrics Delivered](#key-business-metrics-delivered)
2. [PART 2: GROWTH DEPARTMENT DASHBOARD DESIGN](#part-2-growth-department-dashboard-design)
  - [Core KPI Framework](#core-kpi-framework)
  - [KPI Selection Rationale](#kpi-selection-rationale)
  - [Visual Dashboard Mockup](#visual-dashboard-mockup)
  

---
<div style="page-break-after: always;"></div>

# PART 1: Data ANALYSIS & SESSION CLUSTERING

## Business Problem & Context
**Challenge:** Transform raw user request logs into meaningful business applications using intelligent session clustering.

**Core Requirement:** Aggregate multiple requests from the same user into a single application if the time between sequential requests does not exceed a certain threshold.

## Data Architecture & Schema

### Schema Classification: Denormalized Star Schema
The Business Portal data follows a **denormalized star schema pattern** optimized for analytical queries:

```
SCHEMA TYPE: Production Analytical Schema
├── FACT TABLE: requests_log (56,297 user interaction events)
├── DIMENSION TABLE: user_roles (3,151 users, 90.4% coverage)
├── DIMENSION TABLE: user_company (2,264 users, 1,609 companies)
└── BUSINESS RULE: 10-minute session clustering
```

### Core Tables Structure

#### 1. **requests_log** (Fact Table):
- **Grain:** Individual user interaction events
- **Volume:** 56,297 requests from 2,036 unique users
- **Time Span:** 39 days (January 28 - March 8, 2023)
- **Key Fields:** `id` (Unique request identifier), `mapped_user_id`, `timestamp`, contextual metadata
- **Data Quality:** Zero missing timestamps, comprehensive logging

#### 2. **user_roles** (Dimension Table):
- **Coverage:** 2,990 unique users with role assignments (90.4% coverage)
- **Role Distribution:** Admin (60%), Driver (11%), Unknown (28%), Analyst (0.6%)
- **Business Value:** Customer segment identification
- **Data Quality:** 890 missing roles

#### 3.   **user_company** (Dimension Table):
- **Coverage:** 2,264 users across 1,609 companies (100% coverage)
- **Fleet Range:** 0-270 vehicles per company
- **Segmentation:** Small (≤50)(25%), Mid (51-150)(58%), Large (>150)(17%)
- **Data Quality:** Zero missing fleet_size

---
## **Business Logic: 10-Minute Application Clustering**
```sql    
-- Core aggregation rule implementation
CASE
    WHEN TIMESTAMP_DIFF(current_request, previous_request, MINUTE) > 10
    THEN new_application
    ELSE same_application
END
```
**Clustering Results:** 56,297 requests → 15,164 applications (3.71:1 ratio)

## Technical Implementation - Core Clustering Algorithm
```sql
-- View to cluster requests into applications per user using 10-minute rule
CREATE OR REPLACE VIEW `saas-session-analytics.growth_data.applications_view` AS
WITH requests_with_gaps AS (
  SELECT
    mapped_user_id,
    timestamp,
    CASE
      WHEN TIMESTAMP_DIFF(
            timestamp,
            LAG(timestamp) OVER(PARTITION BY mapped_user_id ORDER BY timestamp),
            MINUTE
           ) > 10
           OR LAG(timestamp) OVER(PARTITION BY mapped_user_id ORDER BY timestamp) IS NULL
      THEN 1
      ELSE 0
    END AS new_app_flag
  FROM `saas-session-analytics.growth_data.requests_log`
  WHERE mapped_user_id IS NOT NULL
),
apps_grouped AS (
  SELECT
    mapped_user_id,
    timestamp,
    SUM(new_app_flag) OVER(PARTITION BY mapped_user_id ORDER BY timestamp) AS app_id
  FROM requests_with_gaps
)
SELECT
  mapped_user_id,
  app_id,
  MIN(timestamp) AS application_start_time,
  MAX(timestamp) AS application_end_time,
  COUNT(*) AS requests_in_application
FROM apps_grouped
GROUP BY mapped_user_id, app_id;
```
## Statistical Analysis & Validation

The comprehensive EDA reveals that the Business Portal represents a **sophisticated multi-user system** with clear behavioral patterns that **strongly justify the 10-minute clustering rule**. The analysis demonstrates how raw user interactions transform into meaningful business applications through intelligent aggregation.

### Key Discovery: **54.9% Application Efficiency**
The 10-minute rule successfully reduces **56,297 raw requests** to **15,164 meaningful applications** (3.71:1 ratio), indicating that over half of all applications involve multiple user interactions within focused sessions.

## Scale and Scope Analysis

### Production System Characteristics:
- **56,297 total requests** from **2,036 unique users** over **39 days**
- **15,164 applications** created through intelligent clustering
- **2,990 unique users** with role assignments across the entire system
- **1,609 companies** with fleet sizes ranging from 0-270 vehicles

### User Engagement Patterns:
- **Average: 27.6 requests per user** (indicating serious business usage)
- **Peak user activity:** Single user with 105 requests in one application session
- **Business hours dominance:** 95% weekday activity (14,406 vs 758 weekend applications)

## Time Gap Distribution Analysis

![Gap Distribution](/images/gap_distribution.jpg)

**Methodology:** Analyzed 54,265 inter-request time gaps to validate the 10-minute threshold.
**Key Statistical Findings:**
- **62.7% zero-minute gaps:** Technical events, spam, rapid UI interactions
- **13.3% gaps 1-5 minutes:** Legitimate user interactions within sessions
- **4.8% gaps 6-10 minutes:** Thoughtful evaluation within sessions
- **19.2% gaps >10 minutes:** Genuine session boundaries

### Validation Evidence for 10-Minute Rule
```
Statistical Support:
• Natural breakpoint: Sharp frequency drop after 10 minutes
• Cumulative capture: 80% of legitimate gaps within threshold
• User behavior alignment: Matches decision psychology patterns
• Spam filtering: Effectively groups technical noise (62.7% same-minute requests)
```

### User Behavior Evidence:
- **8,586 requests** occurred within 5 seconds of each other (spam/technical issues)
- **1,601 users** regularly submit requests <10 minutes apart
- **Application session duration:** Ranges from single requests to 68-minute focused sessions

**Real User Validation Example:**
User `auth0|65b36e69c8973e8bb551ad16`:
- Application 1: 105 requests over 68 minutes (complex evaluation session)
- Applications 2–12: Individual requests with >10 minute natural breaks
- Perfect session boundary detection

---

## Core Results & Business Insights

### Primary Metrics Achieved:
- **56,297 raw requests** → **15,164 meaningful applications**
- **3.71:1 compression ratio** shows intelligent aggregation
- **Weekly Average** → **2,166 applications**

## Market Segmentation Insights
### User Role Analysis:

| Role         | Users        | Avg Requests/User | Applications    | Business Insight           |
|--------------|--------------|------------------|------------------|----------------------------|
| **Admin**    | 1,891 (60%)  | 26.1             | 12,577 (76%)     | Admins drive adoption      |
| **Driver**   | 339 (11%)    | 38.1             | 2,683 (16%)      | High engagement per user   |
| **Unknown**  | 890 (28%)    | 36.9             | 1,234 (7.5%)     | Onboarding optimization    |

- **Admin users** represent the **primary customer segment** (76% of applications)
- **Driver users** show the **highest engagement intensity** (38.1 requests/user)
- **Role expansion opportunity:** 28% users with undefined roles suggest onboarding gaps

### Company Size Distribution:

| Company Size    | Users | Applications | Avg Fleet Size | Market Insight        |
|-----------------|-------|--------------|----------------|----------------------|
| **Mid (51-150)**| 1,304 | 8,680 (57%) | 98 vehicles    | Core market segment   |
| **Small (≤50)** | 562   | 3,846 (25%) | 34 vehicles    | Growth opportunity    |
| **Large (>150)**| 398   | 2,616 (17%) | 197 vehicles   | Enterprise segment    |

- **Mid Companies** (51–150 vehicles): 57% of applications — **core market segment**
- **Small Companies (≤50):** 25% of applications — growth opportunity
- **Large Enterprises (>150):** 17% of apps — enterprise sales potential

---

## Temporal Patterns & Operational Insights

### Weekly Growth Trajectory:
```
Weekly Application Trajectory (Product-Market Fit Evidence):
W04: 80 applications → W05: 2,446 (30x growth explosion!)
W06: 2,459 applications → W07: 2,875 (sustained momentum)  
W08: 3,153 applications → W09: 2,969 (market stabilization)
```
**Strategic Insight:** The dramatic 30x increase from W04 to W05 suggests a product-market fit breakthrough or successful marketing campaign.

### Operational Patterns:
- **Peak activity:** 7 AM – 2 PM (matches business decision-making hours)
- **Weekly pattern:** Monday–Friday dominance (95% of applications)
- **Weekend activity:** Minimal (758 applications) suggesting B2B focus

### User Journey Complexity

### Application Complexity Distribution:
- **45% single-request applications:** Quick decisions/inquiries
- **28% short sessions (2–5 requests):** Comparison shopping
- **14% medium sessions (6–10 requests):** Detailed evaluation
- **13% extended sessions (11+ requests):** Complex negotiations
**Business Implication:** Over half of applications require multiple touchpoints, indicating sophisticated evaluation processes that need UX optimization.
![App Distribution by Request Count](/images/app_complexity_pie.jpg)

---

## Advanced Analytics & Optimization
### Alternative Clustering Rules Analysis

### Statistical Optimization Opportunities
**Option A: Refined 8-Minute Threshold**
- Captures 77.2% of gaps (vs 80% for 10 minutes)
- Potential for tighter session quality
- Minimal trade-off for implementation complexity

**Option B: Role-Based Dynamic Thresholds**
```sql
CASE
  WHEN user_role = 'admin' THEN 15 -- Complex fleet decisions
  WHEN user_role = 'driver' THEN 8 -- Quick personal decisions
  ELSE 10 -- Validated baseline
END as smart_threshold
```
**Option C: Context-Aware Clustering**
```sql
CASE
  WHEN company_fleet_size > 100 THEN 20     -- Enterprise approval cycles
  WHEN EXTRACT(HOUR FROM timestamp) NOT BETWEEN 7 AND 14 THEN 15  -- Off-hours
  WHEN user_role = 'driver' THEN 8          -- Quick decisions
  ELSE 10 -- Default validated threshold
END as dynamic_threshold
```
### Machine Learning Approach
**Behavioral Clustering Features:**
- Time gaps, user roles, company context
- Time of day, day of week patterns
- Browser consistency, request patterns
- DBSCAN clustering for natural session boundaries

## Critical Assumptions Analysis
### Key Assumptions:
1. **Request Definition:** Each log entry represents meaningful user interaction
2. **Time-Based Clustering:** Temporal gaps indicate session boundaries
3. **Universal Threshold:** 10-minute rule applies across user types
4. **Data Completeness:** Logs capture all relevant user interactions
5. **Timestamp Accuracy:** Timestamps reflect actual user action timing

### Validation Framework:
- **Stakeholder Interviews:** Understand request definitions
- **Conversion Analysis:** Join with subscription outcome data
- **A/B Testing:** Framework for clustering rule optimization
- Continuous monitoring approach for assumption validity tracking

---

### **Key Business Metrics Delivered**
- **15,164 applications** from 56,297 requests (73% compression)
- **2,166 applications per week** average with clear growth trajectory
- **76% admin-driven usage** informing product development priorities
- **57% mid-market focus** validating business strategy

---

<div style="page-break-after: always;"></div>

# PART 2: GROWTH DEPARTMENT DASHBOARD DESIGN

## Dashboard Strategy

**Challenge:** Provide Growth Department with monthly overview of customer acquisition, retention, and business health across B2C and B2B segments.

**Solution:** Comprehensive KPI dashboard optimized for monthly executive briefings with actionable insights and strategic decision support.

### Design Philosophy
- **5-Second Rule**: Critical insights visible immediately
- **Mobile-Optimized**: Accessible during commutes
- **Alert-Driven**: Red/yellow/green indicators for immediate attention
- **Trend-Focused**: Month-over-month and year-over-year comparisons

---

## Core KPI Framework

### Tier 1 KPIs (Always Visible)

#### **1. Customer Acquisition Velocity**
```
📊 Monthly New Customers: 2,200 (↑22.2% MoM)
• B2C Segment: 1,870 customers (↑32% MoM)
• B2B Segment: 330 customers (↑18% MoM) 
• Daily Run Rate: ~73 customers/day
• YoY Growth: +36.0%
```

**Strategic Rationale**: Growth momentum indicator, segment balance validation, capacity planning driver

#### **2. Monthly Recurring Revenue (MRR)**
```
💰 Total MRR: €4,636,131
• B2C Revenue: €3,458,700 (ARPU €180)
• B2B Revenue: €1,231,650 (ARPU €450)
• MoM Growth: +28.5%
• YoY Growth: +35.3%
```

**Strategic Rationale**: Core subscription business metric, investor KPI, sustainability indicator

<div style="page-break-after: always;"></div>

#### **3. Customer Health Score (NPS)**
```
💚 Combined NPS: 39.5 (Excellent)
• B2C NPS: 33.8 (Good, improving trend)
• B2B NPS: 45.2 (Excellent, stable)
• 3-Month Trend: +2.1 points improvement
```

**Strategic Rationale**: Retention predictor, product-market fit indicator, referral growth driver

#### **4. Unit Economics Health**
```
🎯 CAC/LTV Performance:
• B2C: €85 CAC, 3.2x LTV/CAC ratio
• B2B: €320 CAC, 5.1x LTV/CAC ratio  
• Blended Payback: 8.4 months
• Marketing Efficiency: Improving
```

**Strategic Rationale**: Scaling sustainability, marketing ROI validation, growth investment decisions

---

### Tier 2 KPIs (Drill-Down Analytics)

#### **5. Conversion Funnel Performance**
- **B2C**: 4.5% visitor-to-customer conversion
- **B2B**: 15.0% qualified lead-to-customer conversion
- **Channel efficiency**: Referrals leading at 22% B2C, 35% B2B

#### **6. Retention & Churn Analysis** 
- **B2C Churn**: 8.1% monthly (improving from 8.7%)
- **B2B Churn**: 4.2% monthly (industry-leading)
- **Net Revenue Retention**: 108% with expansion revenue

---

### Advanced Dashboard Features

#### **Smart Alert System**
```
🟢 B2B NPS increased 3.2 points → Replicate success factors
🟡 B2C CAC increased 8% → Investigate ad performance  
🔴 Referral conversion dropped 15% → Urgent channel review
🔵 Monthly revenue record achieved → Celebrate & analyze
```

#### **Interactive Analytics**
- **Geographic Drill-Down**: City/region performance analysis
- **Cohort Analysis**: Customer behavior by acquisition month
- **Predictive Modeling**: 7-day acquisition and churn forecasts
- **Competitive Benchmarking**: Industry comparison context

#### **Cross-Team Integration**
- **Product Team**: NPS insights and feature impact analysis
- **Marketing Team**: Channel optimization and campaign ROI
- **Sales Team**: B2B pipeline health and conversion tracking
- **Finance Team**: Unit economics and revenue forecasting

---

## KPI Selection Rationale

### Strategic Business Alignment

#### **Subscription Business Focus**
- **MRR Priority**: Core metric for subscription model valuation
- **Churn Prevention**: Retention as growth multiplier
- **Unit Economics**: Sustainable scaling validation

#### **B2C vs B2B Differentiation**
- **Different Customer Journeys**: Metrics adapted to segment characteristics
- **Varied Sales Cycles**: B2C immediate, B2B relationship-based
- **Distinct Value Propositions**: Personal vs business use optimization

#### **Growth Stage Optimization**
- **Acquisition Focus**: Appropriate for scaling company phase
- **Efficiency Emphasis**: CAC/LTV ratios for sustainable growth
- **Leading Indicators**: Predictive metrics vs just historical tracking

---
<div style="page-break-after: always;"></div>

 **Visual Dashboard Mockup**
![Dashboard](/images/dashboard_overview.jpg)