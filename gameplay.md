# Threat Engineering: The Kill Chain System

## 1. Overview
The **Kill Chain** system is a core gameplay mechanic in *Incident Response: SOC Simulator* designed to simulate the realistic progression of cyberattacks. Instead of tickets being isolated events, they are interconnected stages of an adversary's campaign. The player's effectiveness in earlier stages determines the severity of later stages.

## 2. The Three Stages of Attack

### Stage 1: Delivery (Low Severity)
*   **Goal:** Attacker attempts to gain a foothold.
*   **Ticket Types:** Phishing alerts, Social Engineering reports.
*   **Objective:** Identify the malicious intent and block the delivery mechanism (e.g., quarantine the email).

### Stage 2: Execution & Persistence (Medium/High Severity)
*   **Goal:** Attacker executes code or gains unauthorized access.
*   **Ticket Types:** Malware Beacons, Unauthorized Access logs, Suspicious Process alerts.
*   **Objective:** Contain the spread and identify compromised assets (e.g., isolate the workstation).

### Stage 3: Impact (Critical Severity)
*   **Goal:** Attacker achieves their objective (Damage/Theft).
*   **Ticket Types:** Ransomware encryption, Data Exfiltration, Service Outage.
*   **Objective:** Damage control and forensic investigation.

---

## 3. Escalation Logic
Threats escalate based on player decisions (or lack thereof).

| Player Action | Result | Escalation Risk |
| :--- | :--- | :--- |
| **Compliant Resolution** | Attack is stopped and documented. | **0%** |
| **Efficient Resolution** | Immediate threat closed, but root cause might remain. | **50%** (if evidence was missed) |
| **Emergency Resolution** | Immediate containment, but skipped forensics. | **75%** (often skips to Stage 3) |
| **Ignored / Timeout** | Attack progresses naturally. | **100%** |

---

## 4. Specific Kill Chain Paths

### Path A: The Malware Outbreak
1.  **PHISH-001:** Standard phishing email.
2.  **MALWARE-CONTAIN-001:** If Phish is ignored/rushed, a user clicks the link and malware installs.
3.  **RANSOM-001:** If Malware is not isolated, the attacker deploys ransomware.

### Path B: The Data Breach
1.  **SOCIAL-001:** Social engineering call/email for password reset.
2.  **INSIDER-001:** If successful, attacker uses compromised credentials to access restricted servers.
3.  **DATA-EXFIL-001:** Attacker begins moving sensitive data to an external IP.

---

## 5. Technical Implementation Goals
*   **ConsequenceEngine:** Acts as the "Dungeon Master," tracking active chains and scheduling the arrival of the next stage.
*   **Revealed Evidence:** When a Stage 2 ticket spawns, the logs that *would* have been found in Stage 1 should be "revealed" in the SIEM to help the player understand how they got there.
*   **Narrative Feedback:** NPCs (like the CISO) should comment on these escalations during shift briefings (e.g., "That phishing email you rushed yesterday just turned into a network-wide infection").

---

## 6. The Hybrid System
To ensure the game is both strategic and unpredictable, we employ a hybrid approach:
*   **Narrative Chains:** Interconnected tickets that follow the Kill Chain logic (e.g., Phish -> Malware -> Ransomware). These are the "Boss Fights" of the SOC world.
*   **Ambient Noise:** Procedural "Generic" tickets (e.g., standard Auth Failures, System Maintenance logs) that do not escalate. These serve to:
    *   Test the player's ability to prioritize under pressure.
    *   Prevent the player from assuming every alert is a critical part of a major breach.
    *   Simulate the high-volume environment of a real SOC.

## 8. Dynamic Shift Events
Beyond the ticket queue, the SOC environment is subject to real-time events that force the player to adapt their strategy. These are triggered by the `NarrativeDirector` to simulate the volatility of a real security operation.

### Event Categories:
| Event | Gameplay Effect | Player Impact |
| :--- | :--- | :--- |
| **"The Zero-Day"** | Emergency global alert. Workstation scans take 50% longer. | Forces careful planning of `scan` vs. `isolate`. |
| **"System Maintenance"** | SIEM Log Viewer UI "lags" or flickers for 30s. | Tests patience and ability to work with degraded tools. |
| **"The CISO's Walk-by"** | 3D interaction: CISO approaches for a verbal status update. | Breaks the 2D desktop "flow" and tests memory of active tasks. |
| **"False Flag Outage"** | Massive influx of "System Offline" logs (Routine Updates). | Tests the ability to quickly identify and ignore "Noise". |

## 9. Resource Monitor (Task Manager)
The Task Manager is the player's diagnostic tool for monitoring the health of their SOC workstation. It provides real-time telemetry that allows players to identify when a **Dynamic Shift Event** is affecting their performance.

### Key Diagnostics:
*   **CPU Load (Process Monitoring):** Spikes during "The Zero-Day" or when the ticket queue is overwhelmed. High CPU load causes tools to respond slower.
*   **Network Throughput:** Visualizes SIEM latency. If the network graph is erratic, the player knows that "System Maintenance" or a "False Flag Outage" is currently active.
*   **Event Correlation:** By observing the graphs, a player can determine if a slowdown is a localized tool issue or a global system event, allowing them to adjust their investigative pace.

## 10. Risk and Reward: The Temptation
To encourage strategic use of high-risk resolution types, we use the **Response Buffer** mechanic. This creates a dilemma: do you work slowly and safely, or do you take a risk to regain control of your queue?

| Resolution Type | Reward (The Temptation) | Penalty (The Risk) |
| :--- | :--- | :--- |
| **Compliant** | Perfect reputation and 0% escalation. | Queue continues to fill with ambient noise. |
| **Efficient** | **Noise Cancellation:** Stops procedural noise tickets for 60s. | 50% chance of threat escalation. |
| **Emergency** | **System Lockdown:** No new tickets arrive for 120s. | 75% chance of skipping straight to Impact Stage. |

## 11. Redemption: Post-Mortem Investigation
Failure is not the end. If a major escalation occurs (Stage 3), the player is offered a path to redemption through a **Black Ticket**.

*   **The Black Ticket:** A high-complexity forensic task with no timer.
*   **Requirement:** Requires 5 specific pieces of evidence from SIEM, Terminal, and Email.
*   **The Payoff:** Successful completion reduces the "Risks Taken" count by 2 and resets CISO relationship to "Neutral," allowing the analyst to save their career after a disaster.

## 12. Visual Clarity: The Evidence Flash
When a threat escalates and new logs are "revealed," the player must be notified immediately to facilitate learning from the mistake.

*   **Icon Glow:** The SIEM desktop icon pulses with a **Magenta Glow** when escalation-related evidence is added.
*   **Log Tagging:** Inside the SIEM Viewer, new evidence logs are highlighted and prefixed with a `[REVEALED]` tag.
*   **Discovery Moment:** This ensures the player realizes that the "Signal" was there all along, but was missed due to their previous rushing.




