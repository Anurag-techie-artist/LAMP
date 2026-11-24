# PHASE 3.2: IMPLEMENTATION-READINESS AUDIT (LBMP & SAMP)
**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 18, 2026  
**Status:** AUDIT COMPLETE — AWAITING USER REVIEW & APPROVAL  
**Governance:** Strict Research & Engineering Audit ONLY (Zero Java Modifications, Zero Simulations, Zero Changes to Phase 1/2/2.2/3.1 Files)  
**Primary Literature Audited:**  
- **LAMP (2019):** Z. Rezazadeh, M. Rezaei, M. Nickray, *"LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications"*, 5th KBEI, Tehran, Iran, pp. 845–850, 2019 *(Local PDF Audited)*.  
- **LBMP (2017):** M. Taneja & A. Davy, *"Resource Aware Placement of IoT Application Modules in Fog-Cloud Computing Paradigm"*, IFIP/IEEE IM, pp. 1222–1228, 2017 *(Secondary Excerpts Audited; Verbatim Local PDF Unavailable)*.  
- **SAMP (2018):** Z. Rezazadeh, D. Rahbari, M. Nickray, *"Optimized Module Placement in IoT Applications Based on Fog Computing"*, 26th IEEE ICEE, pp. 1553–1558, 2018, DOI: `10.1109/ICEE.2018.8472469` *(Paywalled / Unavailable — UNVERIFIED)*.  
**Codebase Audited (Read-Only):**  
- [HealthcareBSNApplication.java](iFogSim-main/src/org/fog/lamp/application/HealthcareBSNApplication.java)  
- [HealthcareTopologyFactory.java](iFogSim-main/src/org/fog/lamp/topology/HealthcareTopologyFactory.java)  
- [Application.java](iFogSim-main/src/org/fog/application/Application.java)  
- [ModulePlacementAsymmetricLAMP.java](iFogSim-main/src/org/fog/lamp/asymmetric/ModulePlacementAsymmetricLAMP.java)  

---

## 1. Task 1 — Verification of LBMP's `LOWERBOUND` Algorithm & Dynamic Re-Sorting Interaction

### 1.1 What the Source Excerpts Specify
Reproduced pseudocode excerpts of Taneja & Davy (2017, Section III, Algorithm 1 `MODULEMAP`) present the following control flow:

```text
Sort(nodes[]), Sort(modules[]) in ascending order
int low = 0, high = nodes.size - 1
for start = 0 to modules.size - 1 do
    int i = LOWERBOUND(nodes[], modules[start], low, high)
    if (i != -1) then
        moduleMap.insert(nodes[i], modules[start])
        Cap(nodes[i]) = Cap(nodes[i]) - Req(modules[start])
        Sort(nodes[]) in ascending order
        low = i + 1          // <--- CRITICAL AUDIT TARGET
    else
        moduleMap.insert(nodes[nodes.size - 1], modules[start])
    end if
end for
```

*Source Verification Caveat:* Because the verbatim PDF of Taneja & Davy (2017) is not stored locally, secondary academic reproductions confirm `Sort(nodes[])` ascending, `LOWERBOUND(nodes[], modules[start], low, high)`, capacity subtraction, and dynamic re-sorting, and several reproductions explicitly print `low = i + 1` on the line following `Sort(nodes[])`. Whether `low = i + 1` is a literal printed line in the original IM 2017 proceedings or a transcription artifact is **PARTIALLY VERIFIED**.

### 1.2 Mathematical Proof of Inconsistency Between `low = i + 1` and Dynamic Re-Sorting
Advancing `low = i + 1` immediately after subtracting capacity and re-sorting `nodes[]` ascending is **mathematically unsound for multi-module hosting** for two independent reasons:

1. **Index Invalidation After Re-Sorting:**  
   When `Cap(nodes[i])` decreases and `nodes[]` is re-sorted in ascending order, the modified node moves **left** to some new index $k \le i$. Every node originally at indices $[k, i - 1]$ shifts **right** by one slot into $[k + 1, i]$. Therefore, the old index `i` no longer refers to the same physical node, and `low = i + 1` skips over nodes whose capacities were never exhausted.
2. **Catastrophic Premature Fog Abandonment (Worked Counterexample on Our BSN Topology):**  
   Consider a 2-gateway topology with 3 Fog nodes: `nodes[] = [d-0(2800), d-1(2800), proxy(2800)]` (`high = 2`), and 12 identical `Sensor_Analyzer` modules demanding `700 MIPS` each (total Fog capacity = `8400 MIPS` = 12 slots):
   - **Module 0:** `low = 0, high = 2` $\rightarrow$ `LOWERBOUND` returns `i = 0` (`d-0`). Capacity updated: `d-0` becomes `2100`. Re-sorted: `[d-0(2100), d-1(2800), proxy(2800)]`. Setting `low = i + 1` sets **`low = 1`** $\rightarrow$ `d-0` (with 3 free slots remaining!) is **permanently excluded**.
   - **Module 1:** `low = 1, high = 2` $\rightarrow$ returns `i = 1` (`d-1`). Updated & re-sorted: `[d-0(2100), d-1(2100), proxy(2800)]`. Setting `low = i + 1` sets **`low = 2`** $\rightarrow$ both `d-0` and `d-1` are permanently excluded.
   - **Module 2:** `low = 2, high = 2` $\rightarrow$ returns `i = 2` (`proxy`). Updated & re-sorted: `[d-0(2100), d-1(2100), proxy(2100)]`. Setting `low = i + 1` sets **`low = 3 > high`**.
   - **Modules 3–11:** `low > high` $\rightarrow$ `LOWERBOUND` returns `-1` for all 9 remaining modules, sending 75% of the workload to the Cloud while **75% of Fog capacity (`6300 / 8400 MIPS`) sits idle**.

### 1.3 What `low = i + 1` Implies vs. Defensible Implementation Interpretation
- **What `low = i + 1` implies:** It only makes sense under a strict **one-module-per-node** constraint (where a node is retired after hosting a single module, making capacity subtraction and re-sorting redundant). It directly contradicts multi-module bin packing and LAMP Section V / Figure 8's statement that LBMP achieves a strong Fog-Cloud balance.
- **Defensible Implementation Decision (Category C — Explicitly NOT Attributed to Original Paper):**  
  Reset `low = 0` and `high = fogNodes.size() - 1` on every iteration after re-sorting `nodes[]`.  
  - *Rationale:* Because `nodes[]` is re-sorted ascending after every capacity update, index `0` holds the node with the smallest remaining capacity. Searching `[0 .. D-1]` enables multi-module consolidation (Best-Fit packing: filling `d-0` from `2800 -> 2100 -> 1400 -> 700 -> 0` before spilling to `d-1`), matching the core resource-packing goal of Taneja & Davy (2017).

---

## 2. Task 2 — Verification of Multi-Resource Eligibility & Validity of Binary Search

### 2.1 Resource Representation in Taneja & Davy (2017) vs. Our iFogSim Codebase
- **Original Paper (Verified Conceptually):**  
  Each infrastructure node $n \in N$ carries a 3-dimensional capacity vector $\text{Cap}(n) = \langle \text{CPU}_n, \text{RAM}_n, \text{BW}_n \rangle$, and each application module $m \in M$ carries a 3-dimensional demand vector $\text{Req}(m) = \langle \text{CPU}_m, \text{RAM}_m, \text{BW}_m \rangle$.
- **Independent Checking (`COMPARE`, Algorithm 3):**  
  All three resources are checked independently via logical conjunction:
  $$\text{COMPARE}(n, m) \equiv (\text{CPU}_n^{\text{avail}} \ge \text{CPU}_m) \;\land\; (\text{RAM}_n^{\text{avail}} \ge \text{RAM}_m) \;\land\; (\text{BW}_n^{\text{avail}} \ge \text{BW}_m)$$
- **Post-Placement Resource Updates:**  
  All three dimensions must be decremented atomically after placement:
  $$\text{CPU}_n^{\text{avail}} \leftarrow \text{CPU}_n^{\text{avail}} - \text{CPU}_m, \quad \text{RAM}_n^{\text{avail}} \leftarrow \text{RAM}_n^{\text{avail}} - \text{RAM}_m, \quad \text{BW}_n^{\text{avail}} \leftarrow \text{BW}_n^{\text{avail}} - \text{BW}_m$$
  *(Correction from Phase 3.1: The Phase 3.1 Java sketch checked and updated only MIPS. That omission is corrected in Task 6.)*

#### Exact Resource Values Audited in Our iFogSim Codebase
From [HealthcareTopologyFactory.java](iFogSim-main/src/org/fog/lamp/topology/HealthcareTopologyFactory.java#L54-L135), [HealthcareBSNApplication.java](iFogSim-main/src/org/fog/lamp/application/HealthcareBSNApplication.java#L73-L86), and [Application.java](iFogSim-main/src/org/fog/application/Application.java#L63-L73):

| Entity | CPU / MIPS | RAM (MB) | Host `bw` (`BwProvisioner`) | Link `upBw` / `downBw` | Bottleneck Status |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `cloud` (Level 0) | 44,800 | 40,000 | 1,000,000 | **100** / 10,000 | `upBw = 100` anomaly (see Task 3) |
| `proxy-server` (Level 1) | 2,800 | 4,000 | 1,000,000 | 10,000 / 10,000 | MIPS binds at 4 modules |
| `d-i` Gateways (Level 2) | 2,800 | 4,000 | 1,000,000 | 10,000 / 10,000 | MIPS binds at 4 modules |
| `m-i-j` Mobiles (Level 3) | 1,000 | 1,000 | 1,000,000 | 10,000 / **270** | Pinned to `Interface` only |
| `Sensor_Analyzer` Demand | **700.0** *(LAMP)* | **10** *(Line 74)* | **1,000** *(`AppModule` default)* | **500 B/s** *(edge sum / 5s)* | MIPS = 25% of GW; RAM = 0.25%; BW = 10% (`upBw`) or 0.1% (`host.bw`) |

*Bandwidth Representation Implementation Decision (Category C):* iFogSim exposes two distinct bandwidth fields on a `FogDevice`: `host.getBw()` (`1,000,000`, provisioned per `Vm`/`AppModule` with default `bw = 1,000`) and network link bandwidth `min(upBw, downBw)` (`10,000` for Fog Gateways and Proxy). Both must be tracked consistently; in Task 6 we recommend using `min(upBw, downBw)` (`10,000`) against `AppModule.getBw()` (`1,000`, allowing up to 10 modules on BW before MIPS binds at 4) OR `host.getBw()` (`1,000,000`), and explicitly logging all three remaining resource dimensions on every placement.

### 2.2 Node Sorting Criterion in the Original Paper
- **Status:** **PARTIALLY VERIFIED / AMBIGUOUS.** Secondary summaries of Taneja & Davy (2017) state `Sort(nodes[])` in ascending order of capacity without publishing a formal total-order comparator over $\mathbb{R}^3$ ($\langle \text{CPU}, \text{RAM}, \text{BW} \rangle$). Because $\mathbb{R}^3$ admits only a partial order under component-wise dominance ($\le$), any sorting algorithm requires either:
  1. Single-resource key (CPU ascending),
  2. Lexicographical tuple key `(CPU ASC, RAM ASC, BW ASC)`, or
  3. A scalarized composite index (e.g., weighted sum of normalized CPU, RAM, BW).

### 2.3 Mathematical Proof: Binary Search Invalidity Under General Multi-Resource Eligibility
**Precondition for Binary Search (`LOWERBOUND`):**  
Binary search over sorted array `nodes[0 .. D-1]` is mathematically valid **if and only if** the boolean eligibility predicate $P(k) = \text{COMPARE}(\text{nodes}[k], m)$ is **monotonically non-decreasing** in $k$:
$$\forall j, k \in \{0, \dots, D-1\}: \quad j < k \land P(j) = \text{TRUE} \implies P(k) = \text{TRUE}$$

**Proof of Failure in General Heterogeneous Networks (Counterexample):**  
Suppose nodes are sorted ascending by CPU (or lexicographically `(CPU, RAM, BW)`), and module $m$ requires $\langle \text{CPU}=500, \text{RAM}=2000, \text{BW}=500 \rangle$:
- `nodes[0]` = $\langle 1000, 4000, 1000 \rangle \implies \text{COMPARE} = \mathbf{TRUE}$
- `nodes[1]` = $\langle 2000, 1000, 1000 \rangle \implies \text{COMPARE} = \mathbf{FALSE}$ *(RAM fails)*
- `nodes[2]` = $\langle 3000, 1000, 1000 \rangle \implies \text{COMPARE} = \mathbf{FALSE}$ *(RAM fails)*

The predicate vector is `[TRUE, FALSE, FALSE]`, which is **non-monotonic**. Executing `LOWERBOUND(nodes, m, 0, 2)`:
1. `mid = 1`: `COMPARE(nodes[1], m)` is `FALSE` $\implies$ binary search sets `low = mid + 1 = 2`, discarding `nodes[0]`.
2. `mid = 2`: `COMPARE(nodes[2], m)` is `FALSE` $\implies$ `low = 3 > high`.
3. **Result:** Binary search returns **`-1` (false Cloud fallback)** even though `nodes[0]` was completely eligible! Even if `nodes[2]` were eligible (`[TRUE, FALSE, TRUE]`), binary search would select `nodes[2]` and miss the true tightest lower bound `nodes[0]`.

**Special-Case Verification for Our Healthcare BSN Fog Pool:**  
In our specific Healthcare BSN topology, **if and only if** the candidate pool is restricted to Fog Gateways (`d-0 .. d-(G-1)`) and `proxy-server` (all starting at $\langle 2800, 4000, 10000 \rangle$) and all dynamic modules are identical `Sensor_Analyzer` instances ($\langle 700, 10, 1000 \rangle$), then after hosting $k$ modules every node's remaining resources satisfy:
$$\text{CPU}(k) = 2800 - 700k, \quad \text{RAM}(k) = 4000 - 10k, \quad \text{BW}(k) = 10000 - 1000k$$
Because all three dimensions decrease strictly linearly with $k$, the three coordinates are **strictly comonotonic**:
$$\text{CPU}(k_1) \le \text{CPU}(k_2) \iff \text{RAM}(k_1) \le \text{RAM}(k_2) \iff \text{BW}(k_1) \le \text{BW}(k_2)$$
Therefore, **within our homogeneous Fog pool only**, binary search is provably valid. However, if any heterogeneous node (such as `mobiles` with `downBw = 270` or `cloud` with `upBw = 100`) enters the sorted array, comonotonicity breaks and binary search becomes mathematically invalid.

**Engineering Consequence:** Our design in Task 6 retains the published `LOWERBOUND` binary search **guarded by an explicit runtime comonotonicity assertion**, paired with a clearly labeled **Multi-Resource Exact Ascending Scan** (`lowerBoundLinearScan`, $O(D)$) that is provably identical to `LOWERBOUND` whenever monotonicity holds and strictly exact whenever it does not.

---

## 3. Task 3 — Candidate Node Scope Definition

### 3.1 Tier-by-Tier Classification in Our LAMP Healthcare Topology

| Topology Tier | Devices | Included in LBMP Search Array? | Evidentiary Classification | Justification |
| :--- | :--- | :---: | :---: | :--- |
| **Tier 3: Mobile End Devices** | `m-i-j` | **NO** | Topology Adaptation (**Category C**) | Hosts pinned `Interface_i_j` (client module). In LAMP BSN, personal mobile devices do not host other patients' `Sensor_Analyzer` modules; `downBw = 270` would also violate BW comonotonicity. |
| **Tier 2: Fog Gateways** | `d-0 .. d-(G-1)` | **YES** | Published Core (**Category A**) | Primary Fog computational nodes (`2,800 MIPS`, `4,000 MB RAM`, `10,000 BW`). |
| **Tier 1: Proxy Server** | `proxy-server` | **YES** | Topology Adaptation aligned with Paper (**Category A/C**) | Intermediate Fog node (`2,800 MIPS`, `4,000 MB RAM`, `10,000 BW`) belonging to the Fog layer between Gateways and Cloud. |
| **Tier 0: Cloud Data Center** | `cloud` | **NO (Explicit Fallback Sink)** | Implementation Decision (**Category C**) | See Section 3.2 below. |

### 3.2 Clarification of Cloud's Role
- **What Taneja & Davy (2017) excerpts indicate (PARTIALLY VERIFIED):**  
  Algorithm 1's `else` clause (`if i == -1`) inserts the unplaced module into `nodes[nodes.size - 1]`. This implies Cloud resides at the top end of the node list as the fallback target when Fog nodes fail `LOWERBOUND`.
- **Why Cloud MUST Be an Explicit Fallback Sink (Not Inside the Sorted Multi-Resource Pool) in Our Topology:**  
  In LAMP Table IV / [HealthcareTopologyFactory.java](iFogSim-main/src/org/fog/lamp/topology/HealthcareTopologyFactory.java#L55), `cloud` is configured with `upBw = 100` (while Fog gateways have `upBw = 10,000`). If `cloud` were checked by `COMPARE` using `upBw >= 1000`, `COMPARE(cloud, module)` would evaluate to `FALSE`, causing failure to offload! Excluding `cloud` from the Fog search pool and invoking it unconditionally when search returns `-1` matches LAMP's Section III unlimited-Cloud model and Taneja & Davy's fallback intent.

### 3.3 Strict Separation of `LBMP_PURE` vs. `LBMP_AFFINITY`
- **`LBMP_PURE` (Primary Baseline — Closest Defensible Reproduction of Taneja & Davy 2017):**  
  - Candidate pool = `{d-0, ..., d-(G-1), proxy-server}` sorted ascending by remaining resources; `cloud` is fallback only.
  - **Zero** locality, gateway affinity, or latency logic is permitted inside `LBMP_PURE`.
  - Consequence: Packs Fog nodes to capacity in pure sorted best-fit order (filling one node to 4/4 before opening the next), matching LAMP Section II's description (*"they focus more on reducing the use of resources... and the delay is not taken"*).
- **`LBMP_AFFINITY` (Optional Experimental Variant — Strictly Category C Adaptation):**  
  - Identical ascending resource sorting and `COMPARE` checks, EXCEPT when multiple eligible Fog nodes tie for the exact same minimum `(availableMips, availableRam, availableBw)`, the tie is broken in favor of the application's local parent gateway (`m-i-j -> d-i`).
  - Never mixed into `LBMP_PURE`; logged and reported under its own distinct algorithm label.

---

## 4. Task 4 — Deterministic Tie-Handling Policy

### 4.1 Why Tie Handling Is Critical Here (and Why "Stable Sort" Alone Is Insufficient)
- **What Taneja & Davy (2017) explicitly state:** **UNVERIFIED / UNSPECIFIED.** The paper does not specify tie-breaking rules for equal-capacity nodes or equal-requirement modules.
- **Why this matters in our Healthcare BSN topology:**  
  At $t = 0$, **100% of analytical modules** (`Sensor_Analyzer_i_j`) have identical requirements ($\langle 700, 10, 1000 \rangle$) and **100% of Fog nodes** (`d-0 .. d-(G-1)` and `proxy-server`) have identical capacities ($\langle 2800, 4000, 10000 \rangle$). Relying on "stable sort" alone leaves placement completely dependent on arbitrary input list construction order (e.g., `[proxy-server, d-0, d-1]` would pack `proxy-server` first, whereas `[d-0, d-1, proxy-server]` packs `d-0` first, producing materially different loop delays!).

### 4.2 Explicit Deterministic Implementation Policy (Category C — Implementation Decision)
Every sort uses an explicit total-order `Comparator` (never relying on implicit input insertion order):

1. **Module Sorting Total Order (Ascending):**
   $$\text{Key}_{\text{module}}(m) = (\text{mipsDemand ASC},\; \text{ramDemand ASC},\; \text{bwDemand ASC},\; \text{gatewayIdx ASC},\; \text{mobileIdx ASC})$$
   - For our homogeneous BSN workload, this deterministically orders modules as `app_0_0, app_0_1, ..., app_0_(M-1), app_1_0, ...`, matching Phase 2's canonical `FORWARD` sequence.
2. **Node Sorting Total Order — `LBMP_PURE` (Ascending):**
   $$\text{Key}_{\text{node}}(n) = (\text{availableMips ASC},\; \text{availableRam ASC},\; \text{availableBw ASC},\; \text{canonicalName ASC})$$
   - Canonical names: `"d-0" < "d-1" < ... < "d-(G-1)" < "proxy-server"`.
   - **Behavior After Capacity Change:** Once `"d-0"` receives module 0, its remaining capacity drops to `(2100, 3990, 9000)`. Ascending re-sort places `"d-0"` uniquely at index `0` (`2100 < 2800`). With `low = 0`, modules 1, 2, and 3 also select `"d-0"` until it reaches `(0, 3960, 6000)`, at which point `"d-0"` remains at index `0` (ineligible) and index `1` (`"d-1"`, at `2800`) becomes the next tightest lower bound.
3. **Node Selection Tie-Breaker — `LBMP_AFFINITY` (Optional Category C Variant):**
   - Nodes are still sorted by $\text{Key}_{\text{node}}(n)$ ascending.
   - After finding the first eligible index `idx` (with resource tuple $R^* = \text{Cap}(\text{nodes}[idx])$), scan the contiguous equal-capacity block $\{j \ge idx : \text{Cap}(\text{nodes}[j]) = R^*\}$; if the module's local gateway `d-i` is in that tied block, select it; otherwise select `nodes[idx]`.

---

## 5. Task 5 — SAMP Evidence Qualification

To maintain strict scientific honesty, evidence regarding SAMP is partitioned into four non-overlapping categories:

### Category A — What the LAMP 2019 Paper Explicitly Says About SAMP
- **Section I (p. 845):** Lists *"Simulated-Annealing Module Placement (SAMP) in [ 9]"* as one of four baseline algorithms evaluated in iFogSim.
- **Section V (p. 848):** Repeats *"Simulated-Annealing Module Placement (SAMP) in [9]"* as a comparison baseline across loop delay, cloud energy, fog energy, cloud cost, and network usage.
- **Figures 3–8 (pp. 848–849):** Displays empirical bar/line series labeled `SAMP`.
- **References (p. 850):** Cites `[9] Z. Rezazadeh, D. Rahbari, and M. Nickray. "Optimized Module Placement in IoT Applications Based on Fog Computing". In Electrical Engineering (ICEE), Iranian Conference on. IEEE. pp. 1553-1558, 2018.`
- **Explicit Omissions in LAMP 2019:** Zero mention of SAMP in Section II (Related Work); zero equations, zero pseudocode, zero cooling parameters, and zero objective function weights.

### Category B — What the Cited 2018 Paper (Rezazadeh et al.) Can Be Verified to Describe
- Verified bibliographic record (`DOI: 10.1109/ICEE.2018.8472469`): Authors Zahra Rezazadeh, Dadmehr Rahbari, and Mohsen Nickray; published at the 26th Iranian Conference on Electrical Engineering (ICEE 2018), pp. 1553–1558.
- Verified topic: Application module placement in Fog-Cloud IoT environments evaluated using iFogSim.
- **No algorithmic mechanics can be verified directly from the primary text** because the paper is behind an IEEE Xplore paywall and unavailable in our local workspace.

### Category C — What Secondary Literature Reports About MFP or Other Methods
- Secondary publication summaries (ResearchGate / web index abstracts referencing Rezazadeh et al. 2018) describe a multi-zone fog layer architecture and an exploratory algorithm named **MFP (Maximal Module Placement)** claiming ~16.81% latency reduction and ~17.75% energy reduction.
- Other secondary web summaries associate the paper with Simulated Annealing only via back-references from the 2019 LAMP paper.
- Because secondary summaries conflict (`MFP` vs. `SAMP`) and lack mathematical definitions, they are **inadmissible as primary implementation specifications**.

### Category D — What Remains UNVERIFIED (Primary Paper Unavailable)
1. Whether Rezazadeh et al. (2018) actually uses Simulated Annealing at all (versus MFP or a hybrid).
2. Exact optimization objective function and metric weights.
3. Solution/state representation.
4. Initial solution construction.
5. Neighborhood move / perturbation operators.
6. Acceptance criterion (Metropolis / Boltzmann or other).
7. Cooling schedule ($T_0, \alpha, T_{\min}$, iterations per temperature) and termination rule.
8. Constraint handling (hard filtering vs. penalty terms) and Cloud offloading behavior.

### Governance Ruling for SAMP
- **SAMP is formally classified as `UNVERIFIED`.**
- Simulated Annealing MUST NOT be described as the verified original SAMP algorithm.
- Faithful historical reproduction of SAMP is **NOT AUTHORIZED**.
- If a Simulated Annealing comparator is later authorized for comparative benchmarking, it MUST be named **`SA_SYNTHETIC`** and documented strictly as a **synthetic metaheuristic comparison baseline (Category C)**, never as a historical reproduction of `[9]`.

---

## 6. Task 6 — Corrected Java Design (Pseudocode Only)

The following design strictly satisfies Tasks 1–5 with zero contradictions. It explicitly models all three resources (CPU/MIPS, RAM, BW), implements deterministic total-order comparators, separates `LBMP_PURE` and `LBMP_AFFINITY`, guards `LOWERBOUND` against multi-resource non-monotonicity, and provides the clearly labeled exact ascending scan alternative.

```java
// ============================================================================
// DESIGN PSEUDOCODE ONLY — NOT FOR COMPILATION / NO PROJECT FILES MODIFIED
// Package (future): org.fog.lamp.baselines
// ============================================================================

// 1. MULTI-RESOURCE REPRESENTATION (Category A concept; Category C iFogSim BW mapping)
class ResourceVector {
    double mips;   // CPU capacity or demand (MIPS)
    int    ram;    // Memory capacity or demand (MB)
    long   bw;     // Bandwidth capacity or demand
                   //   Implementation Decision (Cat. C):
                   //   Device BW = min(device.getUplinkBandwidth(), device.getDownlinkBandwidth())
                   //               (10,000 for Gateways & Proxy)
                   //   Module BW = appModule.getBw() (1,000 default in iFogSim Application.java)
}

class NodeState {
    FogDevice      device;
    String         canonicalName; // e.g., "d-0", "d-1", "proxy-server"
    ResourceVector available;     // Decremented across ALL 3 dimensions after each placement
}

class ModuleRequest {
    String         appId;
    String         moduleName;    // "Sensor_Analyzer_i_j"
    int            gatewayIdx;    // i (originating mobile's local gateway index)
    int            mobileIdx;     // j (originating mobile index)
    String         localGwName;   // "d-" + i (used ONLY by LBMP_AFFINITY)
    ResourceVector required;      // <700.0 MIPS, 10 MB RAM, 1000 BW>
}

// 2. MULTI-RESOURCE ELIGIBILITY CHECK — Algorithm 3: COMPARE (Category A)
boolean compare(NodeState node, ModuleRequest mod) {
    return node.available.mips >= mod.required.mips
        && node.available.ram  >= mod.required.ram
        && node.available.bw   >= mod.required.bw;
}

// 3. ATOMIC MULTI-RESOURCE RESERVATION / UPDATE (Category A)
void reserveResources(NodeState node, ModuleRequest mod) {
    node.available.mips -= mod.required.mips;
    node.available.ram  -= mod.required.ram;
    node.available.bw   -= mod.required.bw;
}

// 4. DETERMINISTIC NODE COMPARATOR — Total Order Ascending (Category A sort + Category C tie-break)
Comparator<NodeState> NODE_ASC_COMPARATOR =
    Comparator.comparingDouble((NodeState n) -> n.available.mips)
              .thenComparingInt(n -> n.available.ram)
              .thenComparingLong(n -> n.available.bw)
              .thenComparing(n -> n.canonicalName);

// 5. DETERMINISTIC MODULE COMPARATOR — Total Order Ascending (Category A sort + Category C tie-break)
Comparator<ModuleRequest> MODULE_ASC_COMPARATOR =
    Comparator.comparingDouble((ModuleRequest m) -> m.required.mips)
              .thenComparingInt(m -> m.required.ram)
              .thenComparingLong(m -> m.required.bw)
              .thenComparingInt(m -> m.gatewayIdx)
              .thenComparingInt(m -> m.mobileIdx);

// 6A. PUBLISHED LOWERBOUND BINARY SEARCH — Algorithm 2 (Category A)
//     PRECONDITION: compare(nodes[k], mod) MUST be monotonic over k in [low..high].
int lowerBoundBinarySearch(List<NodeState> fogNodes, ModuleRequest mod, int low, int high) {
    int ans = -1;
    while (low <= high) {
        int mid = low + (high - low) / 2;
        if (compare(fogNodes.get(mid), mod)) {
            ans = mid;       // Eligible; search left for tighter (smaller) lower bound
            high = mid - 1;
        } else {
            low = mid + 1;   // Ineligible; search right for larger capacity node
        }
    }
    return ans;
}

// 6B. RUNTIME MONOTONICITY VERIFIER (Engineering Guard — Task 2)
boolean isEligibilityMonotonic(List<NodeState> fogNodes, ModuleRequest mod) {
    boolean seenEligible = false;
    for (NodeState node : fogNodes) {
        boolean eligible = compare(node, mod);
        if (seenEligible && !eligible) {
            return false; // Predicate dropped TRUE -> FALSE: binary search is INVALID
        }
        if (eligible) seenEligible = true;
    }
    return true;
}

// 6C. CLEARLY LABELED MULTI-RESOURCE SAFE ALTERNATIVE (Category C Adaptation)
//     Differs from published binary search: O(D) linear ascending scan vs O(log D).
//     Mathematically identical to binary search whenever monotonicity holds, AND
//     provably exact (zero false -1 rejections) when 3D resources are non-monotonic.
int lowerBoundLinearScan(List<NodeState> fogNodes, ModuleRequest mod) {
    for (int k = 0; k < fogNodes.size(); k++) {
        if (compare(fogNodes.get(k), mod)) {
            return k; // First (tightest) eligible node in ascending sorted order
        }
    }
    return -1;
}

// 7 & 8. MAIN PLACEMENT ROUTINE — Algorithm 1: MODULEMAP with Strict Variant Separation
enum LbmpVariant { LBMP_PURE, LBMP_AFFINITY }
enum SearchMode  { BINARY_SEARCH_GUARDED, EXACT_LINEAR_SCAN }

Map<String, String> executeModuleMap(
        List<FogDevice> fogOnlyCandidates, // {d-0..d-(G-1), proxy-server}; NO mobiles, NO cloud
        FogDevice cloudFallback,           // Explicit unlimited Cloud fallback sink
        List<ModuleRequest> requests,      // Dynamic Sensor_Analyzer requests only
        LbmpVariant variant,
        SearchMode searchMode) {

    List<NodeState> fogNodes = initNodeStates(fogOnlyCandidates);
    List<ModuleRequest> sortedModules = new ArrayList<>(requests);

    // Initial ascending sorts (Algorithm 1, Lines 1-2)
    fogNodes.sort(NODE_ASC_COMPARATOR);
    sortedModules.sort(MODULE_ASC_COMPARATOR);

    Map<String, String> analyzerPlacement = new LinkedHashMap<>();

    for (ModuleRequest mod : sortedModules) {
        // Implementation Decision (Task 1): Reset low = 0 after every dynamic re-sort
        // to avoid the index-invalidation / premature Fog abandonment bug of `low = i + 1`.
        int low = 0;
        int high = fogNodes.size() - 1;

        int idx;
        if (searchMode == SearchMode.BINARY_SEARCH_GUARDED) {
            if (!isEligibilityMonotonic(fogNodes, mod)) {
                // Log monotonicity violation and safely fall back to exact linear scan
                logWarning("Non-monotonic 3D eligibility detected for " + mod.moduleName
                           + "; falling back from binary search to exact ascending scan.");
                idx = lowerBoundLinearScan(fogNodes, mod);
            } else {
                idx = lowerBoundBinarySearch(fogNodes, mod, low, high);
            }
        } else {
            idx = lowerBoundLinearScan(fogNodes, mod);
        }

        if (idx != -1) {
            // Optional Variant Handling (Strictly separated from LBMP_PURE)
            if (variant == LbmpVariant.LBMP_AFFINITY) {
                idx = applyLocalGatewayTieBreak(fogNodes, idx, mod.localGwName);
            }

            NodeState chosen = fogNodes.get(idx);
            analyzerPlacement.put(mod.moduleName, chosen.canonicalName);

            // Atomic 3-resource update + mandatory ascending re-sort (Algorithm 1, Lines 10-11)
            reserveResources(chosen, mod);
            fogNodes.sort(NODE_ASC_COMPARATOR);
        } else {
            // Explicit Cloud Fallback (Algorithm 1, Lines 13-15; Category C unconstrained sink)
            analyzerPlacement.put(mod.moduleName, cloudFallback.getName());
        }
    }

    // Fixed BSN modules anchored separately:
    //   Interface_i_j     -> m-i-j  (N placements)
    //   Cloud_Storage_i_j -> cloud  (N placements)
    //   Total System Modules = 3N (invariant verified on every run)
    return analyzerPlacement;
}

// Used ONLY when variant == LBMP_AFFINITY (Category C Experimental Adaptation)
int applyLocalGatewayTieBreak(List<NodeState> fogNodes, int firstEligibleIdx, String localGwName) {
    ResourceVector bestCap = fogNodes.get(firstEligibleIdx).available;
    for (int k = firstEligibleIdx; k < fogNodes.size(); k++) {
        ResourceVector cap = fogNodes.get(k).available;
        if (cap.mips != bestCap.mips || cap.ram != bestCap.ram || cap.bw != bestCap.bw) {
            break; // Exited equal-capacity tie block
        }
        if (fogNodes.get(k).canonicalName.equals(localGwName)) {
            return k;
        }
    }
    return firstEligibleIdx;
}
```

---

## 7. Unresolved Questions Requiring User Sign-Off Prior to Implementation

1. **LBMP Bandwidth Field Choice:** Should `NodeState.available.bw` track `min(device.getUplinkBandwidth(), device.getDownlinkBandwidth())` (`10,000` for Fog nodes vs. `1,000` `AppModule.getBw()`), OR `host.getBw()` (`1,000,000` vs. `1,000`), OR aggregate edge tuple throughput (`500` B/s)? *(Note: Under all three choices, CPU/MIPS remains the binding constraint at 4 modules per Fog node, so placement counts are identical on our homogeneous Fog pool, but explicit selection is needed for logging accuracy.)*
2. **LBMP Variant Scope:** Should Phase 3 execute `LBMP_PURE` alone, or both `LBMP_PURE` and `LBMP_AFFINITY` side-by-side?
3. **SAMP / `SA_SYNTHETIC` Scope Decision:** Because Rezazadeh et al. (2018) is **UNVERIFIED**, should Phase 3:
   - *(Option 1)* Omit SAMP entirely until the primary PDF is acquired and run a verified 4-algorithm study (`COMP`, `EWMP`, `LBMP_PURE`, `LAMP`), OR
   - *(Option 2)* Include a clearly labeled **`SA_SYNTHETIC`** baseline (Category C) alongside `COMP`, `EWMP`, `LBMP_PURE`, and `LAMP`?

---

## 8. Task 7 — Final Readiness Decision Table & Verdict

| Component | Literature verified? | Implementation ready? | Remaining issue |
| :--- | :---: | :---: | :--- |
| **Module sorting** | PARTIALLY VERIFIED | IMPLEMENTATION DECISION REQUIRED | Ascending sort confirmed in secondary excerpts of Taneja & Davy (2017); exact multi-resource comparator and tie-breaker for identical BSN analyzers are unspecified by the paper. |
| **Node sorting** | PARTIALLY VERIFIED | IMPLEMENTATION DECISION REQUIRED | Ascending sort + post-placement re-sort confirmed; exact 3D total-order sort key (CPU-only vs. lexicographical `(CPU, RAM, BW)`) is unspecified in excerpts. |
| **Resource comparison** | VERIFIED (3D check) / PARTIALLY VERIFIED (iFogSim map) | IMPLEMENTATION DECISION REQUIRED | Independent checking of CPU, RAM, and BW (`COMPARE`, Alg. 3) is confirmed; exact mapping of BW to iFogSim fields (`upBw`/`downBw` vs. `host.getBw()`) requires sign-off. |
| **Resource updates** | VERIFIED | VERIFIED | All 3 resources (MIPS, RAM, BW) must be decremented atomically after each placement; Phase 3.1 MIPS-only pseudocode defect is corrected. |
| **LOWERBOUND** | PARTIALLY VERIFIED | IMPLEMENTATION DECISION REQUIRED | (1) `low = i + 1` after re-sorting causes premature Fog abandonment; resetting `low = 0` is required for multi-module hosting. (2) Binary search is mathematically invalid under non-monotonic 3D eligibility; guarded binary search + exact ascending scan alternative defined. |
| **Cloud fallback** | PARTIALLY VERIFIED | IMPLEMENTATION DECISION REQUIRED | Excerpts map unplaced modules (`i == -1`) to `nodes[nodes.size - 1]`; separating Cloud from the Fog search pool is required because Cloud's `upBw = 100` in LAMP Table IV would fail `COMPARE`. |
| **Tie handling** | UNVERIFIED | IMPLEMENTATION DECISION REQUIRED | Paper specifies zero tie-breakers; because all BSN Fog nodes and analyzers start identical, explicit deterministic comparators (`LBMP_PURE` canonical order vs. optional `LBMP_AFFINITY`) must be approved. |
| **SAMP** | UNVERIFIED | UNVERIFIED | Primary source (Rezazadeh et al., IEEE ICEE 2018, DOI `10.1109/ICEE.2018.8472469`) is paywalled/unavailable; secondary summaries cite `MFP`. Cannot be implemented as a faithful reproduction; only permitted as clearly labeled `SA_SYNTHETIC` if approved. |

### Final Readiness Verdict

> [!IMPORTANT]
> ## **READY WITH DOCUMENTED ADAPTATIONS**
>
> **Scope of Verdict:**
> - **LBMP (`LBMP_PURE`, plus optional `LBMP_AFFINITY`):** **READY WITH DOCUMENTED ADAPTATIONS** — All mathematical hazards (`low = i + 1` index invalidation, 3D binary-search monotonicity, Cloud `upBw = 100` anomaly, and homogeneous tie-breaking) have been resolved with explicit, non-contradictory engineering designs awaiting user sign-off on Section 7.
> - **SAMP (Historical Reproduction of Rezazadeh et al. 2018 [9]):** **BLOCKED / UNVERIFIED** — Faithful historical reproduction is **NOT READY** without the primary IEEE ICEE 2018 PDF. Only a clearly designated synthetic comparator (**`SA_SYNTHETIC`**, Category C) may be implemented if explicitly authorized by the user.

---
*Audit completed strictly read-only. Zero project code, datasets, or prior phase artifacts were modified. Standing by for review and authorization.*
