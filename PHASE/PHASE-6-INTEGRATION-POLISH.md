# PHASE 6: INTEGRATION, BALANCING & POLISH (THE FINAL THESIS)

## 1. Objective
Finalize the user experience and ensure the hacker role is a high-quality addition to the project. This phase focuses on the "Role Selection" flow, visual/audio identity (Glitch Aesthetics), and the "Mirror Mode" report.

## 2. Key Task: Role Selection & Save Separation
Update the `TitleScreen.tscn` to allow the player to choose their path.

*   **Action:** Add "Analyst Campaign" and "Hacker Campaign" options.
*   **Logic:** Selection sets `GameState.current_role` and `is_campaign_session: true`.
*   **Save Separation:** Ensure that the `SaveSystem` uses separate JSON files for each career path to prevent state corruption.

## 3. Key Task: Visual & Audio "Glitch" Identity
Define the aesthetic difference between "Corporate Blue" and "Underground Green."

*   **Shaders:** Apply subtle "Chromatic Aberration" to the hacker desktop when Trace Level > 50.
*   **Audio:** Use `AudioManager` to swap standard office ambiance for a "Lofi/Underground" loop with electronic interference SFX.
*   **UI Reskin:** Utilize `GlobalConstants` to swap the "Corporate Blue" theme for a "Terminal Green" or "High-Contrast Amber" theme.

## 4. Key Task: The "Mirror Mode" (Thesis Highlight)
Implement the "Post-Shift Forensic Report."

*   **Split-Screen UI:** After a hacker shift, show a report that compares:
    *   **Left Side (Hacker History):** The actual actions performed (e.g., "Injected Phish").
    *   **Right Side (SIEM Logs):** How that action appeared in the logs (e.g., "IP 10.0.0.5 sent unexpected payload").
*   **Purpose:** Explicitly demonstrate the relationship between attack and detection for educational/thesis clarity.

## 5. Technical Strategy: "Total War" Validation
Perform exhaustive regression testing.

*   **GdUnit4 Testing:** Run existing tests for Analyst mode to ensure no logic was broken.
*   **Mode Switch Stress Test:** Switch between Analyst and Hacker saves 5 times in a row and verify that the `NetworkState` is correctly cleared and reloaded each time.

## 6. Phase 6 Success Criteria (Verification Checklist)
1.  [x] **Campaign Choice:** The player can start a new game in either role from the Title Screen.
2.  [x] **Unified Time:** All forensic timestamps (HackerHistory and SIEM logs) use `ShiftClock.elapsed_seconds` for perfect correlation.
3.  [ ] **Mirror Mode Report:** The split-screen report correctly displays `HackerHistory` data against `LogSystem` data.
4.  [ ] **Glitch UI:** The desktop visual effects respond dynamically to the Trace Level.
5.  [ ] **Stable Progression:** The game is fully playable from Day 1 to Day 7 in both roles without state corruption. (Partial: Days 1-3 stable).
