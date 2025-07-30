# IMF Economic Data Pipeline

This project fetches, transforms, and stores IMF economic indicators using Prefect, PostgreSQL, and Metabase. It covers ingestion, transformation with dbt, and dashboarding.

---

## 🏗️ Project Structure
```bash
imf-data-pipeline
├── create_table.sql 
├── docker-compose.yml 
├── ingestion/
│ └── fetch_data.py 
├── dbt/
│ └── ... # dbt project
├── flows/
│ └── imf_ingestion_flow.py 
├── requirements.txt
└── README.md
```

## 🚀 Getting Started

### 1. Clone this repository

```bash
git clone https://github.com/yourusername/imf-pipeline.git
cd imf-pipeline
```

### 2. Start Services
```bash
docker-compose up -d
```
PostgreSQL runs on localhost:5433. Metabase runs at http://localhost:3000.

### 3. Install Dependencies
Create a virtual environment and install Python packages:
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 4. Run the Pipeline
```bash
python pipeline/imf_pipeline.py
```
This will:
- Create tables
- Fetch indicators, countries, regions, and groups
- Fetch and insert time-series economic data
- Run dbt transformations


## 🧠 Technologies Used
- [Prefect](https://docs.prefect.io/)
- [PostgreSQL](https://www.postgresql.org/)
- [Metabase](https://www.metabase.com/)
- [dbt](https://www.getdbt.com/)

## 📊 Dashboard (Metabase)
- URL: http://localhost:3000

- Set up using PostgreSQL with:
    - Host: postgres_imf
    - Port: 5432
    - DB Name: imf_data
    - User/Password: xiaolong / xiaolong

## 📦 Deployment Notes
- PostgreSQL data is persisted via Docker volume `postgres_data`.

- `create_table.sql` uses range partitioning for better performance.

- dbt models are located in the `/dbt` directory.

