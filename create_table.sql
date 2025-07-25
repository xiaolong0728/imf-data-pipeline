DROP TABLE IF EXISTS imf_data;
DROP TABLE IF EXISTS imf_indicators;
DROP TABLE IF EXISTS imf_countries;
DROP TABLE IF EXISTS imf_regions;
DROP TABLE IF EXISTS imf_groups;

CREATE TABLE IF NOT EXISTS imf_indicators (
    indicator VARCHAR(255) PRIMARY KEY,
    label VARCHAR(255),
    description TEXT,
    source VARCHAR(255),
    unit VARCHAR(255),
    dataset VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS imf_data (    
    indicator VARCHAR(255),
    code VARCHAR(255),
    year INT,
    value FLOAT,
    PRIMARY KEY (indicator, code, year)
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


