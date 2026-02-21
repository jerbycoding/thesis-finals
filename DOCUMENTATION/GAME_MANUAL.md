# VERIFY.EXE: Official Game Systems Manual

## 1. Win & Loss Conditions

### 💀 How to Lose
1.  **Organizational Bankruptcy**: Occurs if the **System Integrity** reaches **0%**. This is scaled by your chosen **Operational Rigor**.
2.  **Professional Termination**: Occurs if the player is classified as **Negligent** at the end of a shift (`Tickets Ignored` >= `Tickets Completed`).

### 🏆 How to Win
*   **The Promotion**: Surving the 14-day narrative arc (Monday to Sunday, Week 1 & 2) and successfully neutralizing the Friday "Total War" event.

---

## 2. Operational Rigor (Difficulty Tiers)
Before starting a campaign, analysts must select their level of rigor. This affects every system in the SOC.

| Tier | Name | Gameplay Adjustments | Who is it for? |
| :--- | :--- | :--- | :--- |
| **Tier 1** | **JUNIOR** | +50% Ticket Time, 0.5x Integrity Damage, Slow Chaos (65s). | Training / Story focus. |
| **Tier 2** | **ANALYST** | Standard values (The intended experience). | Balanced challenge. |
| **Tier 3** | **LEAD** | -30% Ticket Time, 1.5x Integrity Damage, Fast Chaos (25s). | Expert IR simulation. |

---

## 3. The Integrity System (HP)
Integrity represents the organization's stability. Values are scaled by **Difficulty Multipliers**:

*   **Compliant (+5%)**: Standard operating procedure followed. Restores stability.
*   **Efficient (-2%)**: "Cowboy" shortcut taken. Small stability loss.
*   **Emergency (-5%)**: Crisis protocol. Moderate stability loss.
*   **Timeout (-10%)**: Total negligence. Major stability loss.
*   **Data Breach (-40%)**: Critical consequence of poor investigation. Near-fatal stability loss.

---

## 4. Vulnerability Inheritance (Long-Term Memory)
The organization "remembers" the threats you ignore or solve too quickly.

*   **The Trigger**: If you close a ticket as **Efficient** (solving it fast without full evidence), the technical indicators (Attacker IP and Victim Host) are stored in the **HeatManager**.
*   **The Payoff**: These specific indicators will resurface in future, higher-priority tickets. 
    *   *Example*: A phishing IP you didn't blacklist on Monday might reappear as the source of a Ransomware attack on Thursday.
*   **Resetting the Chain**: Successfully completing the **Sunday Hardware Recovery** minigame resets the vulnerability buffer, purging these ghosts from the network.

---

## 5. The Chaos Engine (System Friction)
During active shifts, the Chaos Engine triggers random disruptions.

### Common Chaos Events:
*   **SIEM Lag**: Increases log retrieval time by 5x.
*   **Gossip Flood**: Spawns multiple "Noise" emails to distract the player.
*   **ISP Throttling**: Slows down Terminal 'trace' and 'scan' commands.
*   **Power Flicker**: Blacks out the workstation for 3s, **closing all open windows**.
*   **False Flag**: Floods the SIEM with thousands of fake logs for 60 seconds.
*   **Zero Day**: Combines SIEM Lag, Throttling, and **Screen Shake** for maximum disruption.

---

## 5. Weekly Roadmap (Operational Calendar)

### 📅 Week 1: The Establishment
*   **Monday - Tuesday**: Phishing and manual SIEM searches.
*   **Wednesday**: First active malware beacons and **Lateral Movement**.
*   **Thursday**: Insider Threats and Shadow IT detection.
*   **Friday**: Zero-Day Ransomware and DDoS mitigation.
*   **Weekend**: Physical Infrastructure Audit (Sat) and Hardware Recovery (Sun).

### 📅 Week 2: Escalation & Paranoia
*   **Monday - Tuesday**: **Inheritance** (previous shortcuts resurface) and Supply Chain corruption.
*   **Wednesday**: **Whaling** (C-Suite targets) and Identity Protection.
*   **Thursday**: **Mole Hunt** and real-time forensic Wiper scripts.
*   **Friday**: **Total War**. 10-ticket gauntlet featuring memory injection, VPN RCE, and zero-click web shells.

---

## 6. SOC Analyst Toolbox

### 📊 SIEM Log Viewer (Evidence Attachment)
*   Search logs for technical indicators. Use **Drag-and-Drop** to attach a log to a ticket. A "Compliant" resolution requires finding the exact Log ID mentioned in the briefing.

### 📧 Email Analyzer (Triage)
*   Analyze **Headers** (SPF/DKIM), **Attachments**, and **Links**.
*   **Hidden Risk**: Quarantining without scanning can trigger "Missed Indicator" consequences.

### 💻 SOC Terminal (Active Response)
*   `scan [host]`: Verifies infection status.
*   `isolate [host]`: Removes host from network.
*   `trace [ip]`: Locates internal source of external traffic.
*   **Rigor Note**: In LEAD mode, terminal commands are delayed by DDoS attacks.

---

## 7. Procedural Indicator Registry
Inject these placeholders into custom tickets/logs to sync with the procedural truth engine.

| Standard Key | Alias (Shorthand) | Description |
| :--- | :--- | :--- |
| `{attacker_ip}` | **`{ip}`** | The external source of the attack. |
| `{victim_name}` | **`{victim}`** | The targeted employee's full name. |
| `{victim_host}` | **`{host}`** | The hostname of the compromised computer. |
| `{malicious_url}`| N/A | The phishing/C2 domain (e.g., evil.com). |

---

## 8. Testing with Debug Keys (F12)

*   **`F12`**: Toggle **Debug HUD**.
*   **`F1 / F2`**: Previous / Next Shift.
*   **`F9`**: Trigger **Manual Chaos**.
*   **`Shift + F1-F7`**: Jump to **Week 1** days.
*   **`Ctrl + F1-F5`**: Jump to **Week 2** days.
