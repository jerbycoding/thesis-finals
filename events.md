# Global System Events

This document outlines the **World Events** used by the `NarrativeDirector` to modify the game state globally. These events are triggered by `system_event` entries in the Shift Resource files and broadcast via the central Event Bus.

---

## 📡 Event Architecture

*   **Signal:** `EventBus.world_event_triggered(event_id, active, duration)`
*   **Definition:** Logic keys are usually mapped in `GlobalConstants.gd` or handled directly by systems.
*   **Function:** Unlike Tickets (which are solvable tasks), Events are **conditions** that last for a set duration. All major systems (`LogSystem`, `TerminalSystem`, `NetworkState`) listen to this signal.

---

## ⚡ Active Event Catalog

### 1. `FALSE_FLAG` (The Log Flood)
*   **Narrative:** Attackers flood the system with garbage data to hide their real tracks.
*   **Trigger:** Typically Shift 2 (Tuesday).
*   **Effect (LogSystem):**
    *   Spawns 1 "Noise Log" every 0.5 - 2.0 seconds.
    *   Noise logs look realistic but contain no actionable evidence.
*   **Gameplay Impact:** Forces the player to use SIEM filters effectively.

### 2. `SIEM_LAG` (System Instability)
*   **Narrative:** The SIEM software is glitching due to high load or interference.
*   **Effect (App_SIEMViewer):**
    *   The SIEM window opacity fluctuates randomly (flickers/fades).
*   **Gameplay Impact:** Adds visual stress and difficulty reading forensic data.

### 3. `ZERO_DAY` (Resource Drain)
*   **Narrative:** An unknown exploit is consuming system resources globally.
*   **Effect (TerminalSystem):**
    *   **Scan Time Multiplier:** `1.5x`.
    *   Terminal commands (`scan`, `trace`) take 50% longer.
*   **Effect (TaskManager):** CPU usage spikes to >90%.
*   **Gameplay Impact:** Limits the player's ability to "spam" scans during a crisis.

### 4. `LATERAL_MOVEMENT` (Worm Simulation)
*   **Narrative:** Malware is actively spreading through the network.
*   **Effect (NetworkState):**
    *   Every 10 seconds, there is a 30% chance an INFECTED host spreads the infection to a CLEAN neighbor.
*   **Gameplay Impact:** Creates extreme urgency to use the Terminal `isolate` command.

---

## 🛠️ How to Trigger Manually (Debug)
Since the refactor, signals must be emitted through the `EventBus` singleton:

```gdscript
# Trigger a 30-second Log Flood
EventBus.world_event_triggered.emit("FALSE_FLAG", true, 30.0)

# Trigger 60 seconds of Terminal Slowness
EventBus.world_event_triggered.emit("ZERO_DAY", true, 60.0)

# Trigger Lateral Movement
EventBus.world_event_triggered.emit("LATERAL_MOVEMENT", true, 0.0)
```