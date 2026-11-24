# LAMP Research Reproduction — Project Documentation Index

**Project:** Reproduction and Validation of *LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications* (Rezazadeh, Rezaei, Nickray, IEEE KBEI 2019)  
**Last Updated:** November 24, 2026  

---

## Primary Research Papers
- [A Hybrid Fog Cloud Latency Aware Module.pdf](A Hybrid Fog Cloud Latency Aware Module.pdf) — Rezazadeh, Rezaei & Nickray (2019), IEEE KBEI *(Primary Target Paper — LAMP)*.
- [Resource Aware Placement of IoT Application.pdf](Resource Aware Placement of IoT Application.pdf) — Taneja & Davy (2017), IFIP/IEEE IM *(Primary Source for LBMP Baseline [3])*.

---

## Architecture & Navigation Reference
- [CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md](CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md) — Repository layout, iFogSim resource-subsystem contracts, and Phase 3.4/3.5 isolated package design (`org.fog.lamp.baselines`).

---

## Phase Reports & Audit Trail

| Phase | Document | Scope & Status |
| :--- | :--- | :--- |
| **Phase 1A** | [PHASE_1A_ENVIRONMENT_REPORT.md](PHASE_1A_ENVIRONMENT_REPORT.md) | Environment & JDK/iFogSim setup verification *(Preserved Historical)*. |
| **Phase 1B** | [PHASE_1B_IMPLEMENTATION_REPORT.md](PHASE_1B_IMPLEMENTATION_REPORT.md) | Initial Healthcare BSN & LAMP/COMP implementation *(Preserved Historical)*. |
| **Phase 1** | [PHASE_1_SIMULATION_VALIDATION_REPORT.md](PHASE_1_SIMULATION_VALIDATION_REPORT.md) | Initial 36-run validation baseline & issue discovery *(Preserved Historical)*. |
| **Phase 2** | [PHASE_2_SIMULATION_VALIDATION_REPORT.md](PHASE_2_SIMULATION_VALIDATION_REPORT.md) | Corrected 36-run simulation matrix (COMP, LAMP, EWMP) *(Preserved Baseline)*. |
| **Phase 2 Audit** | [PHASE_2_INDEPENDENT_AUDIT_REPORT.md](PHASE_2_INDEPENDENT_AUDIT_REPORT.md) | Independent audit of time-unit consistency, 3N accounting & loop completion *(Audit Baseline)*. |
| **Phase 2.2** | [PHASE_2_2_ASYMMETRIC_VALIDATION_REPORT.md](PHASE_2_2_ASYMMETRIC_VALIDATION_REPORT.md) | Asymmetric topology validation (20 runs), Eq. 4 dimensional variants & peer-gateway offloading *(Completed)*. |
| **Phase 3 / 3.1** | [PHASE_3_BASELINE_ALGORITHM_ANALYSIS.md](PHASE_3_BASELINE_ALGORITHM_ANALYSIS.md) | Initial baseline research & Phase 3.1 fidelity correction for LBMP & SAMP *(Preserved Audit Record)*. |
| **Phase 3.2** | [PHASE_3_2_IMPLEMENTATION_READINESS_AUDIT.md](PHASE_3_2_IMPLEMENTATION_READINESS_AUDIT.md) | Implementation-readiness audit on LOWERBOUND, 3D monotonicity, tie-breaking & SAMP *(Preserved Audit Record)*. |
| **Phase 3.3** | [PHASE_3_3_RESOURCE_AND_CLOUD_SEMANTICS_AUDIT.md](PHASE_3_3_RESOURCE_AND_CLOUD_SEMANTICS_AUDIT.md) | Source-level trace of iFogSim bandwidth subsystems (`upBw`/`downBw` vs `Host.getBw()`/`BwProvisioner`) & Cloud fallback *(Preserved Audit Record)*. |
| **Phase 3.3.1** | [PHASE_3_3_1_PRIMARY_SOURCE_LBMP_REAUDIT.md](PHASE_3_3_1_PRIMARY_SOURCE_LBMP_REAUDIT.md) | Primary-source re-audit of Taneja & Davy (2017) PDF — verbatim Algorithms 1–3, Eqs. 1–12, Fig. 2 Mbps requirements *(Preserved; §11.2 Cloud BW dominance corrected by Phase 3.4 Erratum)*. |
| **Phase 3.4** | [PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md](PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md) | Final `LBMP_PURE` Design Specification (Rev. 2) — Phase 3.3.1 erratum, benchmark-restricted monotonicity proof, Option A BW, Design C1 Cloud, `low = 0` reset, fixed-module accounting convention, and 11 unit test specs *(Approved Contract)*. |
| **Phase 3.5** | [PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md](PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md) | **`LBMP_PURE` Java Implementation & Unit Validation Report** — isolated `org.fog.lamp.baselines` classes, `-Xlint:all` clean build, 11/11 unit tests (`T01`–`T11`) PASS, CloudSim VM instantiation verification, `D-3.5-01` fallback-demand telemetry, and Research Traceability Matrix *(Completed)*. |
| **Phase 3.5 Validation** | [PHASE_3_5_POST_COMPILE_VALIDATION_REPORT.md](PHASE_3_5_POST_COMPILE_VALIDATION_REPORT.md) | **Post-Compilation Sequential Validation Report** — clean pre-purge, fresh `javac -Xlint:all` build, immediate sequential `T01`–`T11` unit execution, temporal order verification, and bytecode cryptographic SHA-256 audit *(Verified)*. |
| **Phase 3.6 Readiness** | [PHASE_3_6_EXECUTION_READINESS_REPORT.md](PHASE_3_6_EXECUTION_READINESS_REPORT.md) | **`LBMP_PURE` Baseline Simulation Execution Readiness Report (Rev. 3)** — 16 planned configurations (12 symmetric, 4 asymmetric), hardened PowerShell execution wrapper (`run_lbmp_experiments.ps1` Rev. 3), verified pre-flight bytecode & historical CSV cryptography, two-tier post-run validation, and primary-source literature bandwidth reconciliation *(Completed)*. |
| **Phase 3.6 Validation** | [PHASE_3_6_SIMULATION_VALIDATION_REPORT.md](PHASE_3_6_SIMULATION_VALIDATION_REPORT.md) | **`LBMP_PURE` Baseline Simulation Validation Report** — Sequential execution of complete 16-run matrix (12 symmetric, 4 asymmetric), zero harness crashes/timeouts, 16/16 exit code 0, 3 SUCCESS / 13 PARTIAL_COMPLETION, 3N invariant adherence, 100% VM instantiation, and post-run cryptographic immutability *(Completed)*. |
| **Phase 3.7 Comparative Evaluation** | [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md) | **Cross-Algorithm Comparative Evaluation Report (`COMP` vs. `LAMP` vs. `EWMP` vs. `LBMP_PURE`)** — Matched workload analysis across 12 symmetric and 4 asymmetric configurations, loop delay & completion rate analysis, locality breakdown, model-derived energy/cost, and research limitations *(Audited & Corrected)*. |
| **Phase 3.7 Audit & Correction** | [PHASE_3_7_CORRECTION_AND_VALIDATION_REPORT.md](PHASE_3_7_CORRECTION_AND_VALIDATION_REPORT.md) | **Phase 3.7 Targeted Audit and Empirical Correction Report** — Log-by-log reconciliation of partial completions, N/A timeout metrics, 700 MIPS gateway capacity derivation, causal claims qualification, and cryptographic data integrity verification *(Verified)*. |
| **Phase 3.7 Final Addendum** | [PHASE_3_7_FINAL_CONSISTENCY_ADDENDUM.md](PHASE_3_7_FINAL_CONSISTENCY_ADDENDUM.md) | **Phase 3.7 Final Consistency Addendum** — Methodological, dimensional, timeout-semantics, and literature fidelity corrections to the master comparative evaluation report *(Completed)*. |
| **Final Research Consolidation** | [RESEARCH_TRACEABILITY_MATRIX.md](RESEARCH_TRACEABILITY_MATRIX.md) | **Comprehensive Research Traceability Matrix** — Exhaustive 37-item audit mapping original paper specifications (Rezazadeh 2019, Taneja 2017) to iFogSim implementation, fidelity classification (62.2% Reproduced [23 items], 24.3% Adapted [9 items], 10.8% Partially Reproduced [4 items], 2.7% Not Verifiable [1 item]), adaptations, empirical evidence, and disciplined defense notes *(Complete & Verified)*. |

---

## Demonstration & Single-Run Verification Artifacts

| Document | Scope & Status |
| :--- | :--- |
| [DEMONSTRATION_RUN_REPORT.md](DEMONSTRATION_RUN_REPORT.md) | **Controlled Single-Configuration Demonstration Report** — Live execution of LAMP under $G=2 \times M=4$ (8 applications, 24 modules, 8/8 loops, average loop delay 71.9300 ticks, exit code 0) *(Demonstration Artifact)*. |
| [DEMONSTRATION_COMPARISON_REPORT.md](DEMONSTRATION_COMPARISON_REPORT.md) | **Demonstration Comparative Analysis Report** — Rigorous numerical and structural comparison of demonstration run outputs against Phase 2 and Phase 3.7 matched baseline datasets *(Demonstration Artifact)*. |
| [DEMO_INTEGRITY_AUDIT_REPORT.md](DEMO_INTEGRITY_AUDIT_REPORT.md) | **Demonstration Post-Run Cryptographic Integrity Audit Report** — Root-cause audit of verification script exit code 1, confirming 100% SHA-256 integrity match across all historical datasets and baseline Java files *(Integrity Audit)*. |

---

## Pre-Submission Quality Assurance Artifacts

| Document | Scope & Status |
| :--- | :--- |
| [FINAL_DOCUMENTATION_AUDIT_REPORT.md](FINAL_DOCUMENTATION_AUDIT_REPORT.md) | **Pre-Submission Quality Assurance Audit Report** — Full read-only corpus audit across 24 Markdown files, 5 CSV datasets, and source files; verified 100% numerical consistency, unit discipline, and reproducible commands; verdict: `READY WITH MINOR ISSUES` *(Audit Report)*. |

---

## Decision Log (Phase 3.4 & 3.5)

| ID | Date | Decision | Status |
| :---: | :---: | :--- | :---: |
| **D-3.4-01** | 2026-11-18 | Implement **`LBMP_PURE` only** as primary LBMP baseline. | Implemented & Verified |
| **D-3.4-02** | 2026-11-18 | Defer `LBMP_AFFINITY`; exclude historical **SAMP** (unverified) and **`SA_SYNTHETIC`**. | Enforced |
| **D-3.4-03** | 2026-11-18 | Adopt **Option A** BW (`Host.getBw()` vs `AppModule.getBw()`), explicitly documented as a CloudSim VM-layer approximation (NOT exact Taneja & Davy Mbps reproduction). | Implemented & Verified |
| **D-3.4-04** | 2026-11-18 | Reset `low = 0` after every dynamic re-sort as a documented multi-app adaptation to published Algorithm 1 Line 11 (`low = i + 1`). | Implemented & Verified |
| **D-3.4-05** | 2026-11-18 | Use **Design C1**: keep `cloud` inside `nodes[]` ($N = N_F \cup N_C$). | Implemented & Verified |
| **D-3.4-06** | 2026-11-18 | Isolate all new Phase 3.5 code under `org.fog.lamp.baselines` and results under dedicated `results/*lbmp*` paths. | Enforced |
| **D-3.4-07** | 2026-11-18 | Fixed-module accounting convention: pre-reserve `10 MB` RAM and `1,000` Host BW per fixed `Cloud_Storage_i_j` in the LBMP analytical resource ledger; intentionally exclude `Cloud_Storage` CPU to preserve LAMP/EWMP comparability (ledger is not a complete mirror of CloudSim consumption). | Implemented & Verified |
| **D-3.4-08** | 2026-11-18 | Keep normal Cloud selection and unconditional Cloud fallback separate; target explicit `cloudState` reference on fallback; track CloudSim VM instantiation successes/failures separately from analytical fallback counts; preserve monotonicity guard + linear-scan fallback. | Implemented & Verified |
| **D-3.5-01** | 2026-11-18 | Add cumulative Cloud fallback-demand telemetry (`cloudFallbackDemandMips`, `cloudFallbackDemandRam`, `cloudFallbackDemandBw`) plus individual unmet deficit `FallbackRecord`s; never decrement `cloudState` below zero on fallback; keep fallback counts, cumulative demand, and VM instantiation failures strictly separate. | Implemented & Verified |

---

## Change Log

- **2026-11-24 (Final Pre-Submission Documentation Cleanup):** Resolved all three minor findings from `FINAL_DOCUMENTATION_AUDIT_REPORT.md`; converted all 219 machine-specific absolute file URIs across 16 historical phase reports to portable repository-relative Markdown links (F-01); indexed the three controlled demonstration reports and the pre-submission audit report in `DOCUMENTATION_INDEX.md` (F-02); added superseding audit notes to `PHASE_2_SIMULATION_VALIDATION_REPORT.md` clarifying that the final validated outcome was 34 completed runs and 2 watchdog-terminated COMP runs per `PHASE_2_INDEPENDENT_AUDIT_REPORT.md` (F-03).
- **2026-11-24 (Research Traceability Recalibration & Scientific Consistency Audit):** Conducted narrowly scoped scientific-consistency correction of `RESEARCH_TRACEABILITY_MATRIX.md`; reclassified Item 22 (Average Control-Loop Delay) from REPRODUCED to PARTIALLY REPRODUCED due to composite simulation tick time-base uncalibrated to physical latency; recalculated all 37 row classifications programmatically to 23 REPRODUCED (62.2%), 9 ADAPTED (24.3%), 4 PARTIALLY REPRODUCED (10.8%), 1 NOT VERIFIABLE (2.7%); removed conflation between 213.2 ms and 220 ticks in Item 18; corrected Item 11 sensor interval notation; clarified 70 completed vs 72 attempted simulation runs (with 2 watchdog-terminated COMP runs); distinguished algorithmic ranking from physical latency estimation in LAMP Equation 4 (Item 4); clarified that REPRODUCED in LBMP_PURE (Item 31) applies strictly to core sorting/search structures while the overall system is an adapted implementation; converted all machine-specific links to project-relative paths; updated hash audit reporting to distinguish 7 compared reference files from 2 generated files.
- **2026-11-23 (Final Research Consolidation & Traceability Matrix):** Completed exhaustive source-level and empirical audit connecting original literature specifications (Rezazadeh et al. 2019, Taneja & Davy 2017) to iFogSim2 implementation; constructed 37-item Research Traceability Matrix across 5 domains (LAMP mechanisms, Healthcare DAG, 4-tier topology, metrics, baselines); verified 100% cryptographic SHA-256 immutability of historical data and Java source code; authored `RESEARCH_TRACEABILITY_MATRIX.md` in workspace root and mirrored to artifact repository.
- **2026-11-23 (Phase 3.7 Final Consistency Correction & Terminology Audit):** Applied final consistency and unit-integrity corrections to `PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md` and `PHASE_3_7_FINAL_CONSISTENCY_ADDENDUM.md`; reconciled dimensional calculation of gateway analyzer demand ($D_{\text{cpu}} = 700\text{ MIPS}$) while distinguishing sensor seconds from simulation ticks; corrected Host/VM bandwidth units to CloudSim VM/Host-provisioner units ($1,000$ and $1,000,000$ provisioner units), distinguishing them from network link rates (`uplinkBandwidth`/`downlinkBandwidth`); corrected simulation horizon claim to reflect an experimental truncation boundary uncalibrated to real-world deadlines; disciplined causal claims regarding cloud uplink saturation and buffer queue buildup; formally differentiated 2,000-tick simulation horizon from external watchdog timeouts (exit code 143); documented actual implementation scope and approved Phase 3.4 adaptations for LAMP, LBMP_PURE, EWMP, and COMP; verified 100% SHA-256 immutability of historical data and Java source files; authored `PHASE_3_7_FINAL_CONSISTENCY_ADDENDUM.md`.
- **2026-11-23 (Phase 3.7 Correction & Validation Audit):** Completed targeted empirical audit and mathematical correction of `PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md`; replaced $0.00/0.0 timeout placeholders with strict N/A designations; extracted exact loop completion fractions (k/N) from raw logs for all partial completions; corrected fog gateway capacity derivation to exactly 4 analyzers based on 700.0 steady-state MIPS demand; epistemologically qualified causal assertions regarding peer-gateway offloading to distinguish empirical observations, tree routing topology, and proxy switch contention hypotheses; added conditional-delay methodology warnings; verified 100% cryptographic SHA-256 immutability of historical datasets and Java source files; authored `PHASE_3_7_CORRECTION_AND_VALIDATION_REPORT.md`.
- **2026-11-23 (Phase 3.7 Comparative Evaluation):** Completed exhaustive cross-algorithm comparative evaluation of COMP, LAMP, EWMP, and LBMP_PURE across matching symmetric (12) and asymmetric (4) workloads; audited 16/16 raw logs vs CSVs with 0 mismatches; verified post-flight historical CSV SHA-256 immutability; identified the M=4 ideal baseline (82% delay and 73% cost reduction over COMP) and the M=2 peer-offloading pathology in LBMP; produced `PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md`.
- **2026-11-23 (Phase 3.6 Simulation Validation):** Completed live execution of 16-run LBMP_PURE benchmark matrix (12 symmetric, 4 asymmetric) in 13.8 minutes using `run_lbmp_experiments.ps1` (Rev. 3); achieved 16/16 exit code 0, 0 watchdog timeouts; recorded 3 SUCCESS (M=4), 13 PARTIAL_COMPLETION; validated 3N invariant and 100% CloudSim VM instantiation; confirmed historical dataset immutability via pre/post SHA-256 checksums; created `PHASE_3_6_SIMULATION_VALIDATION_REPORT.md`.
- **2026-11-22 (Phase 3.6 Readiness Rev. 2 & Rev. 3):** Revised execution readiness report per independent review; split post-run validation into Category A (Structural Validity) and Category B (Simulation Outcome); designed and implemented dedicated PowerShell wrapper `run_lbmp_experiments.ps1` with isolated process execution, timeout handling, and summary logging; reclassified diagnostic expectations; updated `PHASE_3_6_EXECUTION_READINESS_REPORT.md` (Rev. 3).
- **2026-11-22 (Phase 3.6 Readiness Rev. 1):** Completed initial execution readiness audit for Phase 3.6 (`LBMP_PURE` benchmark experiments across 12 symmetric and 4 asymmetric configurations); documented exact CLI commands, isolation proofs, output paths, and pre/post-run validation checks in `PHASE_3_6_EXECUTION_READINESS_REPORT.md`.
- **2026-11-22 (Phase 3.5 Post-Compile Validation):** Successfully executed post-compilation validation protocol; pre-purged `.class` files, re-compiled with `javac -Xlint:all` (0 errors, 0 warnings), immediately executed `ModulePlacementLBMPTest` strictly after compilation (+1.410s), passing all 11 unit tests (`T01`–`T11`); verified bytecode timestamps and SHA-256 hashes in `PHASE_3_5_POST_COMPILE_VALIDATION_REPORT.md`.
- **2026-11-18 (Phase 3.5):** Implemented isolated `org.fog.lamp.baselines` (`ModulePlacementLBMP.java`, `ModulePlacementLBMPTest.java`, `BaselineSimulationRunner.java`) including `D-3.5-01` cumulative Cloud fallback-demand telemetry; compiled cleanly with `-Xlint:all` (0 errors, 0 warnings); passed 11/11 unit tests (`T01`–`T11`) with CloudSim VM instantiation verified via `ModulePlacementMapping.getDeviceToModuleMap()`; created `PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md`; updated `CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md` and `DOCUMENTATION_INDEX.md`. Full simulation matrix not started (stopped for review).
- **2026-11-18 (Phase 3.4 Rev. 2):** Recorded `D-3.4-07` (`Cloud_Storage` RAM/Host-BW pre-reservation, CPU excluded) and `D-3.4-08` (Cloud/VM safeguards); replaced synchronization claim with required fixed-module accounting convention wording; documented verified LAMP/EWMP source locations & discrepancies; updated `PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md`, `CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md`, and `DOCUMENTATION_INDEX.md`.
- **2026-11-18 (Phase 3.4 Rev. 1):** Created `PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md` (with formal erratum correcting Phase 3.3.1 §11.2 Cloud BW dominance claim and benchmark-restricted monotonicity proof); created `CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md`; updated `DOCUMENTATION_INDEX.md` with Phase 3.4 references, Decision Log, and Change Log.
- **2026-11-18 (Phase 3.3.1):** Created `PHASE_3_3_1_PRIMARY_SOURCE_LBMP_REAUDIT.md` and initial `DOCUMENTATION_INDEX.md` following full 7-page primary PDF audit of Taneja & Davy (2017).
