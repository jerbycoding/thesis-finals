# TASK 5: ROLE GUARDS (SIGNAL HYGIENE)

## Description
[SOLO DEV SCOPE] Add role guard comments to 4 Analyst singletons. Prevents "Kill Chain bleed" from Hacker actions.

## Implementation Details

Add this comment at top of `_ready()` or signal connection function in each file:

### A. ConsequenceEngine.gd
```gdscript
# ROLE GUARD: This engine must NOT consume hacker signals like 'offensive_action_performed'.
# Hacker actions do not advance the Analyst's Kill Chain.
```

### B. ValidationManager.gd
```gdscript
# ROLE GUARD: This manager's rules apply only to the Analyst. Hacker commands bypass it.
```

### C. IntegrityManager.gd
```gdscript
# ROLE GUARD: Organization Damage is handled by the Analyst campaign.
# In _apply_change(), check: if GameState.current_role == Role.HACKER: return
```

### D. TicketManager.gd
```gdscript
# ROLE GUARD: This manager must not attach hacker actions to Analyst tickets.
```

## Success Criteria
- [ ] **[BLOCKER]** All 4 files contain role guard comments
- [ ] IntegrityManager bypasses damage for Hacker role
- [ ] ConsequenceEngine does not consume `offensive_action_performed`

## OUT OF SCOPE
- ❌ Actual signal disconnection logic (add in Phase 3 with RivalAI)
- ❌ Unit tests for guards (add in Phase 6)
