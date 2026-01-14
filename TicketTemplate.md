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
| `steps` | Array[String]| Step-by-step instructions (Max 3 recommended). |
| `required_tool` | String | `siem`, `email`, `terminal`, or `none`. |
| `base_time` | Float | Timer duration in seconds (Default: 180.0). |
| `required_log_ids`| Array[String]| List of specific **Log IDs** (not ticket IDs) needed for **Compliant** resolution. |

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

### **Step 3: Automatic Registration**
**No manual code changes required.** The `TicketManager` automatically scans the `resources/tickets/` directory on startup. As long as your file is a valid `.tres` in that folder, it will be registered.

---

## 3. Mandatory Rule: Resource Validation
The engine performs a safety check on all resources during discovery. If your ticket is missing a `ticket_id` or has a `base_time` of 0, **it will be ignored by the engine.**

**Checklist for a valid ticket:**
1. `ticket_id` is not empty.
2. `base_time` is greater than 0.
3. `steps` array contains 3 or fewer items.

---

## 4. Implementation Example (Kill Chain)

### **Stage 1 Ticket (`PHISH-001`)**
*   **Kill Chain Path:** "Malware Outbreak" | **Stage:** 1
*   **Escalation Ticket:** `res://resources/tickets/TicketMalware001.tres`
*   **Logic:** If resolved via **Efficient/Emergency** mode, the `ConsequenceEngine` rolls for escalation. On failure, Stage 2 spawns automatically.

---

## 5. Tool-Evidence Consistency Requirements
| If `required_tool` is... | You MUST also create... | Linkage Method |
| :--- | :--- | :--- |
| **`siem`** | `LogResource` files. | Log `related_ticket` = Ticket `ticket_id`. |
| **`email`** | `EmailResource` files. | Email `related_ticket` = Ticket `ticket_id`. |
| **`terminal`** | Network Host state. | Hostname must exist in `NetworkState.gd` (or be discovered in ticket description). |