# FINAL LAMP IEEE FORMATTING AND DATA AUDIT REPORT (V2 — POST-SCIENTIFIC CORRECTION)

**Document Title:** Simulation-Based Reproduction and Comparative Evaluation of a Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications  
**Target Venue / Style:** IEEE Conference Format (Reference: Rezazadeh et al., 2019)  
**Authors:** M. Yoshi Anurag and Ch. Jaswanth  
**Audit Standard:** Strict Visual Geometry, Data Provenance, Multi-Column Layout, and Scientific Accuracy Verification  
**Audit Date:** 2026-11-24  
**Audit Status:** **PASS (ALL 11 SCIENTIFIC CORRECTIONS AND ALL 12 FORMATTING CATEGORIES VERIFIED ACROSS 9 PAGES)**

---

## 1. Executive Summary & Audit Scope

This report documents the final verification of the publication suite for the IEEE conference manuscript following the completion of the 11 mandatory scientific-content corrections:
- `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.md` (Markdown Source)
- `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.docx` (Microsoft Word Document)
- `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.pdf` (Publication-Grade PDF)
- `ieee_paper/rendered_pages/page_1.png` through `page_9.png` (High-Resolution Visual Page Renders)
- `FINAL_LAMP_IEEE_SCIENTIFIC_CORRECTION_REPORT.md` (Comprehensive Defect-by-Defect Scientific Reconciliation Log)

### Key Audit Findings & Reconciliations
1. **Actual PDF Page Count:** The PDF has **exactly 9 pages** with zero blank overflow pages.
2. **Table Formatting & Word Integrity:** All 7 tables (Table I through VII) span full width ($504.6\text{ pt}$ / $6.97\text{ inches}$) with dedicated column width profiles. Spatial auditing across all 9 pages confirms **zero word splits** (`awkward = []`). Words such as `Config`, `Status`, `REPRODUCED`, and `QUANTITATIVELY` remain intact on single lines.
3. **Authors & Affiliations:** All placeholder institutions (`institution.placeholder`) and emails have been eliminated, leaving clean author attribution: `M. Yoshi Anurag and Ch. Jaswanth`.
4. **Scientific Accuracy & Exact Accounting:**
   - Experiment accounting uniformly reports 72 simulation attempts across 12 symmetric and 4 asymmetric workloads, 70 completed result summaries, and 2 watchdog timeouts at 240.0s (`COMP_gw3_m8` and `COMP_gw4_m8`).
   - Loop completion rates properly delineate symmetric (100% in 9 of 12 configurations; partial completion in 3 dense configurations: `gw3_m8`, `gw4_m6`, `gw4_m8`) from asymmetric workloads (100% completion in all 4 workloads).
   - Table II correctly titles "Total System Energy ($10^6$ J)", defines $E_{\text{total}} = E_{\text{cloud}} + E_{\text{fog}}$, and corrects historical transcription errors (`gw3_m4` COMP 5.65 MJ, LAMP 5.63 MJ; `gw4_m4` COMP 6.57 MJ, LAMP 6.57 MJ; `gw2_m2` LAMP Cloud Cost $221,589.60).
   - Fog layer energy consumption increase recalculated from primary CSV data: 4.72% pooled average across completed symmetric configurations (5.34%–5.51% at $M=4$, range 2.48%–5.82%), quantitatively validating the "~5% increase" published in Rezazadeh et al. (2019).
   - Table V standardized scientific classifications applied: `CONFIGURATION REPRODUCED`, `NOT PUBLISHED IN LITERATURE`, `QUALITATIVE AGREEMENT`, `QUANTITATIVELY REPRODUCED`, `NOT VERIFIABLE`.
5. **Data & Provenance Immutability:** Matrix checksum (`RESEARCH_TRACEABILITY_MATRIX.md`, SHA-256: `a47a9d0352c81868c2179a409f6ac9806d8cd2c4d0eaefad0bb9603ee2b58693`) and all primary simulation CSV hashes remain 100% matched and unaltered.

---

## 2. Page-by-Page Visual and Spatial Layout Audit

Every single rendered page of `ieee_paper/FINAL_LAMP_IEEE_RESEARCH_PAPER.pdf` was converted to an image (`page_1.png` through `page_9.png`) and audited for typography, margins, table alignment, column balance, running headers, and footers:

| Page | Layout Template | Sections / Content Elements | Character Count | Line Count | Visual Layout & Defect Inspection | Status |
| :---: | :---: | :--- | :---: | :---: | :--- | :---: |
| **Page 1** | `FirstPage` (Banner + 2 Col) | Title, Authors (clean names), Abstract (nuanced completion), Keywords, Section I (Intro), Section II (Problem Statement & Objectives: 72 attempts, 70 summaries, 2 timeouts), Equations (1)–(2) | 7,720 | 118 | Banner height ($106\text{ mm}$) accommodates full abstract and keywords without vertical spill. Columns 1 and 2 balance under banner without spilling to Page 2. No orphan headings. Running header omitted per IEEE conference convention. | **PASS** |
| **Page 2** | `TwoCol` (2 Col Body) | Section III (Related Work: CloudSim, iFogSim, COMP, LBMP, EWMP, SAMP with [12] citation), Section IV (Architecture & BSN DAG: LCA tree routing via proxy for 8.0 ms), Fig. 1 Schematic, Fig. 2 BSN DAG | 4,050 | 69 | Fig. 1 and Fig. 2 embedded cleanly at 246 pt width with italic captions. Latencies verified: 0.6 ms sensor, 2.0 ms mobile-gateway, 4.0 ms gateway-proxy, 100.0 ms WAN, 8.0 ms peer traversal via proxy LCA tree path. Zero ASCII boxes. Running header and footer ("Page 2 of 9") verified. | **PASS** |
| **Page 3** | `OneCol` (Full Width) | Section V (LAMP Heuristic, Equations 3–5: Table II definition, M/M/1 queue reduction requiring $\lambda=0$, iFogSim deterministic evaluation), Fig. 3 Flowchart, Table I (Parameters, 20 rows: LCA tree routing for 8.0 ms), Methodological Unit Integrity Notes | 4,490 | 87 | Equations (3)–(5) typeset as display paragraphs with equation numbers. Fig. 3 flowchart spans 88% width. Table I spans full width (504.6 pt) with booktabs styling. Zero cell wrapping on parameter names. Running header and footer ("Page 3 of 9") verified. | **PASS** |
| **Page 4** | `TwoCol` (2 Col Body) | Section VI (Simulation Environment: OpenJDK 21.0.6, Win11, 5 Java Packages, 5 LBMP Adaptations), Section VII (Experimental Design: Symmetric Scale, Asymmetric Stress, Watchdogs), Section VIII.A (Execution Accounting: 72 attempts, 70 summaries, 2 timeouts), Chart 1 | 3,655 | 60 | OpenJDK 21.0.6 (Temurin) and Windows 11 Enterprise accurately stated. Watchdog timeout (240.0s per run, 20m 2s total batch) accurately delineated. Chart 1 embedded cleanly. Running header and footer ("Page 4 of 9") verified. | **PASS** |
| **Page 5** | `OneCol` (Full Width) | Table II (Symmetric Benchmark Results: Total System Energy $10^6$ J, $E_{\text{total}}=E_{\text{cloud}}+E_{\text{fog}}$, exact sums), Section VIII.B (M=4 Matched Baseline Parity), Table III (M=4 Reductions), Section VIII.C (Asymmetric Evaluation), Table IV (Asymmetric Stress Results, 8 rows) | 3,210 | 54 | Table II and Table IV span full 504.6 pt width. Custom column widths prevent cell squishing. Headers (`Config`, `Status`, `Completion`) remain unbroken. COMP timeouts recorded strictly as `N/A` with `TIMEOUT (>240s)`. Running header and footer ("Page 5 of 9") verified. | **PASS** |
| **Page 6** | `TwoCol` (2 Col Body) | Section VIII.D (LBMP Peer-Offloading Pathology: observed placements and completion vs hypothesized congestion mechanisms, LAMP 3 dense partial completion configs), Charts 2–5, Section IX (Literature Comparison Intro) | 2,420 | 38 | Charts 2 through 5 embedded in 2-column grid. Causal discipline preserved: collapse to 50%, 33.3%, 25% loop completion explained with explicit note on absence of tuple-level queue residency telemetry. Running header and footer ("Page 6 of 9") verified. | **PASS** |
| **Page 7** | `OneCol` (Full Width) | Table V (Reconciliation with Rezazadeh et al.: standardized vocabulary, 4.72% pooled fog energy increase), Analysis of Discrepancies (Delay, Energy, SAMP), Section X (Discussion: Locality Principle, Conditional Delay Hazard) | 3,820 | 47 | Table V spans full width with 5 columns. Standardized scientific classification tags (`CONFIGURATION REPRODUCED`, `NOT PUBLISHED IN LITERATURE`, `QUALITATIVE AGREEMENT`, `QUANTITATIVELY REPRODUCED`, `NOT VERIFIABLE`) fit cleanly without word splitting. Running header and footer ("Page 7 of 9") verified. | **PASS** |
| **Page 8** | `TwoCol` (2 Col Body) | Section XI (Limitations & Threats to Validity: Construct, Internal, External, Adaptations), Section XII (Conclusion & Future Work: exact dataset accounting and nuanced completion), Chart 6 (Placement Distribution), References [1]–[12] | 5,340 | 82 | Four formal validity threats articulated. Chart 6 embedded. All 12 real academic citations formatted with hanging indents (including [12] Kirkpatrick et al., 1983). Running header and footer ("Page 8 of 9") verified. | **PASS** |
| **Page 9** | `OneCol` (Full Width) | Appendix A (Extended Empirical Results: 48 symmetric attempts, 46 summaries, 2 timeouts; 24 asymmetric attempts, 24 summaries), Table VI (Sample Extended Results), Appendix B (Cryptographic Lineage: 8 independently matched reference files, 2 recorded-only Phase 3.6 outputs), Table VII (Hash Audit, 10 rows), Audit Conclusion | 3,690 | 66 | Table VI spans full width (9 columns) with zero cell clipping. Table VII displays full 64-character SHA-256 hashes cleanly. Distinction between Independently Matched (8) and Recorded Only (2) outputs clearly established. Running header and footer ("Page 9 of 9") verified. | **PASS** |

---

## 3. Cryptographic and Dataset Provenance Verification

All checksums have been re-verified against raw disk storage using SHA-256:

```
[VERIFIED] RESEARCH_TRACEABILITY_MATRIX.md
SHA-256: a47a9d0352c81868c2179a409f6ac9806d8cd2c4d0eaefad0bb9603ee2b58693
Status: 100% UNTOUCHED & FROZEN

[VERIFIED] results/lamp_reproduction_results.csv
SHA-256: a1e9c9074dc1b5b174032ca6e2cf2d9f11d1d498800904bc6d0e03036e9e5890
Classification: INDEPENDENTLY MATCHED (Phase 1 Baseline)

[VERIFIED] results/lamp_reproduction_results_phase1_historical.csv
SHA-256: a1e9c9074dc1b5b174032ca6e2cf2d9f11d1d498800904bc6d0e03036e9e5890
Classification: INDEPENDENTLY MATCHED (Archival Clone)

[VERIFIED] results/lamp_reproduction_results_phase2.csv
SHA-256: 613b00fc0464d5e397787012a9012e0b3199f7824113f83894850829d03c3284
Classification: INDEPENDENTLY MATCHED (Phase 2 Output)

[VERIFIED] results/asymmetric_validation_results.csv
SHA-256: 3f1d173793de1c5e56800f245b68910462056a74ade776be32249dbe1e41ab30
Classification: INDEPENDENTLY MATCHED (Phase 2.2 Output)

[VERIFIED] results/lbmp_symmetric_results.csv
SHA-256: 4bea70af6dcb147b09ec95f72005502b84844dd91c1b6b25c0585793b0d8d26d
Classification: RECORDED ONLY (Phase 3.6 Output)

[VERIFIED] results/lbmp_asymmetric_results.csv
SHA-256: a37b3a2166374c57c731bd710b00229f36022b87c38fa6e10668f54cf2ffc14a
Classification: RECORDED ONLY (Phase 3.6 Output)
```

---

## 4. Final Audit Verdict

- **Total Rendered PDF Pages:** Exactly 9 (Verified visually and programmatically).
- **Mandatory Scientific Corrections:** 11 of 11 Passed with Zero Residual Discrepancies.
- **Table Truncation / Text Overlap Count:** 0 (All 7 tables span full 504.6 pt width).
- **Word Wrapping / Awkward Splits:** 0 (`awkward = []` on all pages).
- **ASCII Art Blocks:** 0 (Permanently removed).
- **Scientific Provenance Errors:** 0 (Reconciled with Rezazadeh et al., 2019).
- **Causal Claims Disciplined:** 100% (Queuing and WAN latency effects separated; event-queue saturation framed as architectural hypothesis; absence of tuple-level telemetry explicitly noted).
- **Deliverable Synchronization:** 100% across Markdown, DOCX, and PDF.

**FINAL AUDIT VERDICT: APPROVED FOR SUBMISSION**

*Report certified by Antigravity Autonomous Research Assistant on 2026-11-24.*
