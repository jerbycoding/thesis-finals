# Concrete Plan: Expanding the Consequence Engine

This document outlines a three-phase plan to expand the functionality of the `ConsequenceEngine` to make gameplay more dynamic and responsive to player actions.

---

### **Phase 1: Better Follow-up Tickets (Easy)**

**Goal:** Make consequences feel less generic by using specific, pre-designed tickets from the resource folder instead of creating generic ones on the fly.

*   **Step 1.1:** Create a new, specific ticket resource (e.g., `ticket_malware_outbreak.gd`) for when a player misses a significant malware threat. This ticket will have its own unique description, steps, and requirements.
*   **Step 1.2:** Refactor the `_spawn_followup_ticket` function in `ConsequenceEngine.gd`. It will be modified to load and instance a ticket from a given file path (`res://...`) instead of creating a generic `TicketResource` from scratch.
*   **Step 1.3:** Update the functions that trigger consequences (like `_trigger_hidden_risk_consequence`) to call the new logic, providing the full path to a specific ticket resource.

---

### **Phase 2: Consequences for Email Decisions (Medium)**

**Goal:** Make the player's choices in the Email Analyzer have direct, tangible consequences that are managed by the central `ConsequenceEngine`.

*   **Step 2.1:** Analyze `EmailSystem.gd` to understand and centralize its current consequence logic.
*   **Step 2.2:** Create another new ticket resource (e.g., `ticket_user_complaint.gd`) to be spawned when the player incorrectly quarantines a legitimate, urgent email.
*   **Step 2.3:** Add logic to `ConsequenceEngine.gd`'s `log_email_decision` function. This function will now be responsible for triggering specific follow-up tickets based on the player's decision (e.g., approving a malicious email spawns `ticket_malware_outbreak.gd`).
*   **Step 2.4:** Refactor `EmailSystem.gd` to ensure it only calls `ConsequenceEngine.log_email_decision` and does not handle any consequence logic itself.

---

### **Phase 3: Tool Lockout Consequence (Medium)**

**Goal:** Introduce a new, non-ticket-based penalty: making a tool temporarily unavailable after a critical mistake.

*   **Step 3.1:** Add state-tracking variables to `GameState.gd` to keep a record of which tools are locked (e.g., a dictionary like `{"email": false, "terminal": false}`).
*   **Step 3.2:** Create new functions in `GameState.gd`: `lock_tool(tool_name, duration)` and `is_tool_locked(tool_name)`. The `lock_tool` function will use a `Timer` to automatically unlock the tool after the specified duration.
*   **Step 3.3:** In `ConsequenceEngine.gd`, add a new type of consequence that calls `GameState.lock_tool()`. This could be triggered by a specific hidden risk, like using a dangerous terminal command incorrectly.
*   **Step 3.4:** Update the `open_app` function in `computer_desktop.gd`. Before opening an application window, it will first call `GameState.is_tool_locked()`. If the tool is locked, it will use the `NotificationManager` to show a message like "Terminal is locked for security review" and will not open the app.
