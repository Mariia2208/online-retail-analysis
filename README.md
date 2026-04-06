# 🛒 Online Retail Sales Analysis
 
## 📌 About This Project
 
This is my second data analysis project, and it represents a significant step forward from my first.  
I chose this dataset because I believe there is always a story hidden behind numbers and tables —  
and my goal as an analyst is to find it.
 
I am someone who is always ready to grow, always curious about new ways to uncover insights,  
and always eager to learn new techniques. This project reflects exactly that mindset.
 
Compared to my first project (Telco Churn), here I challenged myself with:
- More complex SQL techniques (Window Functions, CTEs, Subqueries, LOD expressions)
- A larger dataset (1M+ rows)
- A more polished Tableau dashboard
- Deeper business thinking — not just "what happened" but "why" and "what should the business do"
 
**Tools used:** PostgreSQL · Tableau  
**Dataset:** [UCI Online Retail II — Kaggle](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci)  
**Dashboard:** [View on Tableau Public](https://public.tableau.com/views/Book1_17742399211240/Dashboard1)
 
---
 
## 🧠 My Analytical Approach
 
Before writing any query I asked myself:  
*"What would a business owner actually need to know about their sales?"*
 
I structured the analysis in chapters — each chapter builds on the previous one,  
moving from data quality → business health → customer behavior → actionable strategy.
 
> 💡 **Note on data validation:** I initially explored some metrics using Excel Pivot Tables,  
> then cross-validated all results using SQL GROUP BY queries.  
> This taught me an important lesson: *share of total* and *rate within a group* are very different things.  
> All figures in this project are validated through SQL.
 
---
 
## 🔍 Key Business Questions
 
1. Is the business making money?
2. When does the business perform best?
3. Who are the most valuable customers?
4. Are there patterns we can use to grow revenue?
5. Which customer segments need different retention strategies?
 
---
 
## 📊 Key Findings
 
### 💰 Business Health
The business generated **$17.7M over 2 years** (2009–2011) across **36,969 transactions**  
with an average order value of **$22** — confirming a healthy, active operation.
 
### 📅 Seasonality — Q4 Dominates
Only **7 out of 25 months** performed above the monthly average.  
All 7 fall in **September, October, November, and December**.  
November 2010 was the peak month at **$1,172,336** — driven by Black Friday.  
> Q4 is not just the best season — it defines the entire year.
 
### 👥 Customer Insights
- Top customer (ID 18102) generated **$608,821** — 3.4% of total revenue alone
- Active from **day 1 to the last day** of the dataset with **1,058 transactions** (44/month)
- This pattern suggests **wholesale/B2B buyers**, not typical retail consumers
 
### 🎯 Customer Segmentation
| Segment | Customers | Share |
|---------|-----------|-------|
| 🟢 Occasional (<$1K) | 3,131 | 53% |
| 🟡 Regular ($1K–$10K) | 2,480 | 42% |
| 🔴 VIP (>$10K) | 267 | 5% |
 
Only 5% are VIP — yet this small group likely drives the majority of revenue (80/20 rule).
 
### 🌍 Revenue by Country
United Kingdom dominates with **$14.7M** — over 85% of total revenue.  
Top international markets: EIRE ($621K), Netherlands ($554K), Germany ($431K).
 
---
 
## 💡 Business Recommendations
 
| Priority | Recommendation | Based On |
|----------|---------------|----------|
| 🔴 High | Maximize Q4 inventory and marketing spend | 7/25 above-average months all in Q4 |
| 🔴 High | Create VIP retention program | 5% of customers drive majority of revenue |
| 🟡 Medium | Launch loyalty program for Regular segment | 42% of customers close to VIP threshold |
| 🟡 Medium | Re-engagement campaigns for Occasional buyers | 53% at high churn risk |
| 🟢 Low | Explore international expansion | Strong EIRE and Netherlands performance |
 
---
 
## 🛠️ SQL Techniques Demonstrated
 
| Technique | Used For |
|-----------|---------|
| **CTE (Common Table Expression)** | Data cleaning + chained queries |
| **Window Function RANK()** | Customer ranking with tie support |
| **Window Function LAG()** | Month-over-month revenue comparison |
| **Complex CASE WHEN** | Customer segmentation by value tier |
| **Subquery** | Finding months above average revenue |
| **LOD Expression** | Customer-level aggregation in Tableau |
| **Incremental Debugging** | Identifying and fixing logic errors |
| **Hypothesis Testing** | Validating assumptions with data |
 
---
 
## 📁 Repository Structure
 
```
online-retail-analysis/
│
├── README.md                        ← you are here
├── sql/
│   └── online_retail_analysis.sql  ← all queries with storytelling comments
├── visuals/
│   └── dashboard_preview.png       ← Tableau dashboard screenshot
└── tableau/
    └── link.md                     ← Tableau Public link
```
 
---
 
## 📈 Dashboard Preview
 
[🔗 View Interactive Dashboard on Tableau Public](https://public.tableau.com/views/Book1_17742399211240/Dashboard1)
 
---
 
## 🚀 What I Learned
 
This project taught me that data cleaning can take more time than the actual analysis —  
over 30% of records had quality issues that needed to be resolved before any querying.
 
I also learned the difference between writing a query that *works* and writing a query that *communicates* —  
comments, structure, and storytelling matter as much as the SQL itself.
 
Most importantly: **I am always ready to learn, always curious, and always growing.** 💪
 
---
 
*Project by Mariia Pron · [LinkedIn URL](www.linkedin.com/in/mariia-pron) · [Tableau Public](https://public.tableau.com/views/Book1_17742399211240/Dashboard1)*
