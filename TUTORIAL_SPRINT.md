# 🏃 TUTORIAL SPRINT: Physical Onboarding & Guided Investigation
**Goal:** Transform the current text-based tutorial into an immersive "Physical-First" experience followed by a high-polish guided technical investigation.

---

## 📅 Objective Overview
1.  **Phase 1: Physical Orientation (3D)**
    *   Player spawns at elevator.
    *   Dialogue with CISO provides roaming task.
    *   Player must physically walk to "Office C".
2.  **Phase 2: Technical Initialization (Transition)**
    *   Entering the office triggers the "Use Workstation" objective.
    *   Sitting at the desk transitions into a restricted "Guided Mode."
3.  **Phase 3: Guided Forensic Loop (2D)**
    *   Use a "Focus Mask" (dimmed screen with hole punch) to highlight specific icons.
    *   Force the player through the correct sequence: Ticket -> SIEM -> Attach -> Resolve.

---

## 🛠️ Affected Files Checklist

### 1. Autoloads (Logic & State)
- [ ] `autoload/TutorialManager.gd`: 
    - Expand `TutorialStep` enum to include `ROAM_TO_OFFICE`.
    - Add `reach_3d_objective(id)` helper.
    - Implement restricted logic (prevent opening wrong apps during tutorial).
- [ ] `autoload/GameState.gd`:
    - Add `is_guided_mode: bool` to disable the pause menu and "⏻ Exit" button during training.

### 2. 3D Components (Physical Phase)
- [ ] `scripts/3d/TutorialTrigger.gd` **(NEW)**: 
    - Area3D script to detect player entry and notify `TutorialManager`.
- [ ] `scenes/SOC_Office.tscn`: 
    - Add a `TutorialTrigger` volume at the entrance of "Your Room".
    - Add a `Marker3D` for the tutorial spawn point (Elevator).

### 3. UI & Visuals (Guided Phase)
- [ ] `shaders/focus_mask.gdshader` **(NEW)**: 
    - Shader to dim the screen and punch a circular/rectangular hole.
- [ ] `scenes/ui/TutorialOverlay.tscn` **(NEW)**: 
    - Full-screen UI layer using the shader.
- [ ] `scripts/ui/TutorialOverlay.gd` **(NEW)**: 
    - Logic to move the "Hole" to specific UI elements (Tickets icon, Attach button).
- [ ] `scripts/2d/ComputerDesktop.gd`: 
    - Integrate with `TutorialOverlay` to toggle visibility.

### 4. Data & Narrative
- [ ] `resources/dialogue/tutorial_intro.tres`: 
    - Update text to focus on physical roaming ("Walk to Office C").
- [ ] `resources/tickets/TRN-001.tres` **(NEW)**: 
    - A dedicated training ticket with fixed evidence IDs.
- [ ] `resources/logs/LOG-TRN-001.tres` **(NEW)**: 
    - A tutorial-only log entry that provides the exact evidence needed.
- [ ] `resources/emails/EMAIL-TRN-001.tres` **(NEW)**: 
    - A tutorial email explaining the "Technical SOP" (Standard Operating Procedure).
- [ ] `resources/shifts/TutorialShift.tres`: 
    - Update sequence to spawn `TRN-001`.

---

## 🚀 Implementation Tasks

### Sprint 1: The Physical Walk (3D)
1.  **Modify** `TutorialManager.gd` to handle the roaming state.
2.  **Create** `TutorialTrigger.gd` and place it in the office scene.
3.  **Update** `tutorial_intro.tres` to give the walking instructions.

### Sprint 2: The Focus Mask (Visuals)
1.  **Develop** the `focus_mask.gdshader`.
2.  **Create** the `TutorialOverlay.tscn` scene.
3.  **Add** helper functions to `TutorialOverlay.gd` to "HighlightNode(node_path)".

### Sprint 3: The Restricted Loop (Restraints)
1.  **Create** `TRN-001` Tutorial Ticket.
2.  **Modify** `ValidationManager.gd` to block "Efficient/Emergency" closures during tutorial.
3.  **Modify** `DesktopWindowManager.gd` to block non-essential apps during tutorial.

---

## 🧪 Verification Plan
- **Test:** Can the player ignore the desk and walk to the lounge? (Dialogue should remind them to go to the office).
- **Test:** Can the player click the "SIEM" before the "Tickets" app? (Should be blocked by Focus Mask).
- **Test:** Does closing the tutorial ticket return the game to "Normal Mode"?
