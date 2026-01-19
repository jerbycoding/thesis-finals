# VERIFY.EXE: Full Game Technical & Design Authority

## 1. Vision Statement
**VERIFY.EXE** is a high-fidelity Security Operations Center (SOC) simulation that transitions from a scripted narrative into an infinite, stateful career loop. The game bridges the gap between digital forensics (2D) and physical infrastructure (3D), forcing the player to manage both technical threats and organizational trust.

---

## 2. The 7-Day Gameplay Rhythm
The game follows a strict weekly cycle. Players navigate the facility using the **Corporate Elevator Modal**.

### 2.1 Floor Hierarchy & Logic
| Floor | Designation | Environment | Logic Constraints |
| :--- | :--- | :--- | :--- |
| **Floor 2** | **Executive Suite** | 3D (Narrative) | **Input Lock:** Movement disabled. Automatic dialogue trigger. Exit requires dialogue completion. |
| **Floor 1** | **Main SOC Office** | 3D/2D (Hybrid) | **Core Loop:** High-intensity ticket resolution at the workstation. |
| **Floor -1** | **Server Vault** | 3D (Maintenance) | **Free Roam:** Interactive server racks. Sunday recovery focus. |
| **Floor -2** | **Network Hub** | 3D (Audit) | **Free Roam:** Patch panels and routers. Saturday audit focus. |

---

## 3. Meta-Progression: Organization Integrity
The player's primary goal is to keep the **Integrity Score** above 0%. This score represents the company's financial health and public reputation.

### 3.1 Integrity Math (The "HP" Bar)
*   **Formula:** `New_Integrity = Clamp(Current_Integrity + Delta, 0, 100)`
*   **Delta Values:**
    *   `+5.0`: Compliant Closure (Thorough verification).
    *   `-2.0`: Efficient Closure (Rushed, risk accepted).
    *   `-5.0`: Emergency Closure (Protocol bypass).
    *   `-10.0`: Ticket Timeout (Negligence).
    *   `-40.0`: Critical Breach (Total Friday failure).

### 3.2 Maintenance Decay & Recovery
To ensure the 3D weekend missions are essential, Integrity suffers from **Active Session Decay**:
*   **Decay Rate:** Base `-1.0%` per hour of active play (approx. `-0.016%` per minute).
*   **Calculation:** Processed in real-time while the player is inside a 2D or 3D shift.
*   **The Weekend Payoff:** 
    *   **Saturday:** Completing the physical audit in the **Network Hub** grants "Maintenance Immunity," pausing the decay for the remainder of the weekend.
    *   **Sunday:** Completing hardware repairs in the **Server Vault** restores a lump sum of **+15% Integrity**.
*   **Scaling Decay:** In Week 2+, the decay rate is multiplied by the current **Heat Multiplier** (e.g., Week 5 may see `-1.5%` per hour as infrastructure ages).
*   **UI Feedback:** The Integrity Bar displays a subtle "leaking" animation (downward arrows) when decay is active.

---

## 4. Weekend Interaction System (Days 6 & 7)
The weekend shifts use specialized 3D mechanics to differentiate the experience from the standard 2D work week.

### 4.1 Mission Intro (Title Cards)
When the player transitions to a maintenance floor, the `TransitionManager` triggers a custom **Title Card Fade**:
*   The screen stays black for 2 seconds.
*   Centered text appears: `[ MAINTENANCE WINDOW: PREVENTATIVE AUDIT ]` (Saturday) or `[ MAINTENANCE WINDOW: HARDWARE RECOVERY ]` (Sunday).
*   Sound cue: A deep, industrial mechanical hum.

### 4.2 The Auditor's Tablet (HUD Checklist)
While on Floors -1 and -2, the player's HUD displays a **Task Checklist**:
*   **Logic:** A dynamic `VBoxContainer` that listens for `EventBus` signals.
*   **Visuals:** `[ ] Task Description`. Upon completion, the text is struck through and turns Green with a "Success" SFX.
*   **Persistence:** The shift cannot be concluded until all items are checked.

### 4.3 Physical Interaction: Parent-Link Carrying
A simplified mechanical system for hardware replacement (e.g., swapping hard drives):
*   **Architecture:** The Player Camera contains a `Marker3D` child node (offset at `z = -0.5`).
*   **The Pickup:** Pressing "E" on an interactable hardware model calls `reparent(camera_marker)`.
*   **Constraints:** Object collision is disabled while held. Player movement speed is reduced by 25%.
*   **The Drop:** Pressing "E" on a valid "Target Socket" (e.g., a server rack slot) reparents the object back to the world and triggers the "Task Completed" signal.

---

## 5. Procedural Content & Semantic Consistency
To support infinite looping, the game utilizes a **Template + Variable Registry** model.

### 5.1 The Variable Registry (Library of Truth)
A centralized dictionary containing valid organizational data:
*   **EMPLOYEES**: 50+ entries (Name, IP, Dept, Criticality).
*   **HOSTS**: Linked directly to `NetworkState.gd` host definitions.
*   **ATTACKERS**: IPs from non-corporate ranges, malicious domains, and proxy nodes.

### 5.2 The Incident Context (The Truth Packet)
Every spawned incident generates a **Truth Packet** that is passed to all managers via the `EventBus`.
*   **Structure:**
    ```json
    {
      "context_id": "UID_12345",
      "victim": "Alice",
      "victim_host": "WS-05",
      "attacker_ip": "203.0.113.42",
      "malicious_url": "verify-update.net",
      "is_vulnerable": false
    }
    ```
*   **Format-on-Access Logic:** To preserve the integrity of static `.tres` files, data injection occurs only at the UI layer. 
    1. The tool (SIEM, Email, Ticket) retrieves the raw template string containing `{placeholders}`.
    2. The system applies `string.format(truth_packet)` immediately before rendering.
    3. **Crucial:** The original Resource file is never modified or overwritten.

---

## 6. The Inheritance System (Persistent Threats)
Inheritance creates a "Memory" for the world, where past mistakes become future crises.

### 6.1 The Logic Flow
1.  **Origin:** Player closes a Phishing ticket as "Efficient."
2.  **Flagging:** The `IncidentContext` is stored in a persistent `Vulnerability_Buffer`.
3.  **FIFO Selection:** To prevent overwhelming the player, the Procedural Engine selects contexts from the buffer using a **First-In-First-Out (FIFO)** queue. The oldest un-exploited mistake is prioritized for the next escalation.
4.  **Escalation:** The system spawns a **Malware Outbreak** ticket that **Inherits** the original `attacker_ip` and `victim_host` from the selected context.
5.  **Payoff:** The player recognizes the semantic data, creating a narrative link between their past actions and the current threat.

---

## 7. Master Threat Catalog
Detailed stages for the 5 primary Kill Chains.

### 7.1 Chain 1: Malware Outbreak
*   **Stage 1:** Phishing Email (User report).
*   **Stage 2:** Malware Beacon (SIEM Alert).
*   **Stage 3:** Ransomware/Encryption (Server Lockdown).

### 7.2 Chain 2: The Data Breach
*   **Stage 1:** Social Engineering (Credential harvesting).
*   **Stage 2:** Insider Threat (Unauthorized file access).
*   **Stage 3:** Exfiltration (High outbound network traffic).

### 7.3 Chain 3: The Service Siege (DDoS)
*   **Stage 1:** Botnet Probe (Global PING spikes).
*   **Stage 2:** Resource Exhaustion (100% CPU on `WEB-SRV-01`).
*   **Decision:** Isolate server to save hardware (Service Outage) vs. attempt filtering (Risk of hardware failure).

### 7.4 Chain 4: Business Email Compromise (BEC)
*   **Stage 1:** Fraudulent Request (CFO Spoof). Scanners report "CLEAN."
*   **Stage 2:** Forensic Cleanup (Attacker deletes logs).
*   **Detection:** Only catchable by manual Header Analysis and Deletion Event monitoring.

### 7.5 Chain 5: SQL Injection (SQLi)
*   **Stage 1:** The Probe (Web logs showing `' OR '1'='1`).
*   **Stage 2:** The Dump (Database exfiltrating text rows).
*   **Detection:** High-precision log review required.

---

## 8. World Instability (Heat Scaling)
The **Heat Multiplier** increases by `1.15x` every week.
*   **Noise:** SIEM background logs increase in volume.
*   **Timer Pressure:** Ticket resolution times (`base_time`) decrease by 10% every week.
*   **Decay Scaling:** The **Hourly Integrity Decay** increases in direct proportion to the Heat Multiplier.
*   **Tool Instability:** High "Heat" causes random UI glitches or forensic tool lag.

---

## 9. Win/Loss States (Endings)
*   **Exemplary Service:** High Integrity maintained across 4+ weeks. Promotion to Senior Architect.
*   **Termination:** Classification as "Negligent" or hitting 0% Integrity.
*   **Systemic Collapse:** Failing a Stage 3 event during a high-Heat week.
*   **The Black Ticket:** A final, high-difficulty forensic audit that resets all "Vulnerable" flags if solved perfectly.

---

## 10. Developer & Debugging Tools
To facilitate rapid testing of the 7-day loop and 3D mechanics, a hidden **DebugManager** is active in non-release builds.

### 10.1 Shift Overrides (Hotkey Jumps)
*   **F1 - F5:** Instantly jump to the start of the corresponding weekday shift (Floor 1).
*   **F6:** Jump to Saturday (Floor -2: Network Hub).
*   **F7:** Jump to Sunday (Floor -1: Server Vault).
*   **Logic:** These keys bypass the `NarrativeDirector` timers and trigger an immediate `TransitionManager` scene change.

### 10.2 System Cheats
*   **F8 (Integrity Freeze):** Toggles the **Maintenance Decay** logic. Prevents bankruptcy during long 3D testing sessions.
*   **F9 (Force Spawn):** Manually triggers the next ticket in the current shift's pool.
*   **F10 (Reveal Evidence):** Automatically flags all required logs for the active ticket as "Revealed" in the SIEM.

---

## 11. Development Roadmap (The Path to Gold)
1.  **Core Systems (High Priority):**
    *   Build `VariableRegistry.gd` and the Context Generator.
    *   Refactor `TicketManager` to support placeholder injection.
    *   Implement the `OrganizationIntegrity` bar and persistence.
2.  **3D Expansion (Medium Priority):**
    *   Build `ElevatorUI.tscn` and scene transition logic.
    *   Create `ServerVault.tscn` and `NetworkHub.tscn` levels.
    *   Implement the 3D "InteractableHardware" system.
3.  **Debug & Quality of Life:**
    *   Build the `DebugManager.gd` for F-key shift jumping.
4.  **Content Expansion (Continuous):**
    *   Expand NPC dialogue matrix (Context-aware responses).
    *   Implement 20+ generic ticket templates for pool variety.
    *   Convert Master Threat Catalog (DDoS, BEC, SQLi) into procedural templates.