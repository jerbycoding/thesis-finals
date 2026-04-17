# TASK 4: CROSS-PHASE INFRASTRUCTURE (PHASE 3)

## Description
Declare all constants, signals, public API methods, and other hooks required by future phases (4, 5, 6) to ensure a clean handoff and enable parallel development.

## Implementation Details

### A. Global Constants
*   **File:** `autoload/GlobalConstants.gd`
*   **Action:** [x] Declare the following constants:
    *   `const TRACE_COST_RANSOMWARE = 40.0`
    *   `const TRACE_DECAY_RATE = 1.0`
    *   `const RIVAL_AI_SEARCHING_THRESHOLD = 30.0`
    *   `const RIVAL_AI_LOCKDOWN_THRESHOLD = 70.0`
    *   `const RIVAL_AI_BASE_ISOLATION_SECONDS = 20.0`

### B. EventBus Signals
*   **File:** `autoload/EventBus.gd`
*   **Action:** [x] Declare the following signals:
    *   `signal rival_ai_state_changed(new_state: int)`
    *   `signal rival_ai_isolation_complete(hostname: String)`

### C. Public API Methods & Stubs
*   **File:** `autoload/TraceLevelManager.gd`
    *   [x] `func get_trace_level() -> float`
    *   [x] `func get_trace_normalized() -> float`
    *   [ ] `func reduce_trace(amount: float)`
    *   [ ] `func set_isolation_in_progress(value: bool)`
*   **File:** `autoload/RivalAI.gd`
    *   [ ] `func force_state(new_state: int)`
*   **File:** `autoload/TerminalSystem.gd`
    *   [ ] `func inject_system_message(text: String)`

### D. Audio Hooks
*   **File:** `autoload/AudioManager.gd`
*   **Action:** [ ] Wire up placeholder calls for the following SFX events:
    *   `play_sfx("rival_ai_searching")`
    *   `play_sfx("rival_ai_lockdown")`
    *   `play_sfx("rival_ai_isolation_start")`
    *   `play_sfx("rival_ai_isolation_success")`

### E. HackerHistory Extension
*   **File:** `autoload/HackerHistory.gd`
*   **Action:** [x] The singleton must also listen for `rival_ai_isolation_complete` and record it as a forensic event.

## Success Criteria
- [x] **[BLOCKER]** All five specified constants are declared in `GlobalConstants.gd`.
- [x] **[BLOCKER]** Both `rival_ai_*` signals are declared in `EventBus.gd`.
- [ ] **[BLOCKER]** All six specified public methods/stubs exist in their respective files.
- [x] `HackerHistory` is updated to record the isolation event.
- [ ] All four audio hooks are added to `AudioManager`.
