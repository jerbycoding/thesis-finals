# TASK 2: CONTRACT MANAGER EXTENSION

## Description
[SOLO DEV SCOPE] Extend ContractManager to handle shift-based contracts.

## Implementation Details

### A. Contract Pool
```gdscript
var contract_pool: Array[ContractResource] = []

func load_shift_contracts(shift: HackerShiftResource):
    contract_pool = shift.contracts.duplicate()
    active_contract = null

func get_available_contract() -> ContractResource:
    for contract in contract_pool:
        if not contract.is_accepted:
            return contract
    return null
```

### B. EventBus Extensions
```gdscript
signal hacker_shift_started(day: int)
```

### C. NarrativeDirector Integration
```gdscript
# When starting hacker shift:
func start_hacker_shift(day: int):
    var shift = hacker_shift_library[day]
    ContractManager.load_shift_contracts(shift)
    EventBus.hacker_shift_started.emit(day)
    
    # Show broker dialogue if exists
    if shift.broker_intro_dialogue_id != "":
        DialogueManager.start_remote_dialogue("broker", shift.broker_intro_dialogue_id)
```

## Success Criteria
- [ ] **[BLOCKER]** Contracts load from shift resource
- [ ] **[BLOCKER]** `hacker_shift_started` emits on shift start
- [ ] Broker dialogue plays on Day 1

## OUT OF SCOPE
- ❌ Contract expiration logic
- ❌ Multiple simultaneous contracts
