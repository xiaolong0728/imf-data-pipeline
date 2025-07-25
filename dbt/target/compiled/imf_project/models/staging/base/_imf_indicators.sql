

SELECT
    indicator,
    label,
    description,
    unit,
    source,
    dataset
FROM "imf_data"."public"."imf_indicators"
WHERE indicator IS NOT NULL