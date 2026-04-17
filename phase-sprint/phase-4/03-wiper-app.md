# TASK 3: "WIPER" SCRIPTS (EVIDENCE DESTRUCTION)

## Description
Provide a tool for trace reduction and forensic cleaning with precision tiers and proper guards.

## Implementation Details
*   **Inheritance:** [ ] Inherits from `MinigameBase.gd`.
*   **Logic:** [ ] Repurpose the `RuleSliderMinigame.gd` mechanic to represent "Overwrite/Defrag."
*   **Precision Tiers:**
    *   **Deep:** [ ] (Slider Accuracy > 90%) - Reduces Trace by 30%, prunes all logs for host.
    *   **Standard:** [ ] (70%-90%) - Reduces Trace by 20%, prunes 50% of logs for host.
    *   **Shallow:** [ ] (50%-70%) - Reduces Trace by 10%, prunes only earliest logs for host.
*   **Outcome:** 
    *   [ ] Calls `LogSystem.prune_logs_for_host(hostname, scope)`.
    *   [ ] Calls `TraceLevelManager.reduce_trace(amount)`.
*   **[BLOCKER]** **Isolation Guard:** [ ] The Wiper must check `TraceLevelManager.is_isolation_in_progress()` **immediately before** calling `reduce_trace()`. It cannot reduce Trace if a LOCKDOWN has already started.
*   **Feedback:** [ ] After completion, use `TerminalSystem.inject_system_message()` to display the number of logs successfully removed.
*   **Failure Path:**
    *   [ ] If the slider run is failed, it must emit `offensive_action_performed` with `trace_cost: 5.0`.

## Success Criteria
- [ ] **[BLOCKER]** `TraceLevelManager.reduce_trace()` is not called if isolation is already in progress.
- [ ] **[BLOCKER]** `LogSystem.prune_logs_for_host()` returns an Array used to display the count of removed logs in the terminal.
- [ ] Three precision tiers (Shallow, Standard, Deep) are implemented.
- [ ] A failed Wiper run correctly costs Trace.
- [ ] Using the app causes a trace reduction based on accuracy.
