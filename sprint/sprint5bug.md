# 🐛 **Sprint 5 Bug Report: Stuck in Briefing Room - Second Shift**

## 🎯 **Symptom**
After completing the first shift and attempting to start the second shift by clicking the final dialogue choice with the CISO in the `BriefingRoom`, the game gets stuck in the `BriefingRoom`. No transition to the `SOC_Office.tscn` occurs. The player remains in the `BriefingRoom` with movement re-enabled.

## 🗒️ **Reproduction Steps**
1.  Ensure `savegame.json` is deleted.
2.  Launch the game.
3.  Click "START NEW SHIFT".
4.  Complete the CISO briefing in the `BriefingRoom`.
5.  Play through the first shift, completing the two tickets (`SPEAR-PHISH-001` and `MALWARE-CONTAIN-001`).
6.  The Shift Report appears. Click "Continue".
7.  The game transitions back to the `BriefingRoom` for the CISO's second shift briefing.
8.  Interact with the CISO and click the final dialogue choice ("I understand. I'm ready for the challenge.").
9.  **Expected:** The game transitions to `SOC_Office.tscn`, and the second shift begins.
10. **Actual:** The game gets stuck in the `BriefingRoom`. The player can move, but no transition occurs.

## 🔍 **Debugging History & Observations**

### **Initial Problem Statement**
The second shift briefing was not appearing at all.

### **Fix 1: Consistency in Briefing Flow**
*   **Issue:** The "Continue" button from the Shift Report was directly starting `NarrativeDirector.start_shift("second_shift")` and transitioning to `SOC_Office.tscn` without a briefing.
*   **Solution Implemented:**
    *   Added `briefing_second_shift` dialogue to `NPC_CISO.gd`.
    *   Updated `NPC.gd` to handle `start_narrative` effects with string arguments.
    *   Added `start_second_shift_briefing()` to `NarrativeDirector.gd` to transition to `BriefingRoom` and trigger CISO dialogue.
    *   `App_ShiftReport.gd` now calls `NarrativeDirector.start_second_shift_briefing()`.
*   **Result:** The second shift briefing correctly appears in the `BriefingRoom`.

### **Current Problem: Stuck After Briefing Choice**
Even after the dialogue appears, clicking the choice in the CISO's second shift briefing does not trigger the transition to `SOC_Office.tscn`.

### **Debugging Steps Taken (Logs)**

1.  **`TransitionManager.gd` Verbose Logs (`>>> TRANSITION:`):**
    *   Added detailed logs to `TransitionManager.change_scene_to` to trace its execution.
    *   **Observation:** These logs confirm the transition *to* the `BriefingRoom` (for the second shift briefing) works perfectly. However, logs for the transition *from* the `BriefingRoom` to `SOC_Office` are entirely missing. This indicates the `TransitionManager.change_scene_to` function is never called for the second transition.

2.  **`DialogueBox.gd` Effect Log (`>>> DIALOGUEBOX:`):**
    *   Added a log inside `DialogueBox._on_choice_selected` to print the `effect` dictionary being passed to `NPC._apply_choice_effect`.
    *   **Observation:** The log `>>> DIALOGUEBOX: Processing choice effect: { "change_scene": "res://scenes/SOC_Office.tscn", "then_start_narrative": "second_shift" }` clearly appears. This confirms that the `DialogueBox` is correctly reading the effect from `NPC_CISO.gd` and attempting to pass the correct data.

3.  **`NPC.gd` Debug Logs (`>>> NPC DEBUG:` and `>>> NPC:`):**
    *   Added logs within `NPC._apply_choice_effect` to print the received `effect` dictionary and the result of `effect.has("change_scene")`.
    *   **Observation:** These `>>> NPC DEBUG:` logs are **not appearing at all** in the console.

## ❓ **Current Hypothesis**
Despite the `DialogueBox` correctly emitting the signal and logging the intended `effect`, the `_apply_choice_effect` function in `NPC.gd` (which is connected to the `dialogue_choice_selected` signal of `DialogueBox`) is **not being called**, or its execution is being bypassed or interrupted before any of its logs can fire.

This is highly unusual as the signal connection is explicitly made in `NPC.gd`'s `start_dialogue` function: `dialogue_box_instance.dialogue_choice_selected.connect(_on_dialogue_choice_selected)`.

The current behavior suggests a deeper issue with the signal-slot connection, the lifecycle of the `DialogueBox` or `NPC` instance, or an unexpected context switch.

## 🔜 **Next Steps**
To investigate why `NPC._apply_choice_effect` is not being called:
1.  Verify the signal connection itself.
2.  Add logs inside `NPC._on_dialogue_choice_selected` to ensure that the signal is correctly received by the `NPC` instance.
3.  Add logs at the very beginning of `_apply_choice_effect` to confirm entry.
4.  Consider potential issues with `dialogue_box_instance` lifecycle or its connection management.
