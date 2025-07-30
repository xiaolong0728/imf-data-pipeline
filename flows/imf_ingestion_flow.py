import sys
import os
from datetime import datetime
from contextlib import contextmanager
from typing import Dict, Any, List

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../'))
sys.path.append(BASE_DIR)

from prefect import flow, task, get_run_logger
from prefect.tasks import task_input_hash
from prefect_shell import ShellOperation
from ingestion.fetch_data import ImfDataFetcher
import psycopg2
from psycopg2.extras import execute_batch


DB_CONFIG = {
    "dbname": "imf_data",
    "user": "xiaolong", 
    "password": "xiaolong",
    "host": "localhost",
    "port": 5433
}

INDICATORS = ["NGDP_RPCH", "NGDPD", "LUR", "PCPIPCH"]
START_YEAR = 2000
END_YEAR = 2024


@contextmanager
def get_db_connection():
    """Context manager for database connections with proper cleanup."""
    conn = None
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        yield conn
    except Exception as e:
        if conn:
            conn.rollback()
        raise e
    finally:
        if conn:
            conn.close()


@task(cache_key_fn=task_input_hash, retries=2)
def create_tables():
    """Create database and tables using SQL script."""
    logger = get_run_logger()
    logger.info("Creating database and tables")
    
    create_db_result = ShellOperation(
        commands=[f"createdb -h localhost -U xiaolong imf_data || true"],
        return_all=True,
    )
    
    result = ShellOperation(
        commands=[f"psql -h localhost -U xiaolong -d imf_data -f {BASE_DIR}/create_table.sql"],
        return_all=True,
    )
    
    logger.info("Tables created successfully")
    return result


@task(retries=3)
def fetch_indicators_task() -> Dict[str, Any]:
    """Fetch IMF indicator metadata."""
    logger = get_run_logger()
    
    fetcher = ImfDataFetcher(
        start_date=START_YEAR, 
        end_date=END_YEAR, 
        columns=INDICATORS
    )
    
    indicators = fetcher.fetch_indicators()
    logger.info(f"Fetched {len(indicators)} indicators")
    
    if not indicators:
        raise ValueError("No indicators fetched")
    
    return indicators


@task
def insert_indicators_task(indicators: Dict[str, Any]) -> None:
    """Insert indicator metadata into database."""
    logger = get_run_logger()
    
    if not indicators:
        logger.warning("No indicators to insert")
        return
    
    with get_db_connection() as conn:
        cursor = conn.cursor()
        
        indicator_data = [
            (
                indicator,
                value["label"],
                value["description"], 
                value["source"],
                value["unit"],
                value["dataset"],
            )
            for indicator, value in indicators.items()
        ]
        
        insert_query = """
            INSERT INTO imf_indicators (indicator, label, description, source, unit, dataset)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT (indicator) DO NOTHING
        """
        
        execute_batch(cursor, insert_query, indicator_data, page_size=100)
        conn.commit()
        
        logger.info(f"Inserted {len(indicator_data)} indicators to postgres")


@task(retries=3)
def fetch_identifiers_task() -> Dict[str, Dict]:
    """Fetch country, region, and group identifiers."""
    logger = get_run_logger()
    
    fetcher = ImfDataFetcher(
        start_date=START_YEAR, 
        end_date=END_YEAR, 
        columns=INDICATORS
    )
    
    results = {}
    for identifier_type in ["countries", "regions", "groups"]:
        try:
            identifier_dict = fetcher.fetch_identifiers(identifier_type)
            logger.info(f"Fetched {len(identifier_dict[identifier_type])} {identifier_type} identifiers")
            results[identifier_type] = identifier_dict
        except Exception as e:
            logger.error(f"Failed to fetch {identifier_type}: {e}")
            results[identifier_type] = {}
    
    return results


@task
def insert_identifiers_task(identifiers: Dict[str, Dict]) -> None:
    """Insert country/region/group identifiers into database."""
    logger = get_run_logger()
    
    with get_db_connection() as conn:
        cursor = conn.cursor()
        
        for identifier_type, codes in identifiers.items():
            if not codes:
                logger.warning(f"No {identifier_type} to insert")
                continue
                
            data = codes[identifier_type]
            
            identifier_data = [
                (code, value["label"]) 
                for code, value in data.items()
            ]
            
            if identifier_data:
                insert_query = f"""
                    INSERT INTO imf_{identifier_type} (code, label) 
                    VALUES (%s, %s) 
                    ON CONFLICT (code) DO NOTHING
                """
                
                execute_batch(cursor, insert_query, identifier_data, page_size=100)
                logger.info(f"Inserted {len(identifier_data)} {identifier_type} to postgres")
        
        conn.commit()


@task(retries=3)
def fetch_data_task() -> Dict[str, Dict]:
    """Fetch the actual IMF economic data."""
    logger = get_run_logger()
    
    fetcher = ImfDataFetcher(
        start_date=START_YEAR, 
        end_date=END_YEAR, 
        columns=INDICATORS
    )
    
    data = fetcher.fetch_data()
    
    total_rows = sum(
        len(year_data) 
        for country_data in data.values() 
        for year_data in country_data.values()
    )
    
    logger.info(f"Fetched {total_rows} rows of data across {len(data)} indicators")
    
    if not data:
        raise ValueError("No data fetched")
    
    return data


@task
def insert_data_task(data: Dict[str, Dict]) -> None:
    """Insert economic data into database."""
    logger = get_run_logger()
    
    if not data:
        logger.warning("No data to insert")
        return
    
    with get_db_connection() as conn:
        cursor = conn.cursor()
        
        all_data = []
        for indicator, country_data in data.items():
            for country, year_data in country_data.items():
                for year, value in year_data.items():
                    if value is not None:
                        all_data.append((indicator, country, year, value))
        
        if all_data:
            insert_query = """
                INSERT INTO imf_data (indicator, code, year, value)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (indicator, code, year) DO UPDATE SET value = EXCLUDED.value
            """
            
            execute_batch(cursor, insert_query, all_data, page_size=1000)
            conn.commit()
            
            logger.info(f"Inserted {len(all_data)} rows to postgres")
        else:
            logger.warning("No valid data rows to insert")


@task(retries=2)
def run_dbt() -> Any:
    """Run dbt transformations."""
    logger = get_run_logger()
    logger.info("Running dbt transformations")
    
    result = ShellOperation(commands=[f"cd {BASE_DIR}/dbt && dbt run --full-refresh"])
    
    logger.info("dbt transformations completed successfully")
    return result


@flow(
    name="imf_ingestion_flow",
    description="IMF economic data ingestion pipeline",
    flow_run_name=f"imf-ingestion-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
)
def imf_pipeline():
    """Main IMF data ingestion pipeline."""
    logger = get_run_logger()
    logger.info("Starting IMF data ingestion pipeline")
    
    try:
        create_tables()

        indicators = fetch_indicators_task()
        insert_indicators_task(indicators)

        identifiers = fetch_identifiers_task()
        insert_identifiers_task(identifiers)

        data = fetch_data_task()
        insert_data_task(data)

        run_dbt()
        
        logger.info("IMF data ingestion pipeline completed successfully")
        
    except Exception as e:
        logger.error(f"Pipeline failed: {e}")
        raise


if __name__ == "__main__":
    imf_pipeline()