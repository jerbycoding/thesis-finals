# TASK 3: HONEYPOT IMPLEMENTATION

## Description
[SOLO DEV SCOPE] Mark specific hosts as honeypots. Exploiting them triggers instant LOCKDOWN.

## Implementation Details

### A. HostResource Extension (Phase 2 already added field)
```gdscript
@export var is_honeypot: bool = false
```

### B. TerminalSystem Exploit Guard (Phase 2 already implemented)
```gdscript
# In _cmd_exploit():
if host_resource.is_honeypot:
    EventBus.offensive_action_performed.emit({
        action_type = "exploit",
        target = hostname,
        timestamp = ShiftClock.elapsed_seconds,
        result = "HONEYPOT",
        trace_cost = 100.0  # Instant LOCKDOWN
    })
    return {"success": false, "output": "EXPLOIT FAILED: Unknown error"}
```

### C. Day 2 Shift Configuration
Edit `resources/hacker_shifts/day_2.tres`:
```gdscript
honeypot_hosts = ["FINANCE-SRV-01"]  # One honeypot on Day 2
```

## Success Criteria
- [ ] **[BLOCKER]** Honeypot host exists in Day 2
- [ ] **[BLOCKER]** Exploiting honeypot sets Trace to 100
- [ ] Honeypot looks identical to normal hosts in UI

## OUT OF SCOPE
- ❌ Visual distinction (must be indistinguishable)
- ❌ Honeypot reveal dialogue (add if time permits)
