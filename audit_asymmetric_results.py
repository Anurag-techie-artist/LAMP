import csv
import os

csv_path = os.path.join("results", "asymmetric_validation_results.csv")
raw_logs_dir = os.path.join("results", "raw_logs_asymmetric")

rows = []
with open(csv_path, "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for r in reader:
        rows.append(r)

print(f"{'Algo':<10} | {'Workload':<8} | {'Apps':<4} | {'Delay (tau)':<11} | {'Loops (C/E)':<11} | {'Analyzers (L/P/Px/C)':<20} | {'Total (Fog/Cloud/All)':<22} | {'3N Check':<9} | {'Status':<18}")
print("-" * 130)

for r in rows:
    algo = r['algorithm']
    wl = r['workload']
    apps = int(r['total_applications'])
    delay = r['loop_delay_sim_ticks']
    
    # Read loops from raw log
    log_file = os.path.join(raw_logs_dir, f"{algo}_w{wl}.log")
    loops_str = "N/A"
    if os.path.exists(log_file):
        with open(log_file, "r", encoding="utf-8") as lf:
            lcontent = lf.read()
            import re
            m = re.search(r"Loops Completed:\s*(\d+)\s*/\s*(\d+)", lcontent)
            if m:
                loops_str = f"{m.group(1)}/{m.group(2)}"
    
    analyzers = f"{r['analyzer_local_gw']}/{r['analyzer_peer_gw']}/{r['analyzer_proxy']}/{r['analyzer_cloud']}"
    totals = f"{r['total_fog_placements']}/{r['total_cloud_placements']}/{r['total_system_placements']}"
    tot_sys = int(r['total_system_placements'])
    chk_3n = "PASSED" if tot_sys == 3 * apps else "FAILED"
    st = r['status']
    
    print(f"{algo:<10} | {wl:<8} | {apps:<4} | {delay:<11} | {loops_str:<11} | {analyzers:<20} | {totals:<22} | {chk_3n:<9} | {st:<18}")
