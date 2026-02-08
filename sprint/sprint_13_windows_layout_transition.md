# Sprint 13: Windows Layout Transition (Enterprise Hybrid)

**Goal:** Redesign the Desktop UI to follow a "Windows-inspired" layout while maintaining the dark SOC/Enterprise aesthetic. This transition aims to improve player intuition and provide more "Command Center" utility.

**Context:**
The current desktop uses a minimalist dock-style taskbar. While functional, it lacks the professional "workstation" feel of a corporate SOC environment. Moving to a Windows-style layout allows for features like a global search bar and a dedicated system tray for real-time status monitoring.

## Objectives

1.  **Taskbar Restructuring:**
    - Transform the current `Taskbar` from a centered dock into a full-width bottom bar.
    - Implement a "Windows-style" layout: [Start Button] [Search Bar] [Active Tasks Container] [System Tray/Clock].

2.  **Search Bar Implementation:**
    - Create a functional Search Bar on the taskbar.
    - **Utility:** Primarily used for quick-access to logs or documentation (e.g., typing "IP" highlights IP-related tools).

3.  **System Tray Development:**
    - Group status indicators (Network status, integrity, clock) in the bottom-right corner.
    - Ensure visual consistency between the 2D Desktop and the 3D Monitor's "Ambient" view.

4.  **Visual Overhaul (Enterprise Hybrid):**
    - Retain the `EnterpriseTheme` colors (Dark Blues, Neon Greens/Blues).
    - Apply "Acrylic" or "Glass" effects to the taskbar and start menu using `StyleBoxFlat` properties (transparency + subtle borders).

## Technical Implementation Plan

### 1. Scene Updates: `scenes/2d/ComputerDesktop.tscn` & `scenes/2d/AmbientDesktop.tscn`
- **Taskbar:** Update `PanelContainer` to `anchor_bottom = 1.0` and `anchor_right = 1.0` with a fixed height (~45px).
- **Layout:**
    - Left: `HBoxContainer` for Start Menu and new `SearchBar` component.
    - Center: `HBoxContainer` (expanded) for `ActiveTasksContainer`.
    - Right: `HBoxContainer` for `SystemTray` (containing `StatusLabel` and `DesktopClock`).

### 2. New Component: `scenes/2d/DesktopSearchBar.tscn`
- Root: `LineEdit` with custom styling.
- Logic: `scripts/2d/DesktopSearchBar.gd` to filter active tools or search the SOC handbook.

### 3. Desktop Icons System:
- Implement a grid-based icon container on the desktop background.
- Standard icons: "Recycle Bin" (for discarded logs), "My Computer" (Network Map), "SOC Handbook".

## Success Criteria
- [x] Taskbar spans the full width of the screen.
- [x] UI elements are organized into Start, Search, Tasks, and Tray sections.
- [x] The "Ambient" view in 3D correctly mirrors the new taskbar layout.
- [x] The desktop feels more like a "Corporate Workstation" than a mobile/minimalist OS.

**Status: COMPLETE**
The desktop has been successfully transitioned to the Enterprise Hybrid layout. Visual fidelity between 3D and 2D environments is maintained, and the new workstation ergonomics (larger screen + organized taskbar) significantly improve the "SOC Analyst" roleplay experience.
