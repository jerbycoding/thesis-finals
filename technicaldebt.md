# VERIFY.EXE - Technical Debt Audit & Expansion Roadmap

This document identifies core architectural weaknesses (Technical Debt) and outlines the **Sprint 06** plan to "harden" the game for multi-week expansion.

---

## 1. Technical Debt Audit (Phase 6)

### [HIGH] Visual Debt: The Theme-less System
*   **Status:** "Enterprise-Clean" aesthetic is currently implemented via **Sub-Resource Overrides** in individual `.tscn` files.
*   **Impact:** Modifying a global color (e.g., "Active Green") requires manual edits to 15+ files. High risk of visual drift.
*   **Requirement:** Consolidate styles into a global `.theme` resource.

### [MEDIUM] Logic Debt: Metric Redundancy
*   **Status:** `ArchetypeAnalyzer.gd` maintains a local `metrics` dictionary while also having functions to derive metrics from the `ConsequenceEngine` history.
*   **Impact:** "Split-brain" logic. Risk of data discrepancy between the game state and the end-of-shift report.
*   **Requirement:** Remove local tracking; use `ConsequenceEngine` as the single source of truth.

### [MEDIUM] Structural Debt: Narrative Rigidity
*   **Status:** `NarrativeDirector.gd` contains a hardcoded victory check for `shift_friday`.
*   **Impact:** **Primary Blocker for Week 2.** The engine is "hard-wired" to stop on Week 1 Friday regardless of shift chaining.
*   **Requirement:** Make shift progression dynamic based on the presence of `next_shift_id`.

### [MEDIUM] Coupling Debt: Singleton Over-Reliance
*   **Status:** Core tools call managers (Notification, Audio, Email) directly.
*   **Impact:** High code coupling. Fragile during initialization and difficult to test in isolation.
*   **Requirement:** Transition to 100% Signal-Driven communication via the `EventBus`.

### [LOW] Asset Debt: Ghost Resource Files
*   **Status:** Merged components (IntegrityHUD, ShiftTimerHUD, etc.) still exist as separate files.
*   **Impact:** Project clutter and developer confusion.
*   **Requirement:** Perform a "Delete Audit" to purge unreferenced assets.

---

## 2. SPRINT 06: Structural Hardening & Multi-Week Prep

**Goal:** Transform the prototype into an expandable professional platform.

### Task 1: Dynamic Narrative Flow (Unlocking Week 2)
*   **Action:** Refactor `NarrativeDirector.gd` to remove hardcoded Friday checks.
*   **Success Metric:** Sunday transitions to a defined `next_shift_id` instead of resetting or triggering victory.

### Task 2: Global Enterprise Theme (Visual Locking)
*   **Action:** Create `res://assets/themes/EnterpriseTheme.theme`. Map all workstation and HUD elements to this resource.
*   **Success Metric:** Global visual changes can be made in one file.

### Task 3: Single Source of Truth (Data Integrity)
*   **Action:** Deprecate local metric tracking in `ArchetypeAnalyzer`. Sync all reports to the `ConsequenceEngine` history.
*   **Success Metric:** Shift reports accurately reflect saved player choices.

### Task 4: HUD Decoupling (Signal-Driven Visors)
*   **Action:** Use `EventBus.display_prompt` for all 3D interactions.
*   **Success Metric:** `PlayerController.gd` is decoupled from UI node names.

### Task 5: Project Purge (Dead Asset Removal)
*   **Action:** Delete redundant `.tscn` and `.gd` files identified in the audit.
*   **Success Metric:** Zero "Resource Not Found" warnings in the console.
