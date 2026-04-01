# PHASE 4: WIN CONDITION (SOLO DEV SCOPE)

## Objective
Add ONE way to win: Ransomware contract. **ONE working loop:** Accept contract → Exploit → Ransomware → Win.

## Duration
**2 weeks** (Solo Dev)

## Tasks (Consolidated from 5 → 5)

| # | Task | Duration | BLOCKERs |
|---|------|----------|----------|
| 1 | Ransomware App | 4 days | CalibrationMinigame reuse, eligibility guard |
| 2 | BountyLedger | 1 day | Persistence, add/get functions |
| 3 | Basic Contract | 3 days | ContractResource, ContractManager |
| 4 | App Registration | 1 day | HackerAppProfile, AppConfigResource |
| 5 | NetworkState Extension | 1 day | RANSOMED status |

## Phase 4 Playability Test

**Demo Script (5 minutes):** **MVHR MILESTONE**
1. F1 to load Hacker campaign
2. Open Contract Board
3. Accept "Ransom any host" contract
4. Open Terminal
5. `exploit WEB-SRV-01` (Trace: 0 → 15)
6. Open Ransomware app
7. Complete CalibrationMinigame
8. Host status → RANSOMED
9. Contract shows "COMPLETE"
10. Bounty +100
11. **Win screen/notification**

**Alternative Run (Failure):**
- Steps 1-6 same
- Fail CalibrationMinigame
- Contract NOT complete
- Trace +20 (half cost)
- Try again or pivot

**Challenge:** "Complete contract before Trace hits 100"

**What Works:**
✅ Win condition
✅ Contract system
✅ Bounty tracking
✅ Full core loop

**What Doesn't Work Yet:**
❌ No 7-day campaign
❌ No Broker dialogue
❌ No Mirror Mode

## Integration Checklist

- [ ] All 5 tasks complete
- [ ] Ransomware app opens and works
- [ ] Contract completes on ransom
- [ ] Bounty increases
- [ ] **Demo recorded** (5-minute MVHR video)

## Phase 4 → Phase 5 Handoff

**Phase 4 Must Provide:**
- `ContractManager.active_contract` working
- `BountyLedger.add_bounty()` functional
- `NetworkState.HOST_STATUS.RANSOMED` exists

**Phase 5 Will Add:**
- 3-day campaign (Days 1-3)
- Broker dialogue
- Scripted events (honeypots)

---

**Solo Dev Note:** THIS IS YOUR MVHR. If you run out of time after Phase 4, you have a defensible thesis: "Offensive loop with AI response and win condition." Phases 5-6 are polish and narrative.
