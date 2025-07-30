-- Test for macro condition logic
-- This test validates that our macro condition classifications are correct

SELECT *
FROM {{ ref('mart_growth_vs_inflation') }}
WHERE 
    -- Overheating: GDP growth > 0 AND inflation > threshold
    (macro_condition = 'Overheating' AND (gdp_growth <= 0 OR inflation_rate <= {{ var('overheating_inflation_threshold') }}))
    OR
    -- Stagflation: GDP growth < 0 AND inflation > threshold  
    (macro_condition = 'Stagflation' AND (gdp_growth >= 0 OR inflation_rate <= {{ var('stagflation_inflation_threshold') }}))
    OR
    -- Deflationary recession: GDP growth < 0 AND inflation < threshold
    (macro_condition = 'Deflationary recession' AND (gdp_growth >= 0 OR inflation_rate >= {{ var('deflation_inflation_threshold') }}))
    OR
    -- Normal: should not match any of the above conditions
    (macro_condition = 'Normal' AND (
        (gdp_growth > 0 AND inflation_rate > {{ var('overheating_inflation_threshold') }}) OR
        (gdp_growth < 0 AND inflation_rate > {{ var('stagflation_inflation_threshold') }}) OR
        (gdp_growth < 0 AND inflation_rate < {{ var('deflation_inflation_threshold') }})
    )) 