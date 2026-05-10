CREATE OR REPLACE VIEW v_china_commodity_imports AS
SELECT 
    "refYear",
    "cmdCode" as hs_chapter,
    "cmdDesc" as commodity_description,
    SUM(trade_value_usd_mn) as total_value_mn
FROM uae_trade_flows
WHERE "partnerDesc" = 'China'
AND flow_label = 'IMP'
GROUP BY "refYear", "cmdCode", "cmdDesc"
ORDER BY "refYear", total_value_mn DESC;