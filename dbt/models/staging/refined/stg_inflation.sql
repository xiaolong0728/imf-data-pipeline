{{ config(materialized='view', schema='staging') }}

WITH inflation AS (
    SELECT * FROM {{ ref('_imf_data') }}
    WHERE indicator = 'PCPIPCH'
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