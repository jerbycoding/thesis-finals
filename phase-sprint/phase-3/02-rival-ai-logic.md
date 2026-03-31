# TASK 2: AI ANALYST LOGIC (THE MIRROR OPPONENT)

## Description
[REVISED] Create a state-driven AI that "simulates" a SOC analyst, provides clear feedback to the player, and uses safe signal connection hygiene.

## Implementation Details
*   **Singleton:** Create `RivalAI.gd`.
*   **State Machine:**
    *   **[BLOCKER]** All state changes **must** go through a central `_transition_to(new_state)` method. Direct assignment (`current_state = new_state`) is forbidden. This method is responsible for emitting the `rival_ai_state_changed` signal.
    *   Reads `TraceLevelManager.get_trace_level()` to trigger transitions based on thresholds (`IDLE` < 30, `SEARCHING` 30-70, `LOCKDOWN` > 70).
*   **Player Feedback:**
    *   **SEARCHING State:** When transitioning to `SEARCHING`, the AI must:
        1.  Inject a terminal message: `TerminalSystem.inject_system_message("ANOMALY DETECTED: Correlating network telemetry...")`
        2.  Show a one-time toast: `NotificationManager.show_notification("Suspicious activity detected")`
        3.  The UI trace meter must change color to `GlobalConstants.COLOR_TRACE_WARNING`.
    *   **LOCKDOWN State:** When transitioning to `LOCKDOWN`, the AI must:
        1.  Inject a terminal message: `TerminalSystem.inject_system_message("COMPROMISE DETECTED: Initiating host isolation protocol...")`
        2.  The UI trace meter must change color to `GlobalConstants.COLOR_TRACE_CRITICAL`.
*   **Role Guard & Signal Hygiene:**
    *   **[BLOCKER]** The AI must not use always-on listeners. It must `connect()` to `EventBus` signals only when a Hacker shift starts (`hacker_shift_started` signal) and `disconnect()` from them when the shift ends or the role changes.
    *   A standard `if GameState.current_role != Role.HACKER: return` guard should still be used in `_process` as a second layer of safety.
*   **Speed Scaling:** AI "decision" timers (like the isolation countdown) must be scaled by `HeatManager.heat_multiplier`.

## Success Criteria
- [ ] **[BLOCKER]** A private `_transition_to()` method is the only function that changes `RivalAI.current_state`.
- [ ] **[BLOCKER]** The AI connects/disconnects its signal listeners at the start/end of Hacker shifts.
- [ ] Transitioning to `SEARCHING` triggers the terminal message, a one-time notification, and a color change.
- [ ] Transitioning to `LOCKDOWN` triggers a terminal message and a color change.
- [ ] The `RivalAI` singleton is created and added to autoload.
