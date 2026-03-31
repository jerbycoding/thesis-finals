# TASK 3: THE "MIRROR MODE" (THESIS HIGHLIGHT)

## Description
[REVISED] Implement the "Post-Shift Forensic Report," ensuring perfect timestamp alignment and high-fidelity correlation.

## Implementation Details

### A. [BLOCKER] Timestamp Alignment Audit
*   **Action:** Before writing any UI code, audit all six timestamp sources: `HackerHistory`, `LogSystem`, signal payloads, `BountyLedger`, `IntelligenceInventory`, and `NarrativeDirector`.
*   **Verification:** Confirm all sources use `ShiftClock.elapsed_seconds` (NOT system time).

### B. Trigger Points & Guards
*   **Dual Trigger:** Mirror Mode triggers (1) at the start of each new shift (previous shift data) and (2) upon `hacker_campaign_complete` (full summary).
*   **[BLOCKER] Day 1 Guard:** Skip Mirror Mode on the first shift start.
*   **[BLOCKER] Session Guard:** Skip Mirror Mode if `is_campaign_session == false`.

### C. Correlation Engine Features
*   **Wiper Gap Detection:** Detect gaps > `LOG_GAP_THRESHOLD_SECONDS` between SIEM logs and annotate them with `[LOG ENTRIES DESTROYED]`.
*   **[INJECTED] Badge:** Poison logs (`is_poison: true`) must display a colored accent bar in the report view.
*   **Correlation Tiers:** Implement 4 tiers: HIGH (solid line), MEDIUM (dashed), LOW (dotted), UNMATCHED (no line, ? indicator).

### D. Summary Panel & Export
*   **Fields:** Display total bounty, intelligence items stolen, detection rate (%), ghost actions count, and loudest action (highest trace_cost).
*   **Export:** Create a final panel that mimics a "Downloadable Report" for the thesis demo.
*   **[BLOCKER] [CONTINUE] State:** Closing Mirror Mode returns the player to `HackerRoom` in `MODE_3D`.

## Success Criteria
- [ ] **[BLOCKER]** Timestamp audit is signed off; all systems use `ShiftClock`.
- [ ] **[BLOCKER]** Mirror Mode is skipped on Day 1 and in non-campaign sessions.
- [ ] **[BLOCKER]** Injected logs have the visual badge; Wiper gaps are correctly annotated.
- [ ] **[BLOCKER]** Closing the mode returns the player to the 3D room.
- [ ] Correlation engine uses the 4 visual tiers correctly.
- [ ] Summary panel displays all 5 specified fields correctly.
