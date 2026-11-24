# DEMONSTRATION COMPARISON REPORT
## Cross-Algorithm Evaluation on Controlled Demonstration Workload (2 Gateways × 4 Mobiles, $N=8$)

**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 23, 2026  
**Status:** ALL 4 DEMONSTRATION RUNS EXECUTED & VALIDATED  
**Output Directory:** [demonstration_results/](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/demonstration_results/)  
**Integrity Audit:** [DEMO_INTEGRITY_AUDIT_REPORT.md](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/DEMO_INTEGRITY_AUDIT_REPORT.md)  

---

## 1. Executive Summary

This report presents the controlled empirical comparison of all four module placement algorithms executed individually on the identical baseline configuration:
- **Workload:** 2 Gateways $\times$ 4 Mobiles per Gateway ($N = 8$ Applications, $3N = 24$ Modules)
- **Algorithms:** `COMP` (Cloud-Only), `LAMP` (Proposed), `EWMP` (Energy-Weight), and `LBMP_PURE` (Taneja & Davy 2017)
- **Simulation Duration:** 2,000 discrete simulation ticks
- **Execution Platform:** Eclipse JustJ OpenJDK Hotspot 64-Bit Server VM `21.0.6+7-LTS` / iFogSim2 / CloudSim 7

### Key Findings
1. **$100\%$ Process & Loop Completion:** All 4 algorithm runners executed cleanly with exit code `0` in under $2.5\text{ seconds}$ each. All 4 algorithms achieved $100\%$ loop completion ($8 / 8$ loops completed).
2. **Strict $3N = 24$ Invariant:** In every run, exactly 24 application modules were planned, instantiated, and verified.
3. **Algorithmic Equivalence at $M=4$:** As proven theoretically in Phase 3.4 and empirically in Phase 3.6, when mobile density equals gateway analyzer capacity ($M=4$), `LAMP`, `EWMP`, and `LBMP_PURE` converge on the **identical optimal placement plan** ($8$ local analyzers, $0$ peer offloading, $0$ proxy, $8$ cloud storage).
4. **Fog Performance Advantages over `COMP`:** All three fog-enabled algorithms reduced loop delay by **$82.41\%$** ($5.68\times$ speedup), cloud cost by **$73.02\%$**, and network bandwidth by **$21.72\%$** relative to cloud-only execution (`COMP`).

---

## 2. Master Demonstration Comparative Results Table

| Metric | `COMP` (Cloud-Only) | `LAMP` (Proposed) | `EWMP` (Energy-Weight) | `LBMP_PURE` (Taneja & Davy) |
| :--- | :---: | :---: | :---: | :---: |
| **Runner Entry Point** | `HealthcareSimulationRunner` | `HealthcareSimulationRunner` | `HealthcareSimulationRunner` | `BaselineSimulationRunner` |
| **Process Exit Code** | **`0`** | **`0`** | **`0`** | **`0`** |
| **Execution Wall Time** | $2.34\text{ s}$ | $2.01\text{ s}$ | $1.71\text{ s}$ | $1.92\text{ s}$ |
| **Simulation Outcome** | **`SUCCESS`** | **`SUCCESS`** | **`SUCCESS`** | **`SUCCESS`** |
| **Loop Completion Rate** | **$8 / 8$ ($100\%$)** | **$8 / 8$ ($100\%$)** | **$8 / 8$ ($100\%$)** | **$8 / 8$ ($100\%$)** |
| **Total Completed Executions** | 2,160 | 2,946 | 2,946 | 2,946 |
| **Average Loop Delay** | **$408.8623\text{ ticks}$** | **$71.9300\text{ ticks}$** | **$71.9300\text{ ticks}$** | **$71.9300\text{ ticks}$** |
| **Delay Reduction vs COMP** | Baseline ($1.00\times$) | **$-82.41\%$ ($5.68\times$)** | **$-82.41\%$ ($5.68\times$)** | **$-82.41\%$ ($5.68\times$)** |
| **Cloud Energy Consumption** | $2,819,168.88\text{ J}$ | $2,705,869.44\text{ J}$ | $2,705,869.44\text{ J}$ | $2,705,869.44\text{ J}$ |
| **Fog Energy Consumption** | $1,894,337.77\text{ J}$ | $1,995,408.15\text{ J}$ | $1,995,408.15\text{ J}$ | $1,995,408.15\text{ J}$ |
| **Total System Energy** | $4,713,506.66\text{ J}$ | $4,701,277.58\text{ J}$ | $4,701,277.58\text{ J}$ | $4,701,277.58\text{ J}$ |
| **Cloud Infrastructure Cost** | $\$219,986.26$ | **$\$59,359.20$** | **$\$59,359.20$** | **$\$59,359.20$** |
| **Cost Savings vs COMP** | Baseline ($0.0\%$) | **$-73.02\%$** | **$-73.02\%$** | **$-73.02\%$** |
| **Total Network Usage** | $432,651.50$ | **$338,677.00$** | **$338,677.00$** | **$338,677.00$** |
| **Network Reduction vs COMP**| Baseline ($0.0\%$) | **$-21.72\%$** | **$-21.72\%$** | **$-21.72\%$** |
| **Planned Modules (Fog : Cloud)**| 8 : 16 | 16 : 8 | 16 : 8 | 16 : 8 |
| **Total Instantiated Modules**| **24 (Strict $3N$)** | **24 (Strict $3N$)** | **24 (Strict $3N$)** | **24 (Strict $3N$)** |

---

## 3. Placement Distribution by Device & Hierarchy Tier

The detailed breakdown of module placement illustrates the core architectural divergence between cloud-only and fog-enabled strategies:

| Device / Tier | Hardware Specs | `COMP` Placements | `LAMP` Placements | `EWMP` Placements | `LBMP_PURE` Placements |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mobile Tier** (`m-0-x`, `m-1-x`) | $1,000\text{ MIPS}, 1\text{ GB}$ | 8 `Interface` | 8 `Interface` | 8 `Interface` | 8 `Interface` |
| **Local Gateway `d-0`** | $2,800\text{ MIPS}, 4\text{ GB}$ | $0$ modules | 4 `Sensor_Analyzer` | 4 `Sensor_Analyzer` | 4 `Sensor_Analyzer` |
| **Local Gateway `d-1`** | $2,800\text{ MIPS}, 4\text{ GB}$ | $0$ modules | 4 `Sensor_Analyzer` | 4 `Sensor_Analyzer` | 4 `Sensor_Analyzer` |
| **Regional Proxy** (`proxy-server`) | $2,800\text{ MIPS}, 4\text{ GB}$ | $0$ modules | $0$ modules | $0$ modules | $0$ modules |
| **Cloud Data Center** (`cloud`) | $44,800\text{ MIPS}, 40\text{ GB}$ | 8 `Sensor_Analyzer`<br>8 `Cloud_Storage` | 8 `Cloud_Storage` | 8 `Cloud_Storage` | 8 `Cloud_Storage` |
| **Total Modules by Location** | — | **Fog: 8 \| Cloud: 16** | **Fog: 16 \| Cloud: 8** | **Fog: 16 \| Cloud: 8** | **Fog: 16 \| Cloud: 8** |

### Locality & Convergence Dynamics:
- In `COMP`, all 8 `Sensor_Analyzer` modules reside in the Cloud. Every sensor tuple must cross the gateway, proxy, and WAN uplink, yielding high loop delay ($408.86$ ticks).
- In `LAMP`, `EWMP`, and `LBMP_PURE`, each gateway has capacity for exactly 4 analyzers ($2,800\text{ MIPS} / 700\text{ MIPS} = 4$). Since each gateway originates exactly 4 mobiles, all 8 analyzers are absorbed locally on `d-0` and `d-1`.
- **Peer Gateway Placements = 0:** No inter-gateway traffic traverses the proxy switch, resulting in optimal local processing and identical performance across all three fog algorithms.

---

## 4. Reconciliation of Structured Outputs with Raw Logs

For every demonstration run, the structured console banner and CSV record were reconciled against their respective raw log file:

### 4.1 `COMP`
- **Raw Log:** [demonstration_results/COMP_demo_gw2_m4.log](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/demonstration_results/COMP_demo_gw2_m4.log)
- **Reconciliation:**
  `CSV_ROW:COMP,2,4,8,408.8623,2819168.8813,1894337.7743,219986.262141,432651.5000,8,16,SUCCESS`
  Matched console banner metrics with zero discrepancies.

### 4.2 `LAMP`
- **Raw Log:** [demonstration_results/LAMP_demo_gw2_m4.log](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/demonstration_results/LAMP_demo_gw2_m4.log)
- **Reconciliation:**
  `CSV_ROW:LAMP,2,4,8,71.9300,2705869.4357,1995408.1492,59359.200000,338677.0000,16,8,SUCCESS`
  Matched console banner metrics with zero discrepancies.

### 4.3 `EWMP`
- **Raw Log:** [demonstration_results/EWMP_demo_gw2_m4.log](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/demonstration_results/EWMP_demo_gw2_m4.log)
- **Reconciliation:**
  `CSV_ROW:EWMP,2,4,8,71.9300,2705869.4357,1995408.1492,59359.200000,338677.0000,16,8,SUCCESS`
  Matched console banner metrics with zero discrepancies.

### 4.4 `LBMP_PURE`
- **Raw Log:** [demonstration_results/LBMP_demo_gw2_m4.log](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/demonstration_results/LBMP_demo_gw2_m4.log)
- **Reconciliation:**
  `LBMP_SYMM_CSV_ROW:LBMP_PURE,2,4,8,71.9300,2705869.4357,1995408.1492,59359.200000,338677.0000,8,0,0,0,0,16,8,24,24,0,8,0,0.0,0,0,8,SUCCESS`
  Matched candidate ledger, VM instantiation tracking (24/24), binary search count (8), and structured metrics with zero discrepancies.

---

## 5. Methodological & Metric Classification Notes

1. **Simulator-Reported Composite Time vs. Physical Latency:**
   - Loop delay is expressed in **simulation ticks** (discrete-event time units encompassing CPU execution scheduling and link transit delays), NOT physical network milliseconds (RTT).
2. **Model-Derived Energy and Cost:**
   - Cloud cost and energy values are linear analytical CloudSim model calculations derived from static parameter configurations, representing relative architectural load rather than commercial utility billing or hardware wattmeter readings.
3. **Execution vs. Loop Completion Distinction:**
   - In all 4 demonstration runs, process execution succeeded (exit code `0`) AND application loop completion succeeded ($100\%$ loops completed).

---

## 6. Historical Integrity & Cryptographic Proof

As documented in [DEMO_INTEGRITY_AUDIT_REPORT.md](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/DEMO_INTEGRITY_AUDIT_REPORT.md), the earlier exit code `1` during verification was a false-positive caused by an invalid invocation of `git` in a non-git directory.

Recalculated SHA-256 hashes confirm bit-for-bit immutability:

| Historical Dataset / Source File | Canonical SHA-256 Checksum | Verified Post-Demonstration SHA-256 | Status |
| :--- | :--- | :--- | :---: |
| `results\lamp_reproduction_results_phase1_historical.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | **MATCH (100% UNTOUCHED)** |
| `results\lamp_reproduction_results.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | **MATCH (100% UNTOUCHED)** |
| `results\lamp_reproduction_results_phase2.csv` | `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284` | `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284` | **MATCH (100% UNTOUCHED)** |
| `results\asymmetric_validation_results.csv` | `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30` | `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30` | **MATCH (100% UNTOUCHED)** |
| `ModulePlacementLBMP.java` | `DBD48E4B9D25B0033F1228562F9A5B54C10A20E7554EFD3DA9A69E17D049C044` | `DBD48E4B9D25B0033F1228562F9A5B54C10A20E7554EFD3DA9A69E17D049C044` | **MATCH (FROZEN SOURCE)** |
| `BaselineSimulationRunner.java` | `09F1FEB0C3CFDAA6A1B809F20FA65946BFA20C85C309AAB79F11A30CA33E299A` | `09F1FEB0C3CFDAA6A1B809F20FA65946BFA20C85C309AAB79F11A30CA33E299A` | **MATCH (FROZEN SOURCE)** |
| `ModulePlacementLBMPTest.java` | `CD1A1E58B14BC01AC283211491D30A2B68C84E3252AA24B00192CD064EE10885` | `CD1A1E58B14BC01AC283211491D30A2B68C84E3252AA24B00192CD064EE10885` | **MATCH (FROZEN SOURCE)** |

---

## 7. Manual Reproduction Commands

To replicate any of the four demonstration runs manually from PowerShell:

```powershell
Set-Location -Path "C:\Users\91630\Desktop\Code Playground\LAMP"

# 1. Run COMP (Cloud-Only)
& ".\eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe" `
    -cp "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*" `
    org.fog.lamp.simulation.HealthcareSimulationRunner COMP 2 4 2000

# 2. Run LAMP (Proposed)
& ".\eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe" `
    -cp "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*" `
    org.fog.lamp.simulation.HealthcareSimulationRunner LAMP 2 4 2000

# 3. Run EWMP (Energy-Weight)
& ".\eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe" `
    -cp "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*" `
    org.fog.lamp.simulation.HealthcareSimulationRunner EWMP 2 4 2000

# 4. Run LBMP_PURE (Taneja & Davy Baseline)
& ".\eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe" `
    -cp "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*" `
    org.fog.lamp.baselines.BaselineSimulationRunner SYMMETRIC 2 4 2000
```
