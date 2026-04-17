# TASK 6: CROSS-PHASE HOOKS & REGISTRATION

## Description
Declare all constants and register all resources needed by future phases (3, 4, 6) to prevent merge conflicts and ensure systems can be developed in parallel.

## Implementation Details

### A. Trace Cost Constants
*   **File:** `autoload/GlobalConstants.gd`
*   **Action:** [x] Declare the trace cost for all Phase 2 actions. These will be read by `TraceLevelManager` in Phase 3.
    *   `const TRACE_COST_EXPLOIT = 15.0`
    *   `const TRACE_COST_PIVOT = 5.0`
    *   `const TRACE_COST_SPOOF = 8.0`
    *   `const TRACE_COST_PHISH = 10.0`

### B. App Registration
*   For `App_LogPoisoner.tscn` and `App_PhishCrafter.tscn`:
    *   [ ] Create a corresponding `AppConfigResource` file for each.
    *   [ ] Add both `AppConfigResource` files to `resources/permissions/HackerAppProfile.tres` to make them accessible in Hacker mode.

### C. Audio Hooks
*   **File:** `autoload/AudioManager.gd`
*   **Action:** [ ] Wire up placeholder calls for the following SFX events. This allows the audio designer to substitute assets in Phase 6 without requiring new code.
    *   `play_sfx("hacker_exploit_success")`
    *   `play_sfx("hacker_exploit_fail")`
    *   `play_sfx("hacker_pivot")`
    *   `play_sfx("hacker_phish_sent")`

## Success Criteria
- [x] **[BLOCKER]** All four `TRACE_COST_*` constants are declared in `GlobalConstants.gd`.
- [ ] `App_LogPoisoner` and `App_PhishCrafter` are registered in `HackerAppProfile.tres` and appear in-game.
- [ ] `AudioManager` contains placeholder `play_sfx()` calls for the four specified events.
