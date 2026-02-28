# Protocol: Black Ticket Redemption

The **Black Ticket** is a critical, high-stakes forensic event that serves as the organization's "Last Chance" protocol. It is triggered only when the SOC has lost control of a major breach.

### 1. Trigger Conditions
The Redemption protocol is automatically initiated by the `ConsequenceEngine` if:
*   A **Stage 3 (Final Impact)** ticket is ignored or times out.
*   A **Stage 3** ticket is closed with an "Emergency" or "Efficient" bypass, and the resulting risk roll fails.

### 2. The Investigation (Discovery Style)

| Ticket ID | Discovery Style Description (Narrative Clue + [color=#006CFF]Anchor[/color]) | The Forensic Search Path (Discovery Logic) |
| :--- | :--- | :--- |
| **BLACK-TICKET-REDEMPTION** | "CRITICAL FAILURE RECOVERY. The board has initiated a full audit. You must employ [color=#006CFF]ZERO-TRUST FORENSICS[/color] to reconstruct the entire breach timeline. Identify the initial delivery vector, trace the lateral movement, and verify the exfiltration path to stabilize the organization." | **SIEM** (Search `REVEALED`) -> Locate all flashed logs from previous failures: `LOG-PHISH-001`, `LOG-MALWARE-001`, `LOG-EXFIL-001`, `LOG-NETWORK-001`, `LOG-AUTH-003`. |

---

### 3. Forensic Mechanics: The "Evidence Flash"
When the Black Ticket is active, the system employs an "Evidence Flash" mechanic. Missing logs from failed investigations are forcibly "Revealed" in the SIEM database.
*   **Visual Indicator:** Flashed logs appear with a specialized status in the forensic report.
*   **Investigation Depth:** The player must collect evidence from **all four primary threat paths** (Phishing, Malware, Data Breach, and Authentication) to satisfy the audit.

### 4. Strategic Payoff (Proposed)
*   **Integrity Reward:** Due to the extreme effort required (5 specific logs), successful completion is intended to provide a **+20.0 Integrity Restore**.
*   **Narrative Impact:** Completion "purges the record" of the analyst, preventing immediate termination (Fired ending) despite previous negligence.
