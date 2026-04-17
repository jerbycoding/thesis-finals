# TASK 2: THE "LOG POISONER" (SIEM INVERSION)

## Description
Enable decoupled log injection to manipulate the defender's SIEM, ensuring logs are correctly flagged for Mirror Mode and linked to the active spoof identity.

## Implementation Details
*   **Resource:** Create `PoisonLogResource.gd` (inheriting from `LogResource`).
    *   **[BLOCKER]** This resource **must** include `export var is_poison: bool = true`. This flag is critical for the Phase 6 Mirror Mode report and must not be optional.
*   **Decoupled Injection:** The `App_LogPoisoner` scene **must not** call `LogSystem` directly. Instead, it must emit `EventBus.poison_log_requested(log_resource)`. The `LogSystem` will be responsible for listening to this signal.
*   **Schema Validation:** Before emitting the signal, the `App_LogPoisoner` must validate that the `PoisonLogResource` has all required fields populated from its UI (e.g., `source_ip`, `severity_level`, `event_type`, `timestamp`).
*   **Spoof Link:** The `App_LogPoisoner` must check if `GameState.active_spoof_identity` is populated. If it is, the app must automatically use the spoofed IP as the `source_ip` for the injected log, overriding any user input.

## Success Criteria
- [ ] **[BLOCKER]** The `PoisonLogResource` class contains the `is_poison: bool = true` field.
- [ ] **[BLOCKER]** The `App_LogPoisoner` emits the `poison_log_requested` signal instead of calling `LogSystem` directly.
- [ ] An injected log correctly appears in the Analyst's SIEM app with all fields rendered correctly (no blanks).
- [ ] When a spoof is active in `GameState`, the injected log's source IP correctly reflects the spoofed identity.
