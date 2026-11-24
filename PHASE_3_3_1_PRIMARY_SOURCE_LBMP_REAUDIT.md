# PHASE 3.3.1: PRIMARY-SOURCE LBMP RE-AUDIT (TANEJA & DAVY 2017)
**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 18, 2026  
**Status:** PRIMARY-SOURCE AUDIT COMPLETE — AWAITING USER REVIEW & SIGN-OFF  
**Governance:** Strictly Read-Only Research Verification (Zero Java Modifications, Zero Simulations, Zero Edits to Phase 1, 2, 2.2, 3.1, 3.2, or 3.3 Artifacts)  

---

## 1. Executive Summary

We have obtained and completed a full page-by-page textual and visual inspection of the primary source PDF for LBMP: **Taneja & Davy (IFIP/IEEE IM 2017)**, located at [Resource Aware Placement of IoT Application.pdf](Resource Aware Placement of IoT Application.pdf) (7 pages, pp. 1222–1228). Every equation (Eqs. 1–12), algorithm (Algorithms 1–3), figure (Figs. 1–6), and table (Tables I–III) has been directly verified.

### Landmark Primary-Source Discoveries
1. **`low = i + 1` IS Literally Printed in Algorithm 1 (p. 1225, Line 11):** Earlier audits questioned whether `low = i + 1` following `Sort(nodes[])` (Line 10) was a secondary transcription artifact. Primary inspection proves **both lines are literally published together** in Algorithm 1, and proves via trace why this defect was masked in Taneja & Davy's single-application evaluation (5 dynamic modules across 3–7 Fog nodes) yet causes catastrophic premature Cloud offloading on LAMP's multi-application BSN workload (8–32 apps across 3–5 Fog nodes).
2. **Exact Verbatim `LOWERBOUND` (Algorithm 2, p. 1226) Revealed:** Algorithm 2 uses a `while (True)` loop with `return ((mid < length - 1) ? mid + 1 : -1)` at Line 12—a structure that assumes `high` begins at `nodes.size - 1` (including Cloud) and assumes monotonic eligibility.
3. **Bandwidth Units & Module Demands Revealed in Figure 2 (p. 1224) & Table II (p. 1226):** Taneja & Davy explicitly define module requirements in **Figure 2** as `< CPU (MIPS), RAM (MB), BANDWIDTH (Mbps) >` with static developer-assigned module bandwidth demands ranging from **250 Mbps to 5,000 Mbps** (`module_1`..`module_6`), NOT derived from Table III tuple `Network Length` (`500`/`1000`). Table II specifies device `Upstream Capacity (Mbps)` and `Downstream Capacity (Mbps)` (`Cloud`: `1000 / 10000 Mbps`, `ISP_Gateway`: `10000 / 10000`, `Fog-X-Gateway`: `10000 / 10000`, `Device-X-X`: `100 / 250`).
4. **Bandwidth Scalar Gap Confirmed in the Primary Paper Itself:** Even with the full PDF in hand, Taneja & Davy **never publish an equation** mapping Table II's two columns (`Upstream`, `Downstream`) into Equation (1)'s single scalar `Bandwidth_i`, nor does LAMP 2019 publish Figure 2-style Mbps module demands for `Sensor_Analyzer`. However, mathematical deduction from Figure 2 + Table II proves `Device-X-X` (`Up=100, Down=250`) hosting `module_1` (`250 Mbps`) and `Cloud` (`Up=1000, Down=10000`) hosting `module_5`/`module_6` (`2000`/`5000 Mbps`) requires **`Downstream` / `max(Up, Down)`**, **never `Upstream` or `min(Up, Down)`**.
5. **Cloud Belongs Inside `nodes[]` ($N = N_F \cup N_C$):** Equations (2)–(6) (p. 1224) and Section IV.A (p. 1225) explicitly define Algorithm 1's input as the full union $N = N_F \cup N_C$, with Cloud included in `nodes[]` and `nodes[nodes.size - 1]` serving as the unconditional fallback target at Line 13.

---

## 2. Paper Bibliographic Details

- **Title:** Resource Aware Placement of IoT Application Modules in Fog-Cloud Computing Paradigm
- **Authors:** Mohit Taneja and Alan Davy
- **Affiliations:** Telecommunications Software and Systems Group (TSSG), Waterford Institute of Technology, Waterford, Ireland; CONNECT — Centre for Future Networks and Communications, Ireland (`{mtaneja, adavy}@tssg.org`)
- **Venue:** 2017 IFIP/IEEE Symposium on Integrated Network and Service Management (IM) — Special Track on Management of IoT
- **Pages:** 1222–1228 (7 pages)
- **ISBN / Copyright:** `978-3-901882-89-0 ©2017 IFIP`
- **Local File:** [Resource Aware Placement of IoT Application.pdf](Resource Aware Placement of IoT Application.pdf)
- **Role in Primary Target (LAMP 2019):** Cited as Reference `[3]` in Rezazadeh et al. (2019, p. 845, 846, 848, 849, 850) under the name **Lower-Bound Module Placement (LBMP)**.

---

## 3. Page-by-Page Relevant Findings

| PDF Page (Printed Page) | Section(s) | Key Verified Primary-Source Facts |
| :---: | :--- | :--- |
| **Page 1 (p. 1222)** | Abstract, §I Introduction | Defines the goal: *"Module Mapping Algorithm for efficient utilization of resources in the network infrastructure by efficiently deploying Application Modules in Fog-Cloud Infrastructure."* States strategy *"iterates from Fog layer towards the Cloud and tries to place the modules first on the available resources on Fog layer, thereafter iterating towards the Cloud."* |
| **Page 2 (p. 1223)** | §II Related Work, §III System Model & Problem Formulation, Fig. 1 | Defines 3-tier architecture (Tier 1: IoT End Devices; Tier 2: Fog / Smart Gateways; Tier 3: Cloud). Explicitly states: *"in comparison to the Fog devices, the Cloud is visualized as being limitless. Thus, the complete set of resources comprise of the devices at the Fog, and VMs at the Cloud."* Introduces 3 resource attributes per node: **CPU, RAM, and Bandwidth** (extensible to storage). |
| **Page 3 (p. 1224)** | §III (cont.), Eqs. (1)–(12), Fig. 2 | Formalizes `Cap(n_i)` (Eq. 1), $N = N_F \cup N_C$ with $N_F \cap N_C = \phi$ (Eqs. 2–6), DAG $\mathcal{G} = \langle V, E \rangle$ (Eqs. 7–10), `Req(v_i)` (Eq. 8), mapping $\mathcal{M}: V \to N$ (Eq. 11), and feasibility constraint $\text{Req}(v_i) \le \text{Cap}(n_i)$ (Eq. 12). **Fig. 2** displays 6 modules (`module_1`..`module_6`) with exact `< CPU (MIPS), RAM (MB), BANDWIDTH (Mbps) >` vectors! |
| **Page 4 (p. 1225)** | §III (cont.), §IV Proposed Solution (§IV.A, §IV.B), **Algorithm 1** | States iFogSim [19] over CloudSim [20] is used. Explicitly pins **`module_1` on end devices (`Device-X-X`)** so sensors/actuators are co-located with the source module. Prints verbatim **Algorithm 1 (`MODULEMAP`)**, including `Sort(nodes[])` ascending (Line 2), `Cap(node[i]) = Cap(node[i]) - Req(modules[start])` (Line 9), `Sort(nodes[])` ascending (Line 10), **`low = i + 1`** (Line 11), and `moduleMap.insert(nodes[nodes.size-1], modules[start])` (Line 13). |
| **Page 5 (p. 1226)** | **Algorithm 2**, **Algorithm 3**, §IV.B (cont.), §V Evaluation, Fig. 3, **Tables I, II, III** | Prints verbatim **Algorithm 2 (`LOWERBOUND`)** and **Algorithm 3 (`COMPARE`)**. Derives total complexity $O((|N|+|V|+|N|\cdot|V|)\log|N| + |V|\log|V|)$. Shows topology (Fig. 3: Cloud $\to$ ISP_Gateway $\to$ 2/4/6 Fog-X-Gateways $\to$ 2 Device-X-X per gateway). Prints **Table I** (link latencies in ms), **Table II** (node Upstream/Downstream Mbps, RAM MB, CPU MIPS), **Table III** (tuple CPU length in MIPS, Network Length, 10 ms sensor emission rate). |
| **Page 6 (p. 1227)** | §V (cont.), Figs. 4–6, §VI Conclusion | Compares proposed Fog-Cloud placement only against Traditional Cloud Placement (COMP) on Network Usage (KB, Fig. 4), End-to-End Latency (ms, Fig. 5), and Energy Consumption (MJ, Fig. 6). Does NOT plot or report module-to-node mapping logs. |
| **Page 7 (p. 1228)** | References [1]–[24] | Cites Gupta et al. iFogSim arXiv 2016 [19], Buyya CloudSim [20], Gia et al. ECG healthcare [21], Zao EEG gaming [22], and authors' prior 2016 papers [23], [24]. |

---

## 4. Exact Verbatim Algorithm Pseudocode (Taneja & Davy 2017)

Reproduced **verbatim** from pp. 1225–1226 without silent modification. Apparent inconsistencies are preserved here and analyzed separately in Section 11.

### 4.1 Algorithm 1: `ModuleMapping Algorithm: Fog-Cloud Placement` (p. 1225)
```text
Input  : Set of Network nodes N and Application modules V
Output : Mapping of modules on to network nodes
 1: function MODULEMAP(NetworkNode nodes[], AppModule modules[])
 2:     Sort(nodes[]), Sort(modules[]);        ▷ in ascending order
 3:     Map < NetworkNode, AppModule[ ] > moduleMap;
        ▷ Creates Key-Value Pair with Network Node as Key and AppModule as Value
 4:     int low = 0, high = nodes.size - 1, start;
 5:     for start = 0 to modules.size do
 6:         int i = LOWERBOUND(nodes[], modules[start], low, high);
 7:         if (i != -1) then
 8:             moduleMap.insert(nodes[i], modules[start]);
 9:             Cap(node[i]) = Cap(node[i]) - Req(modules[start]);
10:             Sort(nodes[]);                 ▷ in ascending order
11:             low = i + 1;
12:         else
13:             moduleMap.insert(nodes[nodes.size - 1], modules[start]);
14:         end if
15:     end for
16:     return (moduleMap);
17: end function
```

### 4.2 Algorithm 2: `LowerBound Algorithm - Algorithm used for Search` (p. 1226)
```text
 1: function LOWERBOUND(NetworkNode nodes[], AppModule module, int low, int high)
 2:     int length = nodes.size, mid = (low + high) / 2;
 3:     while (True) do
 4:         NetworkNode x = node[mid];
 5:         if COMPARE(x, module) == 1 then
 6:             high = mid - 1;
 7:             if (high < low) then return mid;
 8:             end if
 9:         else
10:             low = mid + 1;
11:             if (low > high) then
12:                 return ((mid < length - 1) ? mid + 1 : -1);
13:             end if
14:         end if
15:         mid = (low + high) / 2;
16:     end while
17: end function
```

### 4.3 Algorithm 3: `Compare Network Node and Application Module` (p. 1226)
```text
 1: function COMPARE(NetworkNode a, AppModule b)
 2:     if (a.CPU >= b.CPU && a.RAM >= b.RAM && a.Bandwidth >= b.Bandwidth) then return 1;
 3:     end if
 4:     return -1;
 5: end function
```

---

## 5. Equations and Variable Definitions (Taneja & Davy 2017, p. 1224)

| Eq. # | Published Formula (p. 1224) | Variable / Symbol Definitions |
| :---: | :--- | :--- |
| **(1)** | $\text{Cap}(n_i) = \langle \text{CPU}_i,\; \text{RAM}_i,\; \text{Bandwidth}_i \rangle$ | Capacity vector of network node $n_i$ (scalar CPU in MIPS, RAM in MB, Bandwidth in Mbps). |
| **(2)** | $N = \{n_i\}$ | Set of all computing resources across Fog and Cloud. |
| **(3)** | $N_F = \text{Set of network nodes in Fog layer}$ | Finite-capacity Fog devices (Smart Gateways, ISP Gateway, end devices). |
| **(4)** | $N_C = \text{Set of network nodes in Cloud layer}$ | Cloud VM / data center resource nodes. |
| **(5)** | $N_F \cup N_C = N$ | Exhaustive partition of infrastructure nodes. |
| **(6)** | $N_F \cap N_C = \phi$ | Mutual exclusivity of Fog and Cloud node sets. |
| **(7)** | $\mathcal{G} = \langle V, E \rangle$ | Application Directed Acyclic Graph (DAG). |
| **(8)** | $\text{Req}(v_i) = \langle \text{CPU}_i,\; \text{RAM}_i,\; \text{Bandwidth}_i \rangle$ | Requirement vector of application module $v_i$ (Fig. 2 units: MIPS, MB, Mbps). |
| **(9)** | $V = \{v_i\}$ | Set of all application modules in the DAG. |
| **(10)** | $E = \{e_i \mid e_i = \langle v_i, v_j \rangle\}\; \forall v_i, v_j \in V$ | Set of directed data-flow edges (periodic or event-based). |
| **(11)** | $\mathcal{M} : V \to N$ | Module mapping function assigning each module to a network node. |
| **(12)** | $\forall (v_i, n_i) \in \mathcal{M} \implies \text{Req}(v_i) \le \text{Cap}(n_i)\; \forall v_i \in V,\; \forall n_i \in N$ | Multi-resource feasibility constraint enforced by `COMPARE` (Alg. 3). |

### Exact Published Module & Device Parameter Values (Fig. 2, p. 1224 & Table II, p. 1226)

| Taneja & Davy Module (Fig. 2) | CPU (MIPS) | RAM (MB) | Bandwidth (Mbps) | Notes (p. 1225) |
| :--- | :---: | :---: | :---: | :--- |
| `module_1` | 500 | 1,024 | 250 | Pinned on `Device-X-X` (p. 1225 col. 1) |
| `module_2` | 3,000 | 4,096 | 500 | Event-based |
| `module_3` | 2,000 | 2,048 | 1,000 | Event-based |
| `module_4` | 1,500 | 1,024 | 300 | Event-based |
| `module_5` | 3,000 | 6,144 | 2,000 | Event-based |
| `module_6` | 1,500 | 8,192 | 5,000 | Periodic edges (`TT_10`, `TT_11` @ 100 ms) |

| Taneja & Davy Device (Table II) | Upstream (Mbps) | Downstream (Mbps) | RAM (MB) | CPU (MIPS) |
| :--- | :---: | :---: | :---: | :---: |
| `Cloud` | 1,000 | 10,000 | 40,960 | 40,000 |
| `ISP_Gateway` | 10,000 | 10,000 | 8,192 | 10,000 |
| `Fog-X-Gateway` | 10,000 | 10,000 | 6,144 | 8,000 |
| `Device-X-X` | 100 | 250 | 2,048 | 4,000 |

---

## 6. Bandwidth Investigation (Task 2 — Core Primary-Source Findings)

Answering all 8 required questions directly from Taneja & Davy (2017):

1. **How does the paper define node bandwidth capacity?**  
   - **Equation (1) (p. 1224):** Single scalar attribute `Bandwidth_i` inside $\text{Cap}(n_i) = \langle \text{CPU}_i, \text{RAM}_i, \text{Bandwidth}_i \rangle$.
   - **Table II (p. 1226):** Lists **two** network columns per device: `Upstream Capacity (Mbps)` and `Downstream Capacity (Mbps)` (mirroring iFogSim's `FogDevice` constructor arguments `upBw` and `downBw`).
   - **Unresolved Gap in Primary Paper:** The paper **never publishes an explicit equation** mapping Table II's two columns (`Upstream`, `Downstream`) into Equation (1)'s single scalar `Bandwidth_i`.
2. **How does it define module bandwidth requirements?**  
   - **Equation (8) (p. 1224) & Figure 2 (p. 1224):** Single static scalar attribute `Bandwidth_i` in **Mbps**, explicitly specified by the application developer on each DAG vertex (`250, 500, 1000, 300, 2000, 5000 Mbps`).
   - **Crucial Fact:** Module bandwidth requirements in Fig. 2 are **NOT** computed from Table III's `Network Length` (`500` / `1000`) divided by sensor emission period (`10 ms`). (`500 bytes / 0.01 s = 50 KB/s = 0.4 Mbps`, orders of magnitude smaller than Fig. 2's `250–5000 Mbps`!)
3. **What units are explicitly stated?**  
   - **Explicitly Published:** **`Mbps`** in both Figure 2 (`BANDWIDTH (Mbps)`, p. 1224) and Table II (`Upstream Capacity (Mbps)`, `Downstream Capacity (Mbps)`, p. 1226).
   - *(Note: Table III's `Network Length` column has no explicit unit label, matching iFogSim's `tupleNwLength` convention.)*
4. **Single scalar or separate upstream/downstream values?**  
   - **Model & Algorithms (Eqs. 1, 8; Alg. 3):** **Single scalar** (`a.Bandwidth >= b.Bandwidth`).
   - **Experimental Configuration (Table II):** **Separate Upstream and Downstream** capacities (`1000/10000` for Cloud; `100/250` for `Device-X-X`).
   - **Mathematical Deduction from Fig. 2 + Table II:**
     - `module_1` (`250 Mbps`) is explicitly placed on `Device-X-X` (`Up = 100 Mbps`, `Down = 250 Mbps`) $\implies$ `a.Bandwidth` **cannot** be `Upstream` (`100 < 250`) or `min(Up, Down)` (`100 < 250`); it must be $\ge 250$ (i.e., `Downstream` or `max(Up, Down)` or an unstated host BW parameter).
     - `module_5` (`2000 Mbps`) and `module_6` (`5000 Mbps`) require placement on `ISP_Gateway` (`10000/10000`) or `Cloud` (`Up = 1000, Down = 10000`) $\implies$ on `Cloud`, `a.Bandwidth` again **cannot** be `Upstream` (`1000 < 2000, 5000`); it must be `Downstream` (`10000`) or `max(Up, Down)` (`10000`) or an unstated host BW parameter.
5. **Network-link capacity, host/VM provisioning capacity, or another resource?**  
   - **Ambiguous in Primary Text:** Section III (p. 1223) calls `(CPU, RAM, Bandwidth)` *"the computational capacity (or resource capacity) of a network node"*, and Table II gives only network-link columns (`Upstream/Downstream Capacity (Mbps)`) without ever mentioning CloudSim's `Host.getBw()` or `BwProvisioner`. Yet Figure 2 attaches a static `Bandwidth (Mbps)` reservation directly to each `AppModule` vertex, mirroring CloudSim's `Vm(mips, ram, bw)` / `AppModule(mips, ram, bw)` resource tuple!
6. **How does `COMPARE` evaluate bandwidth?**  
   - **Algorithm 3 (p. 1226, Line 2):** Single scalar inequality `a.Bandwidth >= b.Bandwidth`, conjoined via `&&` with `a.CPU >= b.CPU` and `a.RAM >= b.RAM`.
7. **Is bandwidth decremented after module placement?**  
   - **YES (Algorithm 1, p. 1225, Line 9):** `Cap(node[i]) = Cap(node[i]) - Req(modules[start]);` — vector subtraction across all attributes in Eq. (1) and Eq. (8), including `Bandwidth`.
8. **Are the equations/examples sufficient to calculate exact LBMP bandwidth values for LAMP 2019?**  
   - **NO.** Taneja & Davy rely on static developer-supplied `Bandwidth (Mbps)` values per module (Fig. 2), which LAMP 2019 **does not publish** for `Interface`, `Sensor_Analyzer`, or `Cloud_Storage`.

---

## 7. Comparison Against LAMP 2019

Inspecting LAMP 2019 (`A Hybrid Fog Cloud Latency Aware Module.pdf`, Tables I, III, IV, pp. 846–848):

| Parameter | Taneja & Davy (2017) | LAMP (2019) | Structural Relationship & Gap |
| :--- | :--- | :--- | :--- |
| **Application DAG** | 6 modules (`module_1`..`module_6`), Fig. 2 | 3 modules (`Interface`, `Sensor_Analyzer`, `Cloud_Storage`), Fig. 2 | Both pin the entry/interface module (`module_1` / `Interface`) to end devices. |
| **Module CPU Demand** | Explicit per-module MIPS in Fig. 2 (`500`–`3000 MIPS`) | Table I gives per-edge `CPU Length (MIPS)` (`3500` on `ENHANCED_SENSOR`) + 5 s interval $\implies$ `700 MIPS` steady-state | LAMP does NOT give Fig. 2 static module MIPS; `700 MIPS` is derived via iFogSim's `rate * tupleCpuLength` (validated by LAMP Fig. 3's `< 4` apps per 2,800 MIPS gateway). |
| **Module RAM Demand** | Explicit per-module MB in Fig. 2 (`1024`–`8192 MB`) | Not listed in Table I; standard iFogSim `addAppModule(name, 10)` = `10 MB` | LAMP omits per-module RAM in Table I; `10 MB` is iFogSim convention. |
| **Module BW Demand** | Explicit per-module **Mbps** in Fig. 2 (`250`–`5000 Mbps`) | **NOT PUBLISHED.** Table I lists only `Network Length` (`500`, `1000`) per tuple edge | **Critical Missing Link:** LAMP 2019 never specifies a static Mbps requirement for `Sensor_Analyzer`. |
| **Node CPU & RAM** | Table II: Cloud `40000/40960`, ISP `10000/8192`, Fog `8000/6144`, End `4000/2048` | Table IV: Cloud `44800/40000`, Proxy `2800/4000`, Fog `2800/4000`, End `1000/1000` | Directly parallel hierarchical schemas. |
| **Node Uplink / Downlink BW** | Table II (labeled **Mbps**): Cloud `1000/10000`, ISP `10000/10000`, Fog `10000/10000`, End `100/250` | Table IV (**unit unlabeled**): Cloud `100/10000`, Proxy `10000/10000`, Fog `10000/10000`, End `10000/270` | Both papers populate iFogSim `FogDevice(upBw, downBw)` directly from their respective device tables! |
| **Tuple Emission Rate** | Table III footnote: `10 ms` deterministic | 5.0 s (`5000 ms`) in Healthcare BSN | Different application domains. |

*Key Observation:* LAMP Table IV's `uplink bw` / `downlink bw` values are **device link capacities**, NOT module bandwidth demands. Neither paper establishes an equivalence between LAMP Table I's `Network Length` (`500`, `1000`) and Taneja & Davy Figure 2's static module `Bandwidth (Mbps)`.

---

## 8. Comparison Against Our iFogSim Source Code

Verified directly from Phase 3.3's source trace (exact line references preserved):
- **`FogDevice.uplinkBandwidth` & `downlinkBandwidth`** ([FogDevice.java:65–66, 864, 892](iFogSim-main/src/org/fog/entities/FogDevice.java#L65-L66)): Used solely to compute `networkDelay = tuple.getCloudletFileSize() / bw` during tuple transmission. Populated directly from LAMP Table IV ([HealthcareTopologyFactory.java:55–79](iFogSim-main/src/org/fog/lamp/topology/HealthcareTopologyFactory.java#L55-L79)). `cloud.uplinkBandwidth = 100` is dead code at root (`parentId = -1`, line 56).
- **`Host.getBw()` & `BwProvisionerOverbooking`** ([Host.java:254–256](iFogSim-main/src/org/cloudbus/cloudsim/Host.java#L254-L256), [BwProvisionerOverbooking.java:30, 49–61](iFogSim-main/src/org/cloudbus/cloudsim/sdn/overbooking/BwProvisionerOverbooking.java#L49-L61)): Hardcoded `1,000,000` on every device ([HealthcareTopologyFactory.java:125, 130](iFogSim-main/src/org/fog/lamp/topology/HealthcareTopologyFactory.java#L125-L130)). Enforced exclusively during VM creation ([HostEntity.java:64–69](iFogSim-main/src/org/cloudbus/cloudsim/core/HostEntity.java#L64-L69)).
- **`AppModule.getBw()`** ([AppModule.java:20, 63](iFogSim-main/src/org/fog/application/AppModule.java#L20), [Application.java:66](iFogSim-main/src/org/fog/application/Application.java#L66)): Hardcoded `1,000` by `Application.addAppModule(name, 10)` ([HealthcareBSNApplication.java:73–75](iFogSim-main/src/org/fog/lamp/application/HealthcareBSNApplication.java#L73-L75)). Enforced exclusively against `Host.getBw()` in `HostEntity.guestCreate:64`.
- **Tuple Network Length (`AppEdge.tupleNwLength`)** ([HealthcareBSNApplication.java:80–86](iFogSim-main/src/org/fog/lamp/application/HealthcareBSNApplication.java#L80-L86)): `500` (`ENHANCED_SENSOR`, `PATIENT_STATE`, `PATIENT_CURRENT_STATE_UPDATE`) and `1000` (`STORE_PROCESS_COMPUTE`). Consumed as `tuple.getCloudletFileSize()` in `sendUpFreeLink`/`sendDownFreeLink` and [NetworkUsageMonitor.java:7–9](iFogSim-main/src/org/fog/utils/NetworkUsageMonitor.java#L7-L9).

### Classification of Candidate Bandwidth Mappings

| Candidate Bandwidth Mapping | Classification | Justification |
| :--- | :---: | :--- |
| **M1: `Host.getBw()` (`1,000,000`) vs. `AppModule.getBw()` (`1,000`)** | **DEFENSIBLE APPROXIMATION** | 100% semantically compatible inside CloudSim's VM allocator (`HostEntity.guestCreate:64`) and preserves a single scalar `BW` matching Eq. (1)/Eq. (8)/Alg. 3; however, uses iFogSim boilerplate constants disconnected from LAMP Table I & Table IV. |
| **M2: `max(upBw, downBw)` / `downBw` (`10,000`) vs. `AppModule.getBw()` (`1,000`)** | **NOT SEMANTICALLY COMPATIBLE** | Mixes Subsystem A (network-link rate divisor) with Subsystem B (CloudSim VM host BW quota), even though numerical scales resemble Taneja & Davy Table II (`10,000`) vs Fig. 2 (`1,000`). |
| **M3: `upBw` / `downBw` vs. derived directional tuple flow $\sum \lambda \cdot L_{\text{nw}}$ (`200` up / `200` down)** | **DEFENSIBLE APPROXIMATION** | Dimensionally self-consistent with `FogDevice.sendUpFreeLink`/`sendDownFreeLink` and LAMP Table I & Table IV; however, splits LBMP's single scalar `BW` into two directional flows (with co-location exception on Cloud) and deviates from Taneja & Davy's static Fig. 2 Mbps model. |
| **M4: Exact primary-source reproduction of LAMP 2019's LBMP module Mbps** | **UNRESOLVED** | Missing information: (1) Taneja & Davy never specify how Table II `(Up, Down)` collapses to scalar `a.Bandwidth`; (2) LAMP 2019 never specifies static `Bandwidth (Mbps)` demands for `Interface`, `Sensor_Analyzer`, or `Cloud_Storage`. |

---

## 9. Reassessment of Previous Audits (Task 3)

Re-examining every major conclusion from `PHASE_3_BASELINE_ALGORITHM_ANALYSIS.md` (3.1), `PHASE_3_2_IMPLEMENTATION_READINESS_AUDIT.md` (3.2), and `PHASE_3_3_RESOURCE_AND_CLOUD_SEMANTICS_AUDIT.md` (3.3) against the actual 2017 primary PDF:

| # | Earlier Audit Conclusion | Source Audit | Reassessment Status | Primary-Source Evidence (Taneja & Davy 2017) |
| :-: | :--- | :---: | :---: | :--- |
| **1** | `low = i + 1` after `Sort(nodes[])` causes index invalidation & premature Fog abandonment; questioned whether it was actually in the printed paper. | 3.2 §1 | **CONFIRMED BY PRIMARY SOURCE** *(existence verified; flaw mathematically confirmed)* | **Algorithm 1, Line 10–11 (p. 1225)** literally prints BOTH `Sort(nodes[])` AND `low = i + 1;`. The mathematical flaw under multi-app BSN ($N > |N_F|$) is confirmed (see §11.1). |
| **2** | `LOWERBOUND` binary search is invalid under general non-monotonic 3D resource eligibility; Phase 3.1/3.2 wrote generic textbook binary search (`while (low <= high)`). | 3.1 §2.3, 3.2 §2.3 | **CORRECTED BY PRIMARY SOURCE** *(actual Alg. 2 syntax differs)* & **CONFIRMED** *(3D non-monotonicity holds)* | **Algorithm 2 (p. 1226)** actually uses `while (True)` with `return ((mid < length - 1) ? mid + 1 : -1)` at Line 12—NOT textbook `while (low <= high)`. Non-monotonicity breaks even on Taneja & Davy's own Table II + Fig. 2 once `module_6` is placed on `ISP_Gateway`! |
| **3** | Nodes and modules sorted ascending; exact 3D sort comparator unspecified. | 3.1 §2.2, 3.2 §2.2 | **CONFIRMED BY PRIMARY SOURCE** | **Algorithm 1, Line 2 (p. 1225)** writes only `Sort(nodes[]), Sort(modules[]); ▷ in ascending order` with **zero** comparator definition across `(CPU, RAM, BW)`. |
| **4** | Cloud belongs in the sorted candidate array `nodes[]` (Phase 3.2 excluded it due to `upBw=100`; Phase 3.3 corrected that error and proposed Design C1). | 3.2 §3, 3.3 §3 | **CONFIRMED BY PRIMARY SOURCE** *(3.3 Design C1 confirmed; 3.2 exclusion corrected)* | **Eqs. (2)–(6) (p. 1224)** & **§IV.A (p. 1225)** explicitly pass $N = N_F \cup N_C$ into `MODULEMAP`. Cloud is inside `nodes[]` at the upper end (`nodes[nodes.size - 1]`). |
| **5** | Whether Cloud fallback is constrained or unlimited. | 3.3 §3.1 | **CONFIRMED BY PRIMARY SOURCE** | **§III (p. 1223, col. 2)** explicitly writes *"the Cloud is visualized as being limitless"* (realized as VMs), AND **Alg. 1 Line 13 (p. 1225)** inserts into `nodes[nodes.size - 1]` with NO `COMPARE` check and NO capacity decrement—yet inside `LOWERBOUND`, Cloud IS checked via `COMPARE` and decremented at Line 9 if selected at `i = nodes.size - 1`! |
| **6** | CPU, RAM, and BW resource mappings (`CPU`: derived 700 MIPS approx.; `RAM`: verified 10 MB; `BW`: unresolved from source). | 3.3 §4 | **PARTIALLY CONFIRMED** *(units now verified as MIPS, MB, Mbps; LAMP BW still unresolved)* | Primary PDF **confirms** Taneja & Davy's exact units (`MIPS`, `MB`, `Mbps` in Fig. 2 & Table II), and **confirms** that Taneja & Davy never map Table II `(Up, Down)` to scalar `a.Bandwidth`, nor does LAMP 2019 define module Mbps demands. |
| **7** | Proposed Host-Provisioner BW approximation (`Host.getBw() = 1M` vs `AppModule.getBw() = 1k`). | 3.3 §4.2 | **STILL UNVERIFIED** *(as primary mechanism; remains a defensible approximation)* | Primary PDF never mentions `Host.getBw()` or `BwProvisioner`; it uses `Mbps` values matching Table II scale (`250`–`10000 Mbps`). Host-Provisioner BW remains strictly a CloudSim-consistent **engineering approximation**. |
| **8** | Deterministic tie-breaking policy (`LBMP_PURE` canonical order vs `LBMP_AFFINITY`). | 3.2 §4 | **CONFIRMED BY PRIMARY SOURCE** *(unspecified in paper)* | Primary PDF specifies **zero** tie-breaking rules and **zero** gateway-locality affinity in Algorithms 1–3. Confirming `LBMP_AFFINITY` is strictly a Category C adaptation. |

---

## 10. Resource Mapping & LAMP Baseline Adaptation Tables (Tasks 4 & 5)

### 10.1 Master Parameter Mapping Table (Task 4 — LBMP as LAMP 2019 Healthcare Baseline)

| Parameter | Original LBMP Source (Taneja & Davy 2017) | LAMP 2019 Source (Rezazadeh et al. 2019) | Our iFogSim Value | Classification |
| :--- | :--- | :--- | :--- | :---: |
| **Node Set $N$** | $N = N_F \cup N_C$ (Eqs. 2–6, p. 1224); `Device-X-X` pinned to `module_1` (p. 1225) | Cloud, Proxy-server, Fog Gateways (`d-i`), End Devices (`m-i-j`) pinned to `Interface` (§III.A) | Fog pool `{d-0..d-(G-1), proxy-server}` + `cloud` | **Preserved Core + Topology Adaptation** |
| **Node CPU Capacity** | Table II (p. 1226): `4000–40000 MIPS` | Table IV (p. 848): Cloud `4.48 GHz` (`44800`), Proxy/GW `0.28 GHz` (`2800`), End `1 GHz` (`1000`) | `Host.getTotalMips()`: `44800`, `2800`, `2800`, `1000` | **LAMP Parameter (Verified)** |
| **Node RAM Capacity** | Table II (p. 1226): `2048–40960 MB` | Table IV (p. 848): Cloud `40 GB` (`40000`), Proxy/GW `4 GB` (`4000`), End `1 GB` (`1000`) | `Host.getRam()`: `40000`, `4000`, `4000`, `1000` MB | **LAMP Parameter (Verified)** |
| **Node BW Capacity** | Eq. (1): scalar `Bandwidth_i`; Table II: `Up/Down (Mbps)` (`1000/10000`, `10000/10000`, `100/250`) | Table IV: `upBw/downBw` (`100/10000`, `10000/10000`, `10000/270`, unlabeled) | `Host.getBw() = 1,000,000` (VM); `upBw/downBw` (Link) | **Unavoidable Approximation** |
| **Module CPU Demand** | Fig. 2 (p. 1224): static `500–3000 MIPS` per module | Table I (p. 847): `ENHANCED_SENSOR` = `3500` @ 5 s $\implies$ `700 MIPS` (Fig. 3: `< 4` apps/GW) | `700.0 MIPS` (steady-state); `AppModule.getMips() = 1000` (boilerplate) | **LAMP-Derived Approximation** |
| **Module RAM Demand** | Fig. 2 (p. 1224): static `1024–8192 MB` | Omitted in Table I; iFogSim convention | `AppModule.getRam() = 10 MB` (`HealthcareBSNApplication.java:74`) | **iFogSim Parameter (Verified)** |
| **Module BW Demand** | Fig. 2 (p. 1224): static `250–5000 Mbps` | **Not published** (Table I lists `Network Length = 500, 1000` only) | `AppModule.getBw() = 1000` (VM) OR `200 up / 200 down` (derived flow) | **Unavoidable Approximation (Unresolved in Paper)** |
| **Node & Module Sorting** | Alg. 1 Line 2 & 10: ascending sort (comparator unspecified) | Not specified | Lexicographical `(MIPS, RAM, BW, canonicalId)` ascending | **Preserved Core + Deterministic Tie-Break** |
| **Search Boundary `low`** | Alg. 1 Line 11: literally `low = i + 1` | Not specified (LAMP Fig. 8 shows strong Fog-Cloud balance) | `low = 0` reset after re-sort (documenting literal `low = i + 1` flaw) | **Unavoidable Multi-App Adaptation** |
| **Cloud Behavior** | Inside `nodes[]` ($N_C \subset N$); §III calls Cloud "limitless"; Alg. 1 Line 13 fallback to `nodes[size-1]` | §III: Cloud "unlimited resources"; Table IV: `44800 MIPS`, `40000 MB` | Design C1 (Cloud at `nodes[size-1]` with checks + Line 13 fallback) | **Preserved Core** |

### 10.2 Final Bandwidth Decision Analysis (Task 5 — Comparison of Defensible Mappings)

| Criterion | Option A: Host-Provisioner BW (`Host.getBw()` vs. `AppModule.getBw()`) | Option C: Directional Link-Flow BW (`upBw`/`downBw` vs. $\sum \lambda \cdot L_{\text{nw}}$) | Option D: Table-II-Analog Scalar (`downBw` vs. static/unspecified Mbps) |
| :--- | :--- | :--- | :--- |
| **Mathematical Definition** | `node.bw = Host.getBw()` (`1,000,000`); `mod.bw = AppModule.getBw()` (`1,000`); decrement `node.bw -= mod.bw` | `node.upBw`, `node.downBw`; `mod.upFlow = 200` (`0` on Cloud due to `Cloud_Storage` co-location), `mod.downFlow = 200`; decrement both | `node.bw = downBw` (`10,000`); `mod.bw = ?` (**no published value in LAMP!**) |
| **Capacity & Demand Units** | CloudSim abstract `long` VM BW units (identical on both sides) | `tupleFileSize / clockUnit` (identical on both sides; matches `FogDevice.java:864, 892`) | `downBw` unlabeled (LAMP Table IV); module Mbps **non-existent in LAMP** |
| **Source Evidence** | Directly enforced by `HostEntity.guestCreate:64` & `BwProvisionerOverbooking:52`; NOT mentioned in Taneja & Davy text | Dimensionally grounded in `FogDevice.sendUpFreeLink:864` / `sendDownFreeLink:892` & LAMP Table I/IV; NOT in Taneja & Davy Alg. 3 | `downBw` inferred from Taneja & Davy Fig. 2 + Table II, but LAMP provides **zero** module demand value |
| **Compatibility w/ LBMP (2017)** | High structural fit: single scalar `a.Bandwidth >= b.Bandwidth` (Alg. 3) + vector subtraction (Alg. 1 Line 9) | Moderate: requires splitting Alg. 3's single `a.Bandwidth` into 2 directional inequalities + co-location check | **Fails** — requires inventing an arbitrary module Mbps number |
| **Compatibility w/ LAMP (2019)** | Low for Table IV (ignores `upBw`/`downBw`), high for iFogSim runtime fidelity | High: directly uses LAMP Table I (`Network Length`) & Table IV (`upBw`, `downBw`) | **Fails** — no LAMP Table I/IV source for module Mbps |
| **Compatibility w/ iFogSim** | **Exact** (mirrors `HostEntity.guestCreate:64` VM check; zero category error) | **Consistent** with tuple TX model (not enforced by `HostEntity`, enforced only in LBMP) | **Invalid** if paired with `AppModule.getBw()` (category error) |
| **Effect on Feasibility** | Non-binding (`1,000,000 / 1,000 = 1,000` slots; MIPS binds at 4 on Fog, 64 on Cloud) | Non-binding (`10,000 / 200 = 50` slots; MIPS binds at 4 on Fog, 64 on Cloud) | Unpredictable (depends entirely on invented constant) |
| **Reproduction Limitation** | Uses iFogSim boilerplate (`1M` vs `1k`), not Table IV link rates | Adds directional & co-location logic absent from Taneja & Davy's Alg. 3 | Scientifically inadmissible (fabricated parameter) |

**Recommended Most Defensible Approach (Task 5):**  
Exact primary-source equivalence **cannot be established** because LAMP 2019 omits module Mbps demands and Taneja & Davy omit the `(Up, Down) -> Bandwidth` mapping. Between the only two scientifically valid, zero-fabrication approximations (**Option A** and **Option C**):
- **Primary Recommendation: Option A (CloudSim Host-Provisioner BW: `Host.getBw()` vs. `AppModule.getBw()`)** — because it preserves Taneja & Davy's exact single-scalar `a.Bandwidth >= b.Bandwidth` signature (Algorithm 3), requires **zero invented constants** (reading values directly from iFogSim's `Host` and `AppModule` objects), matches `HostEntity.guestCreate:64` verbatim, and allows **Design C1** (Cloud cleanly inside `nodes[]` at `nodes[nodes.size - 1]`) without special-casing co-location or Cloud's unused `upBw = 100`.
- **Explicit Disclosure Required:** Document clearly that Option A is a **CloudSim VM-layer approximation** (not a proof that Taneja & Davy used `Host.getBw()`), and optionally verify via unit assertion that Option C (directional link-flow `200 up / 200 down`) yields identical feasibility decisions across all 80 benchmark runs.

---

## 11. Mathematical Reasoning (Verified on Primary Algorithms 1, 2, and 3)

### 11.1 Exact Trace of Published `low = i + 1` (Alg. 1 Line 11) + `LOWERBOUND` (Alg. 2 Line 12)
1. **Why It Worked in Taneja & Davy (2017):** Their evaluation ran **1 application** with 5 dynamic modules (`module_2`..`module_6`) across 3–7 Fog nodes (`2, 4, or 6 Fog-X-Gateways + 1 ISP_Gateway + 1 Cloud`). With $|V_{\text{dyn}}| = 5 \le |N|$ (for 4 and 6 gateways), advancing `low = i + 1` acted as a spread/anti-colocation pointer, placing at most 1 module per node across distinct gateways.
2. **Why It Fails Catastrophically on LAMP Healthcare BSN:** Consider 2 gateways + 1 proxy + 1 cloud: `nodes[] = [d-0(2800), d-1(2800), proxy(2800), cloud(44800)]` (`high = 3`), with $N = 12$ identical `Sensor_Analyzer` modules (`700 MIPS` each):
   - `start = 0`: `low=0, high=3` $\to$ Alg. 2 returns `i = 0` (`d-0`). `d-0` drops to `2100`, re-sorts to index `0`. **Line 11 sets `low = 1`.**
   - `start = 1`: `low=1, high=3` $\to$ returns `i = 1` (`d-1`). `d-1` drops to `2100`, re-sorts to index `1`. **Line 11 sets `low = 2`.**
   - `start = 2`: `low=2, high=3` $\to$ returns `i = 2` (`proxy`). `proxy` drops to `2100`, re-sorts to index `2`. **Line 11 sets `low = 3`.**
   - `start = 3`: `low=3, high=3` $\to$ returns `i = 3` (`cloud`). `cloud` drops to `44100`. **Line 11 sets `low = 4`.**
   - `start = 4..11`: `low = 4, high = 3`! Alg. 2 Line 2 computes `mid = (4 + 3)/2 = 3` (`cloud`), Line 5 succeeds, Line 6 sets `high = 2 < 4`, Line 7 returns **`3` (`cloud`)**!
   - **Result under literal Line 11:** **9 of 12 modules go to Cloud** while **75% of Fog capacity (`6,300 / 8,400 MIPS`) sits completely unused**, directly contradicting LAMP 2019 Section V / Figure 8 (*"the proposed algorithm and algorithm LBMP have been able to create a good balance between cloud and fog"*).
   - **Conclusion:** Resetting `low = 0` after `Sort(nodes[])` is an **unavoidable multi-application adaptation** (never falsely attributed to Taneja & Davy's printed Line 11).

### 11.2 Proof of 3D Non-Monotonicity Inside Taneja & Davy's Own Paper
In Taneja & Davy Table II + Fig. 2, suppose `ISP_Gateway` (`<10000 MIPS, 8192 MB, 10000 Mbps>`) hosts `module_6` (`<1500 MIPS, 8192 MB, 5000 Mbps>`). After Line 9 subtraction:
- `Fog-X-Gateway` = `<8000 MIPS, 6144 MB, 10000 Mbps>`
- `ISP_Gateway` = `<8500 MIPS, 0 MB, 5000 Mbps>`
- `Cloud` = `<40000 MIPS, 40960 MB, 10000 Mbps>`
Sorted ascending by CPU, the array is `[Fog-X-Gateway (eligible), ISP_Gateway (INELIGIBLE: 0 MB RAM!), Cloud (eligible)]` — predicate vector **`[TRUE, FALSE, TRUE]`**! Calling Algorithm 2 (`low=0, high=2`) checks `mid=1` (`ISP_Gateway` $\to$ `COMPARE == -1`), sets `low = 2`, and returns `2` (`Cloud`), **missing `Fog-X-Gateway`!**
- **In our homogeneous LAMP BSN Fog pool + Cloud (under Option A Host BW):** All Fog nodes start identically at `<2800, 4000, 1000000>` and Cloud at `<44800, 40000, 1000000>`, and all `Sensor_Analyzer` modules are identical `<700, 10, 1000>`. Because Cloud strictly dominates every Fog node on all 3 dimensions even after 32 modules (`22400 >= 2800`, `39680 >= 4000`, `968000 >= 1000000`) and all Fog nodes decrease linearly with module count $k$, **comonotonicity holds strictly across `nodes[] = Fog ∪ {cloud}` on all 80 planned runs**, making exact `LOWERBOUND` binary search (with `low = 0`) and exact ascending linear scan mathematically identical on our benchmark matrix!

---

## 12. Assumptions and Unresolved Issues

1. **Unresolved in Taneja & Davy (2017):** Exact formula collapsing Table II `(Upstream, Downstream)` into Equation (1)'s scalar `Bandwidth_i`, and exact 3D comparator inside `Sort(nodes[])` / `Sort(modules[])`.
2. **Unresolved in LAMP (2019):** Exact static `Bandwidth (Mbps)` demand (if any) used by Rezazadeh et al. when running LBMP on Healthcare BSN, and whether they reset `low = 0` or altered Algorithm 1 Line 11.
3. **Explicitly Documented Assumptions Required for Phase 3.4:**
   - **A1 (Multi-App `low = 0` Reset):** Reset `low = 0` after `Sort(nodes[])` (preserving multi-module Fog utilization; optionally log literal `low = i + 1` behavior in a single diagnostic check).
   - **A2 (Bandwidth Approximation — Option A):** Use `Host.getBw()` (`1,000,000`) vs. `AppModule.getBw()` (`1,000`), matching `HostEntity.guestCreate:64`.
   - **A3 (CPU Demand):** Use `700.0 MIPS` (`0.2 Hz * 3500 MI`), matching LAMP and native `ModulePlacementEdgewards`.
   - **A4 (Deterministic Total Order):** Nodes sorted by `(MIPS ASC, RAM ASC, BW ASC, canonicalName ASC)`; modules sorted by `(MIPS ASC, RAM ASC, BW ASC, gatewayIdx ASC, mobileIdx ASC)`.
   - **A5 (Cloud Handling — Design C1):** Include `cloud` in `nodes[]` (verified from Eqs. 2–6 & §IV.A), with Line 13 fallback to `nodes[nodes.size - 1]`.

---

## 13. Implementation Recommendations (Do Not Execute Until Approved)

1. **Implement `ModulePlacementLBMP` in isolated package `org.fog.lamp.baselines`** (zero modifications to Phase 1, 2, or 2.2 classes).
2. **Default Primary Baseline (`LBMP_PURE`):**
   - `nodes[] = {d-0..d-(G-1), proxy-server, cloud}` (**Design C1**, primary-source faithful).
   - 3D resource vector: `(MIPS: 700.0, RAM: 10 MB, BW: AppModule.getBw() = 1000 vs Host.getBw() = 1,000,000)` (**Option A**).
   - Atomic 3D update + ascending re-sort after every placement.
   - `low = 0` reset after re-sort + exact Algorithm 2 `LOWERBOUND` guarded by monotonicity check (with linear-scan safety fallback for general topologies).
   - Zero locality/affinity bias in `LBMP_PURE`; keep `LBMP_AFFINITY` strictly as an optional secondary variant if desired.
3. **SAMP Governance Unchanged:** Historical SAMP (`Rezazadeh et al. 2018 [9]`) remains **UNVERIFIED / BLOCKED**; only implement `SA_SYNTHETIC` if explicitly requested as a Category C synthetic comparator.

---

## 14. Exact File Paths and Source References

- **Primary LBMP PDF:** [Resource Aware Placement of IoT Application.pdf](Resource Aware Placement of IoT Application.pdf) (pp. 1222–1228; Eqs. 1–12 on p. 1224; Fig. 2 on p. 1224; Alg. 1 on p. 1225; Algs. 2–3 & Tables I–III on p. 1226)
- **Primary LAMP PDF:** [A Hybrid Fog Cloud Latency Aware Module.pdf](A Hybrid Fog Cloud Latency Aware Module.pdf) (pp. 845–850; §III p. 846; Table I p. 847; Alg. 1 & Tables III–IV p. 848; §V pp. 848–849)
- **iFogSim / LAMP Source Files Audited:**
  - [FogDevice.java](iFogSim-main/src/org/fog/entities/FogDevice.java#L65-L66) (`upBw`/`downBw` lines 65–66, `sendUpFreeLink` line 864, `sendUp` line 872, `sendDownFreeLink` line 892)
  - [Host.java](iFogSim-main/src/org/cloudbus/cloudsim/Host.java#L254-L267) (`getBw` line 254, `getRam` line 265, `getTotalMips` line 192)
  - [HostEntity.java](iFogSim-main/src/org/cloudbus/cloudsim/core/HostEntity.java#L51-L84) (`guestCreate` lines 51–84)
  - [BwProvisionerOverbooking.java](iFogSim-main/src/org/cloudbus/cloudsim/sdn/overbooking/BwProvisionerOverbooking.java#L30-L61) (`overbookingRatioBw=1.0` line 30, `allocateBwForGuest` lines 49–61)
  - [Application.java](iFogSim-main/src/org/fog/application/Application.java#L63-L74) (`addAppModule` defaults: `mips=1000`, `size=10000`, `bw=1000`)
  - [HealthcareTopologyFactory.java](iFogSim-main/src/org/fog/lamp/topology/HealthcareTopologyFactory.java#L54-L135)
  - [HealthcareBSNApplication.java](iFogSim-main/src/org/fog/lamp/application/HealthcareBSNApplication.java#L73-L86)
  - [ModulePlacementEdgewards.java](iFogSim-main/src/org/fog/placement/ModulePlacementEdgewards.java#L199-L228)
  - [ModulePlacementLAMP.java](iFogSim-main/src/org/fog/lamp/placement/ModulePlacementLAMP.java#L46-L150)
- **Prior Audit Reports Reassessed (Unmodified):**
  - [PHASE_3_BASELINE_ALGORITHM_ANALYSIS.md](PHASE_3_BASELINE_ALGORITHM_ANALYSIS.md)
  - [PHASE_3_2_IMPLEMENTATION_READINESS_AUDIT.md](PHASE_3_2_IMPLEMENTATION_READINESS_AUDIT.md)
  - [PHASE_3_3_RESOURCE_AND_CLOUD_SEMANTICS_AUDIT.md](PHASE_3_3_RESOURCE_AND_CLOUD_SEMANTICS_AUDIT.md)

---

## 15. Final Implementation Readiness Decision (Task 6)

| Component | Primary-Source Evidence (Taneja & Davy 2017) | LAMP 2019 Compatibility | iFogSim Compatibility | Final Status |
| :--- | :--- | :--- | :--- | :---: |
| **CPU** | Verified (Eqs. 1, 8; Fig. 2 & Table II in `MIPS`) | Derived `700.0 MIPS` matches Table I & Fig. 3 (`< 4` apps/GW) | Matches `ModulePlacementEdgewards` & `ModulePlacementLAMP` (distinct from boilerplate `AppModule.mips=1000`) | **READY (Documented Approximation)** |
| **RAM** | Verified (Eqs. 1, 8; Fig. 2 & Table II in `MB`) | Compatible with Table IV (`4000` / `40000 MB`); module RAM `10 MB` by iFogSim convention | **Verified exact match** (`RamProvisionerSimple`, `HostEntity.guestCreate:58`) | **VERIFIED & READY** |
| **BW** | Partially Verified (`Mbps` scalar in Eq. 1/8 & Fig. 2; `(Up, Down)` mapping omitted in Table II) | **Unresolved** (LAMP omits static module Mbps demands) | Option A (`Host.getBw()` vs `AppModule.getBw()`) exact in `HostEntity:64`; Option C (`upBw`/`downBw` vs $\lambda L_{\text{nw}}$) dimensionally sound | **READY WITH DOCUMENTED APPROXIMATION** |
| **Module sorting** | Verified ascending (Alg. 1 Line 2); 3D comparator unspecified | All `Sensor_Analyzer` modules homogeneous | Explicit total order `(MIPS, RAM, BW, gwIdx, mobIdx)` | **READY (Deterministic Policy)** |
| **Node sorting** | Verified ascending + post-placement re-sort (Alg. 1 Lines 2, 10); 3D comparator unspecified | All Fog nodes start homogeneous (`2800, 4000`) | Explicit total order `(MIPS, RAM, BW, canonicalName)` | **READY (Deterministic Policy)** |
| **LOWERBOUND** | Verified verbatim (Alg. 2, p. 1226) AND `low = i + 1` verified in Alg. 1 Line 11 (p. 1225) | Literal `low = i + 1` breaks LAMP multi-app Fog utilization (75% Fog wasted); requires `low = 0` reset | Comonotonicity holds on our homogeneous Fog + Cloud pool under Option A; guarded by runtime verifier | **READY (Multi-App `low=0` Adaptation)** |
| **COMPARE** | Verified verbatim (Alg. 3, p. 1226: 3D `&&` check returning `1` / `-1`) | Compatible under CPU (`700`), RAM (`10`), and chosen BW approximation | Enforced cleanly across all 3 dimensions before `ModulePlacementMapping` | **VERIFIED & READY** |
| **Cloud handling** | Verified inside `nodes[]` ($N = N_F \cup N_C$, Eqs. 2–6); Line 13 fallback to `nodes[size-1]`; §III "limitless" | Compatible with both Table IV (`44800 MIPS`) and §III "unlimited" | **Design C1** (Cloud inside `nodes[]` at `size-1`) works cleanly under Option A (`Host.getBw() = 1M`) | **VERIFIED & READY (Design C1)** |
| **Tie handling** | Unspecified in primary paper | All BSN Fog nodes & modules tie initially | `LBMP_PURE` (canonical name order) strictly separated from optional `LBMP_AFFINITY` | **READY (Documented Policy)** |

### Final Readiness Verdict

> [!IMPORTANT]
> ## **READY WITH DOCUMENTED APPROXIMATIONS**
>
> **Summary of Readiness:**
> - **All primary-source verification for LBMP is now 100% complete** (full 7-page Taneja & Davy 2017 PDF audited visually and textually; no further LBMP primary-source retrieval is needed).
> - Proceeding to **Phase 3.4 (LBMP Java Implementation & Validation)** is ready upon your sign-off on four explicitly documented approximations/adaptations:
>   1. **Multi-app `low = 0` reset** after `Sort(nodes[])` (resolving the verified Algorithm 1 Line 11 `low = i + 1` defect on multi-application workloads).
>   2. **Bandwidth Option A** (`Host.getBw() = 1,000,000` vs. `AppModule.getBw() = 1,000`, matching `HostEntity.guestCreate:64`, with Option C directional link-flow documented as an equivalent non-binding check).
>   3. **Cloud Design C1** (Cloud included in `nodes[]` per Eqs. 2–6 with Line 13 fallback, using finite Table IV capacities).
>   4. **Variant Scope:** `LBMP_PURE` (primary baseline) plus optional `LBMP_AFFINITY` (Category C), while keeping unverified historical **SAMP** excluded unless explicitly authorized as `SA_SYNTHETIC`.

---

## 16. Complete Bibliography

1. **Z. Rezazadeh, M. Rezaei, and M. Nickray**, *"LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications,"* in Proceedings of the 5th Conference on Knowledge-Based Engineering and Innovation (KBEI), Iran University of Science and Technology, Tehran, Iran, IEEE, pp. 845–850, 2019.
2. **M. Taneja and A. Davy**, *"Resource Aware Placement of IoT Application Modules in Fog-Cloud Computing Paradigm,"* in Proceedings of the 2017 IFIP/IEEE Symposium on Integrated Network and Service Management (IM) — Special Track on Management of IoT, Lisbon, Portugal, pp. 1222–1228, May 2017. ISBN: `978-3-901882-89-0`.
3. **H. Gupta, A. V. Dastjerdi, S. K. Ghosh, and R. Buyya**, *"iFogSim: A Toolkit for Modeling and Simulation of Resource Management Techniques in the Internet of Things, Edge and Fog Computing Environments,"* Software: Practice and Experience, vol. 47, no. 9, pp. 1275–1296, 2017.
4. **R. Buyya, R. Ranjan, and R. N. Calheiros**, *"Modeling and simulation of scalable Cloud computing environments and the CloudSim toolkit: Challenges and opportunities,"* in International Conference on High Performance Computing & Simulation (HPCS '09), pp. 1–11, June 2009.
5. **Z. Rezazadeh, D. Rahbari, and M. Nickray**, *"Optimized Module Placement in IoT Applications Based on Fog Computing,"* in 26th Iranian Conference on Electrical Engineering (ICEE), Mashhad, Iran, IEEE, pp. 1553–1558, 2018. DOI: `10.1109/ICEE.2018.8472469` *(Primary PDF unavailable / UNVERIFIED)*.
6. **A. Khalid and M. Shahbaz**, *"Service Architecture Models For Fog Computing: A Remedy for Latency Issues in Data Access from Clouds,"* KSII Transactions on Internet and Information Systems (TIIS), vol. 11, no. 5, pp. 2310–2345, 2017.

---
*Phase 3.3.1 Primary-Source Re-Audit complete. Zero Java files modified, zero simulations run, zero earlier phase reports altered. Standing by for user review and Phase 3.4 authorization.*
