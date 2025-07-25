{{ config(materialized='view', schema='staging') }}

WITH base AS (
    SELECT
        d.code,
        COALESCE(c.label, r.label, g.label) AS label,
        d.year,
        d.indicator,
        d.value
    FROM {{ ref('_imf_data') }} d
    LEFT JOIN {{ ref('_imf_countries') }} c ON d.code = c.code
    LEFT JOIN {{ ref('_imf_regions') }} r ON d.code = r.code
    LEFT JOIN {{ ref('_imf_groups') }} g ON d.code = g.code
)

SELECT
    code,
    label,
    year,
    MAX(CASE WHEN indicator = 'NGDP_RPCH' THEN value END) AS gdp_growth,
    MAX(CASE WHEN indicator = 'PCPIPCH' THEN value END) AS inflation_rate,
    MAX(CASE WHEN indicator = 'NGDPD' THEN value END) AS nominal_gdp,
    MAX(CASE WHEN indicator = 'LUR' THEN value END) AS unemployment_rate
FROM base
GROUP BY 1, 2, 3
