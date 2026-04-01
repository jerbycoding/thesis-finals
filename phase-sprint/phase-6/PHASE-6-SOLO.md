# PHASE 6: THESIS POLISH (SOLO DEV SCOPE)

## Objective
Add Mirror Mode and polish. **ONE working report:** Side-by-side actions vs. logs.

## Duration
**2 weeks** (Solo Dev)

## Tasks (Consolidated from 5 → 5)

| # | Task | Duration | BLOCKERs |
|---|------|----------|----------|
| 1 | Mirror Mode | 4 days | Side-by-side panels, data binding |
| 2 | Glitch Aesthetics | 2 days | HackerTheme, simple shader |
| 3 | LogSystem Extension | 1 day | `get_logs_for_shift()` stub |
| 4 | HackerHistory Extension | 1 day | `get_entries_for_day()` stub |
| 5 | Testing Checklist | 2 days | Full 3-day playthrough |

## Phase 6 Playability Test

**Demo Script (20 minutes):** **THESIS-COMPLETE**
1. Start Hacker campaign
2. Play Day 1 → Complete contract
3. Play Day 2 → Avoid honeypot → Complete
4. Play Day 3 → Complete
5. **Mirror Mode opens:**
   - Left: Your 3 days of actions
   - Right: SIEM logs generated
   - Summary: Bounty, hosts, detections
6. Close Mirror Mode
7. Campaign complete (Days 4-7 cut)

**What Works:**
✅ Full 3-day campaign
✅ Mirror Mode forensic report
✅ Visual theme (green vs. blue)
✅ Save/load

**Thesis Defense Ready:**
- Demonstrate offensive loop (Phase 1-4)
- Show 3-day narrative (Phase 5)
- Explain Mirror Mode concept (Phase 6)
- Discuss architecture (role guards, signal hygiene)

## Integration Checklist

- [ ] All 5 tasks complete
- [ ] Mirror Mode opens after Day 3
- [ ] Both panels populate correctly
- [ ] HackerTheme applies to desktop
- [ ] 3-day playthrough completes without crash
- [ ] **Thesis demo recorded** (20-minute full run)

## Post-Phase 6: Thesis Defense Prep

**Materials to Prepare:**
1. 5-minute MVHR demo (Phase 4)
2. 20-minute full demo (Phase 6)
3. Architecture diagrams (role guards, EventBus)
4. Mirror Mode explanation (attack/detection correlation)

**Optional Scope Additions (If Time Permits):**
- Days 4-7 content
- Correlation lines in Mirror Mode
- Exfiltrator app
- Full Broker reveal

---

**Solo Dev Note:** Phase 6 is YOUR THESIS. The report shows the educational value: making invisible attack/detection relationships visible. Everything before this supports this moment.
