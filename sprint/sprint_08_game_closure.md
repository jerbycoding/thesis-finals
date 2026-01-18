# Sprint 8: Game Loop Closure & Structure

**Goal:** Transform the project from a playable vertical slice into a complete, loop-closed game application. This involves implementing win/loss states, system menus, and a dedicated tutorial scenario.

## 1. End Game Logic (Win/Loss States)
**Objective:** Give the player's choices ultimate consequences by defining how the game ends.

*   [] **Create Ending Scenes**
    *   `res://scenes/ui/endings/Ending_Fired.tscn`: Triggered by "Negligent" archetype or low reputation.
    *   `res://scenes/ui/endings/Ending_Bankrupt.tscn`: Triggered by failing the Friday Ransomware event (Critical financial loss).
    *   `res://scenes/ui/endings/Ending_Promotion.tscn`: Triggered by "Exemplary" performance (surviving Friday with high reputation).
*   [] **Update `NarrativeDirector.gd`**
    *   Implement `check_end_game_conditions()` called at the end of Friday's shift.
    *   Logic to transition to the appropriate ending scene based on `ArchetypeAnalyzer` metrics.

## 2. Dedicated Tutorial Scenario
**Objective:** Remove the "Monday is a tutorial" ambiguity by creating a standalone, guided onboarding experience.

*   [ ] **Create Resource: `TutorialScenario.tres`**
    *   A specialized `ShiftResource` that is shorter and linear.
    *   Tickets: 1 Phishing, 1 Log Analysis.
*   [ ] **Create `TutorialManager.gd`**
    *   A system that listens to the active shift. If it's `TutorialScenario`:
        *   **Highlighting:** Physically flash UI buttons (Email App, Terminal) when the player needs to click them.
        *   **Blocking:** Prevent the player from clicking "wrong" buttons during the guided phase.
*   [ ] **Update `TitleScreen.tscn`**
    *   Add a "TRAINING SIMULATION" (Tutorial) button separate from "START SHIFT" (Campaign).

## 3. System Menus (The Wrapper)
**Objective:** Add standard application functionality (Pause, Options, Quit).

*   [ ] **Create `PauseMenu.tscn`**
    *   Overlay accessible via `ESC` key.
    *   Buttons: Resume, Options (Volume Sliders), Abandon Shift (Quit to Title).
*   [ ] **Update `GameState.gd`**
    *   Handle `PAUSED` state (stop game time, timers, and input processing).

## 4. Persistent Settings
**Objective:** Save player preferences.

*   [ ] **Create `ConfigManager.gd`**
    *   Save/Load volume settings and full-screen preferences to `user://config.cfg`.
    *   Apply settings on game startup.

## 5. Narrative Cleanup
**Objective:** Adjust Monday's shift now that it is no longer the "Tutorial".

*   [ ] **Update `Shift1.tres` (Monday)**
    *   Remove hand-holding "Low" tickets.
    *   Increase pacing slightly to match the Campaign start intensity.
