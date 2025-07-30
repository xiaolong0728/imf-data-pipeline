{{ config(materialized='table', schema='marts') }}

WITH base AS (
    SELECT
        code,
        label,
        year,
        gdp_growth,
        nominal_gdp,
        unemployment_rate,
        inflation_rate,
        ROW_NUMBER() OVER (PARTITION BY code ORDER BY year DESC) AS rn
    FROM {{ ref('stg_all_indicators') }}
),

latest AS (
    SELECT *
    FROM base
    WHERE rn = 1
)

SELECT
    code,
    label,
    year,
    ROUND(gdp_growth::numeric, 2) AS gdp_growth,
    ROUND(nominal_gdp::numeric, 2) AS nominal_gdp,
    ROUND(unemployment_rate::numeric, 2) AS unemployment_rate,
    ROUND(inflation_rate::numeric, 2) AS inflation_rate,

    CASE WHEN gdp_growth < 0 THEN TRUE ELSE FALSE END AS is_in_recession,
    CASE WHEN inflation_rate > {{ var('overheating_inflation_threshold') }} THEN TRUE ELSE FALSE END AS high_inflation,
    CASE WHEN unemployment_rate > {{ var('unemployment_threshold') }} THEN TRUE ELSE FALSE END AS high_unemployment

FROM latest
WHERE label IS NOT NULL
