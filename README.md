# Automated Sales Reporting & Analytics System

An end-to-end data analytics project that takes a messy, real-world-style food delivery dataset and turns it into a clean database, an interactive Power BI dashboard, and a fully automated reporting pipeline that emails stakeholders a PDF report on demand.

Built by **Lavi Kumar**.

---

## Why this project exists

Most portfolio projects stop at a Jupyter notebook with some charts in it. This one doesn't. It starts where real analytics work usually starts — a messy 50,000-row export full of the problems every analyst actually deals with — and carries it all the way through to something a business could genuinely use: a live dashboard and a one-click report that lands in a manager's inbox.

The goal was to practice the full lifecycle, not just the fun parts:

`messy data → cleaning & validation → SQL database → business analysis → BI dashboard → automated reporting`

---

## What the raw data looked like

The starting dataset (`Food_Delivery_Operations_Analytics_messy_50k`) was deliberately unclean, with the kind of issues that show up in real operational exports:

- **757 duplicate order records**, including IDs tagged with `_DUP`
- **Inconsistent data types** — numeric columns like `Revenue_USD` and `Customer_Age` stored as text, mixed with currency symbols (`$471.05`), units (`82 min`, `12.5 km`), and stray text (`unknown`, `N/A`, `-`)
- **Inconsistent categorical formatting** — `Cafe`, `CAFE`, `  cafe  `, `cafe` all representing the same value
- **Invalid values that had no business meaning** — a customer age of `999`, a rating of `10` on a 1–5 scale, negative delivery times
- **Duplicate real-world entities under different labels** — `Bombay` and `Mumbai` recorded as separate cities
- **~9% missing data** across several numeric columns, with no reliable column to impute from (confirmed via near-zero correlation across the numeric fields)

None of this was simulated after the fact — it's documented step by step in the notebooks as it was found and resolved.

---

## What the pipeline actually does

**1. Data Profiling → Validation & Cleaning → Outlier Detection → EDA** *(Python / pandas)*
Row-by-row audit of every column, standardized data types, removed duplicates, corrected 872 malformed Order IDs, cleaned currency/unit strings, merged inconsistent categories (Bombay → Mumbai), handled missing values by column-appropriate strategy (median imputation where justified, row drops where safe), and validated numeric ranges against domain logic (IQR + business-rule bounds). Final dataset: **38,047 clean rows**, ready for analysis.

**2. Exploratory Data Analysis** *(pandas, seaborn, scipy)*
Univariate, bivariate, and multivariate analysis across all numeric and categorical fields, including a full correlation matrix, boxplot-based comparisons across 15+ variable pairs, and Chi-Square independence tests to confirm findings statistically rather than just visually — e.g. weather and complaint rate showed no significant relationship (p = 0.99), which the boxplots alone only suggested.

**3. Database & Business Analysis** *(PostgreSQL)*
The cleaned dataset is loaded into PostgreSQL, where six SQL scripts handle schema setup, data-quality validation (via reusable stored procedures), sales KPIs, customer segmentation, and vendor/cuisine performance — all built on window functions, CTEs, stored procedure and dynamic SQL rather than flat one-off queries. A final reporting layer exposes six SQL views that serve as the single source of truth for both the dashboard and the automated reports.

**4. Interactive Dashboard** *(Power BI)*
A multi-page dashboard (Overview, City, Restaurant & Cuisine, Trends, Customers) built directly on the SQL views — KPI cards, revenue trends, segment breakdowns, and a key-insights panel per page.

**5. Automated Reporting** *(Python, Streamlit, SMTP)*
This is the part most portfolio projects skip. A Streamlit app handles the full send flow: sign up or log in, generate a report on demand, and email it — all from a browser, no code required after setup.
- `report_generator.py` pulls live KPIs from the database, builds a text summary PDF with `fpdf2`, and merges it with the exported Power BI dashboard using `pypdf` into a single report.
- `email_report.py` sends that report via Gmail SMTP, with credentials handled through Google App Passwords (never a raw account password) and persisted locally so the app doesn't ask twice for the same user.

---

## Tech stack

| Layer | Tools |
|---|---|
| Data cleaning & EDA | Python, pandas, seaborn, matplotlib, scipy |
| Database & analysis | PostgreSQL, SQL (CTEs, window functions, stored procedures) |
| Dashboard | Power BI |
| Automation & reporting | Streamlit, fpdf2, pypdf, smtplib |
| Environment | Python virtual environment (`venv`) |

---
# Structure 
Automated-Sales-Reporting-Analytics/
│── README.md
│── .gitignore
│── requirements.txt
│── main.py                         
│
├── dataset/
│   ├── raw/
│   └── clean_dataset1.xlsx/
│   └──clean_dataset.csv/
│
├── notebooks/
│   ├── 01_data_profiling.ipynb
│   ├── 02_data_validation&cleaning.ipynb
│   ├── 03_outlier_detection.ipynb
│   └── 04_eda.ipynb
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_data_validation.sql
│   ├── 03_sales_analysis.sql
│   ├── 04_customer_analysis.sql
│   ├── 05_vendor_analysis.sql
│   └── 06_reporting_queries.sql
│
├── src/
│   └── database.py                  # DB connection + fetch data functions
│
├── powerbi/
│   ├── sales_dashboard.pbix
│   └── screenshots/
│
├── reports/                
│   └── generated/                   # Auto-generated reports save 
│
├── automation/
├── report_generator.py          
├── email_report.py              
└── config.py           

---

## Key findings

- **Total Revenue:** $9.56M across **38,047 orders**, averaging $153.26 per order
- **Total Profit:** $3.39M, holding a consistent **~35.4% margin** across every city and restaurant type — no segment is quietly more or less profitable
- **No single driver of performance:** correlation and Chi-Square testing across the full dataset found no meaningful linear or categorical relationship between operational factors (weather, traffic, restaurant type) and outcomes like delivery time, rating, or churn — a genuinely useful negative result, not a dead end
- **One real signal:** revenue peaks with customers aged 36–55, the one age bracket that meaningfully outperforms the rest
- **Fast Food and Indian cuisine** lead in both revenue and order volume, though margins stay flat across the board — the difference is entirely volume-driven

---

## Running it locally

```bash
# 1. Clone and set up the environment
git clone <repo-url>
cd Automated-Sales-Reporting-Analytics
python -m venv .venv
source .venv/Scripts/activate      # Windows
pip install -r requirements.txt

# 2. Set up the database
# Run the scripts in sql/ against a PostgreSQL instance, in order (01 → 06)

# 3. Point src/database.py at your database, then generate a report
python automation/report_generator.py

# 4. Launch the email dashboard
streamlit run automation/email_report.py
```

`automation/config.py` collects credentials at runtime and never stores raw passwords — Gmail sending uses App Passwords, validated for length before anything is sent.

---

## What I'd build next

- Persist user sessions in a proper database rather than a local JSON file, so the app scales beyond one active user
- Move the SQL stored procedures into a versioned migration setup
- Schedule `report_generator.py` to run automatically (cron / Task Scheduler) instead of on-demand

---

*This project was built as a hands-on exercise in taking data analysis all the way to a working, automated deliverable — not just a dashboard, but a system.*