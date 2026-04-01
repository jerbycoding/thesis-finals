# TASK 3: PIVOT COMMAND (EVASION MECHANIC)

## Description
[SOLO DEV SCOPE] Add `pivot` command. This is the ONLY way to abort isolation.

## Implementation Details

### A. TerminalSystem Extension
Add new command:
```gdscript
"pivot": {
    "description": "Pivot to compromised host",
    "syntax": "pivot [hostname]",
    "risk_level": 3
}
```

### B. _cmd_pivot(args) Implementation
```gdscript
func _cmd_pivot(args: Array) -> Dictionary:
    if args.is_empty():
        return {"success": false, "output": "Syntax: pivot [hostname]"}
    
    var hostname = args[0].to_upper()
    
    # Ownership guard
    if not GameState.hacker_footholds.has(hostname):
        return {"success": false, "output": "Error: Host not compromised"}
    
    # Update current foothold
    GameState.current_foothold = hostname
    
    # Emit signal (for Trace accumulation)
    EventBus.offensive_action_performed.emit({
        action_type = "pivot",
        target = hostname,
        timestamp = ShiftClock.elapsed_seconds,
        result = "SUCCESS",
        trace_cost = GlobalConstants.TRACE_COST_PIVOT  # 5.0
    })
    
    # Abort isolation if in progress
    if RivalAI and RivalAI.is_isolation_in_progress():
        RivalAI.abort_isolation()
        return {"success": true, "output": "Pivot successful. Isolation aborted."}
    
    return {"success": true, "output": "Pivoted to %s" % hostname}
```

### C. GlobalConstants Addition
```gdscript
const TRACE_COST_PIVOT = 5.0
```

## Success Criteria
- [ ] **[BLOCKER]** `pivot WEB-SRV-01` works after exploiting
- [ ] **[BLOCKER]** Pivot aborts isolation countdown
- [ ] Pivot fails if host not in footholds
- [ ] Pivot emits signal with 5.0 trace cost

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Pivot during LOCKDOWN to un-compromised host (simple guard ok)
- ❌ Visual feedback for pivot (terminal text only)
