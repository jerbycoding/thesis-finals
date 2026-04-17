# TASK 3: FORENSIC ACTION LOGGING (THESIS ANCHOR)

## Description
Create a persistent, crash-safe record of every offensive action, including all required data fields and public methods for Phase 6.

## Implementation Details
*   **Singleton:** [x] Create `HackerHistory.gd`.
*   **Signal:** [x] Listens for `EventBus.offensive_action_performed`.
*   **Schema:** [x] The signal payload **must** contain 6 keys: `{ action_type, target, timestamp, result, trace_cost, shift_day }`. The `shift_day` is sourced from `NarrativeDirector.current_hacker_day`.
*   **Persistence:** [x] `HackerHistory` **must** write its data to disk via the `SaveSystem` **immediately upon receiving a signal**. It should not wait for the end of the shift. This ensures forensic data survives a crash.
*   **Scope:** [x] The singleton must record all four action types: `exploit`, `phish`, `pivot`, and `spoof`. (Note: `phish` and `spoof` recording implemented, though commands are pending implementation in Phase 2).
*   **Phase 6 Stubs:**
    *   [x] `HackerHistory.gd` must include a public method `get_entries_for_day(day: int) -> Array`. It can return an empty array for now.
    *   [x] Verify that `LogSystem.gd` has a `get_logs_for_shift(day: int) -> Array` method. If not, create a stub for it.

## Success Criteria
- [x] **[BLOCKER]** The `offensive_action_performed` signal payload includes the `shift_day` key.
- [x] **[BLOCKER]** The `HackerHistory.gd` singleton includes the `get_entries_for_day(day)` method stub.
- [x] **[BLOCKER]** Forensic data is written to disk on every signal emission, not cached until shift end.
- [x] `HackerHistory.gd` is created and added to autoload.
- [x] All four action types (`exploit`, `phish`, `pivot`, `spoof`) are successfully recorded.
- [x] A stub for `LogSystem.get_logs_for_shift(day)` exists.
