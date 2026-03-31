# PHASE 2: THE OFFENSIVE MIRROR LOOP (WEAPONIZATION)

## 1. Objective
Transform existing defensive toolsets into offensive weapons through inheritance and data inversion. This phase establishes the "Mirror Loop" where offensive actions generate forensic footprints.

## 2. Key Task: Offensive Terminal Extension
Extend `TerminalSystem.gd` to handle offensive commands.

*   **Commands:** `exploit [hostname]`, `pivot [hostname]`, `spoof [ip] [identity]`.
*   **Visibility:** Modify `_cmd_help` to check `current_role`. Analyst role must filter out these commands to avoid exposing dev/debug tools.
*   **Logic:** `exploit` must check `NetworkState` for host vulnerabilities. `pivot` must update a new `GameState.current_foothold` variable.

## 3. Key Task: The "Log Poisoner" (SIEM Inversion)
Enable log injection to manipulate the defender's SIEM.

*   **Class:** Create `PoisonLogResource` (inherits from `LogResource`).
*   **Inversion:** The `App_LogPoisoner` app allows the player to fill a `PoisonLogResource` and call `LogSystem.add_log()`.
*   **Impact:** Injected logs appear in the live SIEM feed, serving as "False Flags" to distract the AI Analyst (Phase 3).

## 4. Key Task: Forensic Action Logging (Thesis Anchor)
Create a persistent record of every offensive action performed by the player.

*   **Singleton:** `HackerHistory.gd`.
*   **Logic:** Listens to `EventBus.offensive_action_performed(data)`.
*   **Data:** Stores `action_type`, `target`, `timestamp`, and `result` (Success/Failure).
*   **Purpose:** This hidden data is the "Truth Source" for the Phase 6 "Mirror Mode" split-screen comparison.

## 5. Key Task: The "Phish-Crafter" (Email Inversion)
Invert `EmailSystem.gd` logic to allow the player to initiate the "Infiltration" stage.

*   **Mechanic:** Probability-based success check: `(Urgency + Authority) / Heat Multiplier`.
*   **Outcome:** Successful phish emits `EventBus.foothold_established`, granting initial host access.

## 6. Technical Strategy: The "Wrapper Pattern"
Offensive apps (Terminal, Email, SIEM) will **inherit** from their Analyst counterparts. This ensures they maintain consistent visual logic (scrolling, windows, buttons) while overriding core action functions.

## 7. Phase 2 Success Criteria (Verification Checklist)
1.  [ ] **Command Unlock:** Offensive terminal commands are only available in `Hacker` role.
2.  [ ] **Pivot Tracking:** `GameState.current_foothold` correctly updates the terminal's "Local IP."
3.  [ ] **Log Injection:** An injected "Poison" log correctly appears in the Analyst's SIEM app.
4.  [ ] **Forensic Storage:** Every `exploit` and `phish` attempt is recorded in `HackerHistory`.
