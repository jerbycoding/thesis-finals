# VERIFY.EXE: Analyst Archetype Registry

This document defines the player classification system used to evaluate performance at the end of each shift. Archetypes are derived from historical metrics tracked by the **ConsequenceEngine** and determine the narrative feedback and professional standing of the player.

## 📊 Evaluation Metrics
The system calculates your archetype using the following data points:
- **Completed Tickets**: Successfully resolved incidents.
- **Ignored Tickets**: Incidents that reached timeout without resolution.
- **Risks Taken**: Incremented when closing a ticket using **Efficient** or **Emergency** protocols (shortcuts).
- **Avg Completion Time**: The average speed (in seconds) from ticket selection to closure.

---

## 🎭 The Archetypes

### 🛑 NEGLIGENT
*The Liability*
- **Condition**: `Ignored Tickets > 0` AND `Completed Tickets <= Ignored Tickets`.
- **Description**: You have failed to address critical security alerts. Your lack of action has left the organization vulnerable to multiple breaches and data loss.
- **Consequence**: High risk of **Professional Termination** (Game Over). This style indicates a failure to maintain the minimum operational tempo required by the SOC.

### 📜 BY-THE-BOOK
*The Meticulous*
- **Condition**: `Completed Tickets > 0` AND `Risks Taken == 0` AND `Ignored Tickets == 0`.
- **Description**: You are a meticulous and thorough analyst. You follow procedure to the letter, ensuring every detail is checked.
- **Impact**: Maximizes **Organizational Integrity** gains (+5% per ticket). While safest for the network, this style is the most vulnerable to **Chaos Engine** disruptions like "SIEM Lag" or "Gossip Floods."

### 🤠 COWBOY
*The Decisive*
- **Condition**: `Completed Tickets > 0` AND (`Risks Taken >= 3` OR (`Risks Taken > 0` AND `Avg Completion Time < 60s`)).
- **Description**: You are a fast and decisive analyst, prioritizing speed above all else. You close tickets at a record pace.
- **Impact**: High operational throughput, but triggers **Vulnerability Inheritance**. Technical indicators from "Efficient" closures are cached and will resurface in future, more severe incidents.

### ⚖️ PRAGMATIC
*The Balanced (Default)*
- **Condition**: `Completed Tickets > 0` (Fallback if no other conditions are met).
- **Description**: You are a balanced and efficient analyst. You know when to follow the rules and when to prioritize speed.
- **Impact**: Provides a stable balance between organizational integrity and operational speed. This is considered the ideal baseline for an analyst.

---

## 🛠️ Technical Implementation
The classification is handled by the `ArchetypeAnalyzer.gd` singleton:
- **Data Source**: Derived from the `ConsequenceEngine.choice_log`.
- **Validation**: Every `ticket_completed` event is checked for its `completion_type` (Compliant vs. Efficient/Emergency).
- **Persistence**: Results are gathered via `get_analysis_results()` and persisted through the `SaveSystem` to influence the 14-day narrative arc.
