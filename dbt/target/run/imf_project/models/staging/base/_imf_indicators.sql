
  create view "imf_data"."staging_staging"."_imf_indicators__dbt_tmp"
    
    
  as (
    

SELECT
    indicator,
    label,
    description,
    unit,
    source,
    dataset
FROM "imf_data"."public"."imf_indicators"
WHERE indicator IS NOT NULL
  );