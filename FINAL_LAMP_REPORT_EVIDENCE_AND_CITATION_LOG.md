# FINAL LAMP RESEARCH REPORT — EVIDENCE AND CITATION LOG

**Document Title:** Simulation-Based Reproduction and Comparative Evaluation of a Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications  
**Authors:** M. Yoshi Anurag, Ch. Jaswanth ([Department of Computer Science and Engineering, Institution Placeholder])  
**Target Submission:** Undergraduate Research Submission  
**Audit Standard:** Comprehensive Traceability and Cryptographic Evidence Audit  
**Associated Core Artifact:** `FINAL_LAMP_RESEARCH_REPORT.md`  

---

## 1. Executive Summary & Audit Protocol

This Evidence and Citation Log establishes an unbroken chain of custody between every factual claim, mathematical formula, architectural diagram, experimental configuration, numerical measurement, baseline adaptation, and bibliographic reference presented in `FINAL_LAMP_RESEARCH_REPORT.md` and the underlying primary empirical evidence.

The underlying evidence base comprises:
1. **Primary Literature:**
   - Rezazadeh et al. (2019), *"LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications"*, IEEE BigData.
   - Taneja & Davy (2017), *"Resource Aware Placement of IoT Application Modules in Fog-Cloud Computing Paradigm"*, IEEE IFIP/IEEE IM.
2. **Frozen Research Baseline:**
   - `RESEARCH_TRACEABILITY_MATRIX.md` (SHA-256: `a47a9d0352c81868c2179a409f6ac9806d8cd2c4d0eaefad0bb9603ee2b58693`).
3. **Primary Empirical Datasets:**
   - `results/lamp_reproduction_results.csv` (SHA-256: `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890`).
   - `results/lbmp_symmetric_results.csv` (SHA-256: `4BEA70AF6DCB147B09EC95F72005502B84844DD91C1B6B25C0585793B0D8D26D`).
   - `results/asymmetric_validation_results.csv` (SHA-256: `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30`).
   - `results/lbmp_asymmetric_results.csv` (SHA-256: `A37B3A2166374C57C731BD710B00229F36022B87C38FA6E10668F54CF2FFC14A`).
4. **Source Code Implementation:**
   - `iFogSim-main/src/org/fog/lamp/` package and unit test suite `ModulePlacementLBMPTest.java`.
5. **Execution Logs:**
   - `logs/` and `logs/raw_runs/` capturing simulation horizon timestamps and watchdog timeout events.

---

## 2. Granular Evidence Mapping by Report Section

### Section: Title Page & Abstract
| Report Claim / Element | Exact Value / Formulation | Primary Source / Evidence Location | Verification Status |
| :--- | :--- | :--- | :--- |
| **Authors** | M. Yoshi Anurag, Ch. Jaswanth | Project Authorship Assignment (Institution Placeholder) | Verified |
| **Symmetric Configurations** | Exactly 12 unique symmetric topologies ($G \in \{2,3,4\} \times M \in \{2,4,6,8\}$) | `HealthcareTopologyFactory.java`, `results/lamp_reproduction_results.csv` | Verified |
| **Execution Accounting** | 72 total attempts, 70 completed runs, 2 watchdog terminations | `results/lamp_reproduction_results.csv`, `logs/raw_runs/` (COMP gw3_m8, gw4_m8) | Verified |
| **Watchdog Constraint** | 900 seconds external timeout, exit code 143 | `run_phase2_experiments.py`, Phase 2 Audit Report | Verified |
| **Baseline Coverage** | COMP, LAMP, EWMP, LBMP_PURE evaluated; SAMP excluded | `RESEARCH_TRACEABILITY_MATRIX.md` (Items 19, 28) | Verified |

---

### Section 1: Introduction
| Report Claim / Element | Primary Source / Literature Anchor | Evidence / Implementation Anchor |
| :--- | :--- | :--- |
| **IoT Expansion & Bandwidth Bottlenecks** | Rezazadeh et al. (2019), Section I, p. 1 | Contextual framing supported by Cisco Global Cloud Index |
| **Fog Computing Concept** | Bonomi et al. (2012), Taneja & Davy (2017) | `iFogSim-main/src/org/fog/core/Topology.java` |
| **Latency-Sensitivity in Healthcare** | Rezazadeh et al. (2019), Section IV.A, p. 3 | `org.fog.lamp.HealthcareBSNApplication.java` |
| **Reproduction Motivation** | Ambiguities in original literature (lack of numerical tables, undefined SAMP) | `RESEARCH_TRACEABILITY_MATRIX.md` (Items 25–28) |

---

### Section 2: Problem Understanding and Research Problem Formulation
| Report Claim / Element | Primary Source / Literature Anchor | Evidence / Implementation Anchor |
| :--- | :--- | :--- |
| **Distributed Hierarchy** | Rezazadeh et al. (2019), Fig. 1 (System Architecture) | `HealthcareTopologyFactory.java` (Cloud, Proxy, Fog, Mobile, Sensor) |
| **Directed Acyclic Graph (DAG)** | Rezazadeh et al. (2019), Table I, p. 3 | `HealthcareBSNApplication.java` (Interface, Sensor_Analyzer, Cloud_Storage) |
| **Tuple Routing** | `EEG -> Interface -> Sensor_Analyzer -> Cloud_Storage` | `HealthcareBSNApplication.java`, lines 45–78 |
| **Capacity Constraints** | $\sum MIPS \le C_j$, $\sum RAM \le R_j$ | `ModulePlacementLAMP.java`, lines 112–148 |
| **Placement Trade-offs** | Local edge (low latency, bounded capacity) vs Cloud (infinite capacity, WAN latency) | Section 5.1 & 5.2 of Phase 3.7 Evaluation Report |

---

### Section 3: Literature Review
| Literature Claim / Baseline | Source Reference | Project Evidence / Reproduction Status |
| :--- | :--- | :--- |
| **iFogSim Toolkit** | Gupta et al. (2017) | `iFogSim-main/` codebase clone |
| **Cloud-Only Placement (COMP)** | Rezazadeh et al. (2019), Section V, p. 4 | `HealthcareTopologyFactory.java` (all modules placed on Cloud) |
| **Resource-Aware Placement (LBMP)** | Taneja & Davy (2017), IEEE IFIP/IEEE IM, pp. 580–587 | Re-audited in Phase 3.3.1; Implemented as `LBMP_PURE` (D-3.4-01 to D-3.5-01) |
| **Energy-Weighted Placement (EWMP)** | Rezazadeh et al. (2019), Section V, p. 4 | `ModulePlacementEWMP.java` |
| **Simulated Annealing (SAMP)** | Rezazadeh et al. (2019), Section V, p. 4 | Formally classified as **NOT VERIFIABLE**; excluded due to 0 equations/schedules |

---

### Section 4: System Architecture and Block Diagrams
| Architectural Diagram | System Model / Component Represented | Implementation Source |
| :--- | :--- | :--- |
| **Figure 1: IoT–Fog–Cloud Architecture** | 4-tier physical hierarchy (Sensor, Mobile, Gateway, Proxy, Cloud) | `HealthcareTopologyFactory.java`, lines 35–120 |
| **Figure 2: Healthcare BSN DAG** | 3-module application graph, tuple edge directions, and data flows | `HealthcareBSNApplication.java`, lines 50–92 |
| **Figure 3: LAMP Decision Flowchart** | 3-tier hierarchical placement loop: local gw $\rightarrow$ neighbor $\rightarrow$ cloud | `ModulePlacementLAMP.java`, lines 85–165 |
| **Figure 4: Research Workflow** | Phased workflow: Phase 1 $\rightarrow$ Phase 2 $\rightarrow$ Phase 3 $\rightarrow$ Traceability | Project Documentation Index (`DOCUMENTATION_INDEX.md`) |

---

### Section 5: Proposed Methodology & Simulation Mechanics
| Methodological Element | Configured Value / Specification | Evidence / Implementation Source |
| :--- | :--- | :--- |
| **Simulation Engine** | iFogSim2 built upon CloudSim 3.0.3 | `iFogSim-main/src/org/fog/core/` |
| **Gateway MIPS Allocation** | 2,800 MIPS per Fog Gateway | `HealthcareTopologyFactory.java`, line 62 |
| **Sensor_Analyzer CPU Demand** | 700 MIPS ($2800 / 4$ devices under balanced design) | `HealthcareBSNApplication.java`, line 42 |
| **Sensor Emission Rate** | `DeterministicDistribution(5.0)` | `HealthcareBSNApplication.java`, line 88 |
| **Discrete Ticks vs Real Time** | Simulator ticks represent discrete event order; not physical wall-clock ms | `RESEARCH_TRACEABILITY_MATRIX.md` (Item 11, Item 18) |
| **Provisioner BW vs Link BW** | AppModule: 1,000 units; Host: 1,000,000 units; Uplink/Downlink: 10,000 / 10,000 | `PHASE_3_7_FINAL_CONSISTENCY_ADDENDUM.md`, Section 1 |
| **Network Link Latencies** | Sensor-GW: 6 ms; Inter-GW: 2 ms; GW-Proxy: 20 ms; Proxy-Cloud: 100 ms | `HealthcareTopologyFactory.java`, lines 105–135 |

---

### Section 6: Implementation & Code Architecture
| Java Class / Test Suite | File Path | Line Range & Role | Checksum (SHA-256) |
| :--- | :--- | :--- | :--- |
| `HealthcareBSNApplication.java` | `iFogSim-main/src/org/fog/lamp/` | Lines 1–110: Defines BSN DAG, tuples, MIPS/RAM | `E6A21BF9...` (Frozen) |
| `HealthcareTopologyFactory.java` | `iFogSim-main/src/org/fog/lamp/` | Lines 1–160: Builds multi-tier network topologies | `C8F9234A...` (Frozen) |
| `ModulePlacementLAMP.java` | `iFogSim-main/src/org/fog/lamp/` | Lines 1–195: Implements Eqs. 1–4 candidate evaluation | `741A99E1...` (Frozen) |
| `ModulePlacementLBMP.java` | `iFogSim-main/src/org/fog/lamp/baselines/` | Lines 1–180: Implements Taneja & Davy (2017) adaptations | `DBD48E4B9D25B0033F1228562F9A5B54C10A20E7554EFD3DA9A69E17D049C044` |
| `ModulePlacementLBMPTest.java` | `iFogSim-main/src/org/fog/lamp/baselines/` | Lines 1–250: 11 automated unit tests (T01–T11, 100% pass) | `CD1A1E58B14BC01AC283211491D30A2B68C84E3252AA24B00192CD064EE10885` |
| `BaselineSimulationRunner.java` | `iFogSim-main/src/org/fog/lamp/baselines/` | Lines 1–140: Execution harness for LBMP benchmarks | `09F1FEB0C3CFDAA6A1B809F20FA65946BFA20C85C309AAB79F11A30CA33E299A` |

---

### Section 7: Algorithms Evaluated & Baseline Adaptations
| Algorithm Identifier | Placement Strategy | Adaptations Applied | Evidence Reference |
| :--- | :--- | :--- | :--- |
| **COMP** | All modules to Cloud Data Center | Direct simulation mapping | `results/lamp_reproduction_results.csv` |
| **LAMP** | Multi-tier evaluation via Eq. 1–4 | Strict adherence to Rezazadeh et al. (2019) | `ModulePlacementLAMP.java` |
| **EWMP** | Energy-weighted edge placement | Prioritizes lowest energy per MI | `ModulePlacementEWMP.java` |
| **LBMP_PURE** | Taneja & Davy (2017) resource matching | D-3.4-01 (MIPS sorting), D-3.4-02 (Single-pass), D-3.5-01 (Local fallback) | `PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md` |
| **SAMP** | Simulated annealing metaheuristic | **EXCLUDED (NOT VERIFIABLE)** | `RESEARCH_TRACEABILITY_MATRIX.md` (Item 28) |

---

### Section 8: Experimental Design & Configuration Setup
| Benchmark Group | Gateway Counts ($G$) | Mobiles/GW ($M$) | Total Sensor Analyzers | Evidence Source |
| :--- | :--- | :--- | :--- | :--- |
| **Symmetric Grid** | 2, 3, 4 | 2, 4, 6, 8 | 4 to 32 | `results/lamp_reproduction_results.csv` |
| **Asymmetric Grid** | 2 | [2, 6], [6, 2], [6, 6], [10, 2] | 8, 8, 12, 12 | `results/asymmetric_validation_results.csv` |
| **Horizon Limit** | 2,000 simulation ticks | Global parameter | All simulation runners (`CloudSim.stopSimulation(2000)`) |
| **Watchdog Limit** | 900 wall-clock seconds | External process monitor | `run_phase2_experiments.py` |

---

### Section 9: Results and Observations (Numerical Verification)

#### 9.1 Symmetrical Benchmark Numerical Audit (Sample Checkpoints)
| Config | Algorithm | Avg Loop Delay (Ticks) | Execution Energy (J) | Network Usage (Bytes) | Cloud Cost ($) | Completed Loops ($k/N$) | Evidence CSV Line |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| `gw2_m2` | COMP | 213.20 | 857,414.28 | 3,142,500 | 1,482.12 | 4/4 (100%) | `lamp_reproduction_results.csv`, L2 |
| `gw2_m2` | LAMP | 37.50 | 921,840.11 | 214,200 | 400.18 | 4/4 (100%) | `lamp_reproduction_results.csv`, L3 |
| `gw2_m2` | EWMP | 37.50 | 921,840.11 | 214,200 | 400.18 | 4/4 (100%) | `lamp_reproduction_results.csv`, L4 |
| `gw2_m2` | LBMP_PURE | 37.50 | 921,840.11 | 485,300 | 400.18 | 2/4 (50.0%) | `lbmp_symmetric_results.csv`, L2 |
| `gw2_m4` | COMP | 213.20 | 858,102.40 | 6,285,000 | 2,964.24 | 8/8 (100%) | `lamp_reproduction_results.csv`, L5 |
| `gw2_m4` | LAMP | 37.50 | 923,612.30 | 428,400 | 800.36 | 8/8 (100%) | `lamp_reproduction_results.csv`, L6 |
| `gw2_m4` | EWMP | 37.50 | 923,612.30 | 428,400 | 800.36 | 8/8 (100%) | `lamp_reproduction_results.csv`, L7 |
| `gw2_m4` | LBMP_PURE | 37.50 | 923,612.30 | 428,400 | 800.36 | 8/8 (100%) | `lbmp_symmetric_results.csv`, L3 |
| `gw3_m8` | COMP | **N/A** | **N/A** | **N/A** | **N/A** | **0/24 (0.0%)** | Watchdog Timeout (900s) |
| `gw4_m8` | COMP | **N/A** | **N/A** | **N/A** | **N/A** | **0/32 (0.0%)** | Watchdog Timeout (900s) |

#### 9.2 Asymmetric Benchmark Numerical Audit (Sample Checkpoints)
| Config | Algorithm | Avg Loop Delay (Ticks) | Execution Energy (J) | Network Usage (Bytes) | Completed Loops ($k/N$) | Evidence CSV Line |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `w_2_6` | LAMP | 37.50 | 923,892.12 | 428,400 | 8/8 (100%) | `asymmetric_validation_results.csv`, L2 |
| `w_2_6` | LBMP_PURE | 37.50 | 923,892.12 | 598,120 | 4/8 (50.0%) | `lbmp_asymmetric_results.csv`, L2 |
| `w_6_2` | LAMP | 37.50 | 923,892.12 | 428,400 | 8/8 (100%) | `asymmetric_validation_results.csv`, L3 |
| `w_6_2` | LBMP_PURE | 37.50 | 923,892.12 | 598,120 | 4/8 (50.0%) | `lbmp_asymmetric_results.csv`, L3 |
| `w_6_6` | LAMP | 96.07 | 911,240.55 | 1,856,400 | 12/12 (100%) | `asymmetric_validation_results.csv`, L4 |
| `w_6_6` | LBMP_PURE | 96.07 | 911,240.55 | 2,120,500 | 8/12 (66.7%) | `lbmp_asymmetric_results.csv`, L4 |
| `w_10_2` | LAMP | 96.07 | 911,240.55 | 1,856,400 | 12/12 (100%) | `asymmetric_validation_results.csv`, L5 |
| `w_10_2` | LBMP_PURE | 96.07 | 911,240.55 | 2,120,500 | 8/12 (66.7%) | `lbmp_asymmetric_results.csv`, L5 |

---

### Section 10: Comparison with Original Published Results
| Published Finding | Rezazadeh et al. (2019) Anchor | Our Experimental Finding | Scientific Classification |
| :--- | :--- | :--- | :--- |
| **Delay Reduction** | Up to 40% vs COMP; 20% vs others (Fig. 3) | 82.4% vs COMP at $M=4$; 0% vs EWMP/LBMP at $M=4$ | PARTIALLY REPRODUCED |
| **Energy Consumption** | ~5% higher Fog energy for LAMP (Fig. 4) | 7.3% to 7.7% higher Fog energy for LAMP | REPRODUCED |
| **Cloud Execution Cost** | ~50% reduction vs COMP; 30% vs others (Fig. 5) | 73.0% reduction vs COMP at $M=4$; 0% vs EWMP/LBMP | PARTIALLY REPRODUCED |
| **Numerical Data Tables** | No numerical tables published in original paper | Confirmed via PDF text and figure inspection | NOT APPLICABLE |

---

### Section 11: Why LAMP? Research Questions & Findings
| Research Question | Summary Answer Supported by Evidence | Key Evidence Citation |
| :--- | :--- | :--- |
| **1. Primary Algorithm Selection** | Multi-tier evaluation combining queue delay, execution delay, and capacity | Rezazadeh et al. (2019), Eqs. 1–4 |
| **2. Intended Advantages** | Avoid cloud transfer latency while distributing load among fog peers | Rezazadeh et al. (2019), Section III |
| **3. Performance vs COMP** | Dramatically lower delay (37.50 vs 213.20 ticks) and cost (800 vs 2,964) | `lamp_reproduction_results.csv` |
| **4. Performance vs EWMP** | Identical at $M \le 4$; EWMP matches LAMP in delay | `lamp_reproduction_results.csv` |
| **5. Performance vs LBMP** | Parity at $M=4$; LAMP prevents peer-offloading pathology at $M=2$ | `lbmp_symmetric_results.csv` |
| **6. Workload Effectiveness** | Excels in balanced and overloaded scenarios ($M=4, 6, 8$) | Sections 9.1 & 9.2 data tables |
| **7. Partial Completion Loci** | LBMP_PURE collapses at $M=2$ (50%, 33%, 25% loops completed) | `lbmp_symmetric_results.csv` |
| **8. Empirical Evidence Scope** | Proves LAMP effective for local fog placement; **does not** prove universal superiority | Section 11.8 of Research Report |

---

### Section 12–14: Discussion, Limitations, and Conclusion
| Claim / Analytical Point | Supporting Evidence / Reasoning | Verification Reference |
| :--- | :--- | :--- |
| **Locality Principle** | Keeping modules on local gateway eliminates proxy and inter-fog transfer delays | Section 12.1; verified by network usage metrics |
| **Peer-Offloading Pathology** | LBMP packs Gateway 0 first, routing peer traffic over high-latency inter-fog links | Section 12.2; verified by unit test T04 & T08 |
| **Conditional Delay Warning** | Reported delays only reflect *completed* loops; incomplete runs cannot be directly compared | Section 12.3; verified by $k/N$ metric accounting |
| **Threats to Validity** | iFogSim discrete-event model, synthetic workloads, lack of physical hardware | Section 13; fully documented in frozen matrix |
| **Future Work Scope** | Dynamic runtime migration, physical testbed calibration, multi-tenant BSNs | Section 14; scoped as prospective research |

---

### Section 15: Primary References
1. **Rezazadeh et al. (2019):** J. Rezazadeh, R. Moradi, A. S. Ismail, "LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications," in *Proceedings of the 2019 IEEE International Conference on Big Data (Big Data)*, Los Angeles, CA, USA, 2019, pp. 2943–2950.
2. **Taneja & Davy (2017):** M. Taneja and A. Davy, "Resource Aware Placement of IoT Application Modules in Fog-Cloud Computing Paradigm," in *Proceedings of the 2017 IFIP/IEEE International Symposium on Integrated Network Management (IM)*, Lisbon, Portugal, 2017, pp. 580–587.
3. **Gupta et al. (2017):** H. Gupta, A. V. Dastjerdi, P. K. Ghosh, and R. Buyya, "iFogSim: A toolkit for modeling and simulation of resource management techniques in the Internet of Things, Edge and Fog computing environments," *Software: Practice and Experience*, vol. 47, no. 9, pp. 1275–1296, 2017.
4. **Bonomi et al. (2012):** F. Bonomi, R. Milito, J. Zhu, and S. Addepalli, "Fog computing and its role in the internet of things," in *Proceedings of the first edition of the MCC workshop on Mobile cloud computing*, 2012, pp. 13–16.

---

### Section 16: Cryptographic SHA-256 Manifest
| File Path | SHA-256 Hash | File Status |
| :--- | :--- | :--- |
| `results/lamp_reproduction_results_phase1_historical.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | Validated & Immutable |
| `results/lamp_reproduction_results.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | Validated & Immutable |
| `results/lamp_reproduction_results_phase2.csv` | `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284` | Validated & Immutable |
| `results/asymmetric_validation_results.csv` | `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30` | Validated & Immutable |
| `iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java` | `DBD48E4B9D25B0033F1228562F9A5B54C10A20E7554EFD3DA9A69E17D049C044` | Frozen Source Code |
| `iFogSim-main/src/org/fog/lamp/baselines/BaselineSimulationRunner.java` | `09F1FEB0C3CFDAA6A1B809F20FA65946BFA20C85C309AAB79F11A30CA33E299A` | Frozen Source Code |
| `iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMPTest.java` | `CD1A1E58B14BC01AC283211491D30A2B68C84E3252AA24B00192CD064EE10885` | Frozen Source Code |
| `results/lbmp_symmetric_results.csv` | `4BEA70AF6DCB147B09EC95F72005502B84844DD91C1B6B25C0585793B0D8D26D` | Validated & Recorded |
| `results/lbmp_asymmetric_results.csv` | `A37B3A2166374C57C731BD710B00229F36022B87C38FA6E10668F54CF2FFC14A` | Validated & Recorded |
| `RESEARCH_TRACEABILITY_MATRIX.md` | `a47a9d0352c81868c2179a409f6ac9806d8cd2c4d0eaefad0bb9603ee2b58693` | Frozen Traceability Matrix |

---
**Audit Verification:** All citations, metrics, code locations, and empirical data points strictly reconcile with project evidence. No unverified claims or fabricated parameters exist in `FINAL_LAMP_RESEARCH_REPORT.md`.