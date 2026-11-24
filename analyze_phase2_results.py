import os
import pandas as pd

phase1_csv = os.path.join("results", "lamp_reproduction_results_phase1_historical.csv")
phase2_csv = os.path.join("results", "lamp_reproduction_results_phase2.csv")

df1 = pd.read_csv(phase1_csv)
df2 = pd.read_csv(phase2_csv)

print("=== PHASE 1 HISTORICAL ===")
print(df1[['algorithm', 'gateway_count', 'mobiles_per_gateway', 'application_count', 'loop_delay_ms', 'fog_placements', 'cloud_placements', 'status']].to_string())

print("\n=== PHASE 2 CORRECTED ===")
print(df2[['algorithm', 'gateway_count', 'mobiles_per_gateway', 'application_count', 'loop_delay_sim_ticks', 'fog_placements', 'cloud_placements', 'status']].to_string())
