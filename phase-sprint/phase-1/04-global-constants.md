# TASK 4: GLOBAL CONSTANTS PRE-DECLARATION

## Description
[SOLO DEV SCOPE] Pre-declare Hacker colors and trace costs. Prevents merge conflicts later.

## Implementation Details

### A. Colors in GlobalConstants.gd
```gdscript
const COLOR_HACKER_GREEN = Color("#00ff00")
const COLOR_HACKER_AMBER = Color("#ffbf00")  # Accessibility fallback
const COLOR_TRACE_WARNING = Color("#ffff00")
const COLOR_TRACE_CRITICAL = Color("#ff0000")
```

### B. Trace Costs (Phase 2+ Prep)
```gdscript
const TRACE_COST_EXPLOIT = 15.0
const TRACE_COST_PHISH = 10.0
const TRACE_COST_RANSOMWARE = 40.0
const TRACE_DECAY_RATE = 1.0
```

### C. AI Thresholds (Phase 3 Prep)
```gdscript
const RIVAL_AI_SEARCHING_THRESHOLD = 30.0
const RIVAL_AI_LOCKDOWN_THRESHOLD = 70.0
const RIVAL_AI_BASE_ISOLATION_SECONDS = 20.0
```

## Success Criteria
- [ ] **[BLOCKER]** All 4 color constants declared
- [ ] **[BLOCKER]** All 4 trace cost constants declared
- [ ] All 3 AI threshold constants declared

## OUT OF SCOPE
- ❌ Save path constants (add in Phase 5)
- ❌ Exfiltration constants (cut Exfiltrator from scope)
