# PHASE 2: FIRST TOOL (SOLO DEV SCOPE)

## Objective
Add ONE offensive tool (`exploit`) with consequences (Trace system). **ONE working mechanic:** Exploit host → Trace rises → decays when idle.

## Duration
**1.5 weeks** (Solo Dev)

## Tasks (Consolidated from 6 → 5)

| # | Task | Duration | BLOCKERs |
|---|------|----------|----------|
| 1 | Exploit Command | 3 days | Signal emission, foothold tracking |
| 2 | TraceLevelManager | 2 days | Accumulation, passive decay |
| 3 | HackerHistory | 1 day | Disk persistence |
| 4 | HostResource Extension | 0.5 day | vulnerability_score, is_honeypot |
| 5 | Role Guards | 0.5 day | 4 guard comments |

## Phase 2 Playability Test

**Demo Script (1 minute):**
1. F1 to load Hacker campaign
2. Open Terminal
3. Type `exploit WEB-SRV-01`
4. Watch Trace rise from 0 → 15
5. Wait 10 seconds, watch Trace decay to 5

**What Works:**
✅ Offensive command
✅ Consequence system (Trace)
✅ Forensic logging

**What Doesn't Work Yet:**
❌ AI doesn't respond to Trace
❌ No win/loss condition
❌ No other tools (phish, ransomware)

## Integration Checklist

- [ ] All 5 tasks complete
- [ ] Exploit signal emits with 5-key payload
- [ ] Trace decays at 1.0/second
- [ ] History writes to disk
- [ ] **Demo recorded** (1-minute video)

## Phase 2 → Phase 3 Handoff

**Phase 2 Must Provide:**
- `offensive_action_performed` signal working
- `TraceLevelManager.get_trace_level()` accessible
- `HackerHistory.history` array populating

**Phase 3 Will Add:**
- RivalAI reads Trace level
- AI state machine (IDLE → SEARCHING → LOCKDOWN)
- Isolation sequence (Connection Lost)

---

**Solo Dev Note:** Do NOT add pivot/spoof commands. Do NOT add Log Poisoner or PhishCrafter apps. ONE tool, done well.
