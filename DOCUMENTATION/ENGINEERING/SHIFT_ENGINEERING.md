# Shift Engineering (Narrative Orchestration)

This document defines the technical schema for `ShiftResource` files. Use this to orchestrate the timeline of a shift, including scripted events, random chaos, and weekend minigames.

---

## 1. The Event Sequence (`event_sequence`)
The `event_sequence` is an array of Dictionaries. Each entry must have a `time` (seconds from shift start) and a `type`.

### **A. Ticket Spawn**
Injects a new incident into the player's queue.
```json
{
  "time": 30,
  "type": "spawn_ticket",
  "ticket_id": "PHISH-001"
}
```

### **B. NPC Interaction**
Triggers a dialogue sequence. If the player is in 2D mode, the game will automatically exit to 3D and find the NPC.
```json
{
  "time": 90,
  "type": "npc_interaction",
  "npc_id": "senior_analyst",
  "dialogue_id": "monday_morning"
}
```
*   **Remote Fallback**: If the NPC is not in the current scene, the system looks for a resource at `res://resources/dialogue/[npc_id]_[dialogue_id].tres`.

### **C. System Event**
Triggers environmental effects and gameplay modifiers.
```json
{
  "time": 240,
  "type": "system_event",
  "event_id": "ZERO_DAY",
  "duration": 60.0
}
```
| Event ID | Effect |
| :--- | :--- |
| `ZERO_DAY` | Intense screen shake, aggressive timer acceleration. |
| `SIEM_LAG` | Adds artificial delay/jitter to SIEM search results. |
| `POWER_FLICKER` | Screen flashes black, closes all 2D windows. |
| `DDOS_ATTACK` | Subtle continuous screen shake, increases terminal command latency. |
| `FALSE_FLAG` | Spawns a flood of "Noise" logs in the SIEM. |

### **D. Shift End**
Finalizes the shift and triggers the **Shift Report**.
```json
{
  "time": 600,
  "type": "shift_end",
  "failure_type": "" 
}
```
*   **`failure_type`**: If set to `"fired"` or `"bankrupt"`, the game skip the report and goes straight to the ending scene.

---

## 2. The Chaos Engine (`random_event_pool`)
The `NarrativeDirector` runs a "Chaos Tick" every ~45 seconds (scaled by difficulty). There is a **35% chance** to pick a random event from this pool.
*   Random events use the same schema as `event_sequence` but do not need a `time` key.

---

## 3. Weekend & Minigame Config
Weekend shifts (Saturday/Sunday) use the physical world navigation.

| Field | Value | Effect |
| :--- | :--- | :--- |
| **`minigame_type`** | `"AUDIT"` | Saturday: Navigation in the Network Hub (Floor -2). |
| **`minigame_type`** | `"RECOVERY"` | Sunday: Hardware maintenance in the Server Vault (Floor -1). |
| **`required_floor`** | `-2` or `-1` | Enforces player location before the shift can progress. |

---

## 4. Shift Chaining
*   **`next_shift_id`**: The ID of the `ShiftResource` to load after the current one is completed. 
*   **Victory Condition**: If `next_shift_id` is empty, completing the shift triggers the **Promotion (Victory)** ending.

---

## 5. Threat Intel UI
Data in the "Threat Intelligence" group is displayed in the **Dossier/Briefing** screen during the `Secure Login` sequence.
*   **`threat_indicators`**: Array of strings shown as a bulleted checklist for the player's reference.
