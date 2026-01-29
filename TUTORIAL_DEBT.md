# 📉 TUTORIAL TECHNICAL DEBT
**Project:** VERIFY.EXE (Incident Response SOC Simulator)
**Status:** Functional (High Debt)

This document tracks technical debt accumulated during the implementation of the **Tier 1 SOC Certification** onboarding system. These items should be addressed to ensure long-term maintainability and prevent regression bugs.

---

## 🚨 High Priority (Architectural Risks)

### 1. Enum-to-Resource Desynchronization
*   **Context:** `TutorialStepResource.gd` uses an `enum TriggerType`. Godot serializes these as **integers** inside `TutorialSequence.tres`.
*   **Risk:** Adding a new trigger type to the middle of the enum will shift all integer values, breaking every single step in the `.tres` file.
*   **Requirement:** Transition to string-based trigger IDs or a custom serialization wrapper.

### 2. Hardcoded Narrative Spawning
*   **Context:** `TutorialManager.gd` contains explicit checks for `TRN-002` and `TRN-003` to handle their spawning logic.
*   **Risk:** Adding new tutorial steps or changing the narrative flow requires modifying core GDScript rather than just updating data.
*   **Requirement:** Add a `spawn_ticket_id` property to `TutorialStepResource` so the manager can execute spawns dynamically.

---

## 🛠️ Medium Priority (Code Quality)

### 3. Imperative Cleanup Pattern
*   **Context:** `TutorialManager` manually calls `clear_active_data()` on `TicketManager`, `LogSystem`, and `EmailSystem` during cleanup.
*   **Risk:** New systems added to the game will persist tutorial data unless the developer remembers to manually add them to the tutorial's purge list.
*   **Requirement:** Implement a `LifecycleSubscriber` or `IShiftState` interface so systems can reset themselves automatically when `EventBus.shift_ended` is emitted.

### 4. "God Object" Manager
*   **Context:** `TutorialManager` currently manages logic (state), visuals (HUD/Overlay instantiation), and input (Debug F11).
*   **Risk:** Low cohesion makes unit testing nearly impossible and increases the likelihood of side effects when modifying UI.
*   **Requirement:** Split into `TutorialLogicController` and `TutorialUIController`.

---

## 🧹 Low Priority (Polishing)

### 5. Transition Hardcoding
*   **Context:** The path to the Main Menu (`res://scenes/ui/TitleScreen.tscn`) is hardcoded in the manager.
*   **Risk:** Folder refactoring will crash the game at the end of the tutorial.
*   **Requirement:** Centralize scene paths in `GlobalConstants.gd`.

### 6. Debug Pollution
*   **Context:** `F11` shortcuts and `TRN-003` logic exist directly in the production `TutorialManager.gd`.
*   **Requirement:** Move all debug-only interactions to a dedicated `DebugManager` overlay.

---

## ✅ Resolved Debt (Archive)
*   [x] **Index Mismatch:** Fixed 1-based HUD vs 0-based Logic indexing.
*   [x] **CISO Narrative Removal:** Consistently stripped all `CommsSidebar` and `_send_comms` logic for a cleaner UI.
*   [x] **Null Callable Error:** Fixed GDScript parser error by making `active_filter` nullable.
