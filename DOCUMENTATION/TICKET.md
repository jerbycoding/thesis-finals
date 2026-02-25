# Ticket System Documentation (Incident Engineering)

This document explains how to create and configure tickets for **VERIFY.EXE**. The ticket system is data-driven and uses `TicketResource` (.tres) files.

## 1. Core Logic & The "Root Cause" Box
The UI in the **Ticket Queue** is dynamic. It does not look at the ticket category to show investigation tools; it looks at the properties of the data.

### **Root Cause Identification Input**
The input box for entering an Attacker IP (C2 Server) appears **automatically** based on this rule:
*   **IF** `required_root_cause` is NOT empty: The Input Box is shown.
*   **IF** `required_root_cause` is empty: The Input Box is hidden.

**Usage:**
- Use `"{attacker_ip}"` to have the system randomly pick a procedural IP from the `VariablePool`.
- Use a hardcoded IP (e.g., `"192.168.1.50"`) for scripted narrative events.

---

## 2. Mandatory Fields for "High-Stakes" Tickets
If you are creating an advanced ticket (like the **TRN-005 Ransomware**), ensure these fields are configured:

| Field | Value | Effect |
| :--- | :--- | :--- |
| `category` | `"Ransomware"` | Unlocks the **Decryption Tool** (via `is_restricted` logic). |
| `required_root_cause` | `"{attacker_ip}"` | Forces the player to find the Foreign IP using `netstat`. |
| `required_tool` | `"decrypt"` | Signals to the player (and tutorial) that the Decryption tool is the primary closer. |
| `severity` | `"Critical"` | Increases the Integrity penalty if the ticket is ignored or timed out. |

---

## 3. Interaction with Terminal & SIEM
When a ticket is spawned, it generates a **Truth Packet**.
*   **SIEM Logs:** Logs starting with `LOG-[TicketID]` will automatically filter for this ticket.
*   **Terminal:** The `netstat` command will automatically show the value of `{attacker_ip}` as a **Foreign Address** (Red text) for the victim host.

---

## 4. Best Practices
1.  **Verify Before Action:** If a ticket requires the Decryption tool, ensure the player has a way to find the IP (usually via `netstat` on the infected workstation).
2.  **SOP Alignment:** Label tickets correctly. If it involves file encryption, use the **Ransomware** category so it matches the Handbook/SOP.
3.  **Kill Chain:** Use `kill_chain_stage` to determine how fast the consequence triggers if the ticket is ignored.
