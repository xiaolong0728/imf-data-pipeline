{{ config(materialized='view', schema='staging') }}

WITH gdp_growth AS (
    SELECT * FROM {{ ref('_imf_data') }}
    WHERE indicator = 'NGDP_RPCH'
),
countries AS (
    SELECT * FROM {{ ref('_imf_countries') }}
),
regions AS (
    SELECT * FROM {{ ref('_imf_regions') }}
),
groups AS (
    SELECT * FROM {{ ref('_imf_groups') }}
)

SELECT
    g.indicator,
    g.code,
    COALESCE(c.label, r.label, g2.label) AS label,
    g.year,
    g.value AS gdp_growth
FROM gdp_growth g
LEFT JOIN countries c ON g.code = c.code
LEFT JOIN regions r ON g.code = r.code
LEFT JOIN groups g2 ON g.code = g2.code
WHERE g.value IS NOT NULL

