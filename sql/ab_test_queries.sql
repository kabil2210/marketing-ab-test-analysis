-- 1. Conversion rate by test group
SELECT test_group,
       COUNT(*) AS users,
       SUM(converted) AS conversions,
       ROUND(100.0 * SUM(converted) / COUNT(*), 2) AS conversion_pct
FROM ab_test
GROUP BY test_group
ORDER BY conversion_pct DESC;

-- 2. Conversion by number of ads seen (CTE + CASE)
WITH bucketed AS (
    SELECT CASE WHEN total_ads <= 5   THEN '1-5'
                WHEN total_ads <= 10  THEN '6-10'
                WHEN total_ads <= 25  THEN '11-25'
                WHEN total_ads <= 50  THEN '26-50'
                WHEN total_ads <= 100 THEN '51-100'
                ELSE '100+' END AS ads_bucket,
           test_group,
           converted,
           total_ads
    FROM ab_test
)
SELECT ads_bucket,
       COUNT(*) AS users,
       ROUND(100.0 * AVG(CASE WHEN test_group = 'ad'  THEN converted END), 2) AS ad_pct,
       ROUND(100.0 * AVG(CASE WHEN test_group = 'psa' THEN converted END), 2) AS psa_pct,
       ROUND(100.0 * AVG(CASE WHEN test_group = 'ad'  THEN converted END)
           - 100.0 * AVG(CASE WHEN test_group = 'psa' THEN converted END), 2) AS gap_pp
FROM bucketed
GROUP BY ads_bucket
ORDER BY MIN(total_ads);

-- 3. Conversion by day of week
SELECT most_ads_day,
       COUNT(*) AS users,
       ROUND(100.0 * AVG(CASE WHEN test_group = 'ad'  THEN converted END), 2) AS ad_pct,
       ROUND(100.0 * AVG(CASE WHEN test_group = 'psa' THEN converted END), 2) AS psa_pct,
       ROUND(100.0 * AVG(CASE WHEN test_group = 'ad'  THEN converted END)
           - 100.0 * AVG(CASE WHEN test_group = 'psa' THEN converted END), 2) AS gap_pp
FROM ab_test
GROUP BY most_ads_day
ORDER BY CASE most_ads_day
             WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
             WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
             ELSE 7 END;
