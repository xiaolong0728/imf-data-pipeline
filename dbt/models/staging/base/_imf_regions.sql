{{ config(materialized='view', schema='staging') }}

SELECT
    code,
    label
FROM {{ source('public', 'imf_regions') }}