# TASK 5: NETWORK STATE EXTENSION

## Description
[SOLO DEV SCOPE] Add RANSOMED status to NetworkState. Enables ransomware win condition.

## Implementation Details

### A. GlobalConstants Extension
Add to HOST_STATUS:
```gdscript
const HOST_STATUS = {
    "CLEAN": 0,
    "SUSPICIOUS": 1,
    "INFECTED": 2,
    "ISOLATED": 3,
    "RANSOMED": 4  # NEW
}
```

### B. NetworkState.gd Extension
```gdscript
# In update_host_state(), handle "RANSOMED" status:
if new_state.has("status"):
    var status_val = new_state["status"]
    var status_int = 0
    match status_val:
        "CLEAN": status_int = GlobalConstants.HOST_STATUS.CLEAN
        "SUSPICIOUS": status_int = GlobalConstants.HOST_STATUS.SUSPICIOUS
        "INFECTED": status_int = GlobalConstants.HOST_STATUS.INFECTED
        "ISOLATED": status_int = GlobalConstants.HOST_STATUS.ISOLATED
        "RANSOMED": status_int = GlobalConstants.HOST_STATUS.RANSOMED  # NEW
    EventBus.host_status_changed.emit(hostname, status_int)
```

### C. HostResource Display
```gdscript
func get_status_string() -> String:
    var ns = Engine.get_main_loop().root.get_node_or_null("NetworkState")
    if ns:
        var state = ns.get_host_state(hostname)
        if state.has("status"):
            var s = state["status"]
            if typeof(s) == TYPE_INT:
                match s:
                    0: return "CLEAN"
                    1: return "SUSPICIOUS"
                    2: return "INFECTED"
                    3: return "ISOLATED"
                    4: return "RANSOMED"  # NEW
            return str(s)
    return initial_status
```

## Success Criteria
- [ ] **[BLOCKER]** RANSOMED status exists in HOST_STATUS
- [ ] **[BLOCKER]** NetworkState can set host to RANSOMED
- [ ] NetworkMapper shows RANSOMED status correctly

## OUT OF SCOPE
- ❌ RANSOMED status persistence to save (add in Phase 5)
- ❌ Visual distinction in NetworkMapper (color ok)
