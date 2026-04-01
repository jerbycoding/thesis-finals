# PHASE 5: CAMPAIGN (SOLO DEV SCOPE)

## Objective
Add 3-day narrative arc. **ONE working campaign:** Day 1 → Day 2 → Day 3 with Broker dialogue.

## Duration
**2 weeks** (Solo Dev)

## Tasks (Consolidated from 6 → 5)

| # | Task | Duration | BLOCKERs |
|---|------|----------|----------|
| 1 | HackerShiftResource | 2 days | 3 shift files (Day 1-3) |
| 2 | ContractManager Extension | 2 days | Shift-based contracts |
| 3 | Honeypot Implementation | 1 day | Instant LOCKDOWN trigger |
| 4 | Broker Dialogue | 2 days | 3 dialogue files |
| 5 | Save System Extension | 2 days | Hacker data persistence |

## Phase 5 Playability Test

**Demo Script (15 minutes):**
1. F1 to load Hacker campaign
2. **Day 1:**
   - Broker: "Prove yourself."
   - Accept contract
   - Exploit + Ransom host
   - Contract complete
3. **Day 2:**
   - Broker: "Good work."
   - Exploit honeypot → instant LOCKDOWN (fail state)
   - Learn from mistake
   - Complete contract legitimately
4. **Day 3:**
   - Broker: "There's more to this..."
   - Complete contract
   - Campaign pause (Days 4-7 cut)

**What Works:**
✅ 3-day progression
✅ Broker narrative
✅ Honeypot trap
✅ Save/load

**What Doesn't Work Yet:**
❌ No Days 4-7
❌ No Mirror Mode
❌ No full Broker reveal

## Integration Checklist

- [ ] All 5 tasks complete
- [ ] Day 1-3 shifts load correctly
- [ ] Broker dialogue plays on each day
- [ ] Honeypot triggers LOCKDOWN on Day 2
- [ ] Save/load works for Hacker data
- [ ] **Demo recorded** (15-minute campaign video)

## Phase 5 → Phase 6 Handoff

**Phase 5 Must Provide:**
- `HackerShiftResource` with Day 1-3
- `ContractManager` shift integration
- `HackerHistory.history` populated

**Phase 6 Will Add:**
- Mirror Mode (history vs. logs)
- Glitch aesthetics
- Final testing

---

**Solo Dev Note:** 3 days is ENOUGH for thesis defense. You're showing: progression, narrative, consequences. Days 4-7 are content, not architecture.
