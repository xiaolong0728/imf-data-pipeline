-- Test for reasonable data ranges
-- This test ensures that economic indicators are within reasonable bounds

SELECT *
FROM {{ ref('stg_all_indicators') }}
WHERE 
    -- GDP growth should be between -50% and +50%
    (gdp_growth IS NOT NULL AND (gdp_growth < -50 OR gdp_growth > 50))
    OR
    -- Inflation should be between -20% and +100%
    (inflation_rate IS NOT NULL AND (inflation_rate < -20 OR inflation_rate > 100))
    OR
    -- Unemployment should be between 0% and 50%
    (unemployment_rate IS NOT NULL AND (unemployment_rate < 0 OR unemployment_rate > 50))
    OR
    -- Nominal GDP should be positive
    (nominal_gdp IS NOT NULL AND nominal_gdp <= 0) 