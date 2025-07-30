-- Test for data completeness
-- This test ensures we have data for all major countries in recent years

WITH expected_data AS (
    SELECT 
        code,
        year
    FROM {{ ref('stg_all_indicators') }}
    WHERE year >= {{ var('start_year') }} AND year <= {{ var('end_year') }}
    GROUP BY code, year
    HAVING COUNT(*) = 0  -- Should have at least one record per country/year
)

SELECT *
FROM expected_data 