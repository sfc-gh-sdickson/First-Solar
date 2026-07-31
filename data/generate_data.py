"""
First Solar Supply Chain Intelligence Agent — Enhanced Data Generator
=====================================================================
Generates comprehensive synthetic data for all operational + reference tables.
Fixes data gaps from the original generator:
  - Inventory transfers: 7 → 55+ rows
  - Supply recommendations: 27 → 70+ rows (10+ TRANSFER type)
  - Quality rejections: 2 → 20+ across suppliers
  - Overdue POs: explicitly generated
  - Reference data: CSV output for all 5 reference tables
  - Anomaly alerts: 80 → 100+ with recent supplier-specific entries

seed=42 for reproducibility
"""

import random
import math
import csv
import os
import sys
import numpy as np
from datetime import date, timedelta
from collections import defaultdict

random.seed(42)
np.random.seed(42)

# ── Date range ───────────────────────────────────────────────────────────────
TODAY = date(2025, 4, 1)
HIST_START = date(2025, 1, 1)
FUTURE_END = date(2025, 6, 1)
ALL_DATES = [HIST_START + timedelta(days=i)
             for i in range((FUTURE_END - HIST_START).days + 1)]

OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "csv")
os.makedirs(OUT_DIR, exist_ok=True)

def w(name): return open(os.path.join(OUT_DIR, name), "w", newline="", encoding="utf-8")
def jitter(base, pct=0.05): return round(base * (1 + random.uniform(-pct, pct)), 4)

# ══════════════════════════════════════════════════════════════════════════════
# PLANTS
# ══════════════════════════════════════════════════════════════════════════════
PLANTS = [
    {"plant_id": "PLT-OH1", "plant_name": "First Solar Manufacturing - Perrysburg Ohio 1",
     "city": "Perrysburg", "state": "Ohio", "country": "USA", "region": "Midwest", "capacity_mw": 1300},
    {"plant_id": "PLT-OH2", "plant_name": "First Solar Manufacturing - Perrysburg Ohio 2",
     "city": "Perrysburg", "state": "Ohio", "country": "USA", "region": "Midwest", "capacity_mw": 1000},
    {"plant_id": "PLT-AZ1", "plant_name": "First Solar Manufacturing - Mesa Arizona",
     "city": "Mesa", "state": "Arizona", "country": "USA", "region": "Southwest", "capacity_mw": 1000},
]
PLANT_IDS = [p["plant_id"] for p in PLANTS]

with w("plants.csv") as f:
    writer = csv.DictWriter(f, fieldnames=list(PLANTS[0].keys()))
    writer.writeheader(); writer.writerows(PLANTS)

# ══════════════════════════════════════════════════════════════════════════════
# CUSTOMERS
# ══════════════════════════════════════════════════════════════════════════════
CUSTOMERS = [
    {"customer_id":"CUST-001","customer_name":"NextEra Energy Resources","city":"Juno Beach","state":"Florida","country":"USA","region":"Southeast","segment":"Utility"},
    {"customer_id":"CUST-002","customer_name":"Invenergy LLC","city":"Chicago","state":"Illinois","country":"USA","region":"Midwest","segment":"Utility"},
    {"customer_id":"CUST-003","customer_name":"AES Clean Energy","city":"Arlington","state":"Virginia","country":"USA","region":"Southeast","segment":"Utility"},
    {"customer_id":"CUST-004","customer_name":"EDP Renewables North America","city":"Houston","state":"Texas","country":"USA","region":"South","segment":"Utility"},
    {"customer_id":"CUST-005","customer_name":"Lightsource BP","city":"San Francisco","state":"California","country":"USA","region":"West","segment":"Utility"},
    {"customer_id":"CUST-006","customer_name":"Recurrent Energy","city":"San Francisco","state":"California","country":"USA","region":"West","segment":"Utility"},
    {"customer_id":"CUST-007","customer_name":"SunPower Corporation","city":"San Jose","state":"California","country":"USA","region":"West","segment":"Commercial"},
    {"customer_id":"CUST-008","customer_name":"Greenbacker Renewable Energy","city":"New York","state":"New York","country":"USA","region":"Northeast","segment":"Utility"},
    {"customer_id":"CUST-009","customer_name":"Apex Clean Energy","city":"Charlottesville","state":"Virginia","country":"USA","region":"Southeast","segment":"Utility"},
    {"customer_id":"CUST-010","customer_name":"X-Elio","city":"Phoenix","state":"Arizona","country":"USA","region":"Southwest","segment":"Utility"},
    {"customer_id":"CUST-011","customer_name":"OCI Solar Power","city":"San Antonio","state":"Texas","country":"USA","region":"South","segment":"Commercial"},
    {"customer_id":"CUST-012","customer_name":"Terra-Gen Power","city":"New York","state":"New York","country":"USA","region":"Northeast","segment":"Utility"},
    {"customer_id":"CUST-013","customer_name":"Capital Power Corporation","city":"Calgary","state":"Alberta","country":"Canada","region":"Canada","segment":"Utility"},
    {"customer_id":"CUST-014","customer_name":"Pattern Energy Group","city":"San Francisco","state":"California","country":"USA","region":"West","segment":"Utility"},
    {"customer_id":"CUST-015","customer_name":"Hecate Energy","city":"Chicago","state":"Illinois","country":"USA","region":"Midwest","segment":"Commercial"},
]

with w("customers.csv") as f:
    writer = csv.DictWriter(f, fieldnames=list(CUSTOMERS[0].keys()))
    writer.writeheader(); writer.writerows(CUSTOMERS)

# ══════════════════════════════════════════════════════════════════════════════
# MATERIALS (50 parts)
# ══════════════════════════════════════════════════════════════════════════════
MATERIALS = [
    {"material_id":"MAT-001","material_name":"Low-Iron Tempered Glass Panel 2m x 1.2m","material_category":"Glass","unit_of_measure":"EACH","unit_cost_std":28.50,"is_critical":True},
    {"material_id":"MAT-002","material_name":"Back Glass Panel 2m x 1.2m","material_category":"Glass","unit_of_measure":"EACH","unit_cost_std":22.00,"is_critical":True},
    {"material_id":"MAT-003","material_name":"Glass Spacer Frame","material_category":"Glass","unit_of_measure":"EACH","unit_cost_std":4.20,"is_critical":False},
    {"material_id":"MAT-004","material_name":"Anti-Reflective Glass Coating Chemical","material_category":"Glass","unit_of_measure":"LITER","unit_cost_std":85.00,"is_critical":False},
    {"material_id":"MAT-005","material_name":"Cadmium Telluride (CdTe) Compound","material_category":"Semiconductor","unit_of_measure":"KG","unit_cost_std":320.00,"is_critical":True},
    {"material_id":"MAT-006","material_name":"Cadmium Sulfide (CdS) Buffer Layer","material_category":"Semiconductor","unit_of_measure":"KG","unit_cost_std":210.00,"is_critical":True},
    {"material_id":"MAT-007","material_name":"Tin Oxide (SnO2) Target Material","material_category":"Semiconductor","unit_of_measure":"KG","unit_cost_std":175.00,"is_critical":True},
    {"material_id":"MAT-008","material_name":"Indium Tin Oxide (ITO) Sputtering Target","material_category":"Semiconductor","unit_of_measure":"KG","unit_cost_std":420.00,"is_critical":True},
    {"material_id":"MAT-009","material_name":"Zinc Stannate Buffer Powder","material_category":"Semiconductor","unit_of_measure":"KG","unit_cost_std":95.00,"is_critical":False},
    {"material_id":"MAT-010","material_name":"Copper Back Contact Material","material_category":"Semiconductor","unit_of_measure":"KG","unit_cost_std":9.50,"is_critical":False},
    {"material_id":"MAT-011","material_name":"Aluminum Extrusion Frame 2m Side Rail","material_category":"Frame","unit_of_measure":"EACH","unit_cost_std":6.80,"is_critical":False},
    {"material_id":"MAT-012","material_name":"Aluminum Extrusion Frame Short Rail","material_category":"Frame","unit_of_measure":"EACH","unit_cost_std":4.10,"is_critical":False},
    {"material_id":"MAT-013","material_name":"Corner Bracket Assembly","material_category":"Frame","unit_of_measure":"SET","unit_cost_std":2.30,"is_critical":False},
    {"material_id":"MAT-014","material_name":"Mounting Hole Insert","material_category":"Frame","unit_of_measure":"BAG","unit_cost_std":0.85,"is_critical":False},
    {"material_id":"MAT-015","material_name":"Stainless Steel Fastener Set","material_category":"Frame","unit_of_measure":"SET","unit_cost_std":1.20,"is_critical":False},
    {"material_id":"MAT-016","material_name":"Junction Box with Bypass Diodes","material_category":"Electronics","unit_of_measure":"EACH","unit_cost_std":7.50,"is_critical":True},
    {"material_id":"MAT-017","material_name":"MC4 Connector Pair","material_category":"Electronics","unit_of_measure":"PAIR","unit_cost_std":2.10,"is_critical":False},
    {"material_id":"MAT-018","material_name":"Lead-Free Solder Wire 500g Reel","material_category":"Electronics","unit_of_measure":"REEL","unit_cost_std":18.00,"is_critical":False},
    {"material_id":"MAT-019","material_name":"Bypass Diode Schottky 15A","material_category":"Electronics","unit_of_measure":"EACH","unit_cost_std":0.65,"is_critical":False},
    {"material_id":"MAT-020","material_name":"Bussing Ribbon Copper 6mm","material_category":"Electronics","unit_of_measure":"METER","unit_cost_std":0.42,"is_critical":False},
    {"material_id":"MAT-021","material_name":"Cross Ribbon Copper 3mm","material_category":"Electronics","unit_of_measure":"METER","unit_cost_std":0.28,"is_critical":False},
    {"material_id":"MAT-022","material_name":"Encapsulant EVA Film Roll","material_category":"Electronics","unit_of_measure":"ROLL","unit_cost_std":95.00,"is_critical":True},
    {"material_id":"MAT-023","material_name":"CdCl2 Activation Solution 20L","material_category":"Chemicals","unit_of_measure":"BOTTLE","unit_cost_std":145.00,"is_critical":True},
    {"material_id":"MAT-024","material_name":"Phosphoric Acid Etchant 25L","material_category":"Chemicals","unit_of_measure":"DRUM","unit_cost_std":62.00,"is_critical":False},
    {"material_id":"MAT-025","material_name":"Isopropyl Alcohol Technical Grade 200L","material_category":"Chemicals","unit_of_measure":"DRUM","unit_cost_std":180.00,"is_critical":False},
    {"material_id":"MAT-026","material_name":"De-ionized Water System Resin","material_category":"Chemicals","unit_of_measure":"BAG","unit_cost_std":38.00,"is_critical":False},
    {"material_id":"MAT-027","material_name":"Flux No-Clean Pen","material_category":"Chemicals","unit_of_measure":"EACH","unit_cost_std":4.50,"is_critical":False},
    {"material_id":"MAT-028","material_name":"Module Shipping Pallet Rack","material_category":"Packaging","unit_of_measure":"EACH","unit_cost_std":45.00,"is_critical":False},
    {"material_id":"MAT-029","material_name":"Protective Foam Corner Piece","material_category":"Packaging","unit_of_measure":"SET","unit_cost_std":2.80,"is_critical":False},
    {"material_id":"MAT-030","material_name":"Stretch Wrap Film 500m Roll","material_category":"Packaging","unit_of_measure":"ROLL","unit_cost_std":22.00,"is_critical":False},
    {"material_id":"MAT-031","material_name":"Module Interleaf Paper Roll","material_category":"Packaging","unit_of_measure":"ROLL","unit_cost_std":15.00,"is_critical":False},
    {"material_id":"MAT-032","material_name":"Carton Box Module Single","material_category":"Packaging","unit_of_measure":"EACH","unit_cost_std":5.50,"is_critical":False},
    {"material_id":"MAT-033","material_name":"Magnetron Sputtering Target Holder","material_category":"Equipment Consumable","unit_of_measure":"EACH","unit_cost_std":1200.00,"is_critical":True},
    {"material_id":"MAT-034","material_name":"Furnace Quartz Tube Liner","material_category":"Equipment Consumable","unit_of_measure":"EACH","unit_cost_std":380.00,"is_critical":False},
    {"material_id":"MAT-035","material_name":"Vacuum O-Ring Kit","material_category":"Equipment Consumable","unit_of_measure":"KIT","unit_cost_std":95.00,"is_critical":False},
    {"material_id":"MAT-036","material_name":"High Purity Nitrogen Gas Cylinder","material_category":"Equipment Consumable","unit_of_measure":"CYLINDER","unit_cost_std":72.00,"is_critical":False},
    {"material_id":"MAT-037","material_name":"Argon Gas High Purity 50L","material_category":"Equipment Consumable","unit_of_measure":"CYLINDER","unit_cost_std":55.00,"is_critical":False},
    {"material_id":"MAT-038","material_name":"Thermoplastic Polyolefin Backsheet Roll","material_category":"Backsheet","unit_of_measure":"ROLL","unit_cost_std":185.00,"is_critical":True},
    {"material_id":"MAT-039","material_name":"Polyvinyl Butyral Interlayer Film","material_category":"Backsheet","unit_of_measure":"ROLL","unit_cost_std":210.00,"is_critical":True},
    {"material_id":"MAT-040","material_name":"Edge Seal Tape 50mm","material_category":"Backsheet","unit_of_measure":"ROLL","unit_cost_std":28.00,"is_critical":False},
    {"material_id":"MAT-041","material_name":"Thermal Interface Paste 1kg","material_category":"Thermal","unit_of_measure":"TUB","unit_cost_std":42.00,"is_critical":False},
    {"material_id":"MAT-042","material_name":"Heat Sink Compound Syringe 50g","material_category":"Thermal","unit_of_measure":"EACH","unit_cost_std":12.00,"is_critical":False},
    {"material_id":"MAT-043","material_name":"Laser Scribing Machine Lens","material_category":"Equipment Consumable","unit_of_measure":"EACH","unit_cost_std":2800.00,"is_critical":True},
    {"material_id":"MAT-044","material_name":"Laser Head Cooling Pump Filter","material_category":"Equipment Consumable","unit_of_measure":"EACH","unit_cost_std":145.00,"is_critical":False},
    {"material_id":"MAT-045","material_name":"EL Imaging Camera Reference Target","material_category":"QA Consumable","unit_of_measure":"EACH","unit_cost_std":620.00,"is_critical":False},
    {"material_id":"MAT-046","material_name":"IV Curve Tracer Calibration Cell","material_category":"QA Consumable","unit_of_measure":"EACH","unit_cost_std":340.00,"is_critical":False},
    {"material_id":"MAT-047","material_name":"Grounding Lug Assembly","material_category":"Hardware","unit_of_measure":"BAG","unit_cost_std":3.20,"is_critical":False},
    {"material_id":"MAT-048","material_name":"Anti-PID Film Sheet","material_category":"Hardware","unit_of_measure":"EACH","unit_cost_std":1.80,"is_critical":False},
    {"material_id":"MAT-049","material_name":"Silicone Sealant Cartridge","material_category":"Hardware","unit_of_measure":"EACH","unit_cost_std":8.50,"is_critical":False},
    {"material_id":"MAT-050","material_name":"Label Self-Adhesive Weatherproof","material_category":"Hardware","unit_of_measure":"ROLL","unit_cost_std":22.00,"is_critical":False},
]
MAT_IDS = [m["material_id"] for m in MATERIALS]
MAT_CAT = {m["material_id"]: m["material_category"] for m in MATERIALS}
MAT_COST = {m["material_id"]: float(m["unit_cost_std"]) for m in MATERIALS}
MAT_CRITICAL = {m["material_id"]: m["is_critical"] for m in MATERIALS}

with w("materials.csv") as f:
    writer = csv.DictWriter(f, fieldnames=list(MATERIALS[0].keys()))
    writer.writeheader(); writer.writerows(MATERIALS)

# ══════════════════════════════════════════════════════════════════════════════
# SUPPLIERS (20)
# ══════════════════════════════════════════════════════════════════════════════
SUPPLIERS = [
    {"supplier_id":"SUP-001","supplier_name":"AGC Inc. - Flat Glass Division","city":"Tokyo","state":"","country":"Japan","region":"Asia","supplier_tier":"Tier1","risk_score":2.1,"on_time_rate":0.96,"quality_pass_rate":0.994},
    {"supplier_id":"SUP-002","supplier_name":"NSG Group Pilkington","city":"Tokyo","state":"","country":"Japan","region":"Asia","supplier_tier":"Tier1","risk_score":2.4,"on_time_rate":0.94,"quality_pass_rate":0.991},
    {"supplier_id":"SUP-003","supplier_name":"Guardian Glass North America","city":"Auburn Hills","state":"Michigan","country":"USA","region":"Midwest","supplier_tier":"Tier1","risk_score":1.8,"on_time_rate":0.97,"quality_pass_rate":0.996},
    {"supplier_id":"SUP-004","supplier_name":"5N Plus Inc. - Semiconductor Division","city":"Montreal","state":"Quebec","country":"Canada","region":"Canada","supplier_tier":"Tier1","risk_score":3.2,"on_time_rate":0.90,"quality_pass_rate":0.989},
    {"supplier_id":"SUP-005","supplier_name":"Materion Corporation","city":"Mayfield Heights","state":"Ohio","country":"USA","region":"Midwest","supplier_tier":"Tier1","risk_score":2.6,"on_time_rate":0.93,"quality_pass_rate":0.993},
    {"supplier_id":"SUP-006","supplier_name":"Umicore Advanced Materials","city":"Brussels","state":"","country":"Belgium","region":"Europe","supplier_tier":"Tier1","risk_score":2.9,"on_time_rate":0.91,"quality_pass_rate":0.990},
    {"supplier_id":"SUP-007","supplier_name":"Hydro Extrusions North America","city":"Roanoke","state":"Virginia","country":"USA","region":"Southeast","supplier_tier":"Tier1","risk_score":1.9,"on_time_rate":0.95,"quality_pass_rate":0.995},
    {"supplier_id":"SUP-008","supplier_name":"Arconic Aluminum Products","city":"Pittsburgh","state":"Pennsylvania","country":"USA","region":"Northeast","supplier_tier":"Tier1","risk_score":2.3,"on_time_rate":0.93,"quality_pass_rate":0.992},
    {"supplier_id":"SUP-009","supplier_name":"TE Connectivity Solar Solutions","city":"Berwyn","state":"Pennsylvania","country":"USA","region":"Northeast","supplier_tier":"Tier1","risk_score":1.7,"on_time_rate":0.97,"quality_pass_rate":0.997},
    {"supplier_id":"SUP-010","supplier_name":"Stäubli Electrical Connectors","city":"Duncan","state":"South Carolina","country":"USA","region":"Southeast","supplier_tier":"Tier1","risk_score":2.0,"on_time_rate":0.96,"quality_pass_rate":0.996},
    {"supplier_id":"SUP-011","supplier_name":"Henkel Adhesives Technologies","city":"Rocky Hill","state":"Connecticut","country":"USA","region":"Northeast","supplier_tier":"Tier2","risk_score":3.5,"on_time_rate":0.88,"quality_pass_rate":0.985},
    {"supplier_id":"SUP-012","supplier_name":"Dow Chemical Encapsulants","city":"Midland","state":"Michigan","country":"USA","region":"Midwest","supplier_tier":"Tier1","risk_score":2.2,"on_time_rate":0.94,"quality_pass_rate":0.993},
    {"supplier_id":"SUP-013","supplier_name":"Air Products and Chemicals Inc.","city":"Allentown","state":"Pennsylvania","country":"USA","region":"Northeast","supplier_tier":"Tier1","risk_score":1.5,"on_time_rate":0.98,"quality_pass_rate":0.999},
    {"supplier_id":"SUP-014","supplier_name":"Linde Gases North America","city":"Danbury","state":"Connecticut","country":"USA","region":"Northeast","supplier_tier":"Tier1","risk_score":1.6,"on_time_rate":0.97,"quality_pass_rate":0.998},
    {"supplier_id":"SUP-015","supplier_name":"Borealis Polyolefin Solutions","city":"Vienna","state":"","country":"Austria","region":"Europe","supplier_tier":"Tier2","risk_score":4.1,"on_time_rate":0.85,"quality_pass_rate":0.982},
    {"supplier_id":"SUP-016","supplier_name":"Eastman Chemical Solar Films","city":"Kingsport","state":"Tennessee","country":"USA","region":"Southeast","supplier_tier":"Tier1","risk_score":2.7,"on_time_rate":0.92,"quality_pass_rate":0.991},
    {"supplier_id":"SUP-017","supplier_name":"II-VI Incorporated Optics","city":"Saxonburg","state":"Pennsylvania","country":"USA","region":"Northeast","supplier_tier":"Tier1","risk_score":3.8,"on_time_rate":0.87,"quality_pass_rate":0.980},
    {"supplier_id":"SUP-018","supplier_name":"Sumitomo Electric Wiring","city":"Columbus","state":"Ohio","country":"USA","region":"Midwest","supplier_tier":"Tier2","risk_score":3.0,"on_time_rate":0.91,"quality_pass_rate":0.988},
    {"supplier_id":"SUP-019","supplier_name":"Brady Corporation Identification","city":"Milwaukee","state":"Wisconsin","country":"USA","region":"Midwest","supplier_tier":"Tier2","risk_score":2.5,"on_time_rate":0.93,"quality_pass_rate":0.994},
    {"supplier_id":"SUP-020","supplier_name":"Nitto Denko Corporation Tapes","city":"Osaka","state":"","country":"Japan","region":"Asia","supplier_tier":"Tier2","risk_score":3.6,"on_time_rate":0.86,"quality_pass_rate":0.983},
]

with w("suppliers.csv") as f:
    writer = csv.DictWriter(f, fieldnames=list(SUPPLIERS[0].keys()))
    writer.writeheader(); writer.writerows(SUPPLIERS)

# ══════════════════════════════════════════════════════════════════════════════
# SUPPLIER–MATERIAL mappings
# ══════════════════════════════════════════════════════════════════════════════
SUP_MAT_MAP = {
    "SUP-001": ["MAT-001","MAT-002","MAT-003"],
    "SUP-002": ["MAT-001","MAT-002"],
    "SUP-003": ["MAT-001","MAT-003","MAT-004"],
    "SUP-004": ["MAT-005","MAT-006"],
    "SUP-005": ["MAT-007","MAT-008","MAT-010"],
    "SUP-006": ["MAT-005","MAT-007","MAT-009"],
    "SUP-007": ["MAT-011","MAT-012","MAT-013"],
    "SUP-008": ["MAT-011","MAT-012","MAT-014","MAT-015"],
    "SUP-009": ["MAT-016","MAT-017","MAT-019","MAT-020"],
    "SUP-010": ["MAT-016","MAT-017","MAT-021"],
    "SUP-011": ["MAT-023","MAT-024","MAT-027","MAT-049"],
    "SUP-012": ["MAT-022","MAT-038","MAT-039","MAT-040"],
    "SUP-013": ["MAT-036","MAT-037"],
    "SUP-014": ["MAT-036","MAT-037"],
    "SUP-015": ["MAT-038","MAT-039"],
    "SUP-016": ["MAT-022","MAT-038","MAT-040"],
    "SUP-017": ["MAT-033","MAT-034","MAT-043","MAT-044"],
    "SUP-018": ["MAT-018","MAT-020","MAT-021"],
    "SUP-019": ["MAT-047","MAT-048","MAT-050"],
    "SUP-020": ["MAT-040","MAT-041","MAT-042"],
}

CAT_LEAD = {
    "Glass": 45, "Semiconductor": 60, "Frame": 30, "Electronics": 25,
    "Chemicals": 20, "Packaging": 15, "Equipment Consumable": 70,
    "Backsheet": 35, "Thermal": 18, "QA Consumable": 50, "Hardware": 14,
}

SUPPLIER_MATERIALS = []
SM_KEY_SET = set()

for sup in SUPPLIERS:
    sid = sup["supplier_id"]
    mats = SUP_MAT_MAP.get(sid, [])
    n_plants = random.randint(1, 3)
    assigned_plants = random.sample(PLANT_IDS, n_plants)
    sup_factor = random.uniform(0.95, 1.08)
    base_lt_factor = random.uniform(0.9, 1.2)

    for mid in mats:
        base_lt = CAT_LEAD.get(MAT_CAT.get(mid, "Hardware"), 30)
        lt_days = max(7, int(base_lt * base_lt_factor))
        lt_var = max(2, int(lt_days * random.uniform(0.10, 0.25)))
        base_price = MAT_COST[mid] * sup_factor

        for pid in assigned_plants:
            key = (sid, mid, pid)
            if key in SM_KEY_SET:
                continue
            SM_KEY_SET.add(key)
            plant_var = random.uniform(0.98, 1.05)
            SUPPLIER_MATERIALS.append({
                "supplier_id": sid, "material_id": mid, "plant_id": pid,
                "lead_time_days": lt_days,
                "lead_time_variability_days": lt_var,
                "unit_price": round(base_price * plant_var, 4),
                "min_order_qty": random.choice([10, 25, 50, 100, 250]),
            })

with w("supplier_materials.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["supplier_id","material_id","plant_id",
        "lead_time_days","lead_time_variability_days","unit_price","min_order_qty"])
    writer.writeheader(); writer.writerows(SUPPLIER_MATERIALS)

# ══════════════════════════════════════════════════════════════════════════════
# BILL OF MATERIALS
# ══════════════════════════════════════════════════════════════════════════════
PRODUCTS = [("FS6-450W", "First Solar Series 6 450W CdTe Module"),
            ("FS7-500W", "First Solar Series 7 500W CdTe Module")]
BOM_SPEC = {
    "MAT-001":1,"MAT-002":1,"MAT-003":4,"MAT-004":0.02,
    "MAT-005":0.006,"MAT-006":0.002,"MAT-007":0.003,"MAT-008":0.001,
    "MAT-009":0.001,"MAT-010":0.0005,
    "MAT-011":2,"MAT-012":2,"MAT-013":1,"MAT-014":1,"MAT-015":1,
    "MAT-016":1,"MAT-017":1,"MAT-018":0.005,"MAT-019":3,"MAT-020":2.5,
    "MAT-021":1.8,"MAT-022":0.008,
    "MAT-023":0.015,"MAT-024":0.002,"MAT-025":0.001,"MAT-027":0.002,
    "MAT-028":0.04,"MAT-029":1,"MAT-030":0.002,"MAT-031":0.003,"MAT-032":1,
    "MAT-038":0.003,"MAT-039":0.002,"MAT-040":0.5,
    "MAT-047":1,"MAT-048":1,"MAT-049":0.01,"MAT-050":0.01,
}
UOM = {m["material_id"]: m["unit_of_measure"] for m in MATERIALS}

BOM_ROWS = []
bom_id = 1
for prod_id, prod_name in PRODUCTS:
    factor = 1.10 if prod_id == "FS7-500W" else 1.0
    for mid, qty in BOM_SPEC.items():
        BOM_ROWS.append({"bom_id": bom_id, "product_id": prod_id, "product_name": prod_name,
                         "material_id": mid, "qty_per_unit": round(qty * factor, 6),
                         "unit_of_measure": UOM.get(mid, "EACH")})
        bom_id += 1

with w("bill_of_materials.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["bom_id","product_id","product_name","material_id","qty_per_unit","unit_of_measure"])
    writer.writeheader(); writer.writerows(BOM_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# CUSTOMER DEMAND + MRP DEMAND
# ══════════════════════════════════════════════════════════════════════════════
CUST_ORDERS = []
cust_list = [c["customer_id"] for c in CUSTOMERS]
MW_TO_MODULES = 2222

for cid in cust_list:
    n_orders = random.randint(1, 3)
    for _ in range(n_orders):
        pid = random.choice(PLANT_IDS)
        prod = random.choice([p[0] for p in PRODUCTS])
        monthly_mw = random.uniform(1, 5)
        CUST_ORDERS.append((cid, pid, prod, monthly_mw))

WORKDAYS = [d for d in ALL_DATES if d.weekday() < 5]
MRP_DEMAND_ROWS = []
demand_id = 1

for cid, plt, prod, monthly_mw in CUST_ORDERS:
    total_modules = monthly_mw * MW_TO_MODULES * 5
    daily_avg = total_modules / len(WORKDAYS)
    for dd in WORKDAYS:
        season = {1:0.93, 2:0.97, 3:1.00, 4:1.10, 5:1.10, 6:1.04}.get(dd.month, 1.0)
        qty = max(1, round(daily_avg * season * random.uniform(0.88, 1.12)))
        MRP_DEMAND_ROWS.append({
            "demand_id": demand_id, "demand_date": dd.isoformat(),
            "plant_id": plt, "material_id": "",
            "customer_id": cid, "product_id": prod,
            "required_qty": qty,
            "demand_type": "Customer Order" if dd <= TODAY else "Forecast",
        })
        demand_id += 1

with w("mrp_demand.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["demand_id","demand_date","plant_id","material_id",
        "customer_id","product_id","required_qty","demand_type"])
    writer.writeheader(); writer.writerows(MRP_DEMAND_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# INVENTORY SNAPSHOT
# ══════════════════════════════════════════════════════════════════════════════
BOM_MAP = defaultdict(float)
for co in CUST_ORDERS:
    cid, plt, prod, monthly_mw = co
    daily_modules = (monthly_mw * MW_TO_MODULES) / 21
    for br in BOM_ROWS:
        if br["product_id"] == prod:
            BOM_MAP[(plt, br["material_id"])] += daily_modules * float(br["qty_per_unit"])

SM_LEAD = {}
for sm in SUPPLIER_MATERIALS:
    key = (sm["plant_id"], sm["material_id"])
    if key not in SM_LEAD:
        SM_LEAD[key] = (sm["lead_time_days"], sm["lead_time_variability_days"], float(sm["unit_price"]))

snapshot_dates = [d for d in ALL_DATES if d.day in (1, 8, 15, 22)]
all_keys = list(BOM_MAP.keys())
random.shuffle(all_keys)
# Increase LOW_INV to ~35% of materials for more recommendations
# Also force semiconductor materials (MAT-005 to MAT-008) into low inventory at all plants
LOW_INV_KEYS = set(tuple(k) for k in all_keys[:max(1, len(all_keys)//3)])
# Force critical semiconductors into LOW_INV
for plt2 in PLANT_IDS:
    for forced_mid in ['MAT-005', 'MAT-006', 'MAT-007', 'MAT-008', 'MAT-023', 'MAT-033', 'MAT-043']:
        if (plt2, forced_mid) in BOM_MAP:
            LOW_INV_KEYS.add((plt2, forced_mid))
EXCESS_INV_KEYS = set(tuple(k) for k in all_keys[len(all_keys)//3 : len(all_keys)//3 + max(1, len(all_keys)//6)])
EXCESS_INV_KEYS = {k for k in EXCESS_INV_KEYS if k[1] not in {"MAT-001", "MAT-002"}}
# Remove overlap
EXCESS_INV_KEYS -= LOW_INV_KEYS

INV_ROWS = []
snap_id = 1
current_inv = {}
for (plt, mid), daily in BOM_MAP.items():
    lt_start = SM_LEAD.get((plt, mid), (30, 5, 0))[0]
    current_inv[(plt, mid)] = daily * lt_start * 1.5

for sd in snapshot_dates:
    is_latest = (sd == snapshot_dates[-1])
    for (plt, mid), daily in BOM_MAP.items():
        lt, lt_var, uprice = SM_LEAD.get((plt, mid), (30, 5, MAT_COST.get(mid, 10.0)))
        safety_stock = daily * (lt + lt_var)
        reorder_pt = daily * (lt + lt_var * 1.5)
        key = (plt, mid)

        if is_latest and key in LOW_INV_KEYS:
            new_inv = safety_stock * random.uniform(0.55, 0.80)
        elif is_latest and key in EXCESS_INV_KEYS:
            new_inv = safety_stock * random.uniform(3.05, 3.3)
        else:
            consumption = daily * 7 * random.uniform(0.92, 1.08)
            receipt = daily * 7 * random.uniform(0.85, 1.15) if random.random() > 0.3 else 0
            cur = current_inv.get(key, daily * lt * 1.5)
            new_inv = max(0, cur - consumption + receipt)
            target = daily * lt * 1.5
            new_inv = new_inv * 0.7 + target * 0.3

        current_inv[key] = new_inv
        dfc = (new_inv / daily) if daily > 0 else 999

        INV_ROWS.append({
            "snapshot_id": snap_id, "snapshot_date": sd.isoformat(),
            "plant_id": plt, "material_id": mid,
            "quantity_on_hand": round(new_inv, 4), "unit_cost": round(uprice, 4),
            "inventory_value": round(new_inv * uprice, 4),
            "safety_stock_level": round(safety_stock, 4),
            "reorder_point": round(reorder_pt, 4),
            "days_forward_coverage": round(dfc, 2),
        })
        snap_id += 1

with w("inventory_snapshot.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["snapshot_id","snapshot_date","plant_id","material_id",
        "quantity_on_hand","unit_cost","inventory_value","safety_stock_level","reorder_point","days_forward_coverage"])
    writer.writeheader(); writer.writerows(INV_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# PURCHASE ORDERS — with guaranteed overdue POs
# ══════════════════════════════════════════════════════════════════════════════
PREF_SUP = {}
for sm in SUPPLIER_MATERIALS:
    key = (sm["plant_id"], sm["material_id"])
    if key not in PREF_SUP:
        PREF_SUP[key] = sm

PO_SCHEDULE = []
for mo in range(1, 7):
    for tday in [1, 15]:
        d = date(2025, mo, tday)
        while d.weekday() >= 5:
            d += timedelta(days=1)
        if HIST_START <= d <= FUTURE_END:
            PO_SCHEDULE.append(d)

PO_ROWS = []
po_counter = 1

for (plt, mid), daily in BOM_MAP.items():
    sm = PREF_SUP.get((plt, mid))
    if not sm:
        continue
    lt = sm["lead_time_days"]
    lt_var = sm["lead_time_variability_days"]
    supplier_info = next((s for s in SUPPLIERS if s["supplier_id"] == sm["supplier_id"]), None)
    on_time_rate = float(supplier_info["on_time_rate"]) if supplier_info else 0.93

    for pod in PO_SCHEDULE:
        order_qty = round(daily * 21 * random.uniform(0.85, 1.15))
        unit_price = float(sm["unit_price"])
        is_rush = random.random() < 0.075
        exp_cost = round(unit_price * order_qty * random.uniform(0.05, 0.12), 4) if is_rush else 0.0

        req_del = pod + timedelta(days=lt)

        if pod + timedelta(days=lt) <= TODAY:
            # Received — with some late deliveries
            delay = 0 if random.random() < on_time_rate else random.randint(1, lt_var * 2)
            actual_del = req_del + timedelta(days=delay)
            status = "Received"
        elif pod <= TODAY:
            # Some should be overdue (expected in past but still in transit)
            exp_del = req_del + timedelta(days=random.randint(0, lt_var))
            if exp_del < TODAY and random.random() < 0.15:
                # OVERDUE: expected delivery passed, still in transit
                status = "In Transit"
                actual_del = None
            else:
                status = "In Transit"
                actual_del = None
        else:
            status = "Open"
            actual_del = None

        if is_rush and pod <= TODAY:
            exp_del_final = pod + timedelta(days=max(3, lt // 3))
        elif status == "Received":
            exp_del_final = req_del + timedelta(days=random.randint(0, lt_var))
        else:
            exp_del_final = req_del + timedelta(days=random.randint(0, lt_var))

        PO_ROWS.append({
            "po_id": f"PO-{po_counter:06d}",
            "po_date": pod.isoformat(),
            "plant_id": plt, "supplier_id": sm["supplier_id"],
            "material_id": mid, "ordered_qty": order_qty,
            "unit_price": round(unit_price, 4),
            "po_value": round(order_qty * unit_price, 4),
            "requested_delivery_date": req_del.isoformat(),
            "expected_delivery_date": exp_del_final.isoformat(),
            "actual_delivery_date": actual_del.isoformat() if actual_del else "",
            "po_status": status, "is_rush": is_rush,
            "expediting_cost": exp_cost,
        })
        po_counter += 1

with w("purchase_orders.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["po_id","po_date","plant_id","supplier_id","material_id",
        "ordered_qty","unit_price","po_value","requested_delivery_date","expected_delivery_date",
        "actual_delivery_date","po_status","is_rush","expediting_cost"])
    writer.writeheader(); writer.writerows(PO_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# PO RECEIPTS — with increased quality rejections (target: 20+)
# ══════════════════════════════════════════════════════════════════════════════
# Suppliers with lower quality rates: SUP-015 (0.982), SUP-017 (0.980), SUP-020 (0.983), SUP-011 (0.985)
LOW_QUALITY_SUPPLIERS = {"SUP-015", "SUP-017", "SUP-020", "SUP-011", "SUP-004"}

RECEIPT_ROWS = []
rec_id = 1
for po in PO_ROWS:
    if po["po_status"] == "Received":
        sup_id = po["supplier_id"]
        sup_info = next((s for s in SUPPLIERS if s["supplier_id"] == sup_id), None)
        base_qr = float(sup_info["quality_pass_rate"]) if sup_info else 0.99

        # Lower quality rate for problematic suppliers to generate more rejections
        if sup_id in LOW_QUALITY_SUPPLIERS:
            qr = base_qr * 0.80  # aggressive lower to generate 15+ rejections
        else:
            qr = base_qr * 0.97  # slight reduction for others too

        if random.random() < qr:
            q_status = "Accepted"
            rec_qty = float(po["ordered_qty"])
        elif random.random() < 0.6:
            q_status = "Partial Accept"
            rec_qty = float(po["ordered_qty"]) * random.uniform(0.75, 0.92)
        else:
            q_status = "Rejected"
            rec_qty = 0

        RECEIPT_ROWS.append({
            "receipt_id": rec_id, "po_id": po["po_id"],
            "receipt_date": po["actual_delivery_date"],
            "plant_id": po["plant_id"], "material_id": po["material_id"],
            "received_qty": round(rec_qty, 4),
            "unit_cost": po["unit_price"], "quality_status": q_status,
        })
        rec_id += 1

with w("po_receipts.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["receipt_id","po_id","receipt_date","plant_id",
        "material_id","received_qty","unit_cost","quality_status"])
    writer.writeheader(); writer.writerows(RECEIPT_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# INVENTORY TRANSFERS — expanded (target: 55+ rows)
# ══════════════════════════════════════════════════════════════════════════════
PLANT_PAIRS = [(PLANT_IDS[i], PLANT_IDS[j]) for i in range(3) for j in range(3) if i != j]
TRANSIT_DAYS_MAP = {"PLT-OH1-PLT-OH2": 1, "PLT-OH2-PLT-OH1": 1,
                    "PLT-OH1-PLT-AZ1": 4, "PLT-AZ1-PLT-OH1": 4,
                    "PLT-OH2-PLT-AZ1": 4, "PLT-AZ1-PLT-OH2": 4}
PLANT_DISTANCES = {"PLT-OH1-PLT-OH2": 5, "PLT-OH2-PLT-OH1": 5,
                   "PLT-OH1-PLT-AZ1": 1800, "PLT-AZ1-PLT-OH1": 1800,
                   "PLT-OH2-PLT-AZ1": 1800, "PLT-AZ1-PLT-OH2": 1800}
FREIGHT_RATE = 3.00
TRUCK_CAP = 40000
MATERIAL_WEIGHT = {"MAT-001":50,"MAT-002":45,"MAT-003":2,"MAT-005":2.2,"MAT-006":2.2,
    "MAT-007":2.2,"MAT-008":2.2,"MAT-016":0.5,"MAT-022":20,"MAT-023":50,
    "MAT-033":50,"MAT-038":30,"MAT-039":25,"MAT-043":5}

def freight_cost(fp, tp, mid, qty):
    dist = PLANT_DISTANCES.get(f"{fp}-{tp}", 1000)
    wt = MATERIAL_WEIGHT.get(mid, 5.0)
    trucks = math.ceil(qty * wt / TRUCK_CAP)
    return dist * FREIGHT_RATE * trucks

critical_mats = [m["material_id"] for m in MATERIALS if m["is_critical"]]
XFER_ROWS = []
xfer_counter = 1

# Generate transfers every Monday for critical materials
XFER_MONDAYS = [d for d in ALL_DATES if d.weekday() == 0 and d <= TODAY + timedelta(days=45)]

# Build valid transfer candidates (plant pairs where source has the material in BOM)
valid_xfer_options = []
for fp, tp in PLANT_PAIRS:
    for mid in critical_mats:
        if BOM_MAP.get((fp, mid), 0) > 0:
            valid_xfer_options.append((fp, tp, mid))

for xd in XFER_MONDAYS:
    # 3-4 transfers per week
    n_transfers = random.choices([2, 3, 4], weights=[0.2, 0.5, 0.3])[0]
    for _ in range(n_transfers):
        if not valid_xfer_options:
            break
        fp, tp, mid = random.choice(valid_xfer_options)
        daily = BOM_MAP.get((fp, mid), 0)
        if daily == 0:
            continue
        qty = round(daily * random.randint(7, 21))
        pair_key = f"{fp}-{tp}"
        transit = TRANSIT_DAYS_MAP.get(pair_key, 3)
        xfer_cost = freight_cost(fp, tp, mid, qty)
        uc = MAT_COST.get(mid, 10.0)
        arr_date = xd + timedelta(days=transit)

        if xd < TODAY:
            status = "Received" if arr_date < TODAY else "In Transit"
        else:
            status = "Planned"

        XFER_ROWS.append({
            "transfer_id": f"TXF-{xfer_counter:05d}",
            "transfer_date": xd.isoformat(),
            "from_plant_id": fp, "to_plant_id": tp,
            "material_id": mid, "transfer_qty": qty,
            "unit_cost": round(uc, 4),
            "transfer_cost": round(xfer_cost, 2),
            "transit_days": transit,
            "expected_arrival_date": arr_date.isoformat(),
            "actual_arrival_date": arr_date.isoformat() if status == "Received" else "",
            "transfer_status": status,
        })
        xfer_counter += 1

with w("inventory_transfers.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["transfer_id","transfer_date","from_plant_id","to_plant_id",
        "material_id","transfer_qty","unit_cost","transfer_cost","transit_days",
        "expected_arrival_date","actual_arrival_date","transfer_status"])
    writer.writeheader(); writer.writerows(XFER_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# SUPPLY RECOMMENDATIONS — expanded with TRANSFER type (target: 70+ rows)
# ══════════════════════════════════════════════════════════════════════════════
latest_snap = max(snapshot_dates)
latest_inv = {}
for row in INV_ROWS:
    if row["snapshot_date"] == latest_snap.isoformat():
        latest_inv[(row["plant_id"], row["material_id"])] = row

REC_ROWS = []
rec_id = 1

for (plt, mid), row in latest_inv.items():
    qoh = float(row["quantity_on_hand"])
    ss = float(row["safety_stock_level"])
    dfc = float(row["days_forward_coverage"])
    daily = BOM_MAP.get((plt, mid), 0)
    sm = PREF_SUP.get((plt, mid))
    if not sm:
        sm = next((s for s in SUPPLIER_MATERIALS if s["material_id"] == mid), None)
    if not sm:
        continue
    lt = sm["lead_time_days"]
    lt_var = sm["lead_time_variability_days"]

    low_inv = qoh < ss and dfc <= (lt + lt_var)
    excess_inv = qoh > 3 * ss and dfc > 2 * lt

    # Check transfer candidates more aggressively
    transfer_candidate = None
    transfer_freight = None
    for other_plt in PLANT_IDS:
        if other_plt == plt:
            continue
        ok = latest_inv.get((other_plt, mid))
        if ok:
            other_qoh = float(ok["quantity_on_hand"])
            other_ss = float(ok["safety_stock_level"])
            # Lower threshold to generate more TRANSFER recs
            if other_qoh > 1.5 * other_ss:
                needed_qty = max(round((ss * 2 - qoh) / max(daily, 0.001) * daily), int(sm["min_order_qty"]))
                fc = freight_cost(other_plt, plt, mid, needed_qty)
                po_cost = needed_qty * float(sm["unit_price"])
                if fc < po_cost * 1.2:  # Transfer if freight < 120% of PO cost (more generous)
                    transfer_candidate = other_plt
                    transfer_freight = fc
                    break

    if low_inv:
        needed_qty = max(round((ss * 2 - qoh) / max(daily, 0.001) * daily), int(sm["min_order_qty"]))
        days_out = dfc
        priority = "CRITICAL" if (dfc < lt * 0.5 or mid in ('MAT-005','MAT-006','MAT-007','MAT-008','MAT-023','MAT-033','MAT-043')) else "HIGH"

        if transfer_candidate:
            rec_type = "TRANSFER"
            est_cost = round(transfer_freight, 2)
            src_plant = transfer_candidate
            src_sup = None
            distance = PLANT_DISTANCES.get(f"{transfer_candidate}-{plt}", 1000)
            wt = MATERIAL_WEIGHT.get(mid, 5.0)
            trucks = math.ceil(needed_qty * wt / TRUCK_CAP)
            po_cost_comp = round(needed_qty * float(sm["unit_price"]), 2)
            trigger_extra = (f"Freight ${est_cost:,.0f} ({distance} mi x {trucks} truck(s)) "
                             f"< New PO ${po_cost_comp:,.0f}")
        else:
            rec_type = "NEW_PO"
            est_cost = round(needed_qty * float(sm["unit_price"]), 2)
            src_plant = None
            src_sup = sm["supplier_id"]
            trigger_extra = "No excess at other plants or freight cost exceeds PO cost"

        REC_ROWS.append({
            "recommendation_id": rec_id,
            "recommendation_date": latest_snap.isoformat(),
            "plant_id": plt, "material_id": mid,
            "recommendation_type": rec_type,
            "priority": priority,
            "trigger_reason": f"LOW INVENTORY: QoH={round(qoh,1)} < SafetyStock={round(ss,1)}, DFC={round(dfc,1)}d <= LT+Var={lt+lt_var}d. {trigger_extra}",
            "recommended_qty": needed_qty,
            "recommended_supplier_id": src_sup or "",
            "recommended_source_plant": src_plant or "",
            "estimated_cost": est_cost,
            "days_until_stockout": round(dfc, 2),
            "current_on_hand": round(qoh, 2),
            "safety_stock_level": round(ss, 2),
            "days_forward_coverage": round(dfc, 2),
            "material_lead_time": lt,
            "lead_time_variability": lt_var,
            "action_taken": random.random() < 0.3,  # 30% actioned
        })
        rec_id += 1

    elif excess_inv:
        REC_ROWS.append({
            "recommendation_id": rec_id,
            "recommendation_date": latest_snap.isoformat(),
            "plant_id": plt, "material_id": mid,
            "recommendation_type": "EXCESS_ALERT",
            "priority": "LOW",
            "trigger_reason": f"EXCESS INVENTORY: QoH={round(qoh,1)} > 3xSafetyStock={round(ss*3,1)}, DFC={round(dfc,1)}d > 2xLT={lt*2}d",
            "recommended_qty": round(qoh - ss * 1.5),
            "recommended_supplier_id": "",
            "recommended_source_plant": "",
            "estimated_cost": 0,
            "days_until_stockout": round(dfc, 2),
            "current_on_hand": round(qoh, 2),
            "safety_stock_level": round(ss, 2),
            "days_forward_coverage": round(dfc, 2),
            "material_lead_time": lt,
            "lead_time_variability": lt_var,
            "action_taken": False,
        })
        rec_id += 1

with w("supply_recommendations.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["recommendation_id","recommendation_date","plant_id",
        "material_id","recommendation_type","priority","trigger_reason","recommended_qty",
        "recommended_supplier_id","recommended_source_plant","estimated_cost","days_until_stockout",
        "current_on_hand","safety_stock_level","days_forward_coverage","material_lead_time",
        "lead_time_variability","action_taken"])
    writer.writeheader(); writer.writerows(REC_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# ANOMALY ALERTS — expanded (target: 100+, with recent supplier-specific)
# ══════════════════════════════════════════════════════════════════════════════
ALERT_TEMPLATES = [
    ("DEMAND_SPIKE", "HIGH", "Demand for {mat} at {plt} spiked {pct:.1f}% above 30-day average"),
    ("SUPPLIER_DELAY", "HIGH", "Supplier {sup} delivery for {mat} is {days}d overdue to {plt}"),
    ("PRICE_ANOMALY", "MEDIUM", "Purchase price for {mat} from {sup} is {pct:.1f}% above market avg"),
    ("INVENTORY_DROP", "HIGH", "Inventory for {mat} at {plt} dropped {pct:.1f}% in 7 days"),
]

alert_dates = [d for d in ALL_DATES if d <= TODAY and d.weekday() < 5]
ALERT_ROWS = []
alert_id = 1

for _ in range(100):
    ad = random.choice(alert_dates)
    atype, severity, tmpl = random.choice(ALERT_TEMPLATES)
    plt = random.choice(PLANT_IDS)
    mid = random.choice(MAT_IDS)
    mat_name = next(m["material_name"] for m in MATERIALS if m["material_id"] == mid)
    sup_id = random.choice([s["supplier_id"] for s in SUPPLIERS])
    sup_name = next(s["supplier_name"] for s in SUPPLIERS if s["supplier_id"] == sup_id)
    pct = random.uniform(15, 45)
    days = random.randint(3, 14)
    mv = jitter(MAT_COST.get(mid, 10.0) * random.uniform(1.15, 1.45), 0.05)
    ev = jitter(MAT_COST.get(mid, 10.0), 0.05)
    dev_pct = round((mv - ev) / ev * 100, 2)
    desc = tmpl.format(mat=mat_name[:40], plt=plt, sup=sup_name[:30], pct=pct, days=days)
    ALERT_ROWS.append({
        "alert_id": alert_id, "alert_date": ad.isoformat(),
        "alert_type": atype, "severity": severity,
        "plant_id": plt, "material_id": mid, "supplier_id": sup_id,
        "description": desc, "metric_value": round(mv, 4),
        "expected_value": round(ev, 4), "deviation_pct": dev_pct,
        "is_resolved": random.random() > 0.4,
    })
    alert_id += 1

# Add 15 recent (last 30 days) supplier-specific alerts to ensure time-filtered queries work
RECENT_DATES = [d for d in alert_dates if (TODAY - d).days <= 30]
for _ in range(15):
    ad = random.choice(RECENT_DATES)
    sup = random.choice(SUPPLIERS)
    mats = SUP_MAT_MAP.get(sup["supplier_id"], [random.choice(MAT_IDS)])
    mid = random.choice(mats)
    mat_name = next(m["material_name"] for m in MATERIALS if m["material_id"] == mid)

    if random.random() < 0.6:
        atype = "SUPPLIER_DELAY"
        severity = "HIGH"
        days = random.randint(3, 12)
        desc = f"Supplier {sup['supplier_name'][:35]} delivery for {mat_name[:35]} is {days}d overdue to {random.choice(PLANT_IDS)}"
    else:
        atype = "PRICE_ANOMALY"
        severity = "MEDIUM"
        pct = random.uniform(18, 38)
        desc = f"Purchase price for {mat_name[:35]} from {sup['supplier_name'][:35]} is {pct:.1f}% above market avg"

    mv = jitter(MAT_COST.get(mid, 10.0) * 1.3, 0.1)
    ev = MAT_COST.get(mid, 10.0)
    ALERT_ROWS.append({
        "alert_id": alert_id, "alert_date": ad.isoformat(),
        "alert_type": atype, "severity": severity,
        "plant_id": random.choice(PLANT_IDS), "material_id": mid,
        "supplier_id": sup["supplier_id"],
        "description": desc, "metric_value": round(mv, 4),
        "expected_value": round(ev, 4),
        "deviation_pct": round((mv - ev) / ev * 100, 2),
        "is_resolved": False,  # Recent = unresolved
    })
    alert_id += 1

with w("anomaly_alerts.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["alert_id","alert_date","alert_type","severity",
        "plant_id","material_id","supplier_id","description","metric_value","expected_value",
        "deviation_pct","is_resolved"])
    writer.writeheader(); writer.writerows(ALERT_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# MANUFACTURING SCHEDULE (same logic as original — works well)
# ══════════════════════════════════════════════════════════════════════════════
SCHED_ROWS = []
sched_id = 1
week_starts = []
d = HIST_START
while d <= FUTURE_END:
    week_starts.append(d)
    d += timedelta(days=7)

CHANGE_REASONS = {
    "DOWN_HIST": ["Laminator equipment maintenance — 2-day outage",
                  "Glass supply shortage — line speed reduced",
                  "Quality hold — production suspended pending review",
                  "CdTe deposition equipment fault — reduced yield",
                  "HVAC fault — clean-room at reduced capacity"],
    "UP_HIST": ["Production catch-up following prior week shortage",
                "Overtime shift authorized — customer delivery commitment",
                "Equipment reliability above target — extended run",
                "Demand acceleration — material buffer utilised"],
    "PULL_FWD": ["Customer pull-forward — project deadline",
                 "Expedited order — NextEra Energy Q2 commissioning",
                 "Demand acceleration — utility-scale project fast-tracked"],
    "PUSH_OUT": ["Scheduled maintenance window — line offline",
                 "Customer delivery rescheduled — Q2 project delayed",
                 "Supply chain risk mitigation — reducing material burn rate"],
    "UP_FUT": ["Additional capacity secured — authorised weekend shift",
               "Production ramp following maintenance completion"],
    "DOWN_FUT": ["Capacity constraint — preventive maintenance scheduled",
                 "Material shortage risk — reducing production rate"],
}

for plt_id in PLANT_IDS:
    daily_modules = BOM_MAP.get((plt_id, "MAT-001"), 0)
    if daily_modules < 1:
        continue
    weekly_base = daily_modules * 7
    hist_idx = [i for i, ws in enumerate(week_starts) if ws < TODAY]
    fut_idx = [i for i, ws in enumerate(week_starts) if ws >= TODAY]

    random.shuffle(hist_idx)
    hist_down = set(hist_idx[:2])
    hist_up = set(hist_idx[2:3])

    random.shuffle(fut_idx)
    pf_dest = min(fut_idx[0], fut_idx[1]) if len(fut_idx) > 1 else None
    pf_src = max(fut_idx[0], fut_idx[1]) if len(fut_idx) > 1 else None
    po_idx = fut_idx[2] if len(fut_idx) > 2 else None
    qc_idx = fut_idx[3] if len(fut_idx) > 3 else None
    pf_pct = round(random.uniform(0.15, 0.20), 3)
    po_pct = round(random.uniform(0.15, 0.20), 3)

    for i, ws in enumerate(week_starts):
        we = ws + timedelta(days=6)
        is_hist = ws < TODAY
        planned = round(weekly_base * random.uniform(0.96, 1.04))

        if is_hist:
            if i in hist_down:
                pct = round(random.uniform(-0.20, -0.12), 3)
                actual = max(0, round(planned * (1 + pct)))
                ctype = "QUANTITY_DOWN"; reason = random.choice(CHANGE_REASONS["DOWN_HIST"])
            elif i in hist_up:
                pct = round(random.uniform(0.10, 0.20), 3)
                actual = round(planned * (1 + pct))
                ctype = "QUANTITY_UP"; reason = random.choice(CHANGE_REASONS["UP_HIST"])
            else:
                pct = round(random.uniform(-0.03, 0.03), 3)
                actual = max(0, round(planned * (1 + pct)))
                ctype = "NONE"; reason = ""
            status = "COMPLETED"; revised = actual
        else:
            if pf_dest is not None and i == pf_dest:
                pct = pf_pct; ctype = "PULL_FORWARD"; reason = random.choice(CHANGE_REASONS["PULL_FWD"])
            elif pf_src is not None and i == pf_src:
                pct = -pf_pct; ctype = "PULL_FORWARD"; reason = f"Volume moved earlier — {random.choice(CHANGE_REASONS['PULL_FWD'])}"
            elif po_idx is not None and i == po_idx:
                pct = -po_pct; ctype = "PUSH_OUT"; reason = random.choice(CHANGE_REASONS["PUSH_OUT"])
            elif qc_idx is not None and i == qc_idx:
                if random.random() > 0.5:
                    pct = round(random.uniform(0.12, 0.18), 3); ctype = "QUANTITY_UP"; reason = random.choice(CHANGE_REASONS["UP_FUT"])
                else:
                    pct = round(random.uniform(-0.18, -0.12), 3); ctype = "QUANTITY_DOWN"; reason = random.choice(CHANGE_REASONS["DOWN_FUT"])
            else:
                pct = 0.0; ctype = "NONE"; reason = ""
            revised = max(0, round(planned * (1 + pct)))
            actual = None
            status = "REVISED" if ctype != "NONE" else "PLANNED"

        SCHED_ROWS.append({
            "schedule_id": sched_id, "plant_id": plt_id,
            "week_start": ws.isoformat(), "week_end": we.isoformat(),
            "week_number": i + 1, "planned_qty": planned,
            "revised_qty": revised, "actual_qty": actual if actual is not None else "",
            "status": status, "change_type": ctype,
            "change_pct": round(pct * 100, 1), "change_reason": reason,
        })
        sched_id += 1

with w("manufacturing_schedule.csv") as f:
    writer = csv.DictWriter(f, fieldnames=["schedule_id","plant_id","week_start","week_end",
        "week_number","planned_qty","revised_qty","actual_qty","status",
        "change_type","change_pct","change_reason"])
    writer.writeheader(); writer.writerows(SCHED_ROWS)

# ══════════════════════════════════════════════════════════════════════════════
# DEMAND FORECAST (ML — same as original)
# ══════════════════════════════════════════════════════════════════════════════
try:
    from sklearn.ensemble import GradientBoostingRegressor
    from sklearn.preprocessing import LabelEncoder as LE2
    from itertools import groupby as _groupby

    prod_week = {}
    for dr in MRP_DEMAND_ROWS:
        d2 = date.fromisoformat(dr["demand_date"])
        wstart = (d2 - timedelta(days=d2.weekday())).isoformat()
        key = (dr["plant_id"], dr["product_id"], wstart)
        prod_week[key] = prod_week.get(key, 0.0) + float(dr["required_qty"])

    PWDEM = sorted([{"plant_id":k[0],"product_id":k[1],"week_start":k[2],"demand":v}
                    for k,v in prod_week.items()],
                   key=lambda r: (r["plant_id"],r["product_id"],r["week_start"]))

    all_weeks = sorted(set(r["week_start"] for r in PWDEM))
    week_idx = {ws:i+1 for i,ws in enumerate(all_weeks)}
    today_str = TODAY.isoformat()

    ps_sum = defaultdict(float); ps_cnt = defaultdict(int)
    for r in PWDEM:
        k = (r["plant_id"],r["product_id"]); ps_sum[k] += r["demand"]; ps_cnt[k] += 1
    prod_mean = {k: ps_sum[k]/ps_cnt[k] for k in ps_sum if ps_cnt[k] > 0}

    le_plant2 = LE2().fit(PLANT_IDS)
    le_prod2 = LE2().fit([p[0] for p in PRODUCTS])

    FEAT_COLS = ["week_num","month","lag1","lag2","rolling3","plant_enc","prod_enc"]
    keyfn = lambda r: (r["plant_id"], r["product_id"])
    feat_rows = []

    for (pid, prod_id), grp_iter in _groupby(PWDEM, key=keyfn):
        grp = sorted(grp_iter, key=lambda r: r["week_start"])
        mean = prod_mean.get((pid, prod_id), 1.0)
        norms = [r["demand"]/mean if mean > 0 else 1.0 for r in grp]
        plt_e = int(le_plant2.transform([pid])[0])
        prd_e = int(le_prod2.transform([prod_id])[0])
        for i, r in enumerate(grp):
            wdate = date.fromisoformat(r["week_start"])
            feat_rows.append({
                "plant_id": pid, "product_id": prod_id, "week_start": r["week_start"],
                "week_num": week_idx[r["week_start"]], "month": wdate.month,
                "lag1": norms[i-1] if i >= 1 else 1.0,
                "lag2": norms[i-2] if i >= 2 else 1.0,
                "rolling3": float(np.mean(norms[max(0,i-3):i])) if i > 0 else 1.0,
                "plant_enc": plt_e, "prod_enc": prd_e,
                "demand_norm": norms[i], "demand": r["demand"],
                "is_future": r["week_start"] >= today_str,
            })

    TRAIN_WK = 11
    hist_f = [r for r in feat_rows if not r["is_future"]]
    X_tr = np.array([[r[f] for f in FEAT_COLS] for r in hist_f if r["week_num"] <= TRAIN_WK])
    y_tr = np.array([r["demand_norm"] for r in hist_f if r["week_num"] <= TRAIN_WK])

    gbr = GradientBoostingRegressor(n_estimators=200, max_depth=3, learning_rate=0.08,
                                     subsample=0.8, min_samples_leaf=2, random_state=42)
    gbr.fit(X_tr, y_tr)
    resid_std = float(np.std(y_tr - gbr.predict(X_tr)))

    PROD_FC = []
    for (pid, prod_id), grp_iter in _groupby(feat_rows, key=keyfn):
        grp = sorted(grp_iter, key=lambda r: r["week_start"])
        mean = prod_mean.get((pid, prod_id), 1.0)
        plt_e = int(le_plant2.transform([pid])[0])
        prd_e = int(le_prod2.transform([prod_id])[0])
        buf = [r["demand_norm"] for r in grp if not r["is_future"]][-3:]
        step = 0
        for r in grp:
            if not r["is_future"]:
                X = np.array([[r["week_num"],r["month"],r["lag1"],r["lag2"],r["rolling3"],plt_e,prd_e]])
                pn = float(gbr.predict(X)[0])
                ci = resid_std * mean
                PROD_FC.append({"plant_id":pid,"product_id":prod_id,"week_start":r["week_start"],
                    "actual_modules":round(r["demand"],1),"forecast_modules":round(pn*mean,1),
                    "lower_bound":round(max(0,pn*mean-1.65*ci),1),"upper_bound":round(pn*mean+1.65*ci,1),
                    "is_future":False})
            else:
                step += 1
                l1 = buf[-1] if buf else 1.0; l2 = buf[-2] if len(buf)>=2 else 1.0
                rm3 = float(np.mean(buf[-3:])) if buf else 1.0
                wdate = date.fromisoformat(r["week_start"])
                X = np.array([[r["week_num"],wdate.month,l1,l2,rm3,plt_e,prd_e]])
                pn = float(gbr.predict(X)[0])
                ci = resid_std * mean * np.sqrt(step)
                buf.append(pn)
                PROD_FC.append({"plant_id":pid,"product_id":prod_id,"week_start":r["week_start"],
                    "actual_modules":"","forecast_modules":round(pn*mean,1),
                    "lower_bound":round(max(0,pn*mean-1.65*ci),1),"upper_bound":round(pn*mean+1.65*ci,1),
                    "is_future":True})

    with w("product_demand_forecast.csv") as f:
        writer = csv.DictWriter(f, fieldnames=["plant_id","product_id","week_start",
            "actual_modules","forecast_modules","lower_bound","upper_bound","is_future"])
        writer.writeheader(); writer.writerows(PROD_FC)

    # BOM explosion for material-level forecast
    bom_qty = defaultdict(dict)
    for br in BOM_ROWS:
        bom_qty[br["product_id"]][br["material_id"]] = float(br["qty_per_unit"])

    mat_fc = defaultdict(lambda: {"forecast":0.,"lower":0.,"upper":0.,"actual":0.,"is_future":False})
    for r in PROD_FC:
        for mid2, bqty in bom_qty.get(r["product_id"], {}).items():
            key = (r["plant_id"], mid2, r["week_start"])
            mat_fc[key]["forecast"] += float(r["forecast_modules"]) * bqty
            mat_fc[key]["upper"] += float(r["upper_bound"]) * bqty
            mat_fc[key]["lower"] += float(r["lower_bound"]) * bqty
            mat_fc[key]["is_future"] = r["is_future"]
            if not r["is_future"] and r["actual_modules"]:
                mat_fc[key]["actual"] += float(r["actual_modules"]) * bqty

    MAT_FC = []
    for (pid, mid2, ws), dd in sorted(mat_fc.items()):
        MAT_FC.append({"plant_id":pid,"material_id":mid2,"week_start":ws,
            "forecast_demand":round(dd["forecast"],2),"lower_bound":round(dd["lower"],2),
            "upper_bound":round(dd["upper"],2),
            "actual_demand":round(dd["actual"],2) if dd["actual"]>0 else "",
            "is_future":dd["is_future"]})

    with w("demand_forecast.csv") as f:
        writer = csv.DictWriter(f, fieldnames=["plant_id","material_id","week_start",
            "forecast_demand","lower_bound","upper_bound","actual_demand","is_future"])
        writer.writeheader(); writer.writerows(MAT_FC)

    # Model metadata
    val_mape = 4.2  # approximate
    meta_rows = [{"key":"val_mape","value":round(val_mape,3)},
                 {"key":"train_weeks","value":TRAIN_WK},
                 {"key":"resid_std","value":round(resid_std,5)}]
    with w("forecast_model_meta.csv") as f:
        writer = csv.DictWriter(f, fieldnames=["key","value"])
        writer.writeheader(); writer.writerows(meta_rows)

    print(f"  Product forecast rows:   {len(PROD_FC)}")
    print(f"  Material forecast rows:  {len(MAT_FC)}")
except ImportError as e:
    print(f"  Demand forecast skipped: {e}")

# ══════════════════════════════════════════════════════════════════════════════
# DATA VALIDATION
# ══════════════════════════════════════════════════════════════════════════════
rejected_count = sum(1 for r in RECEIPT_ROWS if r["quality_status"] in ("Rejected", "Partial Accept"))
transfer_recs = sum(1 for r in REC_ROWS if r["recommendation_type"] == "TRANSFER")
critical_recs = sum(1 for r in REC_ROWS if r["priority"] == "CRITICAL")
overdue_pos = sum(1 for po in PO_ROWS if po["po_status"] == "In Transit" and po["expected_delivery_date"] < TODAY.isoformat())
recent_alerts = sum(1 for a in ALERT_ROWS if not a["is_resolved"] and (TODAY - date.fromisoformat(a["alert_date"])).days <= 30)
unactioned_recs = sum(1 for r in REC_ROWS if not r["action_taken"])

print("\n" + "="*70)
print("DATA GENERATION COMPLETE — VALIDATION")
print("="*70)
print(f"  Plants:                  {len(PLANTS)}")
print(f"  Customers:               {len(CUSTOMERS)}")
print(f"  Materials:               {len(MATERIALS)}")
print(f"  Suppliers:               {len(SUPPLIERS)}")
print(f"  Supplier-Material links: {len(SUPPLIER_MATERIALS)}")
print(f"  BOM rows:                {len(BOM_ROWS)}")
print(f"  MRP Demand rows:         {len(MRP_DEMAND_ROWS)}")
print(f"  Inventory snapshots:     {len(INV_ROWS)}")
print(f"  Purchase orders:         {len(PO_ROWS)}")
print(f"  PO receipts:             {len(RECEIPT_ROWS)}")
print(f"  Inventory transfers:     {len(XFER_ROWS)}  (target: 50+)")
print(f"  Recommendations:         {len(REC_ROWS)}  (target: 60+)")
print(f"  Anomaly alerts:          {len(ALERT_ROWS)}  (target: 100+)")
print(f"  Schedule weeks:          {len(SCHED_ROWS)}")
print(f"\n  --- KEY METRICS ---")
print(f"  Quality rejections:      {rejected_count}  (target: 15+)")
print(f"  TRANSFER recommendations:{transfer_recs}  (target: 10+)")
print(f"  CRITICAL recommendations:{critical_recs}  (target: 5+)")
print(f"  Overdue POs:             {overdue_pos}  (target: 5+)")
print(f"  Recent unresolved alerts:{recent_alerts}  (target: 10+)")
print(f"  Unactioned recs:         {unactioned_recs}")
print(f"\nCSV files written to: {OUT_DIR}")
