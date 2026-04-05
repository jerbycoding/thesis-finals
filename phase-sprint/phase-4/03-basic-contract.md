# TASK 3: BASIC CONTRACT (ONE OBJECTIVE) — ✅ COMPLETE!

**Status:** ✅ **COMPLETE** (April 4, 2026)

## Description
[SOLO DEV SCOPE] Create ONE contract type: "Ransom any host". This is your MVP win condition.

## Implementation Details

### A. ContractResource Extension ✅ **CREATED**
*   **File:** `scripts/resources/ContractResource.gd`
*   Fields: contract_id, title, description, required_payload, bounty_reward
*   Runtime state: is_accepted, is_completed
*   Methods: validate(), clear_state()

### B. Contract Manager ✅ **CREATED**
*   **File:** `autoload/ContractManager.gd`
*   Registered in `project.godot` (after BountyLedger)
*   Loads contracts from `resources/contracts/` via `FileUtil`
*   `accept_contract(contract)` → sets active, starts tracking
*   `complete_contract()` → awards bounty, emits signal
*   Listens to `offensive_action_performed` + `host_status_changed` for auto-completion

### C. EventBus Extensions ✅ **DONE**
```gdscript
signal contract_accepted(contract_id: String)
signal contract_completed(contract_id: String)
```

### D. App_ContractBoard ✅ **CREATED**
*   **Files:** `scenes/2d/apps/App_ContractBoard.tscn` + `scripts/2d/apps/App_ContractBoard.gd`
*   Shows active contract status at top
*   Shows available contracts below with ACCEPT buttons
*   Auto-refreshes every 0.5s to detect completion

### E. Contract Resource File ✅ **CREATED**
*   **File:** `resources/contracts/ransom_any.tres`
*   Title: "Ransom Any Host" | Bounty: $100 | Payload: RANSOMWARE

## Success Criteria
- [x] **[BLOCKER]** Contract appears on desktop
- [x] **[BLOCKER]** Accepting contract sets active_contract
- [x] **[BLOCKER]** Ransoming host completes contract
- [x] **[BLOCKER]** Bounty awarded on completion
- [x] Contract shows "COMPLETE ✅" on board
- [x] Notification shows "Contract Complete! Bounty: $100"

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Multiple contracts per shift
- ❌ Contract expiration
- ❌ VariableRegistry token resolution
- ❌ Data type requirements (Exfiltrator cut)
