# PHASE 3: AI RESPONSE (SOLO DEV SCOPE)

## Objective
Add AI that chases you. **ONE working tension loop:** Exploit → Trace rises → AI catches you → Connection Lost.

## Duration
**1.5 weeks** (Solo Dev)

## Tasks (Consolidated from 4 → 5)

| # | Task | Duration | BLOCKERs |
|---|------|----------|----------|
| 1 | RivalAI State Machine | 3 days | 3 states, threshold transitions |
| 2 | Isolation Sequence | 2 days | Countdown, Connection Lost |
| 3 | Pivot Command | 1 day | Evades isolation |
| 4 | EventBus Extensions | 0.5 day | 2 new signals |
| 5 | HackerHistory Extension | 0.5 day | Record isolation |

## Phase 3 Playability Test

**Demo Script (2-3 minutes):**
1. F1 to load Hacker campaign
2. Open Terminal
3. Exploit 3 hosts (Trace: 0 → 45)
4. AI says "ANOMALY DETECTED" (SEARCHING state)
5. Exploit 2 more hosts (Trace: 45 → 75)
6. AI says "COMPROMISE DETECTED" (LOCKDOWN state)
7. Wait 20 seconds → "Connection Lost"
8. **Alternative:** Pivot before 20s → isolation aborts

**Challenge:** "Exploit 5 hosts before getting isolated"

**What Works:**
✅ AI chases you
✅ Tension system
✅ Evasion mechanic
✅ Failure state

**What Doesn't Work Yet:**
❌ No payload apps to complete objectives
❌ No win condition
❌ No campaign structure

## Integration Checklist

- [ ] All 5 tasks complete
- [ ] AI transitions at Trace 30 and 70
- [ ] Isolation countdown visible (terminal message)
- [ ] Pivot aborts isolation
- [ ] **Demo recorded** (3-minute challenge run)

## Phase 3 → Phase 4 Handoff

**Phase 3 Must Provide:**
- `RivalAI.current_state` accessible
- `RivalAI.is_isolation_in_progress()` working
- `rival_ai_isolation_complete` signal emitting

**Phase 4 Will Add:**
- Ransomware app (win condition)
- Basic contract system
- Bounty tracking

---

**Solo Dev Note:** This is your first "game" — there's tension and failure. But no win condition yet. Phase 4 adds that.
