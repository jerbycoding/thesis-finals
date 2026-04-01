# TASK 3: BASIC CONTRACT (ONE OBJECTIVE)

## Description
[SOLO DEV SCOPE] Create ONE contract type: "Ransom any host". This is your MVP win condition.

## Implementation Details

### A. ContractResource Extension
Create `scripts/resources/ContractResource.gd`:
```gdscript
extends Resource
class_name ContractResource

@export var contract_id: String
@export var title: String
@export var description: String
@export var required_payload: String  # "RANSOMWARE"
@export var bounty_reward: int = 100

# Runtime state
var is_accepted := false
var is_completed := false
var target_hostname := ""
```

### B. Simple Contract Manager (Mini, not full system)
Create `autoload/ContractManager.gd`:
```gdscript
extends Node

var active_contract: ContractResource = null

func accept_contract(contract: ContractResource):
    active_contract = contract
    active_contract.is_accepted = true
    EventBus.contract_accepted.emit(contract.contract_id)

func check_completion():
    if not active_contract or not active_contract.is_accepted:
        return
    
    if active_contract.required_payload == "RANSOMWARE":
        # Check if any host is RANSOMED
        for hostname in NetworkState.host_states:
            var state = NetworkState.get_host_state(hostname)
            if state.get("status") == "RANSOMED":
                complete_contract()
                return

func complete_contract():
    if not active_contract:
        return
    
    active_contract.is_completed = true
    BountyLedger.add_bounty(active_contract.bounty_reward)
    EventBus.contract_completed.emit(active_contract.contract_id)
    
    # Show win notification
    NotificationManager.show_notification("Contract Complete! Bounty: %d" % active_contract.bounty_reward, "success")
```

### C. EventBus Extensions
```gdscript
signal contract_accepted(contract_id: String)
signal contract_completed(contract_id: String)
```

### D. App_ContractBoard (Simple UI)
Create `scenes/2d/apps/App_ContractBoard.tscn`:
- Shows current contract title/description
- [ACCEPT] button → calls `ContractManager.accept_contract()`
- Shows "COMPLETE" when contract is done

## Success Criteria
- [ ] **[BLOCKER]** Contract appears on desktop
- [ ] **[BLOCKER]** Accepting contract sets active_contract
- [ ] **[BLOCKER]** Ransoming host completes contract
- [ ] Bounty awarded on completion

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Multiple contracts per shift
- ❌ Contract expiration
- ❌ VariableRegistry token resolution
- ❌ Data type requirements (Exfiltrator cut)
