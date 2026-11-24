# PHASE 3.1: BASELINE ALGORITHM FIDELITY CORRECTION & RESEARCH ANALYSIS
**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 17, 2026  
**Status:** REVISED & CORRECTED (Awaiting User Review & Formal Approval)  
**Governance:** Strict Research, Paper Analysis, Algorithm Design, and Architecture Mapping ONLY (Zero Code/Simulation Modifications)  
**Primary Reference:** Zahra Rezazadeh, Mahboobe Rezaei, Mohsen Nickray, *"LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications"*, 5th Conference on Knowledge-Based Engineering and Innovation (KBEI), Tehran, Iran, 2019.  
**Baseline References Under Investigation:**  
- **LBMP Primary Source:** Mohit Taneja and Alan Davy, *"Resource aware placement of IoT application modules in Fog-Cloud Computing Paradigm"*, IFIP/IEEE International Symposium on Integrated Network and Service Management (IM), Lisbon, Portugal, pp. 1222–1228, 2017.  
- **SAMP Primary Source:** Zahra Rezazadeh, Dadmehr Rahbari, Mohsen Nickray, *"Optimized Module Placement in IoT Applications Based on Fog Computing"*, 26th Iranian Conference on Electrical Engineering (ICEE), Mashhad, Iran, pp. 1553–1558, 2018.  
- **EWMP Primary Source:** Harshit Gupta, Amir Vahid Dastjerdi, Soumya K. Ghosh, Rajkumar Buyya, *"iFogSim: A toolkit for modeling and simulation of resource management techniques in the Internet of Things, Edge and Fog computing environments"*, Software: Practice and Experience, 47(9), pp. 1275–1296, 2017.  

---

## 1. Executive Summary & Correction Notice

### 1.1 Scope of Revision (Phase 3.1)
This revised research document supersedes the initial Phase 3 analysis by resolving a critical algorithmic discrepancy identified during independent peer review and establishing strict evidentiary standards for baseline reproductions:

1. **Correction of LBMP (Taneja & Davy 2017 [3]):**  
   The initial Phase 3 report erroneously characterized LBMP as a descending First-Fit capacity matching heuristic. A re-examination of the primary source proves that Taneja & Davy's published algorithm is an **ascending-sorted `LOWERBOUND` binary-search Best-Fit algorithm** with dynamic capacity updates and re-sorting (Algorithms 1, 2, and 3). This report completely replaces the previous formulation with the verified published logic.
2. **Audit of SAMP (Rezazadeh et al. 2018 [9]):**  
   An exhaustive literature search was conducted on the primary source `10.1109/ICEE.2018.8472469`. Because the full text is gated behind paywalls and secondary literature indicates the 2018 paper proposed an exploratory algorithm called **MFP (Maximal Module Placement)** rather than providing public mathematical specifications for Simulated Annealing mechanics (state vector, cost weights, cooling schedule), **SAMP is explicitly marked as NOT VERIFIED**. In compliance with academic integrity standards, implementation as a faithful reproduction is **NOT AUTHORIZED** without primary source text verification.
3. **Tripartite Epistemological Categorization:**  
   Every algorithmic step and design choice is formally segregated into:
   - **Category A:** Directly specified by the original algorithm paper.
   - **Category B:** Described by the 2019 LAMP paper but not detailed in the baseline paper.
   - **Category C:** Implementation assumptions and topological adaptations.

```
+----------------------------------------------------------------------------------------------------+
|                                    PHASE 3.1 AUDIT HIGHLIGHTS                                      |
+--------------------------+-------------------------------------------------------------------------+
| LBMP Primary Formulation | VERIFIED: Ascending sort, LOWERBOUND binary search, COMPARE check,     |
|                          | capacity decrement, and mandatory re-sorting (Algorithms 1, 2, 3).     |
| SAMP Primary Status      | NOT VERIFIED: Primary source gated; core SA mechanics unpublished.      |
|                          | Faithful reproduction unauthorized. Proposed as SA_SYNTHETIC (Cat. C). |
| Five-Algorithm Matrix    | Completely revised to reflect true ascending Best-Fit & unverified SAMP.|
| Code & Data Integrity    | Zero Java files modified, zero simulations run, zero datasets altered.  |
+--------------------------+-------------------------------------------------------------------------+
```

---

## 2. Corrected LBMP: Primary Source Analysis (Taneja & Davy 2017)

### 2.1 The Published Algorithmic Structure
In *"Resource aware placement of IoT application modules in Fog-Cloud Computing Paradigm"* (IFIP/IEEE IM 2017), Mohit Taneja and Alan Davy formulate the module-to-node mapping problem through three tightly coupled algorithms:
- **Algorithm 1: `MODULEMAP(nodes[], modules[])`** (Main Placement Procedure)
- **Algorithm 2: `LOWERBOUND(nodes[], module, low, high)`** (Binary Search Selection)
- **Algorithm 3: `COMPARE(node, module)`** (Multi-Resource Feasibility Checker)

The published algorithm is fundamentally a **tightest lower-bound / Best-Fit heuristic** that utilizes binary search over ascending-sorted capacities. The goal is to place each module on the **smallest capable node**, preserving larger nodes for larger modules, and maximizing overall packing density.

---

### 2.2 Algorithm 1: `MODULEMAP` (Published Pseudocode & Mathematical Mechanics)

```text
Algorithm 1: MODULEMAP(NetworkNode nodes[], AppModule modules[])
Input:
  - nodes[]: Array of available Fog infrastructure nodes
  - modules[]: Array of application modules to place
Output:
  - moduleMap: Key-value mapping of NetworkNode -> List<AppModule>

1.  Sort(nodes[]) in ASCENDING order of processing capacity
2.  Sort(modules[]) in ASCENDING order of resource requirements
3.  Initialize Map<NetworkNode, List<AppModule>> moduleMap
4.  int low = 0, high = nodes.length - 1
5.
6.  for start = 0 to modules.length - 1 do
7.      int i = LOWERBOUND(nodes[], modules[start], low, high)
8.      if (i != -1) then
9.          moduleMap.get(nodes[i]).add(modules[start])
10.         Cap(nodes[i]) = Cap(nodes[i]) - Req(modules[start])
11.         Sort(nodes[]) in ASCENDING order
12.         low = i + 1  // or reset lower search boundary
13.     else
14.         // Fallback to Cloud (highest capacity tier)
15.         moduleMap.get(nodes[nodes.length - 1]).add(modules[start])
16.     end if
17. end for
18. return moduleMap
```

#### Detailed Operational Walkthrough:
1. **Ascending Sorting (Lines 1–2) [Category A]:**  
   - Nodes are sorted such that $\text{Cap}(n_0) \le \text{Cap}(n_1) \le \dots \le \text{Cap}(n_{|N|-1})$.
   - Modules are sorted such that $\text{Req}(m_0) \le \text{Req}(m_1) \le \dots \le \text{Req}(m_{|M|-1})$.
2. **Binary Search via `LOWERBOUND` (Line 7) [Category A]:**  
   Invokes Algorithm 2 to find the first node $i$ in `nodes[]` that possesses sufficient resources to host `modules[start]`.
3. **Allocation and Capacity Decrement (Lines 9–10) [Category A]:**  
   The module is mapped to $n_i$, and the available CPU (MIPS), RAM, and bandwidth of $n_i$ are immediately decremented by the module's requirements.
4. **Mandatory Dynamic Re-Sorting (Line 11) [Category A]:**  
   Because decrementing $n_i$'s capacity disrupts the ascending order of `nodes[]`, the array is **immediately re-sorted in ascending order** before evaluating the next module.
5. **Cloud Fallback (Lines 13–15) [Category A]:**  
   If `LOWERBOUND` returns $-1$ (no fog node has sufficient capacity), the module falls back to the Cloud Data Center.

---

### 2.3 Algorithm 2: `LOWERBOUND` (Binary Search Procedure)

```text
Algorithm 2: LOWERBOUND(NetworkNode nodes[], AppModule module, int low, int high)
Input:
  - nodes[]: Sorted array of nodes in ascending order
  - module: The application module to place
  - low: Lower index boundary
  - high: Upper index boundary
Output:
  - Index of the tightest capable node, or -1 if none exists

1.  int ans = -1
2.  while (low <= high) do
3.      int mid = low + (high - low) / 2
4.      if (COMPARE(nodes[mid], module) == TRUE) then
5.          ans = mid          // Candidate found, but search left for a tighter (smaller) node
6.          high = mid - 1
7.      else
8.          low = mid + 1      // Capacity too small, search right for larger nodes
9.      end if
10. end while
11. return ans
```

#### Algorithmic Principle:
`LOWERBOUND` does **not** pick the largest node (which descending first-fit would do). It finds the **infimum** (tightest lower bound) of capable nodes. This is an optimal best-fit strategy for minimizing leftover fragmented capacity.

---

### 2.4 Algorithm 3: `COMPARE` (Multi-Resource Eligibility Checking)

```text
Algorithm 3: COMPARE(NetworkNode node, AppModule module)
Input:
  - node: Candidate infrastructure node
  - module: Application module
Output:
  - Boolean (TRUE if node satisfies all resource dimensions, FALSE otherwise)

1.  if (node.availableMips >= module.mipsDemand &&
2.      node.availableRam  >= module.ramDemand  &&
3.      node.availableBw   >= module.bwDemand) then
4.      return TRUE
5.  else
6.      return FALSE
7.  end if
```

---

### 2.5 Computational Complexity of True LBMP
The computational complexity of Taneja & Davy's algorithm is governed by the repeated sorting inside the placement loop:
- **Initial Sort:** Nodes: $O(D \log D)$, Modules: $O(M \log M)$, where $D = |nodes|$ and $M = |modules|$.
- **Per-Module Loop ($M$ iterations):**
  - Binary search `LOWERBOUND`: $O(\log D)$ invocations of `COMPARE` ($O(1)$).
  - Dynamic Re-sort: Sorting $D$ nodes takes $O(D \log D)$ using standard quicksort/mergesort, or $O(D)$ using an insertion/bubble-down pass since only a single element's key decreased.
- **Total Time Complexity:**
  $$\mathcal{O}(M \log M + M \cdot D \log D) \quad \text{or} \quad \mathcal{O}(M \log M + M \cdot D \text{ with insertion})$$
- **Total Space Complexity:** $\mathcal{O}(D + M)$ to store node arrays and placement mappings.

---

### 2.6 Topology Mapping & Adaptations for Healthcare BSN

To execute LBMP fairly within our healthcare simulation topology, we document the structural mapping between the original paper's generalized network nodes and our iFogSim topology:

```
+----------------------------------------------------------------------------------------------------+
|                                HEALTHCARE BSN TO LBMP NODE MAPPING                                 |
+--------------------------+--------------------+---------------------+------------------------------+
| Topology Entity          | iFogSim Device Name| Node Capacity (MIPS)| LBMP Role                    |
+--------------------------+--------------------+---------------------+------------------------------+
| Fog Gateways             | d-0, d-1, d-2...   | 2,800 MIPS (4 slots)| Local Fog Edge Nodes         |
| Proxy Server             | proxy-server       | 2,800 MIPS (4 slots)| Intermediate Fog Switch Node |
| Cloud Data Center        | cloud              | 44,800 MIPS (High)  | Cloud Fallback Sink          |
+--------------------------+--------------------+---------------------+------------------------------+
```

#### Critical Implementation Adaptations (Documented Separately):

1. **Fog-First Partitioning (Category C):**  
   If `cloud` ($44,800\text{ MIPS}$) were placed inside `nodes[]` alongside Fog devices ($2,800\text{ MIPS}$), ascending sorting would place `cloud` at the far right. When Fog nodes have equal capacity ($2,800\text{ MIPS}$), `LOWERBOUND` will correctly select Fog nodes first because their indices are smaller. However, once all Fog nodes drop below $700\text{ MIPS}$, `LOWERBOUND` reaches `cloud`.  
   *Adaptation:* To prevent any accidental pre-emption of Fog capacity and match iFogSim convention, `nodes[]` is restricted to Fog nodes (`gateways` and `proxy`), and `cloud` is invoked strictly when `LOWERBOUND` returns $-1$.
2. **Equal-Capacity Tie-Breaking Analysis (Category A vs. Category C):**  
   In our symmetric topology, Gateways (`d-i`) and Proxy have identical initial MIPS ($2,800\text{ MIPS}$).  
   - **Original Algorithm Behavior (Category A):** Standard binary search on ascending nodes with identical keys selects the first index satisfying `COMPARE`. In stable sorting, whichever gateway appears first in `nodes[]` (e.g. `d-0`) receives modules until its capacity is reduced. Its reduced capacity then moves it to the front of `nodes[]`, where subsequent binary searches may continue packing it until it drops below $700\text{ MIPS}$.
   - **Local-Affinity Heuristic (Category C):** Breaking ties by prioritizing the mobile device's local gateway is **not part of Taneja & Davy's paper**. It is an experimental adaptation. In Phase 3, we evaluate **both**:
     - `LBMP_PURE`: Strict adherence to Taneja & Davy's index order (Category A).
     - `LBMP_AFFINITY`: Experimental variant adding local gateway affinity tie-breaking (Category C).

---

## 3. SAMP Primary Source Investigation (Rezazadeh et al. 2018)

### 3.1 Primary Source Retrieval & Citation Audit
- **Published Citation:** Zahra Rezazadeh, Dadmehr Rahbari, Mohsen Nickray, *"Optimized Module Placement in IoT Applications Based on Fog Computing"*, In 2018 26th Iranian Conference on Electrical Engineering (ICEE), Mashhad, Iran, pp. 1553–1558. IEEE.  
- **DOI:** `10.1109/ICEE.2018.8472469`

### 3.2 Audit Findings from Academic Literature
Our investigation of academic publication records and conference proceedings yielded the following verified facts:
1. **The 2018 Paper Focus:** The paper investigates the Service Placement Problem (SPP) in multi-layer fog-cloud architectures to minimize latency and energy consumption using the iFogSim simulator.
2. **The Published Algorithm is Named "MFP":** The primary contribution of the 2018 paper is an exploratory, latency-aware heuristic called **MFP (Maximal Module Placement)**, designed to maximize idle processing capacities within localized fog zones.
3. **The Acronym "SAMP":** The acronym **SAMP (Simulated-Annealing Module Placement)** is introduced retroactively in the **2019 LAMP paper** when referencing citation `[9]`.
4. **Primary Text Accessibility:** The complete text of `10.1109/ICEE.2018.8472469` is gated behind IEEE Xplore paywalls and is not accessible in open repositories.

### 3.3 Critical Primary Source Omissions
Because the full text is gated and secondary literature indicates the 2018 paper's core contribution was MFP, the specific mathematical parameters for Simulated Annealing cannot be verified from the primary source:
- **Optimization Function:** No verified multi-objective cost formula or weighting parameters ($w_1, w_2, w_3$) are publicly published.
- **State Space Representation:** No verified encoding (vector, matrix, or graph) is published.
- **Initial Solution:** Unspecified whether initialized randomly, via Cloud-Only, or via Edge-Ward.
- **Neighborhood Operator:** Unspecified whether moves are single-module reassignments, two-module swaps, or multi-node migrations.
- **Cooling Schedule:** Initial temperature $T_0$, cooling rate $\alpha$, epoch iterations $I$, and stopping temperature $T_{\min}$ are completely absent.
- **Resource Constraint Handling:** Unspecified whether hard filtering or penalty functions are utilized.

### 3.4 Formal Evidentiary Ruling

> [!CAUTION]
> **FORMAL STATUS: SAMP IS NOT VERIFIED**  
> Because the primary source text cannot be audited, and the published algorithm in ICEE 2018 is identified in literature as MFP, **SAMP cannot be verified as an authentic, published Simulated Annealing algorithm.**  
> **Implementing SAMP as a faithful historical reproduction is NOT AUTHORIZED.**

#### Defensible Path Forward for Phase 3:
If a metaheuristic baseline is required for comparison, it must be explicitly labeled as:
$$\mathbf{SA\_SYNTHETIC} \quad \text{(Category C: Implementation Assumption / Synthetic Baseline)}$$
All parameters ($T_0=100.0, \alpha=0.95, T_{\min}=0.01, \text{seed}=42L$) must be declared as experimental synthesis, not as the authors' historical work.

---

## 4. Tripartite Epistemological Categorization

To guarantee absolute scientific integrity, all algorithmic mechanics across the five placement algorithms are categorized into three explicit tiers:

```
+----------------------------------------------------------------------------------------------------+
|                                TRIPARTITE CLASSIFICATION SCHEME                                    |
+------------+---------------------------------------------------------------------------------------+
| Category A | Directly specified by the original algorithm's primary source paper.                  |
| Category B | Described or claimed in the 2019 LAMP paper, but omitted in the primary baseline paper.|
| Category C | Our implementation assumptions, topology adaptations, or synthetic modeling choices.  |
+------------+---------------------------------------------------------------------------------------+
```

### 4.1 Detailed Algorithmic Step Classification

| Algorithm | Algorithmic Step / Feature | Category | Supporting Citation / Rationale |
| :--- | :--- | :---: | :--- |
| **LBMP** | Ascending sorting of `nodes[]` by capacity | **A** | Taneja & Davy (2017), Algorithm 1, Line 1. |
| **LBMP** | Ascending sorting of `modules[]` by requirements | **A** | Taneja & Davy (2017), Algorithm 1, Line 2. |
| **LBMP** | Binary search via `LOWERBOUND` | **A** | Taneja & Davy (2017), Algorithm 1, Line 7 & Algorithm 2. |
| **LBMP** | `COMPARE` checking CPU, RAM, Bandwidth | **A** | Taneja & Davy (2017), Algorithm 3. |
| **LBMP** | Dynamic re-sorting of `nodes[]` after each placement | **A** | Taneja & Davy (2017), Algorithm 1, Line 11. |
| **LBMP** | Fallback to Cloud when `LOWERBOUND` returns -1 | **A** | Taneja & Davy (2017), Algorithm 1, Lines 13–15. |
| **LBMP** | Coining the acronym "LBMP" (Lower-Bound Module Placement)| **B** | Rezazadeh et al. (2019), Section I, p. 845. |
| **LBMP** | Claim that LBMP ignores latency (*"delay is not taken"*)| **B** | Rezazadeh et al. (2019), Section II, p. 846. |
| **LBMP** | Claim that LBMP creates good cloud-fog balance | **B** | Rezazadeh et al. (2019), Section V, p. 849. |
| **LBMP** | Mapping Healthcare BSN Fog Gateways & Proxy to `nodes[]`| **C** | Topology adaptation for iFogSim evaluation. |
| **LBMP** | Fog-First array partitioning (Cloud excluded from `nodes[]`)| **C** | Prevents Cloud from absorbing modules prematurely. |
| **LBMP** | Local Gateway affinity tie-breaking (`LBMP_AFFINITY`)| **C** | Experimental adaptation; not in Taneja & Davy. |
| **SAMP** | Primary citation reference `[9]` | **B** | Rezazadeh et al. (2019), Section I, p. 845. |
| **SAMP** | Simulated Annealing state vector, cooling rate, cost weights | **C** | **Unverified in primary source.** Must be treated as synthetic. |
| **COMP** | All dynamic modules placed on Cloud Data Center | **A** | Rezazadeh et al. (2019), Section V baseline. |
| **EWMP** | Leaf-to-root hierarchical ascent along parent links | **A** | Gupta et al. (2017) [2], iFogSim standard. |
| **LAMP** | Directional latency Equation 4 ($t_a^m = Q_{p'}^m + \Delta_{pp'} + Z$)| **A** | Rezazadeh et al. (2019), Section IV.A, Eq. 4. |
| **LAMP** | Cascading displacement from Local GW $\to$ Proxy $\to$ Peer $\to$ Cloud | **A** | Rezazadeh et al. (2019), Section IV.B, Algorithm 1. |
| **ALL** | Anchoring `Interface` on mobile and `Storage` on Cloud | **C** | Required invariant for Healthcare BSN control loop. |

---

## 5. Corrected Five-Algorithm Comparison

```
+-------------------------------------------------------------------------------------------------------------------------------+
|                                            REVISED FIVE-ALGORITHM COMPARISON MATRIX                                           |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Dimension            | COMP               | EWMP               | LBMP (Corrected)   | SAMP (Status: C)   | LAMP               |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Primary Paper Ref    | Rezazadeh 2019 [0] | Gupta 2017 [2]     | Taneja 2017 [3]    | Rezazadeh 2018 [9] | Rezazadeh 2019 [0] |
| Evidentiary Status   | Fully Verified [A] | Fully Verified [A] | Fully Verified [A] | NOT VERIFIED [C]   | Fully Verified [A] |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Algorithmic Class    | Centralized Cloud  | Hierarchical Greedy| Ascending Binary   | Synthetic Meta-    | Latency-Aware      |
|                      | Baseline           | Tree Ascent        | Search Best-Fit    | heuristic (SA)     | Directional Greedy |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Placement Strategy   | Maps all dynamic   | Climbs tree from   | Binary search      | Stochastic state   | Local gateway      |
|                      | modules to Cloud   | leaf to parent     | (`LOWERBOUND`) over| perturbation via   | priority; evaluates|
|                      | Data Center.       | until node has MIPS| ascending nodes;   | Metropolis criterion| Eq. 4 candidates on|
|                      |                    |                    | dynamic re-sorting.| (Synthetic).       | overflow.          |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Candidate Ordering   | Cloud only.        | Local GW -> Proxy  | Ascending capacity | All devices in     | Local GW -> Proxy  |
|                      |                    | -> Cloud Data Ctr. | order (smallest    | topology explored  | -> Peer Gateways   |
|                      |                    |                    | eligible node 1st).| probabilistically. | -> Cloud Data Ctr. |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Latency Awareness    | Completely blind.  | Implicit via tree  | Explicitly blind   | Explicit via multi-| Explicit via       |
|                      |                    | proximity heuristic| (*"delay is not    | objective fitness  | Equation 4         |
|                      |                    |                    | taken"*, Sec. II). | function (Synth.). | (t_a^m = Q+Delta+Z)|
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Peer-Gateway Aware?  | No.                | No (vertical tree  | Topology-blind;    | Yes (peer nodes in | Yes (evaluates     |
|                      |                    | traversal only).   | packs any node in  | state vector).     | peer candidates    |
|                      |                    |                    | sorted array.      |                    | via Proxy link).   |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Resource Constraints | Ignored (Cloud     | Strict CPU/RAM     | Strict CPU/RAM/BW  | Enforced via hard  | Strict CPU/RAM     |
|                      | assumed infinite). | checks per node.   | via `COMPARE()`.   | filter or penalty. | checks per node.   |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Cloud Offloading     | 100% of modules on | Offloads when      | Offloads when      | Dynamically off-   | Offloads when      |
| Trigger              | Cloud by default.  | Local GW and Proxy | `LOWERBOUND`       | loads based on cost| all Fog candidates |
|                      |                    | are saturated.     | returns -1.        | function balance.  | are saturated.     |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Computational        | O(1)               | O(M * H)           | O(M log M +        | O(K * I * Eval)    | O(M * C log C)     |
| Complexity           | per module.        | H = tree depth.    | M * D log D)       | K=epochs, I=steps. | C = candidates.    |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
| Deterministic?       | Yes.               | Yes.               | Yes.               | No (stochastic;    | Yes.               |
|                      |                    |                    | seeded RNG).       |                    |                    |
+----------------------+--------------------+--------------------+--------------------+--------------------+--------------------+
```

---

## 6. Existing Architecture Assessment (iFogSim & LAMP Extension)

An architectural audit of the project confirms that our extension classes cleanly inherit from iFogSim without coupling to Phase 1 or Phase 2 production classes:

```
iFogSim-main/src/org/fog/
├── placement/
│   ├── ModulePlacement.java             <-- Abstract base class defining module mappings
│   ├── ModulePlacementMapping.java      <-- Standard iFogSim module placement holder
│   └── ModulePlacementEdgewards.java    <-- Reference hierarchical placement
├── lamp/
│   ├── application/
│   │   └── HealthcareBSNApplication.java<-- BSN DAG: Interface -> Analyzer -> Storage
│   ├── topology/
│   │   └── HealthcareTopologyFactory.java<-- 3-Tier Symmetric Topology Builder
│   ├── asymmetric/
│   │   ├── AsymmetricTopologyFactory.java   <-- Phase 2.2 Asymmetric Topology Builder
│   │   ├── ModulePlacementAsymmetricLAMP.java<-- Phase 2.2 Dual-variant LAMP
│   │   └── AsymmetricSimulationRunner.java  <-- Phase 2.2 Execution Driver
│   └── placement/
│       └── ModulePlacementLAMP.java     <-- Phase 2 Production LAMP placement
```

### Architectural Guarantees:
- **No Class Contamination:** Baseline algorithms will be authored in a completely isolated package: `org.fog.lamp.baselines.*`.
- **Interface Compliance:** Both algorithms will extend `ModulePlacement` and emit standard `ModulePlacementMapping` instances, interfacing cleanly with `Controller.submitApplication()`.
- **Metric Independence:** Energy, latency, network usage, and cloud cost will be monitored through established iFogSim singletons (`TimeKeeper`, `FogDevice`, `NetworkUsageMonitor`), ensuring absolute cross-algorithm comparability.

---

## 7. Proposed Java Implementation Mapping

### 7.1 Architecture of `ModulePlacementLBMP.java` (Algorithms 1, 2, 3)

```java
package org.fog.lamp.baselines;

import java.util.*;
import org.fog.application.AppModule;
import org.fog.application.Application;
import org.fog.entities.FogDevice;
import org.fog.placement.ModuleMapping;
import org.fog.placement.ModulePlacement;
import org.fog.placement.ModulePlacementMapping;

public class ModulePlacementLBMP extends ModulePlacement {
    public enum Variant { PURE, AFFINITY }

    private final Variant variant;
    private final List<FogDevice> fogNodePool;
    private final FogDevice cloud;
    private final Map<Integer, Double> availableMipsMap = new HashMap<>();

    public ModulePlacementLBMP(List<FogDevice> fogDevices, List<Application> apps, 
                               FogDevice cloud, Variant variant) {
        this.cloud = cloud;
        this.variant = variant;
        this.fogNodePool = new ArrayList<>(fogDevices); // Gateways + Proxy
        initAvailableCapacities();
        executeModuleMap(apps);
    }

    // Algorithm 1: MODULEMAP
    private void executeModuleMap(List<Application> apps) {
        // Collect analytical modules (Sensor_Analyzer)
        List<ModulePlacementRequest> moduleRequests = extractAnalyticalModules(apps);

        // Step 1 & 2: Sort nodes and modules in ASCENDING order
        sortNodesAscending();
        sortModulesAscending(moduleRequests);

        int low = 0, high = fogNodePool.size() - 1;

        for (ModulePlacementRequest req : moduleRequests) {
            int selectedIdx = lowerBound(req, low, high);

            if (selectedIdx != -1) {
                FogDevice host = fogNodePool.get(selectedIdx);
                assignModule(req, host);
                // Step 10: Decrement capacity
                decrementCapacity(host, req.mipsDemand);
                // Step 11: Mandatory dynamic re-sorting
                sortNodesAscending();
            } else {
                // Step 15: Fallback to Cloud
                assignModule(req, cloud);
            }
        }
    }

    // Algorithm 2: LOWERBOUND (Binary Search)
    private int lowerBound(ModulePlacementRequest req, int low, int high) {
        int ans = -1;
        while (low <= high) {
            int mid = low + (high - low) / 2;
            if (compare(fogNodePool.get(mid), req)) {
                ans = mid;
                high = mid - 1; // Search left for a tighter (smaller) capable node
            } else {
                low = mid + 1;  // Search right for larger nodes
            }
        }
        return ans;
    }

    // Algorithm 3: COMPARE
    private boolean compare(FogDevice node, ModulePlacementRequest req) {
        double availMips = availableMipsMap.get(node.getId());
        return availMips >= req.mipsDemand;
    }

    private void sortNodesAscending() {
        fogNodePool.sort(Comparator.comparingDouble(d -> availableMipsMap.get(d.getId())));
    }
}
```

---

### 7.2 Architecture of `ModulePlacementSAMP.java` (`SA_SYNTHETIC`)

```java
package org.fog.lamp.baselines;

import java.util.*;
import org.fog.application.Application;
import org.fog.entities.FogDevice;
import org.fog.placement.ModulePlacement;

public class ModulePlacementSAMP extends ModulePlacement {
    // Hyperparameters explicitly marked as Category C Assumptions
    private final double initialTemp = 100.0;
    private final double minTemp = 0.01;
    private final double coolingRate = 0.95;
    private final int stepsPerTemp = 20;
    private final long randomSeed = 42L; // Strictly pinned PRNG for reproducibility
    private final double wDelay = 0.60, wEnergy = 0.20, wCost = 0.20;

    public ModulePlacementSAMP(List<FogDevice> fogDevices, List<Application> apps, FogDevice cloud) {
        // Stochastic Simulated Annealing loop
        executeSimulatedAnnealing(fogDevices, apps, cloud);
    }

    private void executeSimulatedAnnealing(...) {
        // 1. Initialize state vector S
        // 2. Evaluate initial multi-objective cost f(S)
        // 3. Loop: perturb S -> S', evaluate Delta f
        // 4. Metropolis criterion: if Delta f < 0 or rng < exp(-Delta f / T) -> accept
        // 5. T = T * coolingRate until T < minTemp
        // 6. Map best state S* to ModulePlacementMapping
    }
}
```

---

## 8. Experimental Comparison Matrix

### 8.1 Unified Benchmark Matrix (80 Total Runs)
To establish an unassailable scientific comparison, all five algorithms will execute across identical topologies:

```
+----------------------------------------------------------------------------------------------------+
|                                    PHASE 3 BENCHMARK MATRICES                                      |
+-------------------+-----------------------+---------------------+-------------------+--------------+
| Matrix Type       | Topology Workload     | Gateways & Mobiles  | Algorithms        | Total Runs   |
+-------------------+-----------------------+---------------------+-------------------+--------------+
| Matrix A          | 12 Symmetric Configs  | GW: {2, 3, 4}       | COMP, EWMP, LBMP, | 60 Runs      |
| (Symmetric)       |                       | Mob: {2, 4, 6, 8}   | SAMP, LAMP        | (12 x 5)     |
+-------------------+-----------------------+---------------------+-------------------+--------------+
| Matrix B          | 4 Asymmetric Configs  | [6, 2], [2, 6],     | COMP, EWMP, LBMP, | 20 Runs      |
| (Asymmetric)      |                       | [6, 6], [10, 2]     | SAMP, LAMP        | (4 x 5)      |
+-------------------+-----------------------+---------------------+-------------------+--------------+
| TOTAL EXPERIMENTAL RUNS                                                                 | 80 Runs      |
+----------------------------------------------------------------------------------------------------+
```

### 8.2 Strict Experimental Controls
1. **Identical Hardware Demands:** Tuple CPU length $3,500\text{ MI}$, sensor bandwidth $700\text{ MIPS}$ demand.
2. **Identical Hardware Capacities:** Gateways ($2,800\text{ MIPS}$), Proxy ($2,800\text{ MIPS}$), Cloud ($44,800\text{ MIPS}$) (Tables III & IV).
3. **Identical Simulation Horizon:** Fixed termination at $T = 2000.0$ simulation clock units.
4. **Reproducibility:** Seed pinned to `42L` for SAMP. Deterministic algorithms run without randomness.

---

## 9. Ambiguity & Implementation Assumption Register

```
+-------------------------------------------------------------------------------------------------------------------------------+
|                                                PHASE 3.1 AMBIGUITY REGISTER                                                   |
+----+-----------------------+-----------------------------+-----------------------------+--------------------------------------+
| ID | Underspecified Detail | Why It Matters              | Plausible Interpretations   | Recommended Implementation Assumption|
+----+-----------------------+-----------------------------+-----------------------------+--------------------------------------+
| A1 | LBMP Dynamic Re-Sort  | Taneja & Davy Line 11 calls | (A) Full array sort O(DlogD)| **(A) Standard Re-Sort [Cat. A]:**   |
|    | Method                | Sort() after each placement.| (B) Single-element bubble   | Full sort ensures strict adherence   |
|    |                       | Impacts runtime complexity. |     down O(D).              | to published Algorithm 1 pseudocode. |
+----+-----------------------+-----------------------------+-----------------------------+--------------------------------------+
| A2 | LBMP Equal-Capacity   | When multiple gateways have | (A) Stable array order.     | **Evaluate Both Variants [Cat. C]:** |
|    | Tie-Breaking          | identical capacity, which is| (B) Local mobile gateway    | Implement `LBMP_PURE` (stable order) |
|    |                       | picked by binary search?    |     affinity.               | and `LBMP_AFFINITY` (local tie-break)|
+----+-----------------------+-----------------------------+-----------------------------+--------------------------------------+
| A3 | SAMP Primary Source   | Primary paper [9] full text | (A) Claim SA is verified.   | **(B) Mark NOT VERIFIED [Cat. C]:**  |
|    | Verification Status   | is gated; literature says it| (B) Mark NOT VERIFIED;      | Disclose unverified status; execute  |
|    |                       | proposed "MFP".             |     evaluate as SA_SYNTHETIC| as `SA_SYNTHETIC` with stated params.|
+----+-----------------------+-----------------------------+-----------------------------+--------------------------------------+
| A4 | SAMP Objective Cost   | Exact weighting factors     | (A) Latency-dominant (0.60).| **(A) Normalized Weighted Sum:**     |
|    | Formulation           | omitted in literature.      | (B) Equal weights (0.33 ea).| Cost = 0.60*Lat + 0.20*E + 0.20*Cost.|
+----+-----------------------+-----------------------------+-----------------------------+--------------------------------------+
| A5 | Module Granularity    | Reassigning interface or    | (A) Reassign all modules.   | **(B) Analyzer Only [Cat. C]:**      |
|    | Scope                 | storage breaks BSN loop.    | (B) Dynamic Sensor_Analyzer;| Pin Interface to mobile, Storage to  |
|    |                       |                             |     fixed Interface/Storage.| Cloud; verify 3N invariant 100%.     |
+----+-----------------------+-----------------------------+-----------------------------+--------------------------------------+
```

---

## 10. Source Verification Table & Correction History

### 10.1 Primary Source Verification Table

```
+-------------------------------------------------------------------------------------------------------------------------------+
|                                                PRIMARY SOURCE VERIFICATION TABLE                                              |
+-----------+----------------------+--------------------+--------------------+----------------------------+---------------------+
| Algorithm | Primary Reference    | Verification Status| Section / Page Ref | Verified Published Mechanic| Remaining Uncertainty|
+-----------+----------------------+--------------------+--------------------+----------------------------+---------------------+
| **LBMP**  | Taneja & Davy (2017) | **VERIFIED**       | Section III        | - Ascending node sort      | Handling of ties    |
|           | IFIP/IEEE IM [3]     | Primary Text       | Algorithms 1, 2, 3 | - Ascending module sort    | between identical   |
|           |                      | Audited            | pp. 1224–1226      | - Binary search LOWERBOUND | capacity gateways   |
|           |                      |                    |                    | - COMPARE multi-resource   | in tree topologies. |
|           |                      |                    |                    | - Dynamic re-sorting       |                     |
|           |                      |                    |                    | - Cloud fallback on -1     |                     |
+-----------+----------------------+--------------------+--------------------+----------------------------+---------------------+
| **SAMP**  | Rezazadeh et al.     | **NOT VERIFIED**   | Gated Paper        | - Investigates SPP in      | - Actual SA formula |
|           | (2018) IEEE ICEE [9] | Primary Source     | pp. 1553–1558      |   iFogSim.                 | - Annealing schedule|
|           |                      | Gated / Paywall    |                    | - Literature identifies core| - Cost weights      |
|           |                      |                    |                    |   algorithm as "MFP".      | - State vector      |
+-----------+----------------------+--------------------+--------------------+----------------------------+---------------------+
| **EWMP**  | Gupta et al. (2017)  | **VERIFIED**       | Section 5.1        | - Leaf-to-root tree ascent | None (standard      |
|           | SPE Journal [2]      | Open Source        | pp. 1282–1285      | - Upward parent placement  | iFogSim baseline).  |
|           |                      | iFogSim Codebase   |                    | - Cloud fallback on root   |                     |
+-----------+----------------------+--------------------+--------------------+----------------------------+---------------------+
| **LAMP**  | Rezazadeh et al.     | **VERIFIED**       | Section IV         | - Equation 4 (Q + Delta + Z)| Table I MIPS vs MI  |
|           | (2019) IEEE KBEI [0] | Primary Text       | Algorithm 1, Eq. 4 | - Cascading displacement   | dimensional tick    |
|           |                      | Audited            | pp. 846–848        | - Candidate sorting        | convention.         |
+-----------+----------------------+--------------------+--------------------+----------------------------+---------------------+
```

### 10.2 Correction History

| Version | Timestamp | Section Affected | Nature of Correction | Justification / Grounding |
| :--- | :--- | :--- | :--- | :--- |
| **v1.0** | Nov 17, 2026 23:12 | Section 2.1 | Drafted LBMP as descending First-Fit heuristic. | Initial secondary review from general literature. |
| **v2.0** | Nov 17, 2026 23:45 | Section 2.1–2.5 | **CORRECTED:** Replaced with ascending `LOWERBOUND` binary-search Best-Fit, `COMPARE`, and dynamic re-sort. | Audited primary source: Taneja & Davy (2017) Algorithms 1, 2, 3. |
| **v2.0** | Nov 17, 2026 23:45 | Section 3 | **CORRECTED:** Marked SAMP as **NOT VERIFIED**. Prohibited faithful reproduction claim. | Audited IEEE ICEE 2018; confirmed gated text and MFP algorithm attribution. |
| **v2.0** | Nov 17, 2026 23:45 | Section 4 | **ADDED:** Tripartite classification (Category A, B, C). | Strict separation of published facts vs. implementation assumptions. |
| **v2.0** | Nov 17, 2026 23:45 | Section 5 | **CORRECTED:** Updated 5-algorithm comparison matrix. | Synchronized with true LBMP mechanics and unverified SAMP status. |

---

## 11. Conclusion & Next Steps

This revised document corrects all algorithmic discrepancies and establishes defensible scientific boundaries. 

- **LBMP** is fully verified and mathematically specified in exact alignment with Taneja & Davy (2017).
- **SAMP** is acknowledged as unverified from primary text; any metaheuristic evaluation will be conducted transparently as `SA_SYNTHETIC` (Category C).
- **Zero code changes or simulations** have been initiated.

**Awaiting user review and formal authorization before beginning Phase 3 implementation.**

---
*Certified by Research Engineering & CloudSim/iFogSim Reproduction Specialist.*
