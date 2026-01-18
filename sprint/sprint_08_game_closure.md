# Sprint 8: Game Loop Closure & Structure (COMPLETED)

**Goal:** Transform the project from a playable vertical slice into a complete, loop-closed game application. This involves implementing win/loss states, system menus, and a dedicated tutorial scenario.

## 1. End Game Logic (Win/Loss States) - DONE
**Objective:** Give the player's choices ultimate consequences by defining how the game ends.

*   [x] **Create Ending Scenes**
    *   `res://scenes/ui/endings/Ending_Fired.tscn`: Triggered by "Negligent" archetype or low reputation.
    *   `res://scenes/ui/endings/Ending_Bankrupt.tscn`: Triggered by failing the Friday Ransomware event (Critical financial loss).
    *   `res://scenes/ui/endings/Ending_Promotion.tscn`: Triggered by "Exemplary" performance (surviving Friday with high reputation).
*   [x] **Update `NarrativeDirector.gd`**
    *   Implement `_on_campaign_ended()` to transition to the appropriate ending scene based on performance metrics.

## 2. Dedicated Tutorial Scenario - DONE
**Objective:** Remove the "Monday is a tutorial" ambiguity by creating a standalone, guided onboarding experience.

*   [x] **Create Resource: `TutorialShift.tres`**
    *   A specialized `ShiftResource` that is shorter and linear.
*   [x] **Create `TutorialManager.gd`**
    *   Guided prompts for desk interaction, ticket opening, and evidence attachment.
*   [x] **Update `TitleScreen.tscn`**
    *   Logic added for "TRAINING SIMULATION" button.

## 3. System Menus (The Wrapper) - DONE
**Objective:** Add standard application functionality (Pause, Options, Quit).

*   [x] **Create `PauseMenu.tscn`**
    *   Overlay accessible via `ESC` key.
*   [x] **Update `GameState.gd`**
    *   Handle `set_paused()` (stop game time, timers, and input processing).

## 4. Persistent Settings - DONE
**Objective:** Save player preferences.

*   [x] **Create `ConfigManager.gd`**
    *   Save/Load volume settings to `user://settings.cfg`.
*   [x] **Integrated master volume slider** in the Pause Menu.

## 5. Narrative Cleanup - DONE
**Objective:** Standardize shift triggers and transitions.

*   [x] **Refactored `NPC_CISO.gd`** to handle manual "Clock Out" checks.