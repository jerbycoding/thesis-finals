# Developer Specification: Incident & Evidence Engineering

This document provides the technical "Source of Truth" for developers creating `TicketResource`, `LogResource`, and `EmailResource` integrations. Use this to ensure that tools (Terminal, SIEM, Email) interact correctly with your data.

---

## 1. The Procedural Variable Registry
The `VariableRegistry` (and `VariablePool.tres`) provides the data that populates placeholders. **Never hardcode IPs or Hostnames in resources.**

| Variable | Description | Typical Use |
| :--- | :--- | :--- |
| `{attacker_ip}` | The C2/Malicious source IP. | Root cause input, `netstat` output, `trace` target. |
| `{malicious_url}` | The phishing/payload domain. | Email body, Link Analyzer, DNS logs. |
| `{victim_host}` | The hostname of the infected machine. | Terminal `scan`/`isolate` target, Log source. |
| `{victim_name}` | The employee targeted. | Email recipient, Authentication logs. |
| `{dept}` | The department of the victim. | Narrative context. |

---

## 2. Terminal Integration Hooks
The Terminal is the primary "Active Defense" tool. It queries the **Active Ticket's Truth Packet**.

### **Scanning & Isolation**
*   **Trigger**: `required_host_isolation = "{victim_host}"`
*   **Behavior**: When the player runs `isolate [hostname]`, the `TerminalSystem` checks if the hostname matches the resolved value of `{victim_host}`. 
*   **Result**: If it matches, `ticket.is_technically_fulfilled` becomes `true`. The "Close Ticket" button will remain disabled until this is done.

### **Netstat (C2 Identification)**
*   **Logic**: If a player runs `netstat [victim_host]`, the Terminal looks for `{attacker_ip}` in the ticket's `truth_packet`.
*   **Display**: It will display an "ESTABLISHED" connection to that IP in **RED** to signal it is the malicious beacon.

---

## 3. Email Forensics Hooks
The `EmailAnalyzer` is a diagnostic tool.

### **Link Analysis**
*   **Field**: `suspicious_domain`
*   **Integration**: If this matches `{malicious_url}`, the tool will flag it as **BLACKLISTED**.
*   **Hidden Risk**: Setting `quarantine_hidden_risks = {"links": "id"}` will trigger a specific consequence if the user ignores the link scan and simply archives the email.

### **Attachment Analysis**
*   **Logic**: Any attachment in the `attachments` array ending in `.exe`, `.bat`, or `.scr` is automatically flagged as **MALICIOUS** by the scanner.

---

## 4. SIEM & Log Evidence Logic
The SIEM handles the "Forensic Proof" (Log Attachment).

### **Strict Identification**
*   **Field**: `required_log_ids` (Array)
*   **Logic**: Every ID in this array **must** be present in the `attached_log_ids` of the ticket for the **COMPLIANT** resolution strategy to be available.
*   **Best Practice**: Ensure at least one required log contains the `{attacker_ip}` to prove the root cause.

---

## 5. Resolution Strategies & Scaling
Resolution is handled in `ValidationManager.gd`.

| Strategy | Requirement | Metric Impact |
| :--- | :--- | :--- |
| **COMPLIANT** | `has_sufficient_evidence() == true` | +Integrity, -Heat. |
| **EFFICIENT** | None (Can close any time). | -Integrity, +Heat, Triggers Escalation. |
| **EMERGENCY** | Active "Red Alert" (Shift-driven). | --Integrity, ++Risk. |

---

## 6. The "Golden Thread" Checklist
When creating a new incident chain, verify this "Golden Thread" of data:
1. **The Phish**: Email contains `{malicious_url}`.
2. **The Connection**: SIEM Log shows `{victim_host}` connecting to `{attacker_ip}`.
3. **The Proof**: Log contains the message: "Beacon detected to {malicious_url}".
4. **The Lock**: Ticket `required_root_cause` set to `"{attacker_ip}"`.
5. **The Action**: Ticket `required_host_isolation` set to `"{victim_host}"`.
