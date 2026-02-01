# 🧠 Sprint 09: The Great Decoupling & Behavior Library

**Status:** PLANNED
**Focus:** Logic Modernization & Systemic DNA
**Objective:** Eliminate hardcoded string checks and build a Systemic Behavior Pool (Event Pool) to support unlimited threat expansion.

---

## 🎯 Strategic Objectives

1.  **Kill the "String-Matching" Trap:** Remove logic that guesses threat types based on file names.
2.  **Trait-Based Identity:** Implement a `tags: Array[String]` system for all Resources so the engine reacts to behaviors (DNA), not IDs.
3.  **Systemic Behavior Pool:** Build a standardized library of "Payload Handlers" (e.g., UI Glitches, Network Lag, Tool Disabling) that any threat can trigger.
4.  **Self-Contained Consequences:** Move failure logic from the `ConsequenceEngine` into the `TicketResource` itself via "Payload" properties.
5.  **7-Stage Kill Chain Expansion:** Upgrade the architecture to support the full 7-stage Cyber Kill Chain as documented in `CYBERTHREATS.md`.

---

## 📂 File Impact Audit

| File | Type | Change Description |
| :--- | :--- | :--- |
| `resources/tickets/TicketResource.gd` | **Script** | Add `tags`, `on_fail_payloads`, and expand `kill_chain_stage`. |
| `resources/emails/EmailResource.gd` | **Script** | Add `threat_tags` and `on_decision_payloads`. |
| `autoload/ConsequenceEngine.gd` | **Script** | **Major Clean-up:** Delete hardcoded ID checks; replace with tag-based event dispatcher. |
| `autoload/EventBus.gd` | **Script** | Add `system_payload_triggered(payload_id)` signal. |
| `autoload/LogSystem.gd` | **Script** | Add reactor for `SIEM_LAG` behavior. |
| `autoload/TerminalSystem.gd` | **Script** | Add reactor for `CMD_FAILURE` behavior. |

---

## 🛠️ Task Breakdown

### 1. The "Trait" Infrastructure
*   Add `@export var tags: Array[String]` to `TicketResource` and `EmailResource`.
*   Example Tags: `spear_phish`, `malware_payload`, `internal_origin`.

### 2. The Behavior Library (The Event Pool)
*   **Infrastructure:** Update `EventBus` to handle a universal `trigger_payload` signal.
*   **Implement Reactors:** 
    *   `LogSystem`: `SIEM_LAG` (Adds delay to log loading).
    *   `TerminalSystem`: `CMD_ERROR` (Randomly fails commands).
    *   `IntegrityManager`: `INT_STORM` (Accelerates decay).
    *   `DesktopManager`: `UI_GLITCH` (Flickers/glitches windows).

### 3. Data-Driven Failure Logic
*   Add `@export var on_fail_payloads: Array[String]` to `TicketResource`.
*   The engine now simply loops through this array and tells the `EventBus` to trigger each behavior.

### 4. Kill Chain Upgrade
*   Change `kill_chain_stage` logic to handle stages 1 through 7.

---

## ✅ Sprint 09 Completion Criteria
1.  [ ] No scripts contain hardcoded ticket IDs (e.g. `PHISH-001`).
2.  [ ] A new threat type can be created by simply assigning new tags and behaviors in a `.tres` file.
3.  [ ] The 7-stage Kill Chain is supported by the resource schema.
4.  [ ] Failing a ticket with the `SIEM_LAG` payload actually causes the SIEM app to slow down.

> **Note:** This is the "Ultimate Engine Sprint" that turns VERIFY.EXE from a scripted game into a systemic simulation platform.
