# Sprint 12: Ambient Synchronization

**Goal:** Synchronize the visual state of the 3D "Ambient" Desktop with the persistent 2D Desktop overlay. When a player opens a window or receives a notification on the main interface, the 3D monitor in the office should reflect this change.

**Context:**
Currently, the 3D monitor shows a static "clean" desktop. When the player opens apps (like SIEM or Email), stands up, and looks at the monitor, it reverts to the clean state, breaking immersion. Since we have implemented a persistent desktop in Sprint 11, we can now mirror its state to the 3D world.

## Objectives

1.  **Signal Infrastructure:**
    - Update `DesktopWindowManager` to emit comprehensive signals for window lifecycle events (`window_opened`, `window_closed`, `all_windows_closed`).
    - Ensure these signals carry enough data (App ID, maybe visual reference) to reconstruct a "ghost" window.

2.  **Ambient Window System:**
    - Create `scenes/2d/AmbientWindow.tscn`: A purely visual representation of an app window (using the same theme/style but stripped of logic).
    - It needs to support "styles" (e.g., looking like the Email app vs Terminal).

3.  **Controller Logic:**
    - Update `scripts/2d/AmbientDesktop.gd` to:
        - Connect to `DesktopWindowManager` signals.
        - Spawn/Despawn `AmbientWindow` instances matching the real desktop.
        - (Optional) Clear all ambient windows if the real desktop is reset.

## Technical Implementation Plan

### 1. Modify `autoload/DesktopWindowManager.gd`
- Add signals:
    - `window_opened(app_id: String, window_node: Node)`
    - `window_closed(app_id: String)`
- Ensure `open_app` and `close_window` functions emit these signals.

### 2. New Scene: `scenes/2d/AmbientWindow.tscn`
- Root: `PanelContainer` (Theme: `EnterpriseTheme`)
- Script: `scripts/2d/AmbientWindow.gd` (Minimal API: `setup(app_name, title)`)
- Children:
    - Header (Title Label, Fake Close Button)
    - Content Placeholder (ColorRect or simple texture to mimic the app).

### 3. Update `scripts/2d/AmbientDesktop.gd`
- In `_ready()`: Connect to `DesktopWindowManager`.
- Implement `_on_window_opened`:
    - Check if app is already visible (prevent duplicates).
    - Instantiate `AmbientWindow`.
    - Add to `AppWindowContainer` (which exists in `AmbientDesktop.tscn` structure).
- Implement `_on_window_closed`:
    - Find child matching app_id and `queue_free()`.

## Success Criteria
- [ ] Opening "Email" on the 2D overlay and standing up shows a fake Email window on the 3D monitor.
- [ ] Closing the window on the overlay removes it from the 3D monitor.
- [ ] The sync works consistently across multiple sit/stand cycles.
