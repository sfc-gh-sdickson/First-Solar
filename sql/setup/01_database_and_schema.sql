-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 01: Database, Schemas, and Warehouse Setup
-- ============================================================================

USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS FS_INTELLIGENCE;
USE DATABASE FS_INTELLIGENCE;

-- RAW: operational tables (inventory, POs, manufacturing, etc.)
CREATE SCHEMA IF NOT EXISTS RAW;

-- ANALYTICS: curated views for reporting and agent consumption
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

-- REFERENCE: supply chain intelligence reference data (lot trace, risk, benchmarks)
CREATE SCHEMA IF NOT EXISTS REFERENCE;

CREATE WAREHOUSE IF NOT EXISTS FIRST_SOLAR_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for First Solar Supply Chain Intelligence Agent';

USE WAREHOUSE FIRST_SOLAR_WH;
USE SCHEMA RAW;
