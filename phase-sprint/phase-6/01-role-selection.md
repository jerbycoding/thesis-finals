# TASK 1: ROLE SELECTION & SAVE SEPARATION

## Description
Update the `TitleScreen.tscn` to allow the player to choose their path at the start of a new game.

## Implementation Details
*   **Action:** Add "Analyst Campaign" and "Hacker Campaign" options to the title screen.
*   **Logic:** This selection must set `GameState.current_role` and `GameState.is_campaign_session = true`.
*   **Save Separation:** Verify that the `SaveSystem` uses separate JSON files and directories for each career path (`user://saves/analyst/` vs `user://saves/hacker/`) to prevent any state corruption.

## Success Criteria
- [ ] The player can start a new game in either role from the Title Screen.
- [ ] Starting a Hacker campaign correctly sets the global role.
- [ ] Saving and loading the Analyst campaign does not affect the Hacker campaign's progress.
