# TASK 2: DATA EXFILTRATION (THE STEAL MECHANIC)

## Description
Implement a progress-based data theft system with multi-stream support, partial rewards, and LOCKDOWN interruption.

## Implementation Details
*   **Inheritance:** [ ] Inherits from `MinigameBase.gd`.
*   **[BLOCKER]** **LOCKDOWN Interruption:** [ ] The app must listen for `EventBus.rival_ai_isolation_complete`. If fired mid-transfer, it must execute an interruption sequence and apply any partial rewards.
*   **Multi-Stream Logic:**
    *   [ ] Number of streams is controlled by `HostResource.data_volume`.
    *   **Tick Emission:** [ ] Emit `offensive_action_performed` with `action_type: "exfiltration_tick"` every 2 seconds via `TimeManager`. This is how Trace accumulates.
*   **Speed Formula:** [ ] Throttled by `HostResource.network_bandwidth` and `HeatManager.heat_multiplier`.
*   **Partial Reward Logic:**
    *   [ ] If isolation fires at or above `EXFILTRATION_PARTIAL_THRESHOLD` (50%), the player receives a partial `IntelligenceResource`.
    *   [ ] Below 50%, no reward is granted.
*   **[BLOCKER]** **Resource Schema:** [ ] The `IntelligenceResource` must include: `source_hostname`, `data_type`, `shift_day`, `data_label`, `is_partial`, and `trace_cost_total`.
*   **Label Caching:** [ ] The `data_label` (e.g., "Payroll Data") must be generated from `VariableRegistry` **once** at the start of the minigame and cached.

## Success Criteria
- [ ] **[BLOCKER]** A LOCKDOWN mid-transfer correctly triggers the interruption and evaluates partial rewards.
- [ ] **[BLOCKER]** The 50% partial reward threshold is implemented and verified.
- [ ] **[BLOCKER]** The `IntelligenceResource` schema contains all 6 specified fields.
- [ ] Streams emit `exfiltration_tick` every 2 seconds.
- [ ] Transfer speed correctly scales with heat multiplier.
- [ ] `IntelligenceInventory` is updated upon success or partial reward.
