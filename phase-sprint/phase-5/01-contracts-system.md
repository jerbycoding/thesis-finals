# TASK 1: THE "CONTRACTS" SYSTEM (THE MISSION LOOP)

## Description
Implement the data-driven contract system, including its full resource schema, token resolution logic, and the 7-step verification sequence.

## Implementation Details

### A. `ContractResource.gd` Schema
*   **Inheritance:** Inherits from `TicketResource`.
*   **[BLOCKER]** [ ] Must include all 12 fields: `contract_id`, `title`, `description`, `narrative_text`, `target_hostname`, `required_payload` (enum: RANSOMWARE, EXFILTRATION, BOTH), `required_data_type`, `time_limit_shifts`, `expiry_consequence`, `bounty_reward`, `completion_dialogue_id`, and `is_optional`.

### B. Token Resolution & Fallback
*   **Logic:** [ ] `NarrativeDirector` must resolve tokens in `narrative_text` using the format `{VAR:hostname:field}`.
*   **Fallback:** [ ] If `VariableRegistry` resolution returns null, the text must display `[REDACTED]`.

### C. The 7-Step Verification Sequence
When a contract is submitted via `App_ContractBoard`, it must execute this order:
1.  [x] Check `NetworkState` for `RANSOMED` status (if required).
2.  [ ] Check `IntelligenceInventory` for the correct `data_type`.
3.  **[BLOCKER]** [ ] Call `consume_item()` to remove the intelligence resource.
4.  [x] Call `BountyLedger.add_bounty()`.
5.  [x] Emit `EventBus.contract_completed(contract_id)`.
6.  [ ] Trigger the `completion_dialogue_id` via `DialogueManager`.
7.  [x] Store the completion event in `HackerHistory`.

### D. `App_ContractBoard.tscn` State Machine
*   **States:** [x] Implement visual states: `EMPTY`, `AVAILABLE` (can accept), `ACTIVE` (in progress), and `READY_TO_SUBMIT` (all conditions met).
*   **Submit Gate:** [x] The `[SUBMIT]` button is only enabled in the `READY_TO_SUBMIT` state.

## Success Criteria
- [ ] **[BLOCKER]** `ContractResource` contains all 12 required fields.
- [ ] **[BLOCKER]** `consume_item()` is called during completion to prevent multi-use of exfiltrated data.
- [ ] Token resolution correctly handles the `{VAR:...}` syntax with `[REDACTED]` fallback.
- [x] `App_ContractBoard` correctly manages its visual states and submit gate.
- [x] Contract rewards and completions are persisted correctly. (Partial: Basic reward persists).
