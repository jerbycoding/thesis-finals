# TASK 6: INFRASTRUCTURE & SUPPORT (PHASE 5)

## Description
Declare the remaining signals, implement debug tools, and add automated audit checks to ensure shift and contract data is valid.

## Implementation Details

### A. EventBus Signals
*   **[BLOCKER]** [x] Declare the following signals in `autoload/EventBus.gd`:
    *   `signal contract_accepted(contract_id: String)`
    *   `signal contract_submitted(contract_id: String)`
    *   `signal contract_completed(contract_id: String)`
    *   `signal contract_expired(contract_id: String)`
    *   `signal hacker_shift_started(day: int)`
    *   `signal hacker_campaign_complete`

### B. Debug Tools
*   **[BLOCKER]** [ ] Implement `DebugManager` hotkeys for the hacker role:
    *   **F3:** Skip the current hacker shift (mark all active contracts as complete).
    *   **F4:** Force-complete the active contract.
    *   **Role Guards:** Ensure these and F9, F1/F2 are correctly guarded.

### C. Audit Checks
*   [ ] Modify `ResourceAuditManager.gd` to perform:
    1.  A honeypot/contract cross-reference check (ensure no contract targets a honeypot).
    2.  A `VariableRegistry` token resolution audit (ensure all tokens resolve to valid fields).

## Success Criteria
- [x] **[BLOCKER]** All six specified signals are declared in `EventBus.gd`.
- [ ] **[BLOCKER]** F3/F4 debug commands correctly bypass contracts and shifts.
- [ ] **[BLOCKER]** `ResourceAuditManager` correctly flags honeypot-contract conflicts.
- [x] `DebugManager` hotkeys are correctly guarded by role. (Partial: role guards in place for existing keys).
- [ ] `AudioManager` SFX hooks for contract lifecycle events are wired up.
