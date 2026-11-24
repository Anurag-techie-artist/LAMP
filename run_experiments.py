import os
import subprocess
import sys
import re

JAVA_BIN = r"eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe"
CLASSPATH = r"iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*"
MAIN_CLASS = "org.fog.lamp.simulation.HealthcareSimulationRunner"

RAW_LOGS_DIR = os.path.join("results", "raw_logs")
CSV_PATH = os.path.join("results", "lamp_reproduction_results.csv")
os.makedirs(RAW_LOGS_DIR, exist_ok=True)

CSV_HEADER = "algorithm,gateway_count,mobiles_per_gateway,application_count,loop_delay_ms,cloud_energy_j,fog_energy_j,cloud_cost,network_usage,fog_placements,cloud_placements,status\n"

algorithms = ["COMP", "LAMP", "EWMP"]
gateways_list = [2, 3, 4]
mobiles_list = [2, 4, 6, 8]
sim_time = 2000

total_runs = len(algorithms) * len(gateways_list) * len(mobiles_list)
current_run = 0

print(f"Starting execution of full research matrix: {total_runs} simulations total.")
print(f"Algorithms: {algorithms}")
print(f"Gateways: {gateways_list}")
print(f"Mobiles per GW: {mobiles_list}")
print(f"Simulation Duration: {sim_time} time units")
print("=" * 80)

csv_rows = []

for algo in algorithms:
    for gw in gateways_list:
        for mob in mobiles_list:
            current_run += 1
            apps = gw * mob
            log_filename = f"{algo}_gw{gw}_m{mob}.log"
            log_filepath = os.path.join(RAW_LOGS_DIR, log_filename)

            cmd = [
                JAVA_BIN,
                "-cp", CLASSPATH,
                MAIN_CLASS,
                algo,
                str(gw),
                str(mob),
                str(sim_time)
            ]

            print(f"[{current_run}/{total_runs}] Running {algo} | GW={gw} | Mobiles/GW={mob} | Apps={apps} ...", end=" ", flush=True)

            try:
                proc = subprocess.run(
                    cmd,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    timeout=180
                )

                output = proc.stdout + "\n" + proc.stderr
                with open(log_filepath, "w", encoding="utf-8") as f:
                    f.write(output)

                csv_match = re.search(r"CSV_ROW:(.*)", output)
                if csv_match:
                    row = csv_match.group(1).strip()
                    csv_rows.append(row)
                    # Extract loop delay for progress logging
                    parts = row.split(",")
                    loop_delay = parts[4] if len(parts) > 4 else "N/A"
                    print(f"SUCCESS (Loop Delay: {float(loop_delay):.2f} ms)")
                else:
                    status = "FAILED"
                    err_snippet = proc.stderr.strip()[:100] if proc.stderr else "No CSV_ROW found"
                    print(f"FAILED ({err_snippet})")
                    csv_rows.append(f"{algo},{gw},{mob},{apps},0.0,0.0,0.0,0.0,0.0,0,0,FAILED")

            except subprocess.TimeoutExpired:
                print("TIMEOUT (>180s)")
                csv_rows.append(f"{algo},{gw},{mob},{apps},0.0,0.0,0.0,0.0,0.0,0,0,TIMEOUT")
            except Exception as e:
                print(f"ERROR ({e})")
                csv_rows.append(f"{algo},{gw},{mob},{apps},0.0,0.0,0.0,0.0,0.0,0,0,ERROR")

with open(CSV_PATH, "w", encoding="utf-8") as f:
    f.write(CSV_HEADER)
    for r in csv_rows:
        f.write(r + "\n")

print("=" * 80)
print(f"Full matrix execution completed. Results saved to: {CSV_PATH}")
