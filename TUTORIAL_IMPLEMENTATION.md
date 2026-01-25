# 🎓 VERIFY.EXE — Tutorial Implementation Strategy
## "Project Onboarding: Tier 1 SOC Certification"

**Goal:** Implement a high-polish, narrative-driven tutorial that teaches the core technical loop while maintaining the "Enterprise-Clean" aesthetic.

---

### 1. The Core Philosophy
*   **Narrative Onboarding:** It is not a "Tutorial," it is your **First Day Orientation**.
*   **Guided Focus:** Use visual masking to prevent UI overwhelm.
*   **Action-Oriented:** Minimize reading; maximize clicking and investigating.

---

### 2. Phase 1: The Physical Orientation (3D World)
*   **Spawn Point:** Elevator at `Level 04`.
*   **Trigger:** Player exits elevator.
*   **NPC Interaction:** The **CISO** is waiting in the lobby.
    *   *Dialogue:* "Welcome to the team. Head to YOUR ROOM (Office C) and initialize your workstation. I've assigned a training case to your queue."
*   **Instruction:** Floating 3D prompt: `MOVE TO YOUR ROOM [W/A/S/D]`.
*   **Interaction:** Player sits at the desk and presses `[E]`.

---

### 3. Phase 2: The Technical Loop (2D Desktop)
We will use a **Focus Mask** (dimmed screen) to highlight specific apps in order.

| Step | Action | Guided Highlight | Narrative Context |
| :--- | :--- | :--- | :--- |
| **1** | Open Ticket Queue | 'Tickets' Desktop Icon | "Check your active assignments." |
| **2** | Read Ticket | Training Ticket ID: `TRN-001` | "Understand the technical context." |
| **3** | Investigation | 'SIEM' Desktop Icon | "Find the forensic evidence." |
| **4** | Verification | Malicious Log Entry | "Match the IP from the ticket to the SIEM." |
| **5** | Connection | 'Attach to Case' Button | "Document the proof." |
| **6** | Resolution | 'Resolve' -> 'Compliant' | "Close the case according to protocol." |

---

### 4. Technical Components Needed

#### A. `TutorialManager.gd` (Autoload Enhancement)
*   State machine to track `TUTORIAL_STEP`.
*   Signals to detect when specific UI buttons are pressed.
*   Logic to enable/disable the `TutorialOverlay`.

#### B. `GuidedHighlight` (UI Component)
*   A reusable script/scene that can be attached to any `Button` or `TextureRect`.
*   Draws a white 2px border and a subtle "Pulse" animation.
*   Visibility toggled by the `TutorialManager`.

#### C. `TutorialOverlay` (Visual Mask)
*   A full-screen `ColorRect` (Black, 40% Alpha).
*   Uses a "Hole Punch" shader or a dynamic sub-viewport to keep the highlighted button bright while the rest of the screen is dark.

---

### 5. Best Practices Checklist
- [ ] **No giant text blocks:** Instructions must be under 15 words.
- [ ] **Non-punitive:** Disable the "Integrity Decay" and "Heat" during the tutorial.
- [ ] **Validation:** Ensure the player cannot click the wrong app during critical steps.
- [ ] **Feedback:** Play a "Success" sound effect after every correctly completed step.

---

### 6. Tomorrow's Workflow
1.  **Morning:** Create the `TutorialOverlay` shader/mask.
2.  **Afternoon:** Update `TutorialManager.gd` with the expanded logic.
3.  **Evening:** Script the CISO's Orientation dialogue and spawn points.
