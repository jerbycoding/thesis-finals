# VERIFY.EXE: Post-Week 1 Gameplay Evolution

## THE PROBLEM: "The Groundhog Day Effect"
Currently, when the player completes Sunday (Day 7) and loops back to Monday, the shift content is identical to the first week. 
- **Scripted Sequence:** The same tickets (Phishing -> Auth Failure) appear at the same timestamps.
- **Narrative:** The CISO gives the exact same "Welcome to your first day" briefing.
- **Result:** The player feels like their progress has been reset rather than entering a "New Game Plus" or a continuing career.

---

## THE RECOMMENDATION: Procedural Shift Content
To make the game feel like a living simulation, we must move from **Scripted Narrative** to **Procedural Sandbox** after Week 1.

### 1. The Dynamic "Playlist" (NarrativeDirector.gd)
- **Logic:** If `HeatManager.current_week > 1`, the director intercepts the `event_sequence`.
- **Swap Logic:** Instead of spawning the specific `ticket_id` in the `.tres` file, it pulls a random ticket from the library that matches the **Severity Level**.
- **Variety:** Monday Week 2 could have a DDoS attack instead of simple Phishing.

### 2. Context-Aware Briefings
- Update `NPC_CISO.gd` to check the week count.
- **Week 1:** "Welcome to your first day. Follow protocol."
- **Week 2+:** "The attackers are evolving. Our scanners are picking up erratic signatures. Stay sharp."

### 3. Tool Instability (Heat Scaling)
- Use the `HeatMultiplier` to trigger "System Fatigue":
    - **Week 3:** SIEM logs occasionally flicker or lag.
    - **Week 4:** Terminal commands take 0.5s longer to execute due to "CPU Load."
    - **Effect:** The physical and digital world feels like it is wearing down under the pressure of the infinite breach.

---

## IMPLEMENTATION STEPS (Next Turn)
1. **Refactor NarrativeDirector:** Add a `_get_procedural_ticket(severity)` helper.
2. **Inject Randomization:** Wrap the `spawn_ticket` event in a week-check.
3. **Update Dialogue resources:** Create a `ciso_briefing_procedural.tres`.

**Status:** Awaiting player confirmation to transition into Procedural Mode.
