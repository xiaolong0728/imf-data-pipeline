{{ config(materialized='view', schema='staging') }}

SELECT
    code,
    indicator,
    year,
    value::FLOAT
FROM {{ source('public', 'imf_data') }}
