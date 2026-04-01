# TASK 4: EVENTBUS EXTENSIONS (PHASE 3 SIGNALS)

## Description
[SOLO DEV SCOPE] Add 2 new signals for RivalAI communication.

## Implementation Details

### A. New Signals in EventBus.gd
```gdscript
# Phase 3: AI Counter-Measures
signal rival_ai_state_changed(new_state: int)
signal rival_ai_isolation_complete(hostname: String)
```

### B. Signal Consumers (Phase 3+)
| Signal | Emitted By | Consumers |
|--------|-----------|-----------|
| `rival_ai_state_changed` | RivalAI | UI trace meter, AudioManager (Phase 6) |
| `rival_ai_isolation_complete` | RivalAI | HackerHistory, TransitionManager, App_Exfiltrator (Phase 4/5) |

## Success Criteria
- [ ] **[BLOCKER]** Both signals declared
- [ ] RivalAI emits `rival_ai_state_changed` on transition
- [ ] RivalAI emits `rival_ai_isolation_complete` on isolation

## OUT OF SCOPE
- ❌ Phase 5 signals (contract_*, hacker_shift_*)
- ❌ Phase 6 signals (mirror_mode_*, desktop_theme_*)
