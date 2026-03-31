# TASK 3: "CONNECTION LOST" & EVASION MECHANICS

## Description
[REVISED] Define the full, race-condition-safe failure state (isolation) and the mechanics for evading it.

## Implementation Details

### A. The Isolation Sequence
*   **Countdown:** The isolation countdown timer **must** be registered via `TimeManager`. Its duration is `GlobalConstants.RIVAL_AI_BASE_ISOLATION_SECONDS / HeatManager.heat_multiplier`.
*   **Callback Guard:**
    *   **[BLOCKER]** The very first line of the isolation timer's callback method **must** be `if TraceLevelManager.is_isolation_in_progress(): return`. This prevents the race condition where a successful pivot and an isolation completion can fire in the same frame.
*   **Force Close:** When isolation succeeds, it must call `DesktopWindowManager.force_close_all()` to close any open app windows.
*   **Signal Emission:** After closing windows, it must emit `EventBus.rival_ai_isolation_complete(hostname)`.
*   **UI:** Finally, it displays the "CONNECTION LOST" screen/overlay.

### B. Post-Isolation State
When isolation is complete, the following four state changes **must** occur:
1.  `GameState.current_foothold` is reset to `""`.
2.  `trace_level` is retained at its high value (it does not reset).
3.  `RivalAI.current_state` transitions to `SEARCHING` (not `IDLE`).
4.  The isolated host is marked as "blocked" and cannot be the target of a new `exploit` action for the remainder of the shift.

### C. Pivot Evasion
*   **Logic:** The `pivot` command in the terminal calls `RivalAI.abort_isolation()`. This function cancels the `TimeManager` isolation timer and transitions the AI state back to `SEARCHING`.
*   **Guard:** The `pivot` command must still verify the target host is in `GameState.hacker_footholds` even during a `LOCKDOWN`. A player cannot evade by pivoting to an un-compromised host.

## Success Criteria
- [ ] **[BLOCKER]** The isolation callback is guarded against the race condition using `is_isolation_in_progress()`.
- [ ] **[BLOCKER]** The `pivot` command is correctly guarded; it cannot target un-compromised hosts, even during LOCKDOWN.
- [ ] **[BLOCKER]** The `rival_ai_isolation_complete` signal is emitted upon successful isolation.
- [ ] The isolation countdown duration is correctly calculated using the heat multiplier.
- [ ] All four post-isolation state changes are correctly applied.
- [ ] `DesktopWindowManager.force_close_all()` is called before the "CONNECTION LOST" screen appears.
