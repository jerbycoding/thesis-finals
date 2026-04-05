# TASK 3: HONEYPOT INTEGRATION

## Description
[SOLO DEV SCOPE] Configure honeypot host for Day 2. Exploiting it triggers instant LOCKDOWN.

## Implementation Details

### A. HostResource Extension (ALREADY EXISTS)
```gdscript
# resources/HostResource.gd — already has:
@export var is_honeypot: bool = false
```

### B. TerminalSystem Exploit Guard (ALREADY IMPLEMENTED)
```gdscript
# TerminalSystem.gd, _cmd_exploit(), Step 3 — ALREADY EXISTS:
if host_resource and host_resource.is_honeypot:
    EventBus.offensive_action_performed.emit({
        "action_type": "exploit",
        "target": hostname,
        "result": "HONEYPOT",
        "trace_cost": 100.0  # Instant LOCKDOWN
    })
    return {"success": false, "output": "⚠ HONEYPOT DETECTED!"}
```

### C. Honeypot Host Already Exists
```
resources/hosts/HoneypotServer.tres → is_honeypot = true ✅
```

### D. Day 2 Shift Configuration
In `resources/hacker_shifts/day_2.tres`:
```gdscript
honeypot_hosts = ["FINANCE-SRV-01"]  # Mark this host as honeypot for Day 2
```

**Note:** `HoneypotServer.tres` already exists with `is_honeypot = true`. We just need to reference it in the Day 2 shift config.

## Success Criteria
- [x] Honeypot host exists (`HoneypotServer.tres`)
- [x] Honeypot detection in TerminalSystem
- [ ] **[BLOCKER]** Day 2 shift marks honeypot host
- [ ] Exploiting honeypot sets Trace to 100 → instant LOCKDOWN
- [ ] Honeypot looks identical to normal hosts in UI

## OUT OF SCOPE
- ❌ Visual distinction (must be indistinguishable)
- ❌ Honeypot reveal dialogue (add if time permits)
