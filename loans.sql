-- 1 Extract Data (with filters)
SELECT *
FROM `proven-env-473308-c1.loans.loans`
WHERE `Signature Date` >= '1980-01-01';

-- 2.1 Cast Signed Amount to NUMERIC
SELECT SUM(CAST(`Signed Amount` AS NUMERIC)) AS total_funding
FROM `proven-env-473308-c1.loans.loans`;

-- 2.2 Grouping + Aggregation
SELECT Region, SUM(`Signed Amount`) AS total_funding
FROM `loans.loans`
GROUP BY Region
ORDER BY total_funding DESC;

-- 3.1 List all unique region names
SELECT DISTINCT Region
FROM `proven-env-473308-c1.loans.loans`
ORDER BY Region;

-- 3.2 Define region_lookup inline as Common Table Expression
WITH region_lookup AS (
  SELECT 'European Union' AS Region, 1 AS eu_flag UNION ALL
  SELECT 'Asia and Latin America', 0 UNION ALL
  SELECT 'EFTA countries', 0 UNION ALL
  SELECT 'Eastern Europe, Southern Caucasus', 0 UNION ALL
  SELECT 'Mediterranean countries', 0 UNION ALL
  SELECT 'South Africa', 0 UNION ALL
  SELECT 'United Kingdom', 0   
  )

-- 3.3 Join with Lookup (EU flag)
SELECT p.*, r.eu_flag
FROM `loans.loans` p
LEFT JOIN region_lookup r
ON p.Region = r.Region;

-- 4 Feature creation: add signed_num + High_Signed_Amount flag
WITH cleaned AS (
  SELECT
    *,
    CAST(`Signed Amount` AS NUMERIC) AS signed_num
  FROM
    `proven-env-473308-c1.loans.loans`
),
median_val AS (
  SELECT
    APPROX_QUANTILES(signed_num, 100)[OFFSET(50)] AS median_signed
  FROM
    cleaned
)

SELECT
  c.*,
  median_signed,
  CASE
    WHEN c.signed_num > median_signed THEN 1
    ELSE 0
  END AS High_Signed_Amount
FROM
  cleaned c
CROSS JOIN
  median_val;