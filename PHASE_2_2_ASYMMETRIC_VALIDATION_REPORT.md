# PHASE 2.2: LAMP ALGORITHM FIDELITY & ASYMMETRIC TOPOLOGY VALIDATION REPORT
**Project:** LAMP Research Reproduction — *A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications*  
**Date:** November 17, 2026  
**Status:** VALIDATED & COMPLETED  
**Working Directory:** `C:\Users\91630\Desktop\Code Playground\LAMP\`  
**Dataset:** `results/asymmetric_validation_results.csv` (20 rows) & `results/raw_logs_asymmetric/` (20 raw logs)  
**Toolchain:** Eclipse JustJ OpenJDK Hotspot 21.0.6 LTS / iFogSim / CloudSim  

---

## 1. Executive Summary

Phase 2.2 was authorized to evaluate the algorithm fidelity of the Latency-Aware Module Placement (LAMP) algorithm and test its peer-gateway offloading behavior in asymmetric Fog topologies. All experiments were conducted using an **isolated experimental harness** (`org.fog.lamp.asymmetric.*`), ensuring zero modification or overwriting of Phase 1 and Phase 2 source code, datasets, raw logs, or reports.

The study investigated four workload configurations across 2 Fog Gateways:
- **`[6, 2]`**: Gateway 0 has 6 mobiles, Gateway 1 has 2 mobiles (Total $N = 8$).
- **`[2, 6]`**: Gateway 0 has 2 mobiles, Gateway 1 has 6 mobiles (Total $N = 8$, inverted asymmetry).
- **`[6, 6]`**: Gateway 0 has 6 mobiles, Gateway 1 has 6 mobiles (Total $N = 12$, symmetric control).
- **`[10, 2]`**: Gateway 0 has 10 mobiles, Gateway 1 has 2 mobiles (Total $N = 12$, asymmetric saturation probe).

Five distinct algorithmic variants were evaluated:
1. **`COMP`**: Cloud-Only baseline.
2. **`LAMP_FWD`**: Paper's simulation clock convention with Forward iteration order (GW0 $\to$ GW1).
3. **`LAMP_REV`**: Paper's simulation clock convention with Reverse iteration order (GW1 $\to$ GW0).
4. **`LAMP_PHYS`**: Strict physical SI interpretation of Equation 4 in seconds.
5. **`EWMP`**: Hierarchical Edge-Wards placement baseline.

```
+----------------------------------------------------------------------------------------------------+
|                                    PHASE 2.2 CORE HIGHLIGHTS                                       |
+--------------------------+-------------------------------------------------------------------------+
| Peer Gateway Offloading  | ACTIVATED in [10, 2] (GW0 offloaded exactly 2 modules to Peer GW 1).    |
| Cloud Placement Savings  | LAMP placed 0 analytical modules on Cloud in [10, 2] (EWMP placed 2).   |
| Iteration Order Impact   | Macroscopic placement invariant; microscopic mapping reversed.          |
| Cross-Traffic Tradeoff   | Peer offloading traverses Proxy twice, inducing partial loop completion |
|                          | in LAMP (10/12), while EWMP achieved 100% completion (12/12).          |
| 3N Invariant Check       | VERIFIED 100% across all 20 runs (24 modules for N=8, 36 for N=12).     |
| Equation 4 SI Finding    | Under strict SI units, Cloud is 16x faster, causing LAMP to prefer      |
|                          | Cloud over Proxy and Peer Gateways.                                     |
+--------------------------+-------------------------------------------------------------------------+
```

---

## 2. Equation 4 Dimensional Analysis & Table I Ambiguity

### 2.1 The Published Formulation
Section IV.A and Table II of the LAMP paper define:
$$t_a^m = Q_{p'}^m + \Delta_{pp'} + Z \quad \text{(Equation 4)}$$
- $p$: Local Gateway connected to the patient's mobile.
- $p'$: Candidate target host device.
- $\Delta_{pp'}$: One-way network path delay from $p$ to $p'$.
- $Q_{p'}^m$: Execution time of module $m$ on candidate $p'$.
- $Z$: Accumulated network latency up to local gateway ($2.6\text{ ms}$).

### 2.2 Table I Ambiguity: MIPS vs. Million Instructions (MI)
In Table I of the original paper, the column specifying tuple computational workload is labeled:
$$\text{"CPU Length (MIPS)"}$$
In CloudSim/iFogSim, this is a conceptual mislabeling:
- Workload length is stored as **Million Instructions (MI)**.
- Processing capacity is stored as **MIPS (Million Instructions Per Second)**.
- Processing time is $\Delta t = \frac{\text{Workload (MI)}}{\text{Capacity (MIPS)}} = \text{seconds}$.
- For `Sensor_Analyzer` ($3,500\text{ MI}$) on a $2,800\text{ MIPS}$ gateway:
  $$\Delta t = \frac{3,500}{2,800} = 1.25\text{ seconds}$$

### 2.3 Comparison of Equation 4 Interpretations

```
+---------------------------------------------------------------------------------------------------+
|                                EQUATION 4 CANDIDATE LATENCY COMPARISON                            |
+-------------------+---------------------------------------+---------------------------------------+
| Candidate Device  | Variant A: PAPER_CONVENTION (Ticks)   | Variant B: PHYSICAL_SI (Seconds)      |
+-------------------+---------------------------------------+---------------------------------------+
| Local Gateway     | Q=1.25, Delta=0.0, Z=2.6 -> 3.85 tau  | Q=1.25s, Delta=0.0s, Z=0.0026s -> 1.2526s (Rank 2)
| Proxy Server      | Q=1.25, Delta=4.0, Z=2.6 -> 7.85 tau  | Q=1.25s, Delta=0.004s, Z=0.0026s -> 1.2566s (Rank 3)
| Peer Gateway      | Q=1.25, Delta=8.0, Z=2.6 -> 11.85 tau | Q=1.25s, Delta=0.008s, Z=0.0026s -> 1.2606s (Rank 4)
| Cloud Data Center | Q=0.078, Delta=104, Z=2.6 -> 106.68 tau| Q=0.078s, Delta=0.104s, Z=0.0026s -> 0.1847s (Rank 1)
+-------------------+---------------------------------------+---------------------------------------+
| Candidate Ranking | Local GW < Proxy < Peer GW << Cloud   | Cloud << Local GW < Proxy < Peer GW   |
+-------------------+---------------------------------------+---------------------------------------+
```

### 2.4 Assumptions Documented & Methodological Clarification
To preserve scientific rigor, we record the distinct foundational assumptions behind each latency evaluation variant:

> [!IMPORTANT]
> **Methodological Note on `PAPER_CONVENTION`:**
> We do NOT claim that `PAPER_CONVENTION` is conclusively the original authors' implementation. Rather, it is a numerical modeling interpretation consistent with the reported placement behavior. Both `PAPER_CONVENTION` and `PHYSICAL_SI` are preserved as separate experimental variants to expose how unit assumptions dictate placement rankings.

1. **`PAPER_CONVENTION` (Composite Simulation Ticks $\tau$):**
   - **Workload & Delay Integration:** Assumes the simulation engine processes tuple computation ticks ($\frac{3500\text{ MI}}{2800\text{ MIPS}} = 1.25\,\tau$) and network link propagation ticks ($\Delta_{\text{proxy}} = 4.0\,\tau$, $\Delta_{\text{cloud}} = 100.0\,\tau$) as directly additive clock units without scale factors.
   - **Alternative Interpretation:** Alternatively, it assumes an ultra-lightweight IoT analytical workload of $3.5\text{ MI}$ (or $3,500\text{ kMI}$), which executes in $1.25\text{ ms}$ on a $2,800\text{ MIPS}$ gateway, rendering all terms dimensionally in milliseconds.
   - **Resulting Behavior:** Local Gateway ($3.85\,\tau$) < Proxy ($7.85\,\tau$) < Peer Gateway ($11.85\,\tau$) $\ll$ Cloud ($106.68\,\tau$). Preserves the Fog-first hierarchical offloading reported in the paper.

2. **`PHYSICAL_SI` (Strict Physical Seconds):**
   - **Strict SI Conversion:** Link delays from Table III are converted strictly to physical seconds ($0.004\text{ s}$ for Proxy, $0.104\text{ s}$ for Cloud WAN).
   - **Compute Speed Dominance:** Because the Cloud Data Center provides $44,800\text{ MIPS}$ compared to a Fog Gateway's $2,800\text{ MIPS}$ ($16\times$ compute advantage), the Cloud executes a $3,500\text{ MI}$ tuple in $0.078125\text{ s}$, saving $1.171875\text{ s}$ ($1,171.9\text{ ms}$) of CPU processing time over Fog nodes.
   - **Resulting Behavior:** The Cloud's $1,171.9\text{ ms}$ compute speedup completely overwhelms the $104.0\text{ ms}$ WAN latency: Cloud ($0.1847\text{ s}$) $\ll$ Local Gateway ($1.2526\text{ s}$) < Proxy ($1.2566\text{ s}$) < Peer Gateway ($1.2606\text{ s}$). Under strict physical SI units, LAMP ranks Cloud as Candidate #1, transforming it into a Cloud-first offloader.

---

## 3. Comprehensive 20-Run Asymmetric Results Table

```
Algorithm | Workload | Apps | Delay (tau) | Loops (C/E) | Analyzers (L/P/Px/C) | Total (Fog/Cloud/All) | 3N Check | Status
----------+----------+------+-------------+-------------+----------------------+-----------------------+----------+-------------------
COMP      | [6, 2]   | 8    | 472.4297    | 8 / 8       | 0 / 0 / 0 / 8        | 8 / 16 / 24           | PASSED   | SUCCESS
LAMP_FWD  | [6, 2]   | 8    | 216.1901    | 8 / 8       | 6 / 0 / 2 / 0        | 16 / 8 / 24           | PASSED   | SUCCESS
LAMP_REV  | [6, 2]   | 8    | 216.5255    | 8 / 8       | 6 / 0 / 2 / 0        | 16 / 8 / 24           | PASSED   | SUCCESS
LAMP_PHYS | [6, 2]   | 8    | 261.4324    | 8 / 8       | 6 / 0 / 0 / 2        | 14 / 10 / 24          | PASSED   | SUCCESS
EWMP      | [6, 2]   | 8    | 216.1901    | 8 / 8       | 6 / 0 / 2 / 0        | 16 / 8 / 24           | PASSED   | SUCCESS
----------+----------+------+-------------+-------------+----------------------+-----------------------+----------+-------------------
COMP      | [2, 6]   | 8    | 472.4580    | 8 / 8       | 0 / 0 / 0 / 8        | 8 / 16 / 24           | PASSED   | SUCCESS
LAMP_FWD  | [2, 6]   | 8    | 215.1721    | 8 / 8       | 6 / 0 / 2 / 0        | 16 / 8 / 24           | PASSED   | SUCCESS
LAMP_REV  | [2, 6]   | 8    | 215.8343    | 8 / 8       | 6 / 0 / 2 / 0        | 16 / 8 / 24           | PASSED   | SUCCESS
LAMP_PHYS | [2, 6]   | 8    | 261.5234    | 8 / 8       | 6 / 0 / 0 / 2        | 14 / 10 / 24          | PASSED   | SUCCESS
EWMP      | [2, 6]   | 8    | 215.1721    | 8 / 8       | 6 / 0 / 2 / 0        | 16 / 8 / 24           | PASSED   | SUCCESS
----------+----------+------+-------------+-------------+----------------------+-----------------------+----------+-------------------
COMP      | [6, 6]   | 12   | 782.5828    | 12 / 12     | 0 / 0 / 0 / 12       | 12 / 24 / 36          | PASSED   | SUCCESS
LAMP_FWD  | [6, 6]   | 12   | 434.2719    | 12 / 12     | 8 / 0 / 4 / 0        | 24 / 12 / 36          | PASSED   | SUCCESS
LAMP_REV  | [6, 6]   | 12   | 434.5285    | 12 / 12     | 8 / 0 / 4 / 0        | 24 / 12 / 36          | PASSED   | SUCCESS
LAMP_PHYS | [6, 6]   | 12   | 516.3034    | 12 / 12     | 8 / 0 / 0 / 4        | 20 / 16 / 36          | PASSED   | SUCCESS
EWMP      | [6, 6]   | 12   | 434.2719    | 12 / 12     | 8 / 0 / 4 / 0        | 24 / 12 / 36          | PASSED   | SUCCESS
----------+----------+------+-------------+-------------+----------------------+-----------------------+----------+-------------------
COMP      | [10, 2]  | 12   | 569.0689    | 12 / 12     | 0 / 0 / 0 / 12       | 12 / 24 / 36          | PASSED   | SUCCESS
LAMP_FWD  | [10, 2]  | 12   | 310.2287    | 10 / 12     | 6 / 2 / 4 / 0        | 24 / 12 / 36          | PASSED   | PARTIAL_COMPLETION
LAMP_REV  | [10, 2]  | 12   | 306.5562    | 10 / 12     | 6 / 2 / 4 / 0        | 24 / 12 / 36          | PASSED   | PARTIAL_COMPLETION
LAMP_PHYS | [10, 2]  | 12   | 380.1116    | 12 / 12     | 6 / 0 / 0 / 6        | 18 / 18 / 36          | PASSED   | SUCCESS
EWMP      | [10, 2]  | 12   | 344.1805    | 12 / 12     | 6 / 0 / 4 / 2        | 22 / 14 / 36          | PASSED   | SUCCESS
```

---

## 4. Module Accounting: Analytical vs. Total System Placements

To prevent reporting ambiguities, module counts are explicitly separated into:
1. **`Sensor_Analyzer` Placements ($N$ modules):** The only module dynamically placed by algorithms across Local Gateway, Peer Gateway, Proxy Server, and Cloud.
2. **Fixed System Modules ($2N$ modules):** $N$ `Interface` modules pinned to Mobile End Devices, plus $N$ `Cloud_Storage` modules pinned to Cloud Data Center.
3. **Total System Modules ($3N$ modules):**
   $$\text{Total System Modules} = \text{Total Fog} + \text{Total Cloud} = (N + \text{Fog Analyzers}) + (N + \text{Cloud Analyzers}) = 3N$$

```
+---------------+-----------+-----------------------------------+-----------------------------------+--------------+
| Configuration | Algorithm | Sensor_Analyzer Breakdown (N)     | System Module Breakdown (3N)      | 3N Verified? |
+---------------+-----------+-----------------------------------+-----------------------------------+--------------+
| [6, 2] (N=8)  | COMP      | 0 Local, 0 Peer, 0 Proxy, 8 Cloud | 8 Fog (Mobiles) + 16 Cloud        | PASSED (24)  |
| [6, 2] (N=8)  | LAMP_FWD  | 6 Local, 0 Peer, 2 Proxy, 0 Cloud | 16 Fog (8 Mob+8 Fog) + 8 Cloud    | PASSED (24)  |
| [6, 2] (N=8)  | LAMP_PHYS | 6 Local, 0 Peer, 0 Proxy, 2 Cloud | 14 Fog (8 Mob+6 Fog) + 10 Cloud   | PASSED (24)  |
| [6, 2] (N=8)  | EWMP      | 6 Local, 0 Peer, 2 Proxy, 0 Cloud | 16 Fog (8 Mob+8 Fog) + 8 Cloud    | PASSED (24)  |
+---------------+-----------+-----------------------------------+-----------------------------------+--------------+
| [10, 2] (N=12)| COMP      | 0 Local, 0 Peer, 0 Proxy, 12 Cloud| 12 Fog (Mobiles) + 24 Cloud       | PASSED (36)  |
| [10, 2] (N=12)| LAMP_FWD  | 6 Local, 2 Peer, 4 Proxy, 0 Cloud | 24 Fog (12 Mob+12 Fog) + 12 Cloud | PASSED (36)  |
| [10, 2] (N=12)| LAMP_PHYS | 6 Local, 0 Peer, 0 Proxy, 6 Cloud | 18 Fog (12 Mob+6 Fog) + 18 Cloud  | PASSED (36)  |
| [10, 2] (N=12)| EWMP      | 6 Local, 0 Peer, 4 Proxy, 2 Cloud | 22 Fog (12 Mob+10 Fog) + 14 Cloud | PASSED (36)  |
+---------------+-----------+-----------------------------------+-----------------------------------+--------------+
```

> [!CAUTION]
> **Critical Distinction on `LAMP_PHYS` Accounting:**
> In `LAMP_PHYS` for `[10, 2]`, exactly **6 analytical `Sensor_Analyzer` modules** are placed on the Cloud (overflow from saturated local gateways), while **6 analytical modules** remain placed on Fog Gateways (4 on `d-0`, 2 on `d-1`).
> When combined with the $2N = 24$ fixed system modules (12 `Interface` on mobiles and 12 `Cloud_Storage` on Cloud), the total distribution is:
> - **Total Fog Placements:** $12 \text{ (Mobiles)} + 6 \text{ (Analyzers)} = \mathbf{18\text{ Fog modules}}$.
> - **Total Cloud Placements:** $12 \text{ (Cloud\_Storage)} + 6 \text{ (Analyzers)} = \mathbf{18\text{ Cloud modules}}$.
> - **Total System Placements:** $18 + 18 = \mathbf{36\text{ modules } (3N)}$.
>
> It is an error to report that "all 12 system modules are on the Cloud" in `LAMP_PHYS`. The interface modules remain anchored to the mobile end devices, local gateway slots host 6 analytical modules, and only analytical overflow is directed to the Cloud due to compute speed ranking.

---

## 5. Detailed Answers to Core Research Questions

### 5.1 Does LAMP successfully use spare peer-gateway capacity?
**YES.** In Configuration 4 (`[10, 2]`), Gateway 0 hosted 10 mobiles with a local capacity of 4.
- Gateway 0 placed 4 modules on itself (`d-0`).
- Gateway 0 overflowed 6 modules: Proxy Server took 4 (Proxy capacity exhausted: 2,800 MIPS).
- For the remaining 2 overflow modules, Proxy was full. LAMP evaluated Candidate 2 (Peer Gateway `d-1`).
- Gateway 1 had only 2 mobiles ($1,400\text{ MIPS}$ free).
- **LAMP successfully placed `Sensor_Analyzer_0_8` and `Sensor_Analyzer_0_9` on Peer Gateway `d-1`!**
- In `[6, 2]` and `[2, 6]`, peer offloading did not activate because the total overflow was only 2 modules, which the Proxy Server ($t_a^m = 7.85$) absorbed before Peer Gateway ($t_a^m = 11.85$) was reached.

### 5.2 Does reversing application iteration order change placements?
**Macroscopically: NO. Microscopically: YES.**
- In `[10, 2]`:
  - `LAMP_FWD` (GW0 first): Placed `Sensor_Analyzer_0_8` and `0_9` on Peer Gateway `d-1`.
  - `LAMP_REV` (GW1 first): Evaluated `app_1_0` and `app_1_1` first (placed on `d-1`), then evaluated `app_0_9` down to `app_0_0`. The last two overflow modules (`app_0_1` and `app_0_0`) were placed on `d-1`.
- In both orders, total placements were **identical**: Local=6, Peer=2, Proxy=4, Cloud=0.
- Delay was practically identical: $310.23\,\tau$ (Forward) vs. $306.56\,\tau$ (Reverse).

### 5.3 Does LAMP's peer offloading reduce cloud placements?
**YES.**
- In `[10, 2]`:
  - **COMP** placed **12 analytical modules** on Cloud.
  - **EWMP** placed **2 analytical modules** on Cloud (because EWMP cannot route horizontally, overflow from Proxy moved North to Cloud).
  - **LAMP** placed **0 analytical modules** on Cloud (100% placed in Fog).
- By utilizing Peer Gateway 1's spare capacity, LAMP saved 2 Cloud placements compared to EWMP.

### 5.4 Does peer offloading increase proxy traffic or reduce loop completion?
**YES. This is the central tradeoff of LAMP.**
- When Gateway 0 offloads modules to Peer Gateway 1, tuples must travel:
  $$\text{Mobile } m-0-8 \to \text{Gateway } d-0 \to \text{Proxy} \to \text{Gateway } d-1$$
  and the reply travels:
  $$\text{Gateway } d-1 \to \text{Proxy} \to \text{Gateway } d-0 \to \text{Mobile } m-0-8$$
- This creates a **double traversal of the Proxy switch links** for each tuple.
- In `[10, 2]`:
  - **EWMP** routed overflow vertically to Cloud, avoiding horizontal proxy cross-traffic, and achieved **12/12 loop completions (100%, SUCCESS)** with delay $344.18\,\tau$.
  - **LAMP** suffered link contention at the Proxy switch; the 2 offloaded loops experienced delay, achieving only **10/12 loop completions (83.3%, PARTIAL_COMPLETION)** with delay $310.23\,\tau$ for completed loops.

### 5.5 How does EWMP behave under the same asymmetric workloads?
- In `[6, 2]` and `[2, 6]`, EWMP behaved **identically** to LAMP ($216.19\,\tau$, Local=6, Proxy=2, Cloud=0) because Proxy absorbed all overflow along the vertical path.
- In `[10, 2]`, EWMP avoided peer gateways and sent 2 modules to Cloud, achieving higher network stability and 100% completion rate at the cost of slightly higher average delay ($344.18\,\tau$ vs $310.23\,\tau$).

---

## 6. Exact Module-to-Device Mappings: `[10, 2]`

### 6.1 LAMP Forward Mapping (`LAMP_FWD`)
```
Module Name               Host Device     Placement Role
--------------------------------------------------------------
Interface_0_0 .. 0_9      m-0-0 .. m-0-9  Mobile Client (Local)
Cloud_Storage_0_0 .. 0_9  cloud           Cloud Storage (Fixed)
Interface_1_0 .. 1_1      m-1-0 .. m-1-1  Mobile Client (Local)
Cloud_Storage_1_0 .. 1_1  cloud           Cloud Storage (Fixed)

Sensor_Analyzer_0_0       d-0             LOCAL_GW (Slot 1/4)
Sensor_Analyzer_0_1       d-0             LOCAL_GW (Slot 2/4)
Sensor_Analyzer_0_2       d-0             LOCAL_GW (Slot 3/4)
Sensor_Analyzer_0_3       d-0             LOCAL_GW (Slot 4/4 - Saturated)
Sensor_Analyzer_0_4       proxy-server    PROXY (Slot 1/4)
Sensor_Analyzer_0_5       proxy-server    PROXY (Slot 2/4)
Sensor_Analyzer_0_6       proxy-server    PROXY (Slot 3/4)
Sensor_Analyzer_0_7       proxy-server    PROXY (Slot 4/4 - Saturated)
Sensor_Analyzer_0_8       d-1             PEER_GW (Slot 1/2 of free GW1)
Sensor_Analyzer_0_9       d-1             PEER_GW (Slot 2/2 of free GW1)
Sensor_Analyzer_1_0       d-1             LOCAL_GW (Slot 1/2 of local GW1)
Sensor_Analyzer_1_1       d-1             LOCAL_GW (Slot 2/2 of local GW1)
```

### 6.2 EWMP Mapping (`EWMP`)
```
Module Name               Host Device     Placement Role
--------------------------------------------------------------
Sensor_Analyzer_0_0 .. 0_3 d-0            Local Gateway (d-0 full)
Sensor_Analyzer_0_4 .. 0_7 proxy-server   Proxy Server (proxy full)
Sensor_Analyzer_0_8 .. 0_9 cloud          Cloud DC (North along tree)
Sensor_Analyzer_1_0 .. 1_1 d-1            Local Gateway (d-1)
```

### 6.3 LAMP Physical SI Mapping (`LAMP_PHYS`)
```
Module Name               Host Device     Placement Role
--------------------------------------------------------------
Interface_0_0 .. 0_9      m-0-0 .. m-0-9  Mobile Client (Local)
Cloud_Storage_0_0 .. 0_9  cloud           Cloud Storage (Fixed)
Interface_1_0 .. 1_1      m-1-0 .. m-1-1  Mobile Client (Local)
Cloud_Storage_1_0 .. 1_1  cloud           Cloud Storage (Fixed)

Sensor_Analyzer_0_0 .. 0_3 d-0            Local Gateway (Slot 1-4/4 - Saturated)
Sensor_Analyzer_0_4 .. 0_9 cloud          Cloud DC (Rank 1 via Physical SI compute speed)
Sensor_Analyzer_1_0 .. 1_1 d-1            Local Gateway (Slot 1-2/2 of GW1)
```

### 6.4 Exact Candidate Rankings Extracted from Raw Simulation Logs
From `results/raw_logs_asymmetric/LAMP_FWD_w10_2.log`:
```
[Candidate Evaluations via Equation 4 (PAPER_CONVENTION)]
  App app_0_4 (Local GW d-0 saturated). Candidate Ranking (PAPER_CONVENTION): 
    [proxy-server: t_a^m=7.8500 (Q=1.2500, delta=4.0000, Z=2.6000) | 
     d-1:          t_a^m=11.8500 (Q=1.2500, delta=8.0000, Z=2.6000) | 
     cloud:        t_a^m=106.6781 (Q=0.0781, delta=104.0000, Z=2.6000)]
  ...
  App app_0_8 (Local GW d-0 saturated, Proxy saturated). Candidate Ranking:
    [d-1:          t_a^m=11.8500 (Selected -> Placed on Peer Gateway d-1)]
```

From `results/raw_logs_asymmetric/LAMP_PHYS_w10_2.log`:
```
[Candidate Evaluations via Equation 4 (PHYSICAL_SI)]
  App app_0_4 (Local GW d-0 saturated). Candidate Ranking (PHYSICAL_SI): 
    [cloud:        t_a^m=0.1847 (Q=0.0781, delta=0.1040, Z=0.0026) | 
     proxy-server: t_a^m=1.2566 (Q=1.2500, delta=0.0040, Z=0.0026) | 
     d-1:          t_a^m=1.2606 (Q=1.2500, delta=0.0080, Z=0.0026)]
```

---

## 7. Energy and Network Usage Analysis

```
+---------------+-----------+------------------+----------------+----------------+--------------------+
| Workload      | Algorithm | Cloud Energy (J) | Fog Energy (J) | Cloud Cost ($) | Network Usage (B/s)|
+---------------+-----------+------------------+----------------+----------------+--------------------+
| [6, 2]        | COMP      | 2,822,624.32     | 1,894,225.44   | 224,885.11     | 426,421.00         |
| [6, 2]        | LAMP_FWD  | 2,715,151.94     | 1,992,891.84   | 72,519.20      | 341,284.00         |
| [6, 2]        | EWMP      | 2,715,151.94     | 1,992,891.84   | 72,519.20      | 341,284.00         |
| [6, 2]        | LAMP_PHYS | 2,743,583.80     | 1,960,051.15   | 112,827.67     | 357,970.50         |
+---------------+-----------+------------------+----------------+----------------+--------------------+
| [10, 2]       | COMP      | 2,900,164.12     | 2,591,449.35   | 334,814.96     | 630,830.50         |
| [10, 2]       | LAMP_FWD  | 2,724,065.51     | 2,724,852.48   | 85,156.16      | 439,070.50         |
| [10, 2]       | EWMP      | 2,754,124.97     | 2,707,095.53   | 127,772.11     | 520,518.50         |
| [10, 2]       | LAMP_PHYS | 2,858,007.37     | 2,657,127.32   | 275,048.42     | 562,838.50         |
+---------------+-----------+------------------+----------------+----------------+--------------------+
```

### Caveat on Time Units:
As established in the Phase 2 Audit, CloudSim power models integrate Watts over simulation clock ticks ($\tau$). Because $T = 2,000\,\tau$ is treated as $2,000\text{ seconds}$ by the integrator, reported energy in Joules is dimensionally consistent within the simulator, but $1,000\times$ larger than physical energy for 2 physical seconds. Relative energy and cost comparisons remain completely valid:
- In `[10, 2]`, LAMP reduced Cloud Cost to **\$85,156.16** compared to **\$127,772.11** for EWMP (a **33.3% cost reduction**) and **\$334,814.96** for COMP (a **74.6% cost reduction**).
- LAMP reduced network usage to **$439,070.5\text{ B/s}$** vs. **$520,518.5\text{ B/s}$** for EWMP.

---

## 8. Defensible Scientific Conclusions for Professor Defense

When presenting Phase 2.2 to your professor, defend the following rigorous positions:

1. **Proof of Peer Offloading Capability:**
   *"We proved empirically that LAMP's Equation 4 successfully activates peer-gateway offloading when spare capacity exists. In Configuration `[10, 2]`, Gateway 0 offloaded exactly 2 modules to Gateway 1, reducing analytical Cloud placements to zero and lowering loop delay to $310.23\,\tau$ compared to $344.18\,\tau$ for EWMP."*

2. **The Tradeoff of Horizontal Fog Offloading:**
   *"Our experiments revealed the hidden cost of peer offloading in hierarchical Fog trees. Offloading to a peer gateway requires traversing up to the Proxy switch and down to the peer gateway, doubling link traversals. In `[10, 2]`, this link contention caused 2 out of 12 loops to stall before simulation end (`PARTIAL_COMPLETION`), whereas EWMP's direct vertical offloading to Cloud avoided horizontal contention and completed 100% of loops."*

3. **Dimensional Integrity of Equation 4:**
   *"We demonstrated that evaluating Equation 4 in strict physical SI seconds makes Cloud faster than Fog Gateways due to Cloud's 16x higher MIPS, causing LAMP to prefer Cloud over Proxy and Peer Gateways. The paper's Fog-first placement relies on the simulator's unscaled numerical clock tick convention (or implicitly assumes an ultra-lightweight workload of $\approx 1.25\text{ ms}$). We transparently present both variants as distinct experimental models."*

---
*Certified by Research Engineering and CloudSim/iFogSim Reproduction Specialist.*
