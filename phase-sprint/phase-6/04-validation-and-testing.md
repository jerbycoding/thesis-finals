# TASK 4: "TOTAL WAR" VALIDATION (TESTING & REGRESSION)

## Description
Perform exhaustive regression, stress, and device-level testing to ensure thesis-ready stability.

## Implementation Details

### A. [BLOCKER] 10 New GdUnit4 Tests
*   [ ] `test_analyst_integrity_unaffected`: Verify Analyst HP is not hit by Hacker actions.
*   [ ] `test_kill_chain_unaffected_by_hacker_actions`: Verify `ConsequenceEngine` does not advance.
*   [ ] `test_network_context_isolation`: Verify `NetworkState` contexts are isolated.
*   [ ] `test_save_path_separation`: Verify `user://saves/` separation.
*   [ ] `test_mirror_mode_timestamp_alignment`: Programmatic check for `ShiftClock` usage.
*   [ ] `test_trace_inactive_during_analyst_shift`.
*   [ ] `test_rival_ai_inactive_during_analyst_shift`.
*   (Additional 3 tests for Contract Lifecycle, Exfiltration, and Wiper).

### B. [BLOCKER] Mode Switch Stress Test
*   **Action:** [ ] Perform 5 switches.
*   **Verification:** [ ] Check variables: `current_role`, `role_transition_in_progress`, `current_foothold`, `hacker_footholds`, `NetworkState.current_context`, `UIObjectPool` entry count, `TraceLevelManager.trace_level`, `HeatManager.heat_multiplier`, active theme color, and active ambient loop.

### C. [BLOCKER] Android Device Test
*   **Test Case 1:** [ ] High Trace (> 70) with shader active. Target: ≥30fps.
*   **Test Case 2:** [ ] High Trace (> 70) with fallback active. Target: ≥30fps.

### D. [BLOCKER] Full Playthroughs & Scenarios
*   **Analyst Campaign:** [ ] Full Week 1 playthrough to confirm zero regressions.
*   **Hacker Campaign:** [ ] Full Day 1→7 playthrough to confirm narrative arc.
*   **Scenario Tests:** [ ] Day 4 scripted LOCKDOWN, Wiper gap, Emergency Patch on foothold, etc.

## Success Criteria
- [ ] **[BLOCKER]** All 10 new GdUnit4 tests pass.
- [ ] **[BLOCKER]** Stress test shows zero state corruption across 10 key variables.
- [ ] **[BLOCKER]** Android device tests sustain ≥30fps.
- [ ] **[BLOCKER]** Full Hacker Day 1-7 playthrough is successful.
- [ ] Analyst Week 1 playthrough confirms zero regressions.
- [ ] 8 scenario-based integration tests are completed.
