# VERIFY.EXE: Official Game Systems Manual

## 1. Win & Loss Conditions

### 💀 How to Lose
1.  **Organizational Bankruptcy**: Occurs if the **System Integrity** (top-left HUD) reaches **0%**. This is a cumulative failure across multiple incidents.
2.  **Professional Termination**: Occurs if the player is classified as **Negligent** at the end of a shift.
    *   *Condition*: `Tickets Ignored` >= `Tickets Completed`.

### 🏆 How to Win
*   **The Promotion**: Surviing the 7-day narrative arc (Monday to Sunday) and successfully neutralizing the Friday "Zero Day" event.

---

## 2. The Integrity System (HP)
Integrity represents the organization's stability. It is affected by every ticket resolution:

*   **Compliant (+5%)**: Standard operating procedure followed. Restores stability.
*   **Efficient (-2%)**: "Cowboy" shortcut taken. Small stability loss.
*   **Emergency (-5%)**: Crisis protocol. Moderate stability loss.
*   **Timeout (-10%)**: Total negligence. Major stability loss.
*   **Data Breach (-40%)**: Critical consequence of poor investigation. Near-fatal stability loss.

---

## 3. The Chaos Engine (Random Pool)
During active shifts, the **Chaos Engine** (in `NarrativeDirector.gd`) runs a hidden timer. Every 45 seconds, there is a **35% chance** to trigger an event from the shift's `random_event_pool`.

### Common Chaos Events:
*   **SIEM Lag**: Increases log retrieval time by 5x.
*   **Gossip Flood**: Spawns multiple "Noise" emails to distract the player.
*   **ISP Throttling**: Slows down Terminal 'trace' and 'scan' commands.
*   **Power Flicker**: Momentarily blacks out the workstation, closing all open apps.
*   **False Flag**: Floods the SIEM with thousands of fake logs for 60 seconds.

---

## 4. Kill Chain & Inheritance
The game tracks your "shortcuts" to punish you later.

*   **Vulnerability Inheritance**: If you close a ticket as **Efficient**, the attacker's IP and the victim's hostname are stored in the **HeatManager**. 
*   **The Payoff**: These indicators will reappear in a future, higher-priority ticket (e.g., a simple Phish becomes a Ransomware attack targeting the same user).
*   **Kill Chain Stages**:
    1.  **Infiltration**: Phishing / Social Engineering.
    2.  **Propagation**: Malware / Lateral Movement.
    3.  **Exfiltration**: Data Breach / Shadow IT.
    4.  **Impact**: Ransomware / Total Collapse.

---

## 5. Weekend Payoffs (Maintenance Windows)
Successfully completing weekend minigames provides massive permanent boosts for the following week:

*   **Saturday (Audit)**: Suspend the "Base Integrity Decay" for the next week.
*   **Sunday (Recovery)**: Restores **+15% System Integrity** and resets the Kill Chain.

---

## 6. Chaos Engine & Event Reference

The **Chaos Engine** manages operational friction. Every 45 seconds during a shift, there is a **35% chance** to trigger one of the following from the active pool. You can manually cycle through these in debug mode by pressing **F9**.

### 🛠️ System Disruptions (Global)
| Debug Key (F12) | Event ID | Effect | Found In |
| :--- | :--- | :--- | :--- |
| **`siem_bottleneck`** / **`minor_siem_lag`** | `SIEM_LAG` | Log retrieval time increases by 5x. | Shifts 1, 2, 3, 5, 8 |
| **`isp_blip`** / **`isp_throttling`** | `ISP_THROTTLING` | Terminal commands slowed by 3x. | Shifts 1, 3, 5, 8 |
| **`gossip_distraction`** / **`internal_gossip`** | `GOSSIP_FLOOD` | Spawns distracting "Noise" emails. | Shifts 1, 2, 4, 10, 11 |
| **`log_obfuscation`** / **`false_flag_logs`** | `FALSE_FLAG` | Floods SIEM with a "Noise" log stream. | Shifts 2, 4, 11 |
| **`unstable_power`** / **`power_surge`** | `POWER_FLICKER` | Blackout; closes all open apps. (Test: Recovers investigation state). | Shifts 2, 4, 5, 9, 12 |
| **`cpu_thermal_spike`** | `CRYPTO_SPIKE` | Causes graph spikes in TaskMgr. | Shift 3 |

### 🎫 Random Ticket Spawns (Operational Noise)
| Debug Key (F12) | Ticket ID | Context | Found In |
| :--- | :--- | :--- | :--- |
| **`random_login_fail`** | `AUTH-FAIL-GENERIC` | Typical user login failures. | Shift 1 |
| **`account_lockout_noise`** | `TICKET-NOISE-001` | Basic account resets. | Shifts 1, 4, 9 |
| **`urgent_noise`** / **`panic_noise`** | `TICKET-NOISE-002` | Hardware requests (Monitors/Mice). | Shifts 5, 12 |
| **`routine_patching`** | `SYS-MAINT-GENERIC` | Routine server patching notifications. | Shift 2 |
| **`unauthorized_script_noise`** | `MALWARE-002` | Encoded PowerShell script execution. | Shift 2 |
| **`crypto_outbreak`** | `CRYPTOMINER-HUNT-001` | High-CPU mining process alert. | Shift 3 |
| **`polymorphic_noise`** | `TICKET-NOISE-POLY-001` | Evolved Week 2 malware noise. | Shift 8 |
| **`vip_complaint`** | `USER-COMPLAINT-FOLLOWUP` | High-priority user dissatisfaction. | Shift 10 |

---

## 8. Testing with Debug Keys (Operational Manual)

The **DebugManager** provides several hotkeys to test the robustness of the SOC systems. These are active in all builds but intended for "Lead Analyst" use.

### 🎮 Primary Controls
*   **`F12`**: Toggle the **Debug HUD**. Use this to monitor current Shift progress, Integrity %, and the available Chaos Pool.
*   **`F1` / `F2`**: Previous / Next Shift. Use these to jump through the narrative timeline without completing tickets.
*   **`F9`**: Trigger **Manual Chaos**. Forces the engine to immediately execute a random event from the active pool.
*   **`Shift + F1` through `F7`**: Direct jump to any day in **Week 1**.
*   **`Ctrl + F1` through `F5`**: Direct jump to any day in **Week 2**.

### 🧪 Testing "Edge Case" Failures
To verify the game's failure logic and state consistency, use the following procedures:

1.  **Testing Integrity Bankrupcy**:
    *   Jump to any active shift (e.g., **Shift + F1**).
    *   Spam **F9** to flood the queue with tickets.
    *   Let the tickets **Timeout**. Observe the top-left HUD. Once Integrity hits 0%, you should be automatically transitioned to the "Bankrupt" ending.
2.  **Testing State Consistency (Resume)**:
    *   Resolve two tickets as "Compliant."
    *   Press **Esc** ➔ **Quit to Menu**.
    *   Press **2** (Resume) in the Main Menu.
    *   Verify that your completed tickets are still in the registry and the SIEM has the same log history.
3.  **Testing "Logic Leaks"**:
    *   Jump to **`shift_tutorial`** via the menu.
    *   Halfway through, use **F2** to jump to **`shift_monday`**.
    *   Verify that the "Training Filters" (which restrict logs) have been properly cleared and you can see standard corporate noise again.


### 📅 Week 1: The Establishment
*   **Monday (Active Monitoring)**: Baseline training. Focus on Phishing and manual SIEM searches.
*   **Tuesday (Noise)**: Introduction of "False Flag" log floods and Social Engineering.
*   **Wednesday (Outbreak)**: First active malware beacons. Learning to use the Terminal for isolation.
*   **Thursday (Betrayal)**: Introduction of Insider Threats. Investigating your own coworkers.
*   **Friday (Zero Day)**: The major crisis. High-volume DDoS and Ransomware.
*   **Saturday (Audit)**: Physical maintenance. Calibrating network nodes in 3D.
*   **Sunday (Recovery)**: Hardware repair. Slotting server blades and RAID synchronization.

### 📅 Week 2: Escalation & Paranoia
*   **Monday (Inheritance)**: The "Return of the King." Previous shortcuts (Efficient closures) reappear as severe breaches.
*   **Tuesday (System Instability)**: "Ghost Logs" and supply chain corruption.
*   **Wednesday (Executive Targets)**: Attackers go after the C-Suite. CFO and CEO mobile devices are the primary targets.
*   **Thursday (Paranoia)**: High-stakes mole hunt. Active Wiper scripts begin deleting forensic history in real-time.
*   **Friday (Total War)**: The logical conclusion. System-wide lag, terminal lockouts, and a recursive backup wipe.
*   **Victory**: Promotion to Senior Analyst.

---

## 7. SOC Analyst Toolbox

### 📊 SIEM Log Viewer (Security Information & Event Management)
*   **In-Game Use**: The primary tool for forensic investigation. Players search through thousands of logs to find technical indicators (IPs, Hostnames).
*   **Evidence Mechanic**: Use **Drag-and-Drop** to attach a specific log to a ticket. A "Compliant" resolution requires finding the exact log ID mentioned in the briefing.
*   **Cybersecurity Context**: In the real world, a SIEM aggregates data from firewalls, servers, and antivirus. It allows analysts to "connect the dots" between a suspicious email and a subsequent server reboot.

### 📧 Email Analyzer (Phishing Triage)
*   **In-Game Use**: Triage reported emails using three tools: **Header Forensics** (SPF/DKIM), **Attachment Scan** (Malware detection), and **Link Analysis** (Domain reputation).
*   **Hidden Risk**: Quarantining an email without scanning its attachment first can trigger a "Missed Indicator" consequence, leading to a future outbreak.
*   **Cybersecurity Context**: Most breaches start with Phishing. Analysts must check if the sender is spoofed (Headers) and if links lead to malicious credential-harvesting sites.

### 💻 SOC Terminal (Active Response)
*   **In-Game Use**: A command-line interface for active defense.
    *   `scan [hostname]`: Verifies if a host is actually infected.
    *   `isolate [hostname]`: Disconnects a host from the network.
    *   `restore [hostname]`: Reconnects an isolated host to the network.
    *   `trace [ip]`: Identifies which internal host is talking to a hostile external IP.
*   **Trace Workflow Example**:
    1.  SIEM flags `LOG-EXFIL-001` talking to external IP `203.0.113.42`.
    2.  Open Terminal, type: `trace 203.0.113.42`.
    3.  Terminal identifies internal origin: `WORKSTATION-88`.
    4.  Command: `isolate WORKSTATION-88`.
*   **Cybersecurity Context**: This represents **EDR (Endpoint Detection and Response)**. The "Scan-before-Isolate" rule mimics real-world change control—you don't take a server offline without proof, or you risk a "Service Outage" (a self-inflicted DDoS).

### 🌐 Network Mapper (Situational Awareness)
*   **In-Game Use**: A visual dashboard showing the real-time status of all hosts.
    *   **Red**: Infected.
    *   **Gray**: Isolated.
    *   **Cyan**: Nominal.
*   **Cybersecurity Context**: Maintaining a "Single Pane of Glass" view is vital for identifying **Lateral Movement**—where an attacker jumps from one computer to another. If you see nodes turning red in a sequence, you are witnessing a live pivot.

### 🧩 Decryption Tool (Crisis Recovery)
*   **In-Game Use**: A high-stakes hex-based puzzle used to recover files during Ransomware attacks or to bypass Terminal lockouts.
*   **Cybersecurity Context**: When preventative measures fail, analysts must use **Encryption Keys** and recovery modules to restore data from backups. Speed is critical to prevent permanent data loss.

