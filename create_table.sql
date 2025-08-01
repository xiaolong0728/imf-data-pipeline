DROP TABLE IF EXISTS imf_data CASCADE;
DROP TABLE IF EXISTS imf_indicators CASCADE;
DROP TABLE IF EXISTS imf_countries CASCADE;
DROP TABLE IF EXISTS imf_regions CASCADE;
DROP TABLE IF EXISTS imf_groups CASCADE;

CREATE TABLE IF NOT EXISTS imf_data (    
    indicator VARCHAR(255),
    code VARCHAR(255),
    year INT,
    value FLOAT,
    PRIMARY KEY (indicator, code, year)
) PARTITION BY RANGE (year);

CREATE TABLE IF NOT EXISTS imf_data_2000_2004 PARTITION OF imf_data 
    FOR VALUES FROM (2000) TO (2005);

CREATE TABLE IF NOT EXISTS imf_data_2005_2009 PARTITION OF imf_data 
    FOR VALUES FROM (2005) TO (2010);

CREATE TABLE IF NOT EXISTS imf_data_2010_2014 PARTITION OF imf_data 
    FOR VALUES FROM (2010) TO (2015);

CREATE TABLE IF NOT EXISTS imf_data_2015_2019 PARTITION OF imf_data 
    FOR VALUES FROM (2015) TO (2020);

CREATE TABLE IF NOT EXISTS imf_data_2020_2024 PARTITION OF imf_data 
    FOR VALUES FROM (2020) TO (2025);

CREATE TABLE IF NOT EXISTS imf_indicators (
    indicator VARCHAR(255) PRIMARY KEY,
    label VARCHAR(255),
    description TEXT,
    source VARCHAR(255),
    unit VARCHAR(255),
    dataset VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS imf_countries (    
    code VARCHAR(255) PRIMARY KEY,
    label VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS imf_regions (
    code VARCHAR(255) PRIMARY KEY,
    label VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS imf_groups (
    code VARCHAR(255) PRIMARY KEY,
    label VARCHAR(255)
);


