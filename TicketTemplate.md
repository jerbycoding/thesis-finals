# Technical Documentation: Creating New Tickets

This document outlines the standard procedure for engineering new security incidents (tickets) within the *VERIFY.EXE* framework.

---

## 1. Resource Structure
All tickets are Godot Resources (`.tres`) based on `TicketResource.gd`.

### **Core Properties**
| Property | Type | Description |
| :--- | :--- | :--- |
| `ticket_id` | String | Unique identifier (e.g., `MALWARE-001`). Used for logic linkage. |
| `title` | String | User-facing title shown in the queue. |
| `description` | String | Detailed narrative. Use `\n` for line breaks. |
| `severity` | String | `Low`, `Medium`, `High`, or `Critical`. |
| `category` | String | Descriptive category (e.g., `Phishing`, `Forensics`). |
| `steps` | Array[String]| Step-by-step instructions (**MAX 3** for UI layout consistency). |
| `required_tool` | String | `siem`, `email`, `terminal`, `network`, `decryption`, or `none`. |
| `base_time` | Float | Timer duration in seconds (Default: 180.0). |
| `required_log_ids`| Array[String]| List of specific **Log IDs** (not ticket IDs) needed for **Compliant** resolution. |
| `on_complete_event`| String | (Optional) Narrative Event ID to trigger upon successful resolution. |
| `hidden_risks` | Array[String]| Technical indicators missed if the player rushes. Used for consequence generation. |

### **Kill Chain Metadata**
Used by the `ConsequenceEngine` to handle attack progression.
*   **`kill_chain_path`**: The name of the attack arc (e.g., "The Malware Outbreak").
*   **`kill_chain_stage`**: `1` (Delivery), `2` (Persistence), or `3` (Impact).
*   **`escalation_ticket`**: Link to the `.tres` file of the next stage.

---

## 2. Step-by-Step Creation Process

### **Step 1: Create the Resource**
1. In Godot, right-click `res://resources/tickets/` -> **New Resource**.
2. Select `TicketResource`.
3. Save as `Ticket[Name].tres`.

### **Step 2: Define Associated Evidence**
For a ticket to be "solvable" with a **Compliant** rating, you must create logs or emails that reference it.
*   **Discovery Link:** In your `LogResource` or `EmailResource`, set `related_ticket` to match the `ticket_id` of your ticket. This ensures the logs appear when the ticket is active.
*   **Resolution Link:** In your `TicketResource`, add the `log_id` of your evidence logs to the `required_log_ids` array. This ensures the "Attach Evidence" logic works.

---

## 3. Mandatory Rule: Resource Validation
The engine performs a safety check on all resources during discovery. If your ticket is missing a `ticket_id` or has a `base_time` of 0, **it will be ignored by the engine.**

**Checklist for a valid ticket:**
1. `ticket_id` is not empty.
2. `base_time` is greater than 0.
3. `steps` array contains **exactly 3 or fewer** items.

---

## 4. Advanced Logic: Hidden Risks & Consequences
If a ticket is resolved via **Efficient** or **Emergency** mode, the `ConsequenceEngine` checks the `hidden_risks` array to determine the "Price of Speed."
*   **Malware Logic:** If the risk text contains `"malware"` or `"clicked"`, a `MALWARE-CLEANUP` follow-up is scheduled.
*   **Breach Logic:** If the risk text contains `"breach"` or `"data"`, a `BREACH-REPORT` follow-up is scheduled.
*   **Fallback:** If no keywords are found, it defaults to a standard `FOLLOWUP-001`.

---

## 5. Tool-Evidence Consistency Requirements
| If `required_tool` is... | You MUST also create... | Linkage Method |
| :--- | :--- | :--- |
| **`siem`** | `LogResource` files. | Log `related_ticket` = Ticket `ticket_id`. |
| **`email`** | `EmailResource` files. | Email `related_ticket` = Ticket `ticket_id`. |
| **`terminal`** | Network Host state. | Hostname must exist in `NetworkState.gd` or individual `HostResource` files. |