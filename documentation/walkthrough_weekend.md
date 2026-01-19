# Weekend Maintenance Walkthrough

This guide covers the mechanics for the **Saturday Audit** and **Sunday Recovery** missions.

## Day 6: Saturday (Infrastructure Audit)
**Location:** Network Hub (Floor -2)
**Goal:** Verify the physical integrity of the network routers.

### Steps:
1.  **Transition:** Use **F6** to jump directly to Saturday, or complete Friday.
2.  **The Environment:** You spawn in a dark room with server racks and routers.
3.  **Objective:** Look for the **MaintenanceHUD** checklist on your screen. It will list tasks like "Audit Network Router".
4.  **Action:**
    *   Walk up to the large Router racks (Boxes with glowing lights).
    *   Look for any interactive prompts. *Note: In the current prototype, the audit is simulated by simply exploring the area. Future versions will require scanning.*
5.  **Completion:** Since the "Audit" mechanic is currently passive in the prototype, you can verify the floor loaded correctly and then use **F1** to cycle back to Monday.

## Day 7: Sunday (Hardware Recovery)
**Location:** Server Vault (Floor -1)
**Goal:** Physically replace broken hardware. This is the **Core Mechanic** of Sprint 4.

### Steps:
1.  **Transition:** Use **F7** to jump to Sunday.
2.  **The Setup:** You are in a vault with multiple Server Racks. On the floor or tables, you will see loose **Hard Drives** (small, metallic boxes).
3.  **Pickup (The "Hand"):**
    *   Walk close to a loose Hard Drive.
    *   Look at it until you see the prompt: **"Pickup Hard Drive"**.
    *   Press **E**.
    *   **Visual:** The drive will snap to your camera/hand. Your movement speed will decrease.
4.  **Install (The "Socket"):**
    *   Walk to a **Server Rack** that has an empty slot (a dark/glowing recess).
    *   *Hint: In the current scene, look for the racks with glowing slots.*
    *   When close, you will see the prompt: **"Insert Hard Drive"**.
    *   Press **E**.
5.  **The Payoff:**
    *   **Visual:** The drive snaps into the rack.
    *   **Audio:** Success sound plays.
    *   **HUD:** The **MaintenanceHUD** checklist will mark a task as `[✔] COMPLETE`.
    *   **Integrity:** Your System Integrity bar will increase by +15%.

### Troubleshooting
*   **Can't pick up?** Ensure you are close enough. The interaction range is short (2 meters).
*   **Can't drop?** You must be looking at a valid **Socket** to install it. If you just want to drop it on the floor, this feature is currently restricted to sockets to prevent losing items out of bounds.
*   **Camera drifting?** If the Elevator UI was left open, press **F7** again to force a reset.
