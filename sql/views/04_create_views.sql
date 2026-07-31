-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 04: Analytical Views (ANALYTICS schema)
-- ============================================================================

USE DATABASE FS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FIRST_SOLAR_WH;

-- ── Inventory Health Summary (latest snapshot) ──────────────────────────────
CREATE OR REPLACE VIEW V_INVENTORY_HEALTH AS
SELECT
    i.plant_id,
    p.plant_name,
    m.material_id,
    m.material_name,
    m.material_category,
    m.is_critical,
    i.quantity_on_hand,
    i.safety_stock_level,
    i.reorder_point,
    i.days_forward_coverage,
    i.inventory_value,
    i.unit_cost,
    CASE
        WHEN i.quantity_on_hand < i.safety_stock_level THEN 'BELOW_SAFETY_STOCK'
        WHEN i.quantity_on_hand > i.safety_stock_level * 3 THEN 'EXCESS'
        ELSE 'HEALTHY'
    END AS inventory_status,
    ROUND(i.quantity_on_hand - i.safety_stock_level, 2) AS surplus_deficit_qty,
    rp.sourcing_risk_tier,
    rp.substitutability,
    rp.strategic_importance
FROM RAW.INVENTORY_SNAPSHOT i
JOIN RAW.PLANTS p ON i.plant_id = p.plant_id
JOIN RAW.MATERIALS m ON i.material_id = m.material_id
LEFT JOIN REFERENCE.MATERIAL_RISK_PROFILE rp ON i.material_id = rp.material_id
WHERE i.snapshot_date = (SELECT MAX(snapshot_date) FROM RAW.INVENTORY_SNAPSHOT);

-- ── Supplier Performance Scorecard ──────────────────────────────────────────
CREATE OR REPLACE VIEW V_SUPPLIER_SCORECARD AS
SELECT
    s.supplier_id,
    s.supplier_name,
    s.country,
    s.region,
    s.supplier_tier,
    s.risk_score,
    s.on_time_rate,
    s.quality_pass_rate,
    COUNT(DISTINCT po.po_id) AS total_pos,
    SUM(po.po_value) AS total_po_value,
    SUM(CASE WHEN po.is_rush THEN 1 ELSE 0 END) AS rush_po_count,
    SUM(po.expediting_cost) AS total_expediting_cost,
    AVG(CASE WHEN po.actual_delivery_date IS NOT NULL
        THEN DATEDIFF('day', po.expected_delivery_date, po.actual_delivery_date)
        ELSE NULL END) AS avg_delivery_variance_days,
    COUNT(DISTINCT sm.material_id) AS materials_supplied,
    COUNT(DISTINCT sm.plant_id) AS plants_served
FROM RAW.SUPPLIERS s
LEFT JOIN RAW.PURCHASE_ORDERS po ON s.supplier_id = po.supplier_id
LEFT JOIN RAW.SUPPLIER_MATERIALS sm ON s.supplier_id = sm.supplier_id
GROUP BY s.supplier_id, s.supplier_name, s.country, s.region,
         s.supplier_tier, s.risk_score, s.on_time_rate, s.quality_pass_rate;

-- ── Open PO Pipeline ────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW V_OPEN_PO_PIPELINE AS
SELECT
    po.po_id,
    po.po_date,
    po.plant_id,
    p.plant_name,
    po.supplier_id,
    s.supplier_name,
    po.material_id,
    m.material_name,
    m.material_category,
    m.is_critical,
    po.ordered_qty,
    po.po_value,
    po.po_status,
    po.is_rush,
    po.expediting_cost,
    po.requested_delivery_date,
    po.expected_delivery_date,
    DATEDIFF('day', CURRENT_DATE(), po.expected_delivery_date) AS days_until_expected,
    CASE
        WHEN po.expected_delivery_date < CURRENT_DATE() THEN 'OVERDUE'
        WHEN po.expected_delivery_date <= DATEADD('day', 7, CURRENT_DATE()) THEN 'DUE_THIS_WEEK'
        ELSE 'ON_TRACK'
    END AS delivery_risk
FROM RAW.PURCHASE_ORDERS po
JOIN RAW.PLANTS p ON po.plant_id = p.plant_id
JOIN RAW.SUPPLIERS s ON po.supplier_id = s.supplier_id
JOIN RAW.MATERIALS m ON po.material_id = m.material_id
WHERE po.po_status IN ('Open', 'In Transit');

-- ── Manufacturing Schedule Adherence ────────────────────────────────────────
CREATE OR REPLACE VIEW V_MANUFACTURING_ADHERENCE AS
SELECT
    ms.plant_id,
    p.plant_name,
    ms.week_start,
    ms.week_end,
    ms.week_number,
    ms.planned_qty,
    ms.revised_qty,
    ms.actual_qty,
    ms.status,
    ms.change_type,
    ms.change_pct,
    ms.change_reason,
    CASE WHEN ms.actual_qty IS NOT NULL AND ms.planned_qty > 0
        THEN ROUND((ms.actual_qty::FLOAT / ms.planned_qty) * 100, 1)
        ELSE NULL
    END AS adherence_pct,
    COALESCE(ms.actual_qty, ms.revised_qty) - ms.planned_qty AS volume_delta
FROM RAW.MANUFACTURING_SCHEDULE ms
JOIN RAW.PLANTS p ON ms.plant_id = p.plant_id;

-- ── Supply Recommendations with Context ─────────────────────────────────────
CREATE OR REPLACE VIEW V_RECOMMENDATIONS_ENRICHED AS
SELECT
    r.recommendation_id,
    r.recommendation_date,
    r.plant_id,
    p.plant_name,
    r.material_id,
    m.material_name,
    m.material_category,
    m.is_critical,
    r.recommendation_type,
    r.priority,
    r.trigger_reason,
    r.recommended_qty,
    r.recommended_supplier_id,
    rs.supplier_name AS recommended_supplier_name,
    r.recommended_source_plant,
    r.estimated_cost,
    r.days_until_stockout,
    r.current_on_hand,
    r.safety_stock_level,
    r.days_forward_coverage,
    r.material_lead_time,
    r.lead_time_variability,
    r.action_taken,
    rp.sourcing_risk_tier,
    rp.substitutability,
    rp.strategic_importance
FROM RAW.SUPPLY_RECOMMENDATIONS r
JOIN RAW.PLANTS p ON r.plant_id = p.plant_id
JOIN RAW.MATERIALS m ON r.material_id = m.material_id
LEFT JOIN RAW.SUPPLIERS rs ON r.recommended_supplier_id = rs.supplier_id
LEFT JOIN REFERENCE.MATERIAL_RISK_PROFILE rp ON r.material_id = rp.material_id;

-- ── Demand Forecast Accuracy ────────────────────────────────────────────────
CREATE OR REPLACE VIEW V_FORECAST_ACCURACY AS
SELECT
    pdf.plant_id,
    p.plant_name,
    pdf.product_id,
    pdf.week_start,
    pdf.actual_modules,
    pdf.forecast_modules,
    pdf.lower_bound,
    pdf.upper_bound,
    pdf.is_future,
    CASE WHEN pdf.actual_modules > 0
        THEN ROUND(ABS(pdf.actual_modules - pdf.forecast_modules) / pdf.actual_modules * 100, 2)
        ELSE NULL
    END AS absolute_pct_error,
    CASE WHEN pdf.actual_modules IS NOT NULL
        THEN CASE WHEN pdf.actual_modules BETWEEN pdf.lower_bound AND pdf.upper_bound
            THEN TRUE ELSE FALSE END
        ELSE NULL
    END AS within_confidence_band
FROM RAW.PRODUCT_DEMAND_FORECAST pdf
JOIN RAW.PLANTS p ON pdf.plant_id = p.plant_id;

-- ── Anomaly Alert Summary ───────────────────────────────────────────────────
CREATE OR REPLACE VIEW V_ANOMALY_SUMMARY AS
SELECT
    a.alert_id,
    a.alert_date,
    a.alert_type,
    a.severity,
    a.plant_id,
    p.plant_name,
    a.material_id,
    m.material_name,
    a.supplier_id,
    s.supplier_name,
    a.description,
    a.metric_value,
    a.expected_value,
    a.deviation_pct,
    a.is_resolved
FROM RAW.ANOMALY_ALERTS a
LEFT JOIN RAW.PLANTS p ON a.plant_id = p.plant_id
LEFT JOIN RAW.MATERIALS m ON a.material_id = m.material_id
LEFT JOIN RAW.SUPPLIERS s ON a.supplier_id = s.supplier_id;
