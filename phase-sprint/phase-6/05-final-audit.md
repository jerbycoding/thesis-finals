# TASK 5: FINAL PROJECT AUDIT

## Description
[NEW] Perform the final end-of-project checks to ensure all Hacker-role components are correctly integrated and isolated.

## Implementation Details

### A. [BLOCKER] App Roster Verification
*   **Action:** Confirm all 8 Hacker apps (Terminal, Network Mapper, Phish-Crafter, Log Poisoner, Ransomware, Exfiltrator, Wiper, Contract Board) are present in `HackerAppProfile.tres`.
*   **Action:** Confirm zero Hacker apps are visible in the Analyst launcher or permission profiles.

### B. [BLOCKER] Save Integrity Check
*   **Action:** Perform a full 7-day Hacker campaign.
*   **Verification:** Confirm that the `user://saves/analyst/` directory remains completely untouched and its world state is identical to its pre-hacker-campaign state.

### C. [BLOCKER] File Inventory
*   **Verification:** Confirm all necessary files exist at their final paths:
    *   Hacker saves: `user://saves/hacker/*.json`
    *   Hacker shifts: `res://resources/hacker_shifts/day_*.tres`
    *   Mirror Mode report: `HackerHistory` is writing successfully.

## Success Criteria
- [ ] **[BLOCKER]** App roster is verified and correctly isolated.
- [ ] **[BLOCKER]** Analyst save integrity is confirmed after a full Hacker run.
- [ ] **[BLOCKER]** File inventory is complete and correctly located.
