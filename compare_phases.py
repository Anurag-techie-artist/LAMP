import csv
import os

phase1_csv = os.path.join("results", "lamp_reproduction_results_phase1_historical.csv")
phase2_csv = os.path.join("results", "lamp_reproduction_results_phase2.csv")

def read_data(path):
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append(r)
    return rows

p1 = read_data(phase1_csv)
p2 = read_data(phase2_csv)

print(f"{'Algo':<6} | {'GW':<2} | {'M/GW':<4} | {'Apps':<4} | {'Phase 1 Delay':<15} | {'Phase 2 Delay (ticks)':<22} | {'P1 Placements (F/C)':<20} | {'P2 Placements (F/C)':<20} | {'P2 Status':<18}")
print("-" * 125)

for r1, r2 in zip(p1, p2):
    algo = r2['algorithm']
    gw = r2['gateway_count']
    m = r2['mobiles_per_gateway']
    apps = r2['application_count']
    d1 = r1.get('loop_delay_ms', 'N/A')
    d2 = r2.get('loop_delay_sim_ticks', 'N/A')
    p1_plc = f"{r1.get('fog_placements')}/{r1.get('cloud_placements')}"
    p2_plc = f"{r2.get('fog_placements')}/{r2.get('cloud_placements')}"
    st2 = r2.get('status')
    print(f"{algo:<6} | {gw:<2} | {m:<4} | {apps:<4} | {d1:<15} | {d2:<22} | {p1_plc:<20} | {p2_plc:<20} | {st2:<18}")
