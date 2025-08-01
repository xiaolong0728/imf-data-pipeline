{{ config(materialized='table', schema='marts') }}

WITH base AS (
    SELECT
        code,
        label,
        year,
        gdp_growth,
        nominal_gdp,
        unemployment_rate,
        inflation_rate
    FROM {{ ref('stg_all_indicators') }}
    WHERE year >= 2020 AND year <= 2024
)

SELECT
    code,
    label,
    year,
    ROUND(gdp_growth::numeric, 2) AS gdp_growth,
    ROUND(nominal_gdp::numeric, 2) AS nominal_gdp_usd,
    ROUND(unemployment_rate::numeric, 2) AS unemployment_rate,
    ROUND(inflation_rate::numeric, 2) AS inflation_rate,

    CASE WHEN gdp_growth < 0 THEN TRUE ELSE FALSE END AS recession,
    CASE WHEN inflation_rate > 10 THEN TRUE ELSE FALSE END AS high_inflation,
    CASE WHEN unemployment_rate > 10 THEN TRUE ELSE FALSE END AS high_unemployment

FROM base
ORDER BY code, year