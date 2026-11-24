# PHASE 3.5: `LBMP_PURE` JAVA IMPLEMENTATION & UNIT VALIDATION REPORT
**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 18, 2026  
**Status:** IMPLEMENTATION & UNIT VALIDATION COMPLETE — STOPPED AWAITING FULL-MATRIX AUTHORIZATION  
**Governing Contract:** [PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md](PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md) (Rev. 2)  
**Toolchain:** Eclipse JustJ OpenJDK Hotspot 21.0.6 LTS / iFogSim2 / CloudSim 7  

---

## 1. Executive Summary

Phase 3.5 implemented the isolated **`LBMP_PURE`** baseline placement engine, its 11-scenario deterministic unit test suite (`T01`–`T11`), and the unified symmetric/asymmetric simulation runner strictly inside the new package `org.fog.lamp.baselines`.

- **Compilation:** Passed cleanly with `-Xlint:all` (`exit code 0`, **0 errors, 0 warnings**).
- **Unit Testing (`T01`–`T11`):** **11 PASSED, 0 FAILED** on the first execution.
- **VM Instantiation Verification:** Confirmed directly via `ModulePlacementMapping.getDeviceToModuleMap()` across both normal topologies (`T07`: 48/48 VMs; `T11`: 12/12, 24/24, 36/36, 48/48, 96/96 VMs with 0 failures) and an intentionally RAM-starved synthetic Cloud (`T08b`: CloudSim rejected both `Sensor_Analyzer_0_0` and `Cloud_Storage_0_0`, tracked separately as `vmInstantiationFailureCount == 2` alongside `cloudFallbackCount == 1`).
- **Project Protection:** Zero edits to Phase 1, 2, or 2.2 Java classes, CSVs, raw logs, or historical reports. Full benchmark matrix execution has **not** been started.

---

## 2. Exact Files Created / Updated

### 2.1 New Java Source Files (`org.fog.lamp.baselines`)
1. [ModulePlacementLBMP.java](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java) — Core `LBMP_PURE` placement solver, verbatim Algorithms 1–3 (`MODULEMAP`, `LOWERBOUND`, `COMPARE`), runtime monotonicity guard + linear-scan fallback, Option A BW ledger, `Cloud_Storage` RAM/BW pre-reservation, explicit `cloudState` fallback, cumulative Cloud fallback-demand telemetry (`D-3.5-01`), and CloudSim VM instantiation verification.
2. [ModulePlacementLBMPTest.java](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMPTest.java) — Standalone deterministic unit test suite executing all 11 specification scenarios (`T01`–`T11`).
3. [BaselineSimulationRunner.java](iFogSim-main/src/org/fog/lamp/baselines/BaselineSimulationRunner.java) — Isolated CLI driver supporting both `SYMMETRIC` (reusing `HealthcareTopologyFactory`) and `ASYMMETRIC` (reusing `AsymmetricTopologyFactory`) runs with structured CSV output (`LBMP_SYMM_CSV_ROW` / `LBMP_ASYM_CSV_ROW`).

### 2.2 Documentation Files Created / Updated
1. [PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md](PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md) *(Created — this report, SHA-256 verified against artifact copy)*.
2. [CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md](CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md) *(Updated — marks `org.fog.lamp.baselines` implemented & unit-verified and documents `D-3.5-01`)*.
3. [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) *(Updated — adds Phase 3.5 report, Decision `D-3.5-01`, and Change Log entry)*.

---

## 3. Detailed Class, Method, Variable & Unit Documentation

### 3.1 `ModulePlacementLBMP` (`org.fog.lamp.baselines`)

#### Key Nested Data Types & Resource Units
| Type | Fields & Units | Purpose |
| :--- | :--- | :--- |
| `ResourceVector` | `mips` (`double`, MIPS), `ramMb` (`int`, MB), `bwUnits` (`long`, CloudSim VM BW units — Option A) | Immutable-copyable 3D resource tuple matching Taneja & Davy Eqs. (1) & (8). |
| `NodeState` | `device` (`FogDevice`), `canonicalName`, `tierRank` (`0`=GW, `1`=Proxy, `2`=Cloud), `numericIdx`, `isCloud`, `initial`, `available` | Mutable candidate ledger for each node in $N = N_F \cup N_C$ (Design C1). |
| `ModuleRequest` | `appId`, `moduleName`, `mobileName`, `gatewayIdx`, `mobileIdx`, `localGwName` *(telemetry only)*, `required` (`<700.0 MIPS, 10 MB, 1000 BW>`) | Dynamic `Sensor_Analyzer_i_j` placement request. |
| `FallbackRecord` | `appId`, `moduleName`, `fullDemand`, `cloudAvailableAtFallback`, `unmetDeficitMips`, `unmetDeficitRam`, `unmetDeficitBw` | Per-module unmet deficit record captured whenever Path 2 (`i == -1`) fires (`D-3.5-01`). |
| `VmInstantiationFailure` | `appId`, `moduleName`, `targetDeviceName`, `wasCloudFallback` | Actual CloudSim `HostEntity.guestCreate` rejection record (`D-3.4-08`). |

#### Core Methods & Algorithmic Responsibilities
| Method | Location | Semantics & Source Reference |
| :--- | :---: | :--- |
| `compare(NodeState, ModuleRequest)` | [ModulePlacementLBMP.java:295–302](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L295-L302) | Exact Algorithm 3 (Taneja & Davy p. 1226): returns `1` iff `mips >= && ramMb >= && bwUnits >=`, else `-1`. |
| `reserveResources(NodeState, ModuleRequest)` | [ModulePlacementLBMP.java:308–317](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L308-L317) | Algorithm 1 Line 9 (p. 1225): verifies eligibility and atomically decrements all 3 dimensions; throws `IllegalStateException` if ever called on an ineligible node. |
| `lowerBound(List<NodeState>, ModuleRequest, int, int)` | [ModulePlacementLBMP.java:326–348](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L326-L348) | Verbatim Algorithm 2 (p. 1226): `while (true)` binary search returning smallest eligible index or `-1`. |
| `isEligibilityMonotonic(List<NodeState>, ModuleRequest)` | [ModulePlacementLBMP.java:353–364](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L353-L364) | Runtime monotonicity guard (`D-3.4-08`): detects every `TRUE -> FALSE` drop across `nodes[]`. |
| `linearLowerBoundScan(List<NodeState>, ModuleRequest)` | [ModulePlacementLBMP.java:370–377](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L370-L377) | Exact ascending linear scan invoked **only** when `isEligibilityMonotonic` returns `false`. |
| `executeModuleMap(List<ModuleRequest>)` | [ModulePlacementLBMP.java:382–416](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L382-L416) | Algorithm 1 (`MODULEMAP`, p. 1225) with `low = 0` reset (`D-3.4-04`), monotonicity guard, Path 1 normal selection vs. Path 2 explicit `cloudState` fallback. |
| `preReserveFixedCloudStorage(...)` | [ModulePlacementLBMP.java:422–438](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L422-L438) | Fixed-module accounting convention (`D-3.4-07`): pre-reserves `10 MB` RAM and `1,000` Host BW per `Cloud_Storage_i_j` without going negative; excludes CPU. |
| `assignAnalyzerCloudFallback(ModuleRequest)` | [ModulePlacementLBMP.java:456–469](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L456-L469) | Path 2 fallback (`D-3.4-08`, `D-3.5-01`): targets explicit `cloudState`, logs individual `FallbackRecord` unmet deficit, accumulates full demand in `cloudFallbackDemandMips/Ram/Bw`, never decrements `cloudState.available`. |
| `verifyVmInstantiation(...)` | [ModulePlacementLBMP.java:471–495](iFogSim-main/src/org/fog/lamp/baselines/ModulePlacementLBMP.java#L471-L495) | Inspects `ModulePlacementMapping.getDeviceToModuleMap()` to count actual CloudSim VM instantiations (`vmInstantiationSuccessCount`) vs. failures (`vmInstantiationFailureCount`). |

### 3.2 `BaselineSimulationRunner` (`org.fog.lamp.baselines`)
- **CLI Modes:** `SYMMETRIC <numGateways> <numMobilesPerGw> [simTime]` and `ASYMMETRIC <gw0Mobiles> <gw1Mobiles> [simTime]`.
- **Reused Read-Only Factories:** `HealthcareTopologyFactory.createTopology(...)`, `AsymmetricTopologyFactory.createAsymmetricTopology(...)`, `HealthcareBSNApplication.createApplication(...)`.
- **Structured Telemetry:** Prints complete placement distribution, VM instantiation verification, search telemetry, cumulative Cloud fallback demand, per-node remaining ledger, analytical `module -> device` mappings, and `LBMP_SYMM_CSV_ROW:` / `LBMP_ASYM_CSV_ROW:` metrics.

---

## 4. Research Traceability Matrix

| Decision / Req | Paper / Spec Traceability | Java Implementation Location | Verified By |
| :---: | :--- | :--- | :---: |
| **D-3.4-01** | `LBMP_PURE` only (zero locality/affinity in decisions) | `ModulePlacementLBMP.NODE_ASC_COMPARATOR` (lines 145–151) | **T05, T09** |
| **D-3.4-02** | Defer `LBMP_AFFINITY`; exclude SAMP & `SA_SYNTHETIC` | Single pure policy in `org.fog.lamp.baselines` | Code audit |
| **D-3.4-03** | Option A BW (`Host.getBw()` vs `AppModule.getBw()`, CloudSim VM-layer approx.) | Lines 214–219 & 254–258 | **T01, T04, T07** |
| **D-3.4-04** | Multi-app adaptation: `low = 0` reset after `Sort(nodes[])` (replaces Alg. 1 Line 11 `low = i + 1`, Taneja & Davy p. 1225) | Lines 389–390 | **T05, T06, T11** |
| **D-3.4-05** | Design C1: Cloud inside `nodes[]` ($N = N_F \cup N_C$, Eqs. 2–6, p. 1224) | Lines 197–225 | **T07, T11** |
| **D-3.4-06** | Strict package isolation (`org.fog.lamp.baselines`) | Zero edits outside `baselines/` + docs | File audit |
| **D-3.4-07** | Fixed-module accounting convention: pre-reserve `Cloud_Storage` RAM (`10 MB`) & Host BW (`1,000`); exclude CPU for LAMP/EWMP comparability | `preReserveFixedCloudStorage` (lines 422–438) | **T07, T08b** |
| **D-3.4-08** | Separate Cloud normal vs. fallback; explicit `cloudState` ref; VM instantiation check via `getDeviceToModuleMap()`; monotonicity guard + linear scan | Lines 353–415, 456–495 | **T07, T08, T10, T11** |
| **D-3.5-01** | Cumulative Cloud fallback-demand telemetry (`cloudFallbackDemandMips/Ram/Bw`) + per-module unmet deficits; never decrement `cloudState` below zero | `FallbackRecord` (lines 95–120), `assignAnalyzerCloudFallback` (lines 456–469) | **T08a, T08b** |

---

## 5. Compilation & Unit Test Execution Record

### 5.1 Compilation Command & Result
```powershell
& "eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\javac.exe" -Xlint:all -cp "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*" -d "iFogSim-main\bin" "iFogSim-main\src\org\fog\lamp\baselines\ModulePlacementLBMP.java" "iFogSim-main\src\org\fog\lamp\baselines\ModulePlacementLBMPTest.java" "iFogSim-main\src\org\fog\lamp\baselines\BaselineSimulationRunner.java"
```
- **Exit Code:** `0`
- **Errors:** `0`
- **Warnings (`-Xlint:all`):** `0`

### 5.2 Unit Test Execution Command & Full Results (`T01`–`T11`)
```powershell
& "eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe" -cp "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*" org.fog.lamp.baselines.ModulePlacementLBMPTest
```

| Test ID | Scenario | Verified Assertions & VM Instantiation Check | Result |
| :---: | :--- | :--- | :---: |
| **T01** | Resource Equality Boundary | `compare == 1`; placed on `d-0`; remaining `<0.0, 0, 0>` | **PASS** |
| **T02** | Insufficient CPU Independently | `699.9 < 700.0` $\implies$ `compare == -1`; normal Cloud selection (`1`) | **PASS** |
| **T03** | Insufficient RAM Independently | `9 < 10` $\implies$ `compare == -1`; normal Cloud selection (`1`) | **PASS** |
| **T04** | Insufficient BW Independently | `999 < 1000` $\implies$ `compare == -1`; normal Cloud selection (`1`) | **PASS** |
| **T05** | Multiple Modules w/ Dynamic Re-Sorting | `d-0` consolidates 0–3 (`<0, 3960, 996000>`); `d-1` takes 4–5 (`1400`); `proxy`/`cloud` untouched | **PASS** |
| **T06** | `low = 0` Boundary Reset Verification | 12/12 packed onto 3 Fog nodes (`d-0:4, d-1:4, proxy:4`); 0 Cloud; 12 binary searches, 0 linear fallbacks | **PASS** |
| **T07** | Cloud Selected by Normal Comparison (iFogSim) | `2 GW x 8` ($N=16$): 12 Fog + 4 Cloud Normal (`0` fallback); Cloud remaining `<42000.0, 39800, 980000>`; **48/48 VMs instantiated (`0` failures)** | **PASS** |
| **T08** | Cloud Fallback, Cumulative Demand & VM Failure Separation | **(a)** `cloud` (`500 MIPS`) sorted BEFORE `d-0` (`600 MIPS`): fallback targeted explicit `cloudState` (`cloudFallbackCount == 2`, `cloudFallbackDemandMips == 1400.0`, `Ram == 20`, `Bw == 2000`, `cloudState.available.mips == 500.0` unchanged, individual unmet deficit `200.0 MIPS`). **(b)** Synthetic `5 MB` Cloud in iFogSim: `HostEntity.guestCreate` rejected `Sensor_Analyzer_0_0` & `Cloud_Storage_0_0` $\implies$ **`vmInstantiationSuccessCount == 1`, `vmInstantiationFailureCount == 2`**, fallback VM failure explicitly flagged (`wasCloudFallback == true`). | **PASS** |
| **T09** | Deterministic Tie Handling (5 Permutations) | `[2, 6]` asymmetric topology shuffled 5 ways produced 5 bit-for-bit identical mappings (`d-0`: `0_0, 0_1, 1_0, 1_1`; `d-1`: `1_2..1_5`) | **PASS** |
| **T10** | Monotonicity Guard & Linear-Scan Fallback | Predicate `[TRUE, FALSE, FALSE]` detected (`isEligibilityMonotonic == false`); `linearFallbackCount == 1`, `binarySearchCount == 0`; placed on `d-0` (no false Cloud fallback) | **PASS** |
| **T11** | Exact `3N` Module & VM Accounting ($N = 4, 8, 12, 16, 32$) | All 5 sizes passed `totalAnalyzers == N`, `planned == 3N`, **`vmInstantiationSuccessCount == 3N`**, `vmInstantiationFailureCount == 0`, `binarySearchCount == N`, `linearFallbackCount == 0`, Fog:Cloud splits `4:0, 8:0, 12:0, 12:4, 20:12` | **PASS** |

- **Total:** **11 PASSED, 0 FAILED** (`exit code 0`).
- **Failures Encountered During Implementation:** None (0 compilation errors, 0 test failures).

---

## 6. Deviations, Limitations & Unresolved Issues

- **Deviations from `PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md` (Rev. 2):** **None.** All decisions `D-3.4-01` through `D-3.4-08` and mandatory Phase 3.5 safeguard `D-3.5-01` were implemented verbatim.
- **Documented Methodological Limitations (Preserved Explicitly):**
  1. **Option A Bandwidth (`D-3.4-03`):** Uses `Host.getBw()` (`1,000,000`) vs. `AppModule.getBw()` (`1,000`), explicitly classified as a CloudSim VM-layer approximation rather than Taneja & Davy's static Figure 2 Mbps model.
  2. **Multi-App `low = 0` Adaptation (`D-3.4-04`):** Replaces published Algorithm 1 Line 11 (`low = i + 1`) to prevent premature 75% Fog abandonment on multi-application LAMP workloads.
  3. **Fixed-Module Accounting Convention (`D-3.4-07`):** `Cloud_Storage` RAM (`10 MB`) and Host BW (`1,000`) are pre-reserved in the LBMP analytical resource ledger while `Cloud_Storage` CPU is intentionally excluded to preserve comparability with LAMP/EWMP; consequently, the LBMP ledger is not a complete mirror of CloudSim's resource consumption.
  4. **Scope Exclusions (`D-3.4-02`):** `LBMP_AFFINITY` is deferred; historical `SAMP` (unverified primary text) and `SA_SYNTHETIC` are excluded.
- **Unresolved Issues:** **None.**

---

## 7. Stop Condition Confirmation

Implementation, compilation (`-Xlint:all`), all 11 unit tests (`T01`–`T11`), VM instantiation verification, and runner preparation (`BaselineSimulationRunner.java`) are complete. **The full symmetric (12 runs) and asymmetric (4 runs) `LBMP_PURE` simulation matrices have NOT been executed.**

Standing by for your review and explicit authorization to execute the full `LBMP_PURE` benchmark matrix.
