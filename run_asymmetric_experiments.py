import os
import subprocess
import sys
import re

JAVA_BIN = r"eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe"
CLASSPATH = r"iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*"
MAIN_CLASS = "org.fog.lamp.asymmetric.AsymmetricSimulationRunner"

RAW_LOGS_DIR = os.path.join("results", "raw_logs_asymmetric")
CSV_PATH = os.path.join("results", "asymmetric_validation_results.csv")
os.makedirs(RAW_LOGS_DIR, exist_ok=True)

CSV_HEADER = "algorithm,workload,total_applications,loop_delay_sim_ticks,cloud_energy_j,fog_energy_j,cloud_cost,network_usage,analyzer_local_gw,analyzer_peer_gw,analyzer_proxy,analyzer_cloud,total_fog_placements,total_cloud_placements,total_system_placements,status\n"

workloads = [
    (6, 2),
    (2, 6),
    (6, 6),
    (10, 2)
]

algorithms = ["COMP", "LAMP_FWD", "LAMP_REV", "LAMP_PHYS", "EWMP"]
sim_time = 2000

total_runs = len(workloads) * len(algorithms)
current_run = 0

print(f"Starting Phase 2.2 Asymmetric Research Matrix: {total_runs} simulations total.")
print(f"Workloads: {workloads}")
print(f"Algorithms: {algorithms}")
print(f"Target CSV: {CSV_PATH}")
print(f"Target Logs: {RAW_LOGS_DIR}")
print("=" * 80)

# Initialize CSV header
with open(CSV_PATH, "w", encoding="utf-8") as f:
    f.write(CSV_HEADER)

csv_rows = []

for w0, w1 in workloads:
    workload_str = f"{w0}_{w1}"
    apps = w0 + w1
    for algo in algorithms:
        current_run += 1
        log_filename = f"{algo}_w{workload_str}.log"
        log_filepath = os.path.join(RAW_LOGS_DIR, log_filename)

        cmd = [
            JAVA_BIN,
            "-cp", CLASSPATH,
            MAIN_CLASS,
            algo,
            str(w0),
            str(w1),
            str(sim_time)
        ]

        print(f"[{current_run}/{total_runs}] Running {algo} | Workload=[{w0}, {w1}] | Total Apps={apps} ...", end=" ", flush=True)

        try:
            proc = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=240
            )

            output = (proc.stdout or "") + "\n" + (proc.stderr or "")
            with open(log_filepath, "w", encoding="utf-8") as f:
                f.write(output)

            csv_match = re.search(r"ASYM_CSV_ROW:(.*)", output)
            if csv_match:
                row = csv_match.group(1).strip()
                csv_rows.append(row)
                with open(CSV_PATH, "a", encoding="utf-8") as f:
                    f.write(row + "\n")
                parts = row.split(",")
                loop_delay = parts[3]
                status = parts[15]
                loc = parts[8]
                peer = parts[9]
                prx = parts[10]
                cld = parts[11]
                tot_sys = parts[14]
                print(f"{status} (Delay: {loop_delay} ticks | Analyzers: [Local={loc}, Peer={peer}, Proxy={prx}, Cloud={cld}] | Total System: {tot_sys})")
            else:
                err_snip = proc.stderr.strip()[:80] if proc.stderr else "No ASYM_CSV_ROW"
                fail_row = f"{algo},{workload_str},{apps},N/A,0.0,0.0,0.0,0.0,0,0,0,0,0,0,0,FAILED"
                csv_rows.append(fail_row)
                with open(CSV_PATH, "a", encoding="utf-8") as f:
                    f.write(fail_row + "\n")
                print(f"FAILED ({err_snip})")

        except subprocess.TimeoutExpired as te:
            partial_output = (te.stdout or "") + "\n" + (te.stderr or "") + "\n[PROCESS KILLED DUE TO TIMEOUT > 240s]"
            with open(log_filepath, "w", encoding="utf-8") as f:
                f.write(partial_output)
            timeout_row = f"{algo},{workload_str},{apps},N/A,0.0,0.0,0.0,0.0,0,0,0,0,0,0,0,TIMEOUT"
            csv_rows.append(timeout_row)
            with open(CSV_PATH, "a", encoding="utf-8") as f:
                f.write(timeout_row + "\n")
            print("TIMEOUT (>240s)")
        except Exception as e:
            err_row = f"{algo},{workload_str},{apps},N/A,0.0,0.0,0.0,0.0,0,0,0,0,0,0,0,ERROR"
            csv_rows.append(err_row)
            with open(CSV_PATH, "a", encoding="utf-8") as f:
                f.write(err_row + "\n")
            print(f"ERROR ({e})")

print("=" * 80)
print(f"Phase 2.2 execution completed. Results saved to: {CSV_PATH}")
