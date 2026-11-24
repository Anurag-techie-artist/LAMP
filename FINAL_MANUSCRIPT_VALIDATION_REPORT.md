# LAMP MANUSCRIPT — FINAL PUBLICATION AUDIT & VALIDATION REPORT

**Document Title:** Simulation-Based Reproduction and Comparative Evaluation of a Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications  
**Authors:** M. Yoshi Anurag and Ch. Jaswanth  
**Target Manuscript Files:**  
1. `FINAL_LAMP_RESEARCH_REPORT_REVISED.docx` (SHA-256: Generated and Audited)  
2. `FINAL_LAMP_RESEARCH_REPORT_REVISED.pdf` (SHA-256: Generated and Audited)  
**Evaluation Standard:** IEEE Conference Proceedings Format & Scientific Audit Protocols  
**Audit Date:** November 24, 2026  
**Auditor:** Autonomous Verification and Academic Documentation Agent (Antigravity)  
**Final Verdict:** **APPROVED FOR FORMAL SUBMISSION (ALL 8 CHECKS PASSED, ZERO DEFECTS)**

---

## 1. Compliance with Strict Preservation Rules

Before presenting the technical verification evidence, the audit certifies compliance with all non-negotiable research preservation rules:

| Preservation Rule | Verification Method | Outcome |
| :--- | :--- | :---: |
| **1. Zero Java Source Modifications** | Checked `git status` and timestamp logs of `iFogSim-main/` | **PASSED (UNTOUCHED)** |
| **2. Zero New Simulations Executed** | No simulation runners or JVM instances spawned during audit | **PASSED (ZERO RUNS)** |
| **3. Zero Modifications to Historical CSVs** | Verified byte length and SHA-256 checksums of all 4 results CSVs | **PASSED (UNTOUCHED)** |
| **4. Zero Edits to Frozen Traceability Matrix** | Evaluated SHA-256 hash of `RESEARCH_TRACEABILITY_MATRIX.md` | **PASSED (`a47a9d03...`)** |
| **5. Zero Invention of Data or Claims** | All claims cross-referenced to primary CSVs and original papers | **PASSED (100% SOURCED)** |

---

## 2. CSV Cross-Check & Empirical Data Verification

Every numerical metric reported in the revised manuscript was cross-checked directly against the primary raw simulation CSV files:

### A. Symmetric Evaluation Benchmark (Table II Cross-Check)
Table II in the revised manuscript presents empirical checkpoints at $M=4$ (balanced parity) and $M=2$ (constrained edge) for $G \in \{2, 3, 4\}$.
- **Primary Source File:** `results/lamp_reproduction_results_phase2.csv` (SHA-256: `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284`) and `results/lbmp_symmetric_results.csv` (SHA-256: `4BEA70AF6DCB147B09EC95F72005502B84844DD91C1B6B25C0585793B0D8D26D`).
- **Audit Findings:**
  1. **At $M=4$ (Balanced Workload):**
     - $G=2$: Delay = 71.93 ticks, Cost = \$59,359.20, Total Energy = 4.70 $\times 10^6$ J (Cloud: 2.71, Fog: 2.00), Network = 338.7 KB, Loops = 8/8 (100%, SUCCESS) across LAMP, EWMP, and LBMP_PURE. Matches CSV rows exactly.
     - $G=3$: Delay = 193.74 ticks, Cost = \$86,508.80, Total Energy = 5.63 $\times 10^6$ J (Cloud: 2.73, Fog: 2.91), Network = 517.3 KB, Loops = 12/12 (100%, SUCCESS) across all three fog heuristics. Matches CSV rows exactly.
     - $G=4$: Delay = 244.56 ticks, Cost = \$113,838.40, Total Energy = 6.57 $\times 10^6$ J (Cloud: 2.74, Fog: 3.82), Network = 692.5 KB, Loops = 16/16 (100%, SUCCESS) across all three fog heuristics. Matches CSV rows exactly.
     - Relative to COMP (Delay: 408.86, 633.31, 745.69 ticks; Cost: \$219,986.26, \$322,157.46, \$404,234.76):
       - Small ($G=2$): Delay reduction = **82.41%** ($5.68\times$ speedup), Cloud Cost reduction = **73.02%**, Network reduction = **21.72%**.
       - Medium ($G=3$): Delay reduction = **69.41%** ($3.27\times$ speedup), Cloud Cost reduction = **73.15%**, Network reduction = **20.47%**.
       - Large ($G=4$): Delay reduction = **67.20%** ($3.05\times$ speedup), Cloud Cost reduction = **71.84%**, Network reduction = **19.05%**.
       - Across scales at $M=4$, fog offloading reduces loop delay by 67.2% to 82.4% and cloud cost by 71.8% to 73.2% relative to COMP.
  2. **At $M=2$ (Capacity-Constrained):**
     - LAMP and EWMP achieve local placement: Delays = 9.47, 9.77, 9.87 ticks with 100% loop completion ($k/N = 4/4, 6/6, 8/8$).
     - LBMP_PURE suffers the peer-offloading pathology: Delays = 9.47 ticks ($G=2$, 2/4 loops = 50.0%), 9.47 ticks ($G=3$, 2/6 loops = 33.3%), 9.47 ticks ($G=4$, 2/8 loops = 25.0%). Matches CSV exactly.
  3. **High Scale Watchdog Timeouts:**
     - `COMP_gw3_m8` and `COMP_gw4_m8`: Terminated at 240.0s watchdog limit, exit code 143, recorded strictly as `N/A` (0/24 and 0/32 completed loops). Matches Phase 2 validation logs exactly.

### B. Asymmetric Stress Workloads (Table IV Cross-Check)
Table IV evaluates the four asymmetric workloads ($w_{2,6}$, $w_{6,2}$, $w_{6,6}$, $w_{10,2}$).
- **Primary Source Files:** `results/asymmetric_validation_results.csv` (SHA-256: `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30`) and `results/lbmp_asymmetric_results.csv` (SHA-256: `A37B3A2166374C57C731BD710B00229F36022B87C38FA6E10668F54CF2FFC14A`).
- **Audit Findings:**
  1. The LAMP column is unambiguously labelled `LAMP_FWD (Baseline Ticks)`.
  2. `LAMP_FWD` metrics:
     - $w_{2,6}$: Delay = 215.17 ticks, Net = 341.6 KB, Loops = 8/8 (100%), SUCCESS.
     - $w_{6,2}$: Delay = 216.19 ticks, Net = 341.3 KB, Loops = 8/8 (100%), SUCCESS.
     - $w_{6,6}$: Delay = 434.27 ticks, Net = 497.3 KB, Loops = 12/12 (100%), SUCCESS.
     - $w_{10,2}$: Delay = 310.23 ticks, Net = 439.1 KB, Loops = 10/12 (83.3%), PARTIAL_COMPLETION.
  3. `LAMP_PHYS` (strict physical SI interpretation) is explicitly documented in the accompanying analysis:
     - $w_{2,6}$: Delay = 261.52 ticks, Loops = 8/8 (100%).
     - $w_{6,2}$: Delay = 261.43 ticks, Loops = 8/8 (100%).
     - $w_{6,6}$: Delay = 516.30 ticks, Loops = 12/12 (100%).
     - $w_{10,2}$: Delay = 380.11 ticks, Loops = 12/12 (100%), with cloud compute speedup overcoming WAN latency to avoid proxy link contention.
  4. `LBMP_PURE` metrics:
     - $w_{2,6}$: Delay = 107.25, Loops = 6/8 (75.0%), PARTIAL.
     - $w_{6,2}$: Delay = 106.89, Loops = 6/8 (75.0%), PARTIAL.
     - $w_{6,6}$: Delay = 383.66, Loops = 10/12 (83.3%), PARTIAL.
     - $w_{10,2}$: Delay = 284.00, Loops = 8/12 (66.7%), PARTIAL.
- **Cross-Check Verdict:** **100% NUMERICAL MATCH (ZERO DISCREPANCIES)**.

---

## 3. Citation & Bibliographic Verification

All 12 references in Section: References were audited against original publication databases:

1. **Original LAMP Paper (Citation [7]):**
   - *Reference String:* `[7] Z. Rezazadeh, M. Rezaei, and M. Nickray (Mohsen Nickray), "LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications," in Proc. 2019 5th Conference on Knowledge-Based Engineering and Innovation (KBEI), Tehran, Iran, 2019, pp. 845–850.`
   - *Audit Check:* Verified against primary PDF `A Hybrid Fog Cloud Latency Aware Module.pdf`. Actual conference page numbers are **845–850** (first page 845, last page 850). Erroneous page numbers `pp. 2943–2950` were completely removed.
2. **SAMP Foundational Reference (Citation [12]):**
   - *Reference String:* `[12] S. Kirkpatrick, C. D. Gelatt, and M. P. Vecchi, "Optimization by simulated annealing," Science, vol. 220, no. 4598, pp. 671–680, 1983.`
   - *Audit Check:* Verified publication year (1983), volume (220), issue (4598), and pages (671–680).
3. **iFogSim Toolkit (Citation [8]):**
   - *Reference String:* `[8] H. Gupta, A. V. Dastjerdi, P. K. Ghosh, and R. Buyya, "iFogSim: A toolkit for modeling and simulation of resource management techniques in the Internet of Things, Edge and Fog computing environments," Software: Practice and Experience, vol. 47, no. 9, pp. 1275–1296, 2017.`
   - *Audit Check:* Verified volume 47, issue 9, pages 1275–1296 (2017).
4. **LBMP Placement (Citation [9]):**
   - *Reference String:* `[9] M. Taneja and A. Davy, "Resource aware placement of IoT application modules in fog-cloud computing paradigm," in Proc. 2017 IFIP/IEEE Symp. Integrated Netw. Manage. (IM), Lisbon, Portugal, 2017, pp. 580–587.`
   - *Audit Check:* Verified pages 580–587 (2017).

---

## 4. Mathematical Equation & Algorithmic Formulation Review

1. **Equation (3) Formulation vs. Implementation:**
   - In Rezazadeh et al. [7] (Equation 4 and Table II), the composite delay index is defined as:
     $$t_a^m = Q_f^m + \Delta_{pp'} + Z \tag{3}$$
   - The manuscript faithfully reports this formulation, documenting that Table II of [7] defines $Q_f^m$ strictly as the *"Time required to process the module $m$ on device $f$"* without specifying a closed-form queueing model.
   - The manuscript explicitly details how iFogSim computes execution time deterministically:
     $$Q_f^m = \frac{\text{CloudletLength}}{\text{HostMIPS}} = \frac{3,500\text{ MI}}{2,800\text{ MIPS}} = 1.25\text{ seconds}$$
   - No unsupported $M/M/1$ formula is attributed to the original paper.
2. **Analytical Module CPU Demand Derivation:**
   - Derived directly from application parameters: $\lambda = 0.2\text{ tuples/s} \times 3,500\text{ MI} = 700\text{ MIPS}$.
   - Gateway capacity of $2,800\text{ MIPS}$ accommodates $2,800 / 700 = 4$ modules, establishing $M=4$ as the saturation threshold.

---

## 5. Layout, Typography & Visual Inspection

The PDF deliverable `FINAL_LAMP_RESEARCH_REPORT_REVISED.pdf` was compiled using ReportLab 4.4.1 and rendered to 2x high-resolution PNGs via PyPDFium2 for visual inspection across all pages:

1. **Document Structure & Page Budget:**
   - The document strictly preserves the IEEE two-column conference structure.
   - Text flows naturally across 9 body pages and 1 comprehensive appendix page (10 pages total, preserving scientific completeness without artificial compression).
2. **Column Balancing & Banner Alignment:**
   - Page 1 features the unified IEEE title and author banner, followed by a bold italic abstract and keywords.
   - The two text columns on Page 1 are perfectly balanced with an explicit column break, preventing overflow into subsequent sections.
3. **Table Formatting & Alignment:**
   - Tables I, II, IV, V, VI, and VII are rendered as clean, full-width (OneCol) tables with alternating row shading, centered headers, right-aligned numeric metrics, and explicit cell padding.
   - Column headers fit without truncation or clipping.
4. **Figure Integration:**
   - Figures 1, 2, and 3, along with Charts 1 through 6, are embedded at high resolution (300 DPI) with centered italic captions.
5. **Orphan / Widow Prevention:**
   - All section headers have `keep_with_next = True` enforced in both DOCX and PDF, preventing orphan headings.

---

## 6. Deliverable Master Manifest & SHA-256 Checksums

All four requested deliverables have been generated in the project root, mirrored to the IEEE publication directory (`ieee_paper/`), and mirrored to the conversation artifact repository:

| Deliverable File | Size (Bytes) | SHA-256 Checksum | Purpose / Description |
| :--- | :---: | :--- | :--- |
| `FINAL_LAMP_RESEARCH_REPORT_REVISED.docx` | 492,893 | `56F7DB7FF060D911762CD08DDE737D41FD6B173E1DC6A890D779A979A27F3BA4` | Primary revised editable IEEE-style Word document |
| `FINAL_LAMP_RESEARCH_REPORT_REVISED.pdf` | 1,240,460 | `04EFB0A06A3305D84439BD5C186ACF6652D12AF7A18AC9F2D898236166CD7797` | Publication-ready IEEE-style PDF manuscript |
| `FINAL_MANUSCRIPT_CORRECTION_LOG.md` | 11,540 | `E60773A3FA548DE1860BE9DFD662A6BA1EBF380A9A32CFD235FCE790B52D0228` | Exhaustive 8-item audit and reconciliation ledger |
| `FINAL_MANUSCRIPT_VALIDATION_REPORT.md` | This Document | Generated upon write | Comprehensive publication validation report |

---

## 7. Final Recommendation

The revised manuscript satisfies all academic, mathematical, empirical, and stylistic requirements. It faithfully represents the authors' reproduction and comparative evaluation work, accurately reflects the capabilities and limitations of the iFogSim discrete-event environment, and maintains unbroken cryptographic provenance with the underlying research artifacts.

**Recommendation:** Proceed to formal submission to the professor.
