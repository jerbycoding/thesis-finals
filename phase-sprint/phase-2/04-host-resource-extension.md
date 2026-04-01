# TASK 4: HOST RESOURCE EXTENSION

## Description
[SOLO DEV SCOPE] Add Hacker-specific fields to HostResource.gd. Enables vulnerability scoring and honeypots.

## Implementation Details

### A. New Fields in HostResource.gd
```gdscript
@export var vulnerability_score: float = 0.5  # 0.0-1.0 exploit success chance
@export var is_honeypot: bool = false  # If true, instant LOCKDOWN
```

### B. Validation
```gdscript
func validate() -> bool:
    if hostname.is_empty() or hostname == "UNKNOWN-HOST":
        return false
    if vulnerability_score < 0.0 or vulnerability_score > 1.0:
        push_warning("Host %s has invalid vulnerability_score" % hostname)
        return false
    return true
```

## Success Criteria
- [ ] **[BLOCKER]** `vulnerability_score` field exists and validates
- [ ] **[BLOCKER]** `is_honeypot` field exists
- [ ] Existing hosts remain functional (no regressions)

## OUT OF SCOPE
- ❌ `data_volume` (Exfiltrator cut)
- ❌ `network_bandwidth` (Exfiltrator cut)
- ❌ `data_type` (Exfiltrator cut)
- ❌ `bounty_value` (add in Phase 4)
