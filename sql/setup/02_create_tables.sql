-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 02: Table Definitions (RAW + REFERENCE schemas)
-- ============================================================================

USE DATABASE FS_INTELLIGENCE;
USE SCHEMA RAW;

-- ============================================================
-- REFERENCE / DIMENSION TABLES
-- ============================================================

CREATE OR REPLACE TABLE PLANTS (
    plant_id        VARCHAR(10)     NOT NULL,
    plant_name      VARCHAR(100)    NOT NULL,
    city            VARCHAR(100),
    state           VARCHAR(50),
    country         VARCHAR(50)     DEFAULT 'USA',
    region          VARCHAR(50),
    capacity_mw     NUMBER(10,2),
    PRIMARY KEY (plant_id)
);

CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id     VARCHAR(20)     NOT NULL,
    customer_name   VARCHAR(200)    NOT NULL,
    city            VARCHAR(100),
    state           VARCHAR(50),
    country         VARCHAR(50)     DEFAULT 'USA',
    region          VARCHAR(50),
    segment         VARCHAR(50),
    PRIMARY KEY (customer_id)
);

CREATE OR REPLACE TABLE MATERIALS (
    material_id         VARCHAR(20)     NOT NULL,
    material_name       VARCHAR(200)    NOT NULL,
    material_category   VARCHAR(100),
    unit_of_measure     VARCHAR(20),
    unit_cost_std       NUMBER(12,4),
    is_critical         BOOLEAN         DEFAULT FALSE,
    PRIMARY KEY (material_id)
);

CREATE OR REPLACE TABLE SUPPLIERS (
    supplier_id         VARCHAR(20)     NOT NULL,
    supplier_name       VARCHAR(200)    NOT NULL,
    city                VARCHAR(100),
    state               VARCHAR(50),
    country             VARCHAR(50),
    region              VARCHAR(50),
    supplier_tier       VARCHAR(10),
    risk_score          NUMBER(4,2),
    on_time_rate        NUMBER(5,4),
    quality_pass_rate   NUMBER(5,4),
    PRIMARY KEY (supplier_id)
);

CREATE OR REPLACE TABLE SUPPLIER_MATERIALS (
    supplier_id         VARCHAR(20)     NOT NULL,
    material_id         VARCHAR(20)     NOT NULL,
    plant_id            VARCHAR(10)     NOT NULL,
    lead_time_days      NUMBER(5),
    lead_time_variability_days NUMBER(5),
    unit_price          NUMBER(12,4),
    min_order_qty       NUMBER(10),
    PRIMARY KEY (supplier_id, material_id, plant_id)
);

CREATE OR REPLACE TABLE BILL_OF_MATERIALS (
    bom_id          NUMBER AUTOINCREMENT PRIMARY KEY,
    product_id      VARCHAR(20)     NOT NULL,
    product_name    VARCHAR(200),
    material_id     VARCHAR(20)     NOT NULL,
    qty_per_unit    NUMBER(12,6),
    unit_of_measure VARCHAR(20)
);

-- ============================================================
-- INVENTORY & PLANNING TABLES
-- ============================================================

CREATE OR REPLACE TABLE INVENTORY_SNAPSHOT (
    snapshot_id         NUMBER AUTOINCREMENT PRIMARY KEY,
    snapshot_date       DATE            NOT NULL,
    plant_id            VARCHAR(10)     NOT NULL,
    material_id         VARCHAR(20)     NOT NULL,
    quantity_on_hand    NUMBER(14,4),
    unit_cost           NUMBER(12,4),
    inventory_value     NUMBER(18,4),
    safety_stock_level  NUMBER(14,4),
    reorder_point       NUMBER(14,4),
    days_forward_coverage NUMBER(8,2)
);

CREATE OR REPLACE TABLE MRP_DEMAND (
    demand_id       NUMBER AUTOINCREMENT PRIMARY KEY,
    demand_date     DATE            NOT NULL,
    plant_id        VARCHAR(10)     NOT NULL,
    material_id     VARCHAR(20)     NOT NULL,
    customer_id     VARCHAR(20),
    product_id      VARCHAR(20),
    required_qty    NUMBER(14,4),
    demand_type     VARCHAR(30)
);

-- ============================================================
-- PROCUREMENT TABLES
-- ============================================================

CREATE OR REPLACE TABLE PURCHASE_ORDERS (
    po_id               VARCHAR(20)     NOT NULL,
    po_date             DATE            NOT NULL,
    plant_id            VARCHAR(10)     NOT NULL,
    supplier_id         VARCHAR(20)     NOT NULL,
    material_id         VARCHAR(20)     NOT NULL,
    ordered_qty         NUMBER(14,4),
    unit_price          NUMBER(12,4),
    po_value            NUMBER(18,4),
    requested_delivery_date DATE,
    expected_delivery_date  DATE,
    actual_delivery_date    DATE,
    po_status           VARCHAR(30),
    is_rush             BOOLEAN         DEFAULT FALSE,
    expediting_cost     NUMBER(12,4)    DEFAULT 0,
    PRIMARY KEY (po_id)
);

CREATE OR REPLACE TABLE PO_RECEIPTS (
    receipt_id          NUMBER AUTOINCREMENT PRIMARY KEY,
    po_id               VARCHAR(20)     NOT NULL,
    receipt_date        DATE            NOT NULL,
    plant_id            VARCHAR(10)     NOT NULL,
    material_id         VARCHAR(20)     NOT NULL,
    received_qty        NUMBER(14,4),
    unit_cost           NUMBER(12,4),
    quality_status      VARCHAR(20)
);

-- ============================================================
-- TRANSFER TABLES
-- ============================================================

CREATE OR REPLACE TABLE INVENTORY_TRANSFERS (
    transfer_id         VARCHAR(20)     NOT NULL,
    transfer_date       DATE            NOT NULL,
    from_plant_id       VARCHAR(10)     NOT NULL,
    to_plant_id         VARCHAR(10)     NOT NULL,
    material_id         VARCHAR(20)     NOT NULL,
    transfer_qty        NUMBER(14,4),
    unit_cost           NUMBER(12,4),
    transfer_cost       NUMBER(12,4),
    transit_days        NUMBER(5),
    expected_arrival_date DATE,
    actual_arrival_date   DATE,
    transfer_status     VARCHAR(30),
    PRIMARY KEY (transfer_id)
);

-- ============================================================
-- RECOMMENDATION ENGINE OUTPUT
-- ============================================================

CREATE OR REPLACE TABLE SUPPLY_RECOMMENDATIONS (
    recommendation_id   NUMBER AUTOINCREMENT PRIMARY KEY,
    recommendation_date DATE            NOT NULL,
    plant_id            VARCHAR(10)     NOT NULL,
    material_id         VARCHAR(20)     NOT NULL,
    recommendation_type VARCHAR(30),
    priority            VARCHAR(10),
    trigger_reason      VARCHAR(500),
    recommended_qty     NUMBER(14,4),
    recommended_supplier_id VARCHAR(20),
    recommended_source_plant VARCHAR(10),
    estimated_cost      NUMBER(18,4),
    days_until_stockout NUMBER(8,2),
    current_on_hand     NUMBER(14,4),
    safety_stock_level  NUMBER(14,4),
    days_forward_coverage NUMBER(8,2),
    material_lead_time  NUMBER(5),
    lead_time_variability NUMBER(5),
    action_taken        BOOLEAN         DEFAULT FALSE
);

-- ============================================================
-- ANOMALY DETECTION OUTPUT
-- ============================================================

CREATE OR REPLACE TABLE ANOMALY_ALERTS (
    alert_id            NUMBER AUTOINCREMENT PRIMARY KEY,
    alert_date          DATE            NOT NULL,
    alert_type          VARCHAR(50),
    severity            VARCHAR(10),
    plant_id            VARCHAR(10),
    material_id         VARCHAR(20),
    supplier_id         VARCHAR(20),
    description         VARCHAR(500),
    metric_value        NUMBER(18,4),
    expected_value      NUMBER(18,4),
    deviation_pct       NUMBER(8,4),
    is_resolved         BOOLEAN         DEFAULT FALSE
);

-- ============================================================
-- MANUFACTURING SCHEDULE
-- ============================================================

CREATE OR REPLACE TABLE MANUFACTURING_SCHEDULE (
    schedule_id     NUMBER AUTOINCREMENT PRIMARY KEY,
    plant_id        VARCHAR(10)     NOT NULL,
    week_start      DATE            NOT NULL,
    week_end        DATE            NOT NULL,
    week_number     NUMBER(3),
    planned_qty     NUMBER(10),
    revised_qty     NUMBER(10),
    actual_qty      NUMBER(10),
    status          VARCHAR(20),
    change_type     VARCHAR(30),
    change_pct      NUMBER(6,1),
    change_reason   VARCHAR(500)
);

-- ============================================================
-- DEMAND FORECAST (ML-generated)
-- ============================================================

CREATE OR REPLACE TABLE PRODUCT_DEMAND_FORECAST (
    plant_id        VARCHAR(10)     NOT NULL,
    product_id      VARCHAR(20)     NOT NULL,
    week_start      DATE            NOT NULL,
    actual_modules  NUMBER(10,1),
    forecast_modules NUMBER(10,1),
    lower_bound     NUMBER(10,1),
    upper_bound     NUMBER(10,1),
    is_future       BOOLEAN
);

CREATE OR REPLACE TABLE DEMAND_FORECAST (
    plant_id        VARCHAR(10)     NOT NULL,
    material_id     VARCHAR(20)     NOT NULL,
    week_start      DATE            NOT NULL,
    forecast_demand NUMBER(14,2),
    lower_bound     NUMBER(14,2),
    upper_bound     NUMBER(14,2),
    actual_demand   NUMBER(14,2),
    is_future       BOOLEAN
);

CREATE OR REPLACE TABLE FORECAST_MODEL_META (
    key     VARCHAR(100),
    value   NUMBER(12,5)
);

-- ============================================================
-- REFERENCE SCHEMA: Supply Chain Intelligence Tables
-- ============================================================

USE SCHEMA REFERENCE;

CREATE OR REPLACE TABLE MATERIAL_LOT_TRACE (
    lot_id              VARCHAR(30)     NOT NULL,
    event_type          VARCHAR(20)     NOT NULL,  -- RECEIVED, CONSUMED, PRODUCED, SHIPPED
    event_date          DATE            NOT NULL,
    plant_id            VARCHAR(10)     NOT NULL,
    material_id         VARCHAR(20),
    po_id               VARCHAR(20),
    schedule_id         NUMBER,
    parent_lot_id       VARCHAR(30),
    quantity            NUMBER(14,4),
    description         VARCHAR(500),
    PRIMARY KEY (lot_id, event_type, event_date)
);

CREATE OR REPLACE TABLE MATERIAL_RISK_PROFILE (
    material_id                 VARCHAR(20)     NOT NULL PRIMARY KEY,
    sourcing_risk_tier          VARCHAR(20),    -- SINGLE_SOURCE, DUAL_SOURCE, MULTI_SOURCE
    geographic_concentration_pct NUMBER(5,2),
    substitutability            VARCHAR(10),    -- NONE, PARTIAL, FULL
    strategic_importance        VARCHAR(10),    -- CRITICAL, HIGH, MEDIUM, LOW
    avg_lead_time_days          NUMBER(5),
    lead_time_volatility_cv     NUMBER(5,3),
    notes                       VARCHAR(500)
);

CREATE OR REPLACE TABLE TRADE_LANE_DIM (
    supplier_id             VARCHAR(20)     NOT NULL,
    plant_id                VARCHAR(10)     NOT NULL,
    origin_country          VARCHAR(50),
    port_of_entry           VARCHAR(100),
    avg_customs_days        NUMBER(4,1),
    freight_mode            VARCHAR(20),    -- OCEAN, AIR, TRUCK, RAIL
    typical_transit_days    NUMBER(5),
    tariff_pct              NUMBER(5,2),
    geopolitical_risk_score NUMBER(4,2),
    notes                   VARCHAR(500),
    PRIMARY KEY (supplier_id, plant_id)
);

CREATE OR REPLACE TABLE INDUSTRY_BENCHMARK_DIM (
    benchmark_id        NUMBER AUTOINCREMENT PRIMARY KEY,
    metric_name         VARCHAR(100)    NOT NULL,
    material_category   VARCHAR(100),
    benchmark_value     NUMBER(12,4),
    unit                VARCHAR(50),
    source              VARCHAR(200),
    effective_date      DATE
);

CREATE OR REPLACE TABLE SUPPLIER_EVENT_LOG (
    event_id            NUMBER AUTOINCREMENT PRIMARY KEY,
    event_date          DATE            NOT NULL,
    supplier_id         VARCHAR(20)     NOT NULL,
    event_type          VARCHAR(30),    -- FORCE_MAJEURE, PORT_DELAY, QUALITY_HOLD, CAPACITY_CHANGE, PRICE_INCREASE
    severity            VARCHAR(10),
    description         VARCHAR(1000),
    resolution_date     DATE,
    impact_materials    VARCHAR(500)
);
