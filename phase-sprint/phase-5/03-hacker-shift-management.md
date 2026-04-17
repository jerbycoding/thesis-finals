# TASK 3: HACKER SHIFT MANAGEMENT

## Description
Modify the `NarrativeDirector` to handle the 7-day hacker campaign arc.

## Implementation Details
*   **Class:** [x] Create `HackerShiftResource` (inherits from `ShiftResource`).
*   **Action:** [x] When `GameState.current_role == Role.HACKER`, the `NarrativeDirector` must be modified to load shifts from the `res://resources/hacker_shifts/` directory instead of the default analyst shifts.
*   **Scripted Opponent:** [ ] The `NarrativeDirector` should be able to trigger `RivalAI` state changes (e.g., `force_state(LOCKDOWN)`) at specific narrative moments.

## Success Criteria
- [x] `HackerShiftResource.gd` script is created.
- [x] The game correctly loads hacker-specific shifts when playing as the hacker.
- [ ] The `NarrativeDirector` can successfully force the `RivalAI` into a specific state for scripted events.
