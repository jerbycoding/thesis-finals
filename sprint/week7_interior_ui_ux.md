# Sprint Week 7: Interior UI/UX & Spatial Feedback

## 1. Objective
Transform the 3D environment from a static shell into an informative, navigable workspace by implementing Diegetic UI (in-world displays) and improving spatial UX.

## 2. Tasks

### 2.1 Diegetic World Displays (COMPLETED)
*   [x] **War Wall Real-time Data:** Link the "War Wall" emissive materials to `TicketManager` signals. 
*   [x] **Host Status Monitors:** Add small floating or wall-mounted panels near the IT Lab that display the current number of isolated hosts from `NetworkState`.

### 2.2 Spatial Navigation & Signposting (COMPLETED)
*   [x] **Zone Labeling:** Add 3D text meshes or glowing wall decals for "ZONE A: BULLPEN", "ZONE B: SECURE LAB", and "STORAGE/ACCESS".
*   [x] **Floor Guiding Lights:** Implement subtle glowing "pathway" strips on the floor leading from the Bullpen to the Elevator.

### 2.3 Interaction UX Improvements (COMPLETED)
*   [x] **Highlight Material:** Create a visual pulse that activates on the computer monitor or NPCs when the player is within interaction range.
*   [x] **Progressive Interaction Prompts:** Update the 3D HUD to show context-aware prompts.

### 2.4 Environmental Feedback
*   **Zone-Based Audio:** Implement `AudioStreamPlayer3D` nodes for "Server Hum" in the Storage area and "Keyboard Chatter" in the Bullpen.
*   **Elevator Feedback:** Add a mechanical "Ding" sound and a light change (Green/Red) when the elevator doors open/close.

## 3. Technical Requirements
*   All world-space UI must use `ViewportTexture` or `Label3D` for crisp text.
*   Environmental feedback must not interfere with core gameplay 2D transitions.
