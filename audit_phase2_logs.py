import os
import re
import glob

raw_logs_dir = os.path.join("results", "raw_logs_phase2")
csv_path = os.path.join("results", "lamp_reproduction_results_phase2.csv")

algorithms = ["COMP", "LAMP", "EWMP"]
gateways = [2, 3, 4]
mobiles = [2, 4, 6, 8]

results = []

for algo in algorithms:
    for gw in gateways:
        for mob in mobiles:
            apps = gw * mob
            log_name = f"{algo}_gw{gw}_m{mob}.log"
            log_path = os.path.join(raw_logs_dir, log_name)
            
            entry = {
                "algo": algo,
                "gw": gw,
                "mob": mob,
                "apps": apps,
                "log_exists": os.path.exists(log_path),
                "log_size": os.path.getsize(log_path) if os.path.exists(log_path) else 0,
                "csv_row": None,
                "csv_status": None,
                "csv_delay": None,
                "csv_fog_plc": None,
                "csv_cloud_plc": None,
                "log_loops_completed": None,
                "log_loops_expected": None,
                "log_total_executions": None,
                "log_fog_plc": None,
                "log_cloud_plc": None,
                "log_status": None,
                "log_delay": None,
                "loop_delays_found": 0,
                "error_notes": []
            }
            
            if entry["log_exists"]:
                with open(log_path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                # Check CSV_ROW in log
                m_csv = re.search(r"CSV_ROW:(.*)", content)
                if m_csv:
                    entry["csv_row"] = m_csv.group(1).strip()
                    parts = entry["csv_row"].split(",")
                    entry["csv_delay"] = parts[4]
                    entry["csv_fog_plc"] = int(parts[9])
                    entry["csv_cloud_plc"] = int(parts[10])
                    entry["csv_status"] = parts[11]
                
                # Check loops completed line:
                # "Loops Completed: 12 / 12 (Total Executions: 2179)"
                m_loops = re.search(r"Loops Completed:\s*(\d+)\s*/\s*(\d+)\s*\(Total Executions:\s*(\d+)\)", content)
                if m_loops:
                    entry["log_loops_completed"] = int(m_loops.group(1))
                    entry["log_loops_expected"] = int(m_loops.group(2))
                    entry["log_total_executions"] = int(m_loops.group(3))
                
                # Check Placement Distribution
                # "Fog Placements: 24"
                # "Cloud Placements: 12"
                m_fp = re.search(r"Fog Placements:\s*(\d+)", content)
                m_cp = re.search(r"Cloud Placements:\s*(\d+)", content)
                if m_fp:
                    entry["log_fog_plc"] = int(m_fp.group(1))
                if m_cp:
                    entry["log_cloud_plc"] = int(m_cp.group(1))
                
                # Check Status:
                m_st = re.search(r"Status:\s*(\w+)", content)
                if m_st:
                    entry["log_status"] = m_st.group(1)
                
                # Check Loop Delay (sim ticks):
                m_del = re.search(r"Loop Delay \(sim ticks\):\s*([\d\.]+|N/A)", content)
                if m_del:
                    entry["log_delay"] = m_del.group(1)
                
                # Count individual application loop delays listed
                loop_delay_matches = re.findall(r"\[ECG_\d+_\d+.*?\]\s*--->\s*([\d\.]+)", content)
                entry["loop_delays_found"] = len(loop_delay_matches)
                
                # Check if there are exceptions
                if "Exception" in content or "Error" in content:
                    for line in content.split("\n"):
                        if "Exception" in line or "Error" in line:
                            entry["error_notes"].append(line.strip())
            else:
                entry["error_notes"].append("Log file does not exist (TIMEOUT)")
            
            results.append(entry)

print("AUDIT RESULTS TABLE:")
print(f"{'Config':<18} | {'Log?':<5} | {'Loops (Comp/Exp)':<16} | {'Execs':<6} | {'Status':<18} | {'Loop Delay':<12} | {'Placements F/C':<15} | {'3N Check':<10}")
print("-" * 115)

for r in results:
    cfg = f"{r['algo']} gw{r['gw']} m{r['mob']} (N={r['apps']})"
    has_log = "YES" if r['log_exists'] else "NO"
    loops = f"{r['log_loops_completed']}/{r['log_loops_expected']}" if r['log_loops_completed'] is not None else "N/A"
    execs = str(r['log_total_executions']) if r['log_total_executions'] is not None else "N/A"
    st = r['csv_status'] if r['csv_status'] else ("TIMEOUT" if not r['log_exists'] else "UNKNOWN")
    delay = r['csv_delay'] if r['csv_delay'] else "N/A"
    
    plc = "N/A"
    check_3n = "N/A"
    if r['csv_fog_plc'] is not None and r['csv_cloud_plc'] is not None:
        plc = f"{r['csv_fog_plc']}/{r['csv_cloud_plc']}"
        tot = r['csv_fog_plc'] + r['csv_cloud_plc']
        check_3n = f"OK ({tot})" if tot == 3 * r['apps'] else f"FAIL ({tot})"
    elif not r['log_exists']:
        plc = "0/0"
        check_3n = "TIMEOUT"
        
    print(f"{cfg:<18} | {has_log:<5} | {loops:<16} | {execs:<6} | {st:<18} | {delay:<12} | {plc:<15} | {check_3n:<10}")

