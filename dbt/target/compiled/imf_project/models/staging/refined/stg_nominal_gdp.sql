

WITH nominal_gdp AS (
    SELECT * FROM "imf_data"."staging_staging"."_imf_data"
    WHERE indicator = 'NGDP'
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
    n.indicator,
    n.code,
    COALESCE(c.label, r.label, g.label) AS label,
    n.year,
    n.value AS nominal_gdp
FROM nominal_gdp n
LEFT JOIN countries c ON n.code = c.code
LEFT JOIN regions r ON n.code = r.code
LEFT JOIN groups g ON n.code = g.code
WHERE n.value IS NOT NULL