# LAMP Simulation Demonstration Run Report
## Single Controlled Run: 2 Gateways × 4 Mobiles ($N = 8$ Applications)

**Project:** Reproduction & Validation of *LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 23, 2026  
**Execution Status:** COMPLETED SUCCESSFULLY (Exit Code: `0`)  
**Output Directory:** [demonstration_results/](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/demonstration_results/)  
**Primary Log:** [LAMP_demo_gw2_m4.log](file:///C:/Users/91630/Desktop/Code%20Playground/LAMP/demonstration_results/LAMP_demo_gw2_m4.log)  

---

## 1. Executive Summary & Configuration Overview

A controlled single-configuration demonstration of the validated LAMP Healthcare Fog–Cloud simulation was executed on OpenJDK 21 LTS without executing the full benchmark matrix.

| Parameter | Value | Description |
| :--- | :--- | :--- |
| **Algorithm** | `LAMP` | Latency-Aware Module Placement (*Rezazadeh et al., 2019*) |
| **Topology** | Symmetric 4-Tier | Cloud $\rightarrow$ Proxy $\rightarrow$ 2 Gateways $\rightarrow$ 8 Mobiles |
| **Gateways ($G$)** | $2$ | Gateway devices `d-0` and `d-1` |
| **Mobiles / GW ($M$)** | $4$ | 4 mobile devices per gateway ($N = 8$ total applications) |
| **Simulation Duration** | $2,000$ ticks | Standard discrete-event simulation window |
| **Execution Duration** | $2.01\text{ s}$ | Real elapsed wall-clock execution time |
| **Process Exit Code** | `0` | Clean process termination with zero runtime exceptions |
| **Simulation Status** | `SUCCESS` | $100\%$ application loop completion ($8 / 8$ loops) |

---

## 2. Runner Entry Points & Algorithm Options

The project provides dedicated simulation drivers capable of executing single configurations independently:

| Runner Class | Supported Algorithms | Invocation Syntax | Scope |
| :--- | :--- | :--- | :--- |
| **`HealthcareSimulationRunner`** *(Used)* | `COMP`, `LAMP`, `EWMP` | `<ALGO> <numGateways> <numMobilesPerGw> [simTime]` | 4-tier symmetric topology (Phase 2 validated) |
| **`BaselineSimulationRunner`** | `LBMP_PURE` | `SYMMETRIC <numGateways> <numMobilesPerGw> [simTime]` | Taneja & Davy baseline (Phase 3.5 & 3.6 validated) |
| **`AsymmetricSimulationRunner`** | `COMP`, `LAMP` variants, `EWMP` | `<ALGO> <gw0Mobiles> <gw1Mobiles> [simTime]` | 2-gateway asymmetric topology (Phase 2.2 validated) |

---

## 3. Topology & Physical Device Inventory

| Device Name | Device Tier | CPU (MIPS) | RAM (MB) | Uplink / Downlink BW | Attached Peripherals / Clients |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **`cloud`** | Cloud Data Center | $44,800$ | $40,000$ | $100$ / $10,000$ | Host for 8 `Cloud_Storage` modules; cost $\$0.1/\text{s}$ |
| **`proxy-server`** | Regional Proxy | $2,800$ | $4,000$ | $10,000$ / $10,000$ | Inter-gateway routing & hierarchy parent |
| **`d-0`** | Gateway 0 | $2,800$ | $4,000$ | $10,000$ / $10,000$ | Serves mobiles `m-0-0` through `m-0-3` |
| **`d-1`** | Gateway 1 | $2,800$ | $4,000$ | $10,000$ / $10,000$ | Serves mobiles `m-1-0` through `m-1-3` |
| **`m-0-x` (4)** | Mobile Clients (GW 0) | $1,000$ | $1,000$ | $10,000$ / $10,000$ | Each hosts 1 `ECG` sensor and 1 `DISPLAY` actuator |
| **`m-1-x` (4)** | Mobile Clients (GW 1) | $1,000$ | $1,000$ | $10,000$ / $10,000$ | Each hosts 1 `ECG` sensor and 1 `DISPLAY` actuator |

---

## 4. Module Placement & Strict $3N = 24$ Accounting

For $N = 8$ applications, exactly $3 \times 8 = \mathbf{24}$ application modules were planned, placed, and verified:

| Module Category | Host Target | Count | Allocation Details & Locality |
| :--- | :--- | :---: | :--- |
| **`Interface_i_j`** | Mobile Device `m-i-j` | 8 | Pinned to each originating mobile client ($10\text{ MB}$ RAM) |
| **`Sensor_Analyzer_i_j`** | Local Gateway `d-0` / `d-1` | 8 | Gateway `d-0` $\leftarrow 4$ analyzers (`app_0_0`..`app_0_3`)<br>Gateway `d-1` $\leftarrow 4$ analyzers (`app_1_0`..`app_1_3`) |
| **`Cloud_Storage_i_j`** | Cloud Data Center `cloud` | 8 | Fixed on `cloud` data store ($10\text{ MB}$ RAM) |
| **Total Placements** | **Fog: 16 \| Cloud: 8** | **24** | **Strictly matches $3N = 24$ invariant ($100\%$ accounting)** |

> [!NOTE]
> Under $M=4$, all 8 `Sensor_Analyzer` modules are placed on their direct local gateways (`AnalyzerLocalGw = 8`, `AnalyzerPeerGw = 0`). Peer gateway offloading is zero, avoiding inter-gateway proxy bottlenecks.

---

## 5. Application Loop Delay Telemetry

All 8 application loops achieved complete execution ($100\%$ loop completion rate) over **2,946 total loop executions**:

| Application ID | Mobile Origin | Analyzer Host | Completed Executions | Average Loop Delay (ticks) | Status |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **`app_0_0`** | `m-0-0` | `d-0` (Local) | 368 | $77.9205$ | `COMPLETED` |
| **`app_0_1`** | `m-0-1` | `d-0` (Local) | 368 | $71.4066$ | `COMPLETED` |
| **`app_0_2`** | `m-0-2` | `d-0` (Local) | 368 | $72.2913$ | `COMPLETED` |
| **`app_0_3`** | `m-0-3` | `d-0` (Local) | 369 | $71.8587$ | `COMPLETED` |
| **`app_1_0`** | `m-1-0` | `d-1` (Local) | 368 | $76.5713$ | `COMPLETED` |
| **`app_1_1`** | `m-1-1` | `d-1` (Local) | 368 | $67.3838$ | `COMPLETED` |
| **`app_1_2`** | `m-1-2` | `d-1` (Local) | 368 | $68.1174$ | `COMPLETED` |
| **`app_1_3`** | `m-1-3` | `d-1` (Local) | 369 | $69.9635$ | `COMPLETED` |
| **Overall Weighted Average** | — | — | **2,946** | **$71.9300$** | **`SUCCESS` ($8 / 8$)** |

---

## 6. Energy, Cost & Network Metrics

| Performance Metric | Simulated Value | Metric Classification | Baseline Comparison (`COMP` Cloud-Only) |
| :--- | :---: | :--- | :--- |
| **Loop Delay** | **$71.9300$ ticks** | Simulator composite time | **$82.41\%$ reduction** ($5.68\times$ faster than $408.86$ ticks) |
| **Cloud Cost** | **$\$59,359.20$** | Linear model-derived | **$73.02\%$ savings** (vs. $\$219,986.26$ in `COMP`) |
| **Network Usage** | **$338,677.00$** | Link throughput monitor | **$21.72\%$ reduction** (vs. $432,651.50$ in `COMP`) |
| **Cloud Energy** | **$2,705,869.44\text{ J}$** | Model-derived power | Reduced by $113,299\text{ J}$ due to fog offloading |
| **Fog Energy** | **$1,995,408.15\text{ J}$** | Model-derived power | Increased by $101,070\text{ J}$ due to gateway CPU load |
| **Total System Energy** | **$4,701,277.58\text{ J}$** | Combined energy | **$0.26\%$ difference** (static idle power dominates) |

---

## 7. Captured Structured Result & CSV Record

```text
================================================================================
STRUCTURED RESULT METRICS (PHASE 2 VALIDATED)
Algorithm: LAMP
Gateways: 2 | Mobiles/GW: 4 | Total Applications: 8
Loop Delay (sim ticks): 71.9300
Loops Completed: 8 / 8 (Total Executions: 2946)
Cloud Energy (J): 2705869.4357
Fog Energy (J): 1995408.1492
Cloud Cost: 59359.200000
Network Usage: 338677.0000
Fog Placements: 16
Cloud Placements: 8
Status: SUCCESS
================================================================================
CSV_ROW:LAMP,2,4,8,71.9300,2705869.4357,1995408.1492,59359.200000,338677.0000,16,8,SUCCESS
```

---

## 8. Manual Reproduction Command

To reproduce this single demonstration run manually in PowerShell:

```powershell
Set-Location -Path "C:\Users\91630\Desktop\Code Playground\LAMP"

& ".\eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe" `
    -cp "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*" `
    org.fog.lamp.simulation.HealthcareSimulationRunner LAMP 2 4 2000
```
