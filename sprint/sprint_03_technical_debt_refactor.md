# Sprint 3: Architectural Consolidation & Refactoring

This sprint focuses on resolving the technical debt identified during the prototype phase. The goal is to move from hardcoded logic to a fully data-driven system and standardize UI construction to improve scalability and maintainability.

## 🎯 Primary Objectives
1.  **Standardize UI:** Move SIEM log entry construction from code to Scene-based templates.
2.  **Data-Driven Narrative:** Decouple shift progression from hardcoded singletons into the `ShiftResource`.
3.  **Timer Safety:** Implement a centralized timer management system to prevent "ghost" events.
4.  **Decouple Systems:** Reduce circular dependencies and simplify the `SaveSystem` data collection.

---

## 🛠️ Task Breakdown

### 1. UI Standardization (Standardizing the "Cyber" Aesthetic)
*   [ ] **Task 1.1:** Create `res://scenes/2d/apps/components/LogEntry.tscn`.
    *   Design a visual template for SIEM logs that matches `TicketCard.tscn`.
*   [ ] **Task 1.2:** Refactor `App_SIEMViewer.gd`.
    *   Replace manual `PanelContainer.new()` logic with `PackedScene.instantiate()`.
    *   Implement an `update_log(log: LogResource)` method on the new scene.

### 2. Data-Driven Shift Progression
*   [ ] **Task 2.1:** Update `ShiftResource.gd`.
    *   Add `@export var next_shift: ShiftResource` to allow linking shifts in the Inspector.
*   [ ] **Task 2.2:** Refactor `App_ShiftReport.gd`.
    *   Remove the hardcoded `match` statement in `_on_continue_pressed`.
    *   Update logic to pull the next briefing from the current shift's `next_shift` property.
*   [ ] **Task 2.3:** Refactor `SaveSystem.gd`.
    *   Stop hardcoding `"second_shift"`. Save the resource path of the next active shift instead.

### 3. Centralized Time & Event Management
*   [ ] **Task 3.1:** Create `res://autoload/TimeManager.gd`.
    *   Implement a system to track active timers.
    *   Provide `register_timer(id, duration, callback)` and `clear_all_timers()` for safe shift transitions.
*   [ ] **Task 3.2:** Refactor `ConsequenceEngine.gd`.
    *   Migrate fire-and-forget `get_tree().create_timer()` calls to the new `TimeManager`.

### 4. Code & Content Cleanup
*   [ ] **Task 4.1:** standardizing `TicketManager` mapping.
    *   Clean up `_prepare_library` fuzzy matching. Enforce a naming convention (e.g., `Ticket_ID.tres`).
*   [ ] **Task 4.2:** File System Purge.
    *   Delete `New Text Document.txt` and `.tmp` files found in `scenes/2d/apps/components/`.
    *   Remove legacy `.gd.uid` and `.tres.uid` orphans if they no longer match valid files.

---

## 📈 Success Criteria
*   **Visual Consistency:** Modifying one `.tscn` file updates all Log entries across the SIEM.
*   **Scalability:** Adding a new shift requires ZERO changes to `.gd` files.
*   **Stability:** Ending a shift mid-consequence does not trigger errors or ghost tickets in the next session.
*   **Testing:** `SaveSystem` correctly restores the exact stage of theAPT Kill Chain.
