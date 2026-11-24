# PHASE 3.6: `LBMP_PURE` BASELINE SIMULATION VALIDATION REPORT

**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 23, 2026  
**Status:** BENCHMARK EXECUTION COMPLETED & CRYPTOGRAPHICALLY VALIDATED (16/16 RUNS)  
**Governing Contract:** [PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md](PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md) (Rev. 2)  
**Implementation Report:** [PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md](PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md)  
**Execution Readiness Report:** [PHASE_3_6_EXECUTION_READINESS_REPORT.md](PHASE_3_6_EXECUTION_READINESS_REPORT.md) (Rev. 3)  
**Execution Wrapper:** [run_lbmp_experiments.ps1](run_lbmp_experiments.ps1) (Rev. 3)  
**Toolchain:** Eclipse JustJ OpenJDK Hotspot 64-Bit Server VM `21.0.6+7-LTS` / iFogSim2 / CloudSim 7  

---

## 1. Executive Summary

Following explicit user authorization, the complete **Phase 3.6 `LBMP_PURE` Benchmark Matrix** was executed sequentially using the hardened production wrapper [run_lbmp_experiments.ps1](run_lbmp_experiments.ps1).

### Key Execution Highlights
1. **16 Configurations Executed Sequentially:** All 12 symmetric configurations (Phase 2 matrix: 2, 3, 4 gateways $\times$ 2, 4, 6, 8 mobiles) and all 4 asymmetric configurations (Phase 2.2 matrix: `w2_6`, `w6_2`, `w6_6`, `w10_2`) ran to completion.
2. **Zero Harness Crashes / Zero Process Timeouts:**
   - **Process Exit Code:** `0` across all 16 runs ($100\%$).
   - **Watchdog Timeouts:** `0` (no run exceeded the 300-second watchdog limit).
   - **Row Extraction:** `16 / 16` matching rows extracted cleanly from `stdout`.
3. **Simulation Outcomes:**
   - **`SUCCESS`:** **`3` runs** (S02 `gw2_m4`, S06 `gw3_m4`, S10 `gw4_m4`). In all three workloads where $M=4$, **$100\%$ of application loops completed**.
   - **`PARTIAL_COMPLETION`:** **`13` runs** ($0 < \text{CompletedLoops} < N$), strictly matching the queueing and tuple contention dynamics documented in Phase 2 for `COMP`, `LAMP`, and `EWMP`.
   - **`TIMEOUT` / `EXECUTION_ERROR`:** **`0` runs**.
4. **Strict Invariant Adherence ($3N$ System Modules & 100% VM Success):**
   - In every configuration, planned system modules strictly equaled $3 \times N$.
   - **CloudSim VM Instantiation:** $100\%$ success across all scales ($12$ to $96$ VMs), with **$0$ VM instantiation failures**.
   - **Placement Reconciliation:** Local GW + Peer GW + Proxy + Cloud Normal + Cloud Fallback strictly reconciled to $N$ across all 16 runs.
5. **Algorithmic Search & Fallback Integrity:**
   - **Binary Search:** $100\%$ utilization (`BinarySearchCount == TotalApplications`).
   - **Linear Fallbacks:** `0` across all runs (monotonic capacity ordering was preserved dynamically).
   - **Cloud Fallback Telemetry:** `CloudFallback == 0`, cumulative fallback demand = $0.0\text{ MIPS}$, $0\text{ MB}$ RAM, $0\text{ Host BW}$ across all runs.
6. **Zero Historical Mutation:** Pre-flight and post-flight cryptographic audits confirmed that all 4 historical CSV datasets and 66 raw logs remain bit-for-bit untouched.

---

## 2. Complete Run-by-Run Benchmark Results Table (16 Runs)

### 2.1 Suite A: 12 Symmetric Runs (Phase 2 Matrix)

| Run ID | Workload | $G$ | $M$ | Apps ($N$) | Loop Delay (ticks) | Loops Done / $N$ | Cloud Energy (J) | Fog Energy (J) | Cloud Cost ($) | Network Usage | Fog : Cloud Modules | VM Succ / Fail | Status | Duration |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **S01** | `gw2_m2` | 2 | 2 | 4 | **9.4690** | 2 / 4 | 2,821,991.87 | 1,201,944.14 | 223,988.48 | 105,004.00 | 8 : 4 | 12 / 0 | `PARTIAL_COMPLETION` | 34.5s |
| **S02** | `gw2_m4` | 2 | 4 | 8 | **71.9300** | 8 / 8 | 2,705,869.44 | 1,995,408.15 | 59,359.20 | 338,677.00 | 16 : 8 | 24 / 0 | **`SUCCESS`** | 37.6s |
| **S03** | `gw2_m6` | 2 | 6 | 12 | **383.6551** | 10 / 12 | 2,721,913.88 | 2,730,994.95 | 82,105.76 | 446,086.00 | 24 : 12 | 36 / 0 | `PARTIAL_COMPLETION` | 38.8s |
| **S04** | `gw2_m8` | 2 | 8 | 16 | **582.5540** | 12 / 16 | 2,931,376.72 | 3,417,285.79 | 379,065.73 | 585,473.50 | 28 : 20 | 48 / 0 | `PARTIAL_COMPLETION` | 51.9s |
| **S05** | `gw3_m2` | 3 | 2 | 6 | **9.4690** | 2 / 6 | 2,826,685.89 | 1,754,984.24 | 230,643.28 | 128,343.00 | 12 : 6 | 18 / 0 | `PARTIAL_COMPLETION` | 29.7s |
| **S06** | `gw3_m4` | 3 | 4 | 12 | **193.7362** | 12 / 12 | 2,725,019.60 | 2,909,020.81 | 86,508.80 | 517,306.50 | 24 : 12 | 36 / 0 | **`SUCCESS`** | 45.7s |
| **S07** | `gw3_m6` | 3 | 6 | 18 | **460.3947** | 12 / 18 | 2,773,002.11 | 3,970,837.90 | 154,534.63 | 615,769.00 | 34 : 20 | 54 / 0 | `PARTIAL_COMPLETION` | 65.8s |
| **S08** | `gw3_m8` | 3 | 8 | 24 | **646.5091** | 16 / 24 | 3,018,697.90 | 5,005,473.13 | 502,862.85 | 841,078.50 | 40 : 32 | 72 / 0 | `PARTIAL_COMPLETION` | 126.4s |
| **S09** | `gw4_m2` | 4 | 2 | 8 | **9.4690** | 2 / 8 | 2,831,379.90 | 2,260,212.94 | 237,298.08 | 151,682.00 | 16 : 8 | 24 / 0 | `PARTIAL_COMPLETION` | 28.0s |
| **S10** | `gw4_m4` | 4 | 4 | 16 | **244.5591** | 16 / 16 | 2,744,296.73 | 3,823,658.98 | 113,838.40 | 692,514.50 | 32 : 16 | 48 / 0 | **`SUCCESS`** | 68.0s |
| **S11** | `gw4_m6` | 4 | 6 | 24 | **478.0775** | 14 / 24 | 2,908,751.37 | 5,211,681.64 | 346,989.28 | 768,377.00 | 44 : 28 | 72 / 0 | `PARTIAL_COMPLETION` | 92.6s |
| **S12** | `gw4_m8` | 4 | 8 | 32 | **667.0621** | 20 / 32 | 3,069,469.53 | 6,593,778.91 | 574,842.88 | 1,088,714.50 | 52 : 44 | 96 / 0 | `PARTIAL_COMPLETION` | 147.7s |

---

### 2.2 Suite B: 4 Asymmetric Runs (Phase 2.2 Matrix)

| Run ID | Workload | $G$ | Mobiles $[M_0, M_1]$ | Apps ($N$) | Loop Delay (ticks) | Loops Done / $N$ | Cloud Energy (J) | Fog Energy (J) | Cloud Cost ($) | Network Usage | Fog : Cloud Modules | VM Succ / Fail | Status | Duration |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **A01** | `w2_6` | 2 | $[2, 6]$ | 8 | **107.2523** | 6 / 8 | 2,713,161.70 | 1,949,157.79 | 69,697.60 | 276,976.50 | 16 : 8 | 24 / 0 | `PARTIAL_COMPLETION` | 1.6s |
| **A02** | `w6_2` | 2 | $[6, 2]$ | 8 | **106.8902** | 6 / 8 | 2,834,438.10 | 1,949,022.20 | 241,633.76 | 277,099.00 | 16 : 8 | 24 / 0 | `PARTIAL_COMPLETION` | 1.5s |
| **A03** | `w6_6` | 2 | $[6, 6]$ | 12 | **383.6551** | 10 / 12 | 2,721,913.88 | 2,730,994.95 | 82,105.76 | 446,086.00 | 24 : 12 | 36 / 0 | `PARTIAL_COMPLETION` | 3.9s |
| **A04** | `w10_2` | 2 | $[10, 2]$ | 12 | **283.9960** | 8 / 12 | 2,733,554.53 | 2,708,529.41 | 98,608.96 | 382,053.00 | 24 : 12 | 36 / 0 | `PARTIAL_COMPLETION` | 35.1s |

---

## 3. Placement Distribution & Locality Analysis

The placement telemetry strictly confirms the **ascending-capacity, locality-blind sorting dynamics** mandated by Taneja & Davy (2017) Algorithms 1–3:

| Run ID | Workload | Total Analyzers ($N$) | Local GW | Peer GW | Proxy Server | Cloud (Normal) | Cloud (Fallback) | Total Fog Analyzers |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **S01** | `gw2_m2` | 4 | 2 | 2 | 0 | 0 | 0 | **4** (All Fog) |
| **S02** | `gw2_m4` | 8 | 8 | 0 | 0 | 0 | 0 | **8** (All Fog) |
| **S03** | `gw2_m6` | 12 | 6 | 2 | 4 | 0 | 0 | **12** (All Fog) |
| **S04** | `gw2_m8` | 16 | 4 | 4 | 4 | 4 | 0 | **12** (Fog full, 4 to Cloud) |
| **S05** | `gw3_m2` | 6 | 2 | 4 | 0 | 0 | 0 | **6** (All Fog) |
| **S06** | `gw3_m4` | 12 | 12 | 0 | 0 | 0 | 0 | **12** (All Fog) |
| **S07** | `gw3_m6` | 18 | 6 | 6 | 4 | 2 | 0 | **16** (Fog full, 2 to Cloud) |
| **S08** | `gw3_m8` | 24 | 4 | 8 | 4 | 8 | 0 | **16** (Fog full, 8 to Cloud) |
| **S09** | `gw4_m2` | 8 | 2 | 6 | 0 | 0 | 0 | **8** (All Fog) |
| **S10** | `gw4_m4` | 16 | 16 | 0 | 0 | 0 | 0 | **16** (All Fog) |
| **S11** | `gw4_m6` | 24 | 6 | 10 | 4 | 4 | 0 | **20** (Fog full, 4 to Cloud) |
| **S12** | `gw4_m8` | 32 | 4 | 12 | 4 | 12 | 0 | **20** (Fog full, 12 to Cloud) |
| **A01** | `w2_6` | 8 | 6 | 2 | 0 | 0 | 0 | **8** (All Fog) |
| **A02** | `w6_2` | 8 | 6 | 2 | 0 | 0 | 0 | **8** (All Fog) |
| **A03** | `w6_6` | 12 | 6 | 2 | 4 | 0 | 0 | **12** (All Fog) |
| **A04** | `w10_2` | 12 | 4 | 4 | 4 | 0 | 0 | **12** (All Fog) |

### Key Architectural Observations:
1. **Fog Capacity Exhaustion Boundary:**
   - For $G=2$, Fog analyzer capacity is $4 \times (2 + 1) = 12$. S01, S02, S03 pack entirely on Fog; S04 ($N=16$) routes exactly $16 - 12 = \mathbf{4}$ analyzers to Cloud.
   - For $G=3$, Fog capacity is $4 \times (3 + 1) = 16$. S05, S06 pack entirely on Fog; S07 routes $18 - 16 = \mathbf{2}$ to Cloud; S08 routes $24 - 16 = \mathbf{8}$ to Cloud.
   - For $G=4$, Fog capacity is $4 \times (4 + 1) = 20$. S09, S10 pack entirely on Fog; S11 routes $24 - 20 = \mathbf{4}$ to Cloud; S12 routes $32 - 20 = \mathbf{12}$ to Cloud.
2. **Locality Blindness Impact:**
   - In S01 ($G=2, M=2$), `d-0` has 4 slots. LBMP packs all 4 analyzers onto `d-0`. Thus, the 2 modules originating from mobile devices under `d-1` are placed on peer gateway `d-0` (`AnalyzerPeerGw = 2`), incurring inter-gateway network propagation.
   - In contrast, in S02 ($G=2, M=4$), each gateway has exactly 4 mobiles, so 4 pack onto `d-0` and 4 pack onto `d-1`, resulting in zero peer-gateway offloading (`AnalyzerLocalGw = 8`, `AnalyzerPeerGw = 0`). This directly explains why S02 achieves $100\%$ completion (`SUCCESS`).

---

## 4. Algorithmic Diagnostics & Telemetry Verification

1. **Monotonicity & Binary Search Verification:**
   - `BinarySearchCount == TotalApplications` across all 16 runs.
   - `LinearFallbackCount == 0` across all 16 runs.
   - Conclusively proves that the dynamic `low = 0` reset and capacity sorting maintained runtime monotonicity across the entire benchmark matrix.
2. **Cloud Fallback Telemetry (`D-3.5-01`):**
   - `CloudFallbackCount == 0` across all 16 runs.
   - Cumulative Fallback Demand: $0.0\text{ MIPS}$, $0\text{ MB}$ RAM, $0\text{ Host BW}$ across all runs.
   - Confirms that Cloud resources ($44,800\text{ MIPS}$, $40,000\text{ MB}$ RAM) comfortably absorbed all overflow modules without analytical ledger deficits or CloudSim provisioning rejections.

---

## 5. Cryptographic Immutability & Safety Audit

Post-run cryptographic checks were performed immediately after matrix completion:

| Historical Dataset | Expected SHA-256 Checksum | Post-Execution SHA-256 Checksum | Integrity Audit |
| :--- | :--- | :--- | :---: |
| `lamp_reproduction_results_phase1_historical.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | **MATCH (100% UNTOUCHED)** |
| `lamp_reproduction_results.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | **MATCH (100% UNTOUCHED)** |
| `lamp_reproduction_results_phase2.csv` | `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284` | `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284` | **MATCH (100% UNTOUCHED)** |
| `asymmetric_validation_results.csv` | `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30` | `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30` | **MATCH (100% UNTOUCHED)** |

- **Java Source Code Checksums:** Unchanged; match Phase 3.5 records bit-for-bit.
- **Historical Raw Logs:** All 66 historical raw logs in `raw_logs/`, `raw_logs_phase2/`, and `raw_logs_asymmetric/` remain bit-for-bit unchanged.

---

## 6. Output Artifacts Directory Structure

All Phase 3.6 execution artifacts have been written exclusively to dedicated paths:

- **Symmetric Benchmark CSV (12 runs):**  
  [lbmp_symmetric_results.csv](results/lbmp_symmetric_results.csv) (26 columns, 12 data rows + header)
- **Asymmetric Benchmark CSV (4 runs):**  
  [lbmp_asymmetric_results.csv](results/lbmp_asymmetric_results.csv) (25 columns, 4 data rows + header)
- **Execution Summary Log:**  
  [lbmp_execution_summary.txt](results/lbmp_execution_summary.txt) (Start/End times, durations, exit codes, outcomes)
- **Dedicated Raw Console Logs (16 logs):**  
  - Symmetric: `results/raw_logs_lbmp_symmetric/LBMP_gw*.log` (12 files)
  - Asymmetric: `results/raw_logs_lbmp_asymmetric/LBMP_w*.log` (4 files)

---

## 7. Conclusion & Readiness for Phase 3.7

The Phase 3.6 live benchmark matrix is **$100\%$ completed, cryptographically verified, and fully archived**. 

All empirical data for `LBMP_PURE` are now safely collected alongside historical baselines for `COMP`, `LAMP`, and `EWMP`, enabling rigorous, fair, and transparent comparative evaluation in **Phase 3.7**.
