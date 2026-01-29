# 🚀 VERIFY.EXE: Content Expansion Guide

Welcome to the **SOC Analyst Content Creator Manual**. 

Following the Phase 4 refactor, **VERIFY.EXE** is now fully data-driven. This means you can add hours of gameplay—new mysteries, complex breaches, and narrative twists—by simply creating and editing Resource files (`.tres`) in the Godot Editor. **No GDScript knowledge is required.**

---

## 📋 The Golden Rule: "Convention over Coding"
The system is built to find your content automatically. If you put a file in the right folder and name it correctly, the game will "just work."

---

## 🛠️ Content Types & How to Expand Them

### 1. Security Incident Tickets (`TicketResource`)
*   **Location:** `res://resources/tickets/`
*   **How to expand:** Create a new `TicketResource`.
*   **Key Fields:**
	*   `Ticket ID`: Must be unique (e.g., `MALWARE-005`).
	*   `Required Log IDs`: List the IDs of logs the player *must* find and attach for a "Compliant" win.
	*   `Required Host Isolation`: If the player needs to isolate a computer to solve the case, put the hostname here (e.g., `WORKSTATION-12`).
	*   **Kill Chain:** Use `Escalation Ticket` to point to another resource. This creates multi-stage "Boss" incidents.

### 2. Forensic Evidence & Noise (`LogResource`)
*   **Location:** `res://resources/logs/`
*   **How to expand:** 
	*   **Evidence:** Create a log and set its `Related Ticket` to a Ticket ID. It will only appear when that ticket is active.
	*   **Ambient Noise:** To add more "flavor" logs that appear in the background, edit `res://resources/NoiseLogPool.tres`. Add new messages or hostnames to the arrays.

### 3. Email Analysis (`EmailResource`)
*   **Location:** `res://resources/emails/`
*   **How to expand:** Create a new `EmailResource`.
*   **Investigative Depth:** 
	*   Use `Quarantine Hidden Risks` to punish players who don't scan. 
	*   *Example:* If you add `{"attachments": "malware_outbreak"}` to this dictionary, and the player quarantines without clicking "Scan Attachments," a malware outbreak will trigger!

### 4. NPC Dialogues (`DialogueDataResource`)
*   **Location:** `res://resources/dialogue/`
*   **The Naming Magic:** Dialogues are loaded automatically based on filename.
	*   **Convention:** `[npc_id]_[dialogue_id].tres`
	*   *Example:* To add a new talk for the CISO about a zero-day, name it `ciso_zero_day_talk.tres`.
	*   *To Trigger:* In a `ShiftResource`, create an event of type `npc_interaction` with `dialogue_id: "zero_day_talk"`.

### 5. SOC Handbook (`HandbookPage`)
*   **Location:** `res://resources/handbook/`
*   **How to expand:** Create a new `HandbookPage` resource. 
*   **Dynamic UI:** The "Handbook" app on the desktop scans this folder and creates a navigation button for every page it finds. No UI editing needed!

### 6. Procedural Truth (`VariablePool`)
*   **Location:** `res://resources/VariablePool.tres`
*   **How to expand:** Add new names, malicious domains, or attacker IPs to the lists in this file. Every ticket in the game will now have a chance to use your new data for its "randomized" details.

---

## 📅 Creating a New Shift (`ShiftResource`)
Shifts are the "levels" of the game. They coordinate everything else.

1.  Create a `ShiftResource` in `res://resources/shifts/`.
2.  **Briefing:** Set `Briefing Dialogue ID`. (e.g., if you set it to `intro`, the game looks for `ciso_intro.tres`).
3.  **Event Sequence:** This is your timeline.
	*   `Time 10`: Spawn `PHISH-001`
	*   `Time 60`: Trigger `npc_interaction` with `senior_analyst`.
	*   `Time 120`: Trigger `system_event` (e.g., `SIEM_LAG`).
4.  **Progression:** Set `Next Shift ID` to the ID of the shift the player should play tomorrow.

---

## 🔍 Verification: Is my content broken?
We have built an automated Auditor to help you.
1.  Run the game.
2.  Check the **Output Log** in Godot.
3.  Look for the `--- 🔍 RESOURCE CONNECTIVITY AUDIT START ---` section.
4.  It will tell you if a Shift spawns a Ticket that doesn't exist, or if a Ticket requires a Log that is missing.

---

**Tip:** When in doubt, duplicate an existing `.tres` file and modify its properties! 🛠️
