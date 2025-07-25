
  create view "imf_data"."staging_staging"."_imf_data__dbt_tmp"
    
    
  as (
    

SELECT
    code,
    indicator,
    year,
    value::FLOAT
FROM "imf_data"."public"."imf_data"
  );