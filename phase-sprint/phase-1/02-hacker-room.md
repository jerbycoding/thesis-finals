# TASK 2: HACKER ROOM 3D ENVIRONMENT

## Description
[SOLO DEV SCOPE] Create the Hacker's safe house. Reuse existing assets — no new modeling required.

## Implementation Details

### A. Scene Creation
*   **File:** `scenes/3d/HackerRoom.tscn`
*   **Structure:** Reuse `InteractableComputer.tscn` from Analyst office
*   **ViewAnchor:** Must have SAME name as Analyst's ViewAnchor (critical for TransitionManager)

### B. Visual Differentiation (Simple)
*   Change wall color to darker tone (WorldEnvironment)
*   Add green emissive material to monitor screens (ShaderMaterial)
*   Optional: Add "Matrix rain" texture on monitors

### C. Transition Verification
*   Test `TransitionManager.play_secure_login()` anchors correctly
*   Verify camera sits at hacker desk without clipping

## Success Criteria
- [ ] **[BLOCKER]** HackerRoom.tscn exists and is navigable
- [ ] **[BLOCKER]** ViewAnchor name matches Analyst's ViewAnchor
- [ ] Player can sit at computer and desktop loads
- [ ] Room has distinct visual identity (darker, green accents)

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Physical heat indicators (lights, sounds)
- ❌ Phone/router interactions
- ❌ Multi-monitor setup (single monitor ok)
