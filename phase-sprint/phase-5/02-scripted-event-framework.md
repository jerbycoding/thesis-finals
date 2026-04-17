# TASK 2: SCRIPTED EVENT FRAMEWORK (THE DIRECTOR)

## Description
Implement the data-driven framework for scripted security events, ensuring they are authored efficiently and evaluated safely.

## Implementation Details

### A. `ScriptedEventResource.gd`
*   **Properties:** [ ] `event_id`, `event_type` (Enum: `rival_ai_escalation`, `emergency_patch`, `broker_message`, `honeypot_reveal`), `trigger_condition` (String/Dict for evaluation), `event_data` (Variant), `one_shot` (bool).
*   **[BLOCKER]** **One-Shot Guard:** [ ] The `NarrativeDirector` must set the event's `already_fired` flag **before** calling any external handlers or systems.

### B. The Evaluation Loop
*   **[BLOCKER]** **Safe Polling:** [ ] The scripted event evaluation **must** be performed via a `TimeManager`-registered polling timer set at 0.5-second intervals. It must **not** use `_process()` to avoid performance issues on target platforms.
*   **Logic:** [ ] On each poll, `NarrativeDirector` iterates through the active shift's `scripted_events` and evaluates their `trigger_condition`.

### C. Event Execution
*   `rival_ai_escalation`: [ ] Calls `RivalAI.force_state(state)`.
*   `emergency_patch`: [ ] Removes player footholds from a specific host.
*   `broker_message`: [ ] Triggers specific `DialogueManager` sequences.

## Success Criteria
- [ ] **[BLOCKER]** `ScriptedEventResource` class is created with the `one_shot` guard.
- [ ] **[BLOCKER]** Evaluation loop is implemented via `TimeManager` at 0.5s polling intervals.
- [ ] Events correctly fire when their conditions are met.
- [ ] `force_state()` correctly overrides the `RivalAI`'s current state.
