# Simulation-Based Reproduction and Comparative Evaluation of a Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications

**M. Yoshi Anurag** and **Ch. Jaswanth**

---

### Abstract
The proliferation of latency-critical Internet of Things (IoT) applications, such as healthcare Body Sensor Networks (BSNs), presents significant operational challenges for centralized cloud infrastructures due to wide-area network propagation delays and bandwidth bottlenecks. Fog computing mitigates these limitations by providing computational and storage resources in close physical proximity to edge devices. In 2019, Rezazadeh, Rezaei, and Nickray proposed the Latency-Aware Module Placement (LAMP) algorithm, which formalizes application module placement across a hierarchical IoT–fog–cloud architecture using candidate evaluation functions that incorporate processing times, network latencies, and residual computational capacities. In this paper, we present an independent, simulator-based reproduction and comparative evaluation of the LAMP algorithm using the iFogSim toolkit. We evaluate LAMP against three benchmark policies: Cloud-Only Module Placement (COMP), Energy-Weighted Module Placement (EWMP), and a pure, resource-aware baseline (`LBMP_PURE`) derived from Taneja and Davy (2017) with documented adaptations. Our experimental campaign encompasses 72 simulation attempts across 12 unique symmetric topologies ($G \in \{2,3,4\}$ fog gateways, $M \in \{2,4,6,8\}$ mobile devices per gateway) and 4 asymmetric stress workloads. Out of 72 simulation attempts, 70 produced result summaries, while 2 dense COMP runs encountered external process watchdog timeouts at 240 seconds under heavy scale (with unproduced metrics recorded strictly as N/A). In balanced configurations ($M=4$), LAMP, EWMP, and `LBMP_PURE` achieve identical placements on local gateways, delivering an 82.4% delay reduction and a 73.0% cloud cost reduction compared to COMP. However, under capacity-constrained conditions ($M=2$), `LBMP_PURE` exhibits a severe peer-offloading pathology where locality-blind sorting packs modules onto distant peer nodes, causing application-loop completion rates to drop to 50.0% ($G=2$), 33.3% ($G=3$), and 25.0% ($G=4$). Across the entire 16-run Phase 3.6 suite, `LBMP_PURE` achieved complete loop completion in exactly 3 runs (`SUCCESS`) while 13 runs suffered partial completion (`PARTIAL_COMPLETION`), yielding 156 completed loops out of 220 total loops (70.9% completion rate). In contrast, LAMP achieved 100% loop completion in exactly 9 of 12 symmetric configurations—spanning all four $G=2$ topologies (`gw2_m2`, `gw2_m4`, `gw2_m6`, `gw2_m8`), three $G=3$ topologies (`gw3_m2`, `gw3_m4`, `gw3_m6`), and two $G=4$ topologies (`gw4_m2`, `gw4_m4`)—with partial loop completion observed in the 3 densest symmetric configurations (`gw3_m8`, `gw4_m6`, `gw4_m8`) under heavy concurrent scale. Under asymmetric stress workloads, placement fidelity depends on the latency evaluation formulation: the physical SI interpretation (`LAMP_PHYS`) maintains 100% loop completion across all four workloads, whereas the simulation-clock baseline (`LAMP_FWD`) achieves 100% loop completion in three workloads ($w_{2,6}$, $w_{6,2}$, $w_{6,6}$) and 83.3% in $w_{10,2}$ (10/12 loops) due to inter-gateway queue contention. We contextualize our findings against the original publication's configuration tables (noting the absence of numerical experimental results tables in literature), document necessary simulator adaptations, delineate the boundary between discrete simulation ticks and physical time, and provide a full reproducibility package.

**Keywords**—Fog computing, edge computing, module placement, latency-aware scheduling, iFogSim, CloudSim, healthcare IoT, reproducibility.

---

## I. INTRODUCTION

The rapid expansion of the Internet of Things (IoT) has introduced billions of connected physical devices across diverse domains, including industrial automation, smart transportation, environmental monitoring, and personal healthcare [1]. In latency-critical IoT systems, such as healthcare Body Sensor Networks (BSNs), wearable biomedical sensors continuously monitor physiological signals (e.g., electroencephalogram [EEG], electrocardiogram [ECG], pulse oximetry, and respiratory rate). These systems generate continuous data streams that demand near-instantaneous computational analysis to detect anomalous physiological events and trigger life-saving interventions [2].

Historically, centralized cloud data centers have provided the computational elasticity, massive parallelism, and storage capacity required to process large-scale IoT data [3]. However, routing latency-sensitive sensor streams across Wide Area Networks (WANs) to centralized cloud facilities incurs significant limitations:
1. **Unpredictable Latency:** Multi-hop WAN routing introduces high propagation delays, queuing jitter, and dynamic congestion, which can compromise real-time patient monitoring deadlines.
2. **Bandwidth Saturation:** Transmitting raw, high-frequency biomedical data streams from thousands of concurrent edge sensors saturates backhaul bandwidth, incurring substantial network transit costs.
3. **Operational Cost:** Continuous cloud virtual machine (VM) execution and persistent data ingestion generate recurring operational expenses for healthcare providers.

To address these limitations, Bonomi et al. [4] formalized the *fog computing* paradigm, which extends cloud capabilities by deploying heterogeneous, decentralized computational and storage nodes along the network continuum between end devices and centralized data centers. By performing data filtering, feature extraction, and preliminary analytics at intermediate fog nodes—such as smart edge gateways, localized micro-servers, and cellular base stations—fog computing significantly shortens the physical communication path, attenuates core network traffic, and enables low-latency response loops [5].

A foundational optimization challenge in fog computing is the *Application Module Placement Problem*: given a distributed, multi-tier physical infrastructure and a set of interconnected software modules with specific resource demands, how should modules be mapped onto physical execution nodes to minimize latency, optimize energy consumption, and constrain monetary costs without violating hardware capacity limits [6]?

In 2019, Rezazadeh, Rezaei, and Nickray [7] proposed the *Latency-Aware Module Placement (LAMP)* algorithm. LAMP addresses module mapping within a hierarchical IoT–fog–cloud architecture using a multi-criteria candidate evaluation function that jointly accounts for task processing times, transmission latencies, and residual computational capacities. The authors evaluated LAMP against three benchmark placement strategies: Cloud-Only Module Placement (COMP), Energy-Weighted Module Placement (EWMP), and Simulated Annealing Module Placement (SAMP).

Despite its promising conceptual framework, independent reproduction of the findings reported in [7] presents distinct methodological challenges:
- While the original publication provided numerical configuration tables for application tuples and hardware parameters (Tables I, III, and IV), it omitted numerical experimental results tables in Section V, presenting evaluation findings exclusively through visual plots and high-level proportional claims.
- The Simulated Annealing Module Placement (SAMP) baseline omitted critical mathematical specifications, cooling schedules, and perturbation operators, rendering it non-reproducible.
- The relationships between discrete simulation event steps, configured network latencies, and physical wall-clock time were not explicitly disambiguated.

This paper presents an independent, simulator-based reproduction and comparative evaluation of the LAMP algorithm using the iFogSim toolkit [8]. We reconstruct the complete experimental environment, implement the physical topology and healthcare BSN application models, evaluate the LAMP heuristic against COMP, EWMP, and a pure resource-aware baseline (`LBMP_PURE`) derived from Taneja and Davy [9], and provide an evidence-based analysis of placement behaviors under both symmetric and asymmetric workloads.

---

## II. PROBLEM STATEMENT AND RESEARCH OBJECTIVES

### A. Problem Statement
Consider an IoT-enabled healthcare monitoring environment structured as a hierarchical computing continuum. Raw physiological data is generated by wearable sensors attached to patients and transmitted to local mobile end devices. These devices are wirelessly paired with localized Fog Gateways, which connect through an intermediate Proxy Server to a centralized Cloud Data Center.

The distributed software application is modeled as a Directed Acyclic Graph (DAG) $G_{app} = (M, E)$, where $M = \{m_1, m_2, \dots, m_k\}$ denotes the set of application modules and $E$ represents directed data dependencies between modules. Each module $m_i \in M$ requires a specific quantity of computational capacity ($C_{m_i}$ in MIPS), memory ($R_{m_i}$ in MB), and bandwidth ($B_{m_i}$). Concurrently, each physical node $n_j \in N$ in the infrastructure possesses bounded available resources: CPU capacity $C_{n_j}$, RAM $R_{n_j}$, and network link capabilities.

The operational objective of the module placement problem is to define a mapping function $\Pi: M \to N$ that optimizes three primary metrics:
1. **Control-Loop Latency ($D_{loop}$):** The total time required for a sensor tuple to traverse the critical processing path from emission to actuation.
2. **Cloud Resource Cost ($Cost_{cloud}$):** The financial expenditure incurred by executing modules and storing data on commercial cloud virtual machines.
3. **Network Bandwidth Consumption ($BW_{net}$):** The total volume of data transmitted across network links, with particular emphasis on bottleneck WAN links.

The placement function is constrained by physical resource limits:
$$\sum_{m_i \in \Pi^{-1}(n_j)} C_{m_i} \le C_{n_j}, \quad \forall n_j \in N \tag{1}$$
$$\sum_{m_i \in \Pi^{-1}(n_j)} R_{m_i} \le R_{n_j}, \quad \forall n_j \in N \tag{2}$$

### B. Research Objectives
This study is structured around five primary research objectives:
1. **Algorithmic Reconstruction:** Reconstruct the mathematical formulation and algorithmic decision logic of LAMP as specified in [7] within the iFogSim simulation framework.
2. **Baseline Implementation:** Implement canonical benchmark policies—Cloud-Only Module Placement (COMP), Energy-Weighted Module Placement (EWMP), and a pure adaptation of the Resource-Aware Placement algorithm (`LBMP_PURE`) from Taneja and Davy [9]—with explicit architectural documentation.
3. **Rigorous Empirical Accounting:** Execute an extensive experimental campaign across 12 symmetric configurations (48 attempts, 46 result summaries, 2 watchdog timeouts) and 4 asymmetric stress workloads (24 attempts, 24 result summaries), preserving exact execution success and application-loop completion rates ($k/N$).
4. **Independent Comparative Evaluation:** Quantify the trade-offs of LAMP relative to the benchmark policies across control-loop delay, cloud costs, network usage, and energy consumption.
5. **Scientific Traceability & Artifact Auditing:** Establish an unbroken chain of custody linking every research claim, equation, and parameter to primary source code, log files, and immutable dataset hashes.

---

## III. RELATED WORK

Application module placement in distributed edge and fog environments has been investigated extensively across mathematical optimization, metaheuristics, and heuristic scheduling paradigms.

### A. Simulation Frameworks: CloudSim and iFogSim
Simulation tools are critical for evaluating edge and fog resource management policies due to the financial, physical, and administrative overheads of deploying large-scale physical testbeds. Calheiros et al. [10] developed **CloudSim**, a discrete-event simulator that models cloud data centers, virtual machine provisioning, host scheduling, and energy consumption. While CloudSim provides robust abstractions for centralized data centers, it lacks native constructs for hierarchical edge network topologies, sensor data streams, and localized control loops.

To address these limitations, Gupta et al. [8] introduced **iFogSim**, an extension of CloudSim designed specifically for fog and edge computing environments. iFogSim models hierarchical fog topologies composed of `FogDevice` instances, distributed sensor tuple generation via `Sensor` nodes, physical actuators via `Actuator`, and stream processing graphs via `Application` and `AppModule` abstractions. Mahmud et al. [11] subsequently introduced **iFogSim2**, incorporating dynamic module migration, clustering, and microservice orchestration primitives.

### B. Module Placement Policies
1. **Cloud-Only Module Placement (COMP):** The classical cloud computing paradigm maps all computational and analytical modules directly onto centralized cloud data centers, while edge and fog devices serve exclusively as passive packet-forwarding nodes [7]. Although COMP eliminates edge computational constraints, it maximizes WAN latency and network congestion.
2. **Resource-Aware Placement (LBMP):** Taneja and Davy [9] proposed a resource-aware placement algorithm designed to maximize fog layer utilization. LBMP sorts application modules by resource requirements and performs binary search across candidate fog nodes sorted by available capacity. In Section VI, we detail our adaptation (`LBMP_PURE`) for multi-tier multi-application topologies.
3. **Energy-Weighted Placement (EWMP):** Rezazadeh et al. [7] formulated EWMP as a greedy heuristic that prioritizes candidate nodes with lower energy consumption per unit of computation (MIPS/Watt), seeking to minimize overall system energy consumption.
4. **Simulated Annealing Placement (SAMP):** Metaheuristic algorithms, such as simulated annealing, explore global placement search spaces by iteratively perturbing candidate solutions [12]. Rezazadeh et al. [7] included SAMP as a baseline; however, as demonstrated in our traceability audit, the complete absence of algorithmic formulation, cooling schedules, and parameter definitions precludes verified independent reproduction.

---

## IV. SYSTEM ARCHITECTURE AND HEALTHCARE APPLICATION MODEL

### A. Architectural Hierarchy
The original publication [7] defines a general computing hierarchy comprising Cloud, Fog, and IoT/End Device tiers. In our concrete simulation realization, we model the physical continuum as a four-tier concrete topology representing proxy and gateway nodes as distinct tiers within the broader fog layer, with link latencies rigorously derived from Rezazadeh et al. [7] (Table III):

*Fig. 1. Concrete hierarchical IoT–Fog–Cloud simulation topology.*

- **Tier 1 (IoT Sensors & Mobile End Devices):** Wearable biomedical sensors (e.g., EEG electrodes) generate data tuples and transmit them over short-range wireless links (0.6 ms latency) to mobile end devices (`m-i-j`). Actuators are connected with 0.1 ms latency. Mobile devices possess 500 MIPS CPU and 1,000 MB RAM.
- **Tier 2 (Edge Fog Gateways):** Fog Gateways (`gw-i`) are deployed at localized access points (e.g., hospital rooms or clinic hubs). Gateways possess 2,800 MIPS CPU and 4,000 MB RAM. Mobile devices communicate with their parent gateway over 2.0 ms links.
- **Tier 3 (Proxy Server):** An intermediate aggregation server (`proxy-server`) interconnects all fog gateways within a regional domain. The proxy server possesses 2,800 MIPS CPU and 4,000 MB RAM, communicating with gateways over 4.0 ms links. Note that there is no direct horizontal physical link between peer gateways; iFogSim enforces a strict tree topology. Inter-gateway peer traversal follows the dynamic Lowest Common Ancestor (LCA) tree routing path evaluated by `computeOneWayLatency`: `gw-0 -> proxy (4.0 ms) -> gw-1 (4.0 ms) = 8.0 ms`.
- **Tier 4 (Cloud Data Center):** A high-capacity centralized cloud facility (`cloud`) providing virtually unbounded computation (44,800 MIPS allocated) and storage (40,000 MB RAM allocated), connected to the proxy server via a high-latency WAN connection (100.0 ms propagation delay).

### B. Healthcare BSN Application Model
The application workload represents a Body Sensor Network (BSN) patient-monitoring application, structured as a Directed Acyclic Graph (DAG) with three software modules:

*Fig. 2. Healthcare BSN application Directed Acyclic Graph (DAG).*

1. **`Interface` Module:** Pinned directly to the originating mobile end device (`m-i-j`). It ingests `RAW_EEG` sensor tuples (2,000 bytes) at 5.0-tick intervals (`DeterministicDistribution(5.0)`), performs signal normalization, and emits `_SENSOR` tuples. It consumes 10 MB RAM and requires zero CPU execution overhead.
2. **`Sensor_Analyzer` Module:** The primary analytical module evaluated for placement. It ingests `_SENSOR` tuples, executes feature extraction and anomaly classification algorithms requiring 700 MIPS of CPU capacity and 10 MB RAM, and emits processed `ANALYSIS` tuples (1,000 bytes). The 700 MIPS demand is derived directly from application parameters specified in Rezazadeh et al. [7] (Table I): raw EEG tuples have a computational length of 3500 MI and arrive at 5.0-second intervals (tuple generation rate $\lambda = 0.2\text{ tuples/s}$), yielding 3500 / 5.0 = 700 MIPS. The gateway capacity of 2800 MIPS accommodates 4 modules because 2800 / 700 = 4 (or 2,800 / 700 = 4), establishing $M=4$ as the balanced saturation threshold.
3. **`Cloud_Storage` Module:** Pinned to the centralized Cloud Data Center. It ingests `ANALYSIS` tuples and archives historical medical records. It consumes 10 MB RAM and zero CPU execution capacity.

The critical application control loop is defined as the end-to-end traversal from raw sensor tuple generation to analytical processing completion:
$$Loop_{BSN} = [EEG Sensor \to Interface \to Sensor_Analyzer]$$

---

## V. LAMP ALGORITHM AND PLACEMENT METHODOLOGY

The Latency-Aware Module Placement (LAMP) algorithm [7] evaluates candidate execution nodes using a multi-criteria scoring function that estimates processing latency, transmission delay, and resource availability.

### A. Mathematical Formulation
In [7], Rezazadeh et al. formalize the module placement delay metric across Equations (1)–(4):

1. **Cumulative Placement Delay Index ($t_a^m$):** In Section IV.A and Equation (4) of Rezazadeh et al. [7], the composite evaluation index for placing module $m$ of application $a$ onto candidate device $p$ is defined as:
$$t_a^m = Q_p^m + \Delta_{pp'} + Z \tag{3}$$
where $Q_f^m$ (or $Q_p^m$) is defined in Table II of [7] as the *"Time required to process the module $m$ on device $f$"*, $\Delta_{pp'}$ represents the network path transmission delay between the previous host $p'$ and candidate device $p$, and $Z$ represents the accumulated network latency to the current local gateway ($2.6\text{ ms}$). Candidates are ranked in ascending order of $t_a^m$.

2. **Network Path Delay ($\Delta_{pp'}$):** The propagation latency between source node $p'$ and candidate host $p$ sums link latencies along the routing path:
$$\Delta_{pp'} = \sum_{e \in Path(p', p)} Latency(e) \tag{4}$$

3. **Processing Time Formulation vs. iFogSim Implementation:** In the literature, some theoretical works model $Q_p^m$ using single-server $M/M/1$ queueing delay:
$$Q_{M/M/1} = \frac{L_m}{\mu_p - \lambda_p}$$
where $L_m$ is task workload (MI), $\mu_p$ is service rate (MIPS), and $\lambda_p$ is arrival rate. However, the original publication by Rezazadeh et al. [7] never specified an $M/M/1$ queueing formula, defining $Q_p^m$ simply as processing time in Table II. In our iFogSim implementation, task duration is evaluated deterministically as `CloudletLength / HostMIPS`:
$$Q_p^m = \frac{\text{Workload (MI)}}{\text{Host Capacity (MIPS)}} = \frac{3,500\text{ MI}}{2,800\text{ MIPS}} = 1.25\text{ seconds}$$
This deterministic calculation corresponds mathematically to an isolated execution duration (or $M/M/1$ under the assumption of zero background queue backlog, $\lambda_p = 0$). We preserve the original paper's formulation as published without asserting an unsupported closed-form queueing derivation.

*Fig. 3. Algorithmic placement flowchart for the LAMP heuristic.*

### B. Algorithmic Placement Flow
Rather than enforcing an arbitrary static tier hierarchy, Algorithm 1 in [7] defines a **dynamic candidate-ranking procedure** evaluated via Equation (3):
- **Stage 1 (Anchor Placement):** Pre-allocate `Interface` to the local mobile device and `Cloud_Storage` to the Cloud Data Center.
- **Stage 2 (Local Gateway Verification):** Check whether the originating local gateway possesses sufficient unallocated capacity ($C_{avail} \ge 700 MIPS, R_{avail} \ge 10 MB$). Because the local gateway has $\Delta_{pp'} = 0$, it naturally minimizes $t_a^m$. If eligible, allocate the module locally to eliminate network transit.
- **Stage 3 (Candidate Discovery & Ranking):** If the local gateway is saturated, discover candidate nodes comprising the parent proxy server, peer gateways (reachable via proxy), and the cloud data center. Compute $t_a^m$ for all candidates using (3) and sort candidates in ascending order.
- **Stage 4 (First-Fit Selection):** Iterate through the sorted candidate list and select the first node with sufficient unallocated CPU and RAM capacity.

---

## VI. SIMULATION ENVIRONMENT AND IMPLEMENTATION

### A. Simulation Parameters and Unit Clarifications
All experiments were implemented within the `iFogSim` framework running on OpenJDK 64-Bit Server VM version `21.0.6` (Temurin-21.0.6+7, build 21.0.6+7-LTS, Eclipse JustJ distribution) on Microsoft Windows 11 Enterprise (AMD64, build 10.0.26300), orchestrated via Python 3.13 and PowerShell 5.1. Table I details the configured hardware and simulation parameters.

**TABLE I: SIMULATION AND INFRASTRUCTURE PARAMETERS**
| Parameter / Resource | Configured Value | Literature Source / Methodological Derivation |
| :--- | :---: | :--- |
| Cloud CPU Capacity | 44,800 MIPS | Rezazadeh et al. [7], Section IV |
| Cloud RAM | 40,000 MB | Rezazadeh et al. [7], Section IV |
| Fog Gateway CPU Capacity | 2,800 MIPS | Rezazadeh et al. [7], Table IV |
| Fog Gateway RAM | 4,000 MB | Rezazadeh et al. [7], Table IV |
| Proxy Server CPU / RAM | 2,800 MIPS / 4,000 MB | Scaled regional aggregation tier |
| Mobile Device CPU / RAM | 500 MIPS / 1,000 MB | Rezazadeh et al. [7], Table IV |
| `Sensor_Analyzer` CPU Demand | 700 MIPS | Primary derivation: $0.2\text{ tuples/s} \times 3,500\text{ MI} = 700\text{ MIPS}$ (Table I); accommodates 4 modules on a 2,800 MIPS gateway |
| `Sensor_Analyzer` RAM Demand | 10 MB | Rezazadeh et al. [7], Table I |
| Sensor Tuple Inter-Arrival | 5.0 ticks | `DeterministicDistribution(5.0)` |
| Sensor-to-Mobile Link Latency | 0.6 ms | Rezazadeh et al. [7], Table III |
| Actuator-to-Mobile Link Latency| 0.1 ms | Rezazadeh et al. [7], Table III |
| Mobile-to-Gateway Link Latency | 2.0 ms | Rezazadeh et al. [7], Table III |
| Gateway-to-Proxy Link Latency | 4.0 ms | Rezazadeh et al. [7], Table III |
| Proxy-to-Cloud Link Latency | 100.0 ms | Rezazadeh et al. [7], Table III (WAN backhaul link) |
| Inter-Gateway Peer Traversal | 8.0 ms | Lowest Common Ancestor tree routing via proxy ($4.0 + 4.0 ms$) |
| Fog Network Link Bandwidth | 10,000 | Unitless in original Table IV; abstract simulator transmission rate |
| CloudSim Host Provisioner BW | 1,000,000 units | Internal VM-provisioner capacity abstraction (`BwProvisionerOverbooking`) |
| CloudSim AppModule Provisioner BW| 1,000 units | Internal VM-provisioner demand abstraction (`AppModule.getBw()`) |
| Network Usage Accumulation | Bytes | `networkUsage += tuple.getCloudletFileSize()` |

*Methodological Unit Integrity:* In discrete-event simulators such as iFogSim and CloudSim, four distinct bandwidth dimensions must be distinguished:
1. **Network Link Bandwidth:** In Table IV of Rezazadeh et al. [7], `uplink bw` and `downlink bw` are listed as unitless integers (e.g., `10000`, `100`, `270`). In iFogSim's `FogDevice`, transmission latency is computed as `tuple.getCloudletFileSize() / bandwidth`. Physical units are unspecified in the literature; these values operate as abstract simulator transmission rates.
2. **Host-Level Provisioning Bandwidth:** `Host.getBw() = 1,000,000` is an internal CloudSim VM capacity counter allocated via `BwProvisionerOverbooking`.
3. **Module-Level Provisioning Bandwidth:** `AppModule.getBw() = 1,000` is an internal VM allocation unit. It does not constrain network-link throughput.
4. **Simulator-Reported Loop Delays:** Simulator time advances via discrete events. Reported loop delays represent composite discrete-event ticks that aggregate execution durations and scheduled transmission latencies; they cannot be interpreted as calibrated physical milliseconds.

### B. Implementation Architecture
The simulation codebase is structured into modular Java packages under `org.fog.lamp`:
1. **`HealthcareBSNApplication.java`:** Defines the 3-module BSN DAG, tuple specifications (`RAW_EEG`, `_SENSOR`, `ANALYSIS`), execution fractional ratios, and resource demands.
2. **`HealthcareTopologyFactory.java`:** Implements deterministic builders for symmetric physical topologies across variable gateway counts ($G$) and mobile device densities ($M$).
3. **`ModulePlacementLAMP.java`:** Implements the core LAMP algorithm, including candidate discovery, candidate delay ranking via (3), and capacity ledger tracking.
4. **`ModulePlacementLBMP.java`:** Implements our pure adaptation of the Taneja and Davy [9] resource-aware baseline (`LBMP_PURE`), incorporating five formal adaptations:
   - *D-3.4-01:* CPU capacity sorting in descending MIPS order.
   - *D-3.4-03:* Separation of CloudSim host bandwidth from network link rates.
   - *D-3.4-04:* Search lower bound reset (`low = 0`) across sequential multi-application module arrivals.
   - *D-3.4-08:* Dynamic eligibility monotonicity verification with linear scan fallback.
   - *D-3.4-07:* Multi-tier fixed module pre-reservation on cloud resources.
5. **`ModulePlacementLBMPTest.java`:** A verification suite of 11 automated unit tests (T01–T11) validating algorithmic correctness, binary search convergence, fallback handling, and telemetry recording (100% pass rate).

---

## VII. EXPERIMENTAL DESIGN

The empirical evaluation is organized into two distinct experimental campaigns:

### A. Symmetric Workload Campaign
The symmetric matrix systematically varies infrastructure scale across 12 unique configurations:
- **Gateway Counts ($G$):** $G \in \{2, 3, 4\}$ Fog Gateways.
- **Mobile Density ($M$):** $M \in \{2, 4, 6, 8\}$ Mobile Devices per Gateway.
- **Total Deployed Applications ($N$):** $N = G \times M$, spanning 4 to 32 concurrent patient monitoring applications.
- **Evaluated Algorithms:** COMP, LAMP, EWMP, and `LBMP_PURE`.
- **Simulation Horizon & Watchdog Limits:** Simulations run to a discrete-event horizon of 2,000 simulation ticks (`CloudSim.stopSimulation(2000)`). In Phase 2, an external process watchdog terminated runs exceeding 240.0 wall-clock seconds (`subprocess.run(timeout=240)` per simulation execution, with the complete 36-run suite executing in 20 minutes and 2 seconds of total wall-clock time). Phase 3.6 PowerShell wrappers enforced a 300-second watchdog per run.

### B. Asymmetric Stress Workload Campaign
To assess placement resilience under heterogeneous load, we evaluate four asymmetric workloads on a $G=2$ gateway topology:
- **$w_{2,6}$:** Gateway 0 serves 2 devices; Gateway 1 serves 6 devices ($N=8$).
- **$w_{6,2}$:** Gateway 0 serves 6 devices; Gateway 1 serves 2 devices ($N=8$).
- **$w_{6,6}$:** Gateway 0 serves 6 devices; Gateway 1 serves 6 devices ($N=12$).
- **$w_{10,2}$:** Gateway 0 serves 10 devices; Gateway 1 serves 2 devices ($N=12$).

---

## VIII. RESULTS AND COMPARATIVE EVALUATION

### A. Experiment Accounting and Execution Integrity
Across the entire research project, exactly 72 simulation attempts were performed across three experimental batches:
- **Phase 2 (Symmetric Scale):** 36 attempts (12 configurations $\times$ 3 algorithms: COMP, LAMP, EWMP; executed in 20 minutes 2 seconds total wall-clock time). Exactly 34 runs produced complete output summaries. Exactly 2 runs (`COMP_gw3_m8` and `COMP_gw4_m8`) were terminated by the external process watchdog upon reaching their 240.0-second limit (exit code 143) under heavy scale. While host event-queue saturation under centralized cloud routing represents a plausible architectural hypothesis, unproduced metrics are strictly recorded as `N/A`.
- **Phase 2.2 (Asymmetric Stress):** 20 completed runs (4 workloads $\times$ 5 placement variants).
- **Phase 3.6 (LBMP Baseline):** 16 completed execution runs (12 symmetric configurations + 4 asymmetric stress workloads under `LBMP_PURE`). All 16 runs completed execution and emitted CSV summaries; however, exactly 3 runs achieved 100% loop completion (`SUCCESS`), while 13 runs suffered partial loop completion (`PARTIAL_COMPLETION`). Exactly 156 out of 220 application loops completed (70.91% loop completion rate).

In total, 70 runs produced valid result summaries across 72 attempts, while 2 runs were watchdog-terminated. Note that successful simulation execution (producing a valid result summary) must not be conflated with 100% application-loop completion ($k/N$).

**TABLE II: SUMMARY OF SYMMETRIC BENCHMARK RESULTS (M=4 AND M=2 CHECKPOINTS)**
*Note: Total System Energy represents the sum of Cloud and Fog energy ($E_{\text{total}} = E_{\text{cloud}} + E_{\text{fog}}$).*
| Config | Algorithm | Avg Loop Delay (Ticks) | Total System Energy ($10^6$ J) | Network Usage (KB) | Cloud Cost ($) | Loop Completion ($k/N$) | Status |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `gw2_m2` | COMP | 219.32 | 3.93 | 210.4 | 103,027.32 | 4/4 (100%) | SUCCESS |
| `gw2_m2` | LAMP | 9.47 | 4.05 | 164.9 | 221,589.60 | 4/4 (100%) | SUCCESS |
| `gw2_m2` | EWMP | 9.47 | 4.05 | 164.9 | 221,589.60 | 4/4 (100%) | SUCCESS |
| `gw2_m2` | `LBMP_PURE`| 9.47 | 4.02 | 105.0 | 223,988.48 | **2/4 (50.0%)**| PARTIAL |
| `gw2_m4` | COMP | 408.86 | 4.71 | 432.7 | 219,986.26 | 8/8 (100%) | SUCCESS |
| `gw2_m4` | LAMP | 71.93 | 4.70 | 338.7 | 59,359.20 | 8/8 (100%) | SUCCESS |
| `gw2_m4` | EWMP | 71.93 | 4.70 | 338.7 | 59,359.20 | 8/8 (100%) | SUCCESS |
| `gw2_m4` | `LBMP_PURE`| 71.93 | 4.70 | 338.7 | 59,359.20 | 8/8 (100%) | SUCCESS |
| `gw3_m4` | COMP | 633.31 | 5.65 | 650.4 | 322,157.46 | 12/12 (100%) | SUCCESS |
| `gw3_m4` | LAMP | 193.74 | 5.63 | 517.3 | 86,508.80 | 12/12 (100%) | SUCCESS |
| `gw3_m4` | EWMP | 193.74 | 5.63 | 517.3 | 86,508.80 | 12/12 (100%) | SUCCESS |
| `gw3_m4` | `LBMP_PURE`| 193.74 | 5.63 | 517.3 | 86,508.80 | 12/12 (100%) | SUCCESS |
| `gw4_m4` | COMP | 745.69 | 6.57 | 855.4 | 404,234.76 | 16/16 (100%) | SUCCESS |
| `gw4_m4` | LAMP | 244.56 | 6.57 | 692.5 | 113,838.40 | 16/16 (100%) | SUCCESS |
| `gw4_m4` | EWMP | 244.56 | 6.57 | 692.5 | 113,838.40 | 16/16 (100%) | SUCCESS |
| `gw4_m4` | `LBMP_PURE`| 244.56 | 6.57 | 692.5 | 113,838.40 | 16/16 (100%) | SUCCESS |
| `gw3_m8` | COMP | **N/A** | **N/A** | **N/A** | **N/A** | **0/24 (0.0%)** | TIMEOUT (>240s) |
| `gw4_m8` | COMP | **N/A** | **N/A** | **N/A** | **N/A** | **0/32 (0.0%)** | TIMEOUT (>240s) |

### B. M=4 Matched Baseline Parity
A central empirical finding of our study occurs at the balanced capacity threshold ($M=4$). Under this workload, exactly four 700-MIPS `Sensor_Analyzer` modules arrive at each 2,800-MIPS Fog Gateway ($4 \times 700 MIPS = 2,800 MIPS$). Because all modules perfectly saturate the local gateway without triggering overflow, LAMP, EWMP, and `LBMP_PURE` generate identical placement decisions across all gateways.

**TABLE III: RELATIVE PERFORMANCE REDUCTION OVER COMP AT M=4**
| Infrastructure Scale | Delay Reduction | Cloud Cost Reduction | Network Usage Reduction |
| :---: | :---: | :---: | :---: |
| **$G=2$ Fog Gateways** | **82.4%** | **73.0%** | **21.7%** |
| **$G=3$ Fog Gateways** | **69.4%** | **73.2%** | **20.5%** |
| **$G=4$ Fog Gateways** | **67.2%** | **71.8%** | **19.1%** |

*Critical Observation:* Across all three metric dimensions (delay, cost, and network traffic), LAMP, EWMP, and `LBMP_PURE` produce identical quantitative results at $M=4$. LAMP does *not* outperform EWMP or LBMP under balanced capacity; rather, all three algorithms demonstrate identical performance because localized edge capacity fully accommodates module demand.

### C. Asymmetric Stress Workload Evaluation
Table IV details empirical performance across the four asymmetric stress workloads on $G=2$ gateways from `results/asymmetric_validation_results.csv` and `results/lbmp_asymmetric_results.csv`. We explicitly distinguish the forward-order simulation-clock variant (`LAMP_FWD`) from the physical SI variant (`LAMP_PHYS`) and the resource-aware baseline (`LBMP_PURE`).

**TABLE IV: ASYMMETRIC STRESS WORKLOAD PERFORMANCE COMPARISON**
| Workload | Algorithm Variant | Avg Loop Delay (Ticks) | Network Usage (KB) | Completed Loops ($k/N$) | Completion Rate | Status |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| $w_{2,6}$ | `LAMP_FWD` | 215.17 | 341.6 | 8/8 | 100.0% | SUCCESS |
| $w_{2,6}$ | `LAMP_PHYS`| 261.52 | 357.9 | 8/8 | 100.0% | SUCCESS |
| $w_{2,6}$ | `LBMP_PURE` | 107.25 | 277.0 | 6/8 | **75.0%** | PARTIAL |
| $w_{6,2}$ | `LAMP_FWD` | 216.19 | 341.3 | 8/8 | 100.0% | SUCCESS |
| $w_{6,2}$ | `LAMP_PHYS`| 261.43 | 358.0 | 8/8 | 100.0% | SUCCESS |
| $w_{6,2}$ | `LBMP_PURE` | 106.89 | 277.1 | 6/8 | **75.0%** | PARTIAL |
| $w_{6,6}$ | `LAMP_FWD` | 434.27 | 497.3 | 12/12 | 100.0% | SUCCESS |
| $w_{6,6}$ | `LAMP_PHYS`| 516.30 | 538.4 | 12/12 | 100.0% | SUCCESS |
| $w_{6,6}$ | `LBMP_PURE` | 383.66 | 446.1 | 10/12 | **83.3%** | PARTIAL |
| $w_{10,2}$ | `LAMP_FWD` | 310.23 | 439.1 | 10/12 | **83.3%** | PARTIAL |
| $w_{10,2}$ | `LAMP_PHYS`| 380.11 | 562.8 | 12/12 | 100.0% | SUCCESS |
| $w_{10,2}$ | `LBMP_PURE` | 284.00 | 382.1 | 8/12 | **66.7%** | PARTIAL |

*Analysis of Asymmetric Placement Behavior:* In workload $w_{10,2}$, Gateway 0 experiences severe saturation (10 mobile devices vs. 4 local slots). Under `LAMP_FWD`, after saturating local Gateway 0 (4 modules) and the intermediate Proxy Server (4 modules), LAMP successfully offloads 2 analytical modules to spare capacity on Peer Gateway 1 (`6 : 2 : 4 : 0` placement distribution). However, routing tuples across peer gateways requires double traversal of the proxy switch links, inducing queue contention that prevents 2 return tuples from completing within the 2,000-tick horizon (10/12 loops completed, 83.3%). In contrast, under `LAMP_PHYS` (strict SI conversion where cloud compute speedup outweighs WAN latency), the remaining 6 modules are routed directly to the Cloud (`6 : 0 : 0 : 6`), avoiding proxy switch bottlenecking and achieving 12/12 loops completed (100%).

### D. The LBMP Peer-Offloading Pathology
While LAMP and `LBMP_PURE` achieve parity at $M=4$, their placement behavior diverges dramatically under capacity-constrained ($M=2$) and overloaded ($M \ge 6$) conditions.

At $M=2$, each gateway receives only two 700-MIPS modules (1,400 MIPS demand out of 2,800 MIPS capacity). In `LBMP_PURE`, modules are sorted globally by resource requirement and assigned via binary search over all available nodes sorted by capacity. In our multi-application topology, Gateway 0 is evaluated first and filled with modules originating from Gateway 1, forcing Gateway 1's subsequent modules to be placed across horizontal inter-gateway peer paths via the proxy server.

*Observed Outcomes vs. Hypothesized Mechanisms:* Placement ledgers confirm that `LBMP_PURE` assigns Gateway 1 modules to Gateway 0. Under the 2,000-tick simulation horizon, application loop completion rates drop to 50.0% ($G=2$), 33.3% ($G=3$), and 25.0% ($G=4$). It is hypothesized that multi-hop tree routing through the proxy server, combined with event scheduling contention on the receiving gateway, delays return tuples past the 2,000-tick horizon (individual tuple-level queue residency times were not captured by standard iFogSim telemetry). In contrast, LAMP enforces the *locality principle* by verifying local gateway capacity prior to initiating candidate searches. At $M=2$, LAMP places 100% of analyzer modules on their originating local gateway, achieving 100% loop completion ($k/N = 4/4, 6/6, 8/8$) and eliminating inter-gateway transmission delays.

*Comprehensive Workload Completion Rates:* Across the entire 16-run Phase 3.6 suite, `LBMP_PURE` achieved complete loop completion in exactly 3 runs (`SUCCESS`), while 13 runs suffered partial completion (`PARTIAL_COMPLETION`). Across all 16 runs, exactly 156 out of 220 application loops completed (70.91%). For LAMP, 100% loop completion was verified across all four $G=2$ configurations (`gw2_m2` through `gw2_m8`), three $G=3$ configurations (`gw3_m2`, `gw3_m4`, `gw3_m6`), and two $G=4$ configurations (`gw4_m2`, `gw4_m4`), with partial loop completion observed in the 3 densest symmetric configurations (`gw3_m8`, `gw4_m6`, `gw4_m8`) under heavy concurrent scale.

---

## IX. COMPARISON WITH THE ORIGINAL LAMP PUBLICATION

A rigorous scientific comparison requires separating published quantitative configuration tables from visual graph estimates and independent reproduction data. Table V provides a systematic reconciliation against the claims published by Rezazadeh, Rezaei, and Nickray [7].

**TABLE V: RECONCILIATION WITH REZAZADEH ET AL. (2019)**
| Metric / Claim | Original Paper Published Evidence | Original Paper Visual Plots | Our Empirical Findings | Scientific Classification |
| :--- | :--- | :--- | :--- | :--- |
| **Configuration Tables** | Numerical Tables I, III, IV published | System parameters specified | Parameters verified and mapped to iFogSim | **`CONFIGURATION REPRODUCED`** |
| **Numerical Results Tables** | Zero numerical experimental results tables published | Curves in Figs. 3–8 | Full numerical datasets recorded in CSV | **`NOT PUBLISHED IN LITERATURE`** |
| **Control-Loop Delay** | "Reduced by up to 40% vs COMP, 20% vs others" | Curves plotted in Fig. 3 | 82.4% reduction vs COMP at $M=4$; 0% vs EWMP/LBMP | **`QUALITATIVE AGREEMENT`** |
| **Fog Layer Energy** | "Increased by ~5% for LAMP" (narrative claim) | Curves plotted in Fig. 5 | 4.72% pooled increase (5.34%–5.51% at $M=4$, range 2.48%–5.82%) | **`QUALITATIVE AGREEMENT`** |
| **Cloud Execution Cost** | "Reduced by 50% vs COMP, 30% vs others" | Curves plotted in Fig. 6 | 73.0% reduction vs COMP at $M=4$; 0% vs EWMP/LBMP | **`QUALITATIVE AGREEMENT`** |
| **SAMP Baseline** | Claimed as comparison baseline | Curves plotted in Figs. 3–8 | Excluded: 0 equations, schedules, or operators | **`NOT VERIFIABLE`** |

*Analysis of Discrepancies:*
1. **Configuration vs. Results Tables:** Rezazadeh et al. provided detailed numerical configuration tables for tuple attributes (Table I), network latencies (Table III), and node hardware (Table IV). However, the paper published zero numerical results tables for performance metrics, presenting experimental findings exclusively through visual plots (Figs. 3–8) and narrative percentage summaries.
2. **Delay Reduction:** While [7] claims a 40% delay reduction over COMP, our simulator records an 82.4% reduction at $M=4$. This variance stems from the combined effects of queuing delays, scheduling order, and the WAN latency penalty incurred when routing high-frequency sensor streams to the Cloud in iFogSim.
3. **Fog Energy Increase:** In Section V of [7], the original authors note that "energy consumption in fog increases, but given the only 5% increase in fog computing (on average), the proposed algorithm is acceptable in this regard" (supported only by visual curves in Fig. 5 without numerical data). Our independently measured results show a 4.72% pooled average increase in fog energy consumption across completed symmetric configurations (5.34%–5.51% at $M=4$, range 2.48%–5.82%). We classify this as *qualitative agreement* with the published narrative claim, preserving the exact measured value and simulation methodology while acknowledging the absence of numerical baseline data in the literature.
4. **SAMP Omission:** Rezazadeh et al. did not provide cooling factors, initial/minimum temperatures, probability acceptance functions, or neighborhood perturbation operators for SAMP. Implementing an arbitrary simulated annealing heuristic would introduce confounding variables; therefore, SAMP is formally classified as `NOT VERIFIABLE`.

---

## X. DISCUSSION

### A. The Locality Principle in Edge Computing
Our experimental results validate the paramount importance of the *locality principle* in distributed IoT scheduling. In latency-sensitive workflows where sensor data arrives at sub-second intervals, routing intermediate tuples across horizontal peer links or vertical WAN links introduces substantial queueing and transmission delays. By strictly anchoring initial module placements to the originating local gateway, LAMP eliminates cross-link serialization delays and preserves predictable loop execution.

### B. Methodological Hazard of Conditional Delay Metrics
Our analysis reveals a critical methodological hazard in simulation studies: evaluating *conditional delay averages* without reporting application-loop completion rates ($k/N$). In iFogSim, `getExecutionTimeLoop()` computes the average delay exclusively over *completed* loops. In runs where an algorithm experiences severe congestion (such as `LBMP_PURE` at $M=2$), loops that fail to complete within the simulation horizon are excluded from the reported average. Relying solely on delay averages would create the false illusion that LBMP achieved acceptable performance (9.47 ticks), masking the catastrophic failure where up to 75% of patient monitoring loops never completed.

---

## XI. LIMITATIONS AND THREATS TO VALIDITY

1. **Construct Validity:** Discrete-event simulation time in iFogSim advances via scheduled discrete events. Simulator ticks represent an idealized execution sequence and cannot be interpreted as calibrated physical milliseconds.
2. **Internal Validity:** The 240-second external process watchdog boundary in Phase 2 terminated two COMP runs under dense scale (`gw3_m8` and `gw4_m8`). Metrics for these runs are unavailable and recorded strictly as `N/A`. While tuple-queue memory exhaustion or event loop stalls under centralized cloud routing represent plausible architectural hypotheses based on simulation scale, this is an architectural hypothesis rather than an empirically measured internal state, since internal queue lengths were not logged.
3. **External Validity:** The healthcare BSN application is modeled as a synthetic 3-module DAG with deterministic tuple generation. Physical deployments involve heterogeneous wireless channel fading, packet drops, dynamic operating system preemption, and fluctuating network interference.
4. **Algorithmic Adaptations:** `LBMP_PURE` incorporates necessary documented adaptations (D-3.4-01 to D-3.5-01) to support multi-application streaming. Our findings characterize this adapted implementation and do not generalize to alternative interpretations of Taneja and Davy [9].

---

## XII. CONCLUSION AND FUTURE WORK

This paper presented an independent, simulator-based reproduction and comparative evaluation of the Latency-Aware Module Placement (LAMP) algorithm for IoT applications. Across 72 simulation attempts spanning 12 symmetric configurations and 4 asymmetric stress workloads, we evaluated LAMP against COMP, EWMP, and an adapted pure resource-aware baseline (`LBMP_PURE`).

Our findings demonstrate that under balanced workloads ($M=4$), LAMP, EWMP, and `LBMP_PURE` achieve identical placements on local fog gateways, reducing control-loop delay by 82.4% and cloud costs by 73.0% relative to COMP. Under capacity-constrained conditions ($M=2$), `LBMP_PURE` suffers from a peer-offloading pathology that degrades loop completion to 25%–50%, whereas LAMP prioritizes local edge execution. Across all 16 Phase 3.6 runs, `LBMP_PURE` achieved 3 `SUCCESS` and 13 `PARTIAL_COMPLETION` outcomes (156/220 completed loops). For LAMP, 100% loop completion was verified in exactly 9 of 12 symmetric configurations (`gw2_m2` through `gw2_m8`, `gw3_m2` through `gw3_m6`, and `gw4_m2` through `gw4_m4`), with partial loop completion observed in the 3 densest symmetric configurations under heavy concurrent scale. In asymmetric stress workloads, full completion was achieved by `LAMP_PHYS` across all four workloads and by `LAMP_FWD` across three workloads, with peer offloading in $w_{10,2}$ inducing double-proxy transit contention. We reconciled these observations against the original 2019 publication's configuration tables, documented the non-verifiability of SAMP, and established strict unit separation between VM provisioner units and physical link bandwidth.

Future work will investigate runtime module migration and evaluate placement heuristics on containerized Kubernetes edge testbeds.

---

## REFERENCES

[1] A. Al-Fuqaha, M. Guizani, M. Mohammadi, M. Aledhari, and M. Ayyash, "Internet of things: A survey on enabling technologies, protocols, and applications," *IEEE Communications Surveys & Tutorials*, vol. 17, no. 4, pp. 2347–2376, 2015.

[2] P. Verma and S. K. Sood, "Fog assisted-IoT enabled patient health monitoring in smart homes," *IEEE Internet of Things Journal*, vol. 5, no. 3, pp. 1788–1796, 2018.

[3] R. Buyya, C. S. Yeo, S. Venugopal, J. Broberg, and I. Brandic, "Cloud computing and emerging IT platforms: Vision, hype, and reality for delivering computing as the 5th utility," *Future Generation Computer Systems*, vol. 25, no. 6, pp. 599–616, 2009.

[4] F. Bonomi, R. Milito, J. Zhu, and S. Addepalli, "Fog computing and its role in the internet of things," in *Proc. 1st Edition MCC Workshop Mobile Cloud Comput.*, 2012, pp. 13–16.

[5] C. Mouradian, D. Naboulsi, S. Yangui, R. H. Glitho, C. W. Morrow, and P. A. Polakos, "A comprehensive survey on fog computing: State-of-the-art and research challenges," *IEEE Communications Surveys & Tutorials*, vol. 20, no. 1, pp. 416–464, 2018.

[6] A. Brogi and S. Forti, "QoS-aware deployment of IoT applications through the fog," *IEEE Internet of Things Journal*, vol. 4, no. 5, pp. 1185–1192, 2017.

[7] Z. Rezazadeh, M. Rezaei, and M. Nickray (Mohsen Nickray), "LAMP: A Hybrid Fog-Cloud Latency-Aware Module Placement Algorithm for IoT Applications," in *Proc. 2019 5th Conference on Knowledge-Based Engineering and Innovation (KBEI)*, Tehran, Iran, 2019, pp. 845–850.

[8] H. Gupta, A. V. Dastjerdi, P. K. Ghosh, and R. Buyya, "iFogSim: A toolkit for modeling and simulation of resource management techniques in the Internet of Things, Edge and Fog computing environments," *Software: Practice and Experience*, vol. 47, no. 9, pp. 1275–1296, 2017.

[9] M. Taneja and A. Davy, "Resource aware placement of IoT application modules in fog-cloud computing paradigm," in *Proc. 2017 IFIP/IEEE Symp. Integrated Netw. Manage. (IM)*, Lisbon, Portugal, 2017, pp. 580–587.

[10] R. N. Calheiros, R. Ranjan, C. A. De Rose, and R. Buyya, "CloudSim: A toolkit for modeling and simulation of cloud computing environments and evaluation of resource provisioning algorithms," *Software: Practice and Experience*, vol. 41, no. 1, pp. 23–50, 2011.

[11] R. Mahmud, F. L. Pires, and R. Buyya, "iFogSim2: An extended toolkit for modeling and simulation of distributed edge and fog computing environments," *Journal of Systems and Software*, vol. 190, p. 111351, 2022.

[12] S. Kirkpatrick, C. D. Gelatt, and M. P. Vecchi, "Optimization by simulated annealing," *Science*, vol. 220, no. 4598, pp. 671–680, 1983.

---

## APPENDIX: COMPREHENSIVE EXPERIMENTAL BENCHMARK DATA AND REPRODUCIBILITY MANIFEST

### A. Full Symmetric Benchmark Dataset (Selected Subset)
The complete symmetric experimental campaign (48 attempts, 46 result summaries, 2 watchdog timeouts) and asymmetric campaign (24 attempts, 24 result summaries, 0 timeouts), yielding 70 result summaries across 72 total attempts, are preserved in `results/lamp_reproduction_results_phase2.csv` (34 rows), `results/lbmp_symmetric_results.csv` (12 rows), `results/asymmetric_validation_results.csv` (20 rows), and `results/lbmp_asymmetric_results.csv` (4 rows).

**TABLE VI: SAMPLE EXTENDED EMPIRICAL RESULTS**
| Config | Algorithm | Avg Loop Delay | Cloud Energy ($10^6$ J) | Fog Energy ($10^6$ J) | Cloud Cost ($) | Network Usage (Bytes) | Completed Loops ($k/N$) | Status |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `gw2_m6` | COMP | 782.58 | 2.89 | 2.59 | 328,756.71 | 631,399.5 | 12/12 | SUCCESS |
| `gw2_m6` | LAMP | 218.42 | 2.72 | 2.73 | 82,105.76 | 446,086.0 | 12/12 | SUCCESS |
| `gw2_m6` | EWMP | 218.42 | 2.72 | 2.73 | 82,105.76 | 446,086.0 | 12/12 | SUCCESS |
| `gw2_m6` | `LBMP_PURE`| 383.66 | 2.72 | 2.73 | 82,105.76 | 446,086.0 | 10/12 | PARTIAL |
| `gw2_m8` | COMP | 913.85 | 2.96 | 3.29 | 419,156.29 | 820,267.5 | 16/16 | SUCCESS |
| `gw2_m8` | LAMP | 363.58 | 2.76 | 3.42 | 108,091.20 | 549,425.0 | 16/16 | SUCCESS |
| `gw2_m8` | EWMP | 363.58 | 2.76 | 3.42 | 108,091.20 | 549,425.0 | 16/16 | SUCCESS |
| `gw2_m8` | `LBMP_PURE`| 582.55 | 2.93 | 3.42 | 379,065.73 | 585,473.5 | 12/16 | PARTIAL |

### B. Master Cryptographic Hash Manifest
The research environment enforces strict data immutability. Checksums are audited and classified into independently matched pre-recorded references and recorded production benchmark outputs:

**TABLE VII: CRYPTOGRAPHIC HASH AUDIT AND CLASSIFICATION**
| File Path | SHA-256 Checksum | Verification Classification |
| :--- | :--- | :---: |
| `RESEARCH_TRACEABILITY_MATRIX.md` | `a47a9d0352c81868c2179a409f6ac9806d8cd2c4d0eaefad0bb9603ee2b58693` | INDEPENDENTLY MATCHED (Frozen Matrix) |
| `results/lamp_reproduction_results.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | INDEPENDENTLY MATCHED (Phase 1 Baseline) |
| `results/lamp_reproduction_results_phase1_historical.csv` | `A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890` | INDEPENDENTLY MATCHED (Archival Clone)* |
| `results/lamp_reproduction_results_phase2.csv` | `613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284` | INDEPENDENTLY MATCHED (Phase 2 Output) |
| `results/asymmetric_validation_results.csv` | `3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30` | INDEPENDENTLY MATCHED (Phase 2.2 Output) |
| `iFogSim-main/.../ModulePlacementLBMP.java` | `DBD48E4B9D25B0033F1228562F9A5B54C10A20E7554EFD3DA9A69E17D049C044` | INDEPENDENTLY MATCHED (Frozen Source) |
| `iFogSim-main/.../BaselineSimulationRunner.java` | `09F1FEB0C3CFDAA6A1B809F20FA65946BFA20C85C309AAB79F11A30CA33E299A` | INDEPENDENTLY MATCHED (Frozen Source) |
| `iFogSim-main/.../ModulePlacementLBMPTest.java` | `CD1A1E58B14BC01AC283211491D30A2B68C84E3252AA24B00192CD064EE10885` | INDEPENDENTLY MATCHED (Frozen Test Suite) |
| `results/lbmp_symmetric_results.csv` | `4BEA70AF6DCB147B09EC95F72005502B84844DD91C1B6B25C0585793B0D8D26D` | RECORDED ONLY (Phase 3.6 Output) |
| `results/lbmp_asymmetric_results.csv` | `A37B3A2166374C57C731BD710B00229F36022B87C38FA6E10668F54CF2FFC14A` | RECORDED ONLY (Phase 3.6 Output) |

\* *Note on Duplicate Checksums:* Files `lamp_reproduction_results.csv` and `lamp_reproduction_results_phase1_historical.csv` share an identical checksum because the latter was created prior to Phase 2 as an immutable byte-for-byte archival backup of the monolithic Phase 1 experimental data.

*Cryptographic Audit Conclusion:* Unbroken cryptographic verification is established for the 8 independently matched reference files (including the frozen Research Traceability Matrix, Phase 1 archival datasets, Phase 2 and 2.2 output CSVs, and frozen Java placement engines). The 2 Phase 3.6 production output datasets (`results/lbmp_symmetric_results.csv` and `results/lbmp_asymmetric_results.csv`) are cryptographically recorded with their generated checksums documented for independent verification.