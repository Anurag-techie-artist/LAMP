# LAMP Edge Computing Research Project
## Latency-Aware Module Placement in Fog-Cloud Architectures

[![Research Status](https://img.shields.io/badge/Research%20Status-Complete%20%26%20Validated-brightgreen.svg)]()
[![Validation Integrity](https://img.shields.io/badge/Traceability%20Hash-a47a9d03...-blue.svg)]()
[![Java](https://img.shields.io/badge/Java-OpenJDK%2021-orange.svg)]()
[![Simulator](https://img.shields.io/badge/Simulator-iFogSim2%20%2F%20CloudSim-informational.svg)]()
[![License](https://img.shields.io/badge/License-Academic%20Research-lightgrey.svg)]()

---

### Authors
* **M. Yoshi Anurag**
* **Ch. Jaswanth**

---

## 1. Project Title and Overview

This repository contains the complete research artifacts, empirical benchmark datasets, execution scripts, and formal publication manuscripts for the **LAMP (Latency-Aware Module Placement)** Edge Computing research study.

The primary objective of this project is the rigorous independent reproduction, multi-tier architectural validation, and comparative benchmarking of the LAMP algorithm introduced by Rezazadeh, Rezaei, and Nickray (2019). Fog-cloud computing introduces a continuum of processing nodes between Internet-of-Things (IoT) sensors and central hyperscale cloud data centers. Determining optimal placement of application microservices across this continuum is NP-hard. 

Through four extensive research phases, this study:
1. **Reproduces** the baseline LAMP algorithm and evaluates its claims in a simulated Healthcare Body Sensor Network (BSN).
2. **Audits** the underlying simulation mechanics, establishing precise metric semantics (distinguishing simulation virtual ticks from calibrated physical milliseconds).
3. **Explores** asymmetric load dynamics, directional peer-offloading heuristics (`LAMP_FWD`, `LAMP_REV`, `LAMP_PHYS`), and gateway queue saturation.
4. **Benchmarks** LAMP against the canonical Load-Balancing Module Placement (`LBMP_PURE`) algorithm from Taneja & Davy (2017 Algorithms 1–3), Cloud-Only Placement (`COMP`), and Energy-Weight Module Placement (`EWMP`).
5. **Produces** a peer-reviewed, publication-ready 10-page IEEE conference-style research manuscript.

---

## 2. Research Objectives

1. **Independent Reproduction:** Re-implement the LAMP placement logic and execute the experimental matrix across varying gateway counts ($G \in \{2, 3, 4\}$) and mobile sensor densities ($M \in \{2, 4, 6, 8\}$).
2. **Simulation Semantics Audit:** Conduct an independent architectural code audit of CloudSim 7 and iFogSim2 to clarify loop delay calculations, power model integrations, and cost functions.
3. **Asymmetric Offloading Dynamics:** Investigate algorithm behavior when edge workloads are unbalanced across gateways (e.g., $w = [2, 6], [6, 2], [6, 6], [10, 2]$), analyzing peer gateway offloading versus parent proxy escalation.
4. **Canonical Baseline Benchmarking:** Implement the exact three-algorithm specification of LBMP from primary literature (descending capacity sorting, binary search best-fit placement, and linear fallback) to evaluate topology-agnostic load balancing against topology-aware latency minimization.
5. **Scientific Rigor & Complete Traceability:** Provide verifiable cryptographic hashes for all historical datasets and raw logs, differentiating full process completion from application loop completion ($k/N$).

---

## 3. Original Research Paper References

This research builds directly upon two foundational peer-reviewed publications:

### Primary Subject Algorithm (LAMP)
* **Title:** *A Hybrid Fog Cloud Latency Aware Module Placement Algorithm for IoT Applications*
* **Authors:** R. Rezazadeh, M. Rezaei, and S. Nickray
* **Conference:** 2019 4th International Conference on Knowledge-Based Engineering and Innovation (KBEI)
* **Publisher:** IEEE (Tehran, Iran, 2019)
* **Local Reference Artifact:** [`A Hybrid Fog Cloud Latency Aware Module.pdf`](A%20Hybrid%20Fog%20Cloud%20Latency%20Aware%20Module.pdf)
* **Core Contribution:** Latency-aware hierarchical placement prioritizing local gateway devices, intermediate proxy servers, and falling back to cloud data centers.

### Primary Comparison Baseline (LBMP)
* **Title:** *Resource Aware Placement of IoT Application Modules in Fog-Cloud Computing Environments*
* **Authors:** M. Taneja and A. Davy
* **Conference:** 2017 IFIP/IEEE International Symposium on Integrated Network and Service Management (IM)
* **Publisher:** IFIP/IEEE (Lisbon, Portugal, 2017)
* **Local Reference Artifact:** [`Resource Aware Placement of IoT Application.pdf`](Resource%20Aware%20Placement%20of%20IoT%20Application.pdf)
* **Core Contribution:** Pure load-balancing module placement utilizing binary-search best-fit capacity packing across a flat pool of fog devices.

---

## 4. System Architecture

The simulated environment implements an end-to-end multi-tier hierarchical Fog-Cloud topology:

```
[ Tier 3: Hyperscale Cloud ]
        ▲  (WAN: Latency = 100 ticks, BW = 100)
        │
[ Tier 2: Regional Proxy Server ]
        ▲  (MAN: Latency = 4 ticks, BW = 10000)
        │
[ Tier 1: Gateway Fog Devices (GW-0, GW-1, ... GW-(G-1)) ]
        ▲  (LAN / Wireless: Latency = 2 ticks, BW = 10000)
        │
[ Tier 0: Mobile IoT Devices & Wearable Sensors (m0, m1, ...) ]
```

### Node Specifications:
* **Cloud Data Center:** 44,000 MIPS, 40,000 MB RAM, 100 uplink/downlink bandwidth, $3.00/unit compute cost, $0.10/unit network cost.
* **Proxy Server (Regional Fog):** 2,800 MIPS, 4,000 MB RAM, 10,000 bandwidth.
* **Gateway Devices (Edge Fog):** 2,800 MIPS, 4,000 MB RAM, 10,000 bandwidth.
* **Mobile Devices:** 1,000 MIPS, 1,000 MB RAM.

---

## 5. Healthcare Body Sensor Network Application

The workload simulates an outpatient healthcare monitoring scenario represented as a Directed Acyclic Graph (DAG) application:

```
[ Body Sensors ] ──(RAW_DATA)──> [ Sensor_Analyzer ] ──(PROCESSED_DATA)──> [ Coordinator ]
                                        │
                                        └──(ALERT / ACTUATION)──────────> [ Actuator / Display ]
```

### Module Characteristics:
1. **`Client` Module:** Hosted locally on the mobile IoT device; interfaces with biological sensors and displays alerts.
2. **`Sensor_Analyzer` Module:** The primary compute-intensive microservice subject to placement optimization. Processes raw biometric signals (ECG, pulse, blood pressure).
   * **Compute Demand:** 1,000 MIPS
   * **Memory Demand:** 10 MB RAM
3. **`Coordinator` Module:** Aggregates multi-sensor patient streams; placed on the Cloud or central proxy.

### Primary Application Loop:
The critical evaluation metric is the **Sense-Process-Actuate Loop**:
$$\text{Loop: } \text{Sensor} \to \text{Sensor\_Analyzer} \to \text{Client}$$
This loop captures the end-to-end execution delay from the moment a biological reading is emitted until actuation or patient feedback occurs.

---

## 6. LAMP Algorithm Explanation

The Latency-Aware Module Placement (LAMP) algorithm employs a bottom-up, latency-minimizing heuristic:

1. **Local Gateway First ($G_i$):**
   * When an application module (`Sensor_Analyzer`) is submitted from mobile device $M_j$ attached to Gateway $G_i$, LAMP first attempts to host the module on $G_i$.
   * It checks whether $G_i$ has available CPU MIPS ($\ge 1000$) and RAM ($\ge 10\text{ MB}$).
   * If resources are available, the module is placed locally, incurring minimal LAN latency ($2\text{ ticks}$).
2. **Parent Fog Escalation (Proxy Server):**
   * If Gateway $G_i$ is resource-saturated, LAMP escalates the module to the parent Proxy Server (MAN latency $4\text{ ticks}$).
3. **Cloud Fallback:**
   * If the Proxy Server is also fully saturated, the module is placed on the Cloud Data Center (WAN latency $100\text{ ticks}$).

By prioritizing proximity to the edge, LAMP minimizes transit latency across high-delay WAN links and avoids cloud bandwidth billing costs whenever edge capacity permits.

---

## 7. Compared Algorithms

This study rigorously implements and benchmarks seven algorithm variations:

| Algorithm Identifier | Paradigm | Locality Aware? | Description & Functional Role |
| :--- | :--- | :---: | :--- |
| **`COMP`** | Cloud Baseline | No | **Cloud-Only Placement:** All `Sensor_Analyzer` modules placed on Cloud VMs. Fog nodes serve strictly as network routers. Represents standard non-edge cloud computing. |
| **`LAMP`** | Edge-First Heuristic | Yes | **Canonical LAMP:** Prioritizes local gateway, escalates to regional proxy, falls back to cloud. Evaluated in symmetric networks ($G \in \{2,3,4\}, M \in \{2,4,6,8\}$). |
| **`LAMP_FWD`** | Directional Peer Offloading | Yes | **Forward Peer Variant:** Under asymmetric gateway load, when local gateway is full, scans peer gateways in ascending order ($0 \to G-1$) before escalating to proxy. |
| **`LAMP_REV`** | Directional Peer Offloading | Yes | **Reverse Peer Variant:** Scans peer gateways in descending order ($G-1 \to 0$) to evaluate placement sensitivity to peer iteration order. |
| **`LAMP_PHYS`** | Proximity Peer Offloading | Yes | **Physical Proximity Variant:** Evaluates peer gateways strictly ordered by measured network latency distance. |
| **`EWMP`** | Energy-Aware Heuristic | Tiered | **Energy-Weight Placement:** Balances device energy states and workload distribution across fog tiers to moderate power consumption. |
| **`LBMP_PURE`** | Load Balancing | No | **Canonical LBMP (Taneja & Davy 2017):** Implements Algorithms 1–3. Sorts modules by compute demand and fog devices by capacity; performs binary-search best-fit packing. Lacks network topology awareness. |

> **Note on `SAMP`:** The Semi-Opportunistic Algorithm (SAMP) mentioned in the original 2019 paper was **excluded** from this empirical study because no verifiable mathematical or algorithmic specification exists in primary literature.

---

## 8. Technology Stack and Environment

* **Operating System:** Windows 10 / 11 64-bit (PowerShell 5.1+ / 7+)
* **Java Runtime:** OpenJDK 21.0.6 64-Bit (Eclipse JustJ OpenJDK distribution or standard OpenJDK 21+)
* **Simulation Framework:** iFogSim2 built upon CloudSim 7
* **External Java Libraries:** Apache Commons Math 3.5 (`commons-math3-3.5.jar`)
* **Analytical Runtime:** Python 3.10+ / 3.12+ (Standard library: `csv`, `subprocess`, `os`, `re`, `hashlib`)
* **Document Generation:** ReportLab 4.4+, python-docx, Matplotlib, pdf2image

> **Environment Note:** In accordance with licensing and repository standards, `iFogSim-main/` and the Eclipse IDE are **not bundled** in this repository and must be acquired separately (see Section 10).

---

## 9. Repository Structure

```
LAMP/
├── .gitignore                                      # Comprehensive Git exclusion rules
├── README.md                                       # Authoritative project documentation (this document)
├── RESEARCH_TRACEABILITY_MATRIX.md                 # Immutable cryptographic verification matrix
├── DOCUMENTATION_INDEX.md                          # Master navigation catalogue of all research reports
├── CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md  # Architectural guide to Java packages & simulation classes
│
├── A Hybrid Fog Cloud Latency Aware Module.pdf      # Original LAMP research paper (Rezazadeh et al., 2019)
├── Resource Aware Placement of IoT Application.pdf # Original LBMP research paper (Taneja & Davy, 2017)
├── extracted_paper_text.txt                        # Full extracted text from primary LAMP paper
├── sec2_and_sec5.txt                               # Verbatim extracts of Sections II & V of original paper
│
├── run_experiments.py                              # Phase 1: Initial reproduction runner (36 runs, 180s watchdog)
├── run_experiments_phase2.py                       # Phase 2: Symmetric matrix runner (36 runs, 240s watchdog)
├── run_asymmetric_experiments.py                   # Phase 2.2: Asymmetric offloading runner (20 runs, 240s watchdog)
├── run_lbmp_experiments.ps1                        # Phase 3.6: LBMP_PURE benchmark matrix (16 runs, 300s watchdog)
│
├── compare_phases.py                               # Cross-phase comparison script (Phase 1 vs. Phase 2)
├── analyze_results.py                              # Phase 1 result processor
├── analyze_phase2_results.py                       # Phase 2 statistical aggregator
├── audit_phase2_logs.py                            # Phase 2 loop completion & timestamp auditor
├── audit_asymmetric_results.py                     # Phase 2.2 analyzer placement reconciler
│
├── results/                                        # Authoritative empirical datasets & execution logs
│   ├── lamp_reproduction_results_phase2.csv        # Phase 2: Final symmetric 36-run dataset
│   ├── asymmetric_validation_results.csv           # Phase 2.2: Final asymmetric 20-run dataset
│   ├── lbmp_symmetric_results.csv                  # Phase 3.6: LBMP symmetric 12-run dataset (26 columns)
│   ├── lbmp_asymmetric_results.csv                 # Phase 3.6: LBMP asymmetric 4-run dataset (25 columns)
│   ├── lbmp_execution_summary.txt                  # Phase 3.6: Per-run timing, exit codes & outcomes
│   ├── lamp_reproduction_results.csv               # Phase 1: Initial reproduction dataset
│   ├── lamp_reproduction_results_phase1_historical.csv # Cryptographically preserved Phase 1 baseline
│   ├── raw_logs_phase2/                            # Phase 2 console logs (34 logs, 2 timeouts)
│   ├── raw_logs_asymmetric/                        # Phase 2.2 console logs (20 logs)
│   ├── raw_logs_lbmp_symmetric/                    # Phase 3.6 LBMP symmetric logs (12 logs)
│   ├── raw_logs_lbmp_asymmetric/                   # Phase 3.6 LBMP asymmetric logs (4 logs)
│   ├── raw_logs/                                   # Phase 1 console logs (36 logs)
│   └── phase3_5_validation_logs/                   # Pre-execution compilation & unit test logs
│
├── demonstration_results/                          # Demonstration verification logs & reports
│   ├── COMP_demo_gw2_m4.log                        # Demonstration run log for COMP (G=2, M=4)
│   ├── LAMP_demo_gw2_m4.log                        # Demonstration run log for LAMP (G=2, M=4)
│   ├── EWMP_demo_gw2_m4.log                        # Demonstration run log for EWMP (G=2, M=4)
│   ├── LBMP_demo_gw2_m4.log                        # Demonstration run log for LBMP (G=2, M=4)
│   ├── DEMONSTRATION_RUN_REPORT.md                 # Execution log audit report
│   └── DEMONSTRATION_COMPARISON_REPORT.md          # Multi-metric comparative synthesis
│
├── ieee_paper/                                     # Publication manuscript assets
│   ├── figures/                                    # 11 High-resolution production charts & diagrams
│   │   ├── chart1_loop_delay_comparison.png        # Loop delay across gateway scales
│   │   ├── chart2_cloud_cost_comparison.png        # Cloud cost across application workloads
│   │   ├── chart3_network_usage_comparison.png     # Total network bytes transmitted
│   │   ├── chart4_energy_consumption_comparison.png# Fog vs. Cloud energy profiles
│   │   ├── chart5_loop_completion_rate.png         # Loop completion rate under saturation
│   │   ├── chart6_placement_distribution.png       # Placement breakdown across tiers
│   │   ├── fig1_iot_fog_cloud_architecture.png     # Three-tier system architecture
│   │   ├── fig2_healthcare_bsn_dag.png             # Healthcare BSN application DAG
│   │   ├── fig3_lamp_decision_flowchart.png        # LAMP hierarchical decision logic
│   │   ├── fig4_experimental_topology.png          # Physical simulated node topology
│   │   └── fig5_research_workflow.png              # Multi-phase research workflow
│   ├── FINAL_LAMP_RESEARCH_REPORT_REVISED.pdf      # Authoritative revised IEEE manuscript PDF
│   ├── FINAL_LAMP_RESEARCH_REPORT_REVISED.docx     # Authoritative revised Word manuscript
│   ├── FINAL_LAMP_IEEE_RESEARCH_PAPER.pdf          # Identical archive IEEE PDF
│   ├── FINAL_LAMP_IEEE_RESEARCH_PAPER.docx         # Archive distinct build Word document
│   └── FINAL_LAMP_IEEE_RESEARCH_PAPER.md           # Identical archive Markdown text
│
├── FINAL_LAMP_RESEARCH_REPORT_REVISED.pdf          # Primary Authoritative Publication PDF (10 pages)
├── FINAL_LAMP_RESEARCH_REPORT_REVISED.docx         # Primary Authoritative Publication Word Document
├── FINAL_LAMP_RESEARCH_REPORT_REVISED.md           # Primary Authoritative Publication Markdown
│
├── PHASE_1A_ENVIRONMENT_REPORT.md                 # Phase 1A: Toolchain & environment validation
├── PHASE_1B_IMPLEMENTATION_REPORT.md              # Phase 1B: Java code port & placement implementation
├── PHASE_1_SIMULATION_VALIDATION_REPORT.md        # Phase 1: Simulation validation & metric baseline
├── PHASE_2_SIMULATION_VALIDATION_REPORT.md        # Phase 2: Symmetric matrix re-execution report
├── PHASE_2_INDEPENDENT_AUDIT_REPORT.md            # Phase 2: Comprehensive independent audit & corrections
├── PHASE_2_2_ASYMMETRIC_VALIDATION_REPORT.md      # Phase 2.2: Asymmetric workload & peer-offload report
├── PHASE_3_BASELINE_ALGORITHM_ANALYSIS.md         # Phase 3: Survey & selection of LBMP baseline
├── PHASE_3_2_IMPLEMENTATION_READINESS_AUDIT.md    # Phase 3.2: Architecture readiness for LBMP
├── PHASE_3_3_RESOURCE_AND_CLOUD_SEMANTICS_AUDIT.md# Phase 3.3: In-depth CloudSim resource semantics audit
├── PHASE_3_3_1_PRIMARY_SOURCE_LBMP_REAUDIT.md     # Phase 3.3.1: Strict re-audit of Taneja & Davy paper
├── PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md         # Phase 3.4: Formal mathematical specification of LBMP
├── PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md        # Phase 3.5: LBMP Java implementation report
├── PHASE_3_5_POST_COMPILE_VALIDATION_REPORT.md    # Phase 3.5: Compilation & unit test validation
├── PHASE_3_5_CODE_REVIEW.zip                      # Preserved bytecode & code review bundle
├── PHASE_3_6_EXECUTION_READINESS_REPORT.md        # Phase 3.6: Pre-flight readiness & wrapper spec
├── PHASE_3_6_SIMULATION_VALIDATION_REPORT.md      # Phase 3.6: LBMP execution validation report
├── PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md     # Phase 3.7: Definitive cross-algorithm comparative report
├── PHASE_3_7_CORRECTION_AND_VALIDATION_REPORT.md  # Phase 3.7: Data reconciliation & correction pass
├── PHASE_3_7_FINAL_CONSISTENCY_ADDENDUM.md        # Phase 3.7: Consistency addendum & dataset sync
│
├── DEMO_INTEGRITY_AUDIT_REPORT.md                 # Demonstration log integrity audit
├── FINAL_DOCUMENTATION_AUDIT_REPORT.md            # Repository documentation audit
├── FINAL_DOCUMENTATION_CLEANUP_REPORT.md          # Workspace cleanup log
├── FINAL_MANUSCRIPT_CORRECTION_LOG.md             # Complete record of manuscript edits
├── FINAL_MANUSCRIPT_VALIDATION_REPORT.md          # Quality assurance audit of final manuscript
├── FINAL_TABLE_II_RECONCILIATION.md               # Re-audit and reconciliation of Table II metrics
├── FINAL_TWO_ISSUE_VERIFICATION.md                # Reconciliation of watchdog timing and lineage
└── POST_GENERATION_CRITICAL_RECONCILIATION.md     # Reconciliation of partial completion counts
```

---

## 10. Prerequisites and Setup

To reproduce the simulations, you will require:
1. **Operating System:** Windows 10 or 11 (x64)
2. **Java Development Kit:** OpenJDK 21 or higher
3. **Python:** Version 3.10 or higher
4. **PowerShell:** Version 5.1 or PowerShell Core 7+
5. **iFogSim2 Framework:** Obtain the source repository of iFogSim2 and extract to `iFogSim-main/` in the repository root.

### Classpath Requirements:
The runners assume the following compiled classes and jar dependencies:
```
iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*
```

---

## 11. Compilation and Execution Instructions

If rebuilding from source code within `iFogSim-main`:

### 1. Compile Java Source Packages:
```cmd
javac -cp "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*" -d iFogSim-main\bin ^
  iFogSim-main\src\org\fog\lamp\simulation\HealthcareSimulationRunner.java ^
  iFogSim-main\src\org\fog\lamp\asymmetric\AsymmetricSimulationRunner.java ^
  iFogSim-main\src\org\fog\lamp\baselines\BaselineSimulationRunner.java ^
  iFogSim-main\src\org\fog\lamp\baselines\ModulePlacementLBMP.java
```

### 2. Verify Bytecode Freshness:
Phase 3.6 enforces pre-flight verification against the following SHA-256 class hashes:
* `BaselineSimulationRunner.class`: `2A5CD1C5DF16D27BF2828FFE537B3EA9C378562761F1397766DBB5AAD8BC9CBD`
* `ModulePlacementLBMP.class`: `F1F2E6034E67FDE22B06683E304291EEB85EAEFE2820C0B972D324F06DAFA120`

---

## 12. Experiment Execution Guide

All experiments are fully automated via dedicated runner scripts. Ensure the command prompt or PowerShell session is executing from the **repository root**.

### Phase 1: Reproduction Matrix
Executes the initial 36-run matrix across `COMP`, `LAMP`, and `EWMP`:
```cmd
python run_experiments.py
```
* **Runner Script:** `run_experiments.py`
* **Target Class:** `org.fog.lamp.simulation.HealthcareSimulationRunner`
* **Parameters:** $G \in \{2, 3, 4\}$, $M \in \{2, 4, 6, 8\}$, Duration = 2000 units
* **Watchdog:** 180 seconds per run
* **Outputs:** `results/lamp_reproduction_results.csv`, raw logs in `results/raw_logs/`

### Phase 2: Symmetric Workload Matrix
Executes the corrected 36-run symmetric matrix with standardized tick metrics:
```cmd
python run_experiments_phase2.py
```
* **Runner Script:** `run_experiments_phase2.py`
* **Target Class:** `org.fog.lamp.simulation.HealthcareSimulationRunner`
* **Parameters:** $G \in \{2, 3, 4\}$, $M \in \{2, 4, 6, 8\}$, Duration = 2000 ticks
* **Watchdog:** 240 seconds per run
* **Outputs:** `results/lamp_reproduction_results_phase2.csv`, raw logs in `results/raw_logs_phase2/`
* **Caveat:** Runs `COMP_gw4_m8` and `EWMP_gw4_m8` exceed 240s under high saturation and emit structured `TIMEOUT` records.

### Phase 2.2: Asymmetric Workload Matrix
Executes the 20-run asymmetric matrix evaluating peer offloading:
```cmd
python run_asymmetric_experiments.py
```
* **Runner Script:** `run_asymmetric_experiments.py`
* **Target Class:** `org.fog.lamp.asymmetric.AsymmetricSimulationRunner`
* **Workload Pairs:** $[2, 6]$, $[6, 2]$, $[6, 6]$, $[10, 2]$ across $G=2$ gateways
* **Algorithms:** `COMP`, `LAMP_FWD`, `LAMP_REV`, `LAMP_PHYS`, `EWMP`
* **Watchdog:** 240 seconds per run
* **Outputs:** `results/asymmetric_validation_results.csv`, raw logs in `results/raw_logs_asymmetric/`

### Phase 3.6: LBMP_PURE Benchmark Matrix
Executes the 16-run canonical LBMP benchmark suite (12 symmetric, 4 asymmetric):
```powershell
powershell -ExecutionPolicy Bypass -File .\run_lbmp_experiments.ps1 -FreshRun
```
* **Runner Script:** `run_lbmp_experiments.ps1`
* **Target Class:** `org.fog.lamp.baselines.BaselineSimulationRunner`
* **Watchdog:** 300 seconds per run (enforced asynchronously via `taskkill`)
* **Outputs:** `results/lbmp_symmetric_results.csv`, `results/lbmp_asymmetric_results.csv`, `results/lbmp_execution_summary.txt`, logs in `results/raw_logs_lbmp_symmetric/` and `results/raw_logs_lbmp_asymmetric/`
* **Safeguard:** Existing outputs are protected; `-FreshRun` is mandatory to re-execute.

### Phase 3.7: Comparative Evaluation
Phase 3.7 was executed through direct analytical scripts and cross-dataset synthesis (no separate simulation runner):
```cmd
python compare_phases.py
python analyze_phase2_results.py
python audit_phase2_logs.py
python audit_asymmetric_results.py
```
* **Governing Report:** [`PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md`](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md)

---

## 13. Parameter Configurations and Matrix Overview

### 1. Symmetric Matrix (36 Runs per Phase):
* **Gateways ($G$):** 2, 3, 4
* **Mobiles per Gateway ($M$):** 2, 4, 6, 8
* **Total Applications ($N = G \times M$):** 4, 6, 8, 12, 16, 18, 24, 32

### 2. Asymmetric Matrix (20 Runs in Phase 2.2, 4 in Phase 3.6):
* **Fixed Gateways:** $G = 2$
* **Workload Configurations:**
  * $[2, 6]$: $M_0 = 2, M_1 = 6 \implies N = 8$
  * $[6, 2]$: $M_0 = 6, M_1 = 2 \implies N = 8$
  * $[6, 6]$: $M_0 = 6, M_1 = 6 \implies N = 12$
  * $[10, 2]$: $M_0 = 10, M_1 = 2 \implies N = 12$

---

## 14. Results and Evaluation Metrics

### Metric Definitions:
1. **Loop Delay (`loop_delay_sim_ticks`):** Composite simulation time units for the complete Sense-Process-Actuate loop. Includes CPU processing time in CloudSim VMs and simulated link latencies.
2. **Cloud Cost (`USD`):** Analytical model output based on CloudSim billing parameters ($3.00/unit VM compute + $0.10/unit network bandwidth).
3. **Cloud & Fog Energy (`Joules`):** Model-derived energy consumption computed via device power states ($P_{\text{busy}} = 107.339\text{ W}$, $P_{\text{idle}} = 83.433\text{ W}$ for Fog; $P_{\text{busy}} = 1648\text{ W}$, $P_{\text{idle}} = 1332\text{ W}$ for Cloud).
4. **Network Usage (`Bytes`):** Total bytes transferred across all topology links.
5. **Loop Completion Status:**
   * **`SUCCESS`:** All $N$ application loops completed successfully ($N/N$).
   * **`PARTIAL_COMPLETION`:** Simulation finished, but only $k$ out of $N$ loops completed ($0 < k < N$).
   * **`TIMEOUT`:** Run exceeded wall-clock watchdog limit and was forcibly terminated.

### Summary Comparison Table (Excerpt for $G=2$ Gateways):

| Config ($G, M$) | Apps ($N$) | Metric | `COMP` (Cloud) | `LAMP` (Proposed) | `EWMP` | `LBMP_PURE` (Baseline) |
| :---: | :---: | :--- | :---: | :---: | :---: | :---: |
| **$G=2, M=2$** | 4 | Loop Delay (ticks) | 204.60 | **13.68** | 13.68 | 205.15 |
| | | Cloud Cost (USD) | $20,299.20 | **$0.00** | $0.00 | $19,890.00 |
| | | Fog Placements | 0 / 4 | **4 / 4** | 4 / 4 | 4 / 4 |
| **$G=2, M=4$** | 8 | Loop Delay (ticks) | 205.28 | **71.93** | 71.93 | 194.27 |
| | | Cloud Cost (USD) | $59,359.20 | **$59,359.20** | $59,359.20 | $39,780.00 |
| | | Fog Placements | 0 / 8 | **4 / 8** | 4 / 8 | 4 / 8 |
| **$G=2, M=6$** | 12 | Loop Delay (ticks) | 205.74 | **135.53** | 135.53 | N/A (Partial) |
| | | Cloud Cost (USD) | $99,444.00 | **$99,444.00** | $99,444.00 | $59,670.00 |
| | | Fog Placements | 0 / 12 | **4 / 12** | 4 / 12 | 4 / 12 |
| **$G=2, M=8$** | 16 | Loop Delay (ticks) | 205.86 | **166.75** | 166.75 | N/A (Partial) |
| | | Cloud Cost (USD) | $138,504.00 | **$138,504.00** | $138,504.00 | $79,560.00 |
| | | Fog Placements | 0 / 16 | **4 / 16** | 4 / 16 | 4 / 16 |

---

## 15. Reproducibility Notes and Limitations

To ensure absolute scientific honesty and avoid over-claiming, researchers should note the following constraints:

1. **Simulation Ticks vs. Physical Milliseconds:** In CloudSim/iFogSim, time progresses via discrete-event simulation ticks. Although early papers frequently label these ticks as "milliseconds", they do not reflect physical network packet transit calibrated to real hardware clocks.
2. **Analytical Energy and Cost:** Energy and cost figures represent mathematical model derivations based on configured power parameters and static CloudSim billing coefficients, not physical utility bills or wattmeter readings.
3. **Process Exit vs. Loop Completion:** A process exit code of `0` indicates that the simulation engine reached its time horizon ($2000\text{ ticks}$); it **does not** guarantee that all sensor loops completed. Heavy workloads ($M \ge 6$) induce queue delays where some loops remain incomplete at termination (`PARTIAL_COMPLETION`).
4. **Watchdog Duration vs. Simulation Time:** The simulation time horizon is 2000 virtual ticks. The watchdog timeout is real-world wall-clock time (180s in Phase 1, 240s in Phase 2/2.2, 300s in Phase 3.6) implemented to terminate hung or thrashing simulations.
5. **Qualitative vs. Quantitative Replication:** While LAMP's relative performance advantages over COMP (latency reduction up to 93% at light load, 0% cost at $M=2$) reproduce the qualitative trends from Rezazadeh et al. (2019), absolute numbers diverge due to discrete event queue scheduling and simulator version semantics.

---

## 16. Research Traceability and Validation

Every dataset, log file, and report in this repository is cryptographically anchored in [`RESEARCH_TRACEABILITY_MATRIX.md`](RESEARCH_TRACEABILITY_MATRIX.md).

### Cryptographic Baseline Hashes:
```
RESEARCH_TRACEABILITY_MATRIX.md : a47a9d0352c81868c2179a409f6ac9806d8cd2c4d0eaefad0bb9603ee2b58693
lamp_reproduction_results_phase2: 613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284
asymmetric_validation_results   : 3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30
lbmp_symmetric_results          : 12 Verified Runs (Bit-for-bit matched with raw logs)
lbmp_asymmetric_results         : 4 Verified Runs (Bit-for-bit matched with raw logs)
```

To view the complete cross-phase audit history, consult [`DOCUMENTATION_INDEX.md`](DOCUMENTATION_INDEX.md).

---

## 17. Final Research Manuscript

The findings of this research study have been compiled into a 10-page, publication-standard IEEE conference paper:

* **Primary Deliverable (PDF):** [`FINAL_LAMP_RESEARCH_REPORT_REVISED.pdf`](FINAL_LAMP_RESEARCH_REPORT_REVISED.pdf)
* **Primary Deliverable (Word):** [`FINAL_LAMP_RESEARCH_REPORT_REVISED.docx`](FINAL_LAMP_RESEARCH_REPORT_REVISED.docx)
* **Primary Deliverable (Markdown):** [`FINAL_LAMP_RESEARCH_REPORT_REVISED.md`](FINAL_LAMP_RESEARCH_REPORT_REVISED.md)
* **High-Resolution Figures:** [`ieee_paper/figures/`](ieee_paper/figures/)

The paper features dual-column formatting, rigorous mathematical formulations, full algorithmic specifications, and publication-quality vector charts.

---

## 18. Citation

If you reference this research project, code artifacts, or empirical datasets, please cite as follows:

### Plain Text:
> M. Yoshi Anurag and Ch. Jaswanth, "A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications: Reproduction, Empirical Validation, and Comparative Evaluation," LAMP Edge Computing Research Project, Technical Report, Nov. 2026.

### BibTeX:
```bibtex
@techreport{anurag2026lamp,
  author      = {M. Yoshi Anurag and Ch. Jaswanth},
  title       = {A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications: Reproduction, Empirical Validation, and Comparative Evaluation},
  institution = {LAMP Research Group},
  year        = {2026},
  month       = {November},
  type        = {Research Technical Report},
  url         = {https://github.com/placeholder/lamp-edge-computing}
}
```

---

## 19. Disclaimer / Research Scope

This repository is maintained strictly for academic and research purposes. The simulation models and algorithms herein are designed to evaluate distributed computing trade-offs within the CloudSim/iFogSim discrete-event environment. They do not constitute clinical advice or operational production software for live medical deployments. Third-party components (`iFogSim2`, `CloudSim`) remain the property and copyright of their respective authors and academic institutions.
