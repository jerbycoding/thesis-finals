# TASK 5: NETWORK STATE EXTENSION — ✅ COMPLETE!

**Status:** ✅ **COMPLETE** (April 4, 2026)

## Description
[SOLO DEV SCOPE] Add RANSOMED status to NetworkState. Enables ransomware win condition.

## Implementation Details

### A. GlobalConstants Extension ✅ **DONE**
```gdscript
const HOST_STATUS = {
    "CLEAN": 0,
    "SUSPICIOUS": 1,
    "INFECTED": 2,
    "ISOLATED": 3,
    "RANSOMED": 4  # NEW ✅
}
```

### B. NetworkState.gd Extension ✅ **DONE**
*   `"RANSOMED"` string-to-int conversion in `update_host_state()` ✅
*   `get_footholds()` — returns compromised hostnames ✅
*   `get_host_vulnerability(hostname)` — returns vulnerability_score float ✅

## Success Criteria
- [x] **[BLOCKER]** RANSOMED status exists in HOST_STATUS
- [x] **[BLOCKER]** NetworkState can set host to RANSOMED
- [ ] NetworkMapper shows RANSOMED status correctly (untested — needs visual UI)

## OUT OF SCOPE
- ❌ RANSOMED status persistence to save (add in Phase 5)
- ❌ Visual distinction in NetworkMapper (color ok)
