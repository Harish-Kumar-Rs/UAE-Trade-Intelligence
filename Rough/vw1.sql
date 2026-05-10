CREATE OR REPLACE VIEW v_commodity_growth AS
SELECT 
    "refYear",
    "cmdCode" as hs_chapter,
    "cmdDesc" as commodity_description,
    SUM(trade_value_usd_mn) as total_value_mn
FROM uae_trade_flows
WHERE "partnerDesc" = 'World'
AND "cmdCode" IN (27, 71, 85, 84, 87)
GROUP BY "refYear", "cmdCode", "cmdDesc"
ORDER BY "refYear", total_value_mn DESC;

SELECT * FROM v_macro_trade_correlation LIMIT 10;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'v_macro_trade_correlation'
ORDER BY ordinal_position;