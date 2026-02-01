# 🪟 Sprint 10: OS Design Transition (Windows Logic)

**Status:** PLANNED
**Focus:** UI Layout Overhaul & Desktop Ergonomics
**Objective:** Transition the workstation interface from a Linux-inspired layout to a Windows-inspired "Enterprise" design.

---

## 🎯 Strategic Objectives

1.  **Unified Taskbar:** Consolidate the `TopSystemBar` and `BottomDock` into a single `Taskbar` at the bottom of the screen.
2.  **Start Menu Logic:** Reposition the Applications menu to the bottom-left, acting as the primary interaction point.
3.  **System Tray Migration:** Move the `DesktopClock` and `NetworkStatus` to the bottom-right, following standard Windows ergonomics.
4.  **Desktop Grid:** Move utility icons (Handbook, Network Map) from the side bar to a vertical grid on the desktop surface.

---

## 📂 File Impact Audit

| File | Type | Change Description |
| :--- | :--- | :--- |
| `scenes/2d/ComputerDesktop.tscn` | **Scene** | Major hierarchy refactor. Delete `TopSystemBar`, create `Taskbar`. |
| `scripts/2d/ComputerDesktop.gd` | **Script** | Update @onready paths for the new Taskbar structure. |
| `scenes/ui/UnifiedHUD.tscn` | **Scene** | Adjust position if the new taskbar interferes with the 3D-world HUD overlay. |
| `assets/themes/EnterpriseTheme.tres`| **Theme** | Update Taskbar StyleBox to match Windows "Taskbar" aesthetic (slight transparency + blur). |

---

## 🛠️ Task Breakdown

### 1. Taskbar Consolidation
*   Move `DockIcons` and `SystemTray` elements into a new `PanelContainer` at the bottom of the `ScreenSafeArea`.
*   Implement `HBoxContainer` layout: `[StartButton] --- [AppIcons] --- [TrayIcons]`.

### 2. Desktop Shortcut Grid
*   Remove the `LeftUtilityBar`.
*   Implement a `GridContainer` on the left side of the `DesktopBackground`.
*   Place "Handbook", "Network Topology", and "Decryption" as standard desktop shortcuts.

### 3. Start Menu Placeholder
*   Transform the "❄ APPLICATIONS" button into a "Start" icon.
*   (Future) Prepare for a popup Start Menu instead of a top-down list.

### 4. Exit Button Relocation
*   Move the Power/Exit button to the far right of the taskbar or inside the Start Menu.

---

## ✅ Sprint 10 Completion Criteria
1.  [ ] Taskbar is locked to the bottom margin of the `ScreenSafeArea`.
2.  [ ] Windows are still clipped correctly within the safe area above the taskbar.
3.  [ ] Clock and Status remain functional in their new bottom-right position.
4.  [ ] Desktop icons are organized in a clean vertical column on the left.

> **Note:** This transition enhances the "Simulation" feel by mimicking the most common enterprise operating environment.
