# VERIFY.EXE: Full Game Implementation Roadmap

Based on the technical authority of `FULLGAME.md`, development is divided into 5 focused sprints.

## Sprint 1: The Integrity Engine (Meta-Progression)
**Goal:** Implement the "Health Bar" of the organization, making player actions have visible, persistent weight.
*   **System:** Create `IntegrityManager` autoload.
    *   Track `current_integrity` (0-100%).
    *   Implement `calculate_delta()` for ticket resolutions (Compliant +5, Breach -40).
*   **Mechanic:** Active Session Decay.
    *   Implement `decay_timer` (-1.0% per hour).
    *   Add "Maintenance Immunity" state (toggled by weekend success).
*   **UI:** Add `IntegrityMeter` to:
    *   2D Desktop (Always visible).
    *   3D HUD (Wristwatch or corner overlay).
*   **Game Loop:** Connect `TicketManager` resolution signals to `IntegrityManager`.

## Sprint 2: Procedural Truth (Infinite Replayability)
**Goal:** Replace static strings with a dynamic "Truth Packet" system to support infinite ticket generation.
*   **System:** Create `VariableRegistry` autoload.
    *   Dictionaries for `EMPLOYEES` (Names, Depts), `HOSTS` (Linked to NetworkState), `ATTACKERS` (IPs).
*   **Logic:** Implement `ContextGenerator`.
    *   Function `generate_incident_context()` that returns a unique "Truth Packet" (Victim, Attacker, Time, Vulnerability).
*   **Refactor:** Update UI tools to support Format-on-Access.
    *   `TicketCard` -> Inject `{victim}`.
    *   `LogViewer` -> Inject `{timestamp}` and `{attacker_ip}`.
    *   `EmailApp` -> Inject `{sender_name}`.

## Sprint 3: The Physical World (Vertical Expansion)
**Goal:** Break out of the single office room and implement the 7-day physical cycle.
*   **Scene:** Create 3D Environments.
    *   `ServerVault.tscn` (Floor -1).
    *   `NetworkHub.tscn` (Floor -2).
    *   `ExecutiveSuite.tscn` (Floor 2 - Narrative only).
*   **System:** Elevator Modal & Logic.
    *   Update `RoomTeleporter` to support floor selection.
    *   Implement "Floor Constraints" (e.g., Locked floors based on day of week).
*   **Mechanic:** Weekend Logic.
    *   Update `NarrativeDirector` to handle Saturday/Sunday logic (No tickets, just maintenance).

## Sprint 4: Hands-On Maintenance (Weekend Mechanics)
**Goal:** Implement the 3D interaction mechanics required for weekend shifts.
*   **Mechanic:** Parent-Link Carrying System.
    *   `Pickupable` class for 3D objects.
    *   Player `Marker3D` for holding items.
*   **UI:** Auditor's Checklist.
    *   Dynamic HUD list that checks off when `EventBus` signals "HardwareRepaired".
*   **Loop:** Connection to Integrity.
    *   Successful repairs = `IntegrityManager.restore(15)`.

## Sprint 5: Escalation & Heat (Difficulty Scaling)
**Goal:** Implement the systems that make the game harder over time and remember player mistakes.
*   **System:** Heat Manager.
    *   Global `heat_multiplier` (1.15x per week).
    *   Scale ticket timers and noise generation.
*   **System:** The Inheritance Buffer.
    *   Store "Efficient" closures in a `Vulnerability_Buffer`.
    *   Logic to spawn new tickets reusing old `attacker_ip` from the buffer.
*   **Tools:** Developer Debugging.
    *   Implement `DebugManager` (F1-F10 keys) for testing the infinite loop.

---

**Immediate Recommendation:** Start with **Sprint 1 (Integrity Engine)**. It is the core failure state and is required for the "Weekend Payoff" loop to make sense.