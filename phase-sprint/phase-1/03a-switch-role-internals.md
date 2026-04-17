# TASK 3a: SWITCH_ROLE INTERNALS (STATE MANAGEMENT)

## Description
Implement the core state-clearing and context-switching functions, focusing on dual status map architecture and cross-role state preservation.

## Implementation Details
*   **Minigame Guard:** [x] Check `MinigameBase.is_active` as the first step.
*   **Timer Clearing:** [x] `TimeManager.clear_all_timers()` must be called in the role switch sequence.
*   **UI Pool Flushing:** [x] `UIObjectPool.flush()` must be called.
*   **Heat Caching:** [x] `HeatManager.cache_and_reset(role)` must save the Analyst's current heat when switching to Hacker, and restore it when switching back.
*   **Network Context Isolation:**
    *   **[BLOCKER]** [x] `NetworkState` **must maintain two independent status maps in memory simultaneously**—one for each context. 
    *   [x] Switching context does not reset the outgoing context's map; it saves it and loads the other. This ensures in-progress investigations on the Analyst side are preserved during a Hacker shift.

## Success Criteria
- [x] **[BLOCKER]** `NetworkState` maintains two separate, concurrent status maps in memory.
- [x] **[BLOCKER]** Switching context does not destroy existing host status data for the outgoing context.
- [x] `switch_role()` correctly aborts if a minigame is active.
- [x] `TimeManager.clear_all_timers()` is called.
- [x] `HeatManager.cache_and_reset()` correctly saves/restores Analyst heat.
