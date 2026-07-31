-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 06: Create Cortex Search Services (3)
-- ============================================================================
-- Creates 3 search services:
--   1. OPERATIONAL_NOTES_SEARCH — Recommendation reasons, alert descriptions,
--      schedule change explanations
--   2. SUPPLIER_EVENTS_SEARCH — Supplier disruption history (force majeure,
--      delays, quality holds, capacity changes, price increases)
--   3. RISK_INTELLIGENCE_SEARCH — Trade lane notes + material risk profile
--      notes for sourcing risk and logistics intelligence
-- ============================================================================

USE DATABASE FS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FIRST_SOLAR_WH;

-- ── Search Service 1: Operational Notes ─────────────────────────────────────
CREATE OR REPLACE CORTEX SEARCH SERVICE FS_INTELLIGENCE.ANALYTICS.OPERATIONAL_NOTES_SEARCH
  ON search_text
  ATTRIBUTES source_type, plant_id, material_id, date_ref, severity
  WAREHOUSE = FIRST_SOLAR_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search over operational notes: supply recommendation reasons, anomaly alert descriptions, and manufacturing schedule change explanations. Use for WHY questions.'
AS
  -- Supply recommendation trigger reasons
  SELECT
    r.TRIGGER_REASON AS search_text,
    'SUPPLY_RECOMMENDATION' AS source_type,
    r.PLANT_ID,
    r.MATERIAL_ID,
    r.RECOMMENDATION_DATE::VARCHAR AS date_ref,
    r.PRIORITY AS severity,
    r.RECOMMENDATION_ID::VARCHAR AS record_id
  FROM FS_INTELLIGENCE.RAW.SUPPLY_RECOMMENDATIONS r
  WHERE r.TRIGGER_REASON IS NOT NULL AND r.TRIGGER_REASON != ''

  UNION ALL

  -- Anomaly alert descriptions
  SELECT
    a.DESCRIPTION AS search_text,
    'ANOMALY_ALERT' AS source_type,
    a.PLANT_ID,
    a.MATERIAL_ID,
    a.ALERT_DATE::VARCHAR AS date_ref,
    a.SEVERITY,
    a.ALERT_ID::VARCHAR AS record_id
  FROM FS_INTELLIGENCE.RAW.ANOMALY_ALERTS a
  WHERE a.DESCRIPTION IS NOT NULL AND a.DESCRIPTION != ''

  UNION ALL

  -- Manufacturing schedule change reasons
  SELECT
    ms.CHANGE_REASON AS search_text,
    'SCHEDULE_CHANGE' AS source_type,
    ms.PLANT_ID,
    NULL AS material_id,
    ms.WEEK_START::VARCHAR AS date_ref,
    ms.CHANGE_TYPE AS severity,
    ms.SCHEDULE_ID::VARCHAR AS record_id
  FROM FS_INTELLIGENCE.RAW.MANUFACTURING_SCHEDULE ms
  WHERE ms.CHANGE_REASON IS NOT NULL AND ms.CHANGE_REASON != '';

-- ── Search Service 2: Supplier Events ───────────────────────────────────────
CREATE OR REPLACE CORTEX SEARCH SERVICE FS_INTELLIGENCE.ANALYTICS.SUPPLIER_EVENTS_SEARCH
  ON search_text
  ATTRIBUTES event_type, supplier_id, severity, impact_materials
  WAREHOUSE = FIRST_SOLAR_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search over supplier event history: force majeure, port delays, quality holds, capacity changes, price increases. Use for supplier disruption questions.'
AS
  SELECT
    e.DESCRIPTION AS search_text,
    e.EVENT_TYPE,
    e.SUPPLIER_ID,
    e.SEVERITY,
    e.IMPACT_MATERIALS,
    e.EVENT_ID::VARCHAR AS record_id,
    e.EVENT_DATE::VARCHAR AS event_date
  FROM FS_INTELLIGENCE.REFERENCE.SUPPLIER_EVENT_LOG e
  WHERE e.DESCRIPTION IS NOT NULL AND e.DESCRIPTION != '';

-- ── Search Service 3: Risk Intelligence ─────────────────────────────────────
CREATE OR REPLACE CORTEX SEARCH SERVICE FS_INTELLIGENCE.ANALYTICS.RISK_INTELLIGENCE_SEARCH
  ON search_text
  ATTRIBUTES source_type, material_id, supplier_id
  WAREHOUSE = FIRST_SOLAR_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search over material risk profiles and trade lane logistics notes. Use for sourcing risk, geographic concentration, substitutability, and logistics route questions.'
AS
  -- Material risk profile notes
  SELECT
    rp.NOTES AS search_text,
    'MATERIAL_RISK' AS source_type,
    rp.MATERIAL_ID,
    NULL AS supplier_id,
    rp.SOURCING_RISK_TIER AS risk_tier,
    rp.STRATEGIC_IMPORTANCE AS importance
  FROM FS_INTELLIGENCE.REFERENCE.MATERIAL_RISK_PROFILE rp
  WHERE rp.NOTES IS NOT NULL AND rp.NOTES != ''

  UNION ALL

  -- Trade lane logistics notes
  SELECT
    t.NOTES AS search_text,
    'TRADE_LANE' AS source_type,
    NULL AS material_id,
    t.SUPPLIER_ID,
    t.FREIGHT_MODE AS risk_tier,
    t.ORIGIN_COUNTRY AS importance
  FROM FS_INTELLIGENCE.REFERENCE.TRADE_LANE_DIM t
  WHERE t.NOTES IS NOT NULL AND t.NOTES != '';
