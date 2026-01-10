# 📅 **SPRINT 5: WEEK 5 - EXPANSION & PERSISTENCE**
**Theme:** "Add replayability and create a persistent world"

## 🎯 **SPRINT GOAL**
**Deliver:** A game loop that extends beyond the first shift, with more content and a functional save/load system.

**Builds on Sprint 4:** Addresses the content gaps from the vertical slice, adds ticket variety, and implements the foundational save/load system required for a longer campaign.

---

## 📊 **ACCEPTANCE CRITERIA**
1. ✅ All content from Sprint 4 plan is present (narrative/audio folders).
2. ✅ At least 3 new, distinct incident tickets are created and playable.
3. ✅ A "Second Shift" narrative arc is implemented with increased difficulty.
4. ✅ A save/load system is functional, persisting shift progress, tickets, and player stats.
5. ✅ The title screen is updated with a "Continue" button that uses the save system.
6. ✅ Code is documented, especially the save/load logic.
7. ✅ No new critical bugs are introduced.

---

## 📁 **FOLDER STRUCTURE ADDITIONS**
```
/incident_response_soc/
├── /resources/narrative/ (NEW from S4 plan)
│   ├── arc_first_shift.tres
│   ├── dialogue_ciso.json
│   └── archetype_definitions.json
├── /resources/tickets/ (ADDITIONS)
│   ├── ticket_ransomware_01.gd
│   ├── ticket_insider_threat_01.gd
│   └── ticket_social_eng_01.gd
├── /assets/sfx/polish/ (NEW from S4 plan, assuming assets folder)
│   ├── consequence_alert.ogg
│   ├── ui_hover.ogg
│   └── ticket_spawn.ogg
└── /autoload/ (ADDITION)
    └── SaveSystem.gd           # Handles saving and loading game state
```

---

## 📝 **DAY-BY-DAY TASKS**

### **DAY 1: Finish Sprint 4 & Plan Content**
*   **Goal:** Fulfill the missing content requirements from the previous sprint and design the new content.
*   **Tasks:**
    1.  **Create Missing Directories:** Create `/resources/narrative/` and `/assets/sfx/polish/`.
    2.  **Create Placeholder Content:** Add placeholder `.tres`, `.json`, and `.ogg` files to these new directories. This makes the project structure match the plan and ready for assets.
    3.  **Define 3 New Tickets:**
        *   `ticket_ransomware_01`: A high-pressure ticket requiring immediate server isolation via the terminal.
        *   `ticket_insider_threat_01`: A subtle ticket requiring the player to cross-reference SIEM logs with email records to find a suspicious employee.
        *   `ticket_social_eng_01`: A non-technical ticket involving manipulating NPC dialogue choices to gain information.
    4.  **Design "Second Shift" Arc:** Outline the sequence of events. The consequences of the first shift (e.g., a poorly handled ticket) are now active. NPCs will have new dialogue based on the player's archetype.

*   **Deliverable:** Project structure is 100% aligned with the documented plan. New content for Sprint 5 is designed and ready for implementation.

### **DAY 2: Save/Load System - Saving**
*   **Goal:** Implement the core logic for saving the game's state.
*   **Tasks:**
    1.  **Create `SaveSystem.gd`:** Add it as an autoload singleton.
    2.  **Define Save Data Structure:** Determine precisely what needs to be saved (e.g., current shift number, player archetype, NPC relationship values, network host states, active/completed tickets, archetype metrics).
    3.  **Implement `save_game()` function:** This function will gather data from all relevant singletons (`TicketManager`, `NetworkState`, `ArchetypeAnalyzer`, etc.), convert the dictionary to a JSON string, and save it to `user://savegame.json`.
    4.  **Integrate with UI:** Add a temporary "Save and Quit" button to the desktop UI that calls `SaveSystem.save_game()`.

*   **Deliverable:** A `savegame.json` file is created in the user data directory containing the current, accurate game state.

### **DAY 3: Save/Load System - Loading**
*   **Goal:** Implement the logic to load a saved game state and make it accessible.
*   **Tasks:**
    1.  **Implement `load_game()` function:** This function will read the JSON file, parse it, and then carefully distribute the loaded data to the correct systems. To make this robust, each manager singleton should get a `load_state(data)` function.
    2.  **Handle Scene Transitions:** After loading data, the game must transition to the correct scene (e.g., the 2D desktop).
    3.  **Update Title Screen:** Add a "Continue" button. This button should be disabled if no save file exists. When clicked, it will call `SaveSystem.load_game()` and transition into the game.

*   **Deliverable:** The "Continue" button on the title screen successfully loads a saved game and restores the player's state.

### **DAY 4: Content Implementation**
*   **Goal:** Create the new tickets and the "Second Shift" experience.
*   **Tasks:**
    1.  **Create New Ticket Resources:** Implement the three new ticket `.gd` resource files as designed on Day 1.
    2.  **Script the "Second Shift":** In `NarrativeDirector`, create a `second_shift_arc` event array. Add triggers for the new tickets and new NPC dialogue that checks the player's saved archetype.
    3.  **Integrate New Audio:** Hook up the placeholder audio files from Day 1 to game events using `AudioManager`.

*   **Deliverable:** The three new tickets are playable and the second shift can be started from a loaded game.

### **DAY 5: Integration, Testing & Polish**
*   **Goal:** Ensure all new features work together seamlessly and are stable.
*   **Tasks:**
    1.  **Full Loop Testing:** Play through Shift 1, save, quit, use "Continue", and play through Shift 2.
    2.  **Save/Load Edge Case Testing:** Save in the middle of a ticket, during dialogue, and with consequences pending. Ensure the game always loads into a stable state.
    3.  **Bug Fixing & Documentation:** Address any crashes or logical errors. Add comments to `SaveSystem.gd` and the data-loading functions in other managers.

*   **Deliverable:** A stable build where a player can complete Shift 1, save, and continue into Shift 2 without critical errors.
