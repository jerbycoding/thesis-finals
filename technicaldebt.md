# VERIFY.EXE: Technical Debt & Refactoring Roadmap

This document tracks "Static" logic patterns that need to be refactored into "Dynamic" systems to improve maintainability and scalability.

---

## 1. Static Objective Management (Priority: HIGH)
**Location:** `MaintenanceHUD.gd`, `TabletHUD.gd`
**The Debt:** The list of tasks (e.g., `audit_1` through `audit_6` and `rep_1` through `rep_4`) is manually typed into the code. Adding or removing a physical object in the 3D scene requires manual code updates.
**The Fix:** 
- Implement **Scene Discovery**. On `_ready()`, the HUD should scan the "socket" or "audit_nodes" groups.
- Automatically generate the checklist based on the nodes found in the current scene.

## 2. Hardcoded Hardware Requirements
**Location:** `TabletHUD.gd`, `HardwareSocket.gd`
**The Debt:** The Tablet "knows" that RACK_1 needs an NVMe drive because it is written in a Dictionary in the script.
**The Fix:** 
- The Tablet should query the 3D Socket node directly: `socket.get_required_type()`.
- This allows designers to change requirements inside the Godot Inspector without touching GDScript.

## 3. Manual Signal Mapping
**Location:** `MaintenanceHUD.gd` (the `_on_event` function)
**The Debt:** We use `if rack == "RACK_1": _complete_task("rep_1")`. This mapping is fragile.
**The Fix:**
- Standardize the IDs. If a 3D node has `audit_id = "alpha"`, the task ID in the HUD should also be `"alpha"`.
- Use a generic event handler: `_complete_task(details.id)`.

## 4. Shift Progression Logic
**Location:** `SaveSystem.gd`, `NarrativeDirector.gd`
**The Debt:** Determining the "Next Shift" relies on string lookups and manual property checks.
**The Fix:**
- Move all shift transition logic into the `ShiftResource`.
- The SaveSystem should simply save the `current_shift_id` and let the `NarrativeDirector` handle the rest.

---

## Tomorrow's "Payoff" Goal:
Move to a **"Zero-Code Level Design"** model. 
*Goal:* You should be able to drag-and-drop a new Server Rack into the 3D vault, and the game should automatically add it to the HUD, Tablet, and Win-Conditions without you opening a single script.
