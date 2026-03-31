# TASK 1: THE "RANSOMWARE" APP (ENCRYPTION PUZZLE)

## Description
[REVISED] Create a specialized app for locking down hosts, including proper guards and failure paths.

## Implementation Details
*   **Inheritance:** Inherits from `MinigameBase.gd`.
*   **Logic:** Repurpose the `CalibrationMinigame.gd` signal-matching mechanic to represent "Encrypting Host Sectors."
*   **[BLOCKER]** **Eligibility Guard:** A host already set to `RANSOMED` in `NetworkState` must be blocked from being targeted again.
*   **Config:** Create `RansomwareConfig.tres` to hold signal count, timeout duration, and visual labels.
*   **Success Path:**
    *   Set host state to `RANSOMED` in `NetworkState`.
    *   Emit `offensive_action_performed` with `result: "SUCCESS"` and `trace_cost: TRACE_COST_RANSOMWARE`.
    *   Add bounty to `BountyLedger.gd`.
*   **Failure Path:**
    *   **[BLOCKER]** Emit `offensive_action_performed` with `result: "FAILED"`.
    *   Trace cost for failure is `TRACE_COST_RANSOMWARE * 0.5`.

## Success Criteria
- [ ] **[BLOCKER]** Already-ransomed hosts are blocked from re-encryption.
- [ ] **[BLOCKER]** Failed ransomware attempts emit `result: "FAILED"` with half trace cost.
- [ ] `App_Ransomware.tscn` uses `RansomwareConfig.tres` for its tuning values.
- [ ] Bounty is correctly awarded to `BountyLedger` upon success.
