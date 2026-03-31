# Signal Registry
## Phase Agent Reference — signals.md
## Authoritative list of all EventBus signals across all phases

Use this file when diagnosing signal bleed, verifying consumer lists,
or checking that a new signal does not collide with an existing one.

---

## Pre-Existing Signals (Phase 0 Baseline)

These existed before Hacker Role implementation. Do not modify names.

| Signal | Emitted By | Consumed By | Notes |
|---|---|---|---|
| _(fill from your EventBus.gd during Phase 0)_ | | | |

---

## Phase 2 Signals

| Signal | Payload | Emitted By | Authorized Consumers | Forbidden Consumers |
|---|---|---|---|---|
| `offensive_action_performed` | `Dictionary` with 5 keys | `TerminalSystem` (exploit/pivot/spoof), `App_PhishCrafter`, Phase 4 apps | `HackerHistory`, `TraceLevelManager` (Phase 3) | `ConsequenceEngine`, `ValidationManager`, `IntegrityManager`, `TicketManager` |
| `poison_log_requested` | `PoisonLogResource` | `App_LogPoisoner` | `LogSystem` | All others |
| `hacker_foothold_established` | `String` (hostname) | `App_PhishCrafter` | `GameState` (foothold update), `HackerHistory` | `ConsequenceEngine` — **MUST NOT consume this. Distinct from `foothold_established`**. |

### Critical Note on `hacker_foothold_established`
This signal is intentionally named differently from any Analyst-side foothold signal.
`ConsequenceEngine` must have an explicit comment stating it does NOT listen to this signal.
If `ConsequenceEngine` ever receives this signal, the Kill Chain will advance incorrectly.

---

## Phase 3 Signals

| Signal | Payload | Emitted By | Authorized Consumers |
|---|---|---|---|
| `rival_ai_state_changed` | `int` (State enum value) | `RivalAI._transition_to()` | UI Trace meter, `AudioManager`, `App_Exfiltrator` (Phase 4) |
| `rival_ai_isolation_complete` | `String` (hostname) | `RivalAI` | `HackerHistory`, `DesktopWindowManager`, `TransitionManager`, `App_Exfiltrator` (Phase 4) |

### Critical Note on `rival_ai_isolation_complete`
`App_Exfiltrator` (Phase 4) must listen for this signal to handle mid-transfer interruption.
Phase 5 `NarrativeDirector` also reuses this signal when an `emergency_patch` fires on
the current foothold — it emits `rival_ai_isolation_complete` as a secondary effect
so `App_Exfiltrator`'s existing interruption path handles it automatically.

---

## Phase 5 Signals

| Signal | Payload | Emitted By | Authorized Consumers |
|---|---|---|---|
| `contract_accepted` | `String` (contract_id) | `App_ContractBoard` | `NarrativeDirector`, `HackerHistory` |
| `contract_submitted` | `String` (contract_id) | `App_ContractBoard` | `NarrativeDirector` |
| `contract_completed` | `String` (contract_id) | `NarrativeDirector` | `BountyLedger`, `HackerHistory`, `NotificationManager` |
| `contract_expired` | `String` (contract_id) | `NarrativeDirector` | `HackerHistory`, `NotificationManager` |
| `hacker_shift_started` | `int` (day number) | `NarrativeDirector` | `TraceLevelManager` (reset), `RivalAI` (reset), `HackerHistory` |
| `hacker_campaign_complete` | none | `NarrativeDirector` | Phase 6 `MirrorMode`, `SaveSystem` |

### Critical Note on `hacker_shift_started`
Both `TraceLevelManager` and `RivalAI` must listen for this signal to reset their
state at the start of each new shift. If either misses this signal, Trace Level
and AI state carry over from the previous shift — breaking the campaign arc.

---

## Phase 6 Signals

| Signal | Payload | Emitted By | Authorized Consumers |
|---|---|---|---|
| `mirror_mode_closed` | none | `MirrorMode.tscn` | `NarrativeDirector` (continues to next shift or ending) |
| `desktop_theme_changed` | `Role` enum value | `DesktopWindowManager.set_theme()` | All UI elements using theme colors (Trace meter, notification toasts) |

---

## Signal Bleed Diagnosis Table

If a system is behaving unexpectedly, check this table for the most
common signal bleed patterns and their root cause.

| Symptom | Signal Being Mishandled | Unauthorized Consumer | Fix |
|---|---|---|---|
| Kill Chain advances on hacker exploit | `offensive_action_performed` | `ConsequenceEngine` | Add Role Guard in `ConsequenceEngine._on_offensive_action_performed()` |
| Integrity drops during hacker shift | `offensive_action_performed` | `IntegrityManager` | Add Role Guard in `IntegrityManager` |
| Ticket gets created on hacker action | `offensive_action_performed` | `TicketManager` | Add Role Guard in `TicketManager` |
| IR validation runs on hacker command | `offensive_action_performed` | `ValidationManager` | Add Role Guard in `ValidationManager` |
| Exfiltrator not interrupted by LOCKDOWN | `rival_ai_state_changed` | `App_Exfiltrator` not listening | Connect listener in `App_Exfiltrator._ready()` |
| Mirror Mode empty after Wiper | `rival_ai_isolation_complete` not emitted by emergency patch | `NarrativeDirector` | Emergency patch must emit `rival_ai_isolation_complete` as side-effect |
| `hacker_shift_started` not resetting Trace | `hacker_shift_started` | `TraceLevelManager` not connected | Connect in `TraceLevelManager._ready()` only during Hacker shifts |

---

## `offensive_action_performed` Payload Schema

All emissions MUST include these exact keys. Missing any key is a contract violation.

```gdscript
{
    "action_type": String,   # "exploit" | "pivot" | "spoof" | "phish" |
                             # "ransomware" | "exfiltration_tick" | "wiper"
    "target":      String,   # hostname or IP
    "timestamp":   float,    # ShiftClock.elapsed_seconds — NOT system time
    "result":      String,   # "SUCCESS" | "FAILED" | "HONEYPOT" | "EVASION" |
                             # "INTERRUPTED" | "SHALLOW" | "STANDARD" | "DEEP"
    "trace_cost":  float,    # From GlobalConstants.TRACE_COST_* — never hardcoded
}
```

### Valid `result` strings by `action_type`

| `action_type` | Valid `result` values |
|---|---|
| `exploit` | `SUCCESS`, `FAILED`, `HONEYPOT` |
| `pivot` | `SUCCESS`, `EVASION` |
| `spoof` | `SUCCESS`, `FAILED` |
| `phish` | `SUCCESS`, `FAILED` |
| `ransomware` | `SUCCESS`, `FAILED` |
| `exfiltration_tick` | `SUCCESS`, `INTERRUPTED` |
| `wiper` | `SHALLOW`, `STANDARD`, `DEEP`, `FAILED` |
