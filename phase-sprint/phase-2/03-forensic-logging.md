# TASK 3: FORENSIC ACTION LOGGING (THESIS ANCHOR)

## Description
[REVISED] Create a persistent, crash-safe record of every offensive action, including all required data fields and public methods for Phase 6.

## Implementation Details
*   **Singleton:** Create `HackerHistory.gd`.
*   **Signal:** Listens for `EventBus.offensive_action_performed`.
*   **Schema:** The signal payload **must** contain 6 keys: `{ action_type, target, timestamp, result, trace_cost, shift_day }`. The `shift_day` is sourced from `NarrativeDirector.current_day`.
*   **Persistence:** `HackerHistory` **must** write its data to disk via the `SaveSystem` **immediately upon receiving a signal**. It should not wait for the end of the shift. This ensures forensic data survives a crash.
*   **Scope:** The singleton must record all four action types: `exploit`, `phish`, `pivot`, and `spoof`.
*   **Phase 6 Stubs:**
    *   `HackerHistory.gd` must include a public method `get_entries_for_day(day: int) -> Array`. It can return an empty array for now.
    *   Verify that `LogSystem.gd` has a `get_logs_for_shift(day: int) -> Array` method. If not, create a stub for it.

## Success Criteria
- [ ] **[BLOCKER]** The `offensive_action_performed` signal payload includes the `shift_day` key.
- [ ] **[BLOCKER]** The `HackerHistory.gd` singleton includes the `get_entries_for_day(day)` method stub.
- [ ] **[BLOCKER]** Forensic data is written to disk on every signal emission, not cached until shift end.
- [ ] `HackerHistory.gd` is created and added to autoload.
- [ ] All four action types (`exploit`, `phish`, `pivot`, `spoof`) are successfully recorded.
- [ ] A stub for `LogSystem.get_logs_for_shift(day)` exists.
