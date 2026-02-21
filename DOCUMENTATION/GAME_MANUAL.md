# VERIFY.EXE: Official Game Systems Manual

## 1. Win & Loss Conditions

### 💀 How to Lose
1.  **Organizational Bankruptcy**: Occurs if the **System Integrity** (top-left HUD) reaches **0%**. This is a cumulative failure across multiple incidents.
2.  **Professional Termination**: Occurs if the player is classified as **Negligent** at the end of a shift.
    *   *Condition*: `Tickets Ignored` >= `Tickets Completed`.

### 🏆 How to Win
*   **The Promotion**: Surving the 14-day narrative arc (Monday to Sunday, Week 1 & 2) and successfully neutralizing the Friday "Total War" event.

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
*   **Power Flicker**: Momentarily blacks out the workstation for 3s, closing all open apps.
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

## 6. Weekly Roadmap (Operational Calendar)

### 📅 Week 1: The Establishment
*   **Monday (Active Monitoring)**: Baseline training. Focus on Phishing and manual SIEM searches.
*   **Tuesday (Noise)**: Introduction of "False Flag" log floods and Social Engineering.
*   **Wednesday (Outbreak)**: First active malware beacons. Introduction of **Lateral Movement** (Infection spreads every 10s if not contained).
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

---

## 7. SOC Analyst Toolbox

### 📊 SIEM Log Viewer (Security Information & Event Management)
*   **In-Game Use**: Search through logs to find technical indicators. Supports Zebra-stripping and search filters.
*   **Evidence Mechanic**: Use **Drag-and-Drop** to attach a specific log to a ticket.
*   **Cybersecurity Context**: Aggregates data from firewalls and servers to identify attack patterns.

### 📧 Email Analyzer (Phishing Triage)
*   **In-Game Use**: Triage reported emails using **Header Forensics** (SPF/DKIM), **Attachment Scan**, and **Link Analysis**.
*   **Hidden Risk**: Quarantining without scanning can trigger "Missed Indicator" consequences.
*   **Cybersecurity Context**: Triage tool for the most common attack vector: Phishing.

### 💻 SOC Terminal (Active Response)
*   **In-Game Use**: Command-line interface for active defense.
    *   `scan [hostname]`: Verifies if a host is actually infected.
    *   `isolate [hostname]`: Disconnects a host from the network.
    *   `restore [hostname]`: Reconnects an isolated host to the network.
    *   `trace [ip]`: Identifies which internal host is talking to an external IP.
*   **Trace Workflow Example**:
    1.  SIEM flags `LOG-EXFIL-001` talking to external IP `203.0.113.42`.
    2.  Terminal: `trace 203.0.113.42` identifies `WORKSTATION-88`.
    3.  Terminal: `isolate WORKSTATION-88`.

### 🌐 Network Mapper (Situational Awareness)
*   **In-Game Use**: Vertical tiered dashboard showing real-time host status.
    *   **Red**: Infected | **Gray**: Isolated | **Cyan**: Nominal.
*   **Cybersecurity Context**: Visualization of **Lateral Movement** and network topology.

### 🧩 Decryption Tool (Crisis Recovery)
*   **In-Game Use**: Hex-based puzzle used to recover encrypted servers or bypass Terminal lockouts.

---

## 8. Procedural Indicator Registry
When writing tickets, logs, or emails, use these placeholders to inject procedural "Truth" data.

| Standard Key      | Alias (Shorthand) | Description                                                |
|:------------------|:------------------|:-----------------------------------------------------------|
| `{attacker_ip}`   | **`{ip}`**        | The external source of the attack.                         |
| `{victim_name}`   | **`{victim}`**    | The targeted employee's full name.                         |
| `{victim_host}`   | **`{host}`**      | The hostname of the compromised computer.                  |
| `{victim_dept}`   | N/A               | Department of the victim (e.g., Finance, HR).              |
| `{victim_role}`   | N/A               | Job title of the victim.                                   |
| `{malicious_url}` | N/A               | The domain used in phishing/C2 (e.g., evil.com).           |
| `{timestamp}`     | N/A               | System time of the event.                                  |
| `{context_id}`    | N/A               | Unique unique identifier for the specific incident packet. |

---

## 9. Chaos Engine & Event Reference (F12 HUD)

Every 45 seconds, 35% chance to trigger from the active pool. Use **F9** to manually trigger.

### 🛠️ System Disruptions
| Debug Key (F12)          | Event ID         | Effect                           |
|:-------------------------|:-----------------|:---------------------------------|
| **`siem_bottleneck`**    | `SIEM_LAG`       | 5x Log retrieval delay.          |
| **`isp_blip`**           | `ISP_THROTTLING` | 3x Terminal command delay.       |
| **`gossip_distraction`** | `GOSSIP_FLOOD`   | Floods inbox with noise emails.  |
| **`log_obfuscation`**    | `FALSE_FLAG`     | Floods SIEM with noise logs.     |
| **`unstable_power`**     | `POWER_FLICKER`  | 3s Blackout; closes all windows. |
| **`cpu_thermal_spike`**  | `CRYPTO_SPIKE`   | CPU/Net graph spikes in TaskMgr. |

### 🎫 Random Ticket Spawns
| Debug Key (F12)           | Ticket ID           | Context                |
|:--------------------------|:--------------------|:-----------------------|
| **`random_login_fail`**   | `AUTH-FAIL-GENERIC` | User login failures.   |
| **`account_lockout`**     | `TICKET-NOISE-001`  | Password resets.       |
| **`urgent_noise`**        | `TICKET-NOISE-002`  | Hardware requests.     |
| **`routine_patching`**    | `SYS-MAINT-GENERIC` | Server maintenance.    |
| **`unauthorized_script`** | `MALWARE-002`       | PowerShell execution.  |
| **`crypto_outbreak`**     | `CRYPTOMINER-HUNT`  | Cryptominer detection. |

---

## 10. Testing with Debug Keys (Operational Manual)

*   **`F12`**: Toggle **Debug HUD**.
*   **`F1 / F2`**: Previous / Next Shift.
*   **`F9`**: Trigger **Manual Chaos**.
*   **`Shift + F1-F7`**: Jump to **Week 1** days.
*   **`Ctrl + F1-F5`**: Jump to **Week 2** days.
