# PHASE 5: NARRATIVE ARC & SCRIPTED EVENTS (THE CONTRACTS)

## 1. Objective
Establish a structured 7-day hacker campaign using the existing `NarrativeDirector` framework. This phase replaces SOC "Tickets" with "Contracts" and introduces scripted security obstacles.

## 2. Key Task: The "Contracts" System (The Mission Loop)
Implement a hacker-specific version of the ticket system.

*   **Resource:** Create `ContractResource` (inherits from `TicketResource`).
*   **Variable Sync:** Contracts must pull their technical indicators (Target IP, MAC, Hostname) from the `VariableRegistry` truth packets.
*   **Verification:** If a contract target is "Alpha-Host," the terminal `scan` command on "Alpha-Host" must reveal the exact indicators required to fulfill the contract.

## 3. Key Task: Scripted Security Obstacles (The Hurdles)
Introduce technical events that progress the story.

*   **Honeypots:** Add decoy hosts to `NetworkState` that look like high-value targets but spike Trace Level to 100% if touched.
*   **Emergency Patches:** Trigger `EMERGENCY_PATCH` via `NarrativeDirector` to remove player footholds from specific hosts mid-mission.
*   **Underground Dialogue:** Utilize `DialogueManager` for encrypted "Broker" communications.

## 4. Key Task: Hacker Shift Management
Modify the `NarrativeDirector` to handle the hacker arc.

*   **Class:** Create `HackerShiftResource` (inherits from `ShiftResource`).
*   **Action:** When `GameState.current_role == Role.HACKER`, the director must load shifts from the `res://resources/hacker_shifts/` directory.

## 5. Technical Strategy: "The Scripted Opponent"
The `NarrativeDirector` will act as the "Director of Chaos." It will trigger `RivalAI` escalations (Phase 3) at specific narrative points, regardless of the player's actual Trace Level, to simulate "Scripted Detection" events.

## 6. Phase 5 Success Criteria (Verification Checklist)
1.  [ ] **Contract Acceptance:** The player can accept and fulfill a "Contract" objective.
2.  [ ] **Variable Consistency:** All technical data in the contract matches the SIEM/Terminal output.
3.  [ ] **Honeypot Trigger:** Exploiting a Honeypot host correctly triggers a `LOCKDOWN` state in the AI.
4.  [ ] **Bounty Tracking:** Contract rewards are correctly persisted in the `SaveSystem`.
