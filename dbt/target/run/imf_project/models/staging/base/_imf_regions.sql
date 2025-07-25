
  create view "imf_data"."staging_staging"."_imf_regions__dbt_tmp"
    
    
  as (
    

SELECT
    code,
    label
FROM "imf_data"."public"."imf_regions"
  );