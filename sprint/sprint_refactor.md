# 📅 **SPRINT R: REFACTORING & MAINTAINABILITY**
**Theme:** "Address technical debt and improve the long-term health of the codebase."

## 🎯 **SPRINT GOAL**
**Deliver:** A more stable, maintainable, and extensible codebase by systematically refactoring key systems identified in the `GAME.md` technical debt assessment. This sprint focuses on improving architecture and implementing best practices to accelerate future development.

---

## ✅ **TASKS & ACCEPTANCE CRITERIA**

This refactoring effort is broken into phases.

### **PHASE 1: Immediate & High Impact Fixes**
*These tasks address critical bugs and establish a foundation for safer refactoring.*

- [x] **4.1 Refactor Dialogue System to `DialogueManager` Autoload**
  - [x] Create `autoload/DialogueManager.gd` and register it.
  - [x] Move `DialogueBox` instantiation and management to `DialogueManager`.
  - [x] Modify `NPC.gd` to request dialogues from `DialogueManager`.
  - [x] Adjust `DialogueBox.gd` to emit generic signals.
  - **Result:** Dialogue system is robust and functions reliably across scene changes.

- [ ] **4.2 Implement Automated Testing with GdUnit4**
  - [ ] Integrate the GdUnit4 testing framework into the project.
  - [ ] Write initial unit tests for core singletons (`TicketManager`, `ConsequenceEngine`, `DialogueManager`).
  - **Result:** A foundational test suite provides a safety net for future changes.

---

### **PHASE 2: Architectural & Data-Driven Improvements**
*These tasks focus on separating data from logic and improving modularity.*

- [ ] **4.3 Formalize Data-Driven Dialogue (DialogueDataResource)**
  - [ ] Define a new custom `Resource` type: `DialogueDataResource.gd`.
  - [ ] Convert hardcoded `dialogue_data` dictionaries in `NPC` scripts into `DialogueDataResource` files.
  - [ ] Update `NPC.gd` to load its dialogue from the exported resource file.
  - **Result:** Dialogue content is fully separated from code.

- [ ] **4.4 Generalize UI Window Management (DesktopWindowManager Autoload)**
  - [ ] Create a new Autoload singleton: `DesktopWindowManager.gd`.
  - [ ] Extract window management logic from `scripts/2d/computer_desktop.gd` into the new manager.
  - [ ] Refactor `computer_desktop.gd` to use the `DesktopWindowManager` API.
  - **Result:** Desktop UI system is more modular and extensible.

- [ ] **4.5 Decouple Autoloads with Event-Driven Communication**
  - [ ] Identify direct, high-traffic calls between singletons (e.g., `TicketManager` -> `ConsequenceEngine`).
  - [ ] Refactor these direct calls to use signals and observers (e.g., `TicketManager.ticket_completed.emit()`).
  - **Result:** Reduced coupling between core systems improves flexibility.

---

### **PHASE 3: Ongoing & Incremental Refinements**
*These are continuous efforts to be integrated into all future development.*

- [ ] **4.6 Code Style & Consistency**
  - [ ] Consistently apply and enforce project GDScript style guidelines.
  - **Result:** A more uniform and readable codebase.

- [ ] **4.7 Minimize String-Based Lookups**
  - [ ] Where feasible, investigate replacing string-based IDs with direct `Resource` references or `UIDs`.
  - **Result:** Reduced risk of runtime errors from typos.

- [ ] **4.8 Review `_process` Usage for Optimization**
  - [ ] Audit singletons using `_process` for time-based logic.
  - [ ] Consolidate or replace with `Timer` nodes where appropriate.
  - **Result:** Clearer time management logic.
