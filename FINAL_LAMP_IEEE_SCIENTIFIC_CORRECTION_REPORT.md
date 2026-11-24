# LAMP IEEE Manuscript — Final Scientific-Content Correction Report

**Document Title:** Simulation-Based Reproduction and Comparative Evaluation of a Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications  
**Authors:** M. Yoshi Anurag and Ch. Jaswanth  
**Target Venue:** IEEE Conference Format (9-Page Standard Architecture)  
**Audit Date:** November 24, 2026  
**Status:** ALL 11 MANDATORY SCIENTIFIC CORRECTIONS COMPLETED AND VERIFIED  
**Frozen Matrix SHA-256:** `a47a9d0352c81868c2179a409f6ac9806d8cd2c4d0eaefad0bb9603ee2b58693` (Strictly Unmodified)

---

## Executive Summary

Following an independent scientific-content review of the 9-page IEEE conference manuscript (`FINAL_LAMP_IEEE_RESEARCH_PAPER`), exactly eleven (11) mandatory scientific and technical corrections were identified and audited against primary simulation datasets, source code, and historical logs. 

All 11 corrections have been comprehensively resolved across the entire manuscript publication suite:
1. Markdown source: `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.md` (and workspace root / artifacts).
2. Editable Word manuscript: `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.docx` (and workspace root / artifacts).
3. Publication PDF: `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.pdf` (and workspace root / artifacts).
4. High-resolution rendered page images: `ieee_paper/rendered_pages/page_1.png` through `page_9.png`.

The 9-page layout geometry, running headers/footers, and visual table alignments have been verified with zero text overlaps, zero orphan headings, and 100% metric consistency across Abstract, Methodology, Results, Discussion, Conclusion, and Appendix.

---

## Detailed Audit and Reconciliation of the 11 Mandatory Corrections

### Correction 1: Nuanced Accounting of LAMP Loop-Completion Rates

- **Original Defect / Location:** 
  The manuscript previously asserted blanket claims that LAMP maintains "100% loop completion across all workloads" (Abstract, Section VIII.C, Section XII).
- **Primary Evidence Base:**
  - `results/lamp_reproduction_results_phase2.csv` (Symmetric scale benchmark).
  - `results/asymmetric_validation_results.csv` (Asymmetric stress benchmark).
  - *Empirical Breakdown:*
    - In asymmetric workloads (Phase 2.2): LAMP achieved 100% completion (`SUCCESS`) across all 4 workloads ($w_{2,6}: 8/8$, $w_{6,2}: 8/8$, $w_{6,6}: 12/12$, $w_{10,2}: 12/12$).
    - In symmetric configurations (Phase 2): LAMP achieved 100% completion (`SUCCESS`) in 9 of 12 configurations ($M \in \{2, 4\}$ across all gateway scales $G \in \{2, 3, 4\}$, and all configurations for $G=2$ up to $M=8$).
    - In the 3 densest symmetric scale configurations (`gw3_m8`: 24 apps, `gw4_m6`: 24 apps, `gw4_m8`: 32 apps), LAMP encountered `PARTIAL_COMPLETION` under the finite 2,000-tick simulation horizon due to event queue accumulation under heavy concurrent arrivals.
- **Revised Text:**
  - *Abstract:* "In contrast, LAMP achieved 100% loop completion across all 4 asymmetric stress workloads and across 9 of 12 symmetric configurations ($M \in \{2,4\}$ across all gateway scales, and all configurations for $G=2$ up to $M=8$), while encountering partial completion in the 3 densest symmetric scale configurations (`gw3_m8`, `gw4_m6`, and `gw4_m8`) under the finite 2,000-tick horizon due to gateway and cloudlet queue backlogs under heavy concurrent arrivals."
  - *Section VIII.C & Section XII:* Updated with identical nuanced completion accounting.
- **Resolution Status:** Fully resolved and verified.

---

### Correction 2: Correction of Appendix Dataset Accounting

- **Original Defect / Location:** 
  Appendix A and Section VIII.A previously stated that a "48-row symmetric dataset" existed, conflating simulation attempts with emitted summary records.
- **Primary Evidence Base:**
  - `results/lamp_reproduction_results_phase2.csv` contains exactly 34 summary rows.
  - `results/lbmp_symmetric_results.csv` contains exactly 12 summary rows.
  - Total symmetric result summaries emitted: $34 + 12 = 46$ rows.
  - Two dense COMP runs (`COMP_gw3_m8` and `COMP_gw4_m8`) encountered external process watchdog timeouts at 240 seconds and emitted no summary rows in CSV (recorded strictly as N/A in tables).
  - Asymmetric campaign: 20 rows (`asymmetric_validation_results.csv`) + 4 rows (`lbmp_asymmetric_results.csv`) = 24 rows across 24 attempts (0 timeouts).
  - Total across all campaigns: 72 attempts, 70 result summaries, 2 watchdog timeouts.
- **Revised Text:**
  - *Appendix A:* "The complete symmetric experimental campaign (48 attempts, 46 result summaries, 2 watchdog timeouts) and asymmetric campaign (24 attempts, 24 result summaries, 0 timeouts), yielding 70 result summaries across 72 total attempts, are preserved in `results/lamp_reproduction_results_phase2.csv` (34 rows), `results/lbmp_symmetric_results.csv` (12 rows), `results/asymmetric_validation_results.csv` (20 rows), and `results/lbmp_asymmetric_results.csv` (4 rows)."
  - *Section VIII.A:* "In total, 70 runs produced valid result summaries across 72 attempts, while 2 runs were watchdog-terminated."
- **Resolution Status:** Fully resolved and verified.

---

### Correction 3: LBMP Peer-Offloading Causal Explanation Refinement

- **Original Defect / Location:** 
  Section VIII.D asserted definitive tuple-level queueing causality ("introduces significant inter-device queuing latency... return tuples fail to complete") without explicit delineation between directly observed telemetry and inferred queuing hypotheses.
- **Primary Evidence Base:**
  - Raw placement allocations recorded in simulation execution logs and CSV files confirm module placement across peer gateways.
  - Completed loop counters (`k/N`) confirm 50.0% ($G=2$), 33.3% ($G=3$), and 25.0% ($G=4$) loop completion.
  - Discrete-event queue residency times for individual tuples were not logged in standard iFogSim output files.
- **Revised Text:**
  - *Section VIII.D:* "While LAMP and `LBMP_PURE` achieve parity at $M=4$, their placement behavior diverges dramatically under capacity-constrained ($M=2$) and overloaded ($M \ge 6$) conditions. At $M=2$, each gateway receives only two 700-MIPS modules (1,400 MIPS demand out of 2,800 MIPS capacity). In `LBMP_PURE`, modules are sorted globally by resource requirement and assigned via binary search over all available nodes sorted by capacity. In our multi-application topology, Gateway 0 is evaluated first and filled with modules originating from Gateway 1, forcing Gateway 1's subsequent modules to be placed across horizontal inter-gateway peer paths via the proxy server.<br/><br/>*Observed Outcomes vs Hypothesized Mechanisms:* Placement ledgers confirm that `LBMP_PURE` assigns Gateway 1 modules to Gateway 0. Under the 2,000-tick simulation horizon, application loop completion rates drop to 50.0% ($G=2$), 33.3% ($G=3$), and 25.0% ($G=4$). It is hypothesized that multi-hop tree routing through the proxy server, combined with event scheduling contention on the receiving gateway, delays return tuples past the 2,000-tick horizon (individual tuple-level queue residency times were not captured by standard iFogSim telemetry)."
- **Resolution Status:** Fully resolved and verified.

---

### Correction 4: Queueing-Delay Equation (Equation 3) Audit and Clarification

- **Original Defect / Location:** 
  Equation (3) presented $Q_p^m = \frac{L_m}{\mu_p - \lambda_p}$ as queue waiting time, claiming it simplifies to $L_m / MIPS_p$ without establishing the formal mathematical assumptions and literature definitions.
- **Primary Evidence Base:**
  - Rezazadeh et al. (2019), Table II defines $Q_f^m$ as: *"Time required to process the module $m$ on device $f$"*.
  - In classical single-server $M/M/1$ queueing theory, average total sojourn time (waiting + service) is $W = 1 / (\mu - \lambda)$.
  - Mathematically, simplifying $L_m / (\mu_p - \lambda_p)$ to the deterministic processing time $L_m / \text{MIPS}_p$ strictly requires assuming $\lambda_p = 0$ (or $\lambda_p \ll \mu_p$, i.e., an idle device with negligible queue backlog).
  - In iFogSim, task execution duration is evaluated deterministically as `cloudlet.getCloudletLength() / device.getHost().getTotalMips()`.
- **Revised Text:**
  - *Section V.A.1:* "1. **Queueing Delay ($Q_p^m$):** In Table II of Rezazadeh et al. [7], $Q_f^m$ is defined as the *'Time required to process the module $m$ on device $f$'*. When modeled as a single-server $M/M/1$ queue with service rate $\mu_p$ and arrival rate $\lambda_p$, the average system time (waiting plus service) is expressed as:
  $$Q_p^m = \frac{L_m}{\mu_p - \lambda_p} \tag{3}$$
  where $L_m$ represents the task workload in Million Instructions (MI), $\mu_p$ denotes the service rate (MIPS), and $\lambda_p$ is the aggregate arrival rate. Mathematically, reducing this formulation to the isolated execution duration $Q_p^m = L_m / MIPS_p$ requires assuming $\lambda_p = 0$ (or $\lambda_p \ll \mu_p$, reflecting an idle device with negligible queue backlog). In iFogSim, task processing time is evaluated deterministically as `cloudlet.getCloudletLength() / device.getHost().getTotalMips()`."
- **Resolution Status:** Fully resolved and verified.

---

### Correction 5: Technical Derivation of 8 ms Peer Traversal Latency

- **Original Defect / Location:** 
  Table I and Section IV.A previously described 8.0 ms inter-gateway latency without clarifying the underlying network topology routing model.
- **Primary Evidence Base:**
  - `iFogSim` enforces a hierarchical tree topology with no direct horizontal peer links between gateways.
  - `ModulePlacementLAMP.java` lines 326–380 implement `computeOneWayLatency(source, dest)` using a Lowest Common Ancestor (LCA) tree traversal:
    `gw-0 -> proxy-server (4.0 ms) -> gw-1 (4.0 ms) = 8.0 ms`.
- **Revised Text:**
  - *Section IV.A (Tier 3):* "An intermediate aggregation server (`proxy-server`) interconnects all fog gateways within a regional domain. The proxy server possesses 2,800 MIPS CPU and 4,000 MB RAM, communicating with gateways over 4.0 ms links. Note that there is no direct horizontal physical link between peer gateways; iFogSim enforces a strict tree topology. Inter-gateway peer traversal follows the dynamic Lowest Common Ancestor (LCA) tree routing path evaluated by `computeOneWayLatency`: `gw-0 -> proxy (4.0 ms) -> gw-1 (4.0 ms) = 8.0 ms`."
  - *Table I:* Row updated to: `Lowest Common Ancestor tree routing via proxy (4.0 + 4.0 ms)`.
- **Resolution Status:** Fully resolved and verified.

---

### Correction 6: Table II Title Definition and Transcription Error Corrections

- **Original Defect / Location:** 
  Table II was titled "Execution Energy ($10^6$ J)" without clarifying whether it represented host CPU energy or total system energy, and contained minor historical transcription errors from raw CSV datasets.
- **Primary Evidence Base:**
  - Primary CSV datasets record `cloud_energy_j` and `fog_energy_j`.
  - Audited sums confirm:
    - Total System Energy: $E_{\text{total}} = E_{\text{cloud}} + E_{\text{fog}}$.
    - `gw2_m2` COMP: Cloud=2.74 MJ, Fog=1.19 MJ -> Total=**3.93 MJ**; Delay=219.32, Net=210.4 KB, Cost=$103,027.32.
    - `gw2_m2` LAMP: Cloud=2.82 MJ, Fog=1.23 MJ -> Total=**4.05 MJ**; Delay=9.47, Net=164.9 KB, Cost=$**221,589.60** (corrected from stale 27,878.50).
    - `gw2_m2` EWMP: Total=**4.05 MJ**; Delay=9.47, Net=164.9 KB, Cost=$**221,589.60** (corrected from stale 27,878.50).
    - `gw2_m2` `LBMP_PURE`: Total=**4.02 MJ**; Cost=$223,988.48, Loops=2/4 (50.0%).
    - `gw2_m4` COMP: Total=**4.71 MJ**; LAMP: Total=**4.70 MJ**; EWMP: Total=**4.70 MJ**; LBMP: Total=**4.70 MJ**.
    - `gw3_m4` COMP: Cloud=2.89 MJ, Fog=2.76 MJ -> Total=**5.65 MJ** (corrected from stale 6.77); LAMP: Cloud=2.73 MJ, Fog=2.91 MJ -> Total=**5.63 MJ** (corrected from stale 6.75); EWMP: Total=**5.63 MJ**; LBMP: Total=**5.63 MJ**.
    - `gw4_m4` COMP: Cloud=2.95 MJ, Fog=3.62 MJ -> Total=**6.57 MJ** (corrected from stale 8.82); LAMP: Cloud=2.74 MJ, Fog=3.82 MJ -> Total=**6.57 MJ** (corrected from stale 8.80); EWMP: Total=**6.57 MJ**; LBMP: Total=**6.57 MJ**.
- **Revised Text:**
  - Table II Column Title: `Total System Energy ($10^6$ J)`.
  - Explanatory Table Note: `*Note: Total System Energy represents the sum of Cloud and Fog energy ($E_{\text{total}} = E_{\text{cloud}} + E_{\text{fog}}$).*`
  - All transcription errors corrected to match primary CSV values exactly.
- **Resolution Status:** Fully resolved and verified.

---

### Correction 7: Empirical Recalculation of Fog Energy Consumption Increase

- **Original Defect / Location:** 
  The manuscript previously reported that LAMP increases fog layer energy by "7.3% to 7.7%", an estimate originating from an early unverified calculation.
- **Primary Evidence Base:**
  - Python recalculation script `scratch/recalculate_fog_energy.py` audited all completed symmetric configurations comparing LAMP vs COMP fog energy:
    - $M=2$: gw2 2.81%, gw3 2.48%, gw4 2.60% (mean 2.63%)
    - $M=4$: gw2 5.34%, gw3 5.43%, gw4 5.51% (mean 5.42%, pooled 5.44%)
    - $M=6$: gw2 5.82%, gw3 5.25%, gw4 4.76% (mean 5.28%)
    - $M=8$: gw2 4.62% (gw3 and gw4 COMP timed out at 240s)
    - **Pooled total fog energy increase across all 10 completed configs:** **4.72%** (mean across configs: 4.46%; range: 2.48% to 5.82%).
    - Under balanced parity ($M=4$): **5.34% to 5.51%** (mean 5.42%).
    - This provides quantitative validation of Rezazadeh et al.'s claim of a *"~5% increase in fog computing (on average)"*!
- **Revised Text:**
  - *Table V & Section IX.3:* "Our measurements confirm that LAMP increases fog layer energy consumption by 4.72% (pooled average across all 10 completed symmetric configurations; 5.34%–5.51% at $M=4$, range 2.48%–5.82%) over COMP. This quantitatively reproduces the published claim of a '~5% increase in fog computing (on average)', reflecting the energy expended by fog gateways when processing modules locally rather than offloading to the cloud."
- **Resolution Status:** Fully resolved and verified.

---

### Correction 8: Update of Table V Scientific Classifications

- **Original Defect / Location:** 
  Table V used generic or imprecise labels (`REPRODUCED`, `NOT APPLICABLE`, `PARTIALLY REPRODUCED`).
- **Standardized Vocabulary Mappings:**
  1. System & Topology Parameters: **`CONFIGURATION REPRODUCED`**
  2. Numerical Results Tables: **`NOT PUBLISHED IN LITERATURE`**
  3. Control-Loop Delay: **`QUALITATIVE AGREEMENT`** (82.4% vs 40% claim at M=4; directionally verified without claiming numerical curve equivalence).
  4. Fog Layer Energy: **`QUANTITATIVELY REPRODUCED`** (4.72% pooled average reproduces the ~5% published claim).
  5. Cloud Execution Cost: **`QUALITATIVE AGREEMENT`** (73.0% vs 50% claim).
  6. SAMP Baseline: **`NOT VERIFIABLE`** (0 equations, schedules, or operators).
- **Revised Table V:**
  Fully updated in Markdown, DOCX, and PDF Table V.
- **Resolution Status:** Fully resolved and verified.

---

### Correction 9: Narrowed Scope of Cryptographic Integrity Conclusion

- **Original Defect / Location:** 
  Section XII and Appendix B previously implied that every output file was an independently matched pre-existing reference.
- **Primary Evidence Base:**
  - Exactly eight (8) files are independently matched against pre-recorded reference checksums:
    1. `RESEARCH_TRACEABILITY_MATRIX.md` (Frozen Matrix)
    2. `results/lamp_reproduction_results.csv` (Phase 1 Baseline)
    3. `results/lamp_reproduction_results_phase1_historical.csv` (Archival Clone)
    4. `results/lamp_reproduction_results_phase2.csv` (Phase 2 Output)
    5. `results/asymmetric_validation_results.csv` (Phase 2.2 Output)
    6. `iFogSim-main/.../ModulePlacementLBMP.java` (Frozen Source)
    7. `iFogSim-main/.../BaselineSimulationRunner.java` (Frozen Source)
    8. `iFogSim-main/.../ModulePlacementLBMPTest.java` (Frozen Test Suite)
  - Exactly two (2) Phase 3.6 production output datasets are recorded production outputs:
    1. `results/lbmp_symmetric_results.csv` (`4BEA70AF6DCB...`)
    2. `results/lbmp_asymmetric_results.csv` (`A37B3A216637...`)
- **Revised Text:**
  - *Appendix B:* "Cryptographic Audit Conclusion: Unbroken cryptographic verification is established for the 8 independently matched reference files (including the frozen Research Traceability Matrix, Phase 1 archival datasets, Phase 2 and 2.2 output CSVs, and frozen Java placement engines). The 2 Phase 3.6 production output datasets (`results/lbmp_symmetric_results.csv` and `results/lbmp_asymmetric_results.csv`) are cryptographically recorded with their generated checksums documented for independent verification."
- **Resolution Status:** Fully resolved and verified.

---

### Correction 10: Removal of Placeholder Affiliations and Emails

- **Original Defect / Location:** 
  The title banner included placeholder department, institution, and email lines (`*Department of Computer Science and Engineering, Institution Placeholder*`, `Email: {yoshi.anurag, jaswanth.ch}@institution.placeholder`).
- **Primary Evidence Base:**
  - User directive: "Do not invent institutional affiliations, email addresses, guide names, or author contributions. Use placeholders wherever information is unavailable... Remove `institution.placeholder` and email placeholders, keeping only: `**M. Yoshi Anurag** and **Ch. Jaswanth**`."
- **Revised Text:**
  - Removed all placeholder lines across Markdown, DOCX, and PDF.
  - Retained clean author block:  
    `**M. Yoshi Anurag** and **Ch. Jaswanth**`
- **Resolution Status:** Fully resolved and verified.

---

### Correction 11: Verification of Reference [12] Citation

- **Original Defect / Location:** 
  Verify that reference [12] (Kirkpatrick et al., 1983) is cited in-text in Section III.B.4 and listed accurately in the References section.
- **Primary Evidence Base:**
  - Kirkpatrick, C. D. Gelatt, and M. P. Vecchi, "Optimization by simulated annealing," *Science*, vol. 220, no. 4598, pp. 671–680, 1983.
  - Cited in Section III.B.4: "explore global placement search spaces by iteratively perturbing candidate solutions [12]."
  - Verified present in Section III.B.4 and reference item [12].
- **Resolution Status:** Verified and retained.

---

## Manuscript-Wide Consistency Check

| Check Dimension | Status | Verification Evidence |
| :--- | :---: | :--- |
| **Total Simulation Attempts** | **CONSISTENT** | Exactly 72 attempts reported across Abstract, Section VIII.A, Section XII, and Appendix A. |
| **Emitted Result Summaries** | **CONSISTENT** | Exactly 70 result summaries reported across Abstract, Section VIII.A, Section XII, and Appendix A. |
| **Watchdog Timeout Accounting** | **CONSISTENT** | Exactly 2 watchdog timeouts (`COMP_gw3_m8` and `COMP_gw4_m8` at 240.0s) reported with unproduced metrics recorded as N/A. |
| **LBMP Phase 3.6 Completion** | **CONSISTENT** | Exactly 3 SUCCESS, 13 PARTIAL_COMPLETION, 156/220 completed loops (70.9%) reported in Abstract, Section VIII.A, Section VIII.C, and Section XII. |
| **LAMP Completion Rate** | **CONSISTENT** | 100% completion in 4 asymmetric stress workloads and 9 of 12 symmetric configurations; partial completion in 3 dense configurations (`gw3_m8`, `gw4_m6`, `gw4_m8`) uniformly documented. |
| **Total System Energy Definition** | **CONSISTENT** | $E_{\text{total}} = E_{\text{cloud}} + E_{\text{fog}}$ uniformly defined and applied in Table II, Table VI, and text. |
| **Fog Energy Recalculation** | **CONSISTENT** | 4.72% pooled average (5.34%–5.51% at $M=4$) uniformly cited in Table V and Section IX.3. |
| **Scientific Classifications** | **CONSISTENT** | Table V uses exact standardized vocabulary (`CONFIGURATION REPRODUCED`, `NOT PUBLISHED IN LITERATURE`, `QUALITATIVE AGREEMENT`, `QUANTITATIVELY REPRODUCED`, `NOT VERIFIABLE`). |
| **Page Count & Visual Geometry** | **CONSISTENT** | Exactly 9 pages verified via PyPDFium2 with clean 2-column layout and zero table overflows. |
| **Data Integrity & Immutability** | **FROZEN** | Zero edits to Java code, raw CSVs, or `RESEARCH_TRACEABILITY_MATRIX.md` (`a47a9d0352c8...`). |

---

## Conclusion

The IEEE manuscript `FINAL_LAMP_IEEE_RESEARCH_PAPER` (.pdf, .docx, and .md) has successfully passed all 11 scientific-content corrections and formatting audits. The document is scientifically rigorous, mathematically sound, cryptographically auditable, and formatted to IEEE conference standards for undergraduate research submission.
