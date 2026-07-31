-- ============================================================================
-- First Solar Supply Chain Intelligence Agent
-- 03b: Seed Reference Data
-- Comprehensive supply chain intelligence layer:
--   • MATERIAL_RISK_PROFILE — All 50 materials with sourcing risk classification
--   • TRADE_LANE_DIM — All supplier-to-plant logistics routes
--   • INDUSTRY_BENCHMARK_DIM — CdTe manufacturing KPIs by category
--   • SUPPLIER_EVENT_LOG — 6 months of supplier disruption history
--   • MATERIAL_LOT_TRACE — Multi-chain traceability events
-- ============================================================================

USE DATABASE FS_INTELLIGENCE;
USE WAREHOUSE FIRST_SOLAR_WH;
USE SCHEMA REFERENCE;

-- ============================================================
-- MATERIAL_RISK_PROFILE — All 50 materials
-- Sourcing risk, substitutability, strategic importance
-- ============================================================

TRUNCATE TABLE IF EXISTS MATERIAL_RISK_PROFILE;

INSERT INTO MATERIAL_RISK_PROFILE (material_id, sourcing_risk_tier, geographic_concentration_pct, substitutability, strategic_importance, avg_lead_time_days, lead_time_volatility_cv, notes) VALUES
-- Glass (MAT-001 to MAT-004)
('MAT-001','MULTI_SOURCE',45.0,'NONE','CRITICAL',45,0.12,'Low-iron tempered glass — 3 qualified suppliers (AGC, NSG, Guardian). No substitute for CdTe module front glass. 50% of suppliers in Japan.'),
('MAT-002','MULTI_SOURCE',45.0,'NONE','CRITICAL',45,0.11,'Back glass panel — same supplier base as front glass. Critical structural component.'),
('MAT-003','MULTI_SOURCE',33.0,'PARTIAL','LOW',30,0.08,'Glass spacers — multiple sources available. Alternative frame-integrated designs exist.'),
('MAT-004','DUAL_SOURCE',50.0,'PARTIAL','MEDIUM',30,0.15,'AR coating chemical — Guardian and AGC supply. Alternative coatings exist but require 6-month requalification.'),
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
('MAT-016','DUAL_SOURCE',35.0,'NONE','CRITICAL',25,0.14,'Junction box with bypass diodes — TE Connectivity and Stäubli. Custom potting design, 12-month qualification for new suppliers.'),
('MAT-017','DUAL_SOURCE',35.0,'PARTIAL','MEDIUM',25,0.12,'MC4 connector pair — TE and Stäubli. Industry-standard interface but supplier-specific tooling.'),
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
-- Packaging & Shipping (MAT-028 to MAT-032)
('MAT-028','MULTI_SOURCE',20.0,'FULL','LOW',15,0.07,'Module shipping pallet rack — custom design but multiple metal fabricators qualified.'),
('MAT-029','MULTI_SOURCE',20.0,'FULL','LOW',12,0.06,'Protective foam corner pieces — standard packaging, many suppliers.'),
('MAT-030','MULTI_SOURCE',20.0,'FULL','LOW',10,0.05,'Stretch wrap film — commodity packaging material.'),
('MAT-031','MULTI_SOURCE',20.0,'FULL','LOW',10,0.05,'Module interleaf paper — standard packaging consumable.'),
('MAT-032','MULTI_SOURCE',20.0,'FULL','LOW',12,0.06,'Carton box module single — standard corrugated packaging.'),
-- Sputtering & Vapor Deposition Consumables (MAT-033 to MAT-037)
('MAT-033','SINGLE_SOURCE',100.0,'NONE','CRITICAL',70,0.35,'Magnetron sputtering target holder — II-VI only. Custom precision machined component. 10-week lead time, no alternative geometry.'),
('MAT-034','SINGLE_SOURCE',100.0,'PARTIAL','HIGH',70,0.28,'Furnace quartz tube liner — II-VI primary. Alternative quartz suppliers exist but require dimensional qualification.'),
('MAT-035','MULTI_SOURCE',30.0,'FULL','LOW',25,0.10,'Vacuum O-ring kit — standard elastomer seals, many sources (Parker, Trelleborg).'),
('MAT-036','DUAL_SOURCE',35.0,'FULL','MEDIUM',18,0.09,'High purity nitrogen gas — Air Products and Linde. Both deliver to all 3 plants.'),
('MAT-037','DUAL_SOURCE',35.0,'FULL','MEDIUM',18,0.09,'Argon gas high purity — Air Products and Linde. Same delivery infrastructure as N2.'),
-- Backsheet & Encapsulation (MAT-038 to MAT-040)
('MAT-038','DUAL_SOURCE',60.0,'PARTIAL','CRITICAL',35,0.18,'TPO backsheet roll — Dow and Borealis (Austria). Alternative backsheets require 12+ months outdoor exposure testing for IEC qualification.'),
('MAT-039','DUAL_SOURCE',60.0,'PARTIAL','CRITICAL',35,0.17,'PVB interlayer film — Dow and Borealis. Same qualification constraints as backsheet materials.'),
('MAT-040','MULTI_SOURCE',33.0,'FULL','LOW',20,0.09,'Edge seal tape — Dow, Eastman, Nitto Denko all qualified. Standard adhesive tape.'),
-- Thermal Management (MAT-041 to MAT-042)
('MAT-041','MULTI_SOURCE',33.0,'FULL','LOW',18,0.08,'Thermal interface paste — Nitto Denko and 3 other qualified suppliers. Standard thermal compound.'),
('MAT-042','MULTI_SOURCE',33.0,'FULL','LOW',15,0.07,'Heat sink compound syringe — commodity thermal material.'),
-- Laser Scribing Consumables (MAT-043 to MAT-044)
('MAT-043','SINGLE_SOURCE',100.0,'NONE','CRITICAL',70,0.40,'Laser scribing machine lens — II-VI only. Precision CO2 laser optics, custom focal length. Longest lead time in BOM.'),
('MAT-044','SINGLE_SOURCE',100.0,'PARTIAL','HIGH',70,0.25,'Laser head cooling pump filter — II-VI primary. Generic filter media exists but housing is proprietary.'),
-- QA / Testing (MAT-045 to MAT-046)
('MAT-045','DUAL_SOURCE',50.0,'PARTIAL','MEDIUM',50,0.20,'EL imaging camera reference target — 2 qualified optics suppliers. Custom calibration standard.'),
('MAT-046','DUAL_SOURCE',50.0,'PARTIAL','MEDIUM',50,0.18,'IV curve tracer calibration cell — 2 qualified metrology suppliers.'),
-- Misc Hardware (MAT-047 to MAT-050)
('MAT-047','MULTI_SOURCE',25.0,'FULL','LOW',14,0.06,'Grounding lug assembly — standard electrical hardware, many sources.'),
('MAT-048','MULTI_SOURCE',25.0,'FULL','LOW',14,0.07,'Anti-PID film sheet — multiple polymer suppliers qualified.'),
('MAT-049','MULTI_SOURCE',25.0,'FULL','LOW',12,0.06,'Silicone sealant cartridge — standard industrial sealant (Dow, Momentive, Shin-Etsu).'),
('MAT-050','MULTI_SOURCE',25.0,'FULL','LOW',14,0.05,'Label self-adhesive weatherproof — Brady Corporation and 3 other label printers.');

-- ============================================================
-- TRADE_LANE_DIM — All supplier-to-plant logistics routes
-- Every supplier × plant combination from SUPPLIER_MATERIALS
-- ============================================================

TRUNCATE TABLE IF EXISTS TRADE_LANE_DIM;

INSERT INTO TRADE_LANE_DIM (supplier_id, plant_id, origin_country, port_of_entry, avg_customs_days, freight_mode, typical_transit_days, tariff_pct, geopolitical_risk_score, notes) VALUES
-- SUP-001: AGC Inc (Japan) → Glass
('SUP-001','PLT-OH1','Japan','Port of Long Beach',4.5,'OCEAN',35,2.5,3.2,'AGC flat glass via Pacific route. 5-week ocean transit, then intermodal rail to OH. Vessel: weekly NYK Line sailing.'),
('SUP-001','PLT-OH2','Japan','Port of Long Beach',4.5,'OCEAN',35,2.5,3.2,'AGC flat glass via Pacific route. Same terminal as OH1 — last-mile truck from Toledo depot.'),
('SUP-001','PLT-AZ1','Japan','Port of Long Beach',4.0,'OCEAN',32,2.5,3.2,'AGC flat glass. Shorter inland leg to Mesa via I-10. 4.5-week total.'),
-- SUP-002: NSG Pilkington (Japan) → Glass
('SUP-002','PLT-OH1','Japan','Port of Long Beach',4.5,'OCEAN',35,2.5,3.2,'NSG Pilkington via Pacific. Same vessel rotation as AGC.'),
('SUP-002','PLT-AZ1','Japan','Port of Long Beach',4.0,'OCEAN',32,2.5,3.2,'NSG Pilkington — West Coast discharge, truck to Mesa.'),
-- SUP-003: Guardian Glass (USA, Michigan) → Glass
('SUP-003','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Guardian Glass — Auburn Hills MI to Perrysburg OH. 150 miles, same-day delivery. Flatbed with A-frames.'),
('SUP-003','PLT-OH2','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Guardian Glass — same route as OH1 (same industrial park).'),
('SUP-003','PLT-AZ1','USA','N/A',0.0,'TRUCK',4,0.0,1.0,'Guardian Glass — MI to Mesa AZ via I-80/I-40. 1,800 miles, 3-4 day truck.'),
-- SUP-004: 5N Plus (Canada, Montreal) → Semiconductor
('SUP-004','PLT-OH1','Canada','Port Huron MI',1.5,'TRUCK',4,0.0,1.8,'5N Plus Montreal — cross-border via Port Huron. Hazmat classification (cadmium compounds) adds 1-2 day customs delay.'),
('SUP-004','PLT-OH2','Canada','Port Huron MI',1.5,'TRUCK',4,0.0,1.8,'5N Plus to OH2 — same border crossing as OH1.'),
('SUP-004','PLT-AZ1','Canada','Nogales AZ',2.0,'TRUCK',6,0.0,1.8,'5N Plus Montreal to Mesa — cross-border. Hazmat + 2,500 miles. Longest domestic cadmium route.'),
-- SUP-005: Materion (USA, Ohio) → Semiconductor
('SUP-005','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Materion — Mayfield Heights OH to Perrysburg OH. 120 miles, same-day delivery possible.'),
('SUP-005','PLT-OH2','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Materion — same route, both plants in Perrysburg.'),
('SUP-005','PLT-AZ1','USA','N/A',0.0,'TRUCK',4,0.0,1.0,'Materion OH to Mesa AZ. 1,800 miles. Hazmat (ITO targets).'),
-- SUP-006: Umicore (Belgium) → Semiconductor
('SUP-006','PLT-OH1','Belgium','Port Newark NJ',3.5,'OCEAN',28,3.8,4.5,'Umicore Brussels via Atlantic. EU export controls on cadmium compounds require end-use certificate. 4-week transit + rail to OH.'),
('SUP-006','PLT-OH2','Belgium','Port Newark NJ',3.5,'OCEAN',28,3.8,4.5,'Umicore to OH2 — same route as OH1.'),
('SUP-006','PLT-AZ1','Belgium','Port of Long Beach',3.5,'OCEAN',38,3.8,4.5,'Umicore via Suez Canal → Pacific. 5.5-week transit. Longest supply route in network.'),
-- SUP-007: Hydro Extrusions (USA, Virginia) → Frame
('SUP-007','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Hydro Extrusions — Roanoke VA to Perrysburg OH. 400 miles, overnight truck.'),
('SUP-007','PLT-OH2','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Hydro to OH2 — same destination as OH1.'),
('SUP-007','PLT-AZ1','USA','N/A',0.0,'TRUCK',4,0.0,1.0,'Hydro VA to Mesa AZ. 2,100 miles cross-country.'),
-- SUP-008: Arconic (USA, Pittsburgh) → Frame
('SUP-008','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Arconic — Pittsburgh PA to Perrysburg OH. 250 miles, same-day.'),
('SUP-008','PLT-OH2','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Arconic to OH2 — same as OH1.'),
('SUP-008','PLT-AZ1','USA','N/A',0.0,'TRUCK',4,0.0,1.0,'Arconic PA to Mesa AZ. 2,200 miles.'),
-- SUP-009: TE Connectivity (USA, Pennsylvania) → Electronics
('SUP-009','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'TE Connectivity — Berwyn PA to Perrysburg OH. 450 miles.'),
('SUP-009','PLT-OH2','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'TE to OH2 — same route.'),
('SUP-009','PLT-AZ1','USA','N/A',0.0,'TRUCK',4,0.0,1.0,'TE PA to Mesa AZ. 2,300 miles.'),
-- SUP-010: Stäubli (USA, South Carolina) → Electronics
('SUP-010','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Stäubli — Duncan SC to Perrysburg OH. 600 miles.'),
('SUP-010','PLT-OH2','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Stäubli to OH2.'),
('SUP-010','PLT-AZ1','USA','N/A',0.0,'TRUCK',3,0.0,1.0,'Stäubli SC to Mesa AZ. 1,700 miles.'),
-- SUP-011: Henkel (USA, Connecticut) → Chemicals
('SUP-011','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Henkel — Rocky Hill CT to Perrysburg OH. 650 miles. Hazmat (CdCl2 solution). Dedicated carrier.'),
('SUP-011','PLT-AZ1','USA','N/A',0.0,'TRUCK',5,0.0,1.0,'Henkel CT to Mesa AZ. 2,400 miles. Hazmat restricted routing adds 1 day.'),
-- SUP-012: Dow Chemical (USA, Michigan) → Encapsulants/Backsheet
('SUP-012','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Dow Chemical — Midland MI to Perrysburg OH. 130 miles, same-day.'),
('SUP-012','PLT-OH2','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Dow to OH2 — same route.'),
('SUP-012','PLT-AZ1','USA','N/A',0.0,'TRUCK',4,0.0,1.0,'Dow MI to Mesa AZ. 1,850 miles.'),
-- SUP-013: Air Products (USA, Pennsylvania) → Gases
('SUP-013','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Air Products — Allentown PA to OH. Hazmat compressed gas. Dedicated tanker route.'),
('SUP-013','PLT-OH2','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Air Products to OH2 — same depot.'),
('SUP-013','PLT-AZ1','USA','N/A',0.0,'TRUCK',3,0.0,1.0,'Air Products — supplied from Phoenix AZ regional depot. Same-state delivery.'),
-- SUP-014: Linde Gases (USA, Connecticut) → Gases
('SUP-014','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Linde — Danbury CT distribution center. Delivered via regional OH depot.'),
('SUP-014','PLT-OH2','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Linde to OH2.'),
('SUP-014','PLT-AZ1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Linde — Phoenix AZ depot to Mesa.'),
-- SUP-015: Borealis (Austria) → Backsheet/Encapsulation
('SUP-015','PLT-OH1','Austria','Port Newark NJ',4.0,'OCEAN',30,4.2,3.8,'Borealis Vienna via Atlantic. Polymer rolls on container vessel. 4-week transit + truck to OH.'),
('SUP-015','PLT-AZ1','Austria','Port of Long Beach',4.0,'OCEAN',42,4.2,3.8,'Borealis via Suez → Pacific. 6-week ocean transit. Highest geopolitical risk route (Suez chokepoint).'),
-- SUP-016: Eastman Chemical (USA, Tennessee) → Encapsulants
('SUP-016','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Eastman — Kingsport TN to Perrysburg OH. 500 miles.'),
('SUP-016','PLT-AZ1','USA','N/A',0.0,'TRUCK',3,0.0,1.0,'Eastman TN to Mesa AZ. 1,600 miles.'),
-- SUP-017: II-VI Incorporated (USA, Pennsylvania) → Equipment Consumables
('SUP-017','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'II-VI — Saxonburg PA to Perrysburg OH. 280 miles. White-glove freight for precision optics. Climate-controlled.'),
('SUP-017','PLT-OH2','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'II-VI to OH2.'),
('SUP-017','PLT-AZ1','USA','N/A',0.0,'TRUCK',5,0.0,1.0,'II-VI PA to Mesa AZ. 2,200 miles. Air-ride suspension required for optics.'),
-- SUP-018: Sumitomo Electric (USA, Ohio) → Electronics
('SUP-018','PLT-OH1','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Sumitomo Electric — Columbus OH to Perrysburg OH. 130 miles, same-day.'),
('SUP-018','PLT-OH2','USA','N/A',0.0,'TRUCK',1,0.0,1.0,'Sumitomo to OH2.'),
-- SUP-019: Brady Corporation (USA, Wisconsin) → Labels/Hardware
('SUP-019','PLT-OH1','USA','N/A',0.0,'TRUCK',2,0.0,1.0,'Brady Corp — Milwaukee WI to Perrysburg OH. 350 miles.'),
('SUP-019','PLT-AZ1','USA','N/A',0.0,'TRUCK',3,0.0,1.0,'Brady WI to Mesa AZ. 1,700 miles.'),
-- SUP-020: Nitto Denko (Japan) → Tapes/Thermal
('SUP-020','PLT-OH1','Japan','Port of Long Beach',4.5,'OCEAN',33,2.5,3.2,'Nitto Denko Osaka via Pacific → Long Beach → rail to OH. 5-week total.'),
('SUP-020','PLT-OH2','Japan','Port of Long Beach',4.5,'OCEAN',33,2.5,3.2,'Nitto Denko to OH2 — same route.'),
('SUP-020','PLT-AZ1','Japan','Port of Long Beach',4.0,'OCEAN',30,2.5,3.2,'Nitto Denko — shorter inland leg to AZ.');

-- ============================================================
-- INDUSTRY_BENCHMARK_DIM — Comprehensive CdTe Manufacturing KPIs
-- ============================================================

TRUNCATE TABLE IF EXISTS INDUSTRY_BENCHMARK_DIM;

INSERT INTO INDUSTRY_BENCHMARK_DIM (metric_name, material_category, benchmark_value, unit, source, effective_date) VALUES
-- Lead time benchmarks by category
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
-- Days forward coverage targets
('target_days_forward_coverage','Glass',45.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Semiconductor',75.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Frame',30.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Electronics',30.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Chemicals',25.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Equipment Consumable',90.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Backsheet',40.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_days_forward_coverage','Packaging',20.0,'days','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
-- Supplier performance benchmarks
('supplier_otd_benchmark',NULL,0.94,'fraction','ISM Manufacturing Report 2024','2024-09-01'),
('supplier_otd_top_quartile',NULL,0.97,'fraction','ISM Manufacturing Report 2024','2024-09-01'),
('supplier_quality_benchmark',NULL,0.992,'fraction','ISM Manufacturing Report 2024','2024-09-01'),
('supplier_quality_top_quartile',NULL,0.998,'fraction','ISM Manufacturing Report 2024','2024-09-01'),
-- Operational benchmarks
('target_inventory_turns',NULL,8.5,'turns/year','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('target_inventory_turns_top_quartile',NULL,11.0,'turns/year','Wood Mackenzie Solar Manufacturing Benchmarks 2024','2024-03-01'),
('expediting_cost_ratio',NULL,0.03,'fraction of total procurement','APICS Supply Chain Benchmarks 2024','2024-01-01'),
('expediting_cost_ratio_best_in_class',NULL,0.015,'fraction of total procurement','APICS Supply Chain Benchmarks 2024','2024-01-01'),
('manufacturing_schedule_adherence',NULL,0.92,'fraction','SEMI Solar Manufacturing KPIs 2024','2024-06-01'),
('manufacturing_schedule_adherence_top',NULL,0.96,'fraction','SEMI Solar Manufacturing KPIs 2024','2024-06-01'),
('demand_forecast_mape',NULL,8.5,'percent','IBF Forecasting Benchmarks 2024','2024-01-01'),
('demand_forecast_mape_best',NULL,5.0,'percent','IBF Forecasting Benchmarks 2024','2024-01-01'),
-- CdTe-specific production benchmarks
('cdte_deposition_yield',NULL,0.965,'fraction','First Solar 10-K FY2024 (public)','2024-12-31'),
('module_line_throughput',NULL,1200.0,'modules/line/day','SEMI PV Manufacturing Report 2024','2024-06-01'),
('single_source_material_pct',NULL,0.12,'fraction of BOM','Gartner Supply Chain Risk Benchmarks 2024','2024-04-01'),
('single_source_material_pct_risk_threshold',NULL,0.08,'fraction of BOM','Gartner Supply Chain Risk Benchmarks 2024','2024-04-01'),
('avg_supplier_risk_score',NULL,3.0,'1-10 scale','Gartner Supply Chain Risk Benchmarks 2024','2024-04-01'),
('freight_cost_pct_of_cogs',NULL,0.045,'fraction','CSCMP State of Logistics 2024','2024-06-01'),
('inter_plant_transfer_utilization',NULL,0.15,'fraction of total material flow','Internal benchmark','2025-01-01');

-- ============================================================
-- SUPPLIER_EVENT_LOG — 6 months of disruption history
-- Rich unstructured text for Cortex Search
-- ============================================================

TRUNCATE TABLE IF EXISTS SUPPLIER_EVENT_LOG;

INSERT INTO SUPPLIER_EVENT_LOG (event_date, supplier_id, event_type, severity, description, resolution_date, impact_materials) VALUES
-- January 2025
('2025-01-08','SUP-002','PORT_DELAY','MEDIUM','NSG Pilkington glass shipment held at Port of Long Beach — container inspection triggered by random customs audit. Expected 3-day delay. 2 containers (4,000 panels) affected.','2025-01-11','MAT-001, MAT-002'),
('2025-01-15','SUP-001','PORT_DELAY','MEDIUM','AGC Inc vessel (NYK Nebula) delayed 8 days at Long Beach due to West Coast labor action (ILWU work slowdown). 6 containers of glass panels for Ohio plants affected. Alternative berth at Port of Oakland being evaluated.','2025-01-23','MAT-001, MAT-002, MAT-003'),
('2025-01-22','SUP-004','QUALITY_HOLD','HIGH','5N Plus CdTe compound batch 5NP-CdTe-2025-0122 failed incoming purity specification. Required: 99.995% Cd, actual: 99.991%. Trace selenium contamination detected. Batch rejected, replacement lot in production with priority allocation. Expected 14-day delay.','2025-02-05','MAT-005, MAT-006'),
('2025-01-28','SUP-013','CAPACITY_CHANGE','LOW','Air Products notified that Perrysburg OH nitrogen delivery schedule changing from 3x/week to daily deliveries starting February 1 due to increased demand from adjacent industrial customers. No supply risk — capacity increase.','2025-02-01','MAT-036'),
-- February 2025
('2025-02-03','SUP-015','FORCE_MAJEURE','HIGH','Borealis Vienna plant experienced catastrophic gear failure in backsheet extrusion line #3. Line produces 60% of First Solar TPO allocation. Estimated 3-week repair. Emergency procurement from Dow (SUP-012) initiated. Price premium of 12% for spot volume. Production at Mesa at risk if not resolved by Feb 24.','2025-02-24','MAT-038, MAT-039'),
('2025-02-10','SUP-006','PORT_DELAY','LOW','Umicore semiconductor material shipment from Belgium — routine customs inspection at Port Newark for cadmium-containing materials under EPA TSCA Section 12(b) export notification. 3-day administrative delay. Standard occurrence for this material class.','2025-02-13','MAT-005, MAT-007, MAT-009'),
('2025-02-14','SUP-012','CAPACITY_CHANGE','LOW','Dow Chemical confirmed ability to supply 40% of Borealis TPO backsheet allocation from Midland MI facility at 12% spot premium. Temporary dual-source arrangement approved through March 15.','2025-03-15','MAT-038, MAT-039'),
('2025-02-18','SUP-017','CAPACITY_CHANGE','MEDIUM','II-VI Incorporated announced 15% capacity reduction on magnetron sputtering targets and laser optics due to unplanned maintenance on electron beam melting furnace. Lead times extended from 70 to 84 days through end of March. All First Solar plants affected.','2025-03-15','MAT-033, MAT-034, MAT-043, MAT-044'),
('2025-02-22','SUP-005','PRICE_INCREASE','LOW','Materion notified 4% price increase on ITO targets effective March 1, citing indium spot price increase (+18% YTD). Contractual escalation clause triggered. No supply impact.','2025-03-01','MAT-007, MAT-008, MAT-010'),
-- March 2025
('2025-03-01','SUP-011','PRICE_INCREASE','MEDIUM','Henkel notified 8% price increase on CdCl2 activation solution effective April 1, citing cadmium chloride raw material cost escalation (+22% since Jan). Single-source material — no alternative supplier. Annual spend impact estimated at $180K.','2025-04-01','MAT-023'),
('2025-03-05','SUP-020','PORT_DELAY','LOW','Nitto Denko edge seal tape shipment delayed at Long Beach — 4-day backlog from Pineapple Express weather system. Low criticality material with 45+ days coverage. No production impact expected.','2025-03-09','MAT-040, MAT-041, MAT-042'),
('2025-03-10','SUP-007','QUALITY_HOLD','LOW','Hydro Extrusions lot HYD-2025-0310: minor surface anodization inconsistency on 200 frames (out of 5,000). Cosmetic only — no structural concern. Lot accepted with deviation. Root cause: anodization bath concentration drift.','2025-03-12','MAT-011, MAT-012'),
('2025-03-12','SUP-003','QUALITY_HOLD','MEDIUM','Guardian Glass lot GRD-2025-0312 placed on quality hold — micro-fracture detected in 2% of low-iron glass panels during incoming EL inspection at Ohio Plant 1. 3,000 panels in lot. Root cause under investigation. Fracture pattern consistent with thermal stress during annealing. Vendor notified.','2025-03-18','MAT-001, MAT-003'),
('2025-03-15','SUP-017','CAPACITY_CHANGE','LOW','II-VI furnace maintenance completed ahead of schedule. Capacity restored to 100%. Lead times returning to standard 70 days. Backlog of orders placed during reduced capacity period being cleared — expect 2-week surge in deliveries.','2025-03-30','MAT-033, MAT-034, MAT-043, MAT-044'),
('2025-03-18','SUP-015','CAPACITY_CHANGE','LOW','Borealis Vienna extrusion line #3 repair completed. Full production capacity restored. Dow spot allocation being wound down. No further supply concern for TPO backsheet.','2025-03-25','MAT-038, MAT-039'),
('2025-03-20','SUP-009','CAPACITY_CHANGE','LOW','TE Connectivity announced 10% capacity increase for MC4 connector and junction box production line at Berwyn PA facility. New automated assembly cell operational. Lead times expected to improve by 3 days starting April 1.','2025-04-15','MAT-016, MAT-017, MAT-019'),
('2025-03-22','SUP-006','PORT_DELAY','MEDIUM','Umicore zinc stannate buffer shipment delayed — vessel (Maersk Eindhoven) diverted from Suez Canal route due to Houthi maritime threat. Re-routing via Cape of Good Hope adds 12 days transit. Single-source material.','2025-04-08','MAT-009'),
('2025-03-25','SUP-004','FORCE_MAJEURE','HIGH','5N Plus Montreal facility experienced HVAC failure in ISO Class 5 clean room. CdTe production line suspended for 5 days pending environmental re-certification. All cadmium compound production affected. Umicore (SUP-006) contacted for emergency allocation.','2025-03-30','MAT-005, MAT-006'),
('2025-03-28','SUP-008','QUALITY_HOLD','LOW','Arconic aluminum frame lot — dimensional variance on 150 short rails (0.3mm over spec). Accepted with production waiver — within module frame tolerance. Corrective action issued to supplier.','2025-03-29','MAT-012, MAT-014'),
('2025-03-30','SUP-001','PORT_DELAY','LOW','AGC shipment delayed 2 days — vessel berth congestion at Long Beach (post-weather backlog clearing). Minimal impact. Glass inventory at 38 days coverage.','2025-04-01','MAT-001, MAT-002');

-- ============================================================
-- MATERIAL_LOT_TRACE — Comprehensive traceability chains
-- 8 full chains covering receipt → consumption → production → shipment
-- ============================================================

TRUNCATE TABLE IF EXISTS MATERIAL_LOT_TRACE;

INSERT INTO MATERIAL_LOT_TRACE (lot_id, event_type, event_date, plant_id, material_id, po_id, schedule_id, parent_lot_id, quantity, description) VALUES
-- ── Chain 1: CdTe from 5N Plus → Ohio Plant 1 → Series 6 production → NextEra shipment
('LOT-CdTe-5NP-0115','RECEIVED','2025-01-15','PLT-OH1','MAT-005','PO-000042',NULL,NULL,12.500,'5N Plus CdTe compound lot received at Ohio Plant 1. Certificate of Analysis verified: purity 99.997%, particle size D50=45μm. Stored in climate-controlled hazmat vault.'),
('LOT-CdS-5NP-0115','RECEIVED','2025-01-15','PLT-OH1','MAT-006','PO-000043',NULL,NULL,4.200,'5N Plus CdS buffer material received alongside CdTe. CoA: purity 99.99%.'),
('LOT-CdTe-5NP-0115','CONSUMED','2025-01-20','PLT-OH1','MAT-005',NULL,3,NULL,4.200,'Consumed in close-space sublimation CdTe deposition — Series 6 production week 3, line A. Deposition rate: 4.2 μm/min.'),
('LOT-CdS-5NP-0115','CONSUMED','2025-01-20','PLT-OH1','MAT-006',NULL,3,NULL,1.400,'CdS buffer deposited via chemical bath deposition — Series 6 week 3.'),
('LOT-GLASS-AGC-0113','RECEIVED','2025-01-13','PLT-OH1','MAT-001','PO-000038',NULL,NULL,5000.000,'AGC low-iron tempered glass panels received. Visual + EL inspection passed. 5,000 panels stored in glass warehouse.'),
('LOT-GLASS-AGC-0113','CONSUMED','2025-01-20','PLT-OH1','MAT-001',NULL,3,NULL,2450.000,'Front glass consumed in lamination line — Series 6 week 3.'),
('LOT-MOD-OH1-S6-WK03','PRODUCED','2025-01-24','PLT-OH1',NULL,NULL,3,'LOT-CdTe-5NP-0115',2450.000,'Series 6 modules produced week 3 — 2,450 units at Ohio Plant 1. Yield: 96.8%. EL inspection: 99.2% pass rate.'),
('LOT-MOD-OH1-S6-WK03','SHIPPED','2025-01-28','PLT-OH1',NULL,NULL,NULL,'LOT-MOD-OH1-S6-WK03',1200.000,'Shipped 1,200 Series 6 modules to NextEra Energy — Sunshine Solar Project, Manatee County FL. Carrier: XPO Logistics.'),
('LOT-MOD-OH1-S6-WK03','SHIPPED','2025-01-30','PLT-OH1',NULL,NULL,NULL,'LOT-MOD-OH1-S6-WK03',1250.000,'Shipped remaining 1,250 modules to Invenergy — Prairie Wind Solar, McLean County IL.'),

-- ── Chain 2: Glass from Guardian → Ohio Plant 2 → Series 6
('LOT-GLASS-GRD-0203','RECEIVED','2025-02-03','PLT-OH2','MAT-001','PO-000089',NULL,NULL,4200.000,'Guardian Glass low-iron panels received at Ohio Plant 2. Domestic shipment, same-day delivery from Auburn Hills MI.'),
('LOT-JBOX-TE-0201','RECEIVED','2025-02-01','PLT-OH2','MAT-016','PO-000085',NULL,NULL,6000.000,'TE Connectivity junction boxes received. QC sample: all 20 units passed hi-pot test at 3kV.'),
('LOT-GLASS-GRD-0203','CONSUMED','2025-02-07','PLT-OH2','MAT-001',NULL,6,NULL,2100.000,'Consumed in Series 6 production week 6 at OH2.'),
('LOT-JBOX-TE-0201','CONSUMED','2025-02-07','PLT-OH2','MAT-016',NULL,6,'LOT-JBOX-TE-0201',2100.000,'Junction boxes consumed in final assembly — Series 6 week 6.'),
('LOT-MOD-OH2-S6-WK06','PRODUCED','2025-02-10','PLT-OH2',NULL,NULL,6,'LOT-GLASS-GRD-0203',2100.000,'Series 6 modules produced week 6 — 2,100 units at Ohio Plant 2. Yield: 97.1%.'),

-- ── Chain 3: AGC Glass + Umicore ITO → Arizona → Series 7 production
('LOT-GLASS-AGC-0201','RECEIVED','2025-02-01','PLT-AZ1','MAT-001','PO-000128',NULL,NULL,5000.000,'AGC low-iron glass lot received at Mesa AZ. Ocean freight from Japan (NYK Line). 32-day transit. Visual inspection passed.'),
('LOT-ITO-UMC-0125','RECEIVED','2025-01-25','PLT-AZ1','MAT-008','PO-000120',NULL,NULL,8.500,'Umicore ITO sputtering targets received at Mesa. 38-day transit from Belgium via Long Beach. Purity verified: 99.99%.'),
('LOT-GLASS-AGC-0201','CONSUMED','2025-02-05','PLT-AZ1','MAT-001',NULL,8,NULL,2200.000,'Front glass consumed in Series 7 lamination — week 5 at Mesa.'),
('LOT-ITO-UMC-0125','CONSUMED','2025-02-05','PLT-AZ1','MAT-008',NULL,8,NULL,2.800,'ITO targets loaded into magnetron sputtering chamber for TCO deposition — Series 7 week 5.'),
('LOT-MOD-AZ1-S7-WK05','PRODUCED','2025-02-07','PLT-AZ1',NULL,NULL,8,'LOT-GLASS-AGC-0201',2200.000,'Series 7 (500W) modules produced week 5 — 2,200 units at Mesa Arizona. Yield: 95.9%. Larger format = slightly lower yield.'),
('LOT-MOD-AZ1-S7-WK05','SHIPPED','2025-02-12','PLT-AZ1',NULL,NULL,NULL,'LOT-MOD-AZ1-S7-WK05',2200.000,'Full lot shipped to Lightsource BP — Clearview Solar Project, Cochise County AZ.'),

-- ── Chain 4: Guardian Glass quality issue → trace-back
('LOT-GLASS-GRD-0312','RECEIVED','2025-03-12','PLT-OH1','MAT-001','PO-000201',NULL,NULL,3000.000,'Guardian Glass lot GRD-2025-0312 received — QUALITY HOLD. EL inspection detected micro-fracture pattern in 2% of panels (60 units). Lot quarantined pending investigation.'),
('LOT-GLASS-GRD-0312-A','RECEIVED','2025-03-18','PLT-OH1','MAT-001','PO-000201',NULL,'LOT-GLASS-GRD-0312',2940.000,'Guardian Glass lot released after 100% inspection and sorting. 60 fractured panels rejected (returned to supplier), 2,940 panels accepted into inventory.'),
('LOT-GLASS-GRD-0312-A','CONSUMED','2025-03-22','PLT-OH1','MAT-001',NULL,12,NULL,2450.000,'Accepted panels consumed in Series 6 production week 12.'),
('LOT-MOD-OH1-S6-WK12','PRODUCED','2025-03-25','PLT-OH1',NULL,NULL,12,'LOT-GLASS-GRD-0312-A',2450.000,'Series 6 production week 12 — 2,450 modules. Yield: 97.0%. No fracture-related issues in finished modules.'),

-- ── Chain 5: Borealis backsheet (during force majeure) → Dow emergency supply
('LOT-TPO-BOR-0110','RECEIVED','2025-01-10','PLT-OH1','MAT-038','PO-000025',NULL,NULL,45.000,'Borealis TPO backsheet rolls received (pre-force-majeure shipment). Normal quality. 45 rolls = ~3 weeks supply.'),
('LOT-TPO-BOR-0110','CONSUMED','2025-02-15','PLT-OH1','MAT-038',NULL,7,NULL,15.000,'TPO backsheet consumed in lamination — Series 6 week 7. Last Borealis stock before emergency Dow supply.'),
('LOT-TPO-DOW-0220','RECEIVED','2025-02-20','PLT-OH1','MAT-038','PO-000178',NULL,NULL,30.000,'Dow Chemical emergency TPO backsheet supply received. Spot procurement during Borealis force majeure. 12% price premium. Material qualified under deviation waiver.'),
('LOT-TPO-DOW-0220','CONSUMED','2025-02-22','PLT-OH1','MAT-038',NULL,8,NULL,15.000,'Dow TPO consumed in Series 6 week 8. No quality difference observed vs Borealis material.'),

-- ── Chain 6: CdTe from 5N Plus post-force-majeure → Ohio production continuity
('LOT-CdTe-5NP-0330','RECEIVED','2025-03-30','PLT-OH1','MAT-005','PO-000215',NULL,NULL,15.000,'5N Plus CdTe received post-HVAC restoration. Clean room re-certified March 29. Rush production lot. CoA: 99.996% purity.'),
('LOT-CdTe-UMC-0325','RECEIVED','2025-03-25','PLT-OH1','MAT-005','PO-000212',NULL,NULL,8.000,'Umicore emergency CdTe allocation received during 5N Plus force majeure. Diverted from European customer stock. 28-day ocean transit.'),
('LOT-CdTe-UMC-0325','CONSUMED','2025-03-27','PLT-OH1','MAT-005',NULL,13,NULL,4.500,'Umicore CdTe consumed in Series 6 week 13 to maintain production continuity during 5N Plus outage.'),

-- ── Chain 7: II-VI laser lens → Arizona (long lead time critical path)
('LOT-LENS-IIV-0105','RECEIVED','2025-01-05','PLT-AZ1','MAT-043','PO-000015',NULL,NULL,4.000,'II-VI laser scribing lenses received at Mesa. 4 units. 70-day lead time from order. White-glove delivery, climate-controlled.'),
('LOT-LENS-IIV-0105','CONSUMED','2025-02-15','PLT-AZ1','MAT-043',NULL,NULL,NULL,1.000,'Laser lens installed in P3 scribing tool during scheduled maintenance. Previous lens: 8,000 hours runtime.'),
('LOT-LENS-IIV-0320','RECEIVED','2025-03-20','PLT-AZ1','MAT-043','PO-000195',NULL,NULL,2.000,'II-VI laser lenses received — ordered during capacity reduction period. 84-day lead time (14 days above normal). 2 units for safety stock buffer.'),

-- ── Chain 8: Inter-plant transfer trace (CdTe OH1 → AZ1)
('LOT-CdTe-XFER-0305','RECEIVED','2025-03-01','PLT-OH1','MAT-005','PO-000190',NULL,NULL,10.000,'5N Plus CdTe received at OH1 — partial lot designated for transfer to Mesa.'),
('LOT-CdTe-XFER-0305','SHIPPED','2025-03-05','PLT-OH1','MAT-005',NULL,NULL,'LOT-CdTe-XFER-0305',5.000,'5 kg CdTe transferred from OH1 to AZ1 via inter-plant transfer TXF-00025. Hazmat carrier, 4-day transit.'),
('LOT-CdTe-XFER-0305-AZ','RECEIVED','2025-03-09','PLT-AZ1','MAT-005',NULL,NULL,'LOT-CdTe-XFER-0305',5.000,'CdTe transfer received at Mesa from OH1. Integrity verified. Added to deposition material queue.');
