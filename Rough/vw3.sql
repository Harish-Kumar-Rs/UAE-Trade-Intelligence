SELECT hs_chapter, "cmdDesc", 
       SUM(trade_value_usd_mn) as total_value_mn
FROM uae_trade_flows
WHERE "partnerDesc" = 'China'
AND flow_label = 'IMP'
GROUP BY hs_chapter, "cmdDesc"
ORDER BY total_value_mn DESC
LIMIT 10;

SELECT DISTINCT commodity_category, trade_type 
FROM v_commodity_vulnerability 
ORDER BY commodity_category;

SELECT * FROM v_commodity_vulnerability LIMIT 5;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'v_commodity_vulnerability'
ORDER BY ordinal_position;