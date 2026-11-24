# LAMP MANUSCRIPT — FINAL SCIENTIFIC CORRECTION LOG

**Document Title:** Simulation-Based Reproduction and Comparative Evaluation of a Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications  
**Authors:** M. Yoshi Anurag and Ch. Jaswanth  
**Target Manuscript Files:** `FINAL_LAMP_RESEARCH_REPORT_REVISED.docx`, `FINAL_LAMP_RESEARCH_REPORT_REVISED.pdf`  
**Audit Date:** November 24, 2026  
**Auditor:** Autonomous Verification and Academic Documentation Agent (Antigravity)  
**Status:** ALL 8 MANDATORY CORRECTIONS VERIFIED (0 UNRESOLVED)

---

## 1. Executive Summary of Corrections

This log documents the comprehensive resolution of the 8 scientific, mathematical, and editorial issues identified during the publication audit of the IEEE-style research manuscript. All modifications strictly respect the non-negotiable research constraints:
- **Zero changes to Java source code** (`iFogSim-main/...`).
- **Zero new simulations executed**.
- **Zero modifications to historical CSV datasets, raw execution logs, or archived phase reports**.
- **Zero modifications to the frozen Research Traceability Matrix** (`RESEARCH_TRACEABILITY_MATRIX.md`, SHA-256: `a47a9d0352c81868c2179a409f6ac9806d8cd2c4d0eaefad0bb9603ee2b58693`).
- **Full alignment with primary empirical data** recorded in `results/lamp_reproduction_results_phase2.csv`, `results/asymmetric_validation_results.csv`, `results/lbmp_symmetric_results.csv`, and `results/lbmp_asymmetric_results.csv`.

---

## 2. Detailed Item-by-Item Correction Ledger

### Issue A: Abstract Symmetric Configuration Accounting
- **Location:** Page 1, Section: Abstract; mirrored in Section IX.A and Section XII.
- **Original Issue:** The manuscript claimed that LAMP achieved 100% loop completion in 9 of 12 symmetric configurations, but the parenthetical list named only 8 (`gw2_m2` to `gw2_m8`, `gw3_m2`, `gw3_m4`, `gw4_m2`, `gw4_m4`), omitting `gw3_m6`. Furthermore, the 3 partial-completion configurations were not explicitly named, and the root circumstance (heavy concurrent scale) was unstated.
- **Correction Made:**
  1. Added `gw3_m6` to the explicit parenthetical list of 100% loop completion configurations: `gw2_m2`, `gw2_m4`, `gw2_m6`, `gw2_m8`, `gw3_m2`, `gw3_m4`, `gw3_m6`, `gw4_m2`, `gw4_m4` (exactly 9 configurations).
  2. Explicitly named the 3 partial loop completion configurations: `gw3_m8`, `gw4_m6`, and `gw4_m8`.
  3. Contextualized that partial completion occurs under heavy concurrent scale within the finite 2,000-tick discrete-event horizon.
- **Evidence / Source Used:**
  - `results/lamp_reproduction_results_phase2.csv` (rows 14–25):
    - `gw2_m2`: 4/4 (100%, SUCCESS)
    - `gw2_m4`: 8/8 (100%, SUCCESS)
    - `gw2_m6`: 12/12 (100%, SUCCESS)
    - `gw2_m8`: 16/16 (100%, SUCCESS)
    - `gw3_m2`: 6/6 (100%, SUCCESS)
    - `gw3_m4`: 12/12 (100%, SUCCESS)
    - `gw3_m6`: 18/18 (100%, SUCCESS)
    - `gw3_m8`: 20/24 (83.3%, PARTIAL_COMPLETION, Delay: 613.94)
    - `gw4_m2`: 8/8 (100%, SUCCESS)
    - `gw4_m4`: 16/16 (100%, SUCCESS)
    - `gw4_m6`: 20/24 (83.3%, PARTIAL_COMPLETION, Delay: 447.32)
    - `gw4_m8`: 24/32 (75.0%, PARTIAL_COMPLETION, Delay: 614.81)
- **Verification Status:** **VERIFIED (CLOSED)**.

---

### Issue B: Analytical Module CPU Demand Derivation
- **Location:** Page 4, Section IV.B (`Sensor_Analyzer` Module Description) and Table I.
- **Original Issue:** The manuscript inverted the causal derivation by stating that each module demands 700 MIPS because the gateway has 2,800 MIPS and can host 4 modules.
- **Correction Made:** Restructured the derivation strictly according to application parameters:
  1. In Rezazadeh et al. [7] (Table I), raw EEG tuples have a computational length of $3,500\text{ MI}$ and arrive at $5.0\text{-second}$ intervals (tuple generation rate $\lambda = 0.2\text{ tuples/s}$).
  2. Primary demand is calculated as:
     $$\text{CPU Demand} = \lambda \times \text{Workload} = 0.2\text{ tuples/s} \times 3,500\text{ MI/tuple} = 700\text{ MIPS}$$
  3. Separately explained that because each Fog Gateway provides $2,800\text{ MIPS}$ CPU capacity (Table IV of [7]), a gateway can nominally accommodate:
     $$\text{Slot Capacity} = \frac{2,800\text{ MIPS}}{700\text{ MIPS/module}} = 4\text{ modules}$$
  4. Established that $M=4$ represents the balanced saturation threshold where local capacity equals incoming workload.
- **Evidence / Source Used:**
  - Rezazadeh et al. (2019) [7], Section IV, Table I: Tuple CPU length = 3,500 MI, Tuple inter-arrival time = 5.0 s.
  - Rezazadeh et al. (2019) [7], Section IV, Table IV: Fog Gateway MIPS = 2,800 MIPS.
- **Verification Status:** **VERIFIED (CLOSED)**.

---

### Issue C: Queueing Formulation and Simulator Execution Disambiguation
- **Location:** Page 4, Section V.A (Mathematical Formulation) and Equation (3).
- **Original Issue:** The manuscript presented a single-server $M/M/1$ queueing formula without clearly delineating what was published in the original literature versus how iFogSim actually computes task duration.
- **Correction Made:**
  1. Retained Equation (3) as published in Rezazadeh et al. [7]:
     $$t_a^m = Q_f^m + \Delta_{pp'} + Z \tag{3}$$
  2. Explicitly noted that Table II of Rezazadeh et al. [7] defines $Q_f^m$ (or $Q_p^m$) simply as the *"Time required to process the module $m$ on device $f$"*, without specifying an $M/M/1$ or closed-form queueing formula.
  3. Documented that in our iFogSim implementation, task execution duration is evaluated deterministically as:
     $$Q_f^m = \frac{\text{CloudletLength}}{\text{HostMIPS}} = \frac{3,500\text{ MI}}{2,800\text{ MIPS}} = 1.25\text{ seconds}$$
  4. Clarified that this corresponds to isolated execution without background queue backlog ($\lambda = 0$), avoiding any unsupported claims of closed-form $M/M/1$ equivalence.
- **Evidence / Source Used:**
  - Rezazadeh et al. (2019) [7], Section IV.A, Equations (3)–(4), and Table II.
  - `iFogSim-main/src/org/fog/placement/ModulePlacementLAMP.java` lines 98–112.
- **Verification Status:** **VERIFIED (CLOSED)**.

---

### Issue D: Asymmetric Evaluation Disambiguation and Table IV
- **Location:** Page 7, Section IX.B, Section IX.C, and Table IV.
- **Original Issue:** The asymmetric results table labelled the LAMP column ambiguously as "LAMP", creating potential confusion between the simulation-clock baseline (`LAMP_FWD`) and strict physical SI interpretation (`LAMP_PHYS`).
- **Correction Made:**
  1. Explicitly labelled the evaluation column in Table IV as `LAMP_FWD (Baseline Ticks)`.
  2. Verified that all values in Table IV match the corresponding primary dataset `results/asymmetric_validation_results.csv`:
     - $w_{2,6}$: Delay = 215.17, Net = 341.6 KB, Loops = 8/8 (100%), Status = SUCCESS
     - $w_{6,2}$: Delay = 216.19, Net = 341.3 KB, Loops = 8/8 (100%), Status = SUCCESS
     - $w_{6,6}$: Delay = 434.27, Net = 497.3 KB, Loops = 12/12 (100%), Status = SUCCESS
     - $w_{10,2}$: Delay = 310.23, Net = 439.1 KB, Loops = 10/12 (83.3%), Status = PARTIAL
  3. Included a dedicated comparative explanation detailing `LAMP_PHYS`:
     - In $w_{10,2}$, `LAMP_FWD` offloads 2 modules to Peer Gateway 1 (`6 : 2 : 4 : 0`), inducing proxy link serialization contention that yields 10/12 loops (83.3%).
     - Under `LAMP_PHYS`, cloud compute speedup outweighs WAN latency, routing the 6 overflow modules directly to the Cloud (`6 : 0 : 0 : 6`), which achieves 12/12 loops (100%, Delay = 380.11 ticks).
  4. Strictly prevented any substitution of `LAMP_PHYS` values into the `LAMP_FWD` column.
- **Evidence / Source Used:**
  - `results/asymmetric_validation_results.csv` (rows 1–8).
  - `results/lbmp_asymmetric_results.csv` (rows 1–4).
  - `PHASE_2_2_ASYMMETRIC_VALIDATION_REPORT.md`.
- **Verification Status:** **VERIFIED (CLOSED)**.

---

### Issue E: Fog Energy Reduction Reclassification
- **Location:** Page 8, Section X, and Table V.
- **Original Issue:** Table V previously classified the fog energy reduction claim as `NOT SUPPORTED (CONTRADICTED)`, overlooking the narrative statement in Rezazadeh et al. [7] regarding the modest increase in fog computing energy.
- **Correction Made:**
  1. Reclassified the item in Table V from `NOT SUPPORTED (CONTRADICTED)` to **`QUALITATIVE AGREEMENT`**.
  2. Documented the textual claim in Rezazadeh et al. [7] (Page 848): *"given the only 5% increase in fog computing (on average)"*.
  3. Reported our empirical measurements: an average increase of 4.72% in fog energy consumption across completed symmetric configurations (ranging between 5.34% and 5.51% at $M=4$), aligning with the paper's narrative claim despite the omission of numerical tables.
- **Evidence / Source Used:**
  - Rezazadeh et al. (2019) [7], Section V, Page 848, column 2, lines 18–22, and Figure 5.
  - `results/lamp_reproduction_results_phase2.csv` (Fog Energy columns across COMP, LAMP, EWMP).
- **Verification Status:** **VERIFIED (CLOSED)**.

---

### Issue F: Watchdog Timeout Explanation and Internal State Delineation
- **Location:** Page 5 (Section VI.B), Page 9 (Section XI.2), and Appendix.
- **Original Issue:** Earlier descriptions asserted that Phase 2 COMP watchdog timeouts (`gw3_m8` and `gw4_m8` at 240 seconds) were caused by tuple-queue memory exhaustion or event loop stalls, stating an internal mechanism as fact without logging evidence.
- **Correction Made:**
  1. Formulated the explanation strictly as an **architectural hypothesis** based on scale rather than an empirically measured internal state.
  2. Clarified that while centralized routing of 24–32 high-frequency tuple streams to a single cloud datacenter creates heavy discrete-event scheduling density, internal queue residency times and heap telemetry were not logged.
  3. Reaffirmed that unproduced metrics are strictly recorded as `N/A`, with exit code 143 documented.
- **Evidence / Source Used:**
  - `run_experiments_phase2.py` line 17 (`timeout=240`).
  - `PHASE_2_SIMULATION_VALIDATION_REPORT.md` Section 3.2.
  - `PHASE_3_7_FINAL_CONSISTENCY_ADDENDUM.md` Section 2.
- **Verification Status:** **VERIFIED (CLOSED)**.

---

### Issue G: Bibliographic Verification of Rezazadeh et al. (2019)
- **Location:** Page 9, Section: References, Citation [7].
- **Original Issue:** Citation [7] reported incorrect proceedings page numbers (`pp. 2943–2950`) from an erroneous draft template.
- **Correction Made:**
  1. Audited the primary source PDF: `A Hybrid Fog Cloud Latency Aware Module.pdf`.
  2. Verified the exact publication metadata:
     - Authors: Zeinab Rezazadeh, Mohammad Rezaei, and Mohsen Nickray
     - Conference: *2019 5th Conference on Knowledge-Based Engineering and Innovation (KBEI)*
     - Location & Date: Tehran, Iran, February 28 – March 1, 2019
     - Publisher: IEEE
     - Actual Page Numbers: **845–850** (first page 845, last page 850).
  3. Corrected Citation [7] in markdown, DOCX, and PDF to:
     `[7] Z. Rezazadeh, M. Rezaei, and M. Nickray (Mohsen Nickray), "LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications," in Proc. 2019 5th Conference on Knowledge-Based Engineering and Innovation (KBEI), Tehran, Iran, 2019, pp. 845–850.`
- **Evidence / Source Used:**
  - `A Hybrid Fog Cloud Latency Aware Module.pdf` (IEEE Xplore metadata, header, footer, and page folios).
- **Verification Status:** **VERIFIED (CLOSED)**.

---

### Issue H: Strict Simulation Accounting Across All Sections
- **Location:** Entire manuscript (Abstract, Section VI.B, Section IX.A, Section XII, and Appendix).
- **Original Issue:** Inconsistent counts and terminology across drafts (e.g., describing 70 result summaries as "70 successful simulations", obscuring partial completion runs).
- **Correction Made:**
  1. Standardized exact numerical accounting across all chapters:
     - **Symmetric Campaign:** Exactly 48 attempts $\to$ 46 result summaries produced, exactly 2 external watchdog timeouts (`gw3_m8`, `gw4_m8` under COMP).
     - **Asymmetric Campaign:** Exactly 24 attempts $\to$ 24 result summaries produced, 0 timeouts.
     - **Overall Total:** Exactly 72 simulation attempts $\to$ 70 result summaries produced, 2 watchdog timeouts.
     - **Phase 3.6 Baseline (`LBMP_PURE`):** Exactly 16 runs $\to$ 3 `SUCCESS`, 13 `PARTIAL_COMPLETION`, 0 TIMEOUT, 0 ERROR, 156/220 completed application loops (70.9% completion rate).
  2. Strictly disambiguated simulation execution success (producing a non-empty summary row) from application-loop completion ($k/N = 100\%$), highlighting that two COMP runs were partial ($k/N < 100\%$) and 13 LBMP runs were partial.
- **Evidence / Source Used:**
  - `results/lamp_reproduction_results_phase2.csv` (34 rows).
  - `results/lbmp_symmetric_results.csv` (12 rows).
  - `results/asymmetric_validation_results.csv` (20 rows).
  - `results/lbmp_asymmetric_results.csv` (4 rows).
  - Sum: $34 + 12 + 20 + 4 = 70$ result rows across $48 + 24 = 72$ attempts.
- **Verification Status:** **VERIFIED (CLOSED)**.

---

## 3. Verification Summary Table

| Issue ID | Correction Domain | Manuscript Section | Evidence Base | Status |
| :---: | :--- | :--- | :--- | :---: |
| **A** | Abstract Symmetric Configs | Abstract, Sec. IX.A, Sec. XII | `results/lamp_reproduction_results_phase2.csv` | **VERIFIED** |
| **B** | CPU Demand Derivation | Sec. IV.B, Table I | Rezazadeh et al. [7] Tables I & IV | **VERIFIED** |
| **C** | Queueing Formulation | Sec. V.A, Eq. (3) | Rezazadeh et al. [7] Eq. (3), iFogSim source | **VERIFIED** |
| **D** | Asymmetric Table IV | Sec. IX.B, Table IV | `results/asymmetric_validation_results.csv` | **VERIFIED** |
| **E** | Fog Energy Classification | Sec. X, Table V | Rezazadeh et al. [7] p. 848, Phase 2 CSV | **VERIFIED** |
| **F** | Watchdog Explanation | Sec. VI.B, Sec. XI.2 | `run_experiments_phase2.py`, Phase 2 reports | **VERIFIED** |
| **G** | Original Paper Citation | Sec. References [7] | Primary PDF `pp. 845–850` | **VERIFIED** |
| **H** | Experiment Counts | Abstract, Sec. VI, Appendix | All 4 master CSV result files (70 rows / 72 attempts) | **VERIFIED** |

---

## 4. Auditor Sign-Off

The 8 mandatory scientific corrections have been rigorously applied and programmatically verified across all manuscript formats (`.md`, `.docx`, `.pdf`). The research integrity constraints remain fully intact.
