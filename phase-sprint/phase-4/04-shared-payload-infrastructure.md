# TASK 4: SHARED PAYLOAD INFRASTRUCTURE

## Description
Implement the shared singletons, `GameState` variables, and global methods required by all payload apps.

## Implementation Details

### A. New Singletons
*   **`BountyLedger.gd`:** [x] Create and add to autoload (after `RivalAI`). Tracks accumulated bounty points for the shift.
*   **`IntelligenceInventory.gd`:** [x] Create and add to autoload (after `BountyLedger`). Stores `IntelligenceResource` items. Must include a `write-on-add` mechanism for crash safety.

### B. GameState & Resource Extensions
*   **`GameState.gd`:** [ ] Add `var hacker_inventory := []` and `var hacker_exfiltrated_hosts := []`.
*   **`HostResource.gd`:** [ ] Add `var data_volume: int = 3` (stream count) and `var network_bandwidth: float = 1.0`.

### C. LogSystem Extension
*   **[BLOCKER]** [ ] Implement `LogSystem.prune_logs_for_host(hostname, scope) -> Array`.
    *   **Analyst Guard:** Must check `current_role == Role.HACKER` before executing.
    *   **Return Type:** **Must** return an `Array` of the removed `LogResource` entries (for Mirror Mode), not just a count or void.

### D. Shared Eligibility Gate
*   **Logic:** [x] All three payload apps must use a shared base method (or utility) to check conditions before launch. (Partial: Implemented in `App_Ransomware.gd`).
    1.  `current_foothold != ""` (Must be on a host).
    2.  `TraceLevelManager.is_isolation_in_progress() == false` (Cannot launch during LOCKDOWN).
    3.  `current_role == Role.HACKER`.

### E. HackerHistory Tick Collapsing
*   **Logic:** [ ] Modify `HackerHistory.gd` to include a rule that collapses consecutive `exfiltration_tick` signals into a single "Data Exfiltration" entry for the Mirror Mode timeline.

## Success Criteria
- [ ] **[BLOCKER]** `LogSystem.prune_logs_for_host()` returns an `Array` of removed logs.
- [ ] **[BLOCKER]** `GameState.hacker_inventory` and `hacker_exfiltrated_hosts` are declared.
- [x] **[BLOCKER]** The shared eligibility gate is implemented and prevents app launch during LOCKDOWN.
- [ ] **[BLOCKER]** `HackerHistory` implements the tick-collapsing rule for exfiltration.
- [x] `BountyLedger` is created and registered in autoload.
- [x] `IntelligenceInventory` is created and registered in autoload.
- [ ] All required `GlobalConstants` (e.g., `EXFILTRATION_PARTIAL_THRESHOLD`) are declared.
- [x] `HOST_STATUS.RANSOMED` exists and is usable.
