# Sprint 11: 3D Workspace Immersion

**Goal:** Enhance the visual fidelity and immersion of the SOC environment by rendering the 2D desktop interface directly onto the 3D monitor props.

**Context:**
Currently, the 3D office environment features "dead" black screens on computer monitors. The transition to the gameplay loop (2D Desktop) feels disconnected. By projecting a "live" version of the desktop onto the 3D monitor, we create a more cohesive world where the player feels they are physically approaching a working machine.

## Objectives

1.  **Create "Ambient" Desktop Mode:**
    - Develop a simplified version of the `ComputerDesktop` scene that handles visuals (clock, layout, icons) but **excludes** gameplay logic (input handling, window management, event bus connections).
    - This prevents signal duplication bugs when the "real" desktop overlay is loaded later.

2.  **Upgrade 3D Monitor Prop:**
    - Update `Prop_Monitor` to include a `SubViewport`.
    - Create a dynamic material that maps the SubViewport texture to the monitor's screen surface.
    - Ensure the screen emits light (glow) based on the desktop content.

3.  **Integrate into 3D Scene:**
    - Replace the static monitor in `InteractableComputer.tscn` with the new active monitor.
    - Ensure the SubViewport uses "When Visible" update mode to save performance when the player is not looking at the screen.

## Technical Implementation Plan

### 1. New File: `scripts/2d/AmbientDesktop.gd`
A stripped-down version of `ComputerDesktop.gd`.
- **Inherits:** `Control`
- **Features:**
    - Sets up icon layout (visuals only).
    - Updates the clock (visuals only).
    - **NO** `DesktopWindowManager` registration.
    - **NO** `EventBus` signal connections.
    - **NO** `_input` processing.

### 2. New Scene: `scenes/2d/AmbientDesktop.tscn`
- Duplicate of `scenes/2d/ComputerDesktop.tscn`.
- Script attached: `scripts/2d/AmbientDesktop.gd`.
- Remove `ExitButton` (not needed for ambient view).

### 3. Modified Scene: `scenes/3d/props/graybox/Prop_Monitor.tscn`
- Add `SubViewport` node (Size: 1280x720).
- Instance `scenes/2d/AmbientDesktop.tscn` inside the viewport.
- Update `Screen_Glass` material to use `ViewportTexture`.

### 4. Modified Scene: `scenes/InteractableComputer.tscn`
- Ensure it uses the updated `Prop_Monitor` or verify the instance inherits the changes correctly.

## Success Criteria
- [ ] The computer monitor in the 3D office displays the desktop UI.
- [ ] The desktop clock on the 3D monitor updates in real-time.
- [ ] The screen glows in the dark 3D environment.
- [ ] Walking up to and clicking the computer still triggers the `TransitionManager` correctly.
- [ ] No double-signal errors or performance spikes occur.
