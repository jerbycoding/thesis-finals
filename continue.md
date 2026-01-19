# Session Continuation Guide

**Date:** Monday, January 19, 2026
**Status:** Core Systems Complete. Procedural Loop Functional. Weekend Missions Active.

---

## 1. Critical Tasks (Immediate Next Steps)
These items were identified during final testing and should be addressed first.

*   [ ] **Expand Host Pool:** Currently, only 4 hosts exist (`DB`, `FINANCE`, `WEB`, `WS-45`).
    *   **Action:** Update `NetworkState.gd` to procedurally generate 15-20 generic workstations (e.g., `WORKSTATION-01` to `WORKSTATION-20`) at startup. This prevents the "Random Victim" logic from picking the same 4 servers repeatedly.
*   [ ] **Verify False Positive Logic:** We re-enabled auto-infection. Ensure we want this permanently, or if we should add a `is_false_alarm` flag to tickets later.

## 2. Gameplay Polish Checklist
*   [ ] **Elevator Camera:** Verify the camera lock fix (switching to `MODE_2D`) feels smooth in-game.
*   [ ] **Dialogue UI:** Confirm the new Button-based choice system works with mouse clicks.
*   [ ] **Weekend Navigation:** Test the "Title Card" transitions for Saturday/Sunday to ensure they give enough context.

## 3. Content Expansion (Future Sprints)
*   [ ] **More Ticket Templates:** We have ~10 tickets. Aim for 20-25 for variety.
*   [ ] **Email Variety:** Add more "Noise" emails (Potluck, Lost Items) to bury the threats.
*   [ ] **Narrative Depth:** Expand the CISO dialogues for Day 3, 4, and 5 to reflect the escalating heat.

## 4. Known Debug Shortcuts
*   **F1 - F5:** Jump to Weekdays.
*   **F6 - F7:** Jump to Weekend Maintenance (Floors -2, -1).
*   **F9:** Force Spawn Procedural Ticket.
*   **F10:** Reveal Evidence.

---

**Suggestion for Next Session:**
Start by implementing the **Procedural Host Population** in `NetworkState.gd`. It's a quick win that immediately makes the F9 procedural generation feel much larger and more realistic.
