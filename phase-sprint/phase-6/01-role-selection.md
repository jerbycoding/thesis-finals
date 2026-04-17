# TASK 1: ROLE SELECTION & SAVE SEPARATION

## Description
Update the `TitleScreen.tscn` to allow campaign selection with proper transition authority, save-file awareness, and crash recovery.

## Implementation Details

### A. Role Transition Authority
*   **[BLOCKER]** **NO DIRECT ASSIGNMENT:** [x] The selection buttons **must** call `GameState.switch_role(Role.HACKER)` or `GameState.switch_role(Role.ANALYST)`. Direct assignment to `current_role` is forbidden as it bypasses the safety sequence.

### B. Continue Button Logic
*   **Hacker Continue:** [ ] Only visible if `user://saves/hacker/world_state.json` exists.
*   **Analyst Continue:** [ ] Only visible if `user://saves/analyst/world_state.json` exists.
*   **Logic:** [ ] If both are missing, hide both "Continue" options.

### C. Crash Recovery
*   **Logic:** [ ] On Title Screen load, check `GameState.role_transition_in_progress`.
*   **Action:** [ ] If `true` (indicating a crash mid-switch), reset state to `Role.ANALYST`, clear all hacker variables, and show a `NotificationManager` toast: "Session recovered from unexpected termination."

### D. Visual Identity
*   **Analyst Button:** [x] Render in `GlobalConstants.COLOR_CORPORATE_BLUE`.
*   **Hacker Button:** [x] Render in `GlobalConstants.COLOR_HACKER_GREEN`.
*   **Context:** [x] `is_campaign_session` must be set to `true` to enable Mirror Mode.

## Success Criteria
- [x] **[BLOCKER]** Selection buttons call `switch_role()`, triggering the transition sequence.
- [ ] **[BLOCKER]** Continue buttons correctly hide/show based on the existence of their respective save files.
- [ ] Crash recovery logic correctly resets a "dirty" state.
- [x] Selection buttons use role-specific colors from `GlobalConstants`.
