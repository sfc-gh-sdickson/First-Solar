-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 08: ML Model Functions (UDFs)
-- ============================================================================
-- AGENT_PREDICT_STOCKOUT_RISK — Calls registered STOCKOUT_RISK_MODEL
-- AGENT_GET_DEMAND_FORECAST — Returns 8-week forecast from PRODUCT_DEMAND_FORECAST
-- AGENT_GET_MATERIAL_RISK_SUMMARY — Returns high-risk material profiles
-- AGENT_GET_SUPPLY_CHAIN_KPIS — Returns executive KPI dashboard
--
-- NOTE: AGENT_PREDICT_STOCKOUT_RISK uses MODEL()!PREDICT() which requires
-- the ML model to be registered via notebooks/07_ml_models.ipynb first.
-- If the model is not yet registered, the function will fall back to a
-- heuristic-based risk score.
-- ============================================================================

USE DATABASE FS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FIRST_SOLAR_WH;

-- ── UDF 1: Stockout Risk Prediction (MODEL-based) ───────────────────────────
-- Calls the registered STOCKOUT_RISK_MODEL via MODEL()!PREDICT()
-- Fallback: heuristic if model not yet registered
CREATE OR REPLACE FUNCTION AGENT_PREDICT_STOCKOUT_RISK()
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'plant_id', plant_id,
    'material_id', material_id,
    'material_name', material_name,
    'material_category', material_category,
    'is_critical', is_critical,
    'days_forward_coverage', days_forward_coverage,
    'safety_stock_level', safety_stock_level,
    'quantity_on_hand', quantity_on_hand,
    'stockout_risk_score', stockout_risk_score,
    'risk_category', risk_category
)) FROM (
    SELECT
        i.PLANT_ID AS plant_id,
        i.MATERIAL_ID AS material_id,
        m.MATERIAL_NAME AS material_name,
        m.MATERIAL_CATEGORY AS material_category,
        m.IS_CRITICAL AS is_critical,
        i.DAYS_FORWARD_COVERAGE AS days_forward_coverage,
        i.SAFETY_STOCK_LEVEL AS safety_stock_level,
        i.QUANTITY_ON_HAND AS quantity_on_hand,
        -- Call registered model: MODEL(db.schema.model, version)!PREDICT(features)
        -- Model input features: QUANTITY_ON_HAND, SAFETY_STOCK_LEVEL, DAYS_FORWARD_COVERAGE,
        --   REORDER_POINT, UNIT_COST, LEAD_TIME_DAYS, LEAD_TIME_VARIABILITY_DAYS, CAT_ENC, IS_CRITICAL
        -- Fallback to heuristic if model not available
        COALESCE(
            TRY_CAST(
                MODEL(FS_INTELLIGENCE.ANALYTICS.STOCKOUT_RISK_MODEL, 'V1')!PREDICT(
                    i.QUANTITY_ON_HAND, i.SAFETY_STOCK_LEVEL, i.DAYS_FORWARD_COVERAGE,
                    i.REORDER_POINT, i.UNIT_COST,
                    COALESCE(sm.LEAD_TIME_DAYS, 30),
                    COALESCE(sm.LEAD_TIME_VARIABILITY_DAYS, 5),
                    0, -- CAT_ENC placeholder
                    CASE WHEN m.IS_CRITICAL THEN 1 ELSE 0 END
                ):output_feature_0 AS FLOAT
            ),
            -- Heuristic fallback if model not registered
            LEAST(1.0, GREATEST(0.0,
                CASE WHEN i.SAFETY_STOCK_LEVEL > 0
                    THEN (i.SAFETY_STOCK_LEVEL - i.QUANTITY_ON_HAND) / i.SAFETY_STOCK_LEVEL
                    ELSE 0 END
            ))
        ) AS stockout_risk_score,
        CASE
            WHEN i.QUANTITY_ON_HAND < i.SAFETY_STOCK_LEVEL * 0.5 THEN 'CRITICAL'
            WHEN i.QUANTITY_ON_HAND < i.SAFETY_STOCK_LEVEL THEN 'HIGH'
            WHEN i.DAYS_FORWARD_COVERAGE < 30 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_category
    FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT i
    JOIN FS_INTELLIGENCE.RAW.MATERIALS m ON i.MATERIAL_ID = m.MATERIAL_ID
    LEFT JOIN (
        SELECT PLANT_ID, MATERIAL_ID,
               MIN(LEAD_TIME_DAYS) AS LEAD_TIME_DAYS,
               MIN(LEAD_TIME_VARIABILITY_DAYS) AS LEAD_TIME_VARIABILITY_DAYS
        FROM FS_INTELLIGENCE.RAW.SUPPLIER_MATERIALS
        GROUP BY PLANT_ID, MATERIAL_ID
    ) sm ON i.PLANT_ID = sm.PLANT_ID AND i.MATERIAL_ID = sm.MATERIAL_ID
    WHERE i.SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT)
      AND i.QUANTITY_ON_HAND < i.SAFETY_STOCK_LEVEL * 1.2
    ORDER BY stockout_risk_score DESC
    LIMIT 25
)
$$;

-- ── UDF 2: Demand Forecast Summary ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION AGENT_GET_DEMAND_FORECAST()
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'plant_id', PLANT_ID,
    'product_id', PRODUCT_ID,
    'week_start', WEEK_START::VARCHAR,
    'forecast_modules', FORECAST_MODULES,
    'lower_bound', LOWER_BOUND,
    'upper_bound', UPPER_BOUND
)) FROM (
    SELECT PLANT_ID, PRODUCT_ID, WEEK_START, FORECAST_MODULES, LOWER_BOUND, UPPER_BOUND
    FROM FS_INTELLIGENCE.RAW.PRODUCT_DEMAND_FORECAST
    WHERE IS_FUTURE = TRUE
    ORDER BY PLANT_ID, PRODUCT_ID, WEEK_START
    LIMIT 50
)
$$;

-- ── UDF 3: Material Risk Summary ────────────────────────────────────────────
CREATE OR REPLACE FUNCTION AGENT_GET_MATERIAL_RISK_SUMMARY()
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'material_id', rp.MATERIAL_ID,
    'material_name', m.MATERIAL_NAME,
    'material_category', m.MATERIAL_CATEGORY,
    'sourcing_risk_tier', rp.SOURCING_RISK_TIER,
    'substitutability', rp.SUBSTITUTABILITY,
    'strategic_importance', rp.STRATEGIC_IMPORTANCE,
    'avg_lead_time_days', rp.AVG_LEAD_TIME_DAYS,
    'lead_time_volatility_cv', rp.LEAD_TIME_VOLATILITY_CV,
    'geographic_concentration_pct', rp.GEOGRAPHIC_CONCENTRATION_PCT,
    'notes', rp.NOTES
)) FROM (
    SELECT rp.*, m.MATERIAL_NAME, m.MATERIAL_CATEGORY
    FROM FS_INTELLIGENCE.REFERENCE.MATERIAL_RISK_PROFILE rp
    JOIN FS_INTELLIGENCE.RAW.MATERIALS m ON rp.MATERIAL_ID = m.MATERIAL_ID
    WHERE rp.SOURCING_RISK_TIER IN ('SINGLE_SOURCE', 'DUAL_SOURCE')
      AND rp.STRATEGIC_IMPORTANCE IN ('CRITICAL', 'HIGH')
    ORDER BY
        CASE rp.SOURCING_RISK_TIER WHEN 'SINGLE_SOURCE' THEN 1 ELSE 2 END,
        CASE rp.STRATEGIC_IMPORTANCE WHEN 'CRITICAL' THEN 1 ELSE 2 END
    LIMIT 20
) sub
JOIN FS_INTELLIGENCE.REFERENCE.MATERIAL_RISK_PROFILE rp ON sub.MATERIAL_ID = rp.MATERIAL_ID
JOIN FS_INTELLIGENCE.RAW.MATERIALS m ON rp.MATERIAL_ID = m.MATERIAL_ID
$$;

-- ── UDF 4: Supply Chain KPI Dashboard ───────────────────────────────────────
CREATE OR REPLACE FUNCTION AGENT_GET_SUPPLY_CHAIN_KPIS()
RETURNS OBJECT
AS
$$
SELECT OBJECT_CONSTRUCT(
    'total_inventory_value', (
        SELECT ROUND(SUM(INVENTORY_VALUE), 2)
        FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT
        WHERE SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT)
    ),
    'avg_days_forward_coverage', (
        SELECT ROUND(AVG(DAYS_FORWARD_COVERAGE), 1)
        FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT
        WHERE SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT)
    ),
    'open_po_count', (
        SELECT COUNT(*) FROM FS_INTELLIGENCE.RAW.PURCHASE_ORDERS WHERE PO_STATUS IN ('Open', 'In Transit')
    ),
    'open_po_value', (
        SELECT ROUND(SUM(PO_VALUE), 2) FROM FS_INTELLIGENCE.RAW.PURCHASE_ORDERS WHERE PO_STATUS IN ('Open', 'In Transit')
    ),
    'total_expediting_cost', (
        SELECT ROUND(SUM(EXPEDITING_COST), 2) FROM FS_INTELLIGENCE.RAW.PURCHASE_ORDERS WHERE IS_RUSH = TRUE
    ),
    'critical_recommendations', (
        SELECT COUNT(*) FROM FS_INTELLIGENCE.RAW.SUPPLY_RECOMMENDATIONS WHERE PRIORITY IN ('CRITICAL', 'HIGH') AND ACTION_TAKEN = FALSE
    ),
    'unresolved_high_alerts', (
        SELECT COUNT(*) FROM FS_INTELLIGENCE.RAW.ANOMALY_ALERTS WHERE IS_RESOLVED = FALSE AND SEVERITY = 'HIGH'
    ),
    'manufacturing_adherence_pct', (
        SELECT ROUND(SUM(ACTUAL_QTY)::FLOAT / NULLIF(SUM(PLANNED_QTY), 0) * 100, 1)
        FROM FS_INTELLIGENCE.RAW.MANUFACTURING_SCHEDULE WHERE STATUS = 'COMPLETED'
    ),
    'materials_below_safety_stock', (
        SELECT COUNT(*) FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT
        WHERE SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT)
          AND QUANTITY_ON_HAND < SAFETY_STOCK_LEVEL
    ),
    'overdue_po_count', (
        SELECT COUNT(*) FROM FS_INTELLIGENCE.RAW.PURCHASE_ORDERS
        WHERE PO_STATUS = 'In Transit' AND EXPECTED_DELIVERY_DATE < CURRENT_DATE()
    )
)
$$;
