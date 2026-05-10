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

SELECT * FROM v_top_partners 
WHERE "flowDesc" = 'Export' 
AND "refYear" = 2023
ORDER BY partner_rank;

CREATE OR REPLACE VIEW v_top5_partners AS
SELECT
    t.*,
    ROUND((
        (
            SUM(total_trade_usd_mn) FILTER (WHERE "refYear" = 2023)
            OVER (PARTITION BY "partnerDesc", "flowDesc")
            -
            SUM(total_trade_usd_mn) FILTER (WHERE "refYear" = 2020)
            OVER (PARTITION BY "partnerDesc", "flowDesc")
        )
        /
        NULLIF(
            SUM(total_trade_usd_mn) FILTER (WHERE "refYear" = 2020)
            OVER (PARTITION BY "partnerDesc", "flowDesc")
        , 0) * 100
    )::numeric, 2) AS growth_pct_2020_2023

FROM v_trade_concentration t
WHERE "partnerDesc" IN (
    SELECT "partnerDesc"
    FROM v_trade_concentration
    WHERE "partnerDesc" NOT IN ('World', 'Areas, nes', 'Other Asia, nes')
    AND "partnerISO" NOT IN ('W00', '_X ', 'X57')
    GROUP BY "partnerDesc"
    ORDER BY SUM(total_trade_usd_mn) DESC
    LIMIT 5
)
AND "partnerDesc" NOT IN ('World', 'Areas, nes', 'Other Asia, nes')
AND "partnerISO" NOT IN ('W00', '_X ', 'X57');