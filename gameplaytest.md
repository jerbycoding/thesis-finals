# Gameplay Testing Guide: Threat Engineering & Kill Chain

This guide outlines how to manually verify the features implemented during the 3-week "Threat Engineering" sprint.

---

## **Week 1: Core Kill Chain & Consequence Engine**
**Goal:** Verify that tickets are interconnected and escalate based on risk.

### **Test 1.1: The Escalation Probability (Path A)**
1.  Open the Godot Editor and run the game.
2.  Open the **Terminal** and call the debug script: `KillChainTester.test_malware_path_probability()`.
3.  **Action:** In the Ticket Queue, resolve `PHISH-001` as **EFFICIENT**.
4.  **Wait:** 15-20 seconds.
5.  **Expected Result:** There is a 50% chance a `MALWARE-CONTAIN-001` ticket spawns.
6.  **Visual Check:** When the new ticket spawns, open the **SIEM Log Viewer**. Look for logs with a **Magenta Glow** and the `[REVEALED]` prefix.

### **Test 1.2: Guaranteed Escalation (Timeout)**
1.  Call: `KillChainTester.test_timeout_guaranteed_escalation()`.
2.  **Action:** Do nothing. Let the `SOCIAL-001` ticket time out.
3.  **Expected Result:** A `INSIDER-001` ticket should spawn automatically after 15 seconds.

---

## **Week 2: Hybrid System & Dynamic Events**
**Goal:** Verify the "Ambient Noise" and real-time environmental stressors.

### **Test 2.1: Ambient Noise (Generic Tickets)**
1.  Start a shift via the **Title Screen**.
2.  **Action:** Wait for ~45 seconds.
3.  **Expected Result:** A low-severity ticket like `AUTH-FAIL-GENERIC` or `SYS-MAINT-GENERIC` should appear in the queue without being triggered by a narrative event.

### **Test 2.2: The Zero-Day (Scan Delay)**
1.  In the Godot Console (or via a debug trigger), emit: `NarrativeDirector.world_event.emit("ZERO_DAY", true, 30.0)`.
2.  **Action:** Open the **Terminal** and run `scan WORKSTATION-45`.
3.  **Expected Result:** The scan should take **4.5 seconds** instead of the base 3.0 seconds.
4.  **Visual Check:** Open the **Task Manager**. The CPU graph should show a significant spike and the status should change to `HIGH RESOURCE DEMAND`.

### **Test 2.3: SIEM Instability (Visual Lag)**
1.  Emit: `NarrativeDirector.world_event.emit("SIEM_LAG", true, 20.0)`.
2.  **Action:** Open the **SIEM Log Viewer**.
3.  **Expected Result:** The SIEM window should flicker (opacity changes).
4.  **Visual Check:** Open **Task Manager**. The Network graph should show high latency/spikes.

### **Test 2.4: CISO Walk-by (Context Switch)**
1.  Open the **Interactable Computer** (Enter 2D mode).
2.  Emit: `NarrativeDirector.npc_interaction_requested.emit("ciso", "default")`.
3.  **Expected Result:** The game should automatically fade to black, exit the 2D desktop, and return the camera to the 3D office before the dialogue box appears.

---

## **Week 3: Advanced Mechanics & Redemption**
**Goal:** Verify the Risk/Reward buffer and the "Black Ticket" forensic recovery.

### **Test 3.1: Response Buffer (Noise Cancellation)**
1.  Wait for a generic/ambient ticket to spawn.
2.  **Action:** Resolve it as **EMERGENCY**.
3.  **Expected Result:** No new ambient tickets should spawn for the next 120 seconds. (You can check this by watching the console for "Ambient noise spawning PAUSED").

### **Test 3.2: The Black Ticket Redemption**
1.  Trigger a Stage 3 ticket (e.g., `RANSOM-001`) and let it **Time Out** or resolve it as **EMERGENCY**.
2.  **Expected Result:** A notification "CRITICAL RECOVERY INITIATED" should appear, and the **BLACK-TICKET-REDEMPTION** should be added to the queue.
3.  **Requirement:** This ticket should have **no timer** (Timer label should show a very high number or be static).
4.  **Action:** Attach all 5 required logs (Phish, Malware, Exfil, Auth, Network) and resolve as **COMPLIANT**.
5.  **Payoff:** Check the console/metrics. Your `risks_taken` count should decrease by 2.

---

## **Debug Triggers Cheat Sheet**
| Action | Command / Signal |
| :--- | :--- |
| **Spawn Phish** | `TicketManager.spawn_ticket_by_id("phish-001")` |
| **Start Noise** | `TicketManager.start_ambient_spawning()` |
| **Trigger Zero-Day** | `NarrativeDirector.world_event.emit("ZERO_DAY", true, 60)` |
| **Trigger Log Flood** | `NarrativeDirector.world_event.emit("FALSE_FLAG", true, 30)` |
| **Force Black Ticket** | `ConsequenceEngine._spawn_black_ticket()` |
