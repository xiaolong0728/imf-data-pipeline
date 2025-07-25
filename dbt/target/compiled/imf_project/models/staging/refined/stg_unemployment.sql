

WITH unemployment AS (
    SELECT * FROM "imf_data"."staging_staging"."_imf_data"
    WHERE indicator = 'LUR'
),
countries AS (
    SELECT * FROM "imf_data"."staging_staging"."_imf_countries"
),
regions AS (
    SELECT * FROM "imf_data"."staging_staging"."_imf_regions"
),
groups AS (
    SELECT * FROM "imf_data"."staging_staging"."_imf_groups"
)

SELECT
    u.indicator,
    u.code,
    COALESCE(c.label, r.label, g.label) AS label,
    u.year,
    u.value AS unemployment_rate
FROM unemployment u
LEFT JOIN countries c ON u.code = c.code
LEFT JOIN regions r ON u.code = r.code
LEFT JOIN groups g ON u.code = g.code
WHERE u.value IS NOT NULL