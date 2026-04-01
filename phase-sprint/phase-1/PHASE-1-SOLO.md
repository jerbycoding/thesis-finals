# PHASE 1: FOUNDATION (SOLO DEV SCOPE)

## Objective
Enable role switching to Hacker and provide a themed environment. **ONE working flow:** Title Screen → Hacker Campaign → Green Login → Sit at Desk.

## Duration
**1 week** (Solo Dev)

## Tasks (Consolidated from 7 → 5)

| # | Task | Duration | BLOCKERs |
|---|------|----------|----------|
| 1 | Role Switching | 2 days | GameState.Role enum, 6-step switch_role() |
| 2 | Hacker Room | 2 days | Reuse InteractableComputer, ViewAnchor naming |
| 3 | Themed Login | 1 day | String arrays, color swap |
| 4 | Global Constants | 0.5 day | Color + trace cost declarations |
| 5 | Debug Tools | 0.5 day | F1 jump shortcut |

## Phase 1 Playability Test

**Demo Script (30 seconds):**
1. Start game
2. Click "Hacker Campaign"
3. See green login with hacker strings
4. Enter HackerRoom
5. Sit at computer, desktop loads

**What Works:**
✅ Role switching
✅ Themed environment
✅ Desktop interaction

**What Doesn't Work Yet:**
❌ No offensive tools
❌ No objectives
❌ No consequences

## Integration Checklist

- [ ] All 5 tasks complete
- [ ] F1 debug jump works
- [ ] No console errors during role switch
- [ ] Desktop loads on Hacker computer
- [ ] **Demo recorded** (30-second video for advisor)

## Phase 1 → Phase 2 Handoff

**Phase 1 Must Provide:**
- `GameState.current_role` working
- `HackerRoom.tscn` navigable
- `GlobalConstants.TRACE_COST_*` declared

**Phase 2 Will Add:**
- Terminal `exploit` command
- TraceLevelManager
- First consequence system

---

**Solo Dev Note:** Do NOT add save separation, audio swapping, or crash recovery yet. Those are polish items. Focus on ONE working flow.
