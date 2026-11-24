# PHASE 3.7: FINAL CONSISTENCY ADDENDUM
## Methodological, Dimensional, and Epistemological Corrections to the Comparative Evaluation Report

**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 23, 2026  
**Status:** COMPLETE & CRYPTOGRAPHICALLY VALIDATED  
**Governing Documents:**
- Master Comparative Evaluation Report: [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md)
- Audit & Correction Report: [PHASE_3_7_CORRECTION_AND_VALIDATION_REPORT.md](PHASE_3_7_CORRECTION_AND_VALIDATION_REPORT.md)
- LBMP Design Specification: [PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md](PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md) (Rev. 2)
- Master Document Index: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

---

## 1. Overview & Purpose

This addendum records the final targeted consistency corrections applied to [PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md](PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md). 

These revisions address six specific methodological, dimensional, and unit-integrity issues:
1. **Dimensional Consistency:** Resolving the conflation of simulation ticks with physical seconds in module computational demand derivations.
2. **Host/VM Bandwidth Units Integrity:** Designating `AppModule.getBw()` and `Host.getBw()` as CloudSim VM-provisioner bandwidth units rather than physical network-link throughput (KB/s), distinguishing them from network link rates.
3. **Causal Claims Discipline:** Eliminating speculative causal assertions regarding cloud uplink saturation and buffer queue buildup, retaining only what the empirical data and discrete simulation architecture support.
4. **Timeout Semantics Formalization:** Explicitly distinguishing the internal 2,000-tick simulation horizon from external operating system watchdog timeouts (exit code 143).
5. **Simulation Horizon Calibration:** Correcting claims that equated the 2,000-tick cutoff with a real-time cyber-physical deadline to reflect that it is an experimental truncation boundary uncalibrated to a real-world deadline.
6. **Literature Fidelity & Scope Definition:** Explicitly defining the implementation scope of `LAMP`, `LBMP_PURE`, `EWMP`, and `COMP` within iFogSim, removing overgeneralized claims of pure literature execution.

---

## 2. Issue 1: Dimensional Consistency & Exact Source Evidence

### 2.1 The Dimensional Problem
Previous report text wrote:
$$\lambda = 0.2\text{ tuples/tick}, \quad L_{\text{cpu}} = 3,500\text{ MI/tuple}, \quad D_{\text{cpu}} = 700\text{ MIPS}$$
This formulation improperly mixed simulator discrete-event ticks with physical rate units (seconds and MIPS = Million Instructions Per Second), implicitly and incorrectly assuming that $1\text{ tick} \equiv 1\text{ second}$.

### 2.2 Primary Source Code Evidence
Inspection of the frozen Java source code reveals the exact configuration:
1. **Configured Sensor Interval ($T_{\text{sensor}} = 5.0\text{ seconds}$):**
   - In `BaselineSimulationRunner.java:44`:
     ```java
     public static final double SENSOR_INTERVAL_SEC = 5.0;
     ```
   - In `HealthcareTopologyFactory.java:93-95`:
     ```java
     // Add ECG Sensor (Table I & III: 5.0s interval, latency 0.6 ms to mobile)
     Sensor sensor = new Sensor("s-" + i + "-" + j, sensorTupleType, userId, patientAppId,
             new DeterministicDistribution(sensorInterval));
     ```
   - In *Rezazadeh et al. (IEEE KBEI 2019)*, Table I & Table III: ECG sensor periodic transmission interval is explicitly specified as $5.0\text{ seconds}$.
2. **Task Computational Work ($L_{\text{cpu}} = 3,500\text{ MI/tuple}$):**
   - In `HealthcareBSNApplication.java:81`:
     ```java
     application.addAppEdge(modInterface, modAnalyzer, 3500, 500, TUPLE_ENHANCED_SENSOR + sfx, Tuple.UP, AppEdge.MODULE);
     ```
     The computational length per tuple emitted from `Interface` to `Sensor_Analyzer` is exactly $3,500\text{ MI}$.
3. **Steady-State Computational Demand ($D_{\text{cpu}} = 700\text{ MIPS}$):**
   - In `ModulePlacementLAMP.java:45-47`:
     ```java
     // Workload demand per Sensor Analyzer instance (0.2 Hz * 3,500 MI = 700 MIPS)
     public static final double SENSOR_ANALYZER_MIPS_DEMAND = 700.0;
     public static final double SENSOR_ANALYZER_CPU_LENGTH = 3500.0;
     ```

### 2.3 Corrected Mathematical Formulation
The steady-state rate calculation is properly expressed as:
$$\lambda = \frac{1}{T_{\text{sensor}}} = \frac{1}{5.0\text{ s}} = 0.2\text{ tuples/second } (0.2\text{ Hz})$$
$$D_{\text{cpu}} = \lambda \times L_{\text{cpu}} = 0.2\text{ tuples/second} \times 3,500\text{ MI/tuple} = 700.0\text{ MI/second} = \mathbf{700.0\text{ MIPS}}$$

**Crucial Dimensional Distinction:**  
The sensor emission rate is configured in physical seconds ($5.0\text{ s}$), while end-to-end loop latency is reported by CloudSim in discrete-event simulation ticks. One simulation tick must **not** be assumed to equal one physical second, nor should arrival rate in $\text{tuples/second}$ be conflated with simulation ticks.

### 2.4 Host/VM Bandwidth Provisioner Units vs. Physical Network Links
In Section 5.1, previous text described `AppModule` bandwidth demand as $1,000\text{ KB/s}$, Fog Host bandwidth as $1,000,000\text{ KB/s}$, and the capacity comparison as a KB/s calculation. As established in the Phase 3.3 source audit, these parameters originate from `AppModule.getBw()` and `Host.getBw()`, consumed by CloudSim's VM-level bandwidth provisioner (`BwProvisionerSimple`). 

They must not be represented as physical network-link throughput in KB/s. The terminology has been corrected:
- `AppModule.getBw() = 1,000` CloudSim VM-provisioner bandwidth units.
- `Host.getBw() = 1,000,000` CloudSim Host-provisioner bandwidth units.
- The numerical capacity comparison ($\lfloor 1,000,000 / 1,000 \rfloor = 1,000$ modules) is preserved strictly as a comparison within the same provisioner-unit model.
- These values are explicitly distinguished from `FogDevice.uplinkBandwidth` and `downlinkBandwidth`, which define physical network-link transmission rates during tuple routing. No physical unit conversion is assumed or applied to the provisioner-unit model.

---

## 3. Issue 2: Causal Claims Discipline

### 3.1 Unqualified Claims Removed
The following unverified causal assertions were identified and removed:
1. *Cloud Uplink Saturation:* The claim that placing all 24 and 32 analyzers on Cloud "saturates the Cloud uplink, causing CloudSim event processing to exceed the execution threshold (TIMEOUT)".
2. *Queue Buildup Causation:* The claim that partial completions in `LBMP_PURE` and `LAMP` at $M=8$ occurred "due to queue buildup at the saturated proxy and cloud gateway links".

### 3.2 Corrected Evidence-Based Scope
Section 5.3 has been revised to state only what is empirically established:
- **`COMP` Watchdog Termination:** In `gw3_m8` and `gw4_m8`, placing all 24 and 32 analyzers on Cloud resulted in external execution watchdog timeouts before CloudSim completed event processing or emitted summary results (`TIMEOUT`, exit code 143). Because summary statistics were never generated, all associated metrics are recorded as `N/A`. Watchdog termination represents an external execution cutoff rather than directly measured causal proof of Cloud uplink saturation.
- **`LBMP_PURE` & `LAMP` Incomplete Loops:** Both `LBMP_PURE` and `LAMP` produced incomplete loops within the 2,000-tick simulation horizon at $M=8$ ($62.5\%$ to $83.3\%$ completed). Incomplete loops within the 2,000-tick horizon indicate that delayed tuples failed to complete before the cutoff. While proxy and cloud link buffer queueing is a plausible architectural hypothesis consistent with the routing topology, CloudSim does not emit discrete queue timeseries, so queue congestion remains an architectural hypothesis rather than directly measured causal proof.
- **Consistency with Sections 5.2 and 8:** Peer-gateway offloading performance collapse ($25\%-50\%$ completion) is similarly documented as an empirical observation and routing architecture reality, with proxy-link buffer backlog maintained strictly as an architectural hypothesis.

---

## 4. Issue 3: Timeout Semantics Formalization

The report now explicitly differentiates two completely distinct timeout boundaries:

| Dimension | A. Simulation Horizon | B. Execution Watchdog Timeout |
| :--- | :--- | :--- |
| **Definition** | Configured discrete-event simulation timeframe | External OS harness process termination timer |
| **Configured Value** | `Config.MAX_SIMULATION_TIME = 2000` simulation ticks | 20 to 25 minutes wall-clock execution limit |
| **Trigger Mechanism** | CloudSim discrete clock reaches 2,000.0 ticks | External runner kills hanging/slow JVM process |
| **System Exit Code** | `0` (Normal JVM process termination) | `143` (SIGTERM external process kill) |
| **Outcome Recorded** | `SUCCESS` (if $k=N$) or `PARTIAL_COMPLETION` ($0 < k < N$) | `TIMEOUT` (Process aborted before summary emission) |
| **Metric Treatment** | Metrics calculated over completed loops; uncompleted are `null` | **All metrics strictly recorded as `N/A`** |
| **Causal Inference** | Incomplete loops did not finish before tick 2,000 | JVM did not reach completion within wall-clock limit |

### 4.2 Experimental Truncation Boundary vs. Real-Time Deadlines
In Section 8 (limitation 2), previous text stated: *"This threshold reflects real-time deadline expiration in cyber-physical IoT systems."* Because no calibration or empirical mapping between 2,000 CloudSim simulation ticks and a real-world application deadline has been established, this claim was inaccurate.

It has been replaced with:
> "The 2,000-tick value is the configured simulation horizon used in this experiment. It is an experimental truncation boundary and has not been calibrated to a real-world deadline."

---

## 5. Issue 4: Literature Fidelity & Implementation Scope

Section 8.4's previous assertion that all algorithms were executed in their pure literature-specified form has been corrected to document the precise implementation scope and adaptations:
- **`LAMP`:** The implemented reproduction of the primary algorithm from *Rezazadeh et al. (IEEE KBEI 2019)* within the iFogSim discrete-event environment, following its hierarchical placement logic (Local Gateway $\to$ Proxy Server $\to$ Cloud).
- **`LBMP_PURE`:** Follows the placement logic (Algorithms 1–3) from *Taneja & Davy (IFIP/IEEE IM 2017)* with the approved Phase 3.4 adaptations required for multi-application execution: the CloudSim Host-BW approximation (Option A), dynamic-search reset (`low = 0`), and fallback safeguards (`D-3.4-01` through `D-3.5-01`).
- **`EWMP` & `COMP`:** The implemented comparison baselines representing energy-weighted fog-cloud placement and cloud-only execution, respectively.
- **Literature Parameters:** Parameters and simulation mechanisms not explicitly specified in the original literature (such as unstated tie-breaking rules, inter-gateway network topology details, or CloudSim VM provisioning internals) were standardized across all baselines rather than claimed as exact reproductions of unspecified original author settings.

---

## 6. Itemized List of Edited Sections in `PHASE_3_7_COMPARATIVE_EVALUATION_REPORT.md`

| Section | Line Range | Nature of Edit |
| :--- | :---: | :--- |
| **Section 3.4** | Lines 93–94 | Clarified distinction between VM-provisioner bandwidth units (`AppModule.getBw()` / `Host.getBw()`) and physical network-link rates. |
| **Section 3.5** | Lines 96–100 | Added formal subsection distinguishing the 2,000-tick Simulation Horizon from external Execution Watchdog Timeouts (exit code 143). |
| **Section 4 Footnote** | Line 158 | Clarified that marked delays are conditional averages within the 2,000-tick simulation horizon, and defined `TIMEOUT` as watchdog process termination. |
| **Section 5.1** | Lines 167–175 | Corrected dimensional derivation: $\lambda = 1/5.0 = 0.2\text{ tuples/s}$, $D_{\text{cpu}} = 0.2 \times 3,500 = 700\text{ MIPS}$; added explicit distinction between seconds and simulation ticks. |
| **Section 5.1** | Lines 176–180 | Corrected bandwidth units to CloudSim VM/Host-provisioner units ($1,000$ and $1,000,000$ units), distinguished from network links (`uplinkBandwidth`/`downlinkBandwidth`), removing KB/s label. |
| **Section 5.3** | Lines 223–232 | Removed claims of Cloud uplink saturation causation and queue buildup proof; replaced with watchdog termination facts and the proxy link congestion hypothesis. |
| **Section 6 Warning** | Line 273 | Clarified that omitted loops in partial completions are those that failed to complete before the 2,000-tick simulation horizon. |
| **Section 8.2** | Line 324 | Replaced real-time deadline claim with explicit statement that 2,000 ticks is an experimental truncation boundary uncalibrated to a real-world deadline. |
| **Section 8.4** | Lines 327–332 | Replaced "pure literature-specified forms" with the documented implementation scope and approved Phase 3.4 adaptations for LAMP, LBMP_PURE, EWMP, and COMP. |
| **Section 9.2** | Line 343 | Re-affirmed peer-offloading loop completion drop as an empirical observation consistent with the proxy-link congestion hypothesis. |

---

## 7. Cryptographic Verification & Audit Conclusion

An independent SHA-256 verification confirms that no historical datasets, CSV files, or Java source codes were touched during this addendum:

- `results/lamp_reproduction_results_phase1_historical.csv`: `A1E9C907...` (**MATCH**)
- `results/lamp_reproduction_results.csv`: `A1E9C907...` (**MATCH**)
- `results/lamp_reproduction_results_phase2.csv`: `613B00FC...` (**MATCH**)
- `results/asymmetric_validation_results.csv`: `3F1D1737...` (**MATCH**)
- `results/lbmp_symmetric_results.csv`: `4BEA70AF...` (**MATCH**)
- `results/lbmp_asymmetric_results.csv`: `A37B3A21...` (**MATCH**)
- `ModulePlacementLBMP.java`: `DBD48E4B...` (**MATCH**)
- `BaselineSimulationRunner.java`: `09F1FEB0...` (**MATCH**)
- `ModulePlacementLBMPTest.java`: `CD1A1E58...` (**MATCH**)

The Phase 3.7 Comparative Evaluation is now fully reconciled, dimensionally rigorous, and epistemologically sound.
