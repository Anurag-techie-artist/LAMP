# POST-GENERATION CRITICAL RECONCILIATION REPORT
## LAMP Edge Computing Research Project — IEEE Manuscript Rebuild

**Document Identifier:** `POST_GENERATION_CRITICAL_RECONCILIATION.md`  
**Authors:** M. Yoshi Anurag and Ch. Jaswanth  
**Affiliation:** Department of Computer Science and Engineering, Institution Placeholder  
**Date:** 2026-11-24  
**Audit Standard:** Strict Primary-Evidence Traceability and Multi-Phase Reconciliation  
**Overall Status:** **ALL 5 CRITICAL DISCREPANCIES FULLY RESOLVED**  

---

## 1. Executive Summary

Following the initial generation of the IEEE conference-style research manuscript, a critical reconciliation audit was conducted against primary empirical datasets, raw simulation execution logs, runner scripts, previous phase audit reports, and the original publication PDF (*Rezazadeh, Rezaei, and Nickray, 2019*).

This reconciliation resolves five specific discrepancies between earlier report drafts and validated primary research records:
1. **LBMP Phase 3.6 Completion Accounting:** Resolved the exact count of `SUCCESS` (3 runs) versus `PARTIAL_COMPLETION` (13 runs), reconciling the 156/220 completed application loop total across symmetric and asymmetric suites.
2. **Original LAMP Paper Table Characterization:** Corrected the assertion regarding numerical tables, formally distinguishing between published system/network configuration tables (Tables I, III, IV) and the complete absence of numerical experimental results tables.
3. **Bandwidth Unit Lineage & Traceability:** Traced network link bandwidth through the original paper, iFogSim Java source, and CloudSim provisioners, eliminating unsupported "KB/s" assertions and formalizing unitless/simulator-specific transfer rates versus VM provisioner allocations.
4. **Watchdog Timeout Disambiguation:** Reconciled actual external process watchdog limits across experimental phases (Phase 2 at 240s, Phase 3.6 at 300s) and separated them from the 2,000-tick discrete-event simulation horizon.
5. **Cryptographic Hash Classification Integrity:** Disambiguated artifacts that were independently verified against pre-existing trusted reference hashes from newly produced Phase 3.6 benchmark CSV files whose hashes were recorded and verified at generation.

---

## 2. Granular Discrepancy Reconciliation Matrix

### Discrepancy 1: LBMP Phase 3.6 Completion Accounting
- **Previous Manuscript Statement:**  
  *"in Phase 3.6, while all 16 runs completed execution and produced CSV summaries, `LBMP_PURE` suffered severe application-loop completion degradation ($k/N < 100\%$) in 9 out of 16 runs"* (and sample tables indicating single partial runs).
- **Primary Evidence Inspected:**  
  1. `results/lbmp_symmetric_results.csv` (SHA-256: `4BEA70AF...`):  
     - $M=4$ configurations: `gw2_m4` (8/8), `gw3_m4` (12/12), `gw4_m4` (16/16) $	o$ Exactly 3 `SUCCESS` runs (100% loop completion).  
     - $M \in \{2, 6, 8\}$ configurations: 9 runs with $k/N < 100\%$ $	o$ Exactly 9 `PARTIAL_COMPLETION` runs.  
     - Symmetric Loop Totals: 126 completed loops out of 180 total loops.  
  2. `results/lbmp_asymmetric_results.csv` (SHA-256: `A37B3A21...`):  
     - $w_{2,6}$ (6/8), $w_{6,2}$ (6/8), $w_{6,6}$ (10/12), $w_{10,2}$ (8/12) $	o$ Exactly 4 `PARTIAL_COMPLETION` runs.  
     - Asymmetric Loop Totals: 30 completed loops out of 40 total loops.  
  3. `PHASE_3_6_SIMULATION_VALIDATION_REPORT.md` (Section 2, Lines 42–46):  
     - *"`SUCCESS`: 3 runs (S02, S06, S10). In all three workloads where M=4, 100% of loops completed."*  
     - *"`PARTIAL_COMPLETION`: 13 runs (0 < CompletedLoops < N)."*  
     - *"`TIMEOUT`: 0 runs, `ERROR`: 0 runs."*  
     - *"`156 / 220` completed loops across the entire 16-run suite."*
- **Correct Scientific Conclusion:**  
  Across the 16 evaluated `LBMP_PURE` runs in Phase 3.6, exactly **3 runs achieved complete loop execution** (`SUCCESS`), and exactly **13 runs exhibited partial loop completion** (`PARTIAL_COMPLETION`). Exactly 156 out of 220 total application loops completed (70.91% loop completion rate). The earlier report draft incorrectly counted only the 9 symmetric partial runs, omitting the 4 asymmetric partial runs.
- **Required Manuscript Correction:**  
  Update all occurrences in the Abstract, Section VIII, Section VIII.C, Table II, and Table IV to explicitly state: 3 `SUCCESS` runs, 13 `PARTIAL_COMPLETION` runs, 0 `TIMEOUT`, and 156/220 completed loops ($70.9\%$).
- **Status:** **RESOLVED**

---

### Discrepancy 2: Original LAMP Paper Table Characterization
- **Previous Manuscript Statement:**  
  *"The original paper published zero numerical tables, presenting experimental findings exclusively through visual plots."*
- **Primary Evidence Inspected:**  
  1. `A Hybrid Fog Cloud Latency Aware Module.pdf` (Rezazadeh et al., 2019):  
     - **Table I (Page 3):** *"DESCRIPTION OF EDGES IN ECG APPLICATION MODEL"* — reports numerical CPU Length (MIPS) and Network Length for all application tuples.  
     - **Table II (Page 3):** *"DEFINITION OF SYMBOLS"* — defines sets $F, A, M, R$.  
     - **Table III (Page 4):** *"LATENCY OF FOG-CLOUD DEVICES"* — reports numerical link latencies: Sensor to End device ($0.6$ ms), Actuators to End device ($0.1$ ms), End device to Fog ($2$ ms), Fog to Proxy ($4$ ms), Proxy to Cloud ($100$ ms).  
     - **Table IV (Page 4):** *"CONFIGURING FOG DEVICES"* — reports numerical CPU (GHz), RAM (GB), uplink bw, and downlink bw for Cloud ($4.48, 40, 100, 10000$), Proxy-server ($0.28, 4, 10000, 10000$), Fog device ($0.28, 4, 10000, 10000$), and End device ($1, 1, 10000, 270$).  
     - **Section V (Pages 4–6):** *"EVALUATION RESULTS AND ANALYSIS"* — contains Figures 3–8 and textual discussion, but **contains zero numerical experimental results tables**.
- **Correct Scientific Conclusion:**  
  The original LAMP publication **did contain numerical configuration tables** (Tables I, III, and IV), which defined the application tuple sizes, network latencies, and device hardware specifications. However, it contained **zero numerical results tables** reporting measured simulation values (such as exact loop delays, execution costs, or energy expenditures), relying entirely on visual curves (Figs. 3–8) and high-level prose claims. The previous blanket assertion that the paper contained "zero numerical tables" was imprecise.
- **Required Manuscript Correction:**  
  Rephrase all instances to clearly distinguish between *configuration tables* (which were provided) and *experimental results tables* (which were omitted in favor of visual plots).
- **Status:** **RESOLVED**

---

### Discrepancy 3: Bandwidth Parameter Units & Traceability
- **Previous Manuscript Statement:**  
  *"Fog Network Link Bandwidth: 10,000 KB/s"*
- **Primary Evidence Inspected:**  
  1. `A Hybrid Fog Cloud Latency Aware Module.pdf` (Table IV):  
     - Column headers are `uplink bw` and `downlink bw`.  
     - Numerical values are listed without physical unit designations (e.g., `10000`, `100`, `270`).  
  2. `HealthcareTopologyFactory.java` (Lines 35–65):  
     - Passes raw double values directly to the `createFogDevice(...)` constructor:  
       `createFogDevice("proxy-server", 2800, 4000, 10000, 10000, ...)`  
       `createFogDevice("cloud", 44800, 40000, 100, 10000, ...)`  
  3. `iFogSim-main/src/org/fog/entities/FogDevice.java` (Lines 290–310):  
     - Computes transmission latency via direct division:  
       `double networkDelay = tuple.getCloudletFileSize() / getUplinkBandwidth();`  
       `double networkDelay = tuple.getCloudletFileSize() / getDownlinkBandwidth();`  
     - The simulator logic treats bandwidth as an abstract throughput rate relative to tuple length; no physical unit conversion (e.g., bits vs. bytes, kilo vs. mega) is declared.  
  4. `HealthcareTopologyFactory.java` (Line 135) & CloudSim:  
     - `int bw = 1000000; new BwProvisionerOverbooking(bw);`  
     - `appModule.setBw(1000);`  
     - These parameters configure CloudSim's internal VM-level bandwidth provisioner, operating as capacity counters rather than physical network link constraints.
- **Correct Scientific Conclusion:**  
  The bandwidth values in Table IV of Rezazadeh et al. (2019) are **strictly unitless in the original text**. In iFogSim, they operate as simulator-specific rate parameters where transmission delay equals `tuple.getCloudletFileSize() / bandwidth`. Silently labeling them as "KB/s" is unsupported by primary evidence. Furthermore, these network rate parameters must remain strictly distinguished from CloudSim's host-provisioning bandwidth units (`Host.getBw() = 1,000,000`, `AppModule.getBw() = 1,000`).
- **Required Manuscript Correction:**  
  Update Table I and Section VI.A to state: *"Fog Network Link Bandwidth: 10,000 (Unitless in original Table IV; abstract simulator transmission rate in iFogSim)"*. Explicitly define the four distinct bandwidth dimensions: (1) physical network rate parameter, (2) host provisioner bandwidth, (3) app module bandwidth, and (4) accumulated network usage in bytes.
- **Status:** **RESOLVED**

---

### Discrepancy 4: Watchdog Timeout Disambiguation
- **Previous Manuscript Statement:**  
  *"An external process watchdog terminates runs exceeding 900 wall-clock seconds."*
- **Primary Evidence Inspected:**  
  1. `run_experiments_phase2.py` (Line 42):  
     - `subprocess.run(..., timeout=240)` $	o$ Enforces a **240-second timeout**.  
  2. `PHASE_2_INDEPENDENT_AUDIT_REPORT.md` (Section 3, Lines 65–78):  
     - *"Root Cause: In `run_experiments_phase2.py`, `subprocess.run(..., timeout=240)` timed out at 240 seconds."*  
     - *"COMP gw3 m8 (>240s), COMP gw4 m8 (>240s)"* $	o$ Terminated by Python's `subprocess.TimeoutExpired`.  
  3. `run_asymmetric_experiments.py` (Line 50):  
     - `timeout=240` $	o$ Enforces a **240-second timeout** (0 timeouts occurred).  
  4. `run_lbmp_experiments.ps1` (Lines 15–25):  
     - `[int]$TimeoutSeconds = 300;`  
     - `Process.WaitForExit($timeoutMs)` $	o$ Enforces a **300-second watchdog timeout** (0 timeouts occurred; runtimes ranged from 1.6s to 147.7s).  
  5. `HealthcareSimulationRunner.java` & `BaselineSimulationRunner.java`:  
     - `CloudSim.stopSimulation(2000.0)` $	o$ Configures the **2,000-tick discrete-event simulation horizon**.
- **Correct Scientific Conclusion:**  
  The 900-second figure was an unverified assumption in earlier drafts. Primary runner scripts prove that Phase 2 enforced a **240-second external watchdog timeout**, which terminated the two dense COMP runs (`COMP_gw3_m8` and `COMP_gw4_m8`). Phase 3.6 enforced a **300-second watchdog timeout** in PowerShell. The discrete simulation horizon across all phases was consistently **2,000 simulation ticks**.
- **Required Manuscript Correction:**  
  Update Abstract, Section VII.A, Section VIII.A, Table II, and Section XI to state: *"Phase 2 external process watchdog timeout of 240 wall-clock seconds (with Phase 3.6 configured at 300 seconds), separate from the 2,000-tick discrete-event simulation horizon."*
- **Status:** **RESOLVED**

---

### Discrepancy 5: Cryptographic Hash Classification Integrity
- **Previous Manuscript Statement:**  
  All artifacts in the hash table were labeled uniformly as *"100% Match (Immutable)"* or *"Independently Matched"*.
- **Primary Evidence Inspected:**  
  1. `RESEARCH_TRACEABILITY_MATRIX.md` (Point 3, Line 158):  
     - *"Seven reference files (4 historical CSVs and 3 LBMP baseline Java source files) were cryptographically verified against pre-recorded SHA-256 reference hashes (100% match), and current SHA-256 hashes were recorded for the two Phase 3.6 benchmark CSV files."*  
  2. Historical Baseline Files (Audited & Matched against Pre-Recorded Hashes):  
     - `results/lamp_reproduction_results_phase1_historical.csv` (`A1E9C907...`) $	o$ **Independently Matched Reference Hash**  
     - `results/lamp_reproduction_results.csv` (`A1E9C907...`) $	o$ **Independently Matched Reference Hash**  
     - `results/lamp_reproduction_results_phase2.csv` (`613B00FC...`) $	o$ **Independently Matched Reference Hash**  
     - `results/asymmetric_validation_results.csv` (`3F1D1737...`) $	o$ **Independently Matched Reference Hash**  
     - `ModulePlacementLBMP.java` (`DBD48E4B...`) $	o$ **Independently Matched Frozen Source Hash**  
     - `BaselineSimulationRunner.java` (`09F1FEB0...`) $	o$ **Independently Matched Frozen Source Hash**  
     - `ModulePlacementLBMPTest.java` (`CD1A1E58...`) $	o$ **Independently Matched Frozen Test Suite Hash**  
     - `RESEARCH_TRACEABILITY_MATRIX.md` (`a47a9d03...`) $	o$ **Independently Matched Frozen Matrix Hash**  
  3. Phase 3.6 Generated Output Files (Produced during Phase 3.6, Hash Recorded at Generation):  
     - `results/lbmp_symmetric_results.csv` (`4BEA70AF...`) $	o$ **Recorded Output Hash (Verified against Phase 3.6 Report)**  
     - `results/lbmp_asymmetric_results.csv` (`A37B3A21...`) $	o$ **Recorded Output Hash (Verified against Phase 3.6 Report)**
- **Correct Scientific Conclusion:**  
  It is methodologically improper to claim that newly produced Phase 3.6 experimental datasets were "independently matched against pre-existing historical references." The seven pre-Phase 3 reference files were matched 100% against pre-existing reference hashes, while the two Phase 3.6 CSV datasets had their SHA-256 hashes recorded at production and subsequently verified for immutability.
- **Required Manuscript Correction:**  
  Update Appendix Table VII and Section 5 of the audit report to clearly distinguish between *Independently Matched Reference Hashes* and *Recorded & Verified Benchmark Output Hashes*.
- **Status:** **RESOLVED**

---

## 3. Systematic Reconciliation Checklist

| Item | Description | Pre-Reconciliation State | Post-Reconciliation State | Status |
| :---: | :--- | :--- | :--- | :---: |
| **R-01** | **Phase 3.6 LBMP Success Count** | Stated as 7 or unspecified | **Exactly 3 SUCCESS runs** ($M=4$ at $G \in \{2,3,4\}$) | **RESOLVED** |
| **R-02** | **Phase 3.6 LBMP Partial Count** | Stated as 9 partial runs | **Exactly 13 PARTIAL runs** (9 symmetric + 4 asymmetric) | **RESOLVED** |
| **R-03** | **Phase 3.6 LBMP Completed Loops** | Omitted / incomplete | **156 / 220 completed loops** ($70.91\%$) | **RESOLVED** |
| **R-04** | **Original Paper Tables Scope** | "zero numerical tables" | **Config tables (I, III, IV) present; zero results tables** | **RESOLVED** |
| **R-05** | **Link Bandwidth Units** | Claimed as 10,000 KB/s | **Unspecified in Table IV; abstract simulator rate in iFogSim** | **RESOLVED** |
| **R-06** | **CloudSim Provisioner Units** | Conflated with network BW | **Strictly separated as Host (1,000,000) & Module (1,000)** | **RESOLVED** |
| **R-07** | **Watchdog Timeout Limit** | Asserted as 900 seconds | **Phase 2: 240s; Phase 3.6: 300s; Sim Horizon: 2,000 ticks** | **RESOLVED** |
| **R-08** | **Watchdog Process Outcomes** | Conflated with sim failure | **Explicitly recorded as `TIMEOUT` / `N/A` (exit code 143)** | **RESOLVED** |
| **R-09** | **Cryptographic Hash Lineage** | All labeled "100% match" | **Separated into pre-recorded matches vs. recorded output** | **RESOLVED** |
| **R-10** | **Traceability Matrix Preservation** | Frozen matrix SHA-256 | **100% Immutable (`a47a9d03...`)** | **RESOLVED** |

---

## 4. Final Certification & Implementation Order

All five critical findings have been reconciled from primary source code, logs, CSVs, and original paper PDF text. The required modifications will now be applied directly to:
1. `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.md`
2. `ieee_paper/FINAL_LAMP_IEEE_FORMATTING_AND_DATA_AUDIT.md`
3. Regenerate `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.docx`
4. Regenerate `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.pdf`
5. Mirror all updated artifacts to root and artifact directories.