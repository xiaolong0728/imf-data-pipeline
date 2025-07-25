

WITH inflation AS (
    SELECT * FROM "imf_data"."staging_staging"."_imf_data"
    WHERE indicator = 'PCPIPCH'
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
    i.indicator,
    i.code,
    COALESCE(c.label, r.label, g.label) AS label,
    i.year,
    i.value AS inflation_rate
FROM inflation i
LEFT JOIN countries c ON i.code = c.code
LEFT JOIN regions r ON i.code = r.code
LEFT JOIN groups g ON i.code = g.code
WHERE i.value IS NOT NULL