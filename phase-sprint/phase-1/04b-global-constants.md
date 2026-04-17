# TASK 4b: GLOBAL CONSTANTS PRE-DECLARATION

## Description
Pre-declare all `Hacker` role-specific colors and trace costs in `GlobalConstants.gd`. This is critical to prevent merge conflicts and errors when other phases (3, 4, 6) need to access them.

## Implementation Details
*   **File:** `autoload/GlobalConstants.gd`
*   **Action:** [x] Add the following new constants. The exact color values can be placeholders for now, but the constant names **must** be exact.
    *   `const COLOR_HACKER_GREEN = Color("#00ff00")`
    *   `const COLOR_HACKER_AMBER = Color("#ffbf00")`
    *   `const COLOR_TRACE_WARNING = Color("#ffff00")`
    *   `const COLOR_TRACE_CRITICAL = Color("#ff0000")`
    *   (All `TRACE_COST_*` constants as defined in the master document)

## Success Criteria
- [x] **[BLOCKER]** `COLOR_HACKER_GREEN` is declared.
- [x] **[BLOCKER]** `COLOR_HACKER_AMBER` is declared.
- [x] **[BLOCKER]** `COLOR_TRACE_WARNING` is declared.
- [x] **[BLOCKER]** `COLOR_TRACE_CRITICAL` is declared.
- [x] All `TRACE_COST_*` constants from the project specification are present in `GlobalConstants.gd`.
