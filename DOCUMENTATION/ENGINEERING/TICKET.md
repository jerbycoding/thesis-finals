# Ticket System Documentation (Incident Engineering)

This document explains how to create and configure tickets for **VERIFY.EXE**. The ticket system is data-driven, utilizing the `VariableRegistry` to ensure technical indicators (IPs, Hostnames) are consistent across all tools.

---

## 1. Technical Integrity: The "Resource Triad"
A ticket should never be created in isolation. For a high-quality incident, follow the **Triad Rule**:

1.  **The Ticket (.tres)**: Defines the goal, severity, and required evidence.
2.  **The Log (.tres)**: Provides the technical "Anchor." It MUST contain variables like `{attacker_ip}` or `{victim_host}` so the player can "find" them.
3.  **The Email (.tres)**: Provides the narrative "Intent" (e.g., a phishing lure). Its `related_ticket` field must match the Ticket ID.

---

## 2. Dynamic UI & Root Cause Logic
The **Ticket Queue** UI adapts based on the data provided in the resource file.

### **Root Cause Identification**
The input box for entering an IP or Hostname appears **automatically** based on this rule:
*   **IF** `required_root_cause` is NOT empty: The Input Box is shown.
*   **Usage**: Use `"{attacker_ip}"` to force the player to find the C2 IP. The system will validate their typing against the procedural IP generated for that shift.

### **Technical Fulfillment (Terminal Commands)**
Some tickets require active defense before they can be closed.
*   **`required_host_isolation`**: If set to `"{victim_host}"`, the player MUST run the `isolate` command in the Terminal on that specific host before the "Close Ticket" button is enabled.
*   **`required_host_restoration`**: Used for follow-up tickets where a host must be brought back online using the `restore` command.

---

## 3. Tool Provisioning (Permissions)
The `DesktopWindowManager` uses the ticket's metadata to unlock restricted tools. Ensure these match:

| Tool Needed         | Required Category | Required Tool ID |
|:--------------------|:------------------|:-----------------|
| **Decryption Tool** | `"Ransomware"`    | `"decrypt"`      |
| **Network Mapper**  | `"System"`        | `"network"`      |
| **SOC Terminal**    | Any               | `"terminal"`     |

---

## 4. Cross-Tool Interaction Details
*   **SIEM Integration**: Logs with `related_ticket = "TICKET-ID"` are automatically revealed when that ticket is spawned.
*   **Terminal Integration**: The `netstat` command scans the Ticket's truth packet. If the player runs `netstat` on the `{victim_host}`, the `{attacker_ip}` will appear in **RED** as an established connection.
*   **Email Integration**: The Email Analyzer will only show emails where the `related_ticket` matches the active ticket ID.

---

## 5. Technical Integrity Checklist (Pre-Flight)
Before saving a new `.tres` file, verify:
1.  **Anchor Check**: Does at least one Log contain the `{attacker_ip}`? (Otherwise, the Root Cause box is unsolvable).
2.  **ID Consistency**: Does the `required_log_ids` array in the Ticket match the `log_id` field in the Log resources?
3.  **Fulfillment**: If the ticket says "Isolate the host," is the `required_host_isolation` field populated?
4.  **Variables**: Are you using `{attacker_ip}` instead of a hardcoded IP? (Hardcoded IPs break the `netstat` and `trace` logic).
