# 🖥️ Network Hosts & Infrastructure

In **VERIFY.EXE**, the corporate network is composed of various **Hosts**. These represent the individual servers, workstations, and devices that the player must monitor, scan, and occasionally isolate to contain threats.

---

## 1. Host Anatomy
Each host is defined as a `HostResource` and managed dynamically by the `NetworkState.gd` singleton.

### Core Properties
*   **Hostname:** The unique identifier used in the Terminal (e.g., `DB-SRV-01`).
*   **IP Address:** The network location used for tracing and SIEM log cross-referencing.
*   **Criticality:** Boolean flag (`is_critical`). Critical hosts (Servers) trigger severe consequences if compromised or isolated improperly.
*   **OS Type:** Determines tool compatibility.
    *   **Windows / Linux:** Standard workstations and servers.
    *   **Legacy:** Older systems (e.g., `XP-PAYROLL-01`) that return errors when scanned, forcing manual log analysis.
    *   **IoT:** Connected devices (Cameras, Thermostats) often used as entry points for attackers.
    *   **Honeypot:** Decoy systems designed to lure attackers; activity here is a 100% confirmation of a breach.

---

## 2. Host Status & States
Hosts transition through several states during a shift based on narrative events or player actions.

| Status | Code | Description | Map Color |
| :--- | :--- | :--- | :--- |
| **CLEAN** | `0` | System is nominal and uncompromised. | **Green/Cyan** |
| **SUSPICIOUS** | `1` | Anomalous activity detected; requires investigation. | **Orange** |
| **INFECTED** | `2` | Active malware/unauthorized access confirmed. | **Red** |
| **ISOLATED** | `3` | Network interfaces disconnected by the analyst. | **Gray** |

### Additional Flags
*   **Scanned:** Whether the analyst has performed a `scan` command via the Terminal.
*   **Isolated:** Whether the host has been disconnected from the network.

---

## 3. The Source of Truth: `NetworkState.gd`
The `NetworkState` singleton is the central authority for the entire network.
*   **Simulation Loop:** Periodically processes network-wide effects like **Lateral Movement**.
*   **State Persistence:** Saves and loads the health of the network between shifts.
*   **Signal Dispatch:** Emits `host_status_changed` whenever a host's condition updates, ensuring the **Network Map** and **Terminal** stay synchronized.

---

## 4. Interacting with Hosts

### The Terminal (`scan` & `isolate`)
The primary tool for active defense.
1.  **Verification:** Analysts use `scan [hostname]` to confirm a threat.
2.  **Containment:** Analysts use `isolate [hostname]` to disconnect a host.
    *   **Procedural Rule:** Isolating a host **without** scanning it first results in a **Procedural Violation** (-15.0 Integrity).

### The Network Map
A visual dashboard used for situational awareness.
*   **Selection:** Clicking a host on the map opens the **Inspector**, showing IP, OS, and current Status.
*   **Lateral Movement:** Players can see the infection "pulse" as it spreads from one node to another in real-time.

---

## 5. Criticality & Service Outages
Managing **Critical Hosts** (Servers) requires high-precision decision-making.
*   **Infection Impact:** If a critical host remains `INFECTED` for too long, it triggers a **Major Breach** or **Data Loss** event.
*   **Isolation Impact:** Disconnecting a critical server (e.g., `FINANCE-SRV-01`) immediately resolves the threat but triggers a **Service Outage** followup ticket, reflecting the operational cost of the downtime.

---

## 6. Advanced Host Mechanics
*   **Lateral Movement:** When active, `INFECTED` hosts have a 30% chance per tick to spread the infection to neighboring `CLEAN` hosts if not isolated promptly.
*   **Legacy Protocol Error:** Attempting to `scan` a Legacy host returns: `[color=red]ERROR: Legacy Protocol Unsupported.[/color]`. This forces the player to use the **SIEM** to find proof of infection instead of relying on the automated scanner.
