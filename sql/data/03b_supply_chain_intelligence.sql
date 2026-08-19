-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 03b: Seed Reference Data (Supply Chain Intelligence Layer)
-- Scenario: Substrate-glass shortage risk at Alabama plant
-- Plants: Alabama (PLT-AL1), Ohio (PLT-OH1), Louisiana (PLT-LA1)
-- Key supplier: ABC Glass (SUP-001) — primary substrate glass for Alabama
-- ============================================================================

USE DATABASE FS_INTELLIGENCE;
USE WAREHOUSE FIRST_SOLAR_WH;
USE SCHEMA REFERENCE;

-- ============================================================
-- MATERIAL_RISK_PROFILE — All 50 materials
-- ============================================================

TRUNCATE TABLE IF EXISTS MATERIAL_RISK_PROFILE;

INSERT INTO MATERIAL_RISK_PROFILE (material_id, sourcing_risk_tier, geographic_concentration_pct, substitutability, strategic_importance, avg_lead_time_days, lead_time_volatility_cv, notes) VALUES
-- Glass (MAT-001 to MAT-004) — ABC Glass is limited-source for Alabama
('MAT-001','DUAL_SOURCE',55.0,'NONE','CRITICAL',45,0.14,'Low-iron tempered substrate glass — ABC Glass (Mexico) supplies Alabama and Louisiana. Guardian Glass (USA) supplies Ohio. No substitute for CdTe module front glass. ABC Glass is primary supplier for Alabama with limited alternative qualification.'),
('MAT-002','DUAL_SOURCE',55.0,'NONE','CRITICAL',45,0.13,'Back glass panel — same supplier base as front glass. ABC Glass and Guardian. Critical structural component.'),
('MAT-003','MULTI_SOURCE',33.0,'PARTIAL','LOW',30,0.08,'Glass spacers — multiple sources available. Alternative frame-integrated designs exist.'),
('MAT-004','MULTI_SOURCE',33.0,'PARTIAL','LOW',30,0.15,'AR coating chemical — Guardian and others supply. Alternative coatings exist but require 6-month requalification.'),
-- Semiconductor / Active Layer (MAT-005 to MAT-010)
('MAT-005','DUAL_SOURCE',65.0,'NONE','CRITICAL',60,0.20,'CdTe compound — only 5N Plus (Canada) and Umicore (Belgium) supply at 99.995% purity. Irreplaceable for CdTe thin-film technology.'),
('MAT-006','DUAL_SOURCE',65.0,'NONE','CRITICAL',60,0.18,'CdS buffer layer — 5N Plus and Umicore. Essential for p-n junction formation. No substitute in current cell architecture.'),
('MAT-007','DUAL_SOURCE',55.0,'PARTIAL','CRITICAL',60,0.22,'SnO2 target material — Materion and Umicore. Alternative TCO materials (ZnO:Al) require full process requalification (~18 months).'),
('MAT-008','DUAL_SOURCE',55.0,'PARTIAL','CRITICAL',60,0.25,'ITO sputtering target — Materion and Umicore. High purity (99.99%) requirement limits supplier pool globally.'),
('MAT-009','SINGLE_SOURCE',100.0,'PARTIAL','MEDIUM',60,0.19,'Zinc stannate buffer powder — Umicore only at required spec. Alternative buffer (MgZnO) in R&D evaluation.'),
('MAT-010','DUAL_SOURCE',55.0,'FULL','LOW',60,0.15,'Copper back contact material — commodity metal, many sources. Multiple alternative back-contact metals available.'),
-- Frame & Structural (MAT-011 to MAT-015)
('MAT-011','DUAL_SOURCE',40.0,'FULL','LOW',30,0.10,'Aluminum extrusion 2m side rail — Hydro and Arconic. Standard 6063-T6 alloy, widely available.'),
('MAT-012','DUAL_SOURCE',40.0,'FULL','LOW',30,0.10,'Aluminum extrusion short rail — same suppliers and alloy as MAT-011.'),
('MAT-013','MULTI_SOURCE',30.0,'FULL','LOW',25,0.08,'Corner bracket assembly — standard stamped aluminum, 5+ qualified suppliers.'),
('MAT-014','MULTI_SOURCE',25.0,'FULL','LOW',14,0.06,'Mounting hole inserts — commodity fastener, available from any industrial distributor.'),
('MAT-015','MULTI_SOURCE',25.0,'FULL','LOW',14,0.06,'Stainless steel fastener set — commodity hardware, many sources.'),
-- Electronics & Junction Box (MAT-016 to MAT-022)
('MAT-016','DUAL_SOURCE',35.0,'NONE','CRITICAL',25,0.14,'Junction box with bypass diodes — TE Connectivity and Staubli. Custom potting design, 12-month qualification for new suppliers.'),
('MAT-017','DUAL_SOURCE',35.0,'PARTIAL','MEDIUM',25,0.12,'MC4 connector pair — TE and Staubli. Industry-standard interface but supplier-specific tooling.'),
('MAT-018','MULTI_SOURCE',30.0,'FULL','LOW',20,0.09,'Lead-free solder wire — commodity electronics consumable, many suppliers.'),
('MAT-019','MULTI_SOURCE',30.0,'FULL','LOW',20,0.08,'Bypass diode Schottky 15A — standard semiconductor component, multi-source.'),
('MAT-020','DUAL_SOURCE',35.0,'PARTIAL','MEDIUM',22,0.11,'Bussing ribbon copper 6mm — TE and Sumitomo. Specific alloy temper required.'),
('MAT-021','DUAL_SOURCE',35.0,'PARTIAL','LOW',22,0.11,'Cross ribbon copper 3mm — TE and Sumitomo. Same sourcing as MAT-020.'),
('MAT-022','DUAL_SOURCE',40.0,'PARTIAL','CRITICAL',35,0.16,'Encapsulant EVA film — Dow and Eastman. Alternative (POE) requires IEC 61215 requalification (~12 months).'),
-- Chemicals & Coatings (MAT-023 to MAT-027)
('MAT-023','SINGLE_SOURCE',100.0,'NONE','CRITICAL',20,0.30,'CdCl2 activation solution — Henkel only at First Solar specification. Critical for CdTe cell activation. No alternative process available.'),
('MAT-024','MULTI_SOURCE',30.0,'FULL','LOW',18,0.10,'Phosphoric acid etchant — commodity chemical, 5+ suppliers.'),
('MAT-025','MULTI_SOURCE',25.0,'FULL','LOW',15,0.07,'Isopropyl alcohol technical grade — commodity solvent, widely available.'),
('MAT-026','MULTI_SOURCE',25.0,'FULL','LOW',18,0.08,'De-ionized water system resin — standard ion exchange resin, multiple sources.'),
('MAT-027','MULTI_SOURCE',30.0,'FULL','LOW',14,0.06,'Flux no-clean pen — standard electronics consumable.'),
-- Packaging (MAT-028 to MAT-032)
('MAT-028','MULTI_SOURCE',20.0,'FULL','LOW',15,0.07,'Module shipping pallet rack — custom design but multiple metal fabricators qualified.'),
('MAT-029','MULTI_SOURCE',20.0,'FULL','LOW',12,0.06,'Protective foam corner pieces — standard packaging, many suppliers.'),
('MAT-030','MULTI_SOURCE',20.0,'FULL','LOW',10,0.05,'Stretch wrap film — commodity packaging material.'),
('MAT-031','MULTI_SOURCE',20.0,'FULL','LOW',10,0.05,'Module interleaf paper — standard packaging consumable.'),
('MAT-032','MULTI_SOURCE',20.0,'FULL','LOW',12,0.06,'Carton box module single — standard corrugated packaging.'),
-- Equipment Consumables (MAT-033 to MAT-037)
('MAT-033','SINGLE_SOURCE',100.0,'NONE','CRITICAL',70,0.35,'Magnetron sputtering target holder — II-VI only. Custom precision machined component. 10-week lead time, no alternative geometry.'),
('MAT-034','SINGLE_SOURCE',100.0,'PARTIAL','HIGH',70,0.28,'Furnace quartz tube liner — II-VI primary. Alternative quartz suppliers exist but require dimensional qualification.'),
('MAT-035','MULTI_SOURCE',30.0,'FULL','LOW',25,0.10,'Vacuum O-ring kit — standard elastomer seals, many sources (Parker, Trelleborg).'),
('MAT-036','DUAL_SOURCE',35.0,'FULL','MEDIUM',18,0.09,'High purity nitrogen gas — Air Products and Linde. Both deliver to all 3 plants.'),
('MAT-037','DUAL_SOURCE',35.0,'FULL','MEDIUM',18,0.09,'Argon gas high purity — Air Products and Linde. Same delivery infrastructure as N2.'),
-- Backsheet (MAT-038 to MAT-040)
('MAT-038','DUAL_SOURCE',60.0,'PARTIAL','CRITICAL',35,0.18,'TPO backsheet roll — Dow and Borealis (Austria). Alternative backsheets require 12+ months outdoor exposure testing for IEC qualification.'),
('MAT-039','DUAL_SOURCE',60.0,'PARTIAL','CRITICAL',35,0.17,'PVB interlayer film — Dow and Borealis. Same qualification constraints as backsheet materials.'),
('MAT-040','MULTI_SOURCE',33.0,'FULL','LOW',20,0.09,'Edge seal tape — Dow, Eastman, Nitto Denko all qualified. Standard adhesive tape.'),
-- Thermal (MAT-041 to MAT-042)
('MAT-041','MULTI_SOURCE',33.0,'FULL','LOW',18,0.08,'Thermal interface paste — Nitto Denko and 3 other qualified suppliers. Standard thermal compound.'),
('MAT-042','MULTI_SOURCE',33.0,'FULL','LOW',15,0.07,'Heat sink compound syringe — commodity thermal material.'),
-- Laser (MAT-043 to MAT-044)
('MAT-043','SINGLE_SOURCE',100.0,'NONE','CRITICAL',70,0.40,'Laser scribing machine lens — II-VI only. Precision CO2 laser optics, custom focal length. Longest lead time in BOM.'),
('MAT-044','SINGLE_SOURCE',100.0,'PARTIAL','HIGH',70,0.25,'Laser head cooling pump filter — II-VI primary. Generic filter media exists but housing is proprietary.'),
-- QA (MAT-045 to MAT-046)
('MAT-045','DUAL_SOURCE',50.0,'PARTIAL','MEDIUM',50,0.20,'EL imaging camera reference target — 2 qualified optics suppliers. Custom calibration standard.'),
('MAT-046','DUAL_SOURCE',50.0,'PARTIAL','MEDIUM',50,0.18,'IV curve tracer calibration cell — 2 qualified metrology suppliers.'),
-- Hardware (MAT-047 to MAT-050)
('MAT-047','MULTI_SOURCE',25.0,'FULL','LOW',14,0.06,'Grounding lug assembly — standard electrical hardware, many sources.'),
('MAT-048','MULTI_SOURCE',25.0,'FULL','LOW',14,0.07,'Anti-PID film sheet — multiple polymer suppliers qualified.'),
('MAT-049','MULTI_SOURCE',25.0,'FULL','LOW',12,0.06,'Silicone sealant cartridge — standard industrial sealant (Dow, Momentive, Shin-Etsu).'),
('MAT-050','MULTI_SOURCE',25.0,'FULL','LOW',14,0.05,'Label self-adhesive weatherproof — Brady Corporation and 3 other label printers.');

-- ============================================================
-- TRADE_LANE_DIM — Supplier-to-plant logistics routes
-- Updated for Alabama / Ohio / Louisiana geography
-- ============================================================

TRUNCATE TABLE IF EXISTS TRADE_LANE_DIM;

INSERT INTO TRADE_LANE_DIM (supplier_id, plant_id, origin_country, port_of_entry, avg_customs_days, freight_mode, typical_transit_days, tariff_pct, geopolitical_risk_score, notes) VALUES
-- SUP-001: ABC Glass Industries (Mexico, Monterrey) → Substrate Glass
('SUP-001','PLT-AL1','Mexico','Laredo TX',2.0,'TRUCK',3,0.0,2.5,'ABC Glass — Monterrey to Alabama via Laredo TX border crossing. 900 miles. PRIMARY substrate glass supplier for Alabama plant. Cross-border customs typically 1-2 days. Route passes through Gulf Coast corridor.'),
('SUP-001','PLT-LA1','Mexico','Laredo TX',2.0,'TRUCK',2,0.0,2.5,'ABC Glass — Monterrey to Louisiana via Laredo. 650 miles. Shorter route than Alabama.'),
-- SUP-002: NSG Pilkington (Japan) → Glass
('SUP-002','PLT-LA1','Japan','Port of New Orleans',4.5,'OCEAN',35,2.5,3.2,'NSG Pilkington via Pacific → Panama Canal → Gulf of Mexico. 5-week ocean transit.'),
-- SUP-003: Guardian Glass (USA, Michigan) → Glass (Ohio primary, qualified alt for others)
('SUP-003','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Guardian Glass — Auburn Hills MI to Perrysburg OH. 150 miles, same-day delivery. Qualified alternative supplier for substrate glass.'),
('SUP-003','PLT-LA1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Guardian Glass — MI to Louisiana. 850 miles, 2-day truck.'),
-- SUP-004: 5N Plus (Canada, Montreal) → Semiconductor
('SUP-004','PLT-OH1','Canada','Port Huron MI',1.5,'TRUCK',4,0.0,1.8,'5N Plus Montreal — cross-border via Port Huron. Hazmat classification (cadmium compounds) adds 1-2 day customs delay.'),
('SUP-004','PLT-AL1','Canada','Detroit MI',2.0,'TRUCK',5,0.0,1.8,'5N Plus to Alabama — cross-border then 700 miles south. Hazmat routing.'),
-- SUP-005: Materion (USA, Ohio) → Semiconductor
('SUP-005','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Materion — Mayfield Heights OH to Perrysburg OH. 120 miles, same-day delivery.'),
('SUP-005','PLT-AL1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Materion OH to Alabama. 680 miles.'),
('SUP-005','PLT-LA1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Materion OH to Louisiana. 850 miles.'),
-- SUP-006: Umicore (Belgium) → Semiconductor
('SUP-006','PLT-OH1','Belgium','Port Newark NJ',3.5,'OCEAN',28,3.8,4.5,'Umicore Brussels via Atlantic. EU export controls on cadmium compounds require end-use certificate. 4-week transit + truck to OH.'),
('SUP-006','PLT-AL1','Belgium','Port of Savannah',3.5,'OCEAN',26,3.8,4.5,'Umicore — Atlantic route to Savannah, then truck 350 miles to Alabama.'),
-- SUP-007: Hydro Extrusions (USA, Virginia) → Frame
('SUP-007','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Hydro Extrusions — Roanoke VA to Perrysburg OH. 400 miles.'),
('SUP-007','PLT-AL1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Hydro VA to Alabama. 450 miles, overnight truck.'),
('SUP-007','PLT-LA1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Hydro VA to Louisiana. 900 miles.'),
-- SUP-008: Arconic (USA, Pittsburgh) → Frame
('SUP-008','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Arconic — Pittsburgh PA to Perrysburg OH. 250 miles, same-day.'),
('SUP-008','PLT-AL1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Arconic PA to Alabama. 700 miles.'),
-- SUP-009: TE Connectivity (USA, Pennsylvania) → Electronics
('SUP-009','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'TE Connectivity — Berwyn PA to Perrysburg OH. 450 miles.'),
('SUP-009','PLT-AL1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'TE PA to Alabama. 750 miles.'),
('SUP-009','PLT-LA1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'TE PA to Louisiana. 1,100 miles.'),
-- SUP-010: Staubli (USA, South Carolina) → Electronics
('SUP-010','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Staubli — Duncan SC to Perrysburg OH. 600 miles.'),
('SUP-010','PLT-AL1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Staubli SC to Alabama. 350 miles.'),
-- SUP-011: Henkel (USA, Connecticut) → Chemicals
('SUP-011','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Henkel — Rocky Hill CT to OH. 650 miles. Hazmat (CdCl2 solution). Dedicated carrier.'),
('SUP-011','PLT-AL1','USA','N/A',0.0,'TRUCK',3,0.0,1.0,'Henkel CT to Alabama. 1,000 miles. Hazmat restricted routing.'),
-- SUP-012: Dow Chemical (USA, Michigan) → Encapsulants
('SUP-012','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Dow Chemical — Midland MI to Perrysburg OH. 130 miles, same-day.'),
('SUP-012','PLT-AL1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Dow MI to Alabama. 700 miles.'),
('SUP-012','PLT-LA1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Dow MI to Louisiana. 850 miles.'),
-- SUP-013: Air Products → Gases
('SUP-013','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Air Products — delivered from regional OH depot.'),
('SUP-013','PLT-AL1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Air Products — Birmingham AL regional depot to plant.'),
('SUP-013','PLT-LA1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Air Products — Baton Rouge LA depot.'),
-- SUP-014: Linde Gases → Gases
('SUP-014','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Linde — regional OH distribution.'),
('SUP-014','PLT-AL1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Linde — Huntsville AL depot.'),
-- SUP-015: Borealis (Austria) → Backsheet
('SUP-015','PLT-OH1','Austria','Port Newark NJ',4.0,'OCEAN',30,4.2,3.8,'Borealis Vienna via Atlantic. Polymer rolls on container vessel. 4-week transit + truck to OH.'),
('SUP-015','PLT-AL1','Austria','Port of Savannah',4.0,'OCEAN',28,4.2,3.8,'Borealis via Atlantic to Savannah, then truck 350 miles to Alabama.'),
-- SUP-016: Eastman Chemical → Encapsulants
('SUP-016','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Eastman — Kingsport TN to OH. 500 miles.'),
('SUP-016','PLT-AL1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Eastman TN to Alabama. 250 miles.'),
-- SUP-017: II-VI → Equipment Consumables
('SUP-017','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'II-VI — Saxonburg PA to OH. 280 miles. White-glove freight for precision optics.'),
('SUP-017','PLT-AL1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'II-VI PA to Alabama. 700 miles. Climate-controlled.'),
('SUP-017','PLT-LA1','USA','N/A',0.0,'TRUCK',3,0.0,1.0,'II-VI PA to Louisiana. 1,100 miles.'),
-- SUP-018: Sumitomo Electric → Electronics
('SUP-018','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Sumitomo Electric — Columbus OH to Perrysburg OH. 130 miles.'),
('SUP-018','PLT-AL1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Sumitomo OH to Alabama. 650 miles.'),
-- SUP-019: Brady Corporation → Labels
('SUP-019','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Brady Corp — Milwaukee WI to OH. 350 miles.'),
('SUP-019','PLT-AL1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Brady WI to Alabama. 700 miles.'),
-- SUP-020: Nitto Denko (Japan) → Tapes
('SUP-020','PLT-OH1','Japan','Port of Long Beach',4.5,'OCEAN',33,2.5,3.2,'Nitto Denko Osaka via Pacific to Long Beach, then rail to OH.'),
('SUP-020','PLT-AL1','Japan','Port of Savannah',4.5,'OCEAN',35,2.5,3.2,'Nitto Denko via Panama Canal to Savannah, then truck to Alabama.');

-- ============================================================
-- INDUSTRY_BENCHMARK_DIM — CdTe Manufacturing KPIs
-- ============================================================

TRUNCATE TABLE IF EXISTS INDUSTRY_BENCHMARK_DIM;

INSERT INTO INDUSTRY_BENCHMARK_DIM (metric_name, material_category, benchmark_value, unit, source, effective_date) VALUES
('avg_lead_time_days','Glass',40.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Semiconductor',52.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Frame',25.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Electronics',22.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Chemicals',18.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Equipment Consumable',60.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Backsheet',30.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Packaging',12.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Thermal',15.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','Hardware',12.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('avg_lead_time_days','QA Consumable',45.0,'days','BNEF Solar Supply Chain Report 2024','2024-06-01'),
('target_days_forward_coverage','Glass',45.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Semiconductor',75.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Frame',30.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Electronics',30.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Chemicals',25.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Equipment Consumable',90.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Backsheet',40.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Packaging',20.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('supplier_otd_benchmark',NULL,0.94,'fraction','ISM Manufacturing Report 2024','2024-09-01'),
('supplier_otd_top_quartile',NULL,0.97,'fraction','ISM Manufacturing Report 2024','2024-09-01'),
('supplier_quality_benchmark',NULL,0.992,'fraction','ISM Manufacturing Report 2024','2024-09-01'),
('supplier_quality_top_quartile',NULL,0.998,'fraction','ISM Manufacturing Report 2024','2024-09-01'),
('target_inventory_turns',NULL,8.5,'turns/year','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_inventory_turns_top_quartile',NULL,11.0,'turns/year','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('expediting_cost_ratio',NULL,0.03,'fraction of total procurement','APICS Supply Chain Benchmarks 2024','2024-01-01'),
('manufacturing_schedule_adherence',NULL,0.92,'fraction','SEMI Solar Manufacturing KPIs 2024','2024-06-01'),
('manufacturing_schedule_adherence_top',NULL,0.96,'fraction','SEMI Solar Manufacturing KPIs 2024','2024-06-01'),
('demand_forecast_mape',NULL,8.5,'percent','IBF Forecasting Benchmarks 2024','2024-01-01'),
('demand_forecast_mape_best',NULL,5.0,'percent','IBF Forecasting Benchmarks 2024','2024-01-01'),
('cdte_deposition_yield',NULL,0.965,'fraction','First Solar 10-K FY2024 (public)','2024-12-31'),
('module_line_throughput',NULL,1200.0,'modules/line/day','SEMI PV Manufacturing Report 2024','2024-06-01'),
('single_source_material_pct',NULL,0.12,'fraction of BOM','Gartner Supply Chain Risk Benchmarks 2024','2024-04-01'),
('avg_supplier_risk_score',NULL,3.0,'1-10 scale','Gartner Supply Chain Risk Benchmarks 2024','2024-04-01'),
('freight_cost_pct_of_cogs',NULL,0.045,'fraction','CSCMP State of Logistics 2024','2024-06-01'),
('inter_plant_transfer_utilization',NULL,0.15,'fraction of total material flow','Internal benchmark','2025-01-01'),
('glass_inventory_coverage_minimum',NULL,21.0,'days','First Solar Internal Standard','2025-01-01'),
('daily_glass_consumption_rate_al',NULL,530.0,'panels/day','First Solar Alabama Production Plan','2025-01-01');

-- ============================================================
-- SUPPLIER_EVENT_LOG — 6 months of disruption history
-- ABC Glass (SUP-001) has CLEAN HISTORY — supports Act 1 narrative
-- ============================================================

TRUNCATE TABLE IF EXISTS SUPPLIER_EVENT_LOG;

INSERT INTO SUPPLIER_EVENT_LOG (event_date, supplier_id, event_type, severity, description, resolution_date, impact_materials) VALUES
-- January 2025
('2025-01-08','SUP-002','PORT_DELAY','MEDIUM','NSG Pilkington glass shipment held at New Orleans port — container inspection triggered by random customs audit. Expected 3-day delay. 2 containers (4,000 panels) for Louisiana plant affected.','2025-01-11','MAT-001, MAT-002'),
('2025-01-22','SUP-004','QUALITY_HOLD','HIGH','5N Plus CdTe compound batch failed incoming purity specification. Required: 99.995% Cd, actual: 99.991%. Trace selenium contamination. Batch rejected, replacement lot in production. Expected 14-day delay.','2025-02-05','MAT-005, MAT-006'),
('2025-01-28','SUP-013','CAPACITY_CHANGE','LOW','Air Products notified Alabama plant that nitrogen delivery schedule changing from 3x/week to daily deliveries starting February 1. Capacity increase — no supply risk.','2025-02-01','MAT-036'),
-- February 2025
('2025-02-03','SUP-015','FORCE_MAJEURE','HIGH','Borealis Vienna plant experienced gear failure in backsheet extrusion line #3. Line produces 60% of First Solar TPO allocation. Estimated 3-week repair. Emergency procurement from Dow initiated at 12% price premium.','2025-02-24','MAT-038, MAT-039'),
('2025-02-10','SUP-006','PORT_DELAY','LOW','Umicore semiconductor material — routine customs inspection at Port Newark for cadmium-containing materials under EPA TSCA Section 12(b). 3-day administrative delay. Standard occurrence.','2025-02-13','MAT-005, MAT-007, MAT-009'),
('2025-02-14','SUP-012','CAPACITY_CHANGE','LOW','Dow Chemical confirmed ability to supply 40% of Borealis TPO allocation from Midland MI at 12% spot premium. Temporary dual-source arrangement through March 15.','2025-03-15','MAT-038, MAT-039'),
('2025-02-18','SUP-017','CAPACITY_CHANGE','MEDIUM','II-VI Incorporated announced 15% capacity reduction on magnetron sputtering targets due to unplanned furnace maintenance. Lead times extended from 70 to 84 days through end of March.','2025-03-15','MAT-033, MAT-034, MAT-043, MAT-044'),
('2025-02-22','SUP-005','PRICE_INCREASE','LOW','Materion notified 4% price increase on ITO targets effective March 1, citing indium spot price increase (+18% YTD). Contractual escalation clause triggered. No supply impact.','2025-03-01','MAT-007, MAT-008, MAT-010'),
-- March 2025
('2025-03-01','SUP-011','PRICE_INCREASE','MEDIUM','Henkel notified 8% price increase on CdCl2 activation solution effective April 1, citing cadmium chloride cost escalation (+22% since Jan). Single-source material. Annual spend impact ~$180K.','2025-04-01','MAT-023'),
('2025-03-05','SUP-020','PORT_DELAY','LOW','Nitto Denko edge seal tape shipment delayed at Long Beach — 4-day backlog from weather. Low criticality material with 45+ days coverage. No production impact.','2025-03-09','MAT-040, MAT-041, MAT-042'),
('2025-03-10','SUP-007','QUALITY_HOLD','LOW','Hydro Extrusions lot: minor surface anodization inconsistency on 200 frames (out of 5,000). Cosmetic only. Lot accepted with deviation.','2025-03-12','MAT-011, MAT-012'),
('2025-03-12','SUP-003','QUALITY_HOLD','MEDIUM','Guardian Glass lot placed on quality hold — micro-fracture detected in 2% of panels during incoming EL inspection at Ohio. 3,000 panels in lot. Root cause under investigation.','2025-03-18','MAT-001, MAT-003'),
('2025-03-15','SUP-017','CAPACITY_CHANGE','LOW','II-VI furnace maintenance completed ahead of schedule. Capacity restored to 100%. Lead times returning to standard 70 days.','2025-03-30','MAT-033, MAT-034, MAT-043, MAT-044'),
('2025-03-18','SUP-015','CAPACITY_CHANGE','LOW','Borealis Vienna extrusion line #3 repair completed. Full production capacity restored.','2025-03-25','MAT-038, MAT-039'),
('2025-03-22','SUP-006','PORT_DELAY','MEDIUM','Umicore zinc stannate buffer shipment delayed — vessel diverted from Suez Canal route. Re-routing via Cape of Good Hope adds 12 days transit. Single-source material.','2025-04-08','MAT-009'),
('2025-03-25','SUP-004','FORCE_MAJEURE','HIGH','5N Plus Montreal facility HVAC failure in ISO Class 5 clean room. CdTe production suspended 5 days pending re-certification. Umicore contacted for emergency allocation.','2025-03-30','MAT-005, MAT-006'),
('2025-03-28','SUP-008','QUALITY_HOLD','LOW','Arconic aluminum frame lot — dimensional variance on 150 short rails (0.3mm over spec). Accepted with production waiver.','2025-03-29','MAT-012, MAT-014'),
-- ABC Glass (SUP-001) — NO EVENTS. Clean supplier history supports Act 1 narrative.
-- The absence of events for ABC Glass is intentional — from Oracle/ERP data, they look perfect.
('2025-03-30','SUP-001','CAPACITY_CHANGE','LOW','ABC Glass Industries confirmed Q2 production schedule aligned with First Solar demand plan. All open POs on track. No issues reported.','2025-03-30','MAT-001, MAT-002'),
('2025-03-15','SUP-009','CAPACITY_CHANGE','LOW','TE Connectivity announced 10% capacity increase for MC4 connector and junction box production. New automated assembly cell operational. Lead times to improve by 3 days starting April 1.','2025-04-15','MAT-016, MAT-017, MAT-019'),
('2025-03-20','SUP-001','CAPACITY_CHANGE','LOW','ABC Glass Industries quarterly business review: on-time delivery rate 97.2% trailing 12 months. Quality pass rate 99.5%. No capacity constraints identified for Q2. Monterrey facility running at 85% utilization.','2025-03-20','MAT-001, MAT-002');

-- ============================================================
-- MATERIAL_LOT_TRACE — Traceability chains
-- Updated for Alabama / Ohio / Louisiana
-- ============================================================

TRUNCATE TABLE IF EXISTS MATERIAL_LOT_TRACE;

INSERT INTO MATERIAL_LOT_TRACE (lot_id, event_type, event_date, plant_id, material_id, po_id, schedule_id, parent_lot_id, quantity, description) VALUES
-- Chain 1: ABC Glass → Alabama → Series 7 production → NextEra shipment
('LOT-GLASS-ABC-0115','RECEIVED','2025-01-15','PLT-AL1','MAT-001','PO-000012',NULL,NULL,5300.000,'ABC Glass substrate glass panels received at Alabama plant. Cross-border from Monterrey, 3-day transit. Visual + EL inspection passed. 5,300 panels stored in glass warehouse.'),
('LOT-GLASS-ABC-0115','CONSUMED','2025-01-20','PLT-AL1','MAT-001',NULL,3,NULL,2650.000,'Front glass consumed in Series 7 lamination line — week 3 at Alabama.'),
('LOT-MOD-AL1-S7-WK03','PRODUCED','2025-01-24','PLT-AL1',NULL,NULL,3,'LOT-GLASS-ABC-0115',2650.000,'Series 7 modules produced week 3 — 2,650 units at Alabama. Yield: 96.5%.'),
('LOT-MOD-AL1-S7-WK03','SHIPPED','2025-01-28','PLT-AL1',NULL,NULL,NULL,'LOT-MOD-AL1-S7-WK03',1300.000,'Shipped 1,300 Series 7 modules to NextEra Energy — Gulf Coast Solar Project, Mobile County AL.'),
('LOT-MOD-AL1-S7-WK03','SHIPPED','2025-01-30','PLT-AL1',NULL,NULL,NULL,'LOT-MOD-AL1-S7-WK03',1350.000,'Shipped 1,350 modules to Invenergy — Magnolia Solar, Mississippi.'),

-- Chain 2: Guardian Glass → Ohio → Series 6 production
('LOT-GLASS-GRD-0203','RECEIVED','2025-02-03','PLT-OH1','MAT-001','PO-000089',NULL,NULL,4200.000,'Guardian Glass panels received at Ohio. Domestic shipment from Auburn Hills MI, same-day delivery.'),
('LOT-GLASS-GRD-0203','CONSUMED','2025-02-07','PLT-OH1','MAT-001',NULL,6,NULL,2100.000,'Consumed in Series 6 production week 6 at Ohio.'),
('LOT-MOD-OH1-S6-WK06','PRODUCED','2025-02-10','PLT-OH1',NULL,NULL,6,'LOT-GLASS-GRD-0203',2100.000,'Series 6 modules produced week 6 — 2,100 units at Ohio. Yield: 97.1%.'),

-- Chain 3: CdTe from 5N Plus → Ohio → Series 6
('LOT-CdTe-5NP-0115','RECEIVED','2025-01-15','PLT-OH1','MAT-005','PO-000042',NULL,NULL,12.500,'5N Plus CdTe compound received at Ohio. CoA: purity 99.997%, particle size D50=45 um.'),
('LOT-CdTe-5NP-0115','CONSUMED','2025-01-20','PLT-OH1','MAT-005',NULL,3,NULL,4.200,'Consumed in CdTe deposition — Series 6 week 3, line A.'),

-- Chain 4: Guardian Glass quality issue → trace-back
('LOT-GLASS-GRD-0312','RECEIVED','2025-03-12','PLT-OH1','MAT-001','PO-000201',NULL,NULL,3000.000,'Guardian Glass lot — QUALITY HOLD. EL inspection detected micro-fracture in 2% of panels (60 units). Lot quarantined.'),
('LOT-GLASS-GRD-0312-A','RECEIVED','2025-03-18','PLT-OH1','MAT-001','PO-000201',NULL,'LOT-GLASS-GRD-0312',2940.000,'Lot released after sorting. 60 panels rejected, 2,940 accepted.'),
('LOT-GLASS-GRD-0312-A','CONSUMED','2025-03-22','PLT-OH1','MAT-001',NULL,12,NULL,2450.000,'Accepted panels consumed in Series 6 production week 12.'),

-- Chain 5: ABC Glass → Alabama (most recent — just before scenario date)
('LOT-GLASS-ABC-0315','RECEIVED','2025-03-15','PLT-AL1','MAT-001','PO-000180',NULL,NULL,5000.000,'ABC Glass substrate glass received at Alabama. On-time delivery. Inspection passed. This is the most recent glass receipt — next delivery expected in ~3 weeks.'),
('LOT-GLASS-ABC-0315','CONSUMED','2025-03-20','PLT-AL1','MAT-001',NULL,12,NULL,2500.000,'Front glass consumed in Series 7 production week 12.'),
('LOT-GLASS-ABC-0315','CONSUMED','2025-03-27','PLT-AL1','MAT-001',NULL,13,NULL,2500.000,'Remaining glass consumed in week 13. Alabama glass inventory now at approximately 18 days forward coverage.'),

-- Chain 6: Inter-plant transfer (CdTe OH → AL)
('LOT-CdTe-XFER-0305','RECEIVED','2025-03-01','PLT-OH1','MAT-005','PO-000190',NULL,NULL,10.000,'5N Plus CdTe received at Ohio — partial lot designated for transfer to Alabama.'),
('LOT-CdTe-XFER-0305','SHIPPED','2025-03-05','PLT-OH1','MAT-005',NULL,NULL,'LOT-CdTe-XFER-0305',5.000,'5 kg CdTe transferred from Ohio to Alabama via inter-plant transfer. Hazmat carrier, 2-day transit.'),
('LOT-CdTe-XFER-0305-AL','RECEIVED','2025-03-07','PLT-AL1','MAT-005',NULL,NULL,'LOT-CdTe-XFER-0305',5.000,'CdTe transfer received at Alabama from Ohio. Integrity verified.'),

-- Chain 7: II-VI laser lens → Alabama
('LOT-LENS-IIV-0105','RECEIVED','2025-01-05','PLT-AL1','MAT-043','PO-000015',NULL,NULL,4.000,'II-VI laser scribing lenses received at Alabama. 70-day lead time. White-glove delivery.'),
('LOT-LENS-IIV-0105','CONSUMED','2025-02-15','PLT-AL1','MAT-043',NULL,NULL,NULL,1.000,'Laser lens installed in P3 scribing tool during scheduled maintenance.');
