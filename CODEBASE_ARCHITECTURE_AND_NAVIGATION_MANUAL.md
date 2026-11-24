# LAMP Research Reproduction — Codebase Architecture & Navigation Manual

**Project Root:** `C:\Users\91630\Desktop\Code Playground\LAMP\`  
**Last Updated:** November 23, 2026 (Phase 3.6 Validated, Phase 3.7 Audited & Final Research Consolidation Completed)  
**Toolchain:** Eclipse JustJ OpenJDK 21.0.6 LTS / iFogSim2 / CloudSim 7  

---

## 1. Repository Layout & Strict Isolation Boundaries

```text
LAMP/
├── A Hybrid Fog Cloud Latency Aware Module.pdf     [READ-ONLY] Primary Target Paper (LAMP 2019)
├── Resource Aware Placement of IoT Application.pdf [READ-ONLY] Primary Baseline Paper (LBMP 2017)
├── DOCUMENTATION_INDEX.md                          Master index, Change Log & Decision Log
├── CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md  This file
├── RESEARCH_TRACEABILITY_MATRIX.md                 Master 37-item Research Traceability Matrix
├── PHASE_1A .. PHASE_3_4_*.md                      [READ-ONLY] Preserved phase reports & design spec
├── PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md         Phase 3.5 LBMP_PURE implementation report
├── PHASE_3_5_POST_COMPILE_VALIDATION_REPORT.md     Phase 3.5 post-compile sequential validation report
├── PHASE_3_6_EXECUTION_READINESS_REPORT.md         Phase 3.6 16-run simulation execution readiness report (Rev. 3)
├── PHASE_3_6_SIMULATION_VALIDATION_REPORT.md       Phase 3.6 16-run simulation validation report
├── PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md      Phase 3.7 cross-algorithm comparative report
├── PHASE_3_7_CORRECTION_AND_VALIDATION_REPORT.md   Phase 3.7 targeted empirical audit report
├── PHASE_3_7_FINAL_CONSISTENCY_ADDENDUM.md         Phase 3.7 final consistency addendum
├── run_lbmp_experiments.ps1                        Phase 3.6 automated PowerShell execution wrapper
├── results/
│   ├── lamp_reproduction_results_phase1_historical.csv [READ-ONLY] Phase 1 baseline
│   ├── lamp_reproduction_results_phase2.csv            [READ-ONLY] Phase 2 36-run matrix
│   ├── asymmetric_validation_results.csv               [READ-ONLY] Phase 2.2 20-run matrix
│   ├── raw_logs/                                       [READ-ONLY] Phase 1 raw logs
│   ├── raw_logs_phase2/                                [READ-ONLY] Phase 2 raw logs
│   ├── raw_logs_asymmetric/                            [READ-ONLY] Phase 2.2 raw logs
│   ├── lbmp_symmetric_results.csv                      [READ-ONLY] Phase 3.6 12-run symmetric matrix
│   ├── lbmp_asymmetric_results.csv                     [READ-ONLY] Phase 3.6 4-run asymmetric matrix
│   ├── raw_logs_lbmp_symmetric/                        [READ-ONLY] Phase 3.6 symmetric raw logs
│   └── raw_logs_lbmp_asymmetric/                       [READ-ONLY] Phase 3.6 asymmetric raw logs
└── iFogSim-main/src/org/fog/
    ├── placement/                                      [READ-ONLY] Upstream iFogSim placement classes
    │   ├── ModulePlacement.java                        Abstract base class
    │   ├── ModulePlacementMapping.java                 Static mapping wrapper
    │   └── ModulePlacementEdgewards.java               Native Edge-Wards placement
    └── lamp/
        ├── application/
        │   └── HealthcareBSNApplication.java           [READ-ONLY] BSN DAG (Interface->Analyzer->Storage)
        ├── topology/
        │   └── HealthcareTopologyFactory.java          [READ-ONLY] 4-Tier symmetric topology factory
        ├── placement/
        │   └── ModulePlacementLAMP.java                [READ-ONLY] Phase 2 production LAMP
        ├── simulation/
        │   └── HealthcareSimulationRunner.java         [READ-ONLY] Phase 2 36-run CLI driver
        ├── asymmetric/                                 [READ-ONLY] Phase 2.2 isolated harness
        │   ├── AsymmetricTopologyFactory.java          Parameterized [M_0, M_1] 2-GW topology
        │   ├── ModulePlacementAsymmetricLAMP.java      FWD/REV & PAPER_CONVENTION/PHYSICAL_SI
        │   └── AsymmetricSimulationRunner.java         Phase 2.2 20-run CLI driver
        └── baselines/                                  [IMPLEMENTED & UNIT-VERIFIED — PHASE 3.5]
            ├── ModulePlacementLBMP.java                LBMP_PURE (Design C1, Option A BW, low=0, D-3.5-01)
            ├── ModulePlacementLBMPTest.java            11 deterministic unit tests (T01–T11: 11/11 PASS)
            └── BaselineSimulationRunner.java           Isolated LBMP symmetric/asymmetric CLI driver
```

---

## 2. Core Architectural Contracts

### 2.1 Application Model (`HealthcareBSNApplication`)
- Each mobile end device `m-i-j` owns a uniquely scoped application `app_i_j` with three modules (`3N` total system modules):
  1. `Interface_i_j`: Pinned to mobile `m-i-j` (`10 MB` RAM).
  2. `Sensor_Analyzer_i_j`: Dynamically placed (`700.0 MIPS` steady-state demand from `3500 MI / 5.0 s`, `10 MB` RAM, `1,000` default `AppModule.getBw()`).
  3. `Cloud_Storage_i_j`: Fixed on `cloud` (`10 MB` RAM, `1,000` default `AppModule.getBw()`).

### 2.2 Topology & Bandwidth Subsystem Separation (Verified in Phase 3.3)
- **Subsystem A — Network Link Rates (`FogDevice.uplinkBandwidth` / `downlinkBandwidth`):** Used solely by `FogDevice.sendUpFreeLink:864` and `sendDownFreeLink:892` for tuple transmission delay (`tupleFileSize / bw`). `cloud.upBw = 100` is unused at root (`parentId = -1`).
- **Subsystem B — Host VM Provisioner (`Host.getBw()` / `BwProvisionerOverbooking` / `AppModule.getBw()`):** Used solely by `HostEntity.guestCreate:64` during VM instantiation (`1,000,000` per host vs. `1,000` per module).
- **Phase 3.4 Decision (D-3.4-03):** `ModulePlacementLBMP` uses **Option A** (Subsystem B: `Host.getBw()` vs. `AppModule.getBw()`), explicitly documented as a CloudSim VM-layer approximation.

### 2.3 Phase 3.5 & 3.6 Isolated Package (`org.fog.lamp.baselines`)
- **Status:** Implemented, cleanly compiled with `-Xlint:all` (0 errors, 0 warnings), unit-verified (**11/11 tests PASS** in `ModulePlacementLBMPTest.java`), post-compilation validated (`PHASE_3_5_POST_COMPILE_VALIDATION_REPORT.md`), Phase 3.6 benchmark matrix executed (16/16 exit code 0, validated in `PHASE_3_6_SIMULATION_VALIDATION_REPORT.md`), Phase 3.7 comparative evaluation audited (`PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md`), and final research consolidation completed (`RESEARCH_TRACEABILITY_MATRIX.md`).
- **Reused Read-Only Factories:** Imports `HealthcareTopologyFactory`, `AsymmetricTopologyFactory`, and `HealthcareBSNApplication` without modifying any of them.
- **Fixed-Module Accounting Convention (`D-3.4-07`):** `Cloud_Storage` RAM (`10 MB`) and Host BW (`1,000`) are pre-reserved in the LBMP analytical resource ledger; its CPU is intentionally excluded to preserve comparability with the existing LAMP/EWMP placement convention (`ModulePlacementLAMP.java:193–218`, `HealthcareSimulationRunner.java:168–182`). Consequently, the LBMP ledger is not a complete mirror of CloudSim's resource consumption.
- **Cloud, Fallback Demand & VM Safeguards (`D-3.4-08`, `D-3.5-01`):** Normal Cloud selection (`cloudSelectedNormalCount`) and unconditional Cloud fallback (`cloudFallbackCount`) are strictly separated; fallback always uses the explicit `cloudState` reference, records per-module unmet deficits (`FallbackRecord`), accumulates full demand in `cloudFallbackDemandMips/Ram/Bw`, and never decrements `cloudState` below zero; actual CloudSim VM instantiation outcomes (`HostEntity.guestCreate`) are verified via `ModulePlacementMapping.getDeviceToModuleMap()` (`vmInstantiationSuccessCount` / `vmInstantiationFailureCount`); runtime monotonicity guard + linear-scan fallback are preserved.
- **Excluded / Deferred:** `LBMP_AFFINITY` (deferred), historical `SAMP` (excluded — primary source unverified), `SA_SYNTHETIC` (excluded).
