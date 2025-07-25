{{ config(materialized='view', schema='staging') }}

SELECT
    indicator,
    label,
    description,
    unit,
    source,
    dataset
FROM {{ source('public', 'imf_indicators') }}
WHERE indicator IS NOT NULL
