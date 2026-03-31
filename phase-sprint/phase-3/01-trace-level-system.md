# TASK 1: THE "TRACE LEVEL" SYSTEM (OFFENSIVE HEAT)

## Description
[REVISED] Implement a dynamic "Trace Level" that correctly sources trace costs from the signal payload, handles all decay conditions, and resets on a new shift.

## Implementation Details
*   **Singleton:** Create `TraceLevelManager.gd`. It **must** be registered in the autoload list *after* `EventBus` and `GameState`.
*   **Signal Listener:** Listens for `EventBus.offensive_action_performed`.
*   **Trace Accumulation:** The manager **must not** use hardcoded values. It must read the `trace_cost` directly from the signal's payload dictionary. It should accumulate trace for all relevant actions (`exploit`, `phish`, `pivot`, `spoof`, `ransomware`, etc.).
*   **Passive Decay:**
    *   The decay timer **must** be registered via `TimeManager` to ensure it is cleared on role transitions.
    *   The decay amount must be read from `GlobalConstants.TRACE_DECAY_RATE`.
    *   **[BLOCKER]** Decay **must pause** under three conditions:
        1.  A minigame is active (`MinigameBase.is_active == true`).
        2.  The `RivalAI` is in its `LOCKDOWN` state.
        3.  The player is not in the Hacker role (`GameState.current_role != Role.HACKER`).
*   **Shift Reset:** The singleton must listen for the `hacker_shift_started` signal from `NarrativeDirector` and reset `trace_level` to `0.0` upon receipt.

## Success Criteria
- [ ] **[BLOCKER]** Trace decay pauses correctly when a minigame is active.
- [ ] Trace costs are sourced from the signal payload, not hardcoded.
- [ ] The decay timer is registered with `TimeManager`.
- [ ] `trace_level` correctly resets to 0 at the start of a new Hacker shift.
- [ ] `TraceLevelManager` is in the correct autoload order.
- [ ] Decay pauses during `LOCKDOWN` and when the role is not `HACKER`.
