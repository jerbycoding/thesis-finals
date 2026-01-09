# 📅 **SPRINT 6: DEEPER SYSTEMS & GAMEPLAY VARIETY**
**Theme:** "Expand core systems to create more complex and varied gameplay loops."

---

## 🎯 **SPRINT GOAL**
**Deliver:** A more robust gameplay experience where evidence is more than just logs, the corporate world feels more alive, and player progress can be saved.

**Builds on Sprint 4/5:** Takes the established vertical slice and deepens its core mechanics, adding replayability and complexity.

---

## 📊 **ACCEPTANCE CRITERIA**
1. ✅ Evidence can be generated from the Email Analyzer tool.
2. ✅ At least one new ticket exists that requires non-log evidence.
3. ✅ The `CorporateVoice` system is implemented and used for all notifications.
4. ✅ A basic save/load system is functional.
5. ✅ The evidence tracking UI on tickets is updated for new evidence types.
6. ✅ Code is refactored to support the generic `EvidenceResource`.
7. ✅ No new critical bugs are introduced to the core loop.

---

## 📁 **FOLDER STRUCTURE ADDITIONS**
```
/incident_response_soc/
├── /autoload/ (ADDITIONS)
│   └── SaveManager.gd            # Handles saving and loading game state
├── /resources/ (ADDITIONS)
│   ├── EvidenceResource.gd       # NEW base class for all evidence types
│   └── evidence_types/ (NEW)
│       ├── EmailReport.gd        # Evidence generated from an email
│       └── CommandOutput.gd      # (Future) Evidence from a terminal command
└── /scenes/ui/ (ADDITIONS)
    └── EvidenceCard.tscn         # A generic UI card for displaying any evidence
```

---

## 📝 **DAY-BY-DAY TASKS**

### **DAY 1-2: THE EXPANDED EVIDENCE SYSTEM**
**Goal:** Refactor the evidence system to be generic and support evidence from the Email Analyzer.

**Tasks:**
1.  **Create Base Evidence Resource**
    -   Create `resources/EvidenceResource.gd`. This will be a simple base class.
    -   It should have properties like `evidence_id`, `source_tool` ("SIEM", "Email Analyzer"), and `description`.

2.  **Refactor `LogResource`**
    -   Modify `resources/logs/LogResource.gd` to extend `EvidenceResource` instead of just `Resource`.
    -   Ensure it still functions as a log while also being a valid piece of evidence.

3.  **Create `EmailReport` Evidence**
    -   Create `resources/evidence_types/EmailReport.gd`. It should extend `EvidenceResource`.
    -   Add properties to store key email data: `sender`, `subject`, `is_malicious`.

4.  **Modify `TicketResource`**
    -   Change `required_log_ids` and `attached_log_ids` to `required_evidence_ids` and `attached_evidence_ids` respectively.
    -   Update the `attach_log` function to a more generic `attach_evidence(evidence: EvidenceResource)`.

5.  **Update Email Analyzer UI**
    -   Add a new button to the Email Analyzer: "Export as Evidence".
    -   When clicked, this button should create a new `EmailReport` resource from the selected email and call `TicketManager.attach_evidence(...)`.

6.  **Update Ticket & SIEM UI**
    -   Modify the Ticket Queue UI to display a list of generic evidence instead of just logs.
    -   Ensure the SIEM's "Attach Log" button still works with the new generic system.

**Deliverable:** The player can successfully attach a "log" from the SIEM and an "email report" from the Email Analyzer to a ticket.

---

### **DAY 3: CORPORATE VOICE & IMMERSION**
**Goal:** Make all game feedback feel like it's coming from a unified, corporate entity.

**Tasks:**
1.  **Create `CorporateVoice.gd` Autoload**
    -   Implement the `translate(event, data)` function as designed in the Sprint 4 plan.
    -   Create key-value pairs for all notification text, UI tooltips, and ticket resolution messages.

2.  **Refactor `NotificationManager`**
    -   Modify `NotificationManager.show_notification` to accept an event key instead of a raw string.
    -   Have it call `CorporateVoice.translate()` to get the final display text.

3.  **Refactor UI Text**
    -   Go through the various UI scenes (`App_TicketQueue`, `App_EmailAnalyzer`, etc.) and replace hard-coded labels and tooltips with calls to the `CorporateVoice` system where appropriate.
    -   Example: A button tooltip might become `CorporateVoice.translate("tooltip_quarantine_button")`.

**Deliverable:** The game's text feels consistent and immersive, enhancing the corporate satire theme.

---

### **DAY 4: NEW CONTENT & GAMEPLAY**
**Goal:** Create a new gameplay challenge that uses the new evidence system.

**Tasks:**
1.  **Design a New Ticket**
    -   Create a new ticket resource file: `ticket_impersonation.gd`.
    -   **Concept:** An external party is impersonating an internal department. The player must prove it.
    -   `description`: "An employee reports a strange request from the 'IT Dept'. Verify the authenticity of the email."
    -   `severity`: "High"

2.  **Set New Evidence Requirements**
    -   On the new ticket, set `required_evidence_ids` to require two items:
        1.  The `EmailReport` from the suspicious email.
        2.  A `LogResource` from the SIEM showing failed authentication from the sender's supposed location.

3.  **Create Supporting Email and Logs**
    -   Create a new `email_impersonation.gd` that looks legitimate but has failing SPF/DKIM headers.
    -   Create a new `log_auth_failure.gd` that correlates with the impersonation attempt.

4.  **Integrate and Test**
    -   Add the new ticket to the `TicketManager`'s library so it can be spawned.
    -   Play through the new ticket from start to finish, ensuring both pieces of evidence are required for compliant completion.

**Deliverable:** A new, more complex ticket that requires the player to use two different tools to gather evidence.

---

### **DAY 5: SAVE/LOAD SYSTEM**
**Goal:** Allow players to save their progress between sessions.

**Tasks:**
1.  **Create `SaveManager.gd` Autoload**
    -   This singleton will handle the logic for saving and loading.

2.  **Implement `save_game()`**
    -   Create a dictionary to hold the game state.
    -   Save key information from singletons:
        -   `TicketManager`: List of completed and active ticket IDs.
        -   `ConsequenceEngine`: The choice log and NPC relationship scores.
        -   `NarrativeDirector`: The current shift timer or day number.
    -   Convert the dictionary to a JSON string.
    -   Save the string to a file in the `user://` directory (e.g., `user://savegame.json`).

3.  **Implement `load_game()`**
    -   Check if a save file exists.
    -   Load the JSON file and parse it.
    -   Iterate through the saved data and restore the state of each manager. This will involve writing "setter" functions in each manager (e.g., `TicketManager.set_state(saved_state)`).

4.  **Integrate with UI**
    -   Add a "Save and Quit" button to the end-of-shift report screen.
    -   Modify the main Title Screen to have a "Continue" button that calls `load_game()` if a save file is present.

**Deliverable:** A player can complete a shift, save and quit, and then "Continue" from the main menu, restoring their progress.
