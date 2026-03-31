# TASK 2: 3D "REMOTE OFFICE" SCAFFOLDING

## Description
[REVISED] Create the physical "Safe House" environment for the hacker, ensuring all necessary visual and audio systems are correctly registered.

## Implementation Details
*   **Scene:** Create `scenes/3d/HackerRoom.tscn`.
*   **Assets:** 
    *   Reuse `InteractableComputer.tscn`.
    *   **[BLOCKER]** The `ViewAnchor` node within the computer scene **must** have the exact same name as the one in the Analyst's office to ensure `TransitionManager` can find it without role-specific logic.
*   **Visual Bridge:** Verify that the `MonitorInputBridge` system correctly projects the 2D desktop UI onto the 3D computer mesh in the new `HackerRoom.tscn` environment.
*   **Audio Context:** The `HackerRoom.tscn`'s root node must be configured with the correct floor ID to allow `AudioManager` to detect it and trigger the `swap_ambient_loop` function.
*   **Transition:** Verify `TransitionManager.gd`'s sitting animation anchors correctly in the smaller room.

## Success Criteria
- [ ] **[BLOCKER]** The `ViewAnchor` node in `HackerRoom.tscn`'s computer shares the identical name with the Analyst's `ViewAnchor`.
- [ ] `HackerRoom.tscn` exists and is navigable.
- [ ] `MonitorInputBridge` correctly renders the UI on the 3D monitor model.
- [ ] `TransitionManager` transitions cleanly to the computer view without errors.
- [ ] Entering the Hacker Room triggers the correct ambient audio loop via `AudioManager`.
