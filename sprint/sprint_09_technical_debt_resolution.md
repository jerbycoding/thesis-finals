# Sprint 9: Core Systems Refactor & Optimization

**Goal:** Resolve critical technical debt identified in the architectural analysis to improve system stability, scalability, and maintainability. This sprint focuses on decoupling core managers and moving logic from UI to Data Resources.

## 1. Structured Host Registry
**Objective:** Replace fragile RegEx-based host discovery with a reliable, resource-driven source of truth.

*   [ ] **Create `HostResource.gd`**
    *   Define host metadata: `hostname`, `ip_address`, `is_critical`, `os_type`.
*   [ ] **Refactor `NetworkState.gd`**
    *   Remove `_discover_hosts_from_resources()` (RegEx parsing).
    *   Implement a `register_hosts_from_folder()` that loads `.tres` files from `res://resources/hosts/`.
*   [ ] **Update Tickets/Logs**
    *   Replace `hostname` strings with `ext_resource` references to `HostResource` files.

## 2. Resource-Driven Risk Logic
**Objective:** Move business logic out of UI scripts (`App_EmailAnalyzer.gd`, `App_SIEMViewer.gd`) into Data Resources.

*   [ ] **Update `EmailResource.gd`**
    *   Implement `is_suspicious()` and `get_risk_score()` methods.
    *   Move "clue detection" logic (e.g., checking extensions, spoofed domains) into the resource.
*   [ ] **Update `LogResource.gd`**
    *   Implement `get_forensic_summary()` to handle BBCode formatting for the SIEM Inspector.
*   [ ] **Clean UI Scripts**
    *   Refactor Apps to simply display data provided by the Resources rather than calculating risk themselves.

## 3. SIEM Performance & Scaling
**Objective:** Ensure the Log Viewer can handle thousands of "noise" logs without micro-stutter.

*   [ ] **Implement Object Pooling**
    *   Create a `UIObjectPool.gd` to manage and reuse `LogEntry.tscn` instances.
*   [ ] **Optimization: Log Stream Data Structure**
    *   Refactor `LogSystem.gd` to use a custom Ring Buffer for the `active_logs` array to ensure O(1) pruning of old data.

## 4. Signal-Driven Architecture (Event Bus)
**Objective:** Reduce the high coupling between Autoload Singletons.

*   [ ] **Create `EventBus.gd` (Autoload)**
    *   Define centralized signals for cross-system events (e.g., `ticket_modified`, `host_state_changed`, `player_action_logged`).
*   [ ] **Decouple Managers**
    *   Refactor `TicketManager` and `ConsequenceEngine` to listen to the `EventBus` rather than directly connecting to every other manager's signals.

## 5. Mock Logic Replacement
**Objective:** Transition from hardcoded strings to dynamic system queries.

*   [ ] **Refactor `TerminalSystem.gd`**
    *   Update `_cmd_logs` to query the actual `LogSystem` for historical data associated with a host.
*   [ ] **Refactor `ArchetypeAnalyzer.gd`**
    *   Ensure all metrics are pulled from the `choice_log` in `ConsequenceEngine` rather than maintaining separate tracking variables.
