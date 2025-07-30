{{ config(materialized = 'view', schema = 'marts') }} 

WITH base AS (
    SELECT code,
        label,
        year,
        gdp_growth,
        inflation_rate
    FROM {{ ref('stg_all_indicators') }}
    WHERE gdp_growth IS NOT NULL
        AND inflation_rate IS NOT NULL
        AND year >= {{ var('start_year') }} AND year <= {{ var('end_year') }}
),

enriched AS (
    SELECT *,
        LAG(gdp_growth) OVER (
            PARTITION BY code
            ORDER BY year
        ) AS gdp_growth_lag,
        LAG(inflation_rate) OVER (
            PARTITION BY code
            ORDER BY year
        ) AS inflation_lag
    FROM base
)

SELECT code,
    label,
    year,
    ROUND(gdp_growth::numeric, 2) AS gdp_growth,
    ROUND(inflation_rate::numeric, 2) AS inflation_rate,
    ROUND(gdp_growth_lag::numeric, 2) AS gdp_growth_lag,
    ROUND(inflation_lag::numeric, 2) AS inflation_lag,
    CASE
        WHEN gdp_growth > 0
        AND inflation_rate > {{ var('overheating_inflation_threshold') }} THEN 'Overheating'
        WHEN gdp_growth < 0
        AND inflation_rate > {{ var('stagflation_inflation_threshold') }} THEN 'Stagflation'
        WHEN gdp_growth < 0
        AND inflation_rate < {{ var('deflation_inflation_threshold') }} THEN 'Deflationary recession'
        ELSE 'Normal'
    END AS macro_condition
FROM enriched