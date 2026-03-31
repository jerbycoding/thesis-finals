# TASK 4: HACKER SHIFT MANAGEMENT (PROGRESSION)

## Description
[REVISED] Modify the `NarrativeDirector` to handle the data-driven 7-day hacker campaign arc and its 7-step load sequence.

## Implementation Details

### A. `HackerShiftResource.gd` Schema
*   **Inheritance:** Inherits from `ShiftResource`.
*   **[BLOCKER]** Must include all 8 fields: `day_number`, `contracts` (Array), `scripted_events` (Array), `rival_ai_base_aggression`, `available_hosts` (Array), `honeypot_hosts` (Array), `broker_intro_dialogue_id`, and `shift_unlock_condition` (Dict).

### B. The 7-Step Load Sequence
When loading a Hacker shift, `NarrativeDirector` must execute:
1.  Load the `HackerShiftResource`.
2.  Push `available_hosts` to `NetworkState`.
3.  Mark `honeypot_hosts` with `is_honeypot = true`.
4.  Make contracts available in the contract pool.
5.  Trigger `broker_intro_dialogue_id` via `DialogueManager`.
6.  Register all `scripted_events` for the poll loop.
7.  **[BLOCKER]** Emit `EventBus.hacker_shift_started(day_number)`.

### C. Progression Gating
*   **Logic:** Implement `shift_unlock_condition` checks to prevent access to Day 3+ unless Day 1-2 conditions are met (bounty thresholds, intelligence count).

### D. Campaign Completion (Day 7)
*   **[BLOCKER]** When the Day 7 contract is submitted, `NarrativeDirector` must **await** `HackerHistory.history_write_complete` before emitting `EventBus.hacker_campaign_complete`.

## Success Criteria
- [ ] **[BLOCKER]** `HackerShiftResource` resource class is created with all 8 fields.
- [ ] **[BLOCKER]** `hacker_shift_started` is emitted at the end of the load sequence.
- [ ] **[BLOCKER]** Day 7 submission correctly awaits the final history write before completion.
- [ ] The 7-step shift load sequence is implemented in `NarrativeDirector`.
- [ ] `shift_unlock_condition` successfully gates campaign progression.
