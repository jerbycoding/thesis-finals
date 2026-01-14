# Sprint Week 2: Hybrid System & Dynamic Events

## 1. Objective
Add depth to the simulation by introducing procedural noise and unpredictable environment events.

## 2. Tasks
### 2.1 The Hybrid System
*   **Ambient Noise:** Implement a procedural generator for "Generic" tickets (Auth Failures, System Maintenance).
*   **Prioritization Test:** Ensure generic tickets do not trigger the `ConsequenceEngine` but still consume player time.

### 2.2 Dynamic Shift Events
*   **The Zero-Day:** Implement a global state that increases workstation scan times by 50%.
*   **System Maintenance:** Add UI visual effects (flickering/lag) to the SIEM Log Viewer.
*   **The CISO's Walk-by:** Create a 3D NPC interaction that interrupts the desktop view for a status check.
*   **False Flag Outage:** Implement a logic to flood the queue with "System Offline" logs that are actually benign.

### 2.3 Resource Monitor (Task Manager)
*   Implement a diagnostic tool UI that shows:
    *   **CPU Load:** Spikes during specific events or high ticket volume.
    *   **Network Throughput:** Visualizes SIEM latency or "System Maintenance" effects.
*   Allow players to correlate tool performance with active shift events.

### 2.4 Narrative Director Integration
*   Logic for the `NarrativeDirector` to trigger these events randomly or based on shift progression.

## 3. Technical Requirements
*   `NarrativeDirector.gd` integration with `TransitionManager.gd` for 3D/2D context switching during NPC walk-bys.
*   Shader or UI logic for the "System Maintenance" flicker effect.
*   Graphing logic for the Task Manager telemetry.
