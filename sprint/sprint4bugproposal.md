# Sprint 4 Bug Proposal: Refactoring Dialogue System

## Problem Statement

The current dialogue system, particularly the interaction between `NPC.gd` and `DialogueBox.gd`, suffers from a critical bug stemming from the use of a `static var dialogue_box_instance` in `NPC.gd`.

**Symptoms:**
*   `print()` statements (and associated game logic) within `_apply_choice_effect` in `NPC.gd` do not execute after certain dialogue interactions, especially following scene changes.
*   Dialogue choices cease to trigger effects or advance the narrative correctly after transitioning between 3D scenes (e.g., from `BriefingRoom.tscn` to `SOC_Office.tscn`).

**Root Cause:**
1.  **Shared Static Instance:** The `static var dialogue_box_instance` in `NPC.gd` is shared across all instances of `NPC` and its derived classes.
2.  **Stale Signal Connection:** The `dialogue_box_instance.dialogue_choice_selected` signal is connected to the `_on_dialogue_choice_selected` method of the *first* `NPC` instance that initiates a dialogue.
3.  **Scene Unloading:** When a scene changes (e.g., via `TransitionManager.change_scene_to()`, which uses `get_tree().change_scene_to_file()`), the original `NPC` instance (and its associated script) that made the connection is destroyed and freed from memory.
4.  **Dangling Reference:** The `dialogue_box_instance` then holds a signal connection pointing to a freed object.
5.  **Failure to Execute:** Subsequent dialogue interactions from new `NPC` instances in the new scene try to use the existing `dialogue_box_instance`. While the `DialogueBox` might appear, when a choice is made, the signal emission attempts to call a method on the *freed* original `NPC` object. This results in the method not being called on the *current* `NPC` instance, and any game logic (including debug `print()` statements) dependent on that call fails to execute.

## Proposed Solution: Refactor to a Centralized Dialogue Manager Autoload

To address this comprehensively and prevent similar issues, a refactoring of the dialogue system is proposed by introducing a dedicated `DialogueManager` Autoload singleton.

### High-Level Goal

Decouple the `DialogueBox` UI from individual NPC instances, centralize dialogue flow management, and ensure robust signal handling across scene changes.

### Detailed Plan of Action (TODOs)

1.  **Create `DialogueManager.gd` Autoload singleton.**
    *   **Action:** Create `autoload/DialogueManager.gd`. Register it as an Autoload singleton in `project.godot`.
    *   **Purpose:** Establishes a persistent, globally accessible manager for the dialogue system, ensuring the UI and its state survive scene transitions.

2.  **Move dialogue box instantiation and management from `NPC.gd` to `DialogueManager.gd`.**
    *   **Action:** Transfer the `preload("res://scenes/ui/DialogueBox.tscn")` and all logic related to instantiating, adding, showing, and hiding the `DialogueBox` from `NPC.gd` to `DialogueManager.gd`. The `DialogueManager` will maintain a single `DialogueBox` instance as its child (or a child of the root viewport).
    *   **Purpose:** Ensures consistent, centralized control over the dialogue UI lifecycle.

3.  **Modify `NPC.gd` to remove static dialogue box references and request dialogues from `DialogueManager.gd`.**
    *   **Action:** Remove `static var dialogue_box_instance` and related preload from `NPC.gd`. Update `NPC.gd`'s `start_dialogue` function to call `DialogueManager.start_dialogue(self, dialogue_id)`, passing a reference to itself (`self`) and the `dialogue_id`.
    *   **Purpose:** Simplifies NPC logic, making them content providers and responders, not UI managers.

4.  **Modify `DialogueBox.gd` to emit a generic choice signal with the choice data.**
    *   **Action:** Ensure `DialogueBox.gd` solely focuses on displaying text and choices. It will emit a signal (e.g., `choice_made(choice_data: Dictionary)`) when a choice is selected. Remove any logic that directly applies "effects" from the `DialogueBox`, as this logic belongs to the NPC or the `DialogueManager`.
    *   **Purpose:** Enforces separation of concerns; UI handles presentation, game logic handles effects.

5.  **Implement dialogue handling logic in `DialogueManager.gd`, including dynamic signal connections to the requesting NPC.**
    *   **Action:** Implement the `DialogueManager.start_dialogue(requesting_npc: NPC, dialogue_id: String)` method. This method will:
        *   Retrieve dialogue content from `requesting_npc`.
        *   Populate and display the `DialogueBox`.
        *   **Crucially:** Disconnect any existing connections from the `DialogueBox`'s `choice_made` signal. Then, connect the `DialogueBox`'s `choice_made` signal directly to the `requesting_npc`'s `_on_dialogue_choice_selected` method using `Callable(requesting_npc, "_on_dialogue_choice_selected")`.
        *   Manage `GameState` changes (e.g., `GameState.set_game_mode(GameState.GameMode.MODE_DIALOGUE)`).
    *   **Purpose:** This dynamic reconnection ensures that the correct, currently active `NPC` instance always receives the player's choice, resolving the dangling reference issue.

6.  **Update `NarrativeDirector.gd` to use `DialogueManager.gd` for initiating NPC interactions.**
    *   **Action:** Modify `NarrativeDirector.gd`'s `_trigger_event` function. When an event of type `"npc_interaction"` occurs, it should call `DialogueManager.start_dialogue(npc_id, dialogue_id)` (after resolving `npc_id` to the actual `NPC` instance if needed) instead of directly calling `start_dialogue` on an `NPC` instance.
    *   **Purpose:** Maintains `NarrativeDirector`'s role as a high-level orchestrator, delegating UI-specific tasks to the `DialogueManager`.

7.  **Test all dialogue interactions, especially across scene changes, to verify the fix.**
    *   **Action:** Conduct thorough testing of all dialogue flows, including starting new shifts, interacting with different NPCs before and after scene changes, and verifying that all dialogue choices lead to expected outcomes (e.g., `print()` statements appearing, consequences triggering, narrative advancing).
    *   **Purpose:** Validate the effectiveness of the refactoring and ensure no regressions or new bugs are introduced.

## Expected Outcome

A robust, modular, and maintainable dialogue system that handles scene transitions correctly, eliminates dangling signal connections, and clearly separates UI concerns from game logic. The `print` statements in `NPC.gd` will now reliably appear when their associated dialogue choices are made.