# TASK 5: TESTING CHECKLIST (THESIS VERIFICATION)

## Description
[SOLO DEV SCOPE] Run through complete 3-day campaign. Document any blockers.

## Implementation Details

### A. Playthrough Checklist
```
Day 1:
[ ] Broker dialogue plays
[ ] Contract appears
[ ] Can exploit host
[ ] Can ransom host
[ ] Contract completes
[ ] Bounty awarded

Day 2:
[ ] Broker dialogue plays
[ ] Honeypot exists
[ ] Exploiting honeypot → LOCKDOWN
[ ] Can recover and complete contract

Day 3:
[ ] Broker dialogue plays
[ ] Contract completes
[ ] Mirror Mode opens

Mirror Mode:
[ ] Left panel shows actions
[ ] Right panel shows logs
[ ] Summary displays bounty
[ ] Can close and return to game
```

### B. Save/Load Test
```
[ ] Save after Day 1
[ ] Reload save
[ ] Day 1 progress retained
[ ] Bounty retained
[ ] History retained
```

### C. Role Switch Test
```
[ ] Start Hacker campaign
[ ] Complete Day 1
[ ] Save and quit
[ ] Start Analyst campaign
[ ] Analyst data separate
[ ] Return to Hacker campaign
[ ] Hacker data intact
```

## Success Criteria
- [ ] **[BLOCKER]** Full 3-day playthrough completes without crash
- [ ] **[BLOCKER]** Mirror Mode generates without errors
- [ ] Save/load works for Hacker campaign
- [ ] Analyst campaign unaffected (no regression)

## OUT OF SCOPE
- ❌ GdUnit4 automated tests (manual testing ok for solo dev)
- ❌ Android device testing (desktop only for thesis)
