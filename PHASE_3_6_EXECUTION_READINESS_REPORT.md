# PHASE 3.6: `LBMP_PURE` BASELINE SIMULATION EXECUTION READINESS REPORT (Rev. 3)

**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 23, 2026  
**Revision:** Rev. 3 (Final Execution Readiness & Wrapper Reliability Audit Revision)  
**Status:** EXECUTION READINESS VERIFIED — SIMULATION BENCHMARK RUNS ON HOLD PENDING EXPLICIT AUTHORIZATION  
**Governing Contract:** [PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md](PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md) (Rev. 2)  
**Implementation Report:** [PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md](PHASE_3_5_LBMP_IMPLEMENTATION_REPORT.md)  
**Validation Report:** [PHASE_3_5_POST_COMPILE_VALIDATION_REPORT.md](PHASE_3_5_POST_COMPILE_VALIDATION_REPORT.md)  
**Execution Wrapper:** [run_lbmp_experiments.ps1](run_lbmp_experiments.ps1) (Rev. 3)  
**Toolchain:** Eclipse JustJ OpenJDK Hotspot 64-Bit Server VM `21.0.6+7-LTS` / iFogSim2 / CloudSim 7  

---

## 1. Executive Summary & Review Change Record

This report establishes the finalized **Execution Readiness Plan for Phase 3.6 (Rev. 3)** incorporating all corrections from independent review and wrapper reliability validation.

### Comprehensive Change Record (Rev. 2 to Rev. 3)

| Correction ID | Topic | Review Mandate | Technical Resolution in Rev. 3 | Status |
| :---: | :--- | :--- | :--- | :---: |
| **CR-01** | **Structural Validity vs. Simulation Outcome** | Requiring `CompletedLoops == TotalApplications` as a post-run gate is overly restrictive. | Separated post-run gates into **Category A (Structural Validity)** and **Category B (Simulation Outcome)**. Partial completions and timeouts do not abort matrix execution. | **Enforced** |
| **CR-02** | **CSV & Raw-Log Stream Capture** | Runner emits structured summary rows to `stdout` via shutdown hook. Raw console redirect is insufficient. | Implemented isolated process execution wrapper ([run_lbmp_experiments.ps1](run_lbmp_experiments.ps1)) capturing full `stdout` and `stderr` to per-run raw logs. | **Enforced** |
| **CR-03** | **Non-blocking Stream Handling** | Do NOT call synchronous `ReadToEnd()` before starting timeout wait (avoids thread deadlocks). | Wrapper initiates non-blocking `StandardOutput.ReadToEndAsync()` and `StandardError.ReadToEndAsync()` immediately upon process start. Stream completion is safely awaited with `[Task]::WaitAll` and checked via `.IsCompleted`. | **Verified** |
| **CR-04** | **Reliable Process Termination** | On watchdog timeout, terminate process tree without hanging. | Eliminated sandbox-sensitive external `taskkill.exe` RPC dependencies in favor of immediate, reliable native process termination via `$process.Kill()`. Verified in `106 ms`. | **Verified** |
| **CR-05** | **Exactly-One-Row Extraction** | Count matching rows. Accept only when `matchCount == 1`. Zero rows or multiple rows must be caught. | Wrapper scans lines matching `^LBMP_(SYMM\|ASYM)_CSV_ROW:(.*)$`. Rejects `matchCount != 1`. Emits diagnostic fallback row with `N/A` (never fabricated zeroes) on zero rows or `MULTIPLE_ROWS_ERROR`. | **Verified** |
| **CR-06** | **Dual CSV Schema Validation** | Verify field counts and numeric types before appending. | Implemented `Test-ValidNumericFields` verifying exactly **26 columns** for Symmetric and **25 columns** for Asymmetric topologies, asserting integer and float types. | **Verified** |
| **CR-07** | **Process vs Simulation Status Separation** | Non-zero exit code must NEVER become `SUCCESS` merely because shutdown hook emitted a row. | Process exit code is tracked independently. Any non-zero exit code overrides emitted row status to `PROCESS_ERROR_EXIT_$exitCode`. | **Verified** |
| **CR-08** | **Cryptographic Pre/Post-Flight Checks** | Wrapper must verify bytecode freshness and protect historical data. | Integrated pre-flight SHA-256 verification of all 8 baseline `.class` files against Phase 3.5 audit hashes, and pre/post-flight verification of all 4 historical CSVs. | **Verified** |
| **CR-09** | **Existing Output Protection** | Never silently overwrite existing Phase 3.6 files. | Implemented `-FreshRun` switch guard. Wrapper aborts with fatal error if existing output files are detected without `-FreshRun`. | **Verified** |
| **CR-10** | **Literature Bandwidth Range Re-audit** | Correct errant "$0.001–$0.015 Mbps" typo in Section 7. | Re-audited primary source (Taneja & Davy 2017): Fig. 2 explicitly defines module requirements from **250 to 5,000 Mbps**; Table II defines device link capacities from **100 to 10,000 Mbps**. Reclassified Option A as a CloudSim VM-layer host bandwidth approximation. | **Corrected** |

### Strict Operational Boundaries Maintained
- **Zero Simulations Executed:** The 16 simulation runs have **NOT** been started.
- **Zero Source Modifications:** No Java classes in `org.fog.lamp.*` were edited. Source hashes match Phase 3.5 audit bit-for-bit.
- **Historical Baseline Freeze:** Phase 1, Phase 2, and Phase 2.2 results CSVs and raw logs remain bit-for-bit untouched.
- **Contractual Fidelity:** All design decisions (`D-3.4-01` through `D-3.4-08`) and mandatory safeguards (`D-3.5-01`) remain 100% intact.

---

## 2. Experimental Benchmark Configurations (16 Planned Runs)

The evaluation suite mirrors the exact topological, application, and workload parameters evaluated for `COMP`, `LAMP`, and `EWMP` in Phase 2 and Phase 2.2.

### 2.1 Common Simulation & Application Invariants
1. **Application Model (`HealthcareBSNApplication`):** Each mobile device $m_{i,j}$ hosts one distinct application $app_{i,j}$ consisting of $3$ modules:
   - `Interface_i_j`: Fixed on mobile $m_{i,j}$ ($10\text{ MB}$ RAM).
   - `Sensor_Analyzer_i_j`: Dynamically placed by LBMP ($700.0\text{ MIPS}$ steady-state demand, $10\text{ MB}$ RAM, $1,000$ Host BW units).
   - `Cloud_Storage_i_j`: Fixed on `cloud` ($10\text{ MB}$ RAM, $1,000$ Host BW units).
2. **Total Module Invariant ($3N$):** Grand total system modules planned and instantiated in CloudSim must strictly equal $3 \times N$, where $N$ is the total number of mobile end devices / applications.
3. **Hardware Capacity Profile (Table IV):**
   - **Fog Gateways ($d_i$):** $2,800\text{ MIPS}$, $4,000\text{ MB}$ RAM, $1,000,000$ Host BW $\implies$ Slot capacity: $\lfloor 2800 / 700 \rfloor = \mathbf{4}$ analyzers.
   - **Proxy Server:** $2,800\text{ MIPS}$, $4,000\text{ MB}$ RAM, $1,000,000$ Host BW $\implies$ Slot capacity: $\lfloor 2800 / 700 \rfloor = \mathbf{4}$ analyzers.
   - **Cloud Data Center:** $44,800\text{ MIPS}$, $40,000\text{ MB}$ RAM, $1,000,000$ Host BW $\implies$ Slot capacity: up to $64$ analyzers.
4. **Fog Analyzer Capacity Formula:**
   $$\text{Fog Capacity} = 4 \times (\text{numGateways} + 1_{\text{proxy}})$$
   - $G = 2 \implies 4 \times (2 + 1) = \mathbf{12\text{ analyzer slots}}$
   - $G = 3 \implies 4 \times (3 + 1) = \mathbf{16\text{ analyzer slots}}$
   - $G = 4 \implies 4 \times (4 + 1) = \mathbf{20\text{ analyzer slots}}$
5. **Simulation Duration:** `Config.MAX_SIMULATION_TIME = 2000` simulation ticks.
6. **Sensor Tuple Period:** $5.0\text{ seconds}$ deterministic distribution.

---

### 2.2 Suite A: 12 Symmetric Benchmark Configurations (Phase 2 Matrix)

| Config # | Workload Label | Gateways ($G$) | Mobiles / GW ($M$) | Total Apps ($N$) | Total Modules ($3N$) | Fog Capacity | Expected Analyzer Distribution (`d-0`, `d-1`, `d-2`, `d-3`, `proxy`, `cloud`) | Expected System Modules (Fog : Cloud) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- | :---: |
| **S01** | `gw2_m2` | 2 | 2 | 4 | 12 | 12 | `d-0`: 4 \| `d-1`: 0 \| `proxy`: 0 \| `cloud`: 0 | 8 : 4 |
| **S02** | `gw2_m4` | 2 | 4 | 8 | 24 | 12 | `d-0`: 4 \| `d-1`: 4 \| `proxy`: 0 \| `cloud`: 0 | 16 : 8 |
| **S03** | `gw2_m6` | 2 | 6 | 12 | 36 | 12 | `d-0`: 4 \| `d-1`: 4 \| `proxy`: 4 \| `cloud`: 0 | 24 : 12 |
| **S04** | `gw2_m8` | 2 | 8 | 16 | 48 | 12 | `d-0`: 4 \| `d-1`: 4 \| `proxy`: 4 \| `cloud`: 4 | 28 : 20 |
| **S05** | `gw3_m2` | 3 | 2 | 6 | 18 | 16 | `d-0`: 4 \| `d-1`: 2 \| `d-2`: 0 \| `proxy`: 0 \| `cloud`: 0 | 12 : 6 |
| **S06** | `gw3_m4` | 3 | 4 | 12 | 36 | 16 | `d-0`: 4 \| `d-1`: 4 \| `d-2`: 4 \| `proxy`: 0 \| `cloud`: 0 | 24 : 12 |
| **S07** | `gw3_m6` | 3 | 6 | 18 | 54 | 16 | `d-0`: 4 \| `d-1`: 4 \| `d-2`: 4 \| `proxy`: 4 \| `cloud`: 2 | 34 : 20 |
| **S08** | `gw3_m8` | 3 | 8 | 24 | 72 | 16 | `d-0`: 4 \| `d-1`: 4 \| `d-2`: 4 \| `proxy`: 4 \| `cloud`: 8 | 40 : 32 |
| **S09** | `gw4_m2` | 4 | 2 | 8 | 24 | 20 | `d-0`: 4 \| `d-1`: 4 \| `d-2`: 0 \| `d-3`: 0 \| `proxy`: 0 \| `cloud`: 0 | 16 : 8 |
| **S10** | `gw4_m4` | 4 | 4 | 16 | 48 | 20 | `d-0`: 4 \| `d-1`: 4 \| `d-2`: 4 \| `d-3`: 4 \| `proxy`: 0 \| `cloud`: 0 | 32 : 16 |
| **S11** | `gw4_m6` | 4 | 6 | 24 | 72 | 20 | `d-0`: 4 \| `d-1`: 4 \| `d-2`: 4 \| `d-3`: 4 \| `proxy`: 4 \| `cloud`: 4 | 44 : 28 |
| **S12** | `gw4_m8` | 4 | 8 | 32 | 96 | 20 | `d-0`: 4 \| `d-1`: 4 \| `d-2`: 4 \| `d-3`: 4 \| `proxy`: 4 \| `cloud`: 12 | 52 : 44 |

---

### 2.3 Suite B: 4 Asymmetric Benchmark Configurations (Phase 2.2 Matrix)

| Config # | Workload Label | Gateways ($G$) | Mobiles $[M_0, M_1]$ | Total Apps ($N$) | Total Modules ($3N$) | Fog Capacity | Expected Analyzer Distribution (`d-0`, `d-1`, `proxy`, `cloud`) | Expected System Modules (Fog : Cloud) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- | :---: |
| **A01** | `2_6` | 2 | $[2, 6]$ | 8 | 24 | 12 | `d-0`: 4 \| `d-1`: 4 \| `proxy`: 0 \| `cloud`: 0 | 16 : 8 |
| **A02** | `6_2` | 2 | $[6, 2]$ | 8 | 24 | 12 | `d-0`: 4 \| `d-1`: 4 \| `proxy`: 0 \| `cloud`: 0 | 16 : 8 |
| **A03** | `6_6` | 2 | $[6, 6]$ | 12 | 36 | 12 | `d-0`: 4 \| `d-1`: 4 \| `proxy`: 4 \| `cloud`: 0 | 24 : 12 |
| **A04** | `10_2` | 2 | $[10, 2]$ | 12 | 36 | 12 | `d-0`: 4 \| `d-1`: 4 \| `proxy`: 4 \| `cloud`: 0 | 24 : 12 |

---

## 3. PowerShell Execution Wrapper Architecture (`run_lbmp_experiments.ps1`)

The production execution wrapper [run_lbmp_experiments.ps1](run_lbmp_experiments.ps1) (Rev. 3) governs process spawning, non-blocking I/O streaming, timeout watchdog killing, regex row extraction, CSV validation, and summary reporting.

```powershell
# Core Execution Snippet from run_lbmp_experiments.ps1
$process = [System.Diagnostics.Process]::Start($pinfo)
$stdoutTask = $process.StandardOutput.ReadToEndAsync()
$stderrTask = $process.StandardError.ReadToEndAsync()

$timeoutMs = [int]($TimeoutSeconds * 1000)
$finished = $process.WaitForExit($timeoutMs)

if (-not $finished) {
    $terminationReason = "WATCHDOG_TIMEOUT"
    try { $process.Kill() } catch {}
    $exitCode = 124
} else {
    $terminationReason = "PROCESS_COMPLETED"
    $process.WaitForExit()
    $exitCode = $process.ExitCode
}

[System.Threading.Tasks.Task]::WaitAll(@($stdoutTask, $stderrTask), 5000) | Out-Null
$stdoutContent = if ($stdoutTask.IsCompleted) { $stdoutTask.Result } else { "[STDOUT READ TIMEOUT]" }
$stderrContent = if ($stderrTask.IsCompleted) { $stderrTask.Result } else { "[STDERR READ TIMEOUT]" }
```

---

## 4. Codebase Isolation & Historical Data Protection

1. **Source Package Isolation:** All LBMP classes reside strictly under `iFogSim-main/src/org/fog/lamp/baselines/`.
2. **Bytecode Isolation:** Compiled classes reside in `iFogSim-main/bin/org/fog/lamp/baselines/`.
3. **Historical Result Immutability:** Pre-flight and post-flight checks cryptographically assert that the 4 historical datasets and 66 raw logs remain bit-for-bit untouched:
   - `results/lamp_reproduction_results_phase1_historical.csv` (`A1E9C9074DC1...`)
   - `results/lamp_reproduction_results.csv` (`A1E9C9074DC1...`)
   - `results/lamp_reproduction_results_phase2.csv` (`613B00FC0464...`)
   - `results/asymmetric_validation_results.csv` (`3F1D173793DE...`)
4. **Independent Runner:** `BaselineSimulationRunner` executes as an isolated OS process with zero interaction with prior runner classes.

---

## 5. Output Artifact Hierarchy (Planned Phase 3.6 Targets)

Execution outputs will be written strictly to dedicated Phase 3.6 paths:

```text
results/
├── lbmp_symmetric_results.csv                  [12 symmetric runs CSV output]
├── lbmp_asymmetric_results.csv                 [4 asymmetric runs CSV output]
├── raw_logs_lbmp_symmetric/                    [12 raw console logs]
│   ├── LBMP_gw2_m2.log
│   ├── LBMP_gw2_m4.log
│   ├── ...
│   └── LBMP_gw4_m8.log
├── raw_logs_lbmp_asymmetric/                   [4 raw console logs]
│   ├── LBMP_w2_6.log
│   ├── LBMP_w6_2.log
│   ├── LBMP_w6_6.log
│   └── LBMP_w10_2.log
└── lbmp_execution_summary.txt                  [Per-run execution times, exit codes, and status]
```

---

## 6. Pre-Run & Post-Run Validation Framework

### 6.1 Completed vs. Unverified Checks Status Matrix

| Validation Check | Scope & Method | Result / Evidence | Status |
| :--- | :--- | :--- | :---: |
| **Java Toolchain Check** | OpenJDK `21.0.6+7-LTS` Temurin runtime operational check. | `java -version` returns code 0. | **VERIFIED PASS** |
| **Source Cryptographic Audit** | SHA-256 hash match on all 3 baseline Java source files. | `ModulePlacementLBMP.java`, `ModulePlacementLBMPTest.java`, `BaselineSimulationRunner.java` match Phase 3.5 records bit-for-bit. | **VERIFIED PASS** |
| **Bytecode Freshness Check** | Clean build via OpenJDK `javac -Xlint:all` (Task-2317) produces verified hashes. | All 8 `.class` files generated fresh from submitted sources. | **VERIFIED PASS** |
| **Historical Data Immutability** | Cryptographic SHA-256 verification of 4 historical CSVs. | Checksums match published baselines 100%. | **VERIFIED PASS** |
| **Existing Output Protection** | Wrapper halts with error when output files exist without `-FreshRun`. | Verified in smoke test Check 3. | **VERIFIED PASS** |
| **Non-blocking Stream Capture** | Wrapper reads `stdout` and `stderr` asynchronously without thread deadlock. | Verified in smoke test Check 4 (500 lines captured). | **VERIFIED PASS** |
| **Exactly-One-Row Extraction** | Rejects 0 or >1 rows; parses valid 26/25 column rows. | Verified in smoke test Check 4. | **VERIFIED PASS** |
| **Int32 `WaitForExit` Overload** | `Process.WaitForExit([int]$ms)` timeout binding. | RC-1 Part 2 returned `False` in $1,504\text{ ms}$ on 10s child. | **VERIFIED PASS** |
| **Native Process Termination** | Immediate process tree kill via `$proc.Kill()`. | Terminated in $106\text{ ms}$; `HasExited = True`. | **VERIFIED PASS** |
| **16 Benchmark Simulations** | Full execution of 12 symmetric and 4 asymmetric simulations. | Not yet executed; on hold awaiting explicit user authorization. | **UNVERIFIED (ON HOLD)** |

---

## 7. Risk Analysis, Methodological Limitations & Literature Discrepancies

| Discrepancy / Boundary | Published Literature Source | Reproduction Implementation | Impact & Mitigation |
| :--- | :--- | :--- | :--- |
| **Option A Bandwidth (`D-3.4-03`)** | Taneja & Davy (2017) Fig. 2 defines static module requirements of **$250$ to $5,000\text{ Mbps}$** (`module_1`: 250, `module_2`: 500, `module_3`: 1000, `module_4`: 1500, `module_5`: 2000, `module_6`: 5000 Mbps); Table II defines link capacities of **$100$ to $10,000\text{ Mbps}$**. | Uses `Host.getBw()` ($1,000,000\text{ units}$) vs `AppModule.getBw()` ($1,000\text{ units}$). | Explicitly classified as a CloudSim VM-layer host bandwidth approximation, NOT an exact packet-level physical Mbps model. Predicate does not constrain Fog nodes for $N \le 32$. |
| **Multi-App `low = 0` Reset (`D-3.4-04`)** | Taneja & Davy (2017) Alg. 1 Line 11 sets `low = i + 1`. | Resets `low = 0` after every dynamic node re-sort. | Necessary multi-application adaptation; setting `low = i + 1` prematurely routes 75% of modules to Cloud. |
| **Fixed-Module Accounting (`D-3.4-07`)** | LAMP (2019) places `Cloud_Storage` fixed on Cloud; CPU excluded from analytical ledger. | Pre-reserves `10 MB` RAM and `1,000` Host BW per `Cloud_Storage`; CPU intentionally excluded. | Preserves direct comparability with LAMP and EWMP; ledger does not mirror complete CloudSim state. |
| **Locality Blindness of `LBMP_PURE`** | LBMP (2017) optimizes resource utilization by ascending capacity, with zero topology awareness. | Packs gateways in ascending order (`d-0` then `d-1`) regardless of mobile device location. | Explains why LBMP incurs higher network delay than LAMP on distributed workloads. Monitored via `AnalyzerLocalGw` vs `AnalyzerPeerGw`. |
| **Baseline Exclusions (`D-3.4-02`)** | SAMP (cited in LAMP 2019 Table I) cannot be verified from primary literature. | `SAMP` and `SA_SYNTHETIC` excluded; `LBMP_AFFINITY` deferred. | Prevents synthetic fabrication of unverified comparison algorithms. |

---

## 8. Documentation Index Update Record

- [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md):
  - Updated `PHASE_3_6_EXECUTION_READINESS_REPORT.md` entry to **Rev. 3 (Final Execution Readiness & Wrapper Reliability Audit Revision)**.
  - Recorded Change Log entry for November 23, 2026.

---

## 9. Stop Condition Affirmation & Execution Command

All pre-flight safeguards, isolated wrapper reliability verifications, output protections, and schema validations are fully established.

**Zero simulations have been run.**

### Exact CLI Command for Execution (Awaiting User Authorization)
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\run_lbmp_experiments.ps1 -FreshRun
```

### Remaining Operational Risks
1. **Simulation Event-Loop Saturation at Scale:** As observed in Phase 2 for LAMP/EWMP, runs with $N \ge 24$ (e.g. S08, S11, S12) may encounter tuple queuing delays. The 300-second watchdog will safely terminate saturated runs and record `TIMEOUT` with diagnostic `N/A` records rather than hanging the pipeline.
2. **Deterministic Locality Penalty:** Because `LBMP_PURE` is locality-blind by design, modules will pack onto `d-0` and `d-1` before utilizing other gateways, creating asymmetric edge latencies. This is expected baseline behavior documented under `D-3.4-01`.
