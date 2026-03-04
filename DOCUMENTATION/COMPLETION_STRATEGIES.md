# Completion Strategies (Incident Resolution)

This document defines the technical and narrative impact of how an analyst chooses to close a ticket in **VERIFY.EXE**. Every resolution is a trade-off between **Operational Speed** and **Systemic Integrity**.

---

## 1. Resolution Types & Metrics

The `IntegrityManager` and `HeatManager` use these completion types to calculate organizational stability and future threat difficulty.

| Strategy | Integrity (HP) | Evidence Req. | Outcome / Penalty |
| :--- | :--- | :--- | :--- |
| **COMPLIANT** | **+5.0% (Heal)** | **FULL** | Threat Neutralized. Kill Chain broken. |
| **EFFICIENT** | **-2.0% (Minor)** | **NONE** | **Inheritance**: Threat indicators cached for future shifts. |
| **EMERGENCY** | **-5.0% (Major)** | **NONE** | **Consequence**: Immediate follow-up incident triggered. |
| **TIMEOUT** | **-10.0% (Crit)** | **N/A** | **Escalation**: Threat moves to the next Kill Chain stage. |

---

## 2. Technical Gates (The "Grip")

A ticket cannot be closed as **COMPLIANT** unless the following "Grip" conditions are met in the `TicketResource`:

### **A. Forensic Proof (Logs)**
*   The `required_log_ids` array must be a subset of the `attached_log_ids`.
*   *Developer Tip:* Ensure required logs contain the procedural variables (e.g., `{attacker_ip}`) to ensure the player can actually find the proof.

### **B. Root Cause Identification**
*   If `required_root_cause` is set (e.g., to `"{attacker_ip}"`), the player must type the correct resolved value into the Root Cause box.
*   The status will remain **[REQUIRED]** in red until a match is detected.

### **C. Technical Fulfillment**
*   If `required_host_isolation` is set, the player must execute the `isolate` command via the Terminal on the correct host.
*   This sets `is_technically_fulfilled = true` on the ticket instance.

---

## 3. The "Efficient" Shortcut (Vulnerability Inheritance)

Choosing **EFFICIENT** is a "Cowboy" move. It clears the queue but creates "Technical Debt."

1.  **Caching**: The `HeatManager` stores the `{attacker_ip}` and `{victim_host}` in a FIFO buffer.
2.  **Resurfacing**: When a new high-severity ticket spawns, the `TicketManager` pops a vulnerability from the buffer.
3.  **Forced Inheritance**: The new incident is **forced** to use the indicators from your previous Efficient closure.
    *   *Narrative Logic:* Because you didn't verify the root cause, the attacker maintained persistence and has now returned with a Ransomware payload.

---

## 4. Timeout & Escalation (The "Cost of Silence")

If a ticket expires (Timer hits 0:00), it is processed as a **TIMEOUT**.

*   **Integrity Hit**: The maximum possible penalty (-10%).
*   **Kill Chain Advancement**: If the ticket has an `escalation_ticket` defined, that new ticket is spawned immediately with **Critical** priority.
*   *Example:* Ignoring a Phishing alert (`Stage 1`) results in a Malware Outbreak (`Stage 2`) on the same host 10 seconds later.

---

## 5. Developer Implementation
*   **Validation**: Handled via `ValidationManager.is_resolution_allowed()`.
*   **Archetypes**: The `ArchetypeAnalyzer` tracks the ratio of these completions to determine if the player is a "Cowboy" (High Efficient) or "By-the-Book" (High Compliant).
