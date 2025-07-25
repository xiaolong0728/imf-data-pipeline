
  create view "imf_data"."staging_staging"."_imf_groups__dbt_tmp"
    
    
  as (
    

SELECT
    code,
    label
FROM "imf_data"."public"."imf_groups"
  );