import pandas as pd
import numpy as np

df = pd.read_csv("results/lamp_reproduction_results.csv")

print("=" * 90)
print("LAMP RESEARCH REPRODUCTION - EXPERIMENTAL MATRIX SUMMARY (36 RUNS)")
print("=" * 90)

print(df.to_string(index=False))

print("\n" + "=" * 90)
print("ALGORITHM COMPARISON BY APPLICATION LOAD")
print("=" * 90)

# Pivot table for Loop Delay
pivot_delay = df.pivot_table(index=["gateway_count", "mobiles_per_gateway", "application_count"], columns="algorithm", values="loop_delay_ms")
print("\n--- Loop Delay (ms) ---")
print(pivot_delay.round(2))

# Pivot table for Cloud Cost
pivot_cost = df.pivot_table(index=["gateway_count", "mobiles_per_gateway", "application_count"], columns="algorithm", values="cloud_cost")
print("\n--- Cloud Cost ---")
print(pivot_cost.round(2))

# Pivot table for Cloud Energy
pivot_cloud_e = df.pivot_table(index=["gateway_count", "mobiles_per_gateway", "application_count"], columns="algorithm", values="cloud_energy_j")
print("\n--- Cloud Energy (J) ---")
print(pivot_cloud_e.round(2))

# Pivot table for Fog Energy
pivot_fog_e = df.pivot_table(index=["gateway_count", "mobiles_per_gateway", "application_count"], columns="algorithm", values="fog_energy_j")
print("\n--- Fog Energy (J) ---")
print(pivot_fog_e.round(2))

# Pivot table for Network Usage
pivot_net = df.pivot_table(index=["gateway_count", "mobiles_per_gateway", "application_count"], columns="algorithm", values="network_usage")
print("\n--- Network Usage ---")
print(pivot_net.round(2))

# Pivot table for Module Placements
pivot_fog_plc = df.pivot_table(index=["gateway_count", "mobiles_per_gateway", "application_count"], columns="algorithm", values="fog_placements")
print("\n--- Fog Placements ---")
print(pivot_fog_plc)

pivot_cloud_plc = df.pivot_table(index=["gateway_count", "mobiles_per_gateway", "application_count"], columns="algorithm", values="cloud_placements")
print("\n--- Cloud Placements ---")
print(pivot_cloud_plc)
