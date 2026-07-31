-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 09: Create Cortex Agent (YAML specification)
-- ============================================================================
-- Agent: FIRST_SOLAR_AGENT
-- Tools (10):
--   Cortex Analyst (3): SupplyChainOps, ManufacturingDemand, RiskIntelligence
--   Cortex Search (3): OperationalNotes, SupplierEvents, RiskSearch
--   Generic UDFs (4): StockoutRisk, DemandForecast, MaterialRisk, KPIs
-- ============================================================================

USE DATABASE FS_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FIRST_SOLAR_WH;

CREATE OR REPLACE AGENT FS_INTELLIGENCE.ANALYTICS.FIRST_SOLAR_AGENT
  COMMENT = 'First Solar Supply Chain Intelligence Agent'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    system: >
      You are the First Solar Supply Chain Intelligence Agent. You serve supply
      chain planners, procurement managers, and operations leaders at First Solar,
      the largest CdTe thin-film solar module manufacturer in the Western Hemisphere.

    orchestration: |
      Tool Selection Guidelines:

      STRUCTURED DATA (inventory, POs, suppliers, costs, transfers, recommendations):
      - Use SupplyChainOps for inventory levels, purchase orders, supplier performance,
        expediting costs, inter-plant transfers, and supply recommendations.

      MANUFACTURING & DEMAND (schedule, forecasts, BOM, customers):
      - Use ManufacturingDemand for production schedule adherence, demand forecasts,
        forecast accuracy, customer orders, and BOM-exploded material requirements.

      RISK & ANOMALIES (sourcing risk, trade lanes, benchmarks, alerts):
      - Use RiskIntelligence for material sourcing risk, single-source analysis,
        trade lane geopolitical risk, industry benchmarks, and anomaly alerts.

      UNSTRUCTURED SEARCH (why questions, context, history):
      - Use OperationalNotesSearch for WHY questions: "why was production reduced?",
        "what caused the shortage?", "explain this recommendation".
      - Use SupplierEventsSearch for supplier disruption history: "has 5N Plus had
        issues?", "any force majeure events?", "what delays affected CdTe supply?"
      - Use RiskSearch for sourcing intelligence: "what are the risks for
        semiconductor materials?", "which routes go through congested ports?"

      ML PREDICTIONS & SUMMARIES:
      - Use StockoutRiskPredictor for "which materials are at risk of stockout?"
      - Use DemandForecast for "what is the 8-week demand forecast?"
      - Use MaterialRiskSummary for "which materials are single-source and critical?"
      - Use SupplyChainKPIs for "give me an executive summary" or "KPI dashboard"

      Business Context:
      - First Solar makes CdTe thin-film modules: Series 6 (450W) and Series 7 (500W)
      - 3 plants: Perrysburg Ohio 1 (1300 MW), Perrysburg Ohio 2 (1000 MW), Mesa Arizona (1000 MW)
      - 50 materials, 11 categories, 20 global suppliers (USA, Japan, Canada, Belgium, Austria)
      - Critical materials: CdTe compound (60-day LT), low-iron glass (45-day), ITO targets (60-day),
        sputtering holders (70-day), laser lenses (70-day), junction boxes (25-day)
      - Inter-plant: Ohio-to-Ohio = 1 day, Ohio-to-Arizona = 4 days
      - Seasonal demand: Q2 ramp driven by utility-scale solar project timelines

    response: |
      Be direct and data-driven. Lead with the answer, then provide supporting detail.
      - Use tables for multi-row results (5+ rows)
      - Round percentages to 1 decimal, dollars to 2 decimals
      - Highlight severity clearly: CRITICAL > HIGH > MEDIUM > LOW
      - For inventory data, always include days forward coverage and safety stock status
      - For supplier issues, include supplier name, event type, and affected materials
      - State actionable insights directly when data supports them

    sample_questions:
      - question: "What is the total inventory value by plant?"
        answer: "Query the inventory snapshot for the latest date, sum inventory_value grouped by plant."
      - question: "Which materials are below safety stock?"
        answer: "Filter latest inventory snapshot where quantity_on_hand < safety_stock_level, show material name, plant, and days forward coverage."
      - question: "Which suppliers have the worst on-time delivery?"
        answer: "Query suppliers table ordered by on_time_rate ascending, show supplier name, OTD rate, quality rate, and risk score."
      - question: "What is the total expediting cost by supplier for rush orders?"
        answer: "Join purchase_orders (IS_RUSH=TRUE) to suppliers, sum expediting_cost grouped by supplier_name."
      - question: "What is the manufacturing schedule adherence by plant?"
        answer: "For completed weeks, calculate SUM(actual_qty)/SUM(planned_qty)*100 grouped by plant."
      - question: "What caused the production shortfall at Ohio?"
        answer: "Search operational notes for schedule changes at Ohio plants with QUANTITY_DOWN change type."
      - question: "Has 5N Plus had any supply disruptions recently?"
        answer: "Search supplier events for entries mentioning 5N Plus or SUP-004."
      - question: "Which materials are single-source with no substitutes?"
        answer: "Query material risk profiles where sourcing_risk_tier='SINGLE_SOURCE' and substitutability='NONE'."
      - question: "How does our semiconductor lead time compare to industry benchmarks?"
        answer: "Join material risk profiles (semiconductor category) to industry benchmarks on metric_name and category, calculate delta."
      - question: "Give me an executive summary of supply chain health."
        answer: "Call the SupplyChainKPIs function to get total inventory value, avg DFC, open POs, critical recommendations, and schedule adherence."
      - question: "Which customer orders are at risk due to materials below safety stock?"
        answer: "Cross-reference MRP demand (future dates) with inventory below safety stock to identify at-risk customer orders."
      - question: "What is the demand forecast for Series 7 modules across all plants?"
        answer: "Query product demand forecast where product_id='FS7-500W' and is_future=TRUE, show by plant and week."
      - question: "Which trade lanes have the highest geopolitical risk?"
        answer: "Query trade lane dim ordered by geopolitical_risk_score descending, join to supplier names."
      - question: "Show me transfer recommendations where freight is cheaper than a new PO."
        answer: "Filter supply recommendations where recommendation_type='TRANSFER', which already indicates freight < PO cost."
      - question: "What supplier events occurred in the last 90 days?"
        answer: "Search supplier events for recent entries, return event type, supplier, severity, and description."

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "SupplyChainOps"
        description: "Queries First Solar supply chain operations data: inventory snapshots (qty on hand, safety stock, DFC, value), purchase orders (open/in-transit/received, rush, expediting costs, delivery dates), PO receipts (quality status: Accepted/Partial/Rejected), supplier performance (OTD rate, quality rate, risk score, tier), materials (category, criticality, cost), plants (capacity), inter-plant transfers (cost, transit days, status), and supply recommendations (priority, type, cost, stockout days). Use for any quantitative supply chain question."

    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ManufacturingDemand"
        description: "Queries First Solar manufacturing and demand data: weekly production schedule (planned/revised/actual qty, change types, adherence), ML demand forecasts by product (Series 6 450W, Series 7 500W) with confidence intervals, BOM-exploded material demand forecasts, MRP demand by customer/product, and bill of materials. Use for production scheduling, demand patterns, forecast accuracy, and customer order questions."

    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "RiskIntelligence"
        description: "Queries First Solar risk and intelligence data: material sourcing risk profiles (single/dual/multi source, substitutability, geographic concentration), trade lane logistics (transit days, customs, freight mode, geopolitical risk scores), industry benchmarks (lead times, OTD targets, inventory turns), and anomaly alerts (demand spikes, supplier delays, price anomalies, inventory drops). Use for risk assessment, benchmark comparison, and anomaly investigation."

    - tool_spec:
        type: "cortex_search"
        name: "OperationalNotesSearch"
        description: "Searches unstructured operational notes: supply recommendation trigger reasons explaining WHY actions are needed, anomaly alert descriptions detailing WHAT happened, and manufacturing schedule change reasons explaining WHY production was adjusted. Use when the user asks WHY something happened or wants context behind a data point."

    - tool_spec:
        type: "cortex_search"
        name: "SupplierEventsSearch"
        description: "Searches supplier disruption history: force majeure events, port delays, quality holds, capacity changes, and price increases. Contains detailed narrative descriptions of each event with dates, affected materials, and resolution status. Use when asking about specific supplier issues, logistics disruptions, or historical supply chain events."

    - tool_spec:
        type: "cortex_search"
        name: "RiskSearch"
        description: "Searches material risk profile notes and trade lane logistics notes. Contains detailed sourcing risk assessments (supplier dependencies, qualification timelines, alternative evaluation status) and logistics route descriptions (transit routes, hazmat classifications, port congestion notes). Use for sourcing intelligence and logistics risk questions."

    - tool_spec:
        type: "generic"
        name: "StockoutRiskPredictor"
        description: "Returns the top 25 materials at highest risk of stockout based on current inventory vs safety stock. Shows risk score (0-1), risk category (CRITICAL/HIGH/MEDIUM/LOW), days forward coverage, and whether the material is critical-path. Use when asked about stockout risk or materials running low."

    - tool_spec:
        type: "generic"
        name: "DemandForecast"
        description: "Returns the ML-generated demand forecast for the next 8 weeks by plant and product (Series 6 450W, Series 7 500W). Includes point forecast and 90% confidence interval. Use when asked about future demand or production planning needs."

    - tool_spec:
        type: "generic"
        name: "MaterialRiskSummary"
        description: "Returns critical and high-importance materials with supply chain risk profiles: sourcing concentration (single/dual/multi source), geographic risk percentage, substitutability (none/partial/full), lead times, and volatility. Use for single-source risk analysis or supply chain vulnerability assessment."

    - tool_spec:
        type: "generic"
        name: "SupplyChainKPIs"
        description: "Returns an executive KPI summary: total inventory value, average days forward coverage, open PO count and value, total expediting costs, critical recommendation count, unresolved high-severity alerts, and manufacturing schedule adherence percentage. Use for executive summaries or dashboard overviews."

  tool_resources:
    SupplyChainOps:
      semantic_view: "FS_INTELLIGENCE.ANALYTICS.SUPPLY_CHAIN_OPERATIONS_SV"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 299

    ManufacturingDemand:
      semantic_view: "FS_INTELLIGENCE.ANALYTICS.MANUFACTURING_DEMAND_SV"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 299

    RiskIntelligence:
      semantic_view: "FS_INTELLIGENCE.ANALYTICS.RISK_INTELLIGENCE_SV"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 299

    OperationalNotesSearch:
      search_service: "FS_INTELLIGENCE.ANALYTICS.OPERATIONAL_NOTES_SEARCH"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 60

    SupplierEventsSearch:
      search_service: "FS_INTELLIGENCE.ANALYTICS.SUPPLIER_EVENTS_SEARCH"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 60

    RiskSearch:
      search_service: "FS_INTELLIGENCE.ANALYTICS.RISK_INTELLIGENCE_SEARCH"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 60

    StockoutRiskPredictor:
      type: "function"
      identifier: "FS_INTELLIGENCE.ANALYTICS.AGENT_PREDICT_STOCKOUT_RISK"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 60

    DemandForecast:
      type: "function"
      identifier: "FS_INTELLIGENCE.ANALYTICS.AGENT_GET_DEMAND_FORECAST"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 60

    MaterialRiskSummary:
      type: "function"
      identifier: "FS_INTELLIGENCE.ANALYTICS.AGENT_GET_MATERIAL_RISK_SUMMARY"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 60

    SupplyChainKPIs:
      type: "function"
      identifier: "FS_INTELLIGENCE.ANALYTICS.AGENT_GET_SUPPLY_CHAIN_KPIS"
      execution_environment:
        type: "warehouse"
        warehouse: "FIRST_SOLAR_WH"
        query_timeout: 60
  $$;

-- ── Access Grants ───────────────────────────────────────────────────────────
GRANT USAGE ON DATABASE FS_INTELLIGENCE TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA FS_INTELLIGENCE.ANALYTICS TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA FS_INTELLIGENCE.RAW TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA FS_INTELLIGENCE.REFERENCE TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA FS_INTELLIGENCE.RAW TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA FS_INTELLIGENCE.REFERENCE TO ROLE PUBLIC;
GRANT SELECT ON ALL VIEWS IN SCHEMA FS_INTELLIGENCE.ANALYTICS TO ROLE PUBLIC;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW FS_INTELLIGENCE.ANALYTICS.SUPPLY_CHAIN_OPERATIONS_SV TO ROLE PUBLIC;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW FS_INTELLIGENCE.ANALYTICS.MANUFACTURING_DEMAND_SV TO ROLE PUBLIC;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW FS_INTELLIGENCE.ANALYTICS.RISK_INTELLIGENCE_SV TO ROLE PUBLIC;
GRANT USAGE ON AGENT FS_INTELLIGENCE.ANALYTICS.FIRST_SOLAR_AGENT TO ROLE PUBLIC;
GRANT USAGE ON WAREHOUSE FIRST_SOLAR_WH TO ROLE PUBLIC;
