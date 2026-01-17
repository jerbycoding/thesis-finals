# Global System Events

This document outlines the **World Events** used by the `NarrativeDirector` to modify the game state globally. These events are triggered by `system_event` entries in the Shift Resource files.

---

## 📡 Event Architecture

*   **Signal:** `NarrativeDirector.world_event(event_id, active, duration)`
*   **Definition:** Keys are stored in `GlobalConstants.EVENTS`.
*   **Function:** Unlike Tickets (which are solvable tasks), Events are **conditions** that last for a set duration.

---

## ⚡ Active Event Catalog

### 1. `FALSE_FLAG` (The Log Flood)
*   **Narrative:** Attackers flood the system with garbage data to hide their real tracks.
*   **Trigger:** Shift 2 (Tuesday) at `T+90s`.
*   **Duration:** 60 seconds.
*   **Effect (LogSystem):**
    *   Spawns 1 "Noise Log" every 0.5 - 2.0 seconds.
    *   Noise logs look realistic ("Printer Online", "Update Success") but are useless.
*   **Gameplay Impact:** The player must filter through this spam to find the evidence for `SPEAR-PHISH-001`.

### 2. `SIEM_LAG` (System Instability)
*   **Narrative:** The SIEM software is glitching due to high load or interference.
*   **Trigger:** *Currently unused in new Shift plan (was in old Shift 1).*
*   **Effect (App_SIEMViewer):**
    *   The SIEM window opacity fluctuates randomly (flickers/fades).
    *   Makes reading text physically difficult.
*   **Gameplay Impact:** Adds visual stress during investigation.

### 3. `ZERO_DAY` (Resource Drain)
*   **Narrative:** An unknown exploit is consuming system resources.
*   **Trigger:** *Reserved for Shift 5 (Friday) or Random Events.*
*   **Effect (TerminalSystem):**
    *   **Scan Time Multiplier:** `1.5x`.
    *   Terminal commands (`scan`, `logs`) take 50% longer to complete.
*   **Effect (TaskManager):** CPU usage spikes to >90%.
*   **Gameplay Impact:** Forces the player to be more decisive with Terminal commands because they are slow.

---

## 🛠️ How to Trigger Manually (Debug)
You can test these events using the Godot Console or by adding a temporary script:

```gdscript
# Trigger a 30-second Log Flood
NarrativeDirector.world_event.emit("FALSE_FLAG", true, 30.0)

# Trigger 60 seconds of Lag
NarrativeDirector.world_event.emit("SIEM_LAG", true, 60.0)
```
