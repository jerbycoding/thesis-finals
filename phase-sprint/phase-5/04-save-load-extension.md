# TASK 4: SAVE/LOAD EXTENSION

## Description
[SOLO DEV SCOPE] Add basic save/load for Hacker campaign data.

## Implementation Details

### A. SaveSystem.gd Extension
In `save_game()`, add hacker data slice:
```gdscript
var save_data = {
    # ... existing Analyst data ...
    "hacker_role": {
        "current_day": NarrativeDirector.current_hacker_day,
        "bounty": BountyLedger.get_bounty(),
        "footholds": GameState.hacker_footholds,
        "current_foothold": GameState.current_foothold,
        "history": HackerHistory.get_history_log() if HackerHistory else []
    }
}
```

In `_distribute_loaded_data()`:
```gdscript
if data.has("hacker_role"):
    var hacker_data = data.hacker_role
    BountyLedger.total_bounty = hacker_data.get("bounty", 0)
    GameState.hacker_footholds = hacker_data.get("footholds", {})
    GameState.current_foothold = hacker_data.get("current_foothold", "")
    # History restore would go in HackerHistory
```

### B. BountyLedger Extension
```gdscript
func set_bounty(amount: int):
    total_bounty = amount
```

### C. ContractManager Extension
```gdscript
func get_completed_ids() -> Array[String]:
    var ids: Array[String] = []
    for contract in available_contracts:
        if contract.is_completed:
            ids.append(contract.contract_id)
    return ids
```

## Success Criteria
- [ ] **[BLOCKER]** Hacker data saves to file
- [ ] **[BLOCKER]** Hacker data loads correctly
- [ ] Bounty persists after game restart

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Dual-directory separation (single save ok for now)
- ❌ Crash recovery logic
- ❌ Continue button guards on title screen
