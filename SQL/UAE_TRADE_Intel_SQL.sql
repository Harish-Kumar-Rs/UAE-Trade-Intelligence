-- ============================================================
-- UAE Trade Intelligence — PostgreSQL Views
-- Database: UAE_Trade_Intel (port 5433)
-- Author: Harish
-- Created: May 2026
-- Description: Analytical views supporting Power BI dashboards
--              and statistical analysis of UAE trade flows
--              (2020–2023), sourced from UN Comtrade API
--              and World Bank API.
-- ============================================================


-- View 1: Commodity Vulnerability
-- Purpose: Oil vs Non-Oil classification, supplier exposure by partner
CREATE OR REPLACE VIEW v_commodity_vulnerability AS
SELECT
    "refYear",
    "flowDesc",
    "cmdCode",
    "cmdDesc",
    "partnerDesc",
    "partnerISO",
    CASE
        WHEN "cmdCode" = 27 THEN 'Oil'
        ELSE 'NON-OIL'
    END AS commodity_type,
    SUM("primaryValue")        AS total_trade_usd,
    SUM(trade_value_usd_mn)    AS total_trade_usd_mn,
    COUNT(*)                   AS record_count
FROM uae_trade_flows
GROUP BY "refYear", "flowDesc", "cmdCode", "cmdDesc", "partnerDesc", "partnerISO"
ORDER BY "refYear", SUM("primaryValue") DESC;


-- View 2: Trade Concentration
-- Purpose: Partner trade share % per year and flow direction
CREATE OR REPLACE VIEW v_trade_concentration AS
SELECT
    "refYear",
    "flowDesc",
    "partnerDesc",
    "partnerISO",
    SUM(trade_value_usd_mn) AS total_trade_usd_mn,
    ROUND(
        (SUM(trade_value_usd_mn) * 100.0
         / SUM(SUM(trade_value_usd_mn)) OVER (PARTITION BY "refYear", "flowDesc")
        )::NUMERIC, 2
    ) AS trade_share_pct
FROM uae_trade_flows
GROUP BY "refYear", "flowDesc", "partnerDesc", "partnerISO"
ORDER BY "refYear", trade_share_pct DESC;


-- View 3: Re-export Proxy
-- Purpose: Identify commodities/partners with both import and export
--          activity — signals UAE re-export hub behaviour
CREATE OR REPLACE VIEW v_reexport_proxy AS
SELECT
    "refYear",
    "cmdCode",
    "cmdDesc",
    "partnerDesc",
    "partnerISO",
    SUM(trade_value_usd_mn) FILTER (WHERE "flowDesc" = 'Import') AS import_value_mn,
    SUM(trade_value_usd_mn) FILTER (WHERE "flowDesc" = 'Export') AS export_value_mn
FROM uae_trade_flows
GROUP BY "refYear", "cmdCode", "cmdDesc", "partnerDesc", "partnerISO"
HAVING
    SUM(trade_value_usd_mn) FILTER (WHERE "flowDesc" = 'Import') > 0
    AND
    SUM(trade_value_usd_mn) FILTER (WHERE "flowDesc" = 'Export') > 0
ORDER BY "refYear", export_value_mn DESC;


-- View 4: Macro Trade Correlation
-- Purpose: Join yearly trade totals with World Bank macro indicators
--          (GDP, inflation, FDI) for correlation analysis
CREATE OR REPLACE VIEW v_macro_trade_correlation AS
WITH trade_yearly AS (
    SELECT
        "refYear",
        SUM(trade_value_usd_mn) AS total_trade_usd_mn
    FROM uae_trade_flows
    GROUP BY "refYear"
),
macro_pivot AS (
    SELECT
        year,
        MAX(value) FILTER (WHERE indicator_name = 'gdp_current_usd')  AS gdp_current_usd,
        MAX(value) FILTER (WHERE indicator_name = 'gdp_growth_rate')   AS gdp_growth_rate,
        MAX(value) FILTER (WHERE indicator_name = 'inflation_rate')    AS inflation_rate,
        MAX(value) FILTER (WHERE indicator_name = 'trade_pct_gdp')     AS trade_pct_gdp,
        MAX(value) FILTER (WHERE indicator_name = 'fdi_pct_gdp')       AS fdi_pct_gdp
    FROM uae_macro_indicators
    GROUP BY year
)
SELECT
    t."refYear",
    t.total_trade_usd_mn,
    m.gdp_current_usd,
    m.gdp_growth_rate,
    m.inflation_rate,
    m.trade_pct_gdp,
    m.fdi_pct_gdp
FROM trade_yearly t
LEFT JOIN macro_pivot m ON t."refYear" = m.year
ORDER BY t."refYear";


-- View 5: Top Partners (All, Ranked)
-- Purpose: All partners ranked by trade value per year and flow direction
CREATE OR REPLACE VIEW v_top_partners AS
SELECT
    "refYear",
    "flowDesc",
    "partnerDesc",
    "partnerISO",
    total_trade_usd_mn,
    trade_share_pct,
    RANK() OVER (
        PARTITION BY "refYear", "flowDesc"
        ORDER BY total_trade_usd_mn DESC
    ) AS partner_rank
FROM v_trade_concentration;


-- View 6: Top 5 Partners with Growth %
-- Purpose: Top 5 trade partners with 2020–2023 growth percentage
--          Excludes aggregate/unclassified regions (World, Areas nes, etc.)
CREATE OR REPLACE VIEW v_top5_partners AS
SELECT
    "refYear",
    "flowDesc",
    "partnerDesc",
    "partnerISO",
    total_trade_usd_mn,
    trade_share_pct,
    ROUND(
        (
            (
                SUM(total_trade_usd_mn) FILTER (WHERE "refYear" = 2023)
                    OVER (PARTITION BY "partnerDesc", "flowDesc")
                -
                SUM(total_trade_usd_mn) FILTER (WHERE "refYear" = 2020)
                    OVER (PARTITION BY "partnerDesc", "flowDesc")
            )
            / NULLIF(
                SUM(total_trade_usd_mn) FILTER (WHERE "refYear" = 2020)
                    OVER (PARTITION BY "partnerDesc", "flowDesc"),
                0
            )
            * 100.0
        )::NUMERIC, 2
    ) AS growth_pct_2020_2023
FROM v_trade_concentration t
WHERE "partnerDesc" IN (
    SELECT "partnerDesc"
    FROM v_trade_concentration
    WHERE "partnerDesc" NOT IN ('World', 'Areas, nes', 'Other Asia, nes')
      AND "partnerISO"  NOT IN ('W00', '_X ', 'X57')
    GROUP BY "partnerDesc"
    ORDER BY SUM(total_trade_usd_mn) DESC
    LIMIT 5
)
AND "partnerDesc" NOT IN ('World', 'Areas, nes', 'Other Asia, nes')
AND "partnerISO"  NOT IN ('W00', '_X ', 'X57');


-- View 7: China Commodity Imports
-- Purpose: Breakdown of UAE imports from China by HS commodity chapter
CREATE OR REPLACE VIEW v_china_commodity_imports AS
SELECT
    "refYear",
    "cmdCode"  AS hs_chapter,
    "cmdDesc"  AS commodity_description,
    SUM(trade_value_usd_mn) AS total_value_mn
FROM uae_trade_flows
WHERE "partnerDesc" = 'China'
  AND flow_label = 'IMP'
GROUP BY "refYear", "cmdCode", "cmdDesc"
ORDER BY "refYear", total_value_mn DESC;


-- View 8: Commodity Growth (Top 5 HS Chapters)
-- Purpose: Year-on-year trade value for the 5 key commodity chapters:
--          HS 27 (Mineral Fuels), HS 71 (Gems/Precious Metals),
--          HS 85 (Electronics), HS 84 (Machinery), HS 87 (Vehicles)
CREATE OR REPLACE VIEW v_commodity_growth AS
SELECT
    "refYear",
    "cmdCode"  AS hs_chapter,
    "cmdDesc"  AS commodity_description,
    SUM(trade_value_usd_mn) AS total_value_mn
FROM uae_trade_flows
WHERE "partnerDesc" = 'World'
  AND "cmdCode" IN (27, 71, 85, 84, 87)
GROUP BY "refYear", "cmdCode", "cmdDesc"
ORDER BY "refYear", total_value_mn DESC;