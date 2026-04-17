# TASK 4: THE "PHISH-CRAFTER" (EMAIL INVERSION)

## Description
Invert `EmailSystem.gd` logic to allow the player to initiate the "Infiltration" stage, with clear success and failure paths.

## Implementation Details
*   **Scene:** [ ] Create `App_PhishCrafter.tscn`.
*   **Mechanic:** Implement a probability-based success check: `(Urgency + Authority) / HeatManager.heat_multiplier`.
*   **Success Path:** A successful phish emits `EventBus.hacker_foothold_established(hostname)`.
    *   **Rationale:** This signal **must** be distinct from any Analyst-side signals to ensure `ConsequenceEngine` does not consume it and advance the Analyst's Kill Chain.
*   **Failure Path:** A failed phish **must** still emit `EventBus.offensive_action_performed` with `result: "FAILED"` and an appropriate `trace_cost`. This ensures failed attempts have a forensic footprint and risk.
*   **Relationship to `EmailSystem`:** This app is conceptually an inversion of the `EmailAnalyzer`, but it **does not inherit** from `EmailSystem.gd`. It is a standalone app that can reference `EmailSystem`'s validation logic as a data source for its success formula, but it must not be a subclass.

## Success Criteria
- [ ] **[BLOCKER]** A failed phish attempt correctly emits `offensive_action_performed` with `result: "FAILED"`.
- [ ] `App_PhishCrafter.tscn` is created and functional.
- [ ] A successful phish emits the `hacker_foothold_established` signal.
- [ ] The implementation does not subclass or inherit from `EmailSystem.gd`.
