# TASK 3b: SAVE SYSTEM ISOLATION & CRASH RECOVERY

## Description
[REVISED] Implement the dual-directory save system, crash recovery on load, and "Continue" button guards for campaign isolation.

## Implementation Details

### A. Path Constants in `GlobalConstants.gd`
*   `const SAVE_PATH_ANALYST = "user://saves/analyst/"`
*   `const SAVE_PATH_HACKER = "user://saves/hacker/"`

### B. Save System Logic
*   **Path Resolution:** Prefix all paths with the correct constant based on `current_role`.

### C. Crash Recovery
*   **[BLOCKER]** **Recovery on Load:** `SaveSystem.load()` must check `role_transition_in_progress`.
*   **Action if True:** Reset `current_role` to `Role.ANALYST`, clear all Hacker variables, and show a `NotificationManager` toast: "Session recovered from corrupted state."

### D. Continue Button Guards
*   **Logic:** Provide a public method `has_save_for_role(role)` that checks for the existence of `world_state.json` in the respective directory.
*   **Success Criterion:** Use this in the Title Screen to hide "Continue" buttons for campaigns that don't have a save file.

## Success Criteria
- [ ] **[BLOCKER]** `SaveSystem.load()` correctly identifies and recovers from a crashed role transition state.
- [ ] **[BLOCKER]** A method exists to check for save file existence, enabling Title Screen "Continue" guards.
- [ ] `GlobalConstants` contains `SAVE_PATH_ANALYST` and `SAVE_PATH_HACKER`.
- [ ] Saving/loading correctly targets separate role-specific directories.
