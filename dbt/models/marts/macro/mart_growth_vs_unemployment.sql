{{ config(materialized = 'view', schema = 'marts') }} 

WITH base AS (
    SELECT code,
        label,
        year,
        gdp_growth,
        unemployment_rate
    FROM {{ ref('stg_all_indicators') }}
    WHERE gdp_growth IS NOT NULL
        AND unemployment_rate IS NOT NULL
        AND year >= 2018
),

enriched AS (
    SELECT *,
        unemployment_rate - LAG(unemployment_rate) OVER (
            PARTITION BY code
            ORDER BY year
        ) AS unemployment_change,
        gdp_growth - LAG(gdp_growth) OVER (
            PARTITION BY code
            ORDER BY year
        ) AS gdp_growth_change
    FROM base
)

SELECT code,
    label,
    year,
    ROUND(gdp_growth::numeric, 2) AS gdp_growth,
    ROUND(unemployment_rate::numeric, 2) AS unemployment_rate,
    ROUND(gdp_growth_change::numeric, 2) AS gdp_growth_change,
    ROUND(unemployment_change::numeric, 2) AS unemployment_change,
    CASE
        WHEN gdp_growth > 0
        AND unemployment_change > 0 THEN TRUE
        WHEN gdp_growth < 0
        AND unemployment_change < 0 THEN TRUE
        ELSE FALSE
    END AS mismatch_growth_unemployment
FROM enriched