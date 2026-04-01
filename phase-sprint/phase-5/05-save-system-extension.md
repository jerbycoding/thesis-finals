# TASK 5: SAVE SYSTEM EXTENSION

## Description
[SOLO DEV SCOPE] Add basic save/load for Hacker campaign. Single save file for now.

## Implementation Details

### A. SaveSystem.gd Extension
```gdscript
# In save_game():
var save_data = {
    # ... existing Analyst data ...
    "hacker_role": {
        "current_day": NarrativeDirector.current_day,
        "bounty": BountyLedger.get_total_bounty(),
        "completed_contracts": ContractManager.get_completed_ids(),
        "hacker_history": HackerHistory.history
    }
}

# In load_game():
func _distribute_loaded_data(data: Dictionary):
    if data.has("hacker_role"):
        var hacker_data = data.hacker_role
        BountyLedger.set_total_bounty(hacker_data.bounty)
        HackerHistory.history = hacker_data.hacker_history
```

### B. ContractManager Extension
```gdscript
func get_completed_ids() -> Array[String]:
    var ids: Array[String] = []
    for contract in contract_pool:
        if contract.is_completed:
            ids.append(contract.contract_id)
    return ids
```

## Success Criteria
- [ ] **[BLOCKER]** Hacker data saves to file
- [ ] **[BLOCKER]** Hacker data loads correctly
- [ ] Bounty persists after reload

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Dual-directory separation (single save ok for now)
- ❌ Crash recovery logic
- ❌ Continue button guards on title screen
