-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 05: Create Semantic Views (3) for Cortex Analyst
-- ============================================================================
-- Creates 3 domain-specific semantic views:
--   1. SUPPLY_CHAIN_OPERATIONS_SV — Inventory, procurement, suppliers, transfers
--   2. MANUFACTURING_DEMAND_SV — Production scheduling, demand forecasting, BOM
--   3. RISK_INTELLIGENCE_SV — Risk profiles, trade lanes, benchmarks, anomalies
-- ============================================================================

USE DATABASE FS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FIRST_SOLAR_WH;

-- ════════════════════════════════════════════════════════════════════════════════
-- SEMANTIC VIEW 1: Supply Chain Operations
-- Covers: Inventory, Purchase Orders, Suppliers, Materials, Plants, Transfers,
--         Recommendations
-- ════════════════════════════════════════════════════════════════════════════════

CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'FS_INTELLIGENCE.ANALYTICS',
  $$
  name: SUPPLY_CHAIN_OPERATIONS_SV
  description: >
    First Solar supply chain operations semantic view. Covers inventory levels
    (quantity on hand, safety stock, days forward coverage), purchase orders
    (open/in-transit/received, rush orders, expediting costs), supplier
    performance (OTD, quality, risk scores), inter-plant transfers, and
    AI-generated supply recommendations across 3 US manufacturing plants
    (Alabama 3500MW, Ohio 3300MW, Louisiana 3500MW).

  tables:
    - name: INVENTORY_SNAPSHOT
      description: Weekly inventory snapshot per plant and material with quantity on hand, safety stock, and days forward coverage.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: INVENTORY_SNAPSHOT
      primary_key:
        columns: [SNAPSHOT_ID]
      dimensions:
        - name: SNAPSHOT_DATE
          synonyms: [date, as of date, week, inventory date]
          description: Date of the inventory snapshot
          expr: SNAPSHOT_DATE
          data_type: DATE
        - name: PLANT_ID
          synonyms: [plant, facility, site]
          description: Manufacturing plant identifier
          expr: PLANT_ID
          data_type: VARCHAR
        - name: MATERIAL_ID
          synonyms: [part, component, material]
          description: Material or part identifier
          expr: MATERIAL_ID
          data_type: VARCHAR
      metrics:
        - name: TOTAL_QTY_ON_HAND
          synonyms: [qty on hand, stock on hand, inventory quantity, on hand]
          description: Total quantity of material on hand
          expr: SUM(QUANTITY_ON_HAND)
        - name: TOTAL_INVENTORY_VALUE
          synonyms: [inventory dollars, stock value, dollar value]
          description: Total dollar value of inventory
          expr: SUM(INVENTORY_VALUE)
        - name: AVG_SAFETY_STOCK
          synonyms: [safety stock, minimum stock]
          description: Average safety stock level
          expr: AVG(SAFETY_STOCK_LEVEL)
        - name: AVG_DAYS_FORWARD_COVERAGE
          synonyms: [DFC, days of supply, coverage days, how many days of stock]
          description: Average days current inventory covers planned demand
          expr: AVG(DAYS_FORWARD_COVERAGE)
        - name: AVG_UNIT_COST
          synonyms: [unit price, cost per unit]
          description: Average cost per unit
          expr: AVG(UNIT_COST)

    - name: PURCHASE_ORDERS
      description: All purchase orders placed with suppliers including open, in-transit, received, rush orders, and expediting costs.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: PURCHASE_ORDERS
      primary_key:
        columns: [PO_ID]
      dimensions:
        - name: PO_ID
          synonyms: [purchase order, PO number]
          description: Unique purchase order identifier
          expr: PO_ID
          data_type: VARCHAR
        - name: PO_DATE
          synonyms: [order date, placed date]
          description: Date the purchase order was created
          expr: PO_DATE
          data_type: DATE
        - name: PLANT_ID
          synonyms: [destination plant, receiving plant]
          description: Plant receiving the material
          expr: PLANT_ID
          data_type: VARCHAR
        - name: SUPPLIER_ID
          synonyms: [vendor, supplier]
          description: Supplier fulfilling the order
          expr: SUPPLIER_ID
          data_type: VARCHAR
        - name: MATERIAL_ID
          synonyms: [part, component]
          description: Material being ordered
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: PO_STATUS
          synonyms: [order status, status]
          description: "Current status: Open, In Transit, Received, Cancelled"
          expr: PO_STATUS
          data_type: VARCHAR
          sample_values: ['Open', 'In Transit', 'Received', 'Cancelled']
          is_enum: true
        - name: IS_RUSH
          synonyms: [expedited, rush order, emergency]
          description: Whether this is a rush/expedited order
          expr: IS_RUSH
          data_type: BOOLEAN
        - name: EXPECTED_DELIVERY_DATE
          synonyms: [expected delivery, eta]
          description: Expected delivery date
          expr: EXPECTED_DELIVERY_DATE
          data_type: DATE
        - name: ACTUAL_DELIVERY_DATE
          synonyms: [actual delivery, received date]
          description: Actual receipt date
          expr: ACTUAL_DELIVERY_DATE
          data_type: DATE
      metrics:
        - name: TOTAL_ORDERED_QTY
          synonyms: [order quantity, quantity ordered]
          description: Total quantity ordered
          expr: SUM(ORDERED_QTY)
        - name: TOTAL_PO_VALUE
          synonyms: [order value, PO dollars]
          description: Total dollar value of purchase orders
          expr: SUM(PO_VALUE)
        - name: TOTAL_EXPEDITING_COST
          synonyms: [rush cost, expedite fee, premium freight]
          description: Total expediting cost for rush orders
          expr: SUM(EXPEDITING_COST)
        - name: PO_COUNT
          synonyms: [number of orders, order count]
          description: Count of purchase orders
          expr: COUNT(PO_ID)

    - name: PO_RECEIPTS
      description: Purchase order receipt records with quality inspection status (Accepted, Partial Accept, Rejected).
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: PO_RECEIPTS
      primary_key:
        columns: [RECEIPT_ID]
      dimensions:
        - name: RECEIPT_DATE
          synonyms: [received date, delivery date]
          description: Date material was received
          expr: RECEIPT_DATE
          data_type: DATE
        - name: PO_ID
          synonyms: [purchase order]
          description: Associated purchase order
          expr: PO_ID
          data_type: VARCHAR
        - name: PLANT_ID
          synonyms: [receiving plant]
          description: Plant that received the material
          expr: PLANT_ID
          data_type: VARCHAR
        - name: MATERIAL_ID
          synonyms: [part received]
          description: Material received
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: QUALITY_STATUS
          synonyms: [inspection result, QC status, quality]
          description: "Quality inspection result: Accepted, Partial Accept, Rejected"
          expr: QUALITY_STATUS
          data_type: VARCHAR
          sample_values: ['Accepted', 'Partial Accept', 'Rejected']
          is_enum: true
      metrics:
        - name: TOTAL_RECEIVED_QTY
          synonyms: [quantity received, received amount]
          description: Total quantity received
          expr: SUM(RECEIVED_QTY)
        - name: RECEIPT_COUNT
          synonyms: [number of receipts]
          description: Count of receipt records
          expr: COUNT(RECEIPT_ID)

    - name: SUPPLIERS
      description: Supplier master data with location, tier classification, risk score, on-time delivery rate, and quality pass rate.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: SUPPLIERS
      primary_key:
        columns: [SUPPLIER_ID]
      dimensions:
        - name: SUPPLIER_ID
          synonyms: [vendor id, supplier code]
          description: Unique supplier identifier
          expr: SUPPLIER_ID
          data_type: VARCHAR
        - name: SUPPLIER_NAME
          synonyms: [vendor name, supplier]
          description: Full supplier company name
          expr: SUPPLIER_NAME
          data_type: VARCHAR
        - name: COUNTRY
          synonyms: [supplier country, origin]
          description: Supplier headquarters country
          expr: COUNTRY
          data_type: VARCHAR
        - name: SUPPLIER_TIER
          synonyms: [tier, classification]
          description: "Tier1 or Tier2 classification"
          expr: SUPPLIER_TIER
          data_type: VARCHAR
          sample_values: ['Tier1', 'Tier2']
          is_enum: true
      metrics:
        - name: AVG_RISK_SCORE
          synonyms: [risk rating, supplier risk]
          description: Average risk score (1=low, 10=high)
          expr: AVG(RISK_SCORE)
        - name: AVG_ON_TIME_RATE
          synonyms: [OTD, on-time delivery rate, delivery performance]
          description: Average on-time delivery rate (0-1)
          expr: AVG(ON_TIME_RATE)
        - name: AVG_QUALITY_PASS_RATE
          synonyms: [quality rate, acceptance rate]
          description: Average quality pass rate (0-1)
          expr: AVG(QUALITY_PASS_RATE)

    - name: MATERIALS
      description: Material master data with category, standard cost, and criticality flag.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: MATERIALS
      primary_key:
        columns: [MATERIAL_ID]
      dimensions:
        - name: MATERIAL_ID
          synonyms: [part id, component id]
          description: Unique material identifier
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: MATERIAL_NAME
          synonyms: [part name, material description]
          description: Full material name
          expr: MATERIAL_NAME
          data_type: VARCHAR
        - name: MATERIAL_CATEGORY
          synonyms: [category, part type, material type]
          description: "Category: Glass, Semiconductor, Frame, Electronics, Chemicals, etc."
          expr: MATERIAL_CATEGORY
          data_type: VARCHAR
          sample_values: ['Glass', 'Semiconductor', 'Frame', 'Electronics', 'Chemicals', 'Packaging', 'Equipment Consumable', 'Backsheet', 'Thermal', 'QA Consumable', 'Hardware']
          is_enum: true
        - name: IS_CRITICAL
          synonyms: [critical part, critical material]
          description: Whether material is critical-path for production
          expr: IS_CRITICAL
          data_type: BOOLEAN
      metrics:
        - name: AVG_UNIT_COST_STD
          synonyms: [standard cost, base cost]
          description: Average standard cost per unit
          expr: AVG(UNIT_COST_STD)

    - name: PLANTS
      description: Manufacturing plant data with location and annual capacity in megawatts.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: PLANTS
      primary_key:
        columns: [PLANT_ID]
      dimensions:
        - name: PLANT_ID
          synonyms: [plant code, site id]
          description: Unique plant identifier
          expr: PLANT_ID
          data_type: VARCHAR
        - name: PLANT_NAME
          synonyms: [facility name, site name]
          description: Full plant name
          expr: PLANT_NAME
          data_type: VARCHAR
        - name: STATE
          synonyms: [plant state, location]
          description: US state
          expr: STATE
          data_type: VARCHAR
      metrics:
        - name: TOTAL_CAPACITY_MW
          synonyms: [production capacity, nameplate capacity]
          description: Total annual capacity in megawatts
          expr: SUM(CAPACITY_MW)

    - name: INVENTORY_TRANSFERS
      description: Inter-plant material transfers with freight costs, transit times, and status.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: INVENTORY_TRANSFERS
      primary_key:
        columns: [TRANSFER_ID]
      dimensions:
        - name: TRANSFER_DATE
          synonyms: [date, shipped date]
          description: Date transfer was initiated
          expr: TRANSFER_DATE
          data_type: DATE
        - name: FROM_PLANT_ID
          synonyms: [source plant, sending plant]
          description: Plant sending material
          expr: FROM_PLANT_ID
          data_type: VARCHAR
        - name: TO_PLANT_ID
          synonyms: [destination plant, receiving plant]
          description: Plant receiving material
          expr: TO_PLANT_ID
          data_type: VARCHAR
        - name: MATERIAL_ID
          synonyms: [part transferred]
          description: Material being transferred
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: TRANSFER_STATUS
          synonyms: [status]
          description: "Status: Planned, In Transit, Received"
          expr: TRANSFER_STATUS
          data_type: VARCHAR
          sample_values: ['Planned', 'In Transit', 'Received']
          is_enum: true
      metrics:
        - name: TOTAL_TRANSFER_QTY
          synonyms: [quantity transferred]
          description: Total quantity transferred
          expr: SUM(TRANSFER_QTY)
        - name: TOTAL_TRANSFER_COST
          synonyms: [freight cost, shipping cost]
          description: Total freight/handling cost
          expr: SUM(TRANSFER_COST)

    - name: SUPPLY_RECOMMENDATIONS
      description: AI-generated supply chain recommendations including new POs, inter-plant transfers, and excess alerts with priority and cost estimates.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: SUPPLY_RECOMMENDATIONS
      primary_key:
        columns: [RECOMMENDATION_ID]
      dimensions:
        - name: RECOMMENDATION_DATE
          synonyms: [date, generated date]
          description: Date recommendation was generated
          expr: RECOMMENDATION_DATE
          data_type: DATE
        - name: PLANT_ID
          synonyms: [plant, site]
          description: Plant where action is needed
          expr: PLANT_ID
          data_type: VARCHAR
        - name: MATERIAL_ID
          synonyms: [part, material]
          description: Material requiring action
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: RECOMMENDATION_TYPE
          synonyms: [action type, rec type]
          description: "Type: NEW_PO, TRANSFER, EXCESS_ALERT, NO_ACTION"
          expr: RECOMMENDATION_TYPE
          data_type: VARCHAR
          sample_values: ['NEW_PO', 'TRANSFER', 'EXCESS_ALERT', 'NO_ACTION']
          is_enum: true
        - name: PRIORITY
          synonyms: [urgency, severity]
          description: "Priority: CRITICAL, HIGH, MEDIUM, LOW"
          expr: PRIORITY
          data_type: VARCHAR
          sample_values: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
          is_enum: true
        - name: TRIGGER_REASON
          synonyms: [reason, why, explanation]
          description: Why the recommendation was triggered
          expr: TRIGGER_REASON
          data_type: VARCHAR
        - name: ACTION_TAKEN
          synonyms: [actioned, resolved, completed]
          description: Whether action has been taken
          expr: ACTION_TAKEN
          data_type: BOOLEAN
      metrics:
        - name: MIN_DAYS_UNTIL_STOCKOUT
          synonyms: [days to stockout]
          description: Minimum days until stockout
          expr: MIN(DAYS_UNTIL_STOCKOUT)
        - name: TOTAL_ESTIMATED_COST
          synonyms: [cost to resolve, action cost]
          description: Total estimated cost of actions
          expr: SUM(ESTIMATED_COST)
        - name: RECOMMENDATION_COUNT
          synonyms: [number of recommendations, action items]
          description: Count of recommendations
          expr: COUNT(RECOMMENDATION_ID)

  relationships:
    - name: inventory_to_plant
      left_table: INVENTORY_SNAPSHOT
      right_table: PLANTS
      relationship_columns:
        - left_column: PLANT_ID
          right_column: PLANT_ID
    - name: inventory_to_material
      left_table: INVENTORY_SNAPSHOT
      right_table: MATERIALS
      relationship_columns:
        - left_column: MATERIAL_ID
          right_column: MATERIAL_ID
    - name: po_to_plant
      left_table: PURCHASE_ORDERS
      right_table: PLANTS
      relationship_columns:
        - left_column: PLANT_ID
          right_column: PLANT_ID
    - name: po_to_supplier
      left_table: PURCHASE_ORDERS
      right_table: SUPPLIERS
      relationship_columns:
        - left_column: SUPPLIER_ID
          right_column: SUPPLIER_ID
    - name: po_to_material
      left_table: PURCHASE_ORDERS
      right_table: MATERIALS
      relationship_columns:
        - left_column: MATERIAL_ID
          right_column: MATERIAL_ID
    - name: receipt_to_po
      left_table: PO_RECEIPTS
      right_table: PURCHASE_ORDERS
      relationship_columns:
        - left_column: PO_ID
          right_column: PO_ID
    - name: receipt_to_material
      left_table: PO_RECEIPTS
      right_table: MATERIALS
      relationship_columns:
        - left_column: MATERIAL_ID
          right_column: MATERIAL_ID
    - name: transfer_to_material
      left_table: INVENTORY_TRANSFERS
      right_table: MATERIALS
      relationship_columns:
        - left_column: MATERIAL_ID
          right_column: MATERIAL_ID
    - name: rec_to_plant
      left_table: SUPPLY_RECOMMENDATIONS
      right_table: PLANTS
      relationship_columns:
        - left_column: PLANT_ID
          right_column: PLANT_ID
    - name: rec_to_material
      left_table: SUPPLY_RECOMMENDATIONS
      right_table: MATERIALS
      relationship_columns:
        - left_column: MATERIAL_ID
          right_column: MATERIAL_ID

  module_custom_instructions:
    sql_generation: |
      When the user asks about latest or current inventory, filter to MAX(snapshot_date).
      When asking about open purchase orders, filter PO_STATUS IN ('Open', 'In Transit').
      Expediting costs are only on rush orders (IS_RUSH = TRUE).
      Days forward coverage below material lead time indicates stockout risk.
      For time-based questions without explicit dates, default to last 90 days.
      Round percentages to 1 decimal, dollars to 2 decimals.
      Quality rejection rate = COUNT where quality_status IN ('Rejected','Partial Accept') / total COUNT.
    question_categorization: |
      If the user asks about manufacturing schedule, demand forecast, or production planning,
      respond that those questions should use the Manufacturing and Demand semantic view.
      If the user asks about topics unrelated to supply chain, politely decline.

  verified_queries:
    - name: total_inventory_value_by_plant
      question: What is the total inventory value by plant for the latest snapshot?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT p.PLANT_NAME, SUM(i.INVENTORY_VALUE) AS TOTAL_INVENTORY_VALUE
        FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT i
        JOIN FS_INTELLIGENCE.RAW.PLANTS p ON i.PLANT_ID = p.PLANT_ID
        WHERE i.SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT)
        GROUP BY p.PLANT_NAME ORDER BY TOTAL_INVENTORY_VALUE DESC

    - name: materials_below_safety_stock
      question: Which materials are below safety stock levels at any plant?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT p.PLANT_NAME, m.MATERIAL_NAME, i.QUANTITY_ON_HAND,
               i.SAFETY_STOCK_LEVEL, i.DAYS_FORWARD_COVERAGE
        FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT i
        JOIN FS_INTELLIGENCE.RAW.PLANTS p ON i.PLANT_ID = p.PLANT_ID
        JOIN FS_INTELLIGENCE.RAW.MATERIALS m ON i.MATERIAL_ID = m.MATERIAL_ID
        WHERE i.SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT)
          AND i.QUANTITY_ON_HAND < i.SAFETY_STOCK_LEVEL
        ORDER BY (i.SAFETY_STOCK_LEVEL - i.QUANTITY_ON_HAND) DESC

    - name: expediting_cost_by_supplier
      question: What are the total expediting costs by supplier?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT s.SUPPLIER_NAME, SUM(po.EXPEDITING_COST) AS TOTAL_EXPEDITING_COST,
               COUNT(po.PO_ID) AS RUSH_PO_COUNT
        FROM FS_INTELLIGENCE.RAW.PURCHASE_ORDERS po
        JOIN FS_INTELLIGENCE.RAW.SUPPLIERS s ON po.SUPPLIER_ID = s.SUPPLIER_ID
        WHERE po.IS_RUSH = TRUE
        GROUP BY s.SUPPLIER_NAME ORDER BY TOTAL_EXPEDITING_COST DESC

    - name: supplier_on_time_performance
      question: Which suppliers have the worst on-time delivery performance?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT SUPPLIER_NAME, ON_TIME_RATE, QUALITY_PASS_RATE, RISK_SCORE, SUPPLIER_TIER
        FROM FS_INTELLIGENCE.RAW.SUPPLIERS ORDER BY ON_TIME_RATE ASC

    - name: critical_recommendations
      question: Which materials have critical or high priority supply recommendations?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT r.PLANT_ID, m.MATERIAL_NAME, r.RECOMMENDATION_TYPE, r.PRIORITY,
               r.DAYS_FORWARD_COVERAGE, r.DAYS_UNTIL_STOCKOUT, r.ESTIMATED_COST
        FROM FS_INTELLIGENCE.RAW.SUPPLY_RECOMMENDATIONS r
        JOIN FS_INTELLIGENCE.RAW.MATERIALS m ON r.MATERIAL_ID = m.MATERIAL_ID
        WHERE r.PRIORITY IN ('CRITICAL', 'HIGH')
        ORDER BY r.PRIORITY, r.DAYS_UNTIL_STOCKOUT
  $$
);

-- ════════════════════════════════════════════════════════════════════════════════
-- SEMANTIC VIEW 2: Manufacturing & Demand
-- Covers: Manufacturing Schedule, Product Demand Forecast, Material Demand
--         Forecast, MRP Demand, BOM, Customers
-- ════════════════════════════════════════════════════════════════════════════════

CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'FS_INTELLIGENCE.ANALYTICS',
  $$
  name: MANUFACTURING_DEMAND_SV
  description: >
    First Solar manufacturing and demand semantic view. Covers weekly production
    scheduling (planned vs actual, change types, adherence), ML-generated demand
    forecasts (product-level and BOM-exploded material-level), MRP demand by
    customer, and bill of materials. Enables questions about schedule adherence,
    production shortfalls, demand patterns, and forecast accuracy.

  tables:
    - name: MANUFACTURING_SCHEDULE
      description: Weekly manufacturing schedule with planned, revised, and actual quantities plus change tracking.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: MANUFACTURING_SCHEDULE
      primary_key:
        columns: [SCHEDULE_ID]
      dimensions:
        - name: PLANT_ID
          synonyms: [plant, site]
          description: Manufacturing plant
          expr: PLANT_ID
          data_type: VARCHAR
        - name: WEEK_START
          synonyms: [week, production week]
          description: Start date of production week
          expr: WEEK_START
          data_type: DATE
        - name: STATUS
          synonyms: [schedule status]
          description: "COMPLETED, PLANNED, or REVISED"
          expr: STATUS
          data_type: VARCHAR
          sample_values: ['COMPLETED', 'PLANNED', 'REVISED']
          is_enum: true
        - name: CHANGE_TYPE
          synonyms: [type of change, schedule change]
          description: "NONE, QUANTITY_DOWN, QUANTITY_UP, PULL_FORWARD, PUSH_OUT"
          expr: CHANGE_TYPE
          data_type: VARCHAR
          sample_values: ['NONE', 'QUANTITY_DOWN', 'QUANTITY_UP', 'PULL_FORWARD', 'PUSH_OUT']
          is_enum: true
        - name: CHANGE_REASON
          synonyms: [reason, why changed]
          description: Explanation for schedule change
          expr: CHANGE_REASON
          data_type: VARCHAR
      metrics:
        - name: TOTAL_PLANNED_QTY
          synonyms: [planned production, planned modules]
          description: Total planned production (modules)
          expr: SUM(PLANNED_QTY)
        - name: TOTAL_REVISED_QTY
          synonyms: [revised production]
          description: Total revised quantity
          expr: SUM(REVISED_QTY)
        - name: TOTAL_ACTUAL_QTY
          synonyms: [actual production, modules produced]
          description: Total actual production
          expr: SUM(ACTUAL_QTY)

    - name: PRODUCT_DEMAND_FORECAST
      description: ML-generated weekly demand forecast at product level (Series 6, Series 7) with confidence intervals.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: PRODUCT_DEMAND_FORECAST
      primary_key:
        columns: [PLANT_ID, PRODUCT_ID, WEEK_START]
      dimensions:
        - name: PLANT_ID
          synonyms: [plant]
          description: Plant for forecast
          expr: PLANT_ID
          data_type: VARCHAR
        - name: PRODUCT_ID
          synonyms: [product, module type]
          description: "Product: FS6-450W or FS7-500W"
          expr: PRODUCT_ID
          data_type: VARCHAR
          sample_values: ['FS6-450W', 'FS7-500W']
          is_enum: true
        - name: WEEK_START
          synonyms: [forecast week, week]
          description: Week start date
          expr: WEEK_START
          data_type: DATE
        - name: IS_FUTURE
          synonyms: [future, predicted]
          description: Whether this is a future forecast (true) or historical fit (false)
          expr: IS_FUTURE
          data_type: BOOLEAN
      metrics:
        - name: FORECAST_MODULES
          synonyms: [forecast, predicted demand]
          description: Forecasted module demand
          expr: SUM(FORECAST_MODULES)
        - name: ACTUAL_MODULES
          synonyms: [actual demand, actual]
          description: Actual module demand (historical only)
          expr: SUM(ACTUAL_MODULES)
        - name: LOWER_BOUND
          synonyms: [forecast lower, confidence lower]
          description: Lower bound of 90% confidence interval
          expr: SUM(LOWER_BOUND)
        - name: UPPER_BOUND
          synonyms: [forecast upper, confidence upper]
          description: Upper bound of 90% confidence interval
          expr: SUM(UPPER_BOUND)

    - name: DEMAND_FORECAST
      description: BOM-exploded weekly material demand forecast derived from product forecast.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: DEMAND_FORECAST
      primary_key:
        columns: [PLANT_ID, MATERIAL_ID, WEEK_START]
      dimensions:
        - name: PLANT_ID
          synonyms: [plant]
          description: Plant
          expr: PLANT_ID
          data_type: VARCHAR
        - name: MATERIAL_ID
          synonyms: [material, part]
          description: Material
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: WEEK_START
          synonyms: [week]
          description: Week start
          expr: WEEK_START
          data_type: DATE
        - name: IS_FUTURE
          synonyms: [future, forecast period]
          description: Future forecast vs historical fit
          expr: IS_FUTURE
          data_type: BOOLEAN
      metrics:
        - name: FORECAST_DEMAND
          synonyms: [material forecast, predicted material demand]
          description: Forecasted material demand quantity
          expr: SUM(FORECAST_DEMAND)
        - name: ACTUAL_DEMAND
          synonyms: [actual material demand]
          description: Actual material demand (historical)
          expr: SUM(ACTUAL_DEMAND)

    - name: MRP_DEMAND
      description: Daily MRP demand by plant, material, customer, and product. Includes both customer orders and forecast demand.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: MRP_DEMAND
      primary_key:
        columns: [DEMAND_ID]
      dimensions:
        - name: DEMAND_DATE
          synonyms: [date, required date]
          description: Date material is needed
          expr: DEMAND_DATE
          data_type: DATE
        - name: PLANT_ID
          synonyms: [plant]
          description: Plant requiring material
          expr: PLANT_ID
          data_type: VARCHAR
        - name: CUSTOMER_ID
          synonyms: [customer]
          description: Customer driving demand
          expr: CUSTOMER_ID
          data_type: VARCHAR
        - name: PRODUCT_ID
          synonyms: [product, module]
          description: Product being produced
          expr: PRODUCT_ID
          data_type: VARCHAR
        - name: DEMAND_TYPE
          synonyms: [type, order type]
          description: "Customer Order or Forecast"
          expr: DEMAND_TYPE
          data_type: VARCHAR
          sample_values: ['Customer Order', 'Forecast']
          is_enum: true
      metrics:
        - name: TOTAL_REQUIRED_QTY
          synonyms: [demand quantity, required quantity]
          description: Total quantity required
          expr: SUM(REQUIRED_QTY)
        - name: DEMAND_COUNT
          synonyms: [number of demand lines]
          description: Count of demand records
          expr: COUNT(DEMAND_ID)

    - name: CUSTOMERS
      description: Customer master data for utility and commercial solar developers.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: CUSTOMERS
      primary_key:
        columns: [CUSTOMER_ID]
      dimensions:
        - name: CUSTOMER_ID
          synonyms: [customer code]
          description: Unique customer identifier
          expr: CUSTOMER_ID
          data_type: VARCHAR
        - name: CUSTOMER_NAME
          synonyms: [customer, client]
          description: Customer company name
          expr: CUSTOMER_NAME
          data_type: VARCHAR
        - name: SEGMENT
          synonyms: [customer type, market segment]
          description: "Utility or Commercial"
          expr: SEGMENT
          data_type: VARCHAR
          sample_values: ['Utility', 'Commercial']
          is_enum: true
        - name: REGION
          synonyms: [customer region]
          description: Geographic region
          expr: REGION
          data_type: VARCHAR

    - name: PLANTS
      description: Manufacturing plants.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: PLANTS
      primary_key:
        columns: [PLANT_ID]
      dimensions:
        - name: PLANT_ID
          expr: PLANT_ID
          data_type: VARCHAR
        - name: PLANT_NAME
          synonyms: [facility]
          description: Plant name
          expr: PLANT_NAME
          data_type: VARCHAR

  relationships:
    - name: schedule_to_plant
      left_table: MANUFACTURING_SCHEDULE
      right_table: PLANTS
      relationship_columns:
        - left_column: PLANT_ID
          right_column: PLANT_ID
    - name: product_forecast_to_plant
      left_table: PRODUCT_DEMAND_FORECAST
      right_table: PLANTS
      relationship_columns:
        - left_column: PLANT_ID
          right_column: PLANT_ID
    - name: mrp_to_plant
      left_table: MRP_DEMAND
      right_table: PLANTS
      relationship_columns:
        - left_column: PLANT_ID
          right_column: PLANT_ID
    - name: mrp_to_customer
      left_table: MRP_DEMAND
      right_table: CUSTOMERS
      relationship_columns:
        - left_column: CUSTOMER_ID
          right_column: CUSTOMER_ID

  module_custom_instructions:
    sql_generation: |
      Manufacturing schedule adherence = SUM(ACTUAL_QTY) / SUM(PLANNED_QTY) * 100.
      For completed weeks, use STATUS = 'COMPLETED'.
      For forecast accuracy (MAPE), calculate ABS(ACTUAL - FORECAST) / ACTUAL * 100.
      Volume impact of schedule changes = SUM(REVISED_QTY - PLANNED_QTY) where CHANGE_TYPE != 'NONE'.
      Round percentages to 1 decimal place.
    question_categorization: |
      If the user asks about inventory levels, purchase orders, or supplier performance,
      respond that those questions should use the Supply Chain Operations semantic view.

  verified_queries:
    - name: schedule_adherence_by_plant
      question: What is the manufacturing schedule adherence by plant?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT p.PLANT_NAME,
               SUM(ms.ACTUAL_QTY) AS TOTAL_ACTUAL,
               SUM(ms.PLANNED_QTY) AS TOTAL_PLANNED,
               ROUND(SUM(ms.ACTUAL_QTY)::FLOAT / NULLIF(SUM(ms.PLANNED_QTY), 0) * 100, 1) AS ADHERENCE_PCT
        FROM FS_INTELLIGENCE.RAW.MANUFACTURING_SCHEDULE ms
        JOIN FS_INTELLIGENCE.RAW.PLANTS p ON ms.PLANT_ID = p.PLANT_ID
        WHERE ms.STATUS = 'COMPLETED'
        GROUP BY p.PLANT_NAME ORDER BY ADHERENCE_PCT

    - name: production_reduced_weeks
      question: Which weeks had production quantity reduced and why?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT p.PLANT_NAME, ms.WEEK_START, ms.PLANNED_QTY, ms.ACTUAL_QTY,
               ms.CHANGE_PCT, ms.CHANGE_REASON
        FROM FS_INTELLIGENCE.RAW.MANUFACTURING_SCHEDULE ms
        JOIN FS_INTELLIGENCE.RAW.PLANTS p ON ms.PLANT_ID = p.PLANT_ID
        WHERE ms.CHANGE_TYPE = 'QUANTITY_DOWN'
        ORDER BY ms.WEEK_START DESC

    - name: demand_forecast_series6_arizona
      question: What is the demand forecast for Series 6 modules at Arizona?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT WEEK_START, FORECAST_MODULES, LOWER_BOUND, UPPER_BOUND
        FROM FS_INTELLIGENCE.RAW.PRODUCT_DEMAND_FORECAST
        WHERE PLANT_ID = 'PLT-AZ1' AND PRODUCT_ID = 'FS6-450W' AND IS_FUTURE = TRUE
        ORDER BY WEEK_START

    - name: customer_orders_at_risk
      question: Which customer orders are at risk due to materials below safety stock?
      verified_at: 1719792000
      sql: |
        SELECT c.CUSTOMER_NAME, d.PRODUCT_ID, d.PLANT_ID,
               SUM(d.REQUIRED_QTY) AS TOTAL_DEMAND
        FROM FS_INTELLIGENCE.RAW.MRP_DEMAND d
        JOIN FS_INTELLIGENCE.RAW.CUSTOMERS c ON d.CUSTOMER_ID = c.CUSTOMER_ID
        WHERE d.DEMAND_DATE >= CURRENT_DATE()
          AND d.PLANT_ID IN (
            SELECT DISTINCT i.PLANT_ID FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT i
            WHERE i.SNAPSHOT_DATE = (SELECT MAX(SNAPSHOT_DATE) FROM FS_INTELLIGENCE.RAW.INVENTORY_SNAPSHOT)
              AND i.QUANTITY_ON_HAND < i.SAFETY_STOCK_LEVEL
          )
        GROUP BY c.CUSTOMER_NAME, d.PRODUCT_ID, d.PLANT_ID
        ORDER BY TOTAL_DEMAND DESC
  $$
);

-- ════════════════════════════════════════════════════════════════════════════════
-- SEMANTIC VIEW 3: Risk Intelligence
-- Covers: Material Risk Profiles, Trade Lanes, Industry Benchmarks,
--         Anomaly Alerts, joined to Suppliers, Materials, Plants
-- ════════════════════════════════════════════════════════════════════════════════

CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'FS_INTELLIGENCE.ANALYTICS',
  $$
  name: RISK_INTELLIGENCE_SV
  description: >
    First Solar risk intelligence semantic view. Covers material sourcing risk
    (single/dual/multi-source, substitutability, geographic concentration),
    trade lane logistics (transit times, customs, geopolitical risk), industry
    benchmarks (lead times, OTD, inventory turns), anomaly detection
    (demand spikes, supplier delays, price anomalies), and EXTERNAL SHIPPING
    SIGNALS (simulated Marketplace trade/shipping data showing export volumes,
    port dwell times, and shipment delays by supplier lane). Enables risk
    assessment that combines internal and external data sources.

  tables:
    - name: MATERIAL_RISK_PROFILE
      description: Material sourcing risk classification with concentration, substitutability, and strategic importance.
      base_table:
        database: FS_INTELLIGENCE
        schema: REFERENCE
        table: MATERIAL_RISK_PROFILE
      primary_key:
        columns: [MATERIAL_ID]
      dimensions:
        - name: MATERIAL_ID
          synonyms: [part, material]
          description: Material identifier
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: SOURCING_RISK_TIER
          synonyms: [risk tier, sourcing risk, source type]
          description: "SINGLE_SOURCE, DUAL_SOURCE, or MULTI_SOURCE"
          expr: SOURCING_RISK_TIER
          data_type: VARCHAR
          sample_values: ['SINGLE_SOURCE', 'DUAL_SOURCE', 'MULTI_SOURCE']
          is_enum: true
        - name: SUBSTITUTABILITY
          synonyms: [substitute available, replaceable]
          description: "NONE, PARTIAL, or FULL substitutability"
          expr: SUBSTITUTABILITY
          data_type: VARCHAR
          sample_values: ['NONE', 'PARTIAL', 'FULL']
          is_enum: true
        - name: STRATEGIC_IMPORTANCE
          synonyms: [importance, criticality level]
          description: "CRITICAL, HIGH, MEDIUM, or LOW strategic importance"
          expr: STRATEGIC_IMPORTANCE
          data_type: VARCHAR
          sample_values: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
          is_enum: true
        - name: NOTES
          synonyms: [risk notes, description]
          description: Detailed notes about sourcing risk
          expr: NOTES
          data_type: VARCHAR
      metrics:
        - name: AVG_LEAD_TIME
          synonyms: [lead time, avg lead time days]
          description: Average lead time in days
          expr: AVG(AVG_LEAD_TIME_DAYS)
        - name: AVG_LEAD_TIME_VOLATILITY
          synonyms: [volatility, CV]
          description: Average lead time coefficient of variation
          expr: AVG(LEAD_TIME_VOLATILITY_CV)
        - name: AVG_GEOGRAPHIC_CONCENTRATION
          synonyms: [concentration, geographic risk]
          description: Average geographic concentration percentage
          expr: AVG(GEOGRAPHIC_CONCENTRATION_PCT)

    - name: TRADE_LANE_DIM
      description: Physical logistics routes from suppliers to plants with transit times, customs, freight mode, and geopolitical risk.
      base_table:
        database: FS_INTELLIGENCE
        schema: REFERENCE
        table: TRADE_LANE_DIM
      primary_key:
        columns: [SUPPLIER_ID, PLANT_ID]
      dimensions:
        - name: SUPPLIER_ID
          synonyms: [supplier]
          description: Supplier on this route
          expr: SUPPLIER_ID
          data_type: VARCHAR
        - name: PLANT_ID
          synonyms: [destination plant]
          description: Destination plant
          expr: PLANT_ID
          data_type: VARCHAR
        - name: ORIGIN_COUNTRY
          synonyms: [country of origin, source country]
          description: Origin country for shipment
          expr: ORIGIN_COUNTRY
          data_type: VARCHAR
        - name: PORT_OF_ENTRY
          synonyms: [port, entry port]
          description: US port of entry
          expr: PORT_OF_ENTRY
          data_type: VARCHAR
        - name: FREIGHT_MODE
          synonyms: [shipping mode, transport]
          description: "OCEAN, AIR, TRUCK, or RAIL"
          expr: FREIGHT_MODE
          data_type: VARCHAR
          sample_values: ['OCEAN', 'AIR', 'TRUCK', 'RAIL']
          is_enum: true
        - name: NOTES
          synonyms: [route notes, logistics notes]
          description: Route-specific notes
          expr: NOTES
          data_type: VARCHAR
      metrics:
        - name: AVG_TRANSIT_DAYS
          synonyms: [transit time, shipping days]
          description: Average transit days
          expr: AVG(TYPICAL_TRANSIT_DAYS)
        - name: AVG_CUSTOMS_DAYS
          synonyms: [customs clearance time]
          description: Average customs processing days
          expr: AVG(AVG_CUSTOMS_DAYS)
        - name: AVG_TARIFF_PCT
          synonyms: [tariff rate, duty rate]
          description: Average tariff percentage
          expr: AVG(TARIFF_PCT)
        - name: AVG_GEOPOLITICAL_RISK
          synonyms: [geopolitical risk, geo risk score]
          description: Average geopolitical risk score (1-10)
          expr: AVG(GEOPOLITICAL_RISK_SCORE)

    - name: INDUSTRY_BENCHMARK_DIM
      description: Industry benchmarks for CdTe manufacturing KPIs including lead times, inventory turns, OTD, and forecast accuracy.
      base_table:
        database: FS_INTELLIGENCE
        schema: REFERENCE
        table: INDUSTRY_BENCHMARK_DIM
      primary_key:
        columns: [BENCHMARK_ID]
      dimensions:
        - name: METRIC_NAME
          synonyms: [benchmark metric, KPI name]
          description: Name of the benchmark metric
          expr: METRIC_NAME
          data_type: VARCHAR
        - name: MATERIAL_CATEGORY
          synonyms: [category]
          description: Material category (if applicable)
          expr: MATERIAL_CATEGORY
          data_type: VARCHAR
        - name: UNIT
          synonyms: [measurement unit]
          description: Unit of measurement
          expr: UNIT
          data_type: VARCHAR
        - name: SOURCE
          synonyms: [data source, report]
          description: Source publication for benchmark
          expr: SOURCE
          data_type: VARCHAR
      metrics:
        - name: BENCHMARK_VALUE
          synonyms: [benchmark, target value, industry standard]
          description: Benchmark value
          expr: AVG(BENCHMARK_VALUE)

    - name: ANOMALY_ALERTS
      description: Detected anomalies including demand spikes, supplier delays, price anomalies, and inventory drops.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: ANOMALY_ALERTS
      primary_key:
        columns: [ALERT_ID]
      dimensions:
        - name: ALERT_DATE
          synonyms: [date, detected date]
          description: Date anomaly was detected
          expr: ALERT_DATE
          data_type: DATE
        - name: ALERT_TYPE
          synonyms: [anomaly type, type]
          description: "DEMAND_SPIKE, SUPPLIER_DELAY, PRICE_ANOMALY, INVENTORY_DROP"
          expr: ALERT_TYPE
          data_type: VARCHAR
          sample_values: ['DEMAND_SPIKE', 'SUPPLIER_DELAY', 'PRICE_ANOMALY', 'INVENTORY_DROP']
          is_enum: true
        - name: SEVERITY
          synonyms: [severity level, impact]
          description: "HIGH, MEDIUM, or LOW"
          expr: SEVERITY
          data_type: VARCHAR
          sample_values: ['HIGH', 'MEDIUM', 'LOW']
          is_enum: true
        - name: PLANT_ID
          synonyms: [affected plant]
          description: Plant associated with anomaly
          expr: PLANT_ID
          data_type: VARCHAR
        - name: MATERIAL_ID
          synonyms: [affected material]
          description: Material associated with anomaly
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: SUPPLIER_ID
          synonyms: [affected supplier]
          description: Supplier associated with anomaly
          expr: SUPPLIER_ID
          data_type: VARCHAR
        - name: DESCRIPTION
          synonyms: [alert description, details]
          description: Description of the anomaly
          expr: DESCRIPTION
          data_type: VARCHAR
        - name: IS_RESOLVED
          synonyms: [resolved, closed]
          description: Whether resolved
          expr: IS_RESOLVED
          data_type: BOOLEAN
      metrics:
        - name: AVG_DEVIATION_PCT
          synonyms: [deviation, variance]
          description: Average percentage deviation
          expr: AVG(DEVIATION_PCT)
        - name: ALERT_COUNT
          synonyms: [number of alerts, anomaly count]
          description: Count of alerts
          expr: COUNT(ALERT_ID)

    - name: MATERIALS
      description: Material master for joins.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: MATERIALS
      primary_key:
        columns: [MATERIAL_ID]
      dimensions:
        - name: MATERIAL_ID
          expr: MATERIAL_ID
          data_type: VARCHAR
        - name: MATERIAL_NAME
          synonyms: [part name]
          description: Material name
          expr: MATERIAL_NAME
          data_type: VARCHAR
        - name: MATERIAL_CATEGORY
          synonyms: [category]
          description: Material category
          expr: MATERIAL_CATEGORY
          data_type: VARCHAR
        - name: IS_CRITICAL
          synonyms: [critical]
          description: Critical-path flag
          expr: IS_CRITICAL
          data_type: BOOLEAN

    - name: SUPPLIERS
      description: Supplier master for joins.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: SUPPLIERS
      primary_key:
        columns: [SUPPLIER_ID]
      dimensions:
        - name: SUPPLIER_ID
          expr: SUPPLIER_ID
          data_type: VARCHAR
        - name: SUPPLIER_NAME
          synonyms: [vendor name]
          description: Supplier name
          expr: SUPPLIER_NAME
          data_type: VARCHAR
        - name: COUNTRY
          synonyms: [supplier country]
          description: Supplier country
          expr: COUNTRY
          data_type: VARCHAR

    - name: EXTERNAL_SHIPPING_SIGNALS
      description: External Marketplace shipping/trade signals showing supply lane health. Simulated dataset representing live Snowflake Marketplace trade data. Shows export volume trends, port dwell times, shipment delays for supplier lanes.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: EXTERNAL_SHIPPING_SIGNALS
      primary_key:
        columns: [SIGNAL_ID]
      dimensions:
        - name: SIGNAL_DATE
          synonyms: [date, shipping date, signal date]
          description: Date of the shipping/trade signal observation
          expr: SIGNAL_DATE
          data_type: DATE
        - name: SUPPLIER_LANE
          synonyms: [lane, route, shipping lane, supply lane]
          description: "Supplier name and destination (e.g. ABC Glass Industries → Alabama)"
          expr: SUPPLIER_LANE
          data_type: VARCHAR
        - name: ORIGIN_PORT
          synonyms: [origin, source port, departure]
          description: Origin port or industrial area
          expr: ORIGIN_PORT
          data_type: VARCHAR
        - name: ORIGIN_COUNTRY
          synonyms: [source country]
          description: Country of origin
          expr: ORIGIN_COUNTRY
          data_type: VARCHAR
        - name: DESTINATION_PORT
          synonyms: [destination, arrival port]
          description: Destination port
          expr: DESTINATION_PORT
          data_type: VARCHAR
        - name: COMMODITY_CATEGORY
          synonyms: [commodity, product type, goods]
          description: Category of goods being shipped
          expr: COMMODITY_CATEGORY
          data_type: VARCHAR
        - name: DATA_SOURCE
          description: Source of the external data
          expr: DATA_SOURCE
          data_type: VARCHAR
        - name: NOTES
          synonyms: [shipping notes, signal notes]
          description: Additional context about shipping conditions
          expr: NOTES
          data_type: VARCHAR
      metrics:
        - name: AVG_EXPORT_VOLUME_INDEX
          synonyms: [export volume, volume index, trade volume]
          description: Average export volume index (baseline ~100, lower = declining activity)
          expr: AVG(EXPORT_VOLUME_INDEX)
          data_type: NUMBER
        - name: AVG_PORT_DWELL_TIME
          synonyms: [dwell time, port wait, dwell hours]
          description: Average port dwell time in hours (baseline ~24, higher = congestion)
          expr: AVG(PORT_DWELL_TIME_HOURS)
          data_type: NUMBER
        - name: DELAY_RATE
          synonyms: [delay percentage, delay fraction, pct delayed]
          description: Fraction of shipments flagged as delayed
          expr: AVG(SHIPMENT_DELAY_FLAG)
          data_type: NUMBER
        - name: AVG_TRANSIT_DAYS
          synonyms: [transit time, shipping days]
          description: Average transit time in days
          expr: AVG(AVG_TRANSIT_DAYS)
          data_type: NUMBER
        - name: TOTAL_VESSEL_TRUCK_COUNT
          synonyms: [shipment count, vessel count, truck count]
          description: Total vessel/truck movements observed
          expr: SUM(VESSEL_TRUCK_COUNT)
          data_type: NUMBER

    - name: PLANTS
      description: Plant master for joins.
      base_table:
        database: FS_INTELLIGENCE
        schema: RAW
        table: PLANTS
      primary_key:
        columns: [PLANT_ID]
      dimensions:
        - name: PLANT_ID
          expr: PLANT_ID
          data_type: VARCHAR
        - name: PLANT_NAME
          synonyms: [facility]
          description: Plant name
          expr: PLANT_NAME
          data_type: VARCHAR

  relationships:
    - name: risk_to_material
      left_table: MATERIAL_RISK_PROFILE
      right_table: MATERIALS
      relationship_columns:
        - left_column: MATERIAL_ID
          right_column: MATERIAL_ID
    - name: trade_lane_to_supplier
      left_table: TRADE_LANE_DIM
      right_table: SUPPLIERS
      relationship_columns:
        - left_column: SUPPLIER_ID
          right_column: SUPPLIER_ID
    - name: trade_lane_to_plant
      left_table: TRADE_LANE_DIM
      right_table: PLANTS
      relationship_columns:
        - left_column: PLANT_ID
          right_column: PLANT_ID
    - name: alert_to_plant
      left_table: ANOMALY_ALERTS
      right_table: PLANTS
      relationship_columns:
        - left_column: PLANT_ID
          right_column: PLANT_ID
    - name: alert_to_supplier
      left_table: ANOMALY_ALERTS
      right_table: SUPPLIERS
      relationship_columns:
        - left_column: SUPPLIER_ID
          right_column: SUPPLIER_ID
    - name: alert_to_material
      left_table: ANOMALY_ALERTS
      right_table: MATERIALS
      relationship_columns:
        - left_column: MATERIAL_ID
          right_column: MATERIAL_ID

  module_custom_instructions:
    sql_generation: |
      For single-source materials, filter SOURCING_RISK_TIER = 'SINGLE_SOURCE'.
      For highest-risk trade lanes, sort by GEOPOLITICAL_RISK_SCORE DESC.
      When comparing to benchmarks, join on METRIC_NAME and optionally MATERIAL_CATEGORY.
      For recent anomalies, filter ALERT_DATE >= DATEADD('day', -30, CURRENT_DATE()).
      Unresolved alerts have IS_RESOLVED = FALSE.
      For external shipping signals:
      - Baseline period is the first 60 days; recent period is the last 30 days.
      - Compare AVG(EXPORT_VOLUME_INDEX) recent vs baseline to detect declining lanes.
      - Compare AVG(PORT_DWELL_TIME_HOURS) recent vs baseline to detect congestion.
      - Filter SUPPLIER_LANE LIKE '%ABC Glass%' for the Alabama glass supply lane.
    question_categorization: |
      If the user asks about inventory levels or purchase orders, direct them
      to the Supply Chain Operations semantic view.
      If they ask about production schedule or demand forecast, direct them
      to the Manufacturing and Demand semantic view.

  verified_queries:
    - name: single_source_critical_materials
      question: Which materials are single-source with no substitutes?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT rp.MATERIAL_ID, m.MATERIAL_NAME, m.MATERIAL_CATEGORY,
               rp.SOURCING_RISK_TIER, rp.SUBSTITUTABILITY,
               rp.AVG_LEAD_TIME_DAYS, rp.NOTES
        FROM FS_INTELLIGENCE.REFERENCE.MATERIAL_RISK_PROFILE rp
        JOIN FS_INTELLIGENCE.RAW.MATERIALS m ON rp.MATERIAL_ID = m.MATERIAL_ID
        WHERE rp.SOURCING_RISK_TIER = 'SINGLE_SOURCE'
          AND rp.SUBSTITUTABILITY = 'NONE'
        ORDER BY rp.AVG_LEAD_TIME_DAYS DESC

    - name: highest_geopolitical_risk_trade_lanes
      question: Which trade lanes have the highest geopolitical risk scores?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT s.SUPPLIER_NAME, t.ORIGIN_COUNTRY, p.PLANT_NAME,
               t.FREIGHT_MODE, t.TYPICAL_TRANSIT_DAYS,
               t.GEOPOLITICAL_RISK_SCORE, t.NOTES
        FROM FS_INTELLIGENCE.REFERENCE.TRADE_LANE_DIM t
        JOIN FS_INTELLIGENCE.RAW.SUPPLIERS s ON t.SUPPLIER_ID = s.SUPPLIER_ID
        JOIN FS_INTELLIGENCE.RAW.PLANTS p ON t.PLANT_ID = p.PLANT_ID
        ORDER BY t.GEOPOLITICAL_RISK_SCORE DESC
        LIMIT 15

    - name: semiconductor_lead_time_vs_benchmark
      question: How does our semiconductor material lead time compare to industry benchmarks?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT m.MATERIAL_NAME, rp.AVG_LEAD_TIME_DAYS AS OUR_LEAD_TIME,
               b.BENCHMARK_VALUE AS INDUSTRY_BENCHMARK,
               rp.AVG_LEAD_TIME_DAYS - b.BENCHMARK_VALUE AS DELTA_DAYS
        FROM FS_INTELLIGENCE.REFERENCE.MATERIAL_RISK_PROFILE rp
        JOIN FS_INTELLIGENCE.RAW.MATERIALS m ON rp.MATERIAL_ID = m.MATERIAL_ID
        CROSS JOIN (
          SELECT BENCHMARK_VALUE FROM FS_INTELLIGENCE.REFERENCE.INDUSTRY_BENCHMARK_DIM
          WHERE METRIC_NAME = 'avg_lead_time_days' AND MATERIAL_CATEGORY = 'Semiconductor'
        ) b
        WHERE m.MATERIAL_CATEGORY = 'Semiconductor'
        ORDER BY DELTA_DAYS DESC

    - name: unresolved_high_alerts_by_plant
      question: How many unresolved high-severity anomaly alerts are there by plant?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        SELECT p.PLANT_NAME, a.ALERT_TYPE, COUNT(*) AS ALERT_COUNT
        FROM FS_INTELLIGENCE.RAW.ANOMALY_ALERTS a
        JOIN FS_INTELLIGENCE.RAW.PLANTS p ON a.PLANT_ID = p.PLANT_ID
        WHERE a.IS_RESOLVED = FALSE AND a.SEVERITY = 'HIGH'
        GROUP BY p.PLANT_NAME, a.ALERT_TYPE
        ORDER BY ALERT_COUNT DESC

    - name: abc_glass_lane_health
      question: What do external shipping signals show for the ABC Glass supply lane to Alabama?
      verified_at: 1719792000
      use_as_onboarding_question: true
      sql: |
        WITH baseline AS (
          SELECT AVG(EXPORT_VOLUME_INDEX) AS baseline_vol,
                 AVG(PORT_DWELL_TIME_HOURS) AS baseline_dwell,
                 AVG(SHIPMENT_DELAY_FLAG) AS baseline_delay_rate
          FROM FS_INTELLIGENCE.RAW.EXTERNAL_SHIPPING_SIGNALS
          WHERE SUPPLIER_LANE LIKE '%ABC Glass%Alabama%'
            AND SIGNAL_DATE < DATEADD('day', -30, CURRENT_DATE())
        ),
        recent AS (
          SELECT AVG(EXPORT_VOLUME_INDEX) AS recent_vol,
                 AVG(PORT_DWELL_TIME_HOURS) AS recent_dwell,
                 AVG(SHIPMENT_DELAY_FLAG) AS recent_delay_rate,
                 COUNT(*) AS observation_count
          FROM FS_INTELLIGENCE.RAW.EXTERNAL_SHIPPING_SIGNALS
          WHERE SUPPLIER_LANE LIKE '%ABC Glass%Alabama%'
            AND SIGNAL_DATE >= DATEADD('day', -30, CURRENT_DATE())
        )
        SELECT ROUND(b.baseline_vol, 1) AS BASELINE_EXPORT_VOLUME,
               ROUND(r.recent_vol, 1) AS RECENT_EXPORT_VOLUME,
               ROUND((r.recent_vol - b.baseline_vol) / b.baseline_vol * 100, 1) AS VOLUME_CHANGE_PCT,
               ROUND(b.baseline_dwell, 1) AS BASELINE_DWELL_HOURS,
               ROUND(r.recent_dwell, 1) AS RECENT_DWELL_HOURS,
               ROUND(b.baseline_delay_rate * 100, 1) AS BASELINE_DELAY_PCT,
               ROUND(r.recent_delay_rate * 100, 1) AS RECENT_DELAY_PCT,
               r.observation_count AS RECENT_OBSERVATIONS
        FROM baseline b, recent r
  $$
);
