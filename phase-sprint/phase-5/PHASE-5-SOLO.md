# PHASE 5: CAMPAIGN — 3-DAY NARRATIVE ARC

## Objective
Build the 3-day campaign loop. **ONE complete playthrough:** Day 1 (Broker intro) → Day 2 (honeypot lesson) → Day 3 (Broker reveal). Player must survive, complete contracts, and reach the end.

## Duration
**2 weeks** (Solo Dev)

## Current State Assessment

### What Already Exists
| Feature | Status |
|---------|--------|
| Ransomware app (win condition) | ✅ Phase 4 complete |
| Contract Board | ✅ Phase 4 complete |
| BountyLedger | ✅ Phase 4 complete |
| `HackerShiftResource` class | ❌ Not created yet |
| `hacker_shifts/` directory | ❌ Empty |
| Broker dialogue files | ❌ Not created |
| Honeypot host (`HoneypotServer.tres`) | ✅ Exists, `is_honeypot = true` |
| `is_honeypot` field on HostResource | ✅ Exists |
| Honeypot detection in TerminalSystem | ✅ Step 3 of `_cmd_exploit()` |
| `contract_accepted` / `contract_completed` signals | ✅ Phase 4 |
| DialogueManager | ✅ Working for NPCs |
| SaveSystem | ✅ Working for Analyst campaign |

### What Phase 5 Needs
| Component | Effort |
|-----------|--------|
| `HackerShiftResource.gd` | 1 file |
| `day_1.tres`, `day_2.tres`, `day_3.tres` | 3 resource files |
| Broker dialogue (3 files) | 3 resource files |
| NarrativeDirector hacker shift loading | ~40 lines |
| ContractManager shift integration | ~20 lines |
| SaveSystem hacker data persistence | ~30 lines |
| Hacker role switch flow (title → campaign start) | ~20 lines |

## Sprint Tasks (5 Consolidated)

| # | Task | Duration | BLOCKERs | Deliverable |
|---|------|----------|----------|-------------|
| 1 | Hacker Shift System | 3 days | None | `HackerShiftResource.gd` + 3 shift files + NarrativeDirector loading |
| 2 | Broker Dialogue | 2 days | None | 3 dialogue files + DialogueManager remote start |
| 3 | Honeypot Integration | 1 day | None | `FINANCE-SRV-01` marked as honeypot, instant LOCKDOWN verified |
| 4 | Save/Load Extension | 2 days | Task 1 | Hacker data persists across game restarts |
| 5 | Role Switch Flow | 1 day | None | Title → New Game → Hacker → Day 1 starts automatically |

## Deferred (Not Phase 5)
| Item | Reason | When |
|------|--------|------|
| Days 4-7 shifts | MVHR only needs 3 days | Phase 6+ |
| Exfiltrator/Wiper apps | Not thesis-critical | Phase 6+ (if time) |
| `IntelligenceInventory.gd` | Exfiltration only | Phase 6+ |
| `LogSystem.prune_logs_for_host()` | Wiper only | Phase 6+ |
| `HackerHistory` tick collapsing | Exfiltration only | Phase 6+ |
| Contract expiration/timer | Cut for solo dev | Never (out of scope) |
| VariableRegistry token resolution | Too complex for now | Phase 6+ |
| `hacker_campaign_complete` signal | Only needed for Day 7 | Phase 6+ |

## Phase 5 Playability Test

**Demo Script (15 minutes):**
1. Title Screen → New Game → Select Hacker role
2. **Day 1:**
   - Broker dialogue plays: "Prove yourself. First contract awaits."
   - Contract Board shows 1 contract
   - Accept contract
   - Exploit + Ransom host
   - Contract complete → Bounty +$100
3. **Day 2:**
   - Broker dialogue plays: "Good work. But don't get complacent."
   - Exploit honeypot → instant LOCKDOWN (fail state)
   - Learn from mistake
   - Exploit legitimate host + Ransom
   - Contract complete
4. **Day 3:**
   - Broker dialogue plays: "There's more to this job. Meet me after Day 3."
   - Complete contract
   - Campaign pause (Days 4-7 deferred)

**Challenge:** "Survive 3 days without getting isolated"

## Integration Checklist

- [ ] All 5 tasks complete
- [ ] `HackerShiftResource` class exists
- [ ] `day_1.tres`, `day_2.tres`, `day_3.tres` exist
- [ ] NarrativeDirector loads hacker shifts
- [ ] Broker dialogue plays on each day start
- [ ] Honeypot triggers instant LOCKDAY (trace → 100)
- [ ] Save/load persists hacker data (bounty, contracts, footholds)
- [ ] **Demo recorded** (15-minute campaign video)

## Phase 5 → Phase 6 Handoff

**Phase 5 Must Provide:**
- `HackerShiftResource` with Day 1-3
- `ContractManager` shift integration
- `HackerHistory.history` populated
- Save/load working for hacker data

**Phase 6 Will Add:**
- Mirror Mode (history vs. logs correlation)
- Glitch aesthetics
- Days 4-7 (if time)
- Final testing

---

**Solo Dev Note:** 3 days is ENOUGH for thesis defense. You're showing: progression, narrative, consequences. Days 4-7 are content, not architecture. If you finish Phase 5 with a working 3-day loop, the thesis is defensible.
