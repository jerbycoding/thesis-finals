# Contract Board Redesign: Broker Dossier

## Objective
To redesign the `App_ContractBoard` from a standard corporate UI (which fits the Analyst) into an immersive, clandestine "Encrypted Message / Dossier" interface fitting the Hacker role and the "Broker" narrative.

## Key Files & Context
*   **Target Scene:** `res://scenes/2d/apps/App_ContractBoard.tscn`
*   **Target Script:** `res://scripts/2d/apps/App_ContractBoard.gd`
*   **Resources:** Relies on the `ContractResource` structure (which now includes `tactical_hint`).

## Proposed Solution (The Aesthetic Shift)

The new interface will adopt a "High-Contrast Clandestine" aesthetic:
1.  **Header:** Change "CONTRACT BOARD" to something narrative like "ENCRYPTED CHANNEL: BROKER_NODE".
2.  **Layout Refactor:** Move away from the side-by-side or stacked corporate boxes. Use a layout that looks like a raw data feed or a classified document.
3.  **Active Contract Focus (The Dossier):** 
    *   The active mission takes center stage.
    *   The narrative text is presented as "Intercepted Comms" or "Mission Brief".
    *   **The Tactical Hint:** This is visually separated into an eye-catching "BROKER NOTE:" or "LEAKED INTEL:" box with warning colors (e.g., Amber or Cyan) to ensure the player reads the educational advice.
4.  **Available Contracts (The Dark Market):**
    *   Instead of standard buttons, present available contracts as a list of "Available Bounties" or "Open Targets" in a monospaced, data-grid style.

## Implementation Steps

### Phase 1: Scene Reconstruction (`App_ContractBoard.tscn`)
1.  **Colors & Backgrounds:** Ensure all `ColorRect` and `PanelContainer` backgrounds are pitch black (`#050505`) or highly transparent dark grays to let the `HackerTheme` shine.
2.  **Typography Hierarchy:** Use `RichTextLabel` extensively for mission descriptions to allow BBCode formatting (e.g., highlighting target names in red).
3.  **The Intel Block:** Create a specific, bordered `PanelContainer` (maybe with a dashed border via stylebox or text) dedicated solely to the `tactical_hint`.

### Phase 2: Script Enhancements (`App_ContractBoard.gd`)
1.  **Typing Effect (Immersion):** When a contract is clicked or loaded, animate the `visible_characters` property of the `RichTextLabel` to make the mission brief look like it's being decoded or typed out in real-time.
2.  **Data Binding:** Ensure the newly added `tactical_hint` from the `ContractResource` is correctly injected into the "Intel Block".
3.  **Button Polish:** Change generic "ACCEPT" and "SUBMIT" to narrative equivalents like "INITIATE_HANDSHAKE" and "UPLOAD_PAYLOAD_EVIDENCE".

## Verification & Testing
1.  Open the Hacker Campaign.
2.  Launch the Contract Board.
3.  Verify the immediate visual departure from Analyst apps.
4.  Accept a Day 2 or Day 3 mission and verify the "Tactical Hint" (e.g., using Phish Crafter) is highly visible and educational.
5.  Ensure the "Submit" function still correctly ends the shift and triggers the Mirror Mode report.