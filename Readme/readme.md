# UAE Trade Intelligence — Business Analytics Capstone

An end-to-end business analytics project examining UAE international trade flows (2020–2023), built using real-world data from the UN Comtrade API and World Bank API.

---

## Project Summary

UAE total trade grew **78.75%** between 2020 and 2023, driven by both oil and non-oil sectors.  
This project analyzes trade concentration, commodity vulnerability, re-export patterns, and macroeconomic correlations to surface actionable insights for trade strategy.

---

## Key Findings

| Metric | Value |
|---|---|
| Total Trade Growth (2020–2023) | 78.75% |
| Non-Oil Trade Share | 61% |
| Top Trade Partner (China) | 12.72% share |
| Top 5 Partners Combined Share | 37.10% |
| Trade vs GDP Correlation | 0.987 |

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Python (Pandas, NumPy) | Data collection, cleaning, statistical analysis |
| UN Comtrade API | Trade flow data source |
| World Bank API | Macroeconomic indicators (GDP, inflation, FDI) |
| PostgreSQL | Relational database, analytical views |
| Power BI | Interactive dashboards (4 pages) |
| PowerPoint | Executive summary report (13 slides) |

---

## Project Structure
Project_1/
├── data/
│   ├── raw/                        # 4 CSV files from UN Comtrade API (2020–2023)
│   └── uae_trade_clean.csv         # Cleaned dataset — 89,396 rows, 11 columns
├── notebooks/
│   ├── 01_data_collection.ipynb    # API calls — UN Comtrade + World Bank
│   ├── 02_data_cleaning.ipynb      # Pandas cleaning pipeline
│   └── 03_statistical_analysis.ipynb  # Correlation, concentration, growth analysis
├── sql/
│   └── views.sql                   # 8 PostgreSQL analytical views
├── reports/
│   └── UAE_Trade_Intelligence_Report.pptx  # 13-slide executive report
└── README.md
---

## Database — PostgreSQL Views

Eight analytical views were built in PostgreSQL to support Power BI and statistical analysis:

| View | Purpose |
|---|---|
| `v_commodity_vulnerability` | Oil vs Non-Oil classification, supplier exposure |
| `v_trade_concentration` | Partner trade share % by year |
| `v_reexport_proxy` | Re-export candidate identification |
| `v_macro_trade_correlation` | Trade vs GDP, inflation, FDI correlation |
| `v_top_partners` | All partners ranked by trade value |
| `v_top5_partners` | Top 5 partners with 2020–2023 growth % |
| `v_china_commodity_imports` | China import breakdown by HS commodity |
| `v_commodity_growth` | Top 5 commodity chapter trends |

---

## Power BI Dashboard

Four-page interactive dashboard covering:
- Trade overview and growth trends
- Partner concentration analysis
- Commodity breakdown (Oil vs Non-Oil)
- Macroeconomic correlation

> `.pbix` file not included in this repository due to file size.  
> Screenshots available on request.

---

## Data Sources

- [UN Comtrade API](https://comtradeplus.un.org/) — Trade flow data
- [World Bank API](https://data.worldbank.org/) — Macroeconomic indicators

---