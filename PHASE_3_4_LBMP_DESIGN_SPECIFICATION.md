# PHASE 3.4: FINAL `LBMP_PURE` DESIGN SPECIFICATION
**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 18, 2026  
**Status:** DESIGN SPECIFICATION COMPLETE — AWAITING EXPLICIT JAVA IMPLEMENTATION AUTHORIZATION  
**Execution Boundary:** Design-Only Task (Zero Java Files Modified, Zero Simulations Run, Zero Historical Files Altered)  

**Traceability References:**
- **Primary Target Paper (LAMP 2019):** Z. Rezazadeh, M. Rezaei, M. Nickray, *"LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications"*, IEEE KBEI 2019, pp. 845–850 ([A Hybrid Fog Cloud Latency Aware Module.pdf](A Hybrid Fog Cloud Latency Aware Module.pdf)).
- **Primary Baseline Paper (LBMP 2017):** M. Taneja & A. Davy, *"Resource Aware Placement of IoT Application Modules in Fog-Cloud Computing Paradigm"*, IFIP/IEEE IM 2017, pp. 1222–1228 ([Resource Aware Placement of IoT Application.pdf](Resource Aware Placement of IoT Application.pdf)).
- **Preceding Audits:** [PHASE_3_3_RESOURCE_AND_CLOUD_SEMANTICS_AUDIT.md](PHASE_3_3_RESOURCE_AND_CLOUD_SEMANTICS_AUDIT.md), [PHASE_3_3_1_PRIMARY_SOURCE_LBMP_REAUDIT.md](PHASE_3_3_1_PRIMARY_SOURCE_LBMP_REAUDIT.md).

---

## 1. Approved Decisions & Formal Erratum to Phase 3.3.1

### 1.1 Governing Decisions (Locked for Phase 3.4 / 3.5)

| Decision ID | Topic | Approved Specification | Classification |
| :---: | :--- | :--- | :---: |
| **D-3.4-01** | Baseline Variant | Implement **`LBMP_PURE` only** as the primary baseline. | Approved Scope |
| **D-3.4-02** | Deferred Variants | Defer `LBMP_AFFINITY`; exclude historical **SAMP** (unverified) and **`SA_SYNTHETIC`**. | Approved Scope |
| **D-3.4-03** | Bandwidth Model | **Option A:** Node BW = `Host.getBw()` (`1,000,000`), Module BW = `AppModule.getBw()` (`1,000`). **Explicitly classified as a CloudSim VM-layer bandwidth approximation, NOT an exact reproduction of Taneja & Davy's Mbps model.** | Documented Approximation |
| **D-3.4-04** | Search Lower Bound | Reset `low = 0` after every dynamic node re-sort. Documented as a **necessary multi-application adaptation** to Taneja & Davy's published `low = i + 1` (Alg. 1, Line 11, p. 1225). | Documented Adaptation |
| **D-3.4-05** | Cloud Candidate Scope | **Design C1:** `cloud` remains inside the candidate `nodes[]` array ($N = N_F \cup N_C$, Taneja & Davy Eqs. 2–6, p. 1224). | Primary-Source Faithful |
| **D-3.4-06** | Isolation | All new classes reside in isolated package `org.fog.lamp.baselines`. Zero edits to Phase 1, 2, or 2.2 code, CSVs, logs, or reports. | Project Governance |
| **D-3.4-07** | `Cloud_Storage` Pre-Reservation | Pre-reserve `10 MB` RAM and `1,000` Host BW units per fixed `Cloud_Storage_i_j` on `cloudState`; do **not** deduct `Cloud_Storage` CPU from the LBMP analytical placement budget. | Fixed-Module Accounting Convention |
| **D-3.4-08** | Cloud Fallback & VM Instantiation Safeguards | Keep normal Cloud selection and unconditional Cloud fallback strictly separate; always target explicit `cloudState` reference on fallback (never assume `nodes[size - 1]`); track actual CloudSim VM instantiation successes/failures separately from analytical fallback counts; retain runtime monotonicity guard + linear-scan fallback. | Implementation Safeguard |

### 1.2 Mandatory Mathematical Correction to Phase 3.3.1 §11.2 (Erratum)

> [!WARNING]
> **Erratum Recorded Against Phase 3.3.1 §11.2 (Do Not Repeat):**  
> Phase 3.3.1 §11.2 erroneously claimed that under Option A, Cloud strictly dominates every Fog node on all three resource dimensions after 32 module placements. That claim is **mathematically false** on the BW dimension:
> - Untouched Fog node Host BW = `1,000,000`.
> - Saturated Fog node Host BW (after 4 placements) = `1,000,000 - 4 * 1,000 = 996,000`.
> - Cloud Host BW after 12 overflow placements (in `4 GW x 8 mobiles`) = `1,000,000 - 12 * 1,000 = 988,000 < 996,000` (and after 32 hypothetical placements = `968,000 < 1,000,000`; or with 32 pre-reserved `Cloud_Storage` modules + 12 analyzers = `956,000 < 996,000`).
>
> **Therefore, Cloud does NOT strictly dominate Fog nodes in BW.** Earlier Phase 3.3.1 report files are preserved unmodified per governance rules; this erratum formally supersedes §11.2's dominance claim.

### 1.3 Rigorous Proof of Eligibility Monotonicity (Strictly Restricted to Planned Benchmarks)

Let the planned benchmark suite consist of:
- **12 Symmetric Topologies:** $G \in \{2, 3, 4\}$ Gateways, $M \in \{2, 4, 6, 8\}$ Mobiles/GW $\implies N = G \cdot M \in [4, 32]$, $|N_F| = G + 1 \in \{3, 4, 5\}$, $|N| = G + 2 \in \{4, 5, 6\}$.
- **4 Asymmetric Topologies:** `[6, 2]`, `[2, 6]` ($N = 8$, $|N_F| = 3$), `[6, 6]`, `[10, 2]` ($N = 12$, $|N_F| = 3$).
- **Maximum dynamic workload:** $N_{\max} = 32$ (`4 GW x 8 mobiles`).
- **Maximum actual Cloud analyzer placements across all 16 configurations:** $k_{c,\text{actual}} = 32 - 5 \times 4 = 12$ (and theoretical upper bound if every analyzer went to Cloud: $k_{c,\max} = 32$).
- **Eligibility predicate (`COMPARE`):**
  $$P(n) \equiv (\text{CPU}_n \ge 700.0) \;\land\; (\text{RAM}_n \ge 10) \;\land\; (\text{BW}_n \ge 1000)$$

**Theorem (Benchmark-Restricted Eligibility Monotonicity):**  
*Across all 16 planned Healthcare BSN benchmark configurations ($N \le 32$, Option A BW, Design C1, deterministic ascending comparator `NODE_ASC_COMPARATOR`), the boolean eligibility predicate $P(\text{nodes}[k])$ is strictly monotonically non-decreasing in $k \in \{0, \dots, |N|-1\}$ at every iteration $t \in \{0, \dots, N-1\}$.*

**Proof:**
1. **Fog Node Resource Bounds:** Each Fog node $f \in N_F$ starts at $\langle 2800.0\text{ MIPS},\; 4000\text{ MB},\; 1{,}000{,}000\text{ BW} \rangle$. Because each placement decrements CPU by `700.0`, no Fog node can accept more than $k_f \le 4$ modules before $\text{CPU}_f = 0.0 < 700.0$ makes it ineligible. Hence, for all $f \in N_F$ and all $t$:
   $$\text{RAM}_f(t) = 4000 - 10 k_f \ge 3960 \ge 10 \quad (\text{always TRUE})$$
   $$\text{BW}_f(t) = 1{,}000{,}000 - 1000 k_f \ge 996{,}000 \ge 1000 \quad (\text{always TRUE})$$
2. **Cloud Resource Bounds:** `cloud` starts at $\langle 44{,}800.0\text{ MIPS},\; 40{,}000\text{ MB},\; 1{,}000{,}000\text{ BW} \rangle$. Pre-reserving $N \le 32$ fixed `Cloud_Storage` modules deducts at most $320\text{ MB}$ RAM and $32{,}000$ BW. Hosting up to $k_c \le 32$ `Sensor_Analyzer` modules deducts at most $22{,}400\text{ MIPS}$, $320\text{ MB}$ RAM, and $32{,}000$ BW. Hence, for all $t$:
   $$\text{CPU}_c(t) \ge 44{,}800 - 22{,}400 = 22{,}400 \ge 700 \quad (\text{always TRUE})$$
   $$\text{RAM}_c(t) \ge 40{,}000 - 640 = 39{,}360 \ge 10 \quad (\text{always TRUE})$$
   $$\text{BW}_c(t) \ge 1{,}000{,}000 - 64{,}000 = 936{,}000 \ge 1000 \quad (\text{always TRUE})$$
3. **Predicate Collapse:** Because $(\text{RAM}_n \ge 10) \equiv \text{TRUE}$ and $(\text{BW}_n \ge 1000) \equiv \text{TRUE}$ hold **universally for every node $n \in N$ at every step $t$**, the 3D predicate reduces identically to:
   $$P(n) \equiv (\text{CPU}_n \ge 700.0)$$
4. **Monotonicity Under `NODE_ASC_COMPARATOR`:** Because `NODE_ASC_COMPARATOR` orders `nodes[]` primarily by `available.mips` ascending ($\text{CPU}_{\text{nodes}[j]} \le \text{CPU}_{\text{nodes}[k]}$ for all $j < k$):
   $$P(\text{nodes}[j]) = \text{TRUE} \implies \text{CPU}_{\text{nodes}[j]} \ge 700.0 \implies \text{CPU}_{\text{nodes}[k]} \ge 700.0 \implies P(\text{nodes}[k]) = \text{TRUE} \quad \blacksquare$$

> [!CAUTION]
> **Explicit Scope Restriction:** This proof holds **ONLY** for our planned Healthcare BSN benchmark configurations ($N \le 32$, homogeneous Fog nodes, Option A BW, uniform `Sensor_Analyzer` demands). It **DOES NOT** generalize to arbitrary heterogeneous topologies where RAM or BW can become binding on a higher-CPU node. Therefore, the runtime monotonicity guard and linear-scan fallback (Section 6) remain mandatory in `ModulePlacementLBMP`.

---

## 2. Node Resource Vector & Module Demand Vector

### 2.1 Node Capacity Vector (`NodeState` — Taneja & Davy Eq. 1, p. 1224)
Each candidate node $n_i \in N = N_F \cup \{\text{cloud}\}$ is represented by a `NodeState` containing a mutable `ResourceVector(double mips, int ramMb, long bwUnits)`:

| Field | Source in iFogSim | Fog Gateway (`d-i`) | Proxy (`proxy-server`) | Cloud (`cloud`, before `Cloud_Storage`) | Unit & Classification |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `available.mips` | `device.getHost().getTotalMips()` ([Host.java:192](iFogSim-main/src/org/cloudbus/cloudsim/Host.java#L192)) | `2800.0` | `2800.0` | `44800.0` | MIPS (**LAMP Table IV Verified**) |
| `available.ramMb` | `device.getHost().getRam()` ([Host.java:265](iFogSim-main/src/org/cloudbus/cloudsim/Host.java#L265)) | `4000` | `4000` | `40000` | MB (**LAMP Table IV & iFogSim Verified**) |
| `available.bwUnits` | `device.getHost().getBw()` ([Host.java:254](iFogSim-main/src/org/cloudbus/cloudsim/Host.java#L254)) | `1,000,000` | `1,000,000` | `1,000,000` | CloudSim `long` VM BW (**Option A: CloudSim VM-Layer Approximation**) |

### 2.2 Module Demand Vector (`ModuleRequest` — Taneja & Davy Eq. 8, p. 1224)
Each dynamic analytical module `Sensor_Analyzer_i_j` ($N$ total) is represented by a `ModuleRequest`:

| Field | Source | Value | Unit & Classification |
| :--- | :--- | :---: | :--- |
| `required.mips` | Derived steady-state demand: $\lambda \cdot L_{\text{cpu}} = 0.2 \times 3500$ (LAMP Table I, p. 847; [ModulePlacementLAMP.java:46](iFogSim-main/src/org/fog/lamp/placement/ModulePlacementLAMP.java#L46)) | `700.0` | MIPS (**LAMP-Derived Approximation**; matches `ModulePlacementEdgewards` & `ModulePlacementLAMP`, distinct from boilerplate `AppModule.getMips()=1000`) |
| `required.ramMb` | `appModule.getRam()` ([HealthcareBSNApplication.java:74](iFogSim-main/src/org/fog/lamp/application/HealthcareBSNApplication.java#L74)) | `10` | MB (**Verified Mapping**) |
| `required.bwUnits` | `appModule.getBw()` ([Application.java:66](iFogSim-main/src/org/fog/application/Application.java#L66)) | `1,000` | CloudSim `long` VM BW (**Option A: CloudSim VM-Layer Approximation**) |
| `gatewayIdx`, `mobileIdx` | Parsed from `app_i_j` | `i`, `j` | Deterministic tie-break metadata (never used for locality/affinity) |

---

## 3. Resource Comparison & Atomic Decrement

### 3.1 `COMPARE` (Algorithm 3 — Taneja & Davy, p. 1226)
```java
// Exact Algorithm 3 semantics: returns 1 if ALL 3 dimensions satisfy >=, else -1
int compare(NodeState a, ModuleRequest b) {
    if (a.available.mips    >= b.required.mips &&
        a.available.ramMb   >= b.required.ramMb &&
        a.available.bwUnits >= b.required.bwUnits) {
        return 1;
    }
    return -1;
}
```
- **Precision Policy:** All benchmark MIPS values (`2800.0`, `44800.0`, `700.0`) are exact IEEE-754 binary64 integers (`2800 - 4 * 700 == 0.0` exactly with zero rounding error). Standard exact `>=` is therefore exact for all benchmark runs and boundary tests (e.g., `699.9999 < 700.0` returns `-1`, `700.0 >= 700.0` returns `1`).

### 3.2 Atomic Multi-Resource Decrement (Algorithm 1, Line 9 — Taneja & Davy, p. 1225)
```java
void reserveResources(NodeState node, ModuleRequest mod) {
    if (compare(node, mod) != 1) {
        throw new IllegalStateException("Attempted to reserve resources on ineligible node: " + node.canonicalName);
    }
    node.available.mips    -= mod.required.mips;
    node.available.ramMb   -= mod.required.ramMb;
    node.available.bwUnits -= mod.required.bwUnits;
}
```
- All three dimensions are updated atomically before re-sorting `nodes[]`.
- Precondition guard guarantees zero silent negative-capacity underflow during normal placements.

---

## 4. Deterministic Sorting Order & Tie-Breaking (`LBMP_PURE`)

Because Taneja & Davy (2017, Alg. 1 Lines 2 & 10) specify `Sort(nodes[])` and `Sort(modules[])` ascending without defining a 3D total-order comparator or tie-breaker, `LBMP_PURE` defines explicit, insertion-order-independent total orders:

### 4.1 Node Total Order (`NODE_ASC_COMPARATOR`)
```java
// Tier ordering ONLY breaks exact 3D capacity ties (never overrides resource capacity!)
// tierRank: Gateway = 0, Proxy = 1, Cloud = 2
// numericIdx: Gateway i -> i; Proxy -> 0; Cloud -> 0
Comparator<NodeState> NODE_ASC_COMPARATOR =
    Comparator.comparingDouble((NodeState n) -> n.available.mips)
              .thenComparingInt(n -> n.available.ramMb)
              .thenComparingLong(n -> n.available.bwUnits)
              .thenComparingInt(n -> n.tierRank)
              .thenComparingInt(n -> n.numericIdx)
              .thenComparing(n -> n.canonicalName);
```
- **Ordering Behavior on Our Topologies:**
  - Initially: `[d-0(2800), d-1(2800), ..., d-(G-1)(2800), proxy-server(2800), cloud(44800)]`.
  - After placing module 0 on `d-0`: `d-0` drops to `(2100, 3990, 999000)` and remains uniquely at index `0`. Modules 1, 2, 3 consolidate onto `d-0` until `d-0` reaches `(0, 3960, 996000)`.
  - Module 4 skips `d-0` (`0 < 700`) and selects `d-1` (`2800`), consolidating 4 modules onto `d-1`, and so on across `d-2`, ..., `proxy-server`, and finally `cloud`.
  - **Zero Locality/Affinity Bias:** `d-0` hosts `app_0_0..0_3`; if GW0 has only 2 mobiles (`[2, 6]` asymmetric workload), `d-0` still consolidates 4 modules (`app_0_0, app_0_1, app_1_0, app_1_1`) purely by ascending capacity—faithfully reproducing Taneja & Davy's latency-blind packing behavior (LAMP §II, p. 846: *"the delay is not taken"*).

### 4.2 Module Total Order (`MODULE_ASC_COMPARATOR`)
```java
Comparator<ModuleRequest> MODULE_ASC_COMPARATOR =
    Comparator.comparingDouble((ModuleRequest m) -> m.required.mips)
              .thenComparingInt(m -> m.required.ramMb)
              .thenComparingLong(m -> m.required.bwUnits)
              .thenComparingInt(m -> m.gatewayIdx)
              .thenComparingInt(m -> m.mobileIdx);
```
- Orders homogeneous BSN analyzers deterministically as `app_0_0, app_0_1, ..., app_(G-1)_(M-1)`.

---

## 5. Exact `LOWERBOUND` Implementation & Boundary Handling

### 5.1 Verbatim Algorithm 2 (`LOWERBOUND`, Taneja & Davy p. 1226)
```java
// Verbatim Algorithm 2 (Taneja & Davy 2017, p. 1226)
// Preconditions enforced by caller: !nodes.isEmpty(), low == 0, high == nodes.size() - 1,
// and isEligibilityMonotonic(nodes, mod) == true.
int lowerBound(List<NodeState> nodes, ModuleRequest mod, int low, int high) {
    if (nodes.isEmpty() || low > high || low < 0 || high >= nodes.size()) {
        return -1;
    }
    int length = nodes.size();
    int mid = low + (high - low) / 2;
    while (true) {
        NodeState x = nodes.get(mid);
        if (compare(x, mod) == 1) {
            high = mid - 1;
            if (high < low) {
                return mid;
            }
        } else {
            low = mid + 1;
            if (low > high) {
                return (mid < length - 1) ? (mid + 1) : -1;
            }
        }
        mid = low + (high - low) / 2;
    }
}
```

### 5.2 Boundary Reset Rule (`low = 0` Multi-Application Adaptation)
- **Published Line (Alg. 1, Line 11, p. 1225):** `low = i + 1;` after `Sort(nodes[])`.
- **Approved Design Rule (D-3.4-04):** Reset `low = 0` and `high = nodes.size() - 1` before every `lowerBound(...)` call inside the module loop.
- **Why Required:** As proved in Phase 3.3.1 §11.1, literal `low = i + 1` leaves 75% of Fog capacity unused on a 12-app / 2-GW topology (placing 9/12 modules on Cloud after only 1 module per Fog node). Resetting `low = 0` after `Sort(nodes[])` restores valid Best-Fit multi-module packing over the freshly sorted capacity array.

---

## 6. Runtime Monotonicity Guard & Linear-Scan Fallback

### 6.1 Necessity Assessment
- **On our 16 planned BSN benchmark runs ($N \le 32$):** Section 1.3 proves `isEligibilityMonotonic` will return `true` on **100% of iterations** (`linearFallbackCount == 0`), so verbatim Algorithm 2 executes on every single placement step.
- **Why the guard is STILL mandatory:**
  1. Verifies at runtime (rather than merely assuming) that our Theorem holds on every actual run (`linearFallbackCount == 0` logged as an auditable invariant).
  2. Protects unit tests (e.g., Scenario T10: independent RAM/BW failure on a higher-CPU node) and any future heterogeneous extensions against silent binary-search misplacement.
  3. For $|N| \le 6$ nodes in our topologies, the $O(|N|)$ guard costs $< 1\ \mu\text{s}$ total across an entire simulation.

### 6.2 Guard & Fallback Pseudocode
```java
// Detects EVERY TRUE -> FALSE drop across [0 .. nodes.size() - 1]
boolean isEligibilityMonotonic(List<NodeState> nodes, ModuleRequest mod) {
    boolean seenEligible = false;
    for (NodeState node : nodes) {
        boolean eligible = (compare(node, mod) == 1);
        if (seenEligible && !eligible) {
            return false;
        }
        if (eligible) {
            seenEligible = true;
        }
    }
    return true;
}

// Multi-resource exact ascending scan (Category C fallback invoked ONLY on non-monotonicity)
int linearLowerBoundScan(List<NodeState> nodes, ModuleRequest mod) {
    for (int k = 0; k < nodes.size(); k++) {
        if (compare(nodes.get(k), mod) == 1) {
            return k;
        }
    }
    return -1;
}
```

---

## 7. Cloud Placement, Fallback & Fixed Module Treatment

### 7.1 Pinned `Interface` and Fixed `Cloud_Storage` Modules
1. **`Interface_i_j` ($N$ modules):** Fixed on mobile end device `m-i-j` (consistent with Taneja & Davy p. 1225 pinning `module_1` on `Device-X-X`, and LAMP §III.A pinning `Interface` on end devices). Mobiles are **excluded** from `nodes[]`.
2. **`Cloud_Storage_i_j` ($N$ modules):** Fixed on `cloud` (consistent with LAMP §III.A).
   - **Approved Pre-Reservation Policy (`D-3.4-07`):** Before `MODULEMAP` begins, `cloudState` pre-reserves `10 MB` RAM and `1,000` Host BW units per fixed `Cloud_Storage_i_j` (`10 * N` MB RAM and `1000 * N` Host BW), while `Cloud_Storage` CPU is **not** deducted from the LBMP analytical placement budget.
   - **Mandatory Accounting Terminology:**
     > *Fixed-module accounting convention: Cloud_Storage RAM and Host BW are pre-reserved in the LBMP analytical resource ledger. Its CPU is intentionally excluded to preserve comparability with the existing LAMP/EWMP placement convention. Consequently, the LBMP ledger is not a complete mirror of CloudSim's resource consumption.*

#### Source Verification of Existing LAMP/EWMP CPU Exclusion & Discrepancies
Direct read-only inspection of the existing codebase confirms that none of the existing LAMP or EWMP placement implementations deduct `Cloud_Storage` CPU from `cloud`:
- [ModulePlacementLAMP.java:102–105, 193–218](iFogSim-main/src/org/fog/lamp/placement/ModulePlacementLAMP.java#L193-L218): Initializes `availableMipsMap` from `getTotalMips()`, deducts `SENSOR_ANALYZER_MIPS_DEMAND` **only** when `!selectedDevice.getName().equals("cloud")` (lines 193–195), and maps `Cloud_Storage` to `cloud` (lines 212, 218) with zero CPU deduction.
- [ModulePlacementAsymmetricLAMP.java:74–76, 173–194](iFogSim-main/src/org/fog/lamp/asymmetric/ModulePlacementAsymmetricLAMP.java#L173-L194): Identical (`if (!selectedDevice.getName().equals("cloud"))` at line 173; zero CPU deduction for `Cloud_Storage` or `cloud`-hosted `Sensor_Analyzer`).
- [HealthcareSimulationRunner.java:147–182](iFogSim-main/src/org/fog/lamp/simulation/HealthcareSimulationRunner.java#L168-L182) & [AsymmetricSimulationRunner.java:144–176](iFogSim-main/src/org/fog/lamp/asymmetric/AsymmetricSimulationRunner.java#L168-L176) (EWMP): Identical (`if (!selectedDevice.getName().equals("cloud"))` at lines 168–170; zero CPU deduction for `Cloud_Storage`).

**Recorded Discrepancies Between Analytical Ledger and CloudSim Runtime:**
1. *Unmodeled `Cloud_Storage` CPU:* In [HealthcareBSNApplication.java:85](iFogSim-main/src/org/fog/lamp/application/HealthcareBSNApplication.java#L85), `STORE_PROCESS_COMPUTE` carries `tupleCpuLength = 1000 MI` at `0.2 Hz` (`200 MIPS` steady-state), and [Application.java:64](iFogSim-main/src/org/fog/application/Application.java#L64) assigns boilerplate `AppModule.getMips() = 1000`. Neither is deducted in LAMP, EWMP, or the LBMP analytical ledger.
2. *Normal Cloud `Sensor_Analyzer` CPU Deduction Difference:* Existing LAMP and EWMP skip deducting `Sensor_Analyzer` CPU on `cloud` altogether (`!selectedDevice.getName().equals("cloud")`), whereas `LBMP_PURE` under Design C1 **does** deduct `700.0 MIPS` from `cloudState` whenever `cloud` is selected via normal `LOWERBOUND` comparison (`i != -1`).
3. *Host Storage & VM OverSubscription:* CloudSim's `HostEntity.guestCreate` ([HostEntity.java:52–78](iFogSim-main/src/org/cloudbus/cloudsim/core/HostEntity.java#L52-L78)) also enforces `Host.storage` (`10,000,000` vs. `10,000` per module) and uses `VmSchedulerTimeSharedOverSubscription` (which scales MIPS instead of rejecting). Thus, the LBMP analytical ledger and CloudSim runtime enforcement are distinct layers.

### 7.2 Exact Cloud Placement & Fallback Safeguards (Design C1 + `D-3.4-08`)
- `cloudState` is included inside `nodes[]` alongside `{d-0..d-(G-1), proxy-server}` (Taneja & Davy Eqs. 2–6, p. 1224).
- **Path 1 — Normal Cloud Selection (`i != -1` and `nodes.get(i) == cloudState`):**
  - Triggered when all Fog nodes fail `compare` (`< 700 MIPS`) and `LOWERBOUND` (or linear fallback) returns `cloudState`'s index with `compare(cloudState, mod) == 1`.
  - Atomically decrements `cloudState`'s `(mips, ramMb, bwUnits)` via `reserveResources(cloudState, mod)`, re-sorts `nodes[]`, and increments `cloudSelectedNormalCount++`.
- **Path 2 — Unconditional Cloud Fallback (`i == -1` — Algorithm 1, Line 13, p. 1225):**
  - Strictly separated from Path 1; triggered **only** when every node in `nodes[]` (including `cloudState`) fails `compare`.
  - **Explicit Reference Safeguard:** Targets the explicit `cloudState` object reference directly—**never** assumes `nodes.get(nodes.size() - 1)` is Cloud after arbitrary sorting or exhaustion.
  - Increments `cloudFallbackCount++`, emits explicit warning `[LBMP_WARN] Cloud fallback triggered (capacity exceeded) for <module>`, and logs the exact unmet resource deficit (`cloudDeficitMips/Ram/Bw`) without corrupting `cloudState` into silent negative values.
  - **VM Instantiation Separation Safeguard:** A fallback mapping is **NOT** automatically counted as a successful CloudSim VM instantiation. When `ModulePlacementMapping` executes `ModulePlacement.createModuleInstanceOnDevice` ([ModulePlacement.java:47–70](iFogSim-main/src/org/fog/placement/ModulePlacement.java#L47-L70)), actual VM instantiation success/failure (`HostEntity.guestCreate` returning `true` vs. `false`) MUST be inspected from `placement.getDeviceToModuleMap()` and recorded separately (`vmInstantiationSuccessCount` vs. `vmInstantiationFailureCount`).

### 7.3 Complete `executeModuleMap` Control Flow
```java
void executeModuleMap(List<NodeState> nodes, NodeState cloudState, List<ModuleRequest> requests) {
    nodes.sort(NODE_ASC_COMPARATOR);       // Alg. 1 Line 2
    requests.sort(MODULE_ASC_COMPARATOR);  // Alg. 1 Line 2

    for (ModuleRequest mod : requests) {   // Alg. 1 Line 5
        int low = 0;                       // D-3.4-04: Multi-app adaptation (replaces Line 11 low = i + 1)
        int high = nodes.size() - 1;

        int idx;
        if (isEligibilityMonotonic(nodes, mod)) {
            idx = lowerBound(nodes, mod, low, high); // Verbatim Alg. 2
            binarySearchCount++;
        } else {
            logWarning("Non-monotonic eligibility for " + mod.moduleName + "; using linear scan fallback.");
            idx = linearLowerBoundScan(nodes, mod);
            linearFallbackCount++;
        }

        if (idx != -1) {
            // Path 1: Normal selection (Fog OR Cloud via COMPARE == 1)
            NodeState chosen = nodes.get(idx);
            boolean isCloud = (chosen == cloudState);
            assignAnalyzerNormal(mod, chosen, isCloud);
            reserveResources(chosen, mod);   // Alg. 1 Line 9 (atomic 3D decrement)
            nodes.sort(NODE_ASC_COMPARATOR); // Alg. 1 Line 10
        } else {
            // Path 2: Unconditional Cloud fallback (Alg. 1 Line 13)
            // Uses explicit cloudState reference (never nodes.get(nodes.size() - 1))
            assignAnalyzerCloudFallback(mod, cloudState);
            recordCloudFallbackDeficit(cloudState, mod);
        }
    }
}
```

---

## 8. Placement Accounting & Output Schema

Every simulation run must track and assert the exact 2-tier accounting established in Phase 2.2, plus separate CloudSim VM instantiation verification:

1. **Analytical `Sensor_Analyzer` Placement Decisions (Sum MUST equal $N$):**
   - `analyzerLocalGw`: `Sensor_Analyzer_i_j` assigned to its own originating `d-i` *(telemetry only—never influences `LBMP_PURE` placement)*.
   - `analyzerPeerGw`: `Sensor_Analyzer_i_j` assigned to a gateway `d-k` with $k \neq i$.
   - `analyzerProxy`: `Sensor_Analyzer_i_j` assigned to `proxy-server`.
   - `analyzerCloudNormal` (`cloudSelectedNormalCount`): `Sensor_Analyzer_i_j` assigned to `cloud` via Path 1 (`i != -1`, `compare == 1`).
   - `analyzerCloudFallback` (`cloudFallbackCount`): `Sensor_Analyzer_i_j` assigned to `cloud` via Path 2 (`i == -1` fallback; NOT assumed to be a successful VM instantiation).
   - **Invariant 1 (Analytical Decisions):** `analyzerLocalGw + analyzerPeerGw + analyzerProxy + analyzerCloudNormal + analyzerCloudFallback == N`.
2. **Planned System Module Assignments (Sum MUST equal $3N$):**
   - `plannedFogModules = N (Interface on mobiles) + analyzerLocalGw + analyzerPeerGw + analyzerProxy`.
   - `plannedCloudModules = N (Cloud_Storage on cloud) + analyzerCloudNormal + analyzerCloudFallback`.
   - **Invariant 2 (Planned Assignments):** `plannedFogModules + plannedCloudModules == 3 * N`.
3. **Actual CloudSim VM Instantiation Verification (`D-3.4-08`):**
   - After constructing `ModulePlacementMapping` for each application, inspect `placement.getDeviceToModuleMap()` to count modules actually instantiated by `HostEntity.guestCreate`:
     - `vmInstantiationSuccessCount`: actual count of `AppModule` instances present in `deviceToModuleMap` across all devices (expected `3 * N` when no host rejects allocation).
     - `vmInstantiationFailureCount`: `(3 * N) - vmInstantiationSuccessCount` (logged explicitly with exact failed `(moduleName, targetDeviceName)` pairs whenever `> 0`).
   - A fallback mapping (`analyzerCloudFallback > 0`) that fails `HostEntity.guestCreate` (e.g., due to Cloud RAM, Host BW, or Storage exhaustion) is explicitly recorded in `vmInstantiationFailureCount` rather than silently counted as instantiated.
4. **Diagnostic & Audit Output Per Run:**
   - Exact `Sensor_Analyzer_i_j -> hostDevice (NORMAL|CLOUD_NORMAL|CLOUD_FALLBACK)` mapping table.
   - Final remaining `(mips, ramMb, bwUnits)` for every node in `nodes[]` (plus any `cloudDeficitMips/Ram/Bw`).
   - Search & VM telemetry: `binarySearchCount`, `linearFallbackCount`, `cloudSelectedNormalCount`, `cloudFallbackCount`, `vmInstantiationSuccessCount`, `vmInstantiationFailureCount`.
   - Loop completion telemetry: `completedLoops / expectedLoops`, `loopDelaySimTicks` (or `N/A` if 0 completed), status (`SUCCESS`, `PARTIAL_COMPLETION`, `NO_COMPLETION`, `TIMEOUT`).
   - Structured CSV output (`LBMP_SYMM_CSV_ROW` / `LBMP_ASYM_CSV_ROW`) aligned identically with Phase 2 and Phase 2.2 schemas.

---

## 9. Strict Project Isolation Requirements

| Boundary | Rule |
| :--- | :--- |
| **New Java Package** | `iFogSim-main/src/org/fog/lamp/baselines/` (`ModulePlacementLBMP.java`, `BaselineSimulationRunner.java`, `ModulePlacementLBMPTest.java`) |
| **Untouched Java Code** | ZERO edits to `org.fog.lamp.placement.ModulePlacementLAMP`, `org.fog.lamp.simulation.HealthcareSimulationRunner`, `org.fog.lamp.asymmetric.*`, `org.fog.lamp.topology.HealthcareTopologyFactory`, `org.fog.lamp.application.HealthcareBSNApplication`, or any upstream iFogSim/CloudSim class. |
| **Untouched Data & Logs** | ZERO edits to `results/lamp_reproduction_results_phase1_historical.csv`, `results/lamp_reproduction_results_phase2.csv`, `results/asymmetric_validation_results.csv`, `results/raw_logs/`, `results/raw_logs_phase2/`, or `results/raw_logs_asymmetric/`. |
| **Dedicated Output Paths** | `results/lbmp_symmetric_results.csv`, `results/lbmp_asymmetric_results.csv`, `results/raw_logs_lbmp_symmetric/`, `results/raw_logs_lbmp_asymmetric/`. |
| **Untouched Reports** | ZERO edits to Phase 1, 1A, 1B, 2, 2 Audit, 2.2, 3.1, 3.2, or 3.3.1 reports. |

---

## 10. Unit Test & Validation Specification (`ModulePlacementLBMPTest`)

All 11 deterministic unit tests must execute and pass **before** running any full iFogSim benchmark simulation:

| Test ID | Scenario | Input Setup | Exact Expected Output / Assertion |
| :---: | :--- | :--- | :--- |
| **T01** | **Resource Equality Boundary** | 1 Fog node `<700.0, 10, 1000>`, Cloud `<44800, 40000, 1M>`, 1 module `<700.0, 10, 1000>` | `compare == 1`; module placed on Fog node; Fog remaining = `<0.0, 0, 0>`; `cloudSelectedNormalCount == 0`. |
| **T02** | **Insufficient CPU Independently** | 1 Fog node `<699.9, 4000, 1M>`, Cloud `<44800, 40000, 1M>`, 1 module `<700.0, 10, 1000>` | `compare(fog) == -1`; module placed on `cloud`; `cloudSelectedNormalCount == 1`. |
| **T03** | **Insufficient RAM Independently** | 1 Fog node `<2800.0, 9, 1M>`, Cloud `<44800, 40000, 1M>`, 1 module `<700.0, 10, 1000>` | `compare(fog) == -1`; module placed on `cloud`; `cloudSelectedNormalCount == 1`. |
| **T04** | **Insufficient BW Independently** | 1 Fog node `<2800.0, 4000, 999>`, Cloud `<44800, 40000, 1M>`, 1 module `<700.0, 10, 1000>` | `compare(fog) == -1`; module placed on `cloud`; `cloudSelectedNormalCount == 1`. |
| **T05** | **Multiple Modules w/ Dynamic Re-Sorting** | `d-0`, `d-1`, `proxy` (`2800` each) + `cloud`; 6 modules (`700` each) | `d-0` receives modules 0–3 (`2800->2100->1400->700->0`); `d-1` receives modules 4–5 (`2800->2100->1400`); `proxy` untouched (`2800`); `cloud` untouched. |
| **T06** | **`low = 0` Boundary Reset Verification** | `d-0`, `d-1`, `proxy` (`2800` each) + `cloud`; 12 modules (`700` each) | 12/12 placed on Fog (`d-0:4, d-1:4, proxy:4`); **0** on Cloud (proving `low = 0` prevents the 9-to-Cloud abandonment of literal `low = i + 1`). |
| **T07** | **Cloud Selected by Normal Comparison** | `d-0`, `d-1`, `proxy` (`2800` each) + `cloud` (`44800`); 16 modules (`700` each) | 12 on Fog, **4** on Cloud via normal search (`cloudSelectedNormalCount == 4`, `cloudFallbackCount == 0`); Cloud remaining MIPS = `42,000.0`, RAM = `40,000 - 16*10 - 4*10 = 39,800`, BW = `1,000,000 - 16*1000 - 4*1000 = 980,000`. |
| **T08** | **Cloud Selected by `i == -1` Fallback & VM Failure Tracking** | (a) `d-0` `<0, 4000, 1M>`, synthetic `cloud` `<500, 40000, 1M>`, 1 module `<700, 10, 1000>`; (b) synthetic `cloud` `<500, 5, 1M>` (insufficient Cloud RAM so `HostEntity.guestCreate` fails) | (a) `lowerBound` returns `-1`; assigned to explicit `cloudState` (even when `cloudState` is NOT at `nodes[size - 1]`); `cloudFallbackCount == 1`, `cloudSelectedNormalCount == 0`, deficit logged. (b) Fallback recorded in `cloudFallbackCount == 1` AND CloudSim rejection recorded separately in `vmInstantiationFailureCount >= 1` (NOT counted as successful VM instantiation). |
| **T09** | **Deterministic Tie Handling** | Same `[2, 6]` workload initialized with 5 shuffled permutations of `fogDevices` & `apps` lists | All 5 runs produce **bit-for-bit identical** `module -> device` maps (`d-0` gets `app_0_0, 0_1, 1_0, 1_1`; `d-1` gets `app_1_2..1_5`). |
| **T10** | **Monotonicity Guard & Linear Fallback** | Synthetic nodes: `n0=<1000, 4000, 1M>`, `n1=<2000, 5, 1M>`, `n2=<3000, 5, 1M>`; module `<500, 10, 1000>` | Predicate is `[TRUE, FALSE, FALSE]`; guard returns `false`; `linearFallbackCount == 1`; module placed on `n0` (NOT falsely sent to Cloud fallback). |
| **T11** | **Exact `3N` Module & VM Accounting** | Full Healthcare BSN topologies for $N \in \{4, 8, 12, 16, 32\}$ | `sum(analyzers) == N`, `plannedFog + plannedCloud == 3 * N`, `vmInstantiationSuccessCount == 3 * N`, `vmInstantiationFailureCount == 0`, `linearFallbackCount == 0`, `cloudFallbackCount == 0` across all 5 sizes. |

---

## 11. Change Log & Decision Status

### Change Log (Phase 3.4)
- **2026-11-18 (Rev. 2 — Documentation Clarification):** Recorded approved Decision `D-3.4-07` (`Cloud_Storage` RAM/Host-BW pre-reservation, CPU excluded) and `D-3.4-08` (Cloud/VM safeguards); replaced synchronization claim with required fixed-module accounting convention terminology; added verified source locations and discrepancies from existing LAMP/EWMP implementations; separated analytical fallback counts from actual CloudSim VM instantiation successes/failures; mandated explicit `cloudState` reference for fallback; updated Test T08 & T11.
- **2026-11-18 (Rev. 1 — Initial Specification):** Created `PHASE_3_4_LBMP_DESIGN_SPECIFICATION.md` with Phase 3.3.1 §11.2 Cloud BW dominance erratum and benchmark-restricted monotonicity proof; created `CODEBASE_ARCHITECTURE_AND_NAVIGATION_MANUAL.md`; updated `DOCUMENTATION_INDEX.md`.

### Open Technical Questions
**None.** All Phase 3.4 design decisions (`D-3.4-01` through `D-3.4-08`) are now resolved and documented consistently across the project specification, architecture manual, and documentation index.

---
*Phase 3.4 documentation clarification complete. Zero Java files modified, zero simulations run. Standing by for your review and explicit authorization to begin Phase 3.5 Java implementation.*
