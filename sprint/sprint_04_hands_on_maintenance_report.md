# Sprint 4 Completion Report: Hands-On Maintenance

**Status:** COMPLETE
**Objective:** Implement the 3D interaction mechanics for weekend shifts (Picking up items, Server repair).

## 1. Carrying System
*   **Mechanic:** Implemented `reparent()` based carrying.
*   **Player Update:** Added `CarryMarker3D` to the camera.
*   **Constraints:** Player movement speed is reduced by 25% while holding hardware.
*   **Collision:** Object collision is disabled while held to prevent physics glitches.

## 2. Interactive Objects
*   **CarryableHardware.gd:** Base class for pickupable items (e.g., HDDs).
*   **HardwareSocket.gd:** Base class for target locations (e.g., Server Rack Slots).
*   **Assets Created:** `Prop_HardDrive.tscn` and `Prop_ServerSlot.tscn`.

## 3. Weekend Mission Logic
*   **MaintenanceHUD:** A new dynamic checklist that appears only on Floors -1 and -2 during weekends.
*   **Progression:** Connecting hardware to sockets triggers `hardware_repaired` signals.
*   **The Payoff:** Completing all checklist items restores **+15.0% Integrity** to the organization.

## 4. Scene Integration
*   **ServerVault.tscn:** Updated with scattered Hard Drives and target slots for immediate testing.

---

**Next Steps:** Proceed to **Sprint 5: Escalation & Heat** to implement the systems that make the game harder over time and remember player mistakes.