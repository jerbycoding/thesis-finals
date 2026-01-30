# 🎫 Security Incident Tickets

Tickets are the core unit of gameplay in **VERIFY.EXE**. They represent security alerts that the analyst must investigate and resolve within a specific timeframe.

---

## 1. Ticket Anatomy
Each ticket is defined as a `TicketResource` and contains:
*   **Ticket ID:** Unique identifier (e.g., `PHISH-001`, `MALWARE-CONTAIN-001`).
*   **Severity:** Determines time pressure and impact (Low, Medium, High, Critical).
*   **Required Tool:** Guidance on which desktop application is primary for the investigation.
*   **Steps:** A checklist of 3 mandatory actions to guide the player.
*   **Required Logs:** Specific forensic log IDs that must be attached for a "Compliant" resolution.
*   **Technical Truth:** Procedurally generated data (IPs, Hostnames) that ensure technical consistency across tools.

---

## 2. The Lifecycle of a Ticket

### A. Spawning
Tickets enter the queue through three methods:
1.  **Narrative Sequence:** Scripted events defined in `ShiftResource.tres`.
2.  **Kill Chain Escalation:** Triggered by `ConsequenceEngine.gd` when a previous threat wasn't fully neutralized.
3.  **Ambient Noise:** Procedural "distraction" tickets spawned by `TicketManager.gd` to test player prioritization.

### B. Investigation
Players must use the desktop tools to find evidence matching the ticket's "Technical Truth."
*   **Email Analyzer:** Inspecting headers and links for phishing indicators.
*   **SIEM Log Viewer:** Finding matching connection logs.
*   **Terminal:** Scanning hosts to verify infections.

### C. Evidence Attachment
To justify a resolution, players must **drag and drop** relevant logs from the SIEM onto the ticket in the Queue app.

---

## 3. Resolution Strategies
When a ticket is ready to be closed, the player must choose a strategy via the **Completion Modal**.

| Strategy | Requirement | Risk | Integrity Impact |
| :--- | :--- | :--- | :--- |
| **Compliant** | All required evidence attached. | Lowest | **+5.0 (Gain)** |
| **Efficient** | Can be closed at any time. | 50% Escalation Risk | **-2.0 (Loss)** |
| **Emergency** | Crisis bypass (any time). | 75% Escalation Risk | **-5.0 (Loss)** |
| **Timeout** | Failure to act. | 100% Escalation Risk | **-10.0 (Loss)** |

---

## 4. Kill Chains & Escalation
Many tickets are linked through a **Kill Chain Path**.
*   **Inheritance:** If a Stage 1 ticket (e.g., Phishing) is closed as "Efficient," the `HeatManager.gd` caches the missed vulnerability.
*   **Escalation:** The next stage (e.g., Malware Beacon) will spawn later, inheriting the same Attacker IP and Victim Host from the original mistake.
*   **Redemption:** If the player falls too far into procedural debt, they may be offered a **Black Ticket**—a complex, multi-evidence post-mortem that resets their record.

---

## 5. Procedural Truth
The `VariableRegistry.gd` ensures that every ticket feels unique yet consistent. 
*   When `PHISH-001` spawns, it generates a "Truth Packet."
*   The **Attacker IP** in the email headers will match the **Source IP** in the SIEM logs.
*   The **Victim Host** in the alert will be the same host the player must `scan` in the Terminal.
