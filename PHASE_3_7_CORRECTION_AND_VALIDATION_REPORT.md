# PHASE 3.7: CORRECTION AND VALIDATION AUDIT REPORT
## Targeted Audit, Empirical Correction, and Cryptographic Verification of the Comparative Evaluation Report

**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 23, 2026  
**Status:** COMPLETE & FULLY RECONCILED  
**Primary Auditor:** Autonomous Antigravity Execution Environment  
**Governing Documents:**
- Corrected Evaluation Report: [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md)
- Simulation Validation Report: [PHASE_3_6_SIMULATION_VALIDATION_REPORT.md](PHASE_3_6_SIMULATION_VALIDATION_REPORT.md)
- LBMP Design Specification: [PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md](PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md) (Rev. 2)
- Post-Demonstration Audit: [DEMO_INTEGRITY_AUDIT_REPORT.md](DEMO_INTEGRITY_AUDIT_REPORT.md)
- Master Document Index: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

---

## 1. Executive Summary

This audit report documents the targeted review, empirical reconciliation, and mathematical correction of [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md).

The audit verified all empirical metrics, tables, capacity derivations, algorithmic designations, and causal assertions against primary raw console logs, historical CSV datasets, and frozen Java source code. All eight identified deficiencies have been rigorously corrected in place without modifying any historical data files, without re-running simulations, and without altering the frozen simulation engine or baseline implementations.

### Summary of Audit Achievements
1. **Zero Data Fabrication for Timeouts:** All unproduced metrics for timed-out simulations (`COMP` at `G3_M8` and `G4_M8`) were replaced from fabricated `$0.00`, `0.0`, and `0 : 0` placeholders to strict **`N/A`** designations.
2. **Exhaustive Exact Loop Accounting ($k / N$):** Reconciled all partial-completion placeholders (`PARTIAL / 24`, `PARTIAL / 32`, `PARTIAL / 12`) against primary log lines, inserting exact completion denominators (`20/24`, `22/24`, `24/32`, `10/12`) adjacent to loop delays.
3. **Rigorous Capacity Derivation:** Replaced inaccurate capacity text with the exact mathematical derivation of $\mathbf{4\text{ analyzers per gateway}}$ based on the approved $700.0\text{ MIPS}$ steady-state demand ($\lambda = 1/5.0\text{ s} = 0.2\text{ tuples/second}$, $L_{\text{cpu}} = 3,500\text{ MI/tuple}$, $D_{\text{cpu}} = 0.2 \times 3,500 = 700\text{ MI/second} = 700\text{ MIPS}$) versus $2,800.0\text{ MIPS}$ gateway capacity, eliminating confusion with the $1,000\text{ units}$ CloudSim VM-provisioner bandwidth specification and explicitly distinguishing physical seconds from discrete simulation ticks.
4. **Epistemological Discipline on Causal Assertions:** Replaced unqualified claims of proxy queue contention causation with precise delineations: verified empirical observation, physical routing path architecture, and the proxy link queueing working hypothesis.
5. **Algorithm Variant Clarity:** Explicitly distinguished the canonical forward-traversing `LAMP` / `LAMP_FWD` baseline from exploratory sensitivity variants (`LAMP_REV`, `LAMP_PHYS`).
6. **Methodological Restrictions on Conditional Delays:** Added prominent warnings prohibiting the comparison of conditional delays ($\mathbb{E}[\text{Delay} \mid \text{Completed}]$) across unequal completion rates as speedups.
7. **Formal Metric Semantics:** Provided formal definitions for simulator composite time units, linear model-derived energy/cost, and byte-transfer network accounting.
8. **Consistent Positive Formatting:** Standardized performance reduction headers to positive percentages ($82.41\%$, $73.02\%$, etc.) with explicit delta notation for energy change.

---

## 2. Exhaustive Log-by-Log Empirical Reconciliation

All historical logs and CSV rows referenced in the comparative evaluation were audited against their primary disk files:

### 2.1 Primary Log Evidence for Partial Completions

| Simulation Configuration | Algorithm | Primary Log File | Exact Console Log Line | Verified Value | Previous Placeholder | Corrected Report Entry |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| Symmetric `gw3_m8` | `LAMP` | `results/raw_logs_phase2/LAMP_gw3_m8.log` | Line 337: `Loops Completed: 20 / 24` | 20 / 24 (83.3%) | `PARTIAL / 24` | **`20 / 24 (83.3%)`** |
| Symmetric `gw4_m6` | `LAMP` | `results/raw_logs_phase2/LAMP_gw4_m6.log` | Line 344: `Loops Completed: 22 / 24` | 22 / 24 (91.7%) | `PARTIAL / 24` | **`22 / 24 (91.7%)`** |
| Symmetric `gw4_m8` | `LAMP` | `results/raw_logs_phase2/LAMP_gw4_m8.log` | Line 430: `Loops Completed: 24 / 32` | 24 / 32 (75.0%) | `PARTIAL / 32` | **`24 / 32 (75.0%)`** |
| Asymmetric `w10_2` | `LAMP_FWD` | `results/raw_logs_asymmetric/LAMP_FWD_w10_2.log` | Line 161: `Loops Completed: 10 / 12` | 10 / 12 (83.3%) | `PARTIAL / 12` | **`10 / 12 (83.3%)`** |
| Asymmetric `w10_2` | `LAMP_REV` | `results/raw_logs_asymmetric/LAMP_REV_w10_2.log` | Line 161: `Loops Completed: 10 / 12` | 10 / 12 (83.3%) | `PARTIAL / 12` | **`10 / 12 (83.3%)`** |
| Symmetric `gw3_m8` | `COMP` | *(Timed out before file write)* | Exit code 143 (SIGTERM Timeout) | `TIMEOUT` | `$0.00 / 0.0 / 0:0` | **`N/A / N/A / N/A`** |
| Symmetric `gw4_m8` | `COMP` | *(Timed out before file write)* | Exit code 143 (SIGTERM Timeout) | `TIMEOUT` | `$0.00 / 0.0 / 0:0` | **`N/A / N/A / N/A`** |

---

## 3. Exhaustive Itemized List of Corrections

### Item 1: Timeout Metrics Representation
- **Problem:** In Section 4 (Master Symmetric Table), `COMP` at `G3_M8` and `G4_M8` displayed Cloud Cost as `$0.00`, Network Usage as `0.0`, and Placements as `0 : 0`. Because these simulations were terminated by the watchdog timeout at 2,000 ticks, CloudSim never emitted completion statistics. Representing unproduced metrics as zero implies zero cost or zero bandwidth, which is empirically false.
- **Correction Applied:** Replaced `$0.00`, `0.0`, and `0 : 0` with **`N/A`** across both rows. Added explicit semantic rule in Section 3.4 mandating `N/A` for all unproduced metrics.
- **Location:** [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:130](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L130), [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:146](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L146).

### Item 2: Explicit Loop Completion Ratios ($k / N$)
- **Problem:** Several partial-completion rows in Section 4 and Section 6 contained qualitative strings (`PARTIAL / 24`, `PARTIAL / 32`, `PARTIAL / 12`) without reporting exact completed loop counts or percentages.
- **Correction Applied:** Audited primary console logs and inserted exact fractions and percentages:
  - `LAMP` at `G3_M8`: `20 / 24 (83.3%)` (delay $613.9435^*$)
  - `LAMP` at `G4_M6`: `22 / 24 (91.7%)` (delay $447.3214^*$)
  - `LAMP` at `G4_M8`: `24 / 32 (75.0%)` (delay $614.8137^*$)
  - `LAMP_FWD` at `w10_2`: `10 / 12 (83.3%)` (delay $310.2287^*$)
  - `LAMP_REV` at `w10_2`: `10 / 12 (83.3%)` (delay $306.5562^*$)
  - Standardized all successful runs with `(100%)` for visual consistency.
- **Location:** [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:102-149](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L102-L149), [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:228-251](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L228-L251).

### Item 3: Resource Capacity Derivation & Bandwidth Disambiguation
- **Problem:** Section 5.1 incorrectly stated: *"gateway MIPS 2,800 / 1,000 = 2 or 4 based on workload"*, confusing CloudSim VM-provisioner bandwidth demand ($1,000\text{ units}$) with computational demand.
- **Correction Applied:** Replaced with the exact mathematical capacity derivation:
  - Configured sensor inter-arrival period: $T_{\text{sensor}} = 5.0\text{ seconds}$ (`BaselineSimulationRunner.java:44`, `HealthcareTopologyFactory.java:94-95`).
  - Sensor tuple generation rate: $\lambda = 1 / T_{\text{sensor}} = 1 / 5.0\text{ s} = 0.2\text{ tuples/second } (0.2\text{ Hz})$.
  - Tuple processing work: $L_{\text{cpu}} = 3,500.0\text{ MI/tuple}$ (`HealthcareBSNApplication.java:81`).
  - Steady-state module computational demand: $D_{\text{cpu}} = \lambda \cdot L_{\text{cpu}} = 0.2\text{ tuples/second} \times 3,500\text{ MI/tuple} = 700.0\text{ MI/second} = \mathbf{700.0\text{ MIPS}}$ (`ModulePlacementLAMP.java:46`, `BaselineSimulationRunner.java:182`).
  - Fog gateway CPU capacity: $C_{\text{cpu}} = 2,800.0\text{ MIPS}$.
  - Binding capacity: $\lfloor 2,800.0 / 700.0 \rfloor = \mathbf{4\text{ analyzers per gateway}}$.
  - Disambiguation: Explicitly noted that $1,000\text{ units}$ represents CloudSim VM-provisioner bandwidth demand (`AppModule.getBw()`), not MIPS demand and not physical network-link throughput. Crucially, explicitly distinguished the configured sensor interval in seconds from simulator-reported loop delay ticks, without equating 1 simulation tick to 1 physical second.
- **Location:** [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:159-164](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L159-L164).

### Item 4: Epistemological Qualification of Causal Claims
- **Problem:** Sections 5.2, 7.1, and 9 stated without qualification that peer gateway offloading *"causes severe queue contention at the proxy switch"*. While proxy traversal is the sole structural difference between local and peer paths, CloudSim 7 does not output fine-grained packet queue telemetry.
- **Correction Applied:** Re-structured all peer offloading discussions into three distinct epistemological levels:
  1. *Empirical Observation:* Loop completion drops from $100\%$ to $25\%-50\%$ exclusively when `AnalyzerPeerGw` $> 0$.
  2. *Architectural Fact:* Peer gateway offloading introduces a bidirectional vertical hop through the parent proxy server (Sensor $\to$ LocalGW $\to$ Proxy $\to$ PeerGW $\to$ Proxy $\to$ LocalGW $\to$ Actuator).
  3. *Working Hypothesis:* Incomplete loops are consistent with packet queue delay exceeding the 2,000-tick cutoff, but absent per-link queue buffer traces, this remains an architectural hypothesis rather than directly measured causal proof.
- **Location:** [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:197-201](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L197-L201), [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:294](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L294), [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:310-312](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L310-L312), [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:320-321](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L320-L321).

### Item 5: Algorithm Variant Differentiation
- **Problem:** In Section 6, `LAMP_FWD`, `LAMP_REV`, and `LAMP_PHYS` were presented in a table without contextual distinction between the canonical literature implementation and exploratory sensitivity variants.
- **Correction Applied:** Added a dedicated Callout Note at the beginning of Section 6 clarifying that `LAMP_FWD` is the canonical forward-traversing implementation of *Rezazadeh et al. (2019)*, whereas `LAMP_REV` and `LAMP_PHYS` are exploratory sensitivity variants designed in Phase 2.2.
- **Location:** [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:221-225](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L221-L225).

### Item 6: Conditional Delay Warnings across Partial Completions
- **Problem:** In asymmetric workloads (`w2_6`, `w6_2`, `w10_2`), `LBMP_PURE`'s reported loop delay (e.g., $107.25$ ticks in `w2_6`) was lower than `LAMP`'s ($215.17$ ticks). A naive reader could interpret this as `LBMP_PURE` being "faster", ignoring that `LBMP_PURE` failed to complete $25\%$ to $33\%$ of its application loops.
- **Correction Applied:**
  - Marked all partial completion delay values with an asterisk (`*`).
  - Added an explicit Warning Alert: delay in partial completion runs is a conditional average ($\mathbb{E}[\text{Delay} \mid \text{Completed}]$). Unfinished loops timing out beyond 2,000 ticks are excluded from the denominator.
  - Explicitly banned claiming speedups when completion rates are unequal or partial.
- **Location:** [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:151](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L151), [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:253-256](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L253-L256).

### Item 7: Formal Metric Semantics and Accounting
- **Problem:** Definitions for simulator composite time, linear model-derived energy/cost, and byte-transfer network usage were brief and lacked formal boundary conditions.
- **Correction Applied:** Expanded Section 3 with dedicated subsections:
  - Section 3.1: Mathematical definition of discrete-event composite loop delay ticks.
  - Section 3.2: Formal specification of the completed-loop average calculation and the partial-completion denominator effect.
  - Section 3.3: Static linear power and billing equations, clarifying that baseline static idle power accounts for $>98\%$ of recorded energy.
  - Section 3.4: Byte-transfer network accounting and mandatory `N/A` semantics for uncompleted runs.
- **Location:** [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:69-93](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L69-L93).

### Item 8: Positive Percentage Reduction Formatting
- **Problem:** Section 5.1 displayed reductions with negative signs under reduction column headers (e.g., `Delay Reduction vs COMP: -82.41%`), creating double negatives.
- **Correction Applied:** Re-formatted all performance reduction columns to positive magnitudes: **`82.41%`** ($5.68\times$ speedup), **`73.02%`**, **`21.72%`**, and labeled the energy change column as `Total Energy Change (Δ)` with $-0.26\%$.
- **Location:** [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md:171-176](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md#L171-L176).

---

## 4. Cryptographic Source Code & Historical Dataset Validation

To verify that these report corrections did not contaminate or alter frozen simulation source code or historical datasets, an independent SHA-256 cryptographic audit was executed:

| Target File | Pre-Correction Checksum (Expected) | Post-Correction Checksum (Verified) | Verification Status |
| :--- | :--- | :--- | :---: |
| `results/lamp_reproduction_results_phase1_historical.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | **MATCH (UNTOUCHED)** |
| `results/lamp_reproduction_results.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | **MATCH (UNTOUCHED)** |
| `results/lamp_reproduction_results_phase2.csv` | `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284` | `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284` | **MATCH (UNTOUCHED)** |
| `results/asymmetric_validation_results.csv` | `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30` | `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30` | **MATCH (UNTOUCHED)** |
| `results/lbmp_symmetric_results.csv` | `4BEA70AF6DCB147B09EC95F72005502B84844DD91C1B6B25C0585793B0D8D26D` | `4BEA70AF6DCB147B09EC95F72005502B84844DD91C1B6B25C0585793B0D8D26D` | **MATCH (UNTOUCHED)** |
| `results/lbmp_asymmetric_results.csv` | `A37B3A2166374C57C731BD710B00229F36022B87C38FA6E10668F54CF2FFC14A` | `A37B3A2166374C57C731BD710B00229F36022B87C38FA6E10668F54CF2FFC14A` | **MATCH (UNTOUCHED)** |
| `iFogSim-main/.../ModulePlacementLBMP.java` | `DBD48E4B9D25B0033F1228562F9A5B54C10A20E7554EFD3DA9A69E17D049C044` | `DBD48E4B9D25B0033F1228562F9A5B54C10A20E7554EFD3DA9A69E17D049C044` | **MATCH (FROZEN)** |
| `iFogSim-main/.../BaselineSimulationRunner.java` | `09F1FEB0C3CFDAA6A1B809F20FA65946BFA20C85C309AAB79F11A30CA33E299A` | `09F1FEB0C3CFDAA6A1B809F20FA65946BFA20C85C309AAB79F11A30CA33E299A` | **MATCH (FROZEN)** |
| `iFogSim-main/.../ModulePlacementLBMPTest.java` | `CD1A1E58B14BC01AC283211491D30A2B68C84E3252AA24B00192CD064EE10885` | `CD1A1E58B14BC01AC283211491D30A2B68C84E3252AA24B00192CD064EE10885` | **MATCH (FROZEN)** |

---

## 5. Exhaustive List of Unresolved Issues and Limitations

In accordance with strict scientific integrity, the following limitations and unresolved domain issues remain:

1. **Absence of Link Buffer Timeseries Telemetry:**
   - *Limitation:* iFogSim2 / CloudSim 7 does not generate packet-by-packet switch buffer logs or time-series queue occupancy metrics per network port.
   - *Impact:* The connection between peer gateway offloading and loop drop rates ($25\%-50\%$) is mathematically consistent with inter-gateway proxy link congestion, but direct empirical proof of switch queue overflow cannot be extracted without instrumenting the underlying CloudSim network core.
2. **Fixed Duration Loop Truncation:**
   - *Limitation:* All simulation runs terminated strictly at $2,000\text{ simulation ticks}$.
   - *Impact:* Tuples that encountered severe buffering delays and remained in transit at tick 2,001 were classified as uncompleted (`null`). In real-world systems, these packets might eventually arrive with high latency or be retransmitted by TCP.
3. **Linear Model Assumptions:**
   - *Limitation:* Energy and Cloud Cost metrics are calculated via static linear multiplier formulas.
   - *Impact:* Real cloud pricing incorporates dynamic tiered bandwidth egress and API request minimums, while physical IoT hardware exhibits non-linear thermal and power scaling.
4. **Permanent Exclusion of SAMP:**
   - *Limitation:* The `SAMP` baseline remains excluded from comparative evaluation.
   - *Impact:* Because the original algorithm specification in literature lacked reproducible pseudocode and mathematical formulation, synthetic approximation was rejected to maintain rigorous scientific reproducibility.
5. **Single-Run Determinism vs. Stochastic Variance:**
   - *Limitation:* CloudSim 7 operates as a deterministic discrete-event simulator with fixed seed schedules.
   - *Impact:* While perfectly reproducible, these results do not incorporate stochastic wireless packet loss (e.g., Rayleigh fading or random backoff jitter).

---

## 6. Audit Conclusion & Document Index Cross-Reference

The comparative evaluation report [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md) is now **100% audited, mathematically corrected, and cryptographically verified**.

The document index [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) has been updated to include this audit record and the corrected comparative evaluation deliverables.
